(function () {
  // Frontend architecture notes for contributors:
  // - Server renders primary HTML for reliability and first-load speed.
  // - JS progressively enhances pages (inline edits, modal editing, drag/drop, charts).
  // - Keep all network writes CSRF-protected and space-scoped via `withSpace`.
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || "";
  const modal = document.getElementById("card-editor-modal");
  const modalForm = document.getElementById("card-editor-form");
  const modalTitle = document.getElementById("card-editor-title");
  const themeToggle = document.getElementById("theme-toggle");
  const globalNewTaskButton = document.getElementById("global-new-task-btn");

  const defaultTaskStatuses = ["Todo", "In Progress", "Blocked", "Done", "Cancelled"];
  const defaultProjectStatuses = ["Planned", "Active", "Blocked", "Complete"];

  let lookupsPromise = null;
  let cachedLookups = null;
  let onModalSubmit = null;
  let currentTaskScope = "my";
  let currentTaskTeamId = "";
  let taskSearchTimer = null;
  let taskById = new Map();
  let purgeConfirmResolve = null;
  let purgeConfirmLastFocus = null;
  const listSurfaceRegistry = new Map();
  let activeListColumnContext = null;
  const kanbanBoardRegistry = new Map();
  let activeKanbanColumnContext = null;
  const activeSpaceId = new URLSearchParams(window.location.search).get("space_id") || "";

  function escapeHtml(value) {
    if (value === null || value === undefined) {
      return "";
    }
    return String(value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/\"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function splitLines(value) {
    if (!value) {
      return [];
    }
    return String(value)
      .split(/\r?\n/g)
      .map((line) => line.trim())
      .filter(Boolean);
  }

  function escapeCssValue(value) {
    if (window.CSS && typeof window.CSS.escape === "function") {
      return window.CSS.escape(String(value));
    }
    return String(value).replace(/["\\]/g, "\\$&");
  }

  function asInt(value, fallback) {
    if (value === null || value === undefined || value === "") {
      return fallback;
    }
    const parsed = Number.parseInt(String(value), 10);
    return Number.isFinite(parsed) ? parsed : fallback;
  }

  function withSpace(url) {
    // Preserve current space context when calling APIs so edits stay scoped to one makerspace.
    if (!activeSpaceId) {
      return url;
    }
    try {
      const absolute = new URL(url, window.location.origin);
      if (!absolute.searchParams.get("space_id")) {
        absolute.searchParams.set("space_id", activeSpaceId);
      }
      return `${absolute.pathname}${absolute.search}${absolute.hash}`;
    } catch (_err) {
      return url;
    }
  }

  function setTheme(theme) {
    document.body.dataset.theme = theme;
    if (themeToggle) {
      const isDark = theme === "dark";
      themeToggle.textContent = isDark ? "Light" : "Dark";
      themeToggle.setAttribute("aria-pressed", isDark ? "true" : "false");
    }
    window.localStorage.setItem("makerflow-theme", theme);
  }

  function initTheme() {
    const stored = window.localStorage.getItem("makerflow-theme");
    setTheme(stored === "light" ? "light" : "dark");
    if (themeToggle) {
      themeToggle.addEventListener("click", () => {
        setTheme(document.body.dataset.theme === "dark" ? "light" : "dark");
      });
    }
  }

  function closeModal() {
    if (!modal || !modalForm) {
      return;
    }
    modal.setAttribute("aria-hidden", "true");
    modalForm.innerHTML = "";
    onModalSubmit = null;
  }

  function openModal(title, formHtml, submitHandler, submitLabel) {
    if (!modal || !modalForm || !modalTitle) {
      return;
    }
    modalTitle.textContent = title;
    modalForm.innerHTML = `
      ${formHtml}
      <div class="modal-actions">
        <button type="button" class="btn ghost" data-close-modal="1">Cancel</button>
        <button type="submit" class="btn">${escapeHtml(submitLabel || "Save")}</button>
      </div>
      <p class="muted" id="modal-feedback" aria-live="polite"></p>
    `;
    onModalSubmit = submitHandler;
    modal.setAttribute("aria-hidden", "false");
    const firstInput = modalForm.querySelector("input, textarea, select, button");
    if (firstInput) {
      firstInput.focus();
    }
    hydrateModalCommentThreads();
  }

  function setModalFeedback(message, isError) {
    const feedback = document.getElementById("modal-feedback");
    if (!feedback) {
      return;
    }
    feedback.textContent = message || "";
    feedback.classList.toggle("error-text", Boolean(isError));
  }

  function formEncode(payload) {
    // Centralized payload encoder keeps csrf + active space propagation consistent.
    const params = new URLSearchParams();
    Object.keys(payload).forEach((key) => {
      const value = payload[key];
      if (value === undefined || value === null) {
        return;
      }
      params.set(key, String(value));
    });
    params.set("csrf_token", csrfToken);
    if (activeSpaceId && !params.get("active_space_id")) {
      params.set("active_space_id", activeSpaceId);
    }
    return params;
  }

  async function postForm(url, payload) {
    const response = await fetch(withSpace(url), {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
        "X-CSRF-Token": csrfToken,
      },
      credentials: "same-origin",
      body: formEncode(payload).toString(),
    });
    let data = {};
    try {
      data = await response.json();
    } catch (_err) {
      data = {};
    }
    if (!response.ok || data.ok === false) {
      if (data && data.error === "status_required" && Array.isArray(data.required_statuses)) {
        throw new Error(`status_required:${data.required_statuses.join("|")}`);
      }
      throw new Error(data.error || "Request failed");
    }
    return data;
  }

  function describeRequestError(error, entityLabel) {
    const raw = String((error && error.message) || "Request failed");
    if (raw.startsWith("status_required:")) {
      const options = raw.split(":")[1]
        .split("|")
        .map((item) => item.trim())
        .filter(Boolean);
      if (options.length) {
        return `Move this ${entityLabel || "item"} to ${options.join(" or ")} before deleting.`;
      }
      return "Move this item to a terminal status before deleting.";
    }
    if (raw === "invalid_project") {
      return "Select a valid project before saving.";
    }
    if (raw === "missing_space") {
      return "Select or create a makerspace before saving.";
    }
    if (raw === "comment_required") {
      return "Enter a comment before posting.";
    }
    if (raw === "not_found") {
      return "The item no longer exists or was already removed.";
    }
    return raw;
  }

  const interfaceLogTimestamps = new Map();

  function logInterfaceEvent(action, payload, summary, contextKey) {
    const safeAction = String(action || "").trim().toLowerCase().replace(/[^a-z0-9_.-]+/g, "_").slice(0, 64);
    if (!safeAction) {
      return;
    }
    const message = String(summary || safeAction).trim().slice(0, 220);
    const scopeKey = String(contextKey || window.location.pathname || "").slice(0, 120);
    const dedupeKey = `${safeAction}:${scopeKey}:${message}`;
    const nowMs = Date.now();
    const last = interfaceLogTimestamps.get(dedupeKey) || 0;
    if (nowMs - last < 1800) {
      return;
    }
    interfaceLogTimestamps.set(dedupeKey, nowMs);
    let payloadJson = "{}";
    try {
      payloadJson = JSON.stringify(payload || {});
    } catch (_err) {
      payloadJson = JSON.stringify({ value: String(payload || "") });
    }
    const body = formEncode({
      action: safeAction,
      board_key: scopeKey,
      summary: message,
      payload_json: payloadJson,
      path: window.location.pathname || "",
    }).toString();
    fetch(withSpace("/api/interface/log"), {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
        "X-CSRF-Token": csrfToken,
      },
      credentials: "same-origin",
      body,
    }).catch(() => {
      // Never block UX on telemetry/audit logging failures.
    });
  }

  function initInterfaceIssueTracking() {
    if (document.body.dataset.interfaceIssueTracking === "1") {
      return;
    }
    document.body.dataset.interfaceIssueTracking = "1";
    window.addEventListener("error", (event) => {
      logInterfaceEvent(
        "interface_error",
        {
          message: String(event.message || ""),
          source: String(event.filename || ""),
          line: Number(event.lineno || 0),
          column: Number(event.colno || 0),
        },
        "Runtime error",
        window.location.pathname || "",
      );
    });
    window.addEventListener("unhandledrejection", (event) => {
      const reason = event && event.reason;
      const msg = reason instanceof Error ? reason.message : String(reason || "Unhandled rejection");
      logInterfaceEvent(
        "interface_error",
        { message: msg.slice(0, 400) },
        "Unhandled promise rejection",
        window.location.pathname || "",
      );
    });
  }

  async function getLookups() {
    // Lookup payload is shared across many inline-edit widgets; cache it to reduce request load.
    if (!lookupsPromise) {
      lookupsPromise = fetch(withSpace("/api/lookups"), { credentials: "same-origin" })
        .then((res) => {
          if (!res.ok) {
            throw new Error("Could not load lookups");
          }
          return res.json();
        })
        .then((payload) => {
          cachedLookups = payload;
          return payload;
        })
        .catch((err) => {
          lookupsPromise = null;
          throw err;
        });
    }
    return lookupsPromise;
  }

  function selectOptions(items, selectedValue, placeholder) {
    const selected = selectedValue === null || selectedValue === undefined ? "" : String(selectedValue);
    const options = [];
    if (placeholder !== undefined) {
      options.push(`<option value="">${escapeHtml(placeholder)}</option>`);
    }
    (items || []).forEach((item) => {
      const value = String(item.id);
      options.push(`<option value="${escapeHtml(value)}"${value === selected ? " selected" : ""}>${escapeHtml(item.name)}</option>`);
    });
    return options.join("");
  }

  function fixedOptions(items, selectedValue) {
    const selected = selectedValue === null || selectedValue === undefined ? "" : String(selectedValue);
    return (items || [])
      .map((item) => {
        const value = String(item);
        return `<option${value === selected ? " selected" : ""}>${escapeHtml(value)}</option>`;
      })
      .join("");
  }

  function userNameById(lookups, userId) {
    const id = userId === null || userId === undefined ? "" : String(userId);
    const row = (lookups.users || []).find((user) => String(user.id) === id);
    return row ? row.name : "Unassigned";
  }

  function permissionForEntity(lookups, entity) {
    // Keep entity-permission mapping explicit; backend emits capability flags per entity.
    const map = {
      task: "task",
      project: "project",
      intake: "intake",
      asset: "asset",
      consumable: "consumable",
      partnership: "partnership",
      team: "team",
      space: "space",
    };
    const key = map[entity] || entity;
    const perms = (lookups && lookups.permissions && lookups.permissions[key]) || {};
    return {
      can_edit: Boolean(perms.can_edit),
      can_inline_title_edit: Boolean(perms.can_inline_title_edit),
      can_title_select: Boolean(perms.can_title_select),
    };
  }

  function titleOptionsForEntity(lookups, entity) {
    // Mirrors backend entity naming so role-restricted users can pick existing canonical titles.
    const map = {
      task: "tasks",
      project: "projects",
      intake: "intake",
      asset: "assets",
      consumable: "consumables",
      partnership: "partnerships",
      team: "teams",
      space: "spaces",
    };
    const key = map[entity] || entity;
    const options = (lookups && lookups.title_options && lookups.title_options[key]) || [];
    return Array.isArray(options) ? options : [];
  }

  function normalizedOptions(values, currentValue) {
    const out = [];
    const seen = new Set();
    const current = String(currentValue || "");
    (values || []).forEach((value) => {
      const text = String(value || "").trim();
      if (!text || seen.has(text)) {
        return;
      }
      seen.add(text);
      out.push(text);
    });
    if (current && !seen.has(current)) {
      out.unshift(current);
    }
    return out;
  }

  function optionsFromStrings(values, selected, placeholder) {
    const chosen = selected === null || selected === undefined ? "" : String(selected);
    const items = normalizedOptions(values, chosen);
    const opts = [];
    if (placeholder !== undefined) {
      opts.push(`<option value="">${escapeHtml(placeholder)}</option>`);
    }
    items.forEach((value) => {
      opts.push(`<option value="${escapeHtml(value)}"${String(value) === chosen ? " selected" : ""}>${escapeHtml(value)}</option>`);
    });
    return opts.join("");
  }

  function toneToken(value) {
    return String(value || "")
      .trim()
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "");
  }

  function normalizeHexColor(value) {
    const raw = String(value || "").trim();
    if (/^#[0-9a-fA-F]{6}$/.test(raw)) {
      return raw.toLowerCase();
    }
    if (/^#[0-9a-fA-F]{3}$/.test(raw)) {
      const r = raw[1];
      const g = raw[2];
      const b = raw[3];
      return `#${r}${r}${g}${g}${b}${b}`.toLowerCase();
    }
    return "";
  }

  function hexToRgb(color) {
    const hex = normalizeHexColor(color);
    if (!hex) {
      return null;
    }
    const value = hex.slice(1);
    return {
      r: Number.parseInt(value.slice(0, 2), 16),
      g: Number.parseInt(value.slice(2, 4), 16),
      b: Number.parseInt(value.slice(4, 6), 16),
    };
  }

  function textColorForHex(color) {
    const rgb = hexToRgb(color);
    if (!rgb) {
      return "";
    }
    const luminance = (0.299 * rgb.r + 0.587 * rgb.g + 0.114 * rgb.b) / 255;
    return luminance > 0.62 ? "#0f2238" : "#f4f9ff";
  }

  function mixWithBlack(color, ratio) {
    const rgb = hexToRgb(color);
    if (!rgb) {
      return "";
    }
    const weight = Math.max(0, Math.min(1, ratio));
    const r = Math.round(rgb.r * (1 - weight));
    const g = Math.round(rgb.g * (1 - weight));
    const b = Math.round(rgb.b * (1 - weight));
    return `#${[r, g, b].map((part) => part.toString(16).padStart(2, "0")).join("")}`;
  }

  function applyCustomSelectColor(select, color) {
    if (!(select instanceof HTMLSelectElement)) {
      return;
    }
    const hex = normalizeHexColor(color);
    if (!hex) {
      select.style.removeProperty("background-color");
      select.style.removeProperty("border-color");
      select.style.removeProperty("color");
      select.classList.remove("custom-color");
      delete select.dataset.customColor;
      return;
    }
    select.dataset.customColor = hex;
    select.classList.add("custom-color");
    select.style.backgroundColor = hex;
    select.style.borderColor = mixWithBlack(hex, 0.24);
    select.style.color = textColorForHex(hex);
  }

  function applySelectTone(select) {
    if (!select || !(select.classList.contains("quick-status") || select.classList.contains("quick-field"))) {
      return;
    }
    const field = select.getAttribute("data-field") || "";
    if (select.classList.contains("quick-status") || field === "priority") {
      select.dataset.tone = toneToken(select.value || "");
    }
    if (select.dataset.customColor) {
      applyCustomSelectColor(select, select.dataset.customColor);
    } else {
      select.classList.remove("custom-color");
      select.style.removeProperty("background-color");
      select.style.removeProperty("border-color");
      select.style.removeProperty("color");
    }
  }

  function applyPillTone(pill) {
    if (!pill || pill.classList.contains("soft") || pill.classList.contains("status-overdue")) {
      return;
    }
    const token = toneToken(pill.textContent || "");
    if (token) {
      pill.dataset.tone = token;
    }
  }

  function refreshSemanticTones(root) {
    const scope = root || document;
    scope.querySelectorAll(".quick-status, .quick-field").forEach((node) => applySelectTone(node));
    scope.querySelectorAll(".pill").forEach((pill) => applyPillTone(pill));
  }

  function updateCardStatusSelect(card, status) {
    const select = card.querySelector(".quick-status");
    if (select) {
      select.value = status;
      applySelectTone(select);
    }
    if (card.dataset.status !== undefined) {
      card.dataset.status = status;
    }
    if (card.dataset.stage !== undefined && card.classList.contains("partnership-card")) {
      card.dataset.stage = status;
    }
  }

  function syncQuickFieldValue(card, field, value) {
    const node = card.querySelector(`.quick-field[data-field='${field}']`);
    if (node) {
      node.value = value === null || value === undefined ? "" : String(value);
      applySelectTone(node);
    }
  }

  function moveCardToStatus(card, entity, status) {
    const target = document.querySelector(`.drop-zone[data-entity="${entity}"][data-status="${escapeCssValue(status)}"]`);
    if (target && card.parentElement !== target) {
      target.appendChild(card);
    }
    const board = card.closest(".kanban-board");
    refreshColumnCounts(board);
    const boardKey = kanbanBoardKey(board);
    if (boardKey) {
      const registry = kanbanBoardRegistry.get(boardKey);
      if (registry && typeof registry.applyAndSave === "function") {
        registry.applyAndSave();
      }
    }
  }

  function refreshColumnCounts(board) {
    if (!board) {
      return;
    }
    board.querySelectorAll(".kanban-col").forEach((column) => {
      const count = column.querySelector(".kanban-col-head .kanban-col-count, .kanban-col-head span");
      if (count) {
        count.textContent = String(column.querySelectorAll(".kanban-card:not([hidden])").length);
      }
    });
  }

  function titleFieldByEntity(entity) {
    return {
      task: "title",
      project: "name",
      intake: "title",
      asset: "name",
      consumable: "name",
      partnership: "partner_name",
      team: "name",
      space: "name",
    }[entity] || "title";
  }

  function titleControlMarkup(entity, id, title, lookups) {
    const perms = permissionForEntity(lookups, entity);
    const field = titleFieldByEntity(entity);
    const safeTitle = String(title || "Untitled");
    if (perms.can_inline_title_edit) {
      return `<input class="quick-title-input quick-field" data-entity="${escapeHtml(entity)}" data-id="${escapeHtml(id)}" data-field="${escapeHtml(field)}" aria-label="Title" value="${escapeHtml(safeTitle)}" />`;
    }
    if (perms.can_title_select && perms.can_edit) {
      return `<select class="quick-title-select quick-field" data-entity="${escapeHtml(entity)}" data-id="${escapeHtml(id)}" data-field="${escapeHtml(field)}" aria-label="Title">${optionsFromStrings(titleOptionsForEntity(lookups, entity), safeTitle)}</select>`;
    }
    return `<span class="title-readonly">${escapeHtml(safeTitle)}</span>`;
  }

  function quickSelectMarkup(entity, id, field, selected, options, placeholder, disabled) {
    return `
      <select class="quick-field" data-entity="${escapeHtml(entity)}" data-id="${escapeHtml(id)}" data-field="${escapeHtml(field)}"${disabled ? " disabled" : ""}>
        ${optionsFromStrings(options, selected, placeholder)}
      </select>
    `;
  }

  function quickSelectFromObjects(entity, id, field, selected, options, placeholder, disabled) {
    const current = selected === null || selected === undefined ? "" : String(selected);
    const opts = [];
    if (placeholder !== undefined) {
      opts.push(`<option value="">${escapeHtml(placeholder)}</option>`);
    }
    const seen = new Set();
    (options || []).forEach((item) => {
      const value = String(item.id);
      if (seen.has(value)) {
        return;
      }
      seen.add(value);
      opts.push(`<option value="${escapeHtml(value)}"${value === current ? " selected" : ""}>${escapeHtml(item.name)}</option>`);
    });
    if (current && !seen.has(current)) {
      opts.push(`<option value="${escapeHtml(current)}" selected>${escapeHtml(current)}</option>`);
    }
    return `
      <select class="quick-field" data-entity="${escapeHtml(entity)}" data-id="${escapeHtml(id)}" data-field="${escapeHtml(field)}"${disabled ? " disabled" : ""}>
        ${opts.join("")}
      </select>
    `;
  }

  function modalTitleFieldMarkup(lookups, entity, fieldName, label, value, required) {
    const perms = permissionForEntity(lookups, entity);
    const safeValue = String(value || "");
    const req = required ? " required" : "";
    if (perms.can_inline_title_edit) {
      return `<label>${escapeHtml(label)} <input name="${escapeHtml(fieldName)}"${req} value="${escapeHtml(safeValue)}" /></label>`;
    }
    if (perms.can_title_select && perms.can_edit) {
      return `<label>${escapeHtml(label)} <select name="${escapeHtml(fieldName)}"${req}>${optionsFromStrings(titleOptionsForEntity(lookups, entity), safeValue)}</select></label>`;
    }
    return `<label>${escapeHtml(label)} <input name="${escapeHtml(fieldName)}"${req} value="${escapeHtml(safeValue)}" readonly /></label>`;
  }

  function deletePanelMarkup(lookups, entity, itemId, statusValue) {
    if (!itemId) {
      return "";
    }
    const perms = permissionForEntity(lookups, entity);
    if (!perms.can_delete) {
      return "";
    }
    const policy = (lookups.delete_policies && lookups.delete_policies[entity]) || {};
    const required = Array.isArray(policy.ready_statuses) ? policy.ready_statuses.map((value) => String(value)) : [];
    const status = String(statusValue || "");
    const ready = !required.length || required.includes(status);
    const hint = required.length
      ? `Move status to ${required.join(" or ")} to enable delete.`
      : "Delete moves this item into the Deleted queue.";
    if (!ready) {
      return `
        <section class="modal-delete-zone">
          <h4>Delete</h4>
          <p class="muted">${escapeHtml(hint)}</p>
        </section>
      `;
    }
    return `
      <section class="modal-delete-zone">
        <h4>Delete</h4>
        <p class="muted">This will move the item to Deleted Items where workspace admins can restore or purge it.</p>
        <button type="button" class="btn danger-btn" data-delete-entity="${escapeHtml(entity)}" data-delete-id="${escapeHtml(itemId)}">Move to Deleted</button>
      </section>
    `;
  }

  function commentThreadMarkup(entity, itemId) {
    if (!itemId || !["task", "project"].includes(String(entity || ""))) {
      return "";
    }
    return `
      <section class="modal-comment-thread" data-comment-thread="1" data-entity="${escapeHtml(entity)}" data-item-id="${escapeHtml(itemId)}">
        <h4>Comment Thread</h4>
        <div class="comment-list"><p class="muted">Loading comments...</p></div>
        <div class="comment-compose">
          <textarea rows="3" data-comment-body placeholder="Add update, decision, blocker, or handoff note... Use @name or @email to mention teammates."></textarea>
          <button type="button" class="btn ghost" data-comment-submit="1">Post Comment</button>
        </div>
      </section>
    `;
  }

  function inlineCardChatMarkup(entity, itemId) {
    if (!itemId || !["task", "project"].includes(String(entity || ""))) {
      return "";
    }
    return `
      <details class="card-chat" data-inline-chat="1" data-entity="${escapeHtml(entity)}" data-item-id="${escapeHtml(itemId)}">
        <summary>Chat</summary>
        <div class="card-chat-list" data-inline-chat-list="1"><p class="muted">Open to load thread...</p></div>
        <div class="card-chat-compose">
          <textarea rows="2" data-inline-comment-body placeholder="Reply... @mention teammates"></textarea>
          <button type="button" class="btn ghost" data-inline-comment-submit="1">Post</button>
        </div>
      </details>
    `;
  }

  function formatCommentTimestamp(value) {
    if (!value) {
      return "-";
    }
    const date = new Date(String(value));
    if (Number.isNaN(date.getTime())) {
      return String(value);
    }
    return date.toLocaleString();
  }

  function renderCommentList(container, comments) {
    if (!container) {
      return;
    }
    if (!Array.isArray(comments) || !comments.length) {
      container.innerHTML = "<p class='muted'>No comments yet.</p>";
      return;
    }
    container.innerHTML = comments
      .map((comment) => {
        const name = comment.author_name || "Unknown";
        const body = comment.body || "";
        const created = formatCommentTimestamp(comment.created_at || "");
        return `
          <article class="comment-item">
            <header><strong>${escapeHtml(name)}</strong><span class="muted">${escapeHtml(created)}</span></header>
            <p>${escapeHtml(body)}</p>
          </article>
        `;
      })
      .join("");
  }

  async function loadCommentThread(threadNode) {
    if (!threadNode) {
      return;
    }
    const entity = threadNode.getAttribute("data-entity") || "";
    const itemId = threadNode.getAttribute("data-item-id") || "";
    const listNode = threadNode.querySelector(".comment-list");
    if (!entity || !itemId || !listNode) {
      return;
    }
    try {
      const response = await fetch(withSpace(`/api/comments?entity=${encodeURIComponent(entity)}&item_id=${encodeURIComponent(itemId)}`), {
        credentials: "same-origin",
      });
      if (!response.ok) {
        throw new Error("Could not load comments.");
      }
      const payload = await response.json();
      renderCommentList(listNode, payload.comments || []);
    } catch (err) {
      listNode.innerHTML = `<p class='error-text'>${escapeHtml(describeRequestError(err, entity))}</p>`;
    }
  }

  function hydrateModalCommentThreads() {
    if (!modalForm) {
      return;
    }
    modalForm.querySelectorAll("[data-comment-thread='1']").forEach((threadNode) => {
      loadCommentThread(threadNode);
    });
  }

  async function loadInlineCardChat(threadNode) {
    if (!threadNode) {
      return;
    }
    const entity = String(threadNode.getAttribute("data-entity") || "").trim();
    const itemId = String(threadNode.getAttribute("data-item-id") || "").trim();
    const listNode = threadNode.querySelector("[data-inline-chat-list='1']");
    if (!entity || !itemId || !listNode) {
      return;
    }
    listNode.innerHTML = "<p class='muted'>Loading comments...</p>";
    try {
      const response = await fetch(withSpace(`/api/comments?entity=${encodeURIComponent(entity)}&item_id=${encodeURIComponent(itemId)}`), {
        credentials: "same-origin",
      });
      if (!response.ok) {
        throw new Error("Could not load comments.");
      }
      const payload = await response.json();
      renderCommentList(listNode, payload.comments || []);
    } catch (err) {
      listNode.innerHTML = `<p class='error-text'>${escapeHtml(describeRequestError(err, entity))}</p>`;
    }
  }

  function ensureInlineCardChatForBoard(board, entity, cardSelector) {
    if (!board || !entity || !cardSelector) {
      return;
    }
    board.querySelectorAll(cardSelector).forEach((card) => {
      if (!(card instanceof HTMLElement)) {
        return;
      }
      if (card.querySelector("[data-inline-chat='1']")) {
        return;
      }
      const id = String(card.dataset.id || "").trim();
      if (!id) {
        return;
      }
      const shell = document.createElement("div");
      shell.innerHTML = inlineCardChatMarkup(entity, id).trim();
      if (shell.firstElementChild) {
        card.appendChild(shell.firstElementChild);
      }
    });
  }

  async function openTaskEditor(task, isNew) {
    const lookups = await getLookups();
    const extra = task.extra && typeof task.extra === "object" && Object.keys(task.extra).length
      ? JSON.stringify(task.extra, null, 2)
      : "";

    const formHtml = `
      <input type="hidden" name="task_id" value="${escapeHtml(task.id || "")}" />
      <section class="entity-editor">
        <div class="entity-editor-title">
          ${modalTitleFieldMarkup(lookups, "task", "title", "Task Title", task.title || "", true)}
        </div>
        <div class="entity-editor-meta-grid">
          <label>Status <select name="status">${fixedOptions(lookups.task_statuses || defaultTaskStatuses, task.status || "Todo")}</select></label>
          <label>Priority <select name="priority">${fixedOptions(lookups.priorities || ["Low", "Medium", "High", "Critical"], task.priority || "Medium")}</select></label>
          <label>Assignee <select name="assignee_user_id">${selectOptions(lookups.users, task.assignee_user_id, "Unassigned")}</select></label>
          <label>Project <select name="project_id">${selectOptions(lookups.projects, task.project_id, "Auto: Lab Maintenance")}</select></label>
          <label>Due Date <input type="date" name="due_date" value="${escapeHtml(task.due_date || "")}" /></label>
          <label>Estimate Hours <input type="number" min="0" step="0.25" name="estimate_hours" value="${escapeHtml(task.estimate_hours || "")}" /></label>
          <label>Team <select name="team_id">${selectOptions(lookups.teams, task.team_id, "Unassigned")}</select></label>
          <label>Space <select name="space_id">${selectOptions(lookups.spaces, task.space_id, "Auto: Default Space")}</select></label>
          <label>Energy <select name="energy">${fixedOptions(lookups.energies || ["Low", "Medium", "High"], task.energy || "Medium")}</select></label>
        </div>
        <div class="entity-editor-columns">
          <div class="entity-editor-main">
            <label class="field-block">Description <textarea name="description">${escapeHtml(task.description || "")}</textarea></label>
            <label class="field-block">External Docs / Attachments (one URL per line) <textarea name="attachments">${escapeHtml((task.attachments || []).join("\n"))}</textarea></label>
            <label class="field-block">Working Notes <textarea name="note">${escapeHtml(task.note || "")}</textarea></label>
            <label class="field-block">Extra Metadata (JSON object) <textarea name="extra_json" placeholder='{"impact_goal":"..."}'>${escapeHtml(extra)}</textarea></label>
          </div>
          <aside class="entity-editor-side">
            <p class="muted">Team chat supports <code>@mentions</code> and sends notifications.</p>
            ${commentThreadMarkup("task", task.id || "")}
            ${deletePanelMarkup(lookups, "task", task.id || "", task.status || "Todo")}
          </aside>
        </div>
      </section>
    `;

    openModal(isNew ? "New Task" : "Edit Task", formHtml, async (formData) => {
      const payload = Object.fromEntries(formData.entries());
      try {
        if (isNew) {
          await postForm("/api/tasks/create", payload);
        } else {
          await postForm("/api/tasks/save", payload);
        }
        closeModal();
        if (document.getElementById("task-kanban")) {
          await refreshTaskBoard();
        } else {
          window.location.href = withSpace("/tasks?msg=Task%20saved");
        }
      } catch (err) {
        setModalFeedback(describeRequestError(err, "task"), true);
      }
    }, isNew ? "Create Task" : "Save Task");
  }

  function projectFromCard(card) {
    return {
      id: card.dataset.id,
      name: card.dataset.name || "",
      description: card.dataset.description || "",
      lane: card.dataset.lane || "Core Operations",
      status: card.dataset.status || "Planned",
      priority: card.dataset.priority || "Medium",
      owner_user_id: card.dataset.ownerId || "",
      team_id: card.dataset.teamId || "",
      space_id: card.dataset.spaceId || "",
      start_date: card.dataset.startDate || "",
      due_date: card.dataset.dueDate || "",
      progress_pct: card.dataset.progressPct || "0",
      tags: card.dataset.tags || "",
      note: card.dataset.note || "",
      attachments: splitLines(card.dataset.attachments || ""),
      extra: {},
    };
  }

  async function openProjectEditor(card) {
    const lookups = await getLookups();
    const project = projectFromCard(card);

    const formHtml = `
      <input type="hidden" name="project_id" value="${escapeHtml(project.id)}" />
      <section class="entity-editor">
        <div class="entity-editor-title">
          ${modalTitleFieldMarkup(lookups, "project", "name", "Project Name", project.name || "", true)}
        </div>
        <div class="entity-editor-meta-grid">
          <label>Status <select name="status">${fixedOptions(lookups.project_statuses || defaultProjectStatuses, project.status || "Planned")}</select></label>
          <label>Lane <select name="lane">${fixedOptions(lookups.lanes || [], project.lane || "Core Operations")}</select></label>
          <label>Priority <select name="priority">${fixedOptions(lookups.priorities || ["Low", "Medium", "High", "Critical"], project.priority || "Medium")}</select></label>
          <label>Owner <select name="owner_user_id">${selectOptions(lookups.users, project.owner_user_id, "Unassigned")}</select></label>
          <label>Progress % <input type="number" min="0" max="100" name="progress_pct" value="${escapeHtml(project.progress_pct || 0)}" /></label>
          <label>Team <select name="team_id">${selectOptions(lookups.teams, project.team_id, "Unassigned")}</select></label>
          <label>Space <select name="space_id">${selectOptions(lookups.spaces, project.space_id, "Unassigned")}</select></label>
          <label>Start Date <input type="date" name="start_date" value="${escapeHtml(project.start_date || "")}" /></label>
          <label>Due Date <input type="date" name="due_date" value="${escapeHtml(project.due_date || "")}" /></label>
        </div>
        <div class="entity-editor-columns">
          <div class="entity-editor-main">
            <label class="field-block">Tags <input name="tags" value="${escapeHtml(project.tags || "")}" /></label>
            <label class="field-block">Description <textarea name="description">${escapeHtml(project.description || "")}</textarea></label>
            <label class="field-block">External Docs / Attachments (one URL per line) <textarea name="attachments">${escapeHtml((project.attachments || []).join("\n"))}</textarea></label>
            <label class="field-block">Working Notes <textarea name="note">${escapeHtml(project.note || "")}</textarea></label>
          </div>
          <aside class="entity-editor-side">
            <p class="muted">Project updates can tag teammates with <code>@mentions</code>.</p>
            ${commentThreadMarkup("project", project.id || "")}
            ${deletePanelMarkup(lookups, "project", project.id || "", project.status || "Planned")}
          </aside>
        </div>
      </section>
    `;

    openModal("Edit Project", formHtml, async (formData) => {
      const payload = Object.fromEntries(formData.entries());
      try {
        const result = await postForm("/api/projects/save", payload);
        applyProjectUpdate(card, payload, result.status);
        closeModal();
      } catch (err) {
        setModalFeedback(describeRequestError(err, "project"), true);
      }
    }, "Save Project");
  }

  function applyProjectUpdate(card, payload, serverStatus) {
    const status = serverStatus || payload.status || card.dataset.status || "Planned";
    card.dataset.name = payload.name || card.dataset.name || "";
    card.dataset.description = payload.description || card.dataset.description || "";
    card.dataset.lane = payload.lane || card.dataset.lane || "Core Operations";
    card.dataset.status = status;
    card.dataset.priority = payload.priority || card.dataset.priority || "Medium";
    card.dataset.ownerId = payload.owner_user_id || card.dataset.ownerId || "";
    card.dataset.teamId = payload.team_id || card.dataset.teamId || "";
    card.dataset.spaceId = payload.space_id || card.dataset.spaceId || "";
    card.dataset.startDate = payload.start_date || card.dataset.startDate || "";
    card.dataset.dueDate = payload.due_date || card.dataset.dueDate || "";
    card.dataset.progressPct = payload.progress_pct || card.dataset.progressPct || "0";
    card.dataset.tags = payload.tags || card.dataset.tags || "";
    card.dataset.note = payload.note || card.dataset.note || "";
    card.dataset.attachments = payload.attachments || card.dataset.attachments || "";

    const title = card.querySelector(".card-title-label");
    if (title) {
      title.innerHTML = titleControlMarkup("project", card.dataset.id || "", card.dataset.name || "Untitled", cachedLookups || {});
    }
    const prioritySelect = card.querySelector(".quick-field[data-field='priority']");
    if (prioritySelect) {
      prioritySelect.value = card.dataset.priority;
    }
    syncQuickFieldValue(card, "team_id", card.dataset.teamId || "");
    syncQuickFieldValue(card, "space_id", card.dataset.spaceId || "");
    syncQuickFieldValue(card, "owner_user_id", card.dataset.ownerId || "");
    const progressBar = card.querySelector(".progress span");
    if (progressBar) {
      const pct = asInt(card.dataset.progressPct, 0);
      progressBar.style.width = `${Math.max(0, Math.min(100, pct))}%`;
    }

    updateCardStatusSelect(card, status);
    moveCardToStatus(card, "project", status);
    syncStaticCardSummary(card, "project", cachedLookups || {});
  }

  function intakeFromCard(card) {
    return {
      id: card.dataset.id,
      title: card.dataset.title || "",
      lane: card.dataset.lane || "Core Operations",
      urgency: card.dataset.urgency || "3",
      impact: card.dataset.impact || "3",
      effort: card.dataset.effort || "3",
      status: card.dataset.status || "Triage",
      owner_user_id: card.dataset.ownerId || "",
      details: card.dataset.details || "",
      requestor_name: card.dataset.requestorName || "",
      requestor_email: card.dataset.requestorEmail || "",
    };
  }

  async function openIntakeEditor(card) {
    const lookups = await getLookups();
    const intake = intakeFromCard(card);
    const formHtml = `
      <input type="hidden" name="intake_id" value="${escapeHtml(intake.id)}" />
      <div class="modal-grid two-col">
        ${modalTitleFieldMarkup(lookups, "intake", "title", "Title", intake.title || "", true)}
        <label>Status <select name="status">${fixedOptions(lookups.intake_statuses || [], intake.status)}</select></label>
        <label>Lane <select name="lane">${fixedOptions(lookups.lanes || [], intake.lane)}</select></label>
        <label>Owner <select name="owner_user_id">${selectOptions(lookups.users, intake.owner_user_id, "Unassigned")}</select></label>
        <label>Urgency (1-5) <input type="number" min="1" max="5" name="urgency" value="${escapeHtml(intake.urgency)}" /></label>
        <label>Impact (1-5) <input type="number" min="1" max="5" name="impact" value="${escapeHtml(intake.impact)}" /></label>
        <label>Effort (1-5) <input type="number" min="1" max="5" name="effort" value="${escapeHtml(intake.effort)}" /></label>
        <label>Requestor Name <input name="requestor_name" value="${escapeHtml(intake.requestor_name)}" /></label>
        <label>Requestor Email <input type="email" name="requestor_email" value="${escapeHtml(intake.requestor_email)}" /></label>
      </div>
      <label>Details <textarea name="details">${escapeHtml(intake.details)}</textarea></label>
      ${deletePanelMarkup(lookups, "intake", intake.id || "", intake.status || "Triage")}
    `;

    openModal("Edit Intake Item", formHtml, async (formData) => {
      const payload = Object.fromEntries(formData.entries());
      try {
        const result = await postForm("/api/intake/save", payload);
        const ownerName = userNameById(lookups, payload.owner_user_id);
        card.dataset.title = payload.title || card.dataset.title;
        card.dataset.status = result.status || payload.status || card.dataset.status;
        card.dataset.lane = payload.lane || card.dataset.lane;
        card.dataset.ownerId = payload.owner_user_id || "";
        card.dataset.urgency = payload.urgency || card.dataset.urgency;
        card.dataset.impact = payload.impact || card.dataset.impact;
        card.dataset.effort = payload.effort || card.dataset.effort;
        card.dataset.details = payload.details || "";
        card.dataset.requestorName = payload.requestor_name || "";
        card.dataset.requestorEmail = payload.requestor_email || "";

        const title = card.querySelector(".card-title-label");
        if (title) {
          title.innerHTML = titleControlMarkup("intake", card.dataset.id || "", card.dataset.title || "Untitled", lookups);
        }
        const line1 = card.querySelector(".meta-line-1");
        const line2 = card.querySelector(".meta-line-2");
        if (line1) {
          line1.textContent = `${card.dataset.lane} · Owner: ${ownerName}`;
        }
        if (line2) {
          line2.innerHTML = `Score: <strong>${escapeHtml(result.score || "-")}</strong> · U/I/E: ${escapeHtml(card.dataset.urgency)}/${escapeHtml(card.dataset.impact)}/${escapeHtml(card.dataset.effort)}`;
        }
        syncQuickFieldValue(card, "lane", card.dataset.lane || "");
        syncQuickFieldValue(card, "owner_user_id", card.dataset.ownerId || "");

        updateCardStatusSelect(card, card.dataset.status);
        moveCardToStatus(card, "intake", card.dataset.status);
        closeModal();
      } catch (err) {
        setModalFeedback(describeRequestError(err, "intake item"), true);
      }
    }, "Save Intake Item");
  }

  function assetFromCard(card) {
    return {
      id: card.dataset.id,
      name: card.dataset.name || "",
      space: card.dataset.space || "",
      asset_type: card.dataset.assetType || "",
      status: card.dataset.status || "Operational",
      last_maintenance: card.dataset.lastMaintenance || "",
      next_maintenance: card.dataset.nextMaintenance || "",
      cert_required: card.dataset.certRequired === "1",
      cert_name: card.dataset.certName || "",
      owner_user_id: card.dataset.ownerId || "",
      notes: card.dataset.notes || "",
    };
  }

  async function openAssetEditor(card) {
    const lookups = await getLookups();
    const asset = assetFromCard(card);

    const formHtml = `
      <input type="hidden" name="asset_id" value="${escapeHtml(asset.id)}" />
      <div class="modal-grid two-col">
        ${modalTitleFieldMarkup(lookups, "asset", "name", "Name", asset.name || "", true)}
        <label>Status <select name="status">${fixedOptions(lookups.asset_statuses || [], asset.status)}</select></label>
        <label>Space <input name="space" required value="${escapeHtml(asset.space)}" /></label>
        <label>Type <input name="asset_type" value="${escapeHtml(asset.asset_type)}" /></label>
        <label>Last Maintenance <input type="date" name="last_maintenance" value="${escapeHtml(asset.last_maintenance)}" /></label>
        <label>Next Maintenance <input type="date" name="next_maintenance" value="${escapeHtml(asset.next_maintenance)}" /></label>
        <label>Owner <select name="owner_user_id">${selectOptions(lookups.users, asset.owner_user_id, "Unassigned")}</select></label>
        <label>Certification Name <input name="cert_name" value="${escapeHtml(asset.cert_name)}" /></label>
        <label><input type="checkbox" name="cert_required" value="1" ${asset.cert_required ? "checked" : ""} /> Certification required</label>
      </div>
      <label>Notes <textarea name="notes">${escapeHtml(asset.notes)}</textarea></label>
      ${deletePanelMarkup(lookups, "asset", asset.id || "", asset.status || "Operational")}
    `;

    openModal("Edit Asset", formHtml, async (formData) => {
      const payload = Object.fromEntries(formData.entries());
      payload.cert_required = formData.get("cert_required") ? "1" : "0";
      try {
        const result = await postForm("/api/assets/save", payload);
        card.dataset.name = payload.name || card.dataset.name;
        card.dataset.space = payload.space || card.dataset.space;
        card.dataset.assetType = payload.asset_type || "";
        card.dataset.status = result.status || payload.status || card.dataset.status;
        card.dataset.lastMaintenance = payload.last_maintenance || "";
        card.dataset.nextMaintenance = payload.next_maintenance || "";
        card.dataset.certRequired = payload.cert_required;
        card.dataset.certName = payload.cert_name || "";
        card.dataset.ownerId = payload.owner_user_id || "";
        card.dataset.notes = payload.notes || "";

        const title = card.querySelector(".card-title-label");
        if (title) {
          title.innerHTML = titleControlMarkup("asset", card.dataset.id || "", card.dataset.name || "Untitled", lookups);
        }
        const ownerName = userNameById(lookups, payload.owner_user_id);
        const line1 = card.querySelector(".meta-line-1");
        const line2 = card.querySelector(".meta-line-2");
        if (line1) {
          line1.textContent = `${card.dataset.space} · ${card.dataset.assetType || "-"}`;
        }
        if (line2) {
          line2.textContent = `Owner: ${ownerName} · Next: ${card.dataset.nextMaintenance || "-"}`;
        }
        syncQuickFieldValue(card, "space", card.dataset.space || "");
        syncQuickFieldValue(card, "owner_user_id", card.dataset.ownerId || "");

        updateCardStatusSelect(card, card.dataset.status);
        moveCardToStatus(card, "asset", card.dataset.status);
        closeModal();
      } catch (err) {
        setModalFeedback(describeRequestError(err, "asset"), true);
      }
    }, "Save Asset");
  }

  function consumableFromCard(card) {
    return {
      id: card.dataset.id,
      name: card.dataset.name || "",
      category: card.dataset.category || "",
      space_id: card.dataset.spaceId || "",
      quantity_on_hand: card.dataset.quantityOnHand || "0",
      unit: card.dataset.unit || "",
      reorder_point: card.dataset.reorderPoint || "0",
      status: card.dataset.status || "In Stock",
      owner_user_id: card.dataset.ownerId || "",
      notes: card.dataset.notes || "",
    };
  }

  async function openConsumableEditor(card) {
    const lookups = await getLookups();
    const consumable = consumableFromCard(card);
    const statuses = lookups.consumable_statuses || ["In Stock", "Low", "Out"];
    const formHtml = `
      <input type="hidden" name="consumable_id" value="${escapeHtml(consumable.id)}" />
      <div class="modal-grid two-col">
        ${modalTitleFieldMarkup(lookups, "consumable", "name", "Name", consumable.name || "", true)}
        <label>Status <select name="status">${fixedOptions(statuses, consumable.status)}</select></label>
        <label>Category <input name="category" value="${escapeHtml(consumable.category)}" /></label>
        <label>Space <select name="space_id" required>${selectOptions(lookups.spaces, consumable.space_id, "Select space")}</select></label>
        <label>Quantity on hand <input type="number" min="0" step="0.01" name="quantity_on_hand" value="${escapeHtml(consumable.quantity_on_hand)}" /></label>
        <label>Unit <input name="unit" value="${escapeHtml(consumable.unit)}" /></label>
        <label>Reorder point <input type="number" min="0" step="0.01" name="reorder_point" value="${escapeHtml(consumable.reorder_point)}" /></label>
        <label>Owner <select name="owner_user_id">${selectOptions(lookups.users, consumable.owner_user_id, "Unassigned")}</select></label>
      </div>
      <label>Notes <textarea name="notes">${escapeHtml(consumable.notes)}</textarea></label>
      ${deletePanelMarkup(lookups, "consumable", consumable.id || "", consumable.status || "In Stock")}
    `;

    openModal("Edit Consumable", formHtml, async (formData) => {
      const payload = Object.fromEntries(formData.entries());
      try {
        const result = await postForm("/api/consumables/save", payload);
        card.dataset.name = payload.name || card.dataset.name;
        card.dataset.category = payload.category || "";
        card.dataset.spaceId = payload.space_id || "";
        card.dataset.quantityOnHand = payload.quantity_on_hand || "0";
        card.dataset.unit = payload.unit || "";
        card.dataset.reorderPoint = payload.reorder_point || "0";
        card.dataset.status = result.status || payload.status || card.dataset.status;
        card.dataset.ownerId = payload.owner_user_id || "";
        card.dataset.notes = payload.notes || "";

        const title = card.querySelector(".card-title-label");
        if (title) {
          title.innerHTML = titleControlMarkup("consumable", card.dataset.id || "", card.dataset.name || "Untitled", lookups);
        }
        const spaceName = (lookups.spaces || []).find((space) => String(space.id) === String(card.dataset.spaceId))?.name || "No space";
        const ownerName = userNameById(lookups, payload.owner_user_id);
        const line1 = card.querySelector(".meta-line-1");
        const line2 = card.querySelector(".meta-line-2");
        const line3 = card.querySelector(".meta-line-3");
        if (line1) {
          line1.textContent = `${spaceName} · ${card.dataset.category || "-"}`;
        }
        if (line2) {
          line2.textContent = `On hand: ${card.dataset.quantityOnHand || "0"} ${card.dataset.unit || ""} · Reorder at ${card.dataset.reorderPoint || "0"}`;
        }
        if (line3) {
          line3.textContent = `Owner: ${ownerName}`;
        }
        syncQuickFieldValue(card, "space_id", card.dataset.spaceId || "");
        syncQuickFieldValue(card, "owner_user_id", card.dataset.ownerId || "");

        updateCardStatusSelect(card, card.dataset.status);
        moveCardToStatus(card, "consumable", card.dataset.status);
        closeModal();
      } catch (err) {
        setModalFeedback(describeRequestError(err, "consumable"), true);
      }
    }, "Save Consumable");
  }

  function partnershipFromCard(card) {
    return {
      id: card.dataset.id,
      partner_name: card.dataset.partnerName || "",
      school: card.dataset.school || "",
      stage: card.dataset.stage || "Discovery",
      health: card.dataset.health || "Medium",
      last_contact: card.dataset.lastContact || "",
      next_followup: card.dataset.nextFollowup || "",
      owner_user_id: card.dataset.ownerId || "",
      notes: card.dataset.notes || "",
    };
  }

  async function openPartnershipEditor(card) {
    const lookups = await getLookups();
    const partnership = partnershipFromCard(card);

    const formHtml = `
      <input type="hidden" name="partnership_id" value="${escapeHtml(partnership.id)}" />
      <div class="modal-grid two-col">
        ${modalTitleFieldMarkup(lookups, "partnership", "partner_name", "Partner Name", partnership.partner_name || "", true)}
        <label>Stage <select name="stage">${fixedOptions(lookups.partnership_stages || [], partnership.stage)}</select></label>
        <label>School / Unit <input name="school" value="${escapeHtml(partnership.school)}" /></label>
        <label>Health <select name="health">${fixedOptions(lookups.partnership_healths || ["Strong", "Medium", "At Risk"], partnership.health)}</select></label>
        <label>Last Contact <input type="date" name="last_contact" value="${escapeHtml(partnership.last_contact)}" /></label>
        <label>Next Followup <input type="date" name="next_followup" value="${escapeHtml(partnership.next_followup)}" /></label>
        <label>Owner <select name="owner_user_id">${selectOptions(lookups.users, partnership.owner_user_id, "Unassigned")}</select></label>
      </div>
      <label>Notes <textarea name="notes">${escapeHtml(partnership.notes)}</textarea></label>
      ${deletePanelMarkup(lookups, "partnership", partnership.id || "", partnership.stage || "Discovery")}
    `;

    openModal("Edit Partnership", formHtml, async (formData) => {
      const payload = Object.fromEntries(formData.entries());
      try {
        const result = await postForm("/api/partnerships/save", payload);
        card.dataset.partnerName = payload.partner_name || card.dataset.partnerName;
        card.dataset.school = payload.school || "";
        card.dataset.stage = result.status || payload.stage || card.dataset.stage;
        card.dataset.status = card.dataset.stage;
        card.dataset.health = payload.health || card.dataset.health;
        card.dataset.lastContact = payload.last_contact || "";
        card.dataset.nextFollowup = payload.next_followup || "";
        card.dataset.ownerId = payload.owner_user_id || "";
        card.dataset.notes = payload.notes || "";

        const title = card.querySelector(".card-title-label");
        if (title) {
          title.innerHTML = titleControlMarkup("partnership", card.dataset.id || "", card.dataset.partnerName || "Untitled", lookups);
        }
        const ownerName = userNameById(lookups, payload.owner_user_id);
        const line1 = card.querySelector(".meta-line-1");
        const line2 = card.querySelector(".meta-line-2");
        if (line1) {
          line1.textContent = `${card.dataset.school || "-"} · ${card.dataset.health || "Medium"}`;
        }
        if (line2) {
          line2.textContent = `Owner: ${ownerName} · Follow-up: ${card.dataset.nextFollowup || "-"}`;
        }
        syncQuickFieldValue(card, "health", card.dataset.health || "Medium");
        syncQuickFieldValue(card, "owner_user_id", card.dataset.ownerId || "");

        updateCardStatusSelect(card, card.dataset.stage);
        moveCardToStatus(card, "partnership", card.dataset.stage);
        closeModal();
      } catch (err) {
        setModalFeedback(describeRequestError(err, "partnership"), true);
      }
    }, "Save Partnership");
  }

  function taskCardMarkup(task) {
    const refs = Array.isArray(task.attachments) && task.attachments.length
      ? `<span class="pill soft">+${task.attachments.length} refs</span>`
      : "";
    const description = task.description || "No description provided.";
    const snippet = description.length > 100 ? `${description.slice(0, 100).trim()}...` : description;
    const lookups = cachedLookups || {};
    const users = lookups.users || [];
    const teams = lookups.teams || [];
    const spaces = lookups.spaces || [];
    const statuses = lookups.task_statuses || defaultTaskStatuses;
    const priorities = lookups.priorities || ["Low", "Medium", "High", "Critical"];
    const perms = permissionForEntity(lookups, "task");
    const selectedAssignee = task.assignee_user_id === null || task.assignee_user_id === undefined ? "" : String(task.assignee_user_id);
    const assigneeOptions = ["<option value=''>Unassigned</option>"];
    users.forEach((user) => {
      const value = String(user.id);
      assigneeOptions.push(`<option value="${escapeHtml(value)}"${value === selectedAssignee ? " selected" : ""}>${escapeHtml(user.name)}</option>`);
    });

    return `
      <article class="kanban-card interactive-card task-card"
        draggable="true"
        tabindex="0"
        data-entity="task"
        data-id="${escapeHtml(task.id)}"
        data-title="${escapeHtml(task.title || "Untitled Task")}"
        data-priority="${escapeHtml(task.priority || "Medium")}"
        data-team-id="${escapeHtml(task.team_id || "")}"
        data-space-id="${escapeHtml(task.space_id || "")}"
        data-assignee-id="${escapeHtml(task.assignee_user_id || "")}"
        data-project-id="${escapeHtml(task.project_id || "")}"
        data-due-date="${escapeHtml(task.due_date || "")}"
        data-status="${escapeHtml(task.status || "Todo")}">
        <div class="card-topline">
          <h5 class="card-title-label">${titleControlMarkup("task", task.id, task.title || "Untitled Task", lookups)}</h5>
          <div class="inline">
            <select class="quick-status" data-entity="task" data-id="${escapeHtml(task.id)}" aria-label="Status for ${escapeHtml(task.title || "task")}"${!perms.can_edit ? " disabled" : ""}>
              ${fixedOptions(statuses, task.status || "Todo")}
            </select>
            ${quickSelectMarkup("task", task.id, "priority", task.priority || "Medium", priorities, undefined, !perms.can_edit)}
            ${refs}
          </div>
        </div>
        <p class="muted meta-line-1">${escapeHtml(task.project || "No project")} · ${escapeHtml(task.assignee || "Unassigned")}</p>
        <p class="muted meta-line-2">Due: ${escapeHtml(task.due_date || "-")} · Energy: ${escapeHtml(task.energy || "-")} · Team: ${escapeHtml(task.team || "-")}</p>
        <div class="inline quick-edit-row">
          <span class="muted">Owner</span>
          <select class="quick-assignee quick-field" data-entity="task" data-id="${escapeHtml(task.id)}" data-field="assignee_user_id" aria-label="Assignee for ${escapeHtml(task.title || "task")}"${!perms.can_edit ? " disabled" : ""}>${assigneeOptions.join("")}</select>
          ${quickSelectFromObjects("task", task.id, "team_id", task.team_id, teams, "No team", !perms.can_edit)}
          ${quickSelectFromObjects("task", task.id, "space_id", task.space_id, spaces, "No space", !perms.can_edit)}
        </div>
        <p class="muted meta-line-3">${escapeHtml(snippet)}</p>
        <p class="card-hint">Click to edit · Drag to move</p>
        ${inlineCardChatMarkup("task", task.id)}
      </article>
    `;
  }

  function renderTaskBoard(board, tasks, statuses) {
    const grouped = {};
    statuses.forEach((status) => {
      grouped[status] = [];
    });

    tasks.forEach((task) => {
      const status = statuses.includes(task.status) ? task.status : statuses[0];
      grouped[status].push(task);
    });

    const html = statuses
      .map((status) => {
        const cards = grouped[status].map(taskCardMarkup).join("") || "<p class='muted'>No tasks in this status.</p>";
        const color = {
          Todo: "#67b8ff",
          "In Progress": "#ffc857",
          Blocked: "#ff6b6b",
          Done: "#35c36b",
          Cancelled: "#8c95a1",
        }[status] || "#9aa4af";
        return `
          <section class="kanban-col" data-status="${escapeHtml(status)}">
            <header class="kanban-col-head" style="--kanban-color:${color}">
              <h4>${escapeHtml(status)}</h4>
              <span>${grouped[status].length}</span>
            </header>
            <div class="kanban-col-body drop-zone" data-entity="task" data-status="${escapeHtml(status)}">${cards}</div>
          </section>
        `;
      })
      .join("");

    board.innerHTML = html;
    refreshSemanticTones(board);
  }

  function renderTaskList(tableBody, tasks) {
    if (!tableBody) {
      return;
    }
    const lookups = cachedLookups || {};
    const statuses = lookups.task_statuses || defaultTaskStatuses;
    const priorities = lookups.priorities || ["Low", "Medium", "High", "Critical"];
    const users = lookups.users || [];
    const assigneeOptions = (selected) => {
      const current = selected === null || selected === undefined ? "" : String(selected);
      const opts = ["<option value=''>Unassigned</option>"];
      users.forEach((user) => {
        const value = String(user.id);
        opts.push(`<option value="${escapeHtml(value)}"${value === current ? " selected" : ""}>${escapeHtml(user.name)}</option>`);
      });
      return opts.join("");
    };

    tableBody.innerHTML = tasks
      .map(
        (task) => `
        <tr data-task-id="${escapeHtml(task.id)}">
          <td><button type="button" class="linkish list-open" data-list-entity="task" data-list-id="${escapeHtml(task.id)}">${escapeHtml(task.title || "Untitled Task")}</button></td>
          <td>${escapeHtml(task.project || "-")}</td>
          <td><select class="quick-status list-quick-status" data-entity="task" data-id="${escapeHtml(task.id)}" aria-label="Task status for ${escapeHtml(task.title || "task")}">${fixedOptions(statuses, task.status || "Todo")}</select></td>
          <td><select class="quick-field list-quick-field" data-entity="task" data-id="${escapeHtml(task.id)}" data-field="priority" aria-label="Task priority for ${escapeHtml(task.title || "task")}">${fixedOptions(priorities, task.priority || "Medium")}</select></td>
          <td><select class="quick-field list-quick-field" data-entity="task" data-id="${escapeHtml(task.id)}" data-field="assignee_user_id" aria-label="Task assignee for ${escapeHtml(task.title || "task")}">${assigneeOptions(task.assignee_user_id)}</select></td>
          <td>${escapeHtml(task.team || "-")}</td>
          <td>${escapeHtml(task.space || "-")}</td>
          <td><input type="date" class="quick-field list-quick-field due-input" data-entity="task" data-id="${escapeHtml(task.id)}" data-field="due_date" value="${escapeHtml(task.due_date || "")}" aria-label="Task due date for ${escapeHtml(task.title || "task")}" /></td>
        </tr>
      `,
      )
      .join("") || "<tr><td colspan='8'>No tasks in this view.</td></tr>";
    refreshSemanticTones(tableBody);
    const surface = tableBody.closest(".board-list-surface");
    if (surface) {
      const boardKey = surface.getAttribute("data-view-surface") || "";
      const registry = listSurfaceRegistry.get(boardKey);
      if (registry && typeof registry.applyAndSave === "function") {
        registry.applyAndSave();
      }
    }
  }

  async function fetchTasks(scope, search, teamId) {
    const params = new URLSearchParams();
    params.set("scope", scope || "my");
    params.set("search", search || "");
    if (teamId) {
      params.set("team_id", teamId);
    }
    const response = await fetch(withSpace(`/api/tasks?${params.toString()}`), { credentials: "same-origin" });
    if (!response.ok) {
      throw new Error("Could not load tasks");
    }
    const payload = await response.json();
    return payload.tasks || [];
  }

  async function refreshTaskBoard() {
    const board = document.getElementById("task-kanban");
    if (!board) {
      return;
    }
    const searchInput = document.getElementById("task-search");
    const statuses = (board.dataset.statuses || "").split("|").filter(Boolean);
    const activeStatuses = statuses.length ? statuses : defaultTaskStatuses;
    const search = searchInput ? searchInput.value.trim() : "";

    await getLookups();
    const tasks = await fetchTasks(currentTaskScope, search, currentTaskTeamId);
    taskById = new Map(tasks.map((task) => [String(task.id), task]));
    renderTaskBoard(board, tasks, activeStatuses);
    initKanbanColumnCustomization(board, "task");
    renderTaskList(document.getElementById("task-list-body"), tasks);
  }

  async function moveTask(taskId, status) {
    await postForm("/api/tasks/save", { task_id: taskId, status: status });
  }

  async function moveProject(projectId, status) {
    await postForm("/api/projects/save", { project_id: projectId, status: status });
  }

  async function moveIntake(intakeId, status) {
    await postForm("/api/intake/save", { intake_id: intakeId, status: status });
  }

  async function moveAsset(assetId, status) {
    await postForm("/api/assets/save", { asset_id: assetId, status: status });
  }

  async function moveConsumable(consumableId, status) {
    await postForm("/api/consumables/save", { consumable_id: consumableId, status: status });
  }

  async function movePartnership(partnershipId, stage) {
    await postForm("/api/partnerships/save", { partnership_id: partnershipId, stage: stage });
  }

  function datasetKeyForField(field) {
    const explicit = {
      owner_user_id: "ownerId",
      assignee_user_id: "assigneeId",
      team_id: "teamId",
      space_id: "spaceId",
      project_id: "projectId",
      partner_name: "partnerName",
      due_date: "dueDate",
      next_followup: "nextFollowup",
      last_contact: "lastContact",
      quantity_on_hand: "quantityOnHand",
      reorder_point: "reorderPoint",
      asset_type: "assetType",
      last_maintenance: "lastMaintenance",
      next_maintenance: "nextMaintenance",
      cert_required: "certRequired",
      cert_name: "certName",
    };
    if (explicit[field]) {
      return explicit[field];
    }
    return String(field || "").replace(/_([a-z])/g, (_m, char) => char.toUpperCase());
  }

  function staticTitleDatasetKey(entity) {
    return {
      project: "name",
      intake: "title",
      asset: "name",
      consumable: "name",
      partnership: "partnerName",
    }[entity] || "title";
  }

  function staticInlineFields(entity, lookups) {
    switch (entity) {
      case "project":
        return [
          { field: "priority", type: "strings", options: lookups.priorities || [] },
          { field: "team_id", type: "objects", options: lookups.teams || [], placeholder: "No team" },
          { field: "space_id", type: "objects", options: lookups.spaces || [], placeholder: "No space" },
          { field: "owner_user_id", type: "objects", options: lookups.users || [], placeholder: "Owner" },
        ];
      case "intake":
        return [
          { field: "lane", type: "strings", options: lookups.lanes || [] },
          { field: "owner_user_id", type: "objects", options: lookups.users || [], placeholder: "Owner" },
        ];
      case "asset":
        return [
          { field: "space", type: "strings", options: (lookups.spaces || []).map((space) => space.name) },
          { field: "owner_user_id", type: "objects", options: lookups.users || [], placeholder: "Owner" },
        ];
      case "consumable":
        return [
          { field: "space_id", type: "objects", options: lookups.spaces || [], placeholder: "Select space" },
          { field: "owner_user_id", type: "objects", options: lookups.users || [], placeholder: "Owner" },
        ];
      case "partnership":
        return [
          { field: "health", type: "strings", options: lookups.partnership_healths || ["Strong", "Medium", "At Risk"] },
          { field: "owner_user_id", type: "objects", options: lookups.users || [], placeholder: "Owner" },
        ];
      default:
        return [];
    }
  }

  function findByIdName(rows, id, fallback) {
    const key = String(id || "");
    const row = (rows || []).find((item) => String(item.id) === key);
    return row ? String(row.name || "") : fallback;
  }

  function syncStaticCardSummary(card, entity, lookups) {
    if (entity === "project") {
      const line1 = card.querySelector(".meta-line-1");
      const line2 = card.querySelector(".meta-line-2");
      if (line1) {
        line1.textContent = `${card.dataset.lane || "-"} · ${findByIdName(lookups.teams, card.dataset.teamId, "No team")} · ${findByIdName(lookups.spaces, card.dataset.spaceId, "No space")}`;
      }
      if (line2) {
        line2.textContent = `Owner: ${findByIdName(lookups.users, card.dataset.ownerId, "-")} · Due: ${card.dataset.dueDate || "-"}`;
      }
      return;
    }
    if (entity === "intake") {
      const line1 = card.querySelector(".meta-line-1");
      if (line1) {
        line1.textContent = `${card.dataset.lane || "-"} · Owner: ${findByIdName(lookups.users, card.dataset.ownerId, "Unassigned")}`;
      }
      return;
    }
    if (entity === "asset") {
      const line1 = card.querySelector(".meta-line-1");
      const line2 = card.querySelector(".meta-line-2");
      if (line1) {
        line1.textContent = `${card.dataset.space || "-"} · ${card.dataset.assetType || "-"}`;
      }
      if (line2) {
        line2.textContent = `Owner: ${findByIdName(lookups.users, card.dataset.ownerId, "Unassigned")} · Next: ${card.dataset.nextMaintenance || "-"}`;
      }
      return;
    }
    if (entity === "consumable") {
      const line1 = card.querySelector(".meta-line-1");
      const line2 = card.querySelector(".meta-line-2");
      const line3 = card.querySelector(".meta-line-3");
      if (line1) {
        line1.textContent = `${findByIdName(lookups.spaces, card.dataset.spaceId, "No space")} · ${card.dataset.category || "-"}`;
      }
      if (line2) {
        line2.textContent = `On hand: ${card.dataset.quantityOnHand || "0"} ${card.dataset.unit || ""} · Reorder at ${card.dataset.reorderPoint || "0"}`;
      }
      if (line3) {
        line3.textContent = `Owner: ${findByIdName(lookups.users, card.dataset.ownerId, "Unassigned")}`;
      }
      return;
    }
    if (entity === "partnership") {
      const line1 = card.querySelector(".meta-line-1");
      const line2 = card.querySelector(".meta-line-2");
      if (line1) {
        line1.textContent = `${card.dataset.school || "-"} · ${card.dataset.health || "Medium"}`;
      }
      if (line2) {
        line2.textContent = `Owner: ${findByIdName(lookups.users, card.dataset.ownerId, "Unassigned")} · Follow-up: ${card.dataset.nextFollowup || "-"}`;
      }
    }
  }

  function hydrateStaticCardInlineControls(card, config, lookups) {
    const perms = permissionForEntity(lookups, config.entity);
    const titleNode = card.querySelector(".card-title-label");
    const titleDatasetKey = staticTitleDatasetKey(config.entity);
    if (titleNode) {
      titleNode.innerHTML = titleControlMarkup(
        config.entity,
        card.dataset.id || "",
        card.dataset[titleDatasetKey] || "Untitled",
        lookups,
      );
    }

    const statusSelect = card.querySelector(`.quick-status[data-entity='${config.entity}']`);
    if (statusSelect && !perms.can_edit) {
      statusSelect.disabled = true;
    }

    const inline = card.querySelector(".card-topline .inline");
    if (!inline) {
      return;
    }
    staticInlineFields(config.entity, lookups).forEach((fieldConfig) => {
      if (inline.querySelector(`.quick-field[data-field='${fieldConfig.field}']`)) {
        return;
      }
      const selected = card.dataset[datasetKeyForField(fieldConfig.field)] || "";
      const html = fieldConfig.type === "objects"
        ? quickSelectFromObjects(config.entity, card.dataset.id || "", fieldConfig.field, selected, fieldConfig.options, fieldConfig.placeholder, !perms.can_edit)
        : quickSelectMarkup(config.entity, card.dataset.id || "", fieldConfig.field, selected, fieldConfig.options, fieldConfig.placeholder, !perms.can_edit);
      const holder = document.createElement("span");
      holder.innerHTML = html.trim();
      if (holder.firstElementChild) {
        inline.appendChild(holder.firstElementChild);
      }
    });
  }

  async function saveStaticInlineField(config, card, field, value) {
    const payload = {
      [config.idField]: card.dataset.id || "",
      [field]: value,
    };
    return postForm(config.saveUrl, payload);
  }

  function initTaskBoard() {
    const board = document.getElementById("task-kanban");
    if (!board) {
      return;
    }

    currentTaskScope = board.dataset.initialScope || "my";
    currentTaskTeamId = board.dataset.initialTeamId || "";

    const scopeButtons = document.querySelectorAll("[data-task-scope]");
    scopeButtons.forEach((button) => {
      button.addEventListener("click", () => {
        currentTaskScope = button.getAttribute("data-task-scope") || "my";
        scopeButtons.forEach((node) => {
          const selected = (node.getAttribute("data-task-scope") || "") === currentTaskScope;
          node.classList.toggle("active", selected);
          node.setAttribute("aria-pressed", selected ? "true" : "false");
        });
        refreshTaskBoard().catch(() => {
          board.innerHTML = "<section class='kanban-col'><header class='kanban-col-head'><h4>Error</h4><span>!</span></header><div class='kanban-col-body'><p>Could not load task board.</p></div></section>";
        });
      });
    });

    const teamButtons = document.querySelectorAll("[data-task-team]");
    teamButtons.forEach((button) => {
      button.addEventListener("click", () => {
        currentTaskTeamId = button.getAttribute("data-task-team") || "";
        teamButtons.forEach((node) => {
          node.classList.toggle("active", (node.getAttribute("data-task-team") || "") === currentTaskTeamId);
        });
        refreshTaskBoard().catch(() => {
          setModalFeedback("Could not refresh tasks.", true);
        });
      });
    });

    const searchInput = document.getElementById("task-search");
    if (searchInput) {
      searchInput.addEventListener("input", () => {
        window.clearTimeout(taskSearchTimer);
        taskSearchTimer = window.setTimeout(() => {
          refreshTaskBoard().catch(() => {
            setModalFeedback("Could not refresh tasks.", true);
          });
        }, 190);
      });
    }

    board.addEventListener("change", async (event) => {
      const select = event.target.closest(".quick-status[data-entity='task']");
      if (!select) {
        return;
      }
      const card = select.closest(".task-card");
      if (!card) {
        return;
      }
      const taskId = card.dataset.id;
      const status = select.value;
      if (isKanbanStatusRestricted(board, status)) {
        setModalFeedback("This status column is restricted by board settings.", true);
        select.value = String(card.dataset.status || "Todo");
        return;
      }
      try {
        await moveTask(taskId, status);
        await refreshTaskBoard();
      } catch (_err) {
        setModalFeedback("Could not update task status.", true);
      }
    });

    board.addEventListener("change", async (event) => {
      const fieldNode = event.target.closest(".quick-field[data-entity='task']");
      if (!fieldNode || fieldNode.classList.contains("quick-title-input")) {
        return;
      }
      const card = fieldNode.closest(".task-card");
      if (!card) {
        return;
      }
      const field = fieldNode.getAttribute("data-field") || "";
      if (!field) {
        return;
      }
      try {
        await postForm("/api/tasks/save", { task_id: card.dataset.id, [field]: fieldNode.value });
        await refreshTaskBoard();
      } catch (_err) {
        setModalFeedback("Could not update task field.", true);
      }
    });

    board.addEventListener("blur", async (event) => {
      const input = event.target.closest(".quick-title-input[data-entity='task']");
      if (!input) {
        return;
      }
      const card = input.closest(".task-card");
      if (!card) {
        return;
      }
      const nextValue = input.value.trim();
      if (!nextValue || nextValue === (card.dataset.title || "")) {
        input.value = card.dataset.title || "";
        return;
      }
      try {
        await postForm("/api/tasks/save", {
          task_id: card.dataset.id,
          [input.getAttribute("data-field") || "title"]: nextValue,
        });
        await refreshTaskBoard();
      } catch (_err) {
        setModalFeedback("Could not update task title.", true);
      }
    }, true);

    board.addEventListener("keydown", (event) => {
      const input = event.target.closest(".quick-title-input[data-entity='task']");
      if (!input) {
        return;
      }
      if (event.key === "Enter") {
        event.preventDefault();
        input.blur();
      }
    });

    board.addEventListener("click", (event) => {
      const card = event.target.closest(".task-card");
      if (!card) {
        return;
      }
      if (event.target.closest("a, button, input, textarea, select, label, summary")) {
        return;
      }
      const task = taskById.get(card.dataset.id || "");
      if (task) {
        openTaskEditor(task, false).catch(() => {
          setModalFeedback("Could not open task editor.", true);
        });
      }
    });

    board.addEventListener("keydown", (event) => {
      const card = event.target.closest(".task-card");
      if (!card) {
        return;
      }
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        const task = taskById.get(card.dataset.id || "");
        if (task) {
          openTaskEditor(task, false).catch(() => {
            setModalFeedback("Could not open task editor.", true);
          });
        }
      }
    });

    board.addEventListener("dragstart", (event) => {
      const card = event.target.closest(".task-card");
      if (!card || !event.dataTransfer) {
        return;
      }
      event.dataTransfer.effectAllowed = "move";
      event.dataTransfer.setData("text/plain", JSON.stringify({ entity: "task", id: card.dataset.id }));
      card.classList.add("dragging");
    });

    board.addEventListener("dragend", (event) => {
      const card = event.target.closest(".task-card");
      if (card) {
        card.classList.remove("dragging");
      }
      board.querySelectorAll(".drop-zone.drag-over").forEach((zone) => zone.classList.remove("drag-over"));
    });

    board.addEventListener("dragover", (event) => {
      const zone = event.target.closest('.drop-zone[data-entity="task"]');
      if (!zone) {
        return;
      }
      event.preventDefault();
      zone.classList.add("drag-over");
    });

    board.addEventListener("dragleave", (event) => {
      const zone = event.target.closest('.drop-zone[data-entity="task"]');
      if (!zone) {
        return;
      }
      zone.classList.remove("drag-over");
    });

    board.addEventListener("drop", async (event) => {
      const zone = event.target.closest('.drop-zone[data-entity="task"]');
      if (!zone) {
        return;
      }
      event.preventDefault();
      zone.classList.remove("drag-over");
      if (!event.dataTransfer) {
        return;
      }
      let payload = null;
      try {
        payload = JSON.parse(event.dataTransfer.getData("text/plain") || "{}");
      } catch (_err) {
        payload = null;
      }
      if (!payload || payload.entity !== "task" || !payload.id) {
        return;
      }
      const status = zone.dataset.status || "Todo";
      if (isKanbanStatusRestricted(board, status)) {
        setModalFeedback("This status column is restricted by board settings.", true);
        return;
      }
      try {
        await moveTask(payload.id, status);
        await refreshTaskBoard();
      } catch (_err) {
        setModalFeedback("Could not move task.", true);
      }
    });

    refreshTaskBoard().catch(() => {
      board.innerHTML = "<section class='kanban-col'><header class='kanban-col-head'><h4>Error</h4><span>!</span></header><div class='kanban-col-body'><p>Could not load task board.</p></div></section>";
    });
  }

  function initStaticBoard(config) {
    const board = document.getElementById(config.boardId);
    if (!board) {
      return;
    }
    initKanbanColumnCustomization(board, config.entity);

    board.addEventListener("change", async (event) => {
      const select = event.target.closest(`.quick-status[data-entity='${config.entity}']`);
      if (!select) {
        return;
      }
      const card = select.closest(config.cardSelector);
      if (!card) {
        return;
      }
      if (isKanbanStatusRestricted(board, select.value)) {
        setModalFeedback(`This ${config.entity} status column is restricted by board settings.`, true);
        select.value = String(card.dataset.status || card.dataset.stage || "");
        return;
      }
      try {
        await config.moveStatus(card.dataset.id || "", select.value, card);
        updateCardStatusSelect(card, select.value);
        moveCardToStatus(card, config.entity, select.value);
        applySelectTone(select);
      } catch (_err) {
        setModalFeedback(`Could not update ${config.entity} status.`, true);
      }
    });

    board.addEventListener("change", async (event) => {
      const fieldNode = event.target.closest(`.quick-field[data-entity='${config.entity}']`);
      if (!fieldNode || fieldNode.classList.contains("quick-title-input")) {
        return;
      }
      const card = fieldNode.closest(config.cardSelector);
      if (!card) {
        return;
      }
      const field = fieldNode.getAttribute("data-field") || "";
      if (!field) {
        return;
      }
      try {
        await saveStaticInlineField(config, card, field, fieldNode.value);
        card.dataset[datasetKeyForField(field)] = fieldNode.value;
        syncStaticCardSummary(card, config.entity, cachedLookups || {});
        applySelectTone(fieldNode);
      } catch (_err) {
        setModalFeedback(`Could not update ${config.entity} field.`, true);
        fieldNode.value = card.dataset[datasetKeyForField(field)] || "";
      }
    });

    board.addEventListener("blur", async (event) => {
      const input = event.target.closest(`.quick-title-input[data-entity='${config.entity}']`);
      if (!input) {
        return;
      }
      const card = input.closest(config.cardSelector);
      if (!card) {
        return;
      }
      const field = input.getAttribute("data-field") || titleFieldByEntity(config.entity);
      const datasetKey = datasetKeyForField(field);
      const nextValue = input.value.trim();
      if (!nextValue || nextValue === (card.dataset[datasetKey] || "")) {
        input.value = card.dataset[datasetKey] || "";
        return;
      }
      try {
        await saveStaticInlineField(config, card, field, nextValue);
        card.dataset[datasetKey] = nextValue;
        syncStaticCardSummary(card, config.entity, cachedLookups || {});
      } catch (_err) {
        setModalFeedback(`Could not update ${config.entity} title.`, true);
        input.value = card.dataset[datasetKey] || "";
      }
    }, true);

    board.addEventListener("keydown", (event) => {
      const input = event.target.closest(`.quick-title-input[data-entity='${config.entity}']`);
      if (!input) {
        return;
      }
      if (event.key === "Enter") {
        event.preventDefault();
        input.blur();
      }
    });

    board.addEventListener("click", (event) => {
      const card = event.target.closest(config.cardSelector);
      if (!card) {
        return;
      }
      if (event.target.closest("a, button, input, textarea, select, label, summary")) {
        return;
      }
      config.openEditor(card).catch(() => {
        setModalFeedback(`Could not open ${config.entity} editor.`, true);
      });
    });

    board.addEventListener("keydown", (event) => {
      const card = event.target.closest(config.cardSelector);
      if (!card) {
        return;
      }
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        config.openEditor(card).catch(() => {
          setModalFeedback(`Could not open ${config.entity} editor.`, true);
        });
      }
    });

    board.addEventListener("dragstart", (event) => {
      const card = event.target.closest(config.cardSelector);
      if (!card || !event.dataTransfer) {
        return;
      }
      event.dataTransfer.effectAllowed = "move";
      event.dataTransfer.setData("text/plain", JSON.stringify({ entity: config.entity, id: card.dataset.id }));
      card.classList.add("dragging");
    });

    board.addEventListener("dragend", (event) => {
      const card = event.target.closest(config.cardSelector);
      if (card) {
        card.classList.remove("dragging");
      }
      board.querySelectorAll(".drop-zone.drag-over").forEach((zone) => zone.classList.remove("drag-over"));
    });

    board.addEventListener("dragover", (event) => {
      const zone = event.target.closest(`.drop-zone[data-entity='${config.entity}']`);
      if (!zone) {
        return;
      }
      event.preventDefault();
      zone.classList.add("drag-over");
    });

    board.addEventListener("dragleave", (event) => {
      const zone = event.target.closest(`.drop-zone[data-entity='${config.entity}']`);
      if (!zone) {
        return;
      }
      zone.classList.remove("drag-over");
    });

    board.addEventListener("drop", async (event) => {
      const zone = event.target.closest(`.drop-zone[data-entity='${config.entity}']`);
      if (!zone) {
        return;
      }
      event.preventDefault();
      zone.classList.remove("drag-over");
      if (!event.dataTransfer) {
        return;
      }
      let payload = null;
      try {
        payload = JSON.parse(event.dataTransfer.getData("text/plain") || "{}");
      } catch (_err) {
        payload = null;
      }
      if (!payload || payload.entity !== config.entity || !payload.id) {
        return;
      }
      const card = board.querySelector(`${config.cardSelector}[data-id="${escapeCssValue(String(payload.id))}"]`);
      if (!card) {
        return;
      }
      const status = zone.dataset.status || "";
      if (!status) {
        return;
      }
      if (isKanbanStatusRestricted(board, status)) {
        setModalFeedback(`This ${config.entity} status column is restricted by board settings.`, true);
        return;
      }
      try {
        await config.moveStatus(payload.id, status, card);
        updateCardStatusSelect(card, status);
        moveCardToStatus(card, config.entity, status);
      } catch (_err) {
        setModalFeedback(`Could not move ${config.entity}.`, true);
      }
    });

    getLookups()
      .then((lookups) => {
        board.querySelectorAll(config.cardSelector).forEach((card) => {
          hydrateStaticCardInlineControls(card, config, lookups);
          syncStaticCardSummary(card, config.entity, lookups);
        });
        if (config.entity === "project") {
          ensureInlineCardChatForBoard(board, "project", config.cardSelector);
        }
        refreshSemanticTones(board);
      })
      .catch(() => {
        setModalFeedback(`Could not load ${config.entity} inline controls.`, true);
      });
  }

  function initProjectBoard() {
    initStaticBoard({
      boardId: "project-kanban",
      cardSelector: ".project-card",
      entity: "project",
      saveUrl: "/api/projects/save",
      idField: "project_id",
      moveStatus: async (id, status, card) => {
        await moveProject(id, status);
        card.dataset.status = status;
      },
      openEditor: openProjectEditor,
    });
  }

  function initIntakeBoard() {
    initStaticBoard({
      boardId: "intake-kanban",
      cardSelector: ".intake-card",
      entity: "intake",
      saveUrl: "/api/intake/save",
      idField: "intake_id",
      moveStatus: async (id, status, card) => {
        await moveIntake(id, status);
        card.dataset.status = status;
      },
      openEditor: openIntakeEditor,
    });
  }

  function initAssetBoard() {
    initStaticBoard({
      boardId: "asset-kanban",
      cardSelector: ".asset-card",
      entity: "asset",
      saveUrl: "/api/assets/save",
      idField: "asset_id",
      moveStatus: async (id, status, card) => {
        await moveAsset(id, status);
        card.dataset.status = status;
      },
      openEditor: openAssetEditor,
    });
  }

  function initConsumableBoard() {
    initStaticBoard({
      boardId: "consumable-kanban",
      cardSelector: ".consumable-card",
      entity: "consumable",
      saveUrl: "/api/consumables/save",
      idField: "consumable_id",
      moveStatus: async (id, status, card) => {
        await moveConsumable(id, status);
        card.dataset.status = status;
      },
      openEditor: openConsumableEditor,
    });
  }

  function initPartnershipBoard() {
    initStaticBoard({
      boardId: "partnership-kanban",
      cardSelector: ".partnership-card",
      entity: "partnership",
      saveUrl: "/api/partnerships/save",
      idField: "partnership_id",
      moveStatus: async (id, status, card) => {
        await movePartnership(id, status);
        card.dataset.stage = status;
        card.dataset.status = status;
      },
      openEditor: openPartnershipEditor,
    });
  }

  function initModalEvents() {
    if (!modal || !modalForm) {
      return;
    }

    modal.addEventListener("click", (event) => {
      if (event.target.closest("[data-close-modal='1']")) {
        closeModal();
      }
    });

    modalForm.addEventListener("click", async (event) => {
      const commentButton = event.target.closest("[data-comment-submit='1']");
      if (commentButton) {
        event.preventDefault();
        const threadNode = commentButton.closest("[data-comment-thread='1']");
        if (!threadNode) {
          return;
        }
        const entity = threadNode.getAttribute("data-entity") || "";
        const itemId = threadNode.getAttribute("data-item-id") || "";
        const textarea = threadNode.querySelector("[data-comment-body]");
        const body = textarea ? textarea.value.trim() : "";
        if (!body) {
          setModalFeedback("Enter a comment before posting.", true);
          return;
        }
        commentButton.disabled = true;
        try {
          await postForm("/api/comments/add", { entity, item_id: itemId, body });
          if (textarea) {
            textarea.value = "";
          }
          await loadCommentThread(threadNode);
          setModalFeedback("Comment posted.", false);
        } catch (err) {
          setModalFeedback(describeRequestError(err, entity), true);
        } finally {
          commentButton.disabled = false;
        }
        return;
      }

      const deleteButton = event.target.closest("[data-delete-entity][data-delete-id]");
      if (!deleteButton) {
        return;
      }
      event.preventDefault();
      const entity = deleteButton.getAttribute("data-delete-entity") || "";
      const id = deleteButton.getAttribute("data-delete-id") || "";
      const confirmed = window.confirm("Move this item to Deleted Items?");
      if (!confirmed) {
        return;
      }
      deleteButton.disabled = true;
      try {
        await postForm("/api/items/delete", { entity, id });
        closeModal();
        window.location.reload();
      } catch (err) {
        deleteButton.disabled = false;
        setModalFeedback(describeRequestError(err, entity), true);
      }
    });

    modalForm.addEventListener("submit", async (event) => {
      event.preventDefault();
      if (!onModalSubmit) {
        return;
      }
      const submitButton = modalForm.querySelector("button[type='submit']");
      if (submitButton) {
        submitButton.disabled = true;
      }
      setModalFeedback("Saving...", false);
      try {
        await onModalSubmit(new FormData(modalForm));
      } finally {
        if (submitButton) {
          submitButton.disabled = false;
        }
      }
    });

    window.addEventListener("keydown", (event) => {
      if (event.key === "Escape" && modal.getAttribute("aria-hidden") === "false") {
        closeModal();
      }
    });
  }

  function ensurePurgeConfirmModal() {
    let shell = document.getElementById("purge-confirm-modal");
    if (shell) {
      return shell;
    }
    shell = document.createElement("div");
    shell.id = "purge-confirm-modal";
    shell.className = "confirm-modal-shell";
    shell.setAttribute("aria-hidden", "true");
    shell.innerHTML = `
      <div class="confirm-modal-backdrop" data-close-purge-confirm="1"></div>
      <section class="confirm-modal-card" role="dialog" aria-modal="true" aria-labelledby="purge-confirm-title">
        <header class="confirm-modal-head">
          <h2 id="purge-confirm-title">Confirm Action</h2>
          <button type="button" class="btn ghost" data-close-purge-confirm="1" aria-label="Close confirmation">Close</button>
        </header>
        <p id="purge-confirm-message" class="muted"></p>
        <div id="purge-confirm-checklist" class="confirm-checklist"></div>
        <div class="confirm-modal-actions">
          <button type="button" class="btn ghost" data-close-purge-confirm="1">Cancel</button>
          <button type="button" class="btn danger-btn" id="purge-confirm-submit" disabled>Confirm Purge</button>
        </div>
      </section>
    `;
    document.body.appendChild(shell);
    return shell;
  }

  function closePurgeConfirm(confirmed) {
    const shell = document.getElementById("purge-confirm-modal");
    if (!shell) {
      return;
    }
    shell.setAttribute("aria-hidden", "true");
    const resolver = purgeConfirmResolve;
    purgeConfirmResolve = null;
    if (purgeConfirmLastFocus && typeof purgeConfirmLastFocus.focus === "function") {
      purgeConfirmLastFocus.focus();
    }
    purgeConfirmLastFocus = null;
    if (typeof resolver === "function") {
      resolver(Boolean(confirmed));
    }
  }

  function updatePurgeConfirmState() {
    const checklist = document.getElementById("purge-confirm-checklist");
    const submitButton = document.getElementById("purge-confirm-submit");
    if (!checklist || !submitButton) {
      return;
    }
    const boxes = Array.from(checklist.querySelectorAll("input[type='checkbox']"));
    const ready = boxes.length === 0 || boxes.every((box) => box.checked);
    submitButton.disabled = !ready;
  }

  function openPurgeChecklistConfirm(options) {
    const shell = ensurePurgeConfirmModal();
    const titleNode = document.getElementById("purge-confirm-title");
    const messageNode = document.getElementById("purge-confirm-message");
    const checklistNode = document.getElementById("purge-confirm-checklist");
    const submitButton = document.getElementById("purge-confirm-submit");
    if (!titleNode || !messageNode || !checklistNode || !submitButton) {
      return Promise.resolve(false);
    }

    const title = options && options.title ? String(options.title) : "Confirm Permanent Deletion";
    const message = options && options.message
      ? String(options.message)
      : "This action permanently deletes data and cannot be undone.";
    const listItems = Array.isArray(options && options.items)
      ? options.items.map((item) => String(item || "").trim()).filter(Boolean)
      : [];

    titleNode.textContent = title;
    messageNode.textContent = message;
    checklistNode.innerHTML = listItems.length
      ? listItems
        .map(
          (item, idx) => `
            <label class="confirm-checklist-item">
              <input type="checkbox" data-confirm-item="${idx}" />
              <span>${escapeHtml(item)}</span>
            </label>
          `,
        )
        .join("")
      : `<p class="muted">No checklist items were provided.</p>`;

    updatePurgeConfirmState();
    shell.setAttribute("aria-hidden", "false");
    purgeConfirmLastFocus = document.activeElement;

    return new Promise((resolve) => {
      purgeConfirmResolve = resolve;
      const firstCheckbox = checklistNode.querySelector("input[type='checkbox']");
      if (firstCheckbox) {
        firstCheckbox.focus();
      } else {
        submitButton.focus();
      }
    });
  }

  function parseChecklistItems(form) {
    const raw = String(form.getAttribute("data-confirm-items") || "");
    const items = raw
      .split("||")
      .map((item) => item.trim())
      .filter(Boolean);
    if (items.length) {
      return items;
    }
    return [
      "I understand this action cannot be undone.",
      "I confirmed I selected the correct item.",
      "I want to permanently remove this data.",
    ];
  }

  function initPurgeConfirmations() {
    const shell = ensurePurgeConfirmModal();
    const submitButton = document.getElementById("purge-confirm-submit");
    if (!shell || !submitButton) {
      return;
    }

    shell.addEventListener("click", (event) => {
      if (event.target.closest("[data-close-purge-confirm='1']")) {
        closePurgeConfirm(false);
      }
    });

    shell.addEventListener("change", (event) => {
      if (event.target instanceof HTMLInputElement && event.target.type === "checkbox") {
        updatePurgeConfirmState();
      }
    });

    submitButton.addEventListener("click", () => {
      if (submitButton.disabled) {
        return;
      }
      closePurgeConfirm(true);
    });

    window.addEventListener("keydown", (event) => {
      if (event.key === "Escape" && shell.getAttribute("aria-hidden") === "false") {
        closePurgeConfirm(false);
      }
    });

    document.addEventListener(
      "submit",
      async (event) => {
        const form = event.target;
        if (!(form instanceof HTMLFormElement)) {
          return;
        }
        if (form.getAttribute("data-purge-confirm") !== "1") {
          return;
        }
        if (form.dataset.purgeConfirmBypass === "1") {
          form.dataset.purgeConfirmBypass = "";
          return;
        }
        event.preventDefault();

        const title = String(form.getAttribute("data-confirm-title") || "Confirm Permanent Deletion");
        const message = String(
          form.getAttribute("data-confirm-message")
            || "This action permanently deletes data and cannot be undone.",
        );
        const items = parseChecklistItems(form);
        const confirmed = await openPurgeChecklistConfirm({ title, message, items });
        if (!confirmed) {
          return;
        }

        form.dataset.purgeConfirmBypass = "1";
        if (typeof form.requestSubmit === "function") {
          const submitter = event.submitter && form.contains(event.submitter) ? event.submitter : null;
          if (submitter) {
            form.requestSubmit(submitter);
          } else {
            form.requestSubmit();
          }
          return;
        }
        form.submit();
      },
      true,
    );
  }

  function initGlobalNewTask() {
    if (!globalNewTaskButton) {
      return;
    }
    globalNewTaskButton.addEventListener("click", () => {
      openTaskEditor(
        {
          status: "Todo",
          priority: "Medium",
          energy: "Medium",
          space_id: activeSpaceId || "",
          attachments: [],
          note: "",
          extra: {},
        },
        true,
      ).catch(() => {
        setModalFeedback("Could not open new task editor.", true);
      });
    });
  }

  function initSpaceContextForms() {
    if (!activeSpaceId) {
      return;
    }
    document.querySelectorAll("form").forEach((form) => {
      if (!form.querySelector("input[name='active_space_id']")) {
        const hidden = document.createElement("input");
        hidden.type = "hidden";
        hidden.name = "active_space_id";
        hidden.value = activeSpaceId;
        form.appendChild(hidden);
      }
    });
  }

  function listColumnStorageKey(boardKey) {
    return `makerflow-list-columns-${boardKey}`;
  }

  function listStateStorageKey(boardKey) {
    return `makerflow-list-state-${boardKey}`;
  }

  function readStorageJSON(key, fallbackValue) {
    try {
      const parsed = JSON.parse(window.localStorage.getItem(key) || "null");
      return parsed && typeof parsed === "object" ? parsed : fallbackValue;
    } catch (_err) {
      return fallbackValue;
    }
  }

  function writeStorageJSON(key, value) {
    try {
      window.localStorage.setItem(key, JSON.stringify(value));
    } catch (_err) {
      // Ignore storage write failures (private mode/quota) and keep in-memory behavior.
    }
  }

  function fallbackVisibleColumns(count) {
    return Array.from({ length: count }, (_v, idx) => idx);
  }

  function cleanColumnIndexes(values, count) {
    if (!Array.isArray(values)) {
      return fallbackVisibleColumns(count);
    }
    const cleaned = values
      .map((value) => Number.parseInt(String(value), 10))
      .filter((value) => Number.isInteger(value) && value >= 0 && value < count);
    return cleaned.length ? Array.from(new Set(cleaned)) : fallbackVisibleColumns(count);
  }

  function normalizeListState(state, count) {
    const raw = state && typeof state === "object" ? state : {};
    return {
      visible_columns: cleanColumnIndexes(raw.visible_columns, count),
      required_columns: raw.required_columns && typeof raw.required_columns === "object" ? raw.required_columns : {},
      restrict_edit_columns: raw.restrict_edit_columns && typeof raw.restrict_edit_columns === "object" ? raw.restrict_edit_columns : {},
      restrict_view_columns: raw.restrict_view_columns && typeof raw.restrict_view_columns === "object" ? raw.restrict_view_columns : {},
      descriptions: raw.descriptions && typeof raw.descriptions === "object" ? raw.descriptions : {},
      label_aliases: raw.label_aliases && typeof raw.label_aliases === "object" ? raw.label_aliases : {},
      label_colors: raw.label_colors && typeof raw.label_colors === "object" ? raw.label_colors : {},
      muted_assign_columns: raw.muted_assign_columns && typeof raw.muted_assign_columns === "object" ? raw.muted_assign_columns : {},
      column_types: raw.column_types && typeof raw.column_types === "object" ? raw.column_types : {},
      filters: raw.filters && typeof raw.filters === "object" ? raw.filters : {},
      global_search: String(raw.global_search || ""),
      person_filter: String(raw.person_filter || ""),
      group_by: Number.isInteger(raw.group_by) ? raw.group_by : null,
      sort_index: Number.isInteger(raw.sort_index) ? raw.sort_index : null,
      sort_direction: raw.sort_direction === "desc" ? "desc" : (raw.sort_direction === "asc" ? "asc" : "none"),
    };
  }

  function loadListState(boardKey, count) {
    const fromState = readStorageJSON(listStateStorageKey(boardKey), null);
    if (fromState) {
      return normalizeListState(fromState, count);
    }
    // Backward compatibility with older column-visibility storage key.
    const oldVisible = readStorageJSON(listColumnStorageKey(boardKey), []);
    return normalizeListState({ visible_columns: oldVisible }, count);
  }

  function saveListState(boardKey, state) {
    writeStorageJSON(listStateStorageKey(boardKey), state);
    writeStorageJSON(listColumnStorageKey(boardKey), state.visible_columns || []);
  }

  function kanbanStateStorageKey(boardKey) {
    return `makerflow-kanban-state-${boardKey}`;
  }

  function kanbanBoardKey(board) {
    if (!board) {
      return "";
    }
    return board.id || board.getAttribute("data-view-surface") || "";
  }

  function normalizeKanbanState(state) {
    const raw = state && typeof state === "object" ? state : {};
    return {
      hidden_statuses: raw.hidden_statuses && typeof raw.hidden_statuses === "object" ? raw.hidden_statuses : {},
      collapsed_statuses: raw.collapsed_statuses && typeof raw.collapsed_statuses === "object" ? raw.collapsed_statuses : {},
      required_statuses: raw.required_statuses && typeof raw.required_statuses === "object" ? raw.required_statuses : {},
      restrict_edit_statuses: raw.restrict_edit_statuses && typeof raw.restrict_edit_statuses === "object" ? raw.restrict_edit_statuses : {},
      restrict_view_statuses: raw.restrict_view_statuses && typeof raw.restrict_view_statuses === "object" ? raw.restrict_view_statuses : {},
      muted_assign_statuses: raw.muted_assign_statuses && typeof raw.muted_assign_statuses === "object" ? raw.muted_assign_statuses : {},
      descriptions: raw.descriptions && typeof raw.descriptions === "object" ? raw.descriptions : {},
      label_aliases: raw.label_aliases && typeof raw.label_aliases === "object" ? raw.label_aliases : {},
      label_colors: raw.label_colors && typeof raw.label_colors === "object" ? raw.label_colors : {},
      filters: raw.filters && typeof raw.filters === "object" ? raw.filters : {},
      sort_directions: raw.sort_directions && typeof raw.sort_directions === "object" ? raw.sort_directions : {},
      group_by: raw.group_by && typeof raw.group_by === "object" ? raw.group_by : {},
    };
  }

  function loadKanbanState(boardKey) {
    return normalizeKanbanState(readStorageJSON(kanbanStateStorageKey(boardKey), {}));
  }

  function saveKanbanState(boardKey, state) {
    writeStorageJSON(kanbanStateStorageKey(boardKey), state);
  }

  function kanbanColumnStatus(column) {
    return String(column?.getAttribute("data-status") || "").trim();
  }

  function kanbanLabelForStatus(state, status) {
    const alias = state && state.label_aliases && typeof state.label_aliases === "object"
      ? String(state.label_aliases[status] || "").trim()
      : "";
    return alias || status;
  }

  function defaultKanbanColorForStatus(status) {
    const palette = {
      Todo: "#67b8ff",
      "In Progress": "#ffc857",
      Blocked: "#ff6b6b",
      Done: "#35c36b",
      Cancelled: "#8c95a1",
      Planned: "#67b8ff",
      Active: "#ffc857",
      Complete: "#35c36b",
      Triage: "#67b8ff",
      "On Hold": "#ff6b6b",
      Rejected: "#8c95a1",
      Operational: "#35c36b",
      "Needs Service": "#ffc857",
      Down: "#ff6b6b",
      "In Stock": "#35c36b",
      Low: "#ffc857",
      Out: "#ff6b6b",
      Discovery: "#67b8ff",
      Pilot: "#ffc857",
      Dormant: "#8c95a1",
      Closed: "#8c95a1",
    };
    return palette[String(status || "").trim()] || "#9aa4af";
  }

  function clearKanbanGroupRows(column) {
    column.querySelectorAll(".kanban-group-row").forEach((node) => node.remove());
  }

  function kanbanCardFieldText(card, field) {
    const key = String(field || "").trim();
    if (!key || key === "title") {
      return String(card.dataset.title || card.querySelector(".quick-title-input")?.value || card.querySelector(".title-readonly")?.textContent || "").trim();
    }
    if (key === "priority") {
      const node = card.querySelector(".quick-field[data-field='priority']");
      return String(node?.value || card.dataset.priority || "").trim();
    }
    if (key === "assignee") {
      const node = card.querySelector(".quick-assignee, .quick-field[data-field='assignee_user_id'], .quick-field[data-field='owner_user_id']");
      if (node instanceof HTMLSelectElement) {
        return String(node.options[node.selectedIndex]?.textContent || "").trim();
      }
      return "";
    }
    if (key === "project") {
      return String(card.dataset.projectId || "").trim();
    }
    return String(card.textContent || "").trim();
  }

  function applyKanbanGrouping(column, field) {
    clearKanbanGroupRows(column);
    const groupField = String(field || "").trim();
    if (!groupField) {
      return;
    }
    const body = column.querySelector(".kanban-col-body");
    if (!body) {
      return;
    }
    const cards = Array.from(body.querySelectorAll(".kanban-card")).filter((card) => !card.hidden);
    if (!cards.length) {
      return;
    }
    let current = "";
    cards.forEach((card) => {
      const label = kanbanCardFieldText(card, groupField) || "No value";
      if (label !== current) {
        current = label;
        const row = document.createElement("p");
        row.className = "kanban-group-row muted";
        row.innerHTML = `<span class="pill soft">Group</span> ${escapeHtml(label)}`;
        body.insertBefore(row, card);
      }
    });
  }

  function applyKanbanStatusAliases(board, state) {
    const statusColors = state.label_colors && typeof state.label_colors === "object" ? state.label_colors : {};
    board.querySelectorAll(".quick-status").forEach((select) => {
      if (!(select instanceof HTMLSelectElement)) {
        return;
      }
      Array.from(select.options).forEach((option) => {
        if (option.dataset.baseLabel === undefined) {
          option.dataset.baseLabel = option.textContent || "";
        }
        const status = String(option.value || "").trim();
        if (!status) {
          option.textContent = String(option.dataset.baseLabel || option.textContent || "");
          return;
        }
        const alias = String((state.label_aliases && state.label_aliases[status]) || "").trim();
        option.textContent = alias || String(option.dataset.baseLabel || option.textContent || "");
      });
      applyCustomSelectColor(select, statusColors[String(select.value || "").trim()] || "");
    });
  }

  function applyKanbanColumnState(board, state) {
    if (!board) {
      return;
    }
    board.querySelectorAll(".kanban-col").forEach((column) => {
      clearKanbanGroupRows(column);
      const status = kanbanColumnStatus(column);
      if (!status) {
        return;
      }
      const hidden = Boolean(state.hidden_statuses[status] || state.restrict_view_statuses[status]);
      const collapsed = Boolean(state.collapsed_statuses[status]);
      const required = Boolean(state.required_statuses[status]);
      const restrictedEdit = Boolean(state.restrict_edit_statuses[status]);
      const muted = Boolean(state.muted_assign_statuses[status]);
      const description = String((state.descriptions && state.descriptions[status]) || "").trim();
      const label = kanbanLabelForStatus(state, status);
      const customColor = normalizeHexColor((state.label_colors && state.label_colors[status]) || "");
      const header = column.querySelector(".kanban-col-head");
      const titleNode = column.querySelector(".kanban-col-title");
      if (titleNode) {
        titleNode.textContent = label;
        titleNode.setAttribute("aria-label", `Status ${label}`);
      }
      if (header) {
        const baseColor = normalizeHexColor(column.dataset.defaultColor || "") || defaultKanbanColorForStatus(status);
        header.style.setProperty("--kanban-color", customColor || baseColor);
        header.classList.toggle("required-column", required);
        header.classList.toggle("restricted-edit-column", restrictedEdit);
        header.classList.toggle("muted-column", muted);
        header.title = description || label;
      }
      column.hidden = hidden;
      column.classList.toggle("collapsed-column", collapsed);

      const filterValue = String((state.filters && state.filters[status]) || "").trim().toLowerCase();
      const body = column.querySelector(".kanban-col-body");
      const cards = Array.from(column.querySelectorAll(".kanban-card"));
      cards.forEach((card) => {
        const visible = !hidden && (!filterValue || String(card.textContent || "").toLowerCase().includes(filterValue));
        card.hidden = !visible;
        card.querySelectorAll("input, select, textarea").forEach((field) => {
          if (field.dataset.baseDisabled === undefined) {
            field.dataset.baseDisabled = field.disabled ? "1" : "0";
          }
          const baseDisabled = field.dataset.baseDisabled === "1";
          field.disabled = baseDisabled || restrictedEdit;
        });
      });

      const direction = String((state.sort_directions && state.sort_directions[status]) || "none");
      if (body && (direction === "asc" || direction === "desc")) {
        cards
          .slice()
          .sort((left, right) => {
            const lv = sortableValue(kanbanCardFieldText(left, "title"));
            const rv = sortableValue(kanbanCardFieldText(right, "title"));
            const cmp = compareValues(lv, rv);
            return direction === "asc" ? cmp : -cmp;
          })
          .forEach((card) => body.appendChild(card));
      }

      applyKanbanGrouping(column, state.group_by && state.group_by[status]);
    });
    applyKanbanStatusAliases(board, state);
    refreshColumnCounts(board);
    refreshSemanticTones(board);
  }

  function ensureKanbanColumnMenu() {
    let shell = document.getElementById("kanban-column-menu-shell");
    if (shell) {
      return shell;
    }
    shell = document.createElement("div");
    shell.id = "kanban-column-menu-shell";
    shell.className = "list-col-menu-shell";
    shell.setAttribute("hidden", "hidden");
    shell.innerHTML = `
      <div class="list-col-menu-backdrop" data-close-kanban-col-menu="1"></div>
      <section class="list-col-menu" role="menu" aria-label="Kanban column menu">
        <button type="button" class="list-col-menu-item" data-kanban-action="edit_labels">Edit labels</button>
        <details class="list-col-submenu">
          <summary>Settings</summary>
          <div class="list-col-submenu-body">
            <button type="button" class="list-col-menu-item" data-kanban-action="settings_customize_people">Customize People column</button>
            <button type="button" class="list-col-menu-item" data-kanban-action="settings_add_description">Add description</button>
            <button type="button" class="list-col-menu-item" data-kanban-action="settings_mute_assign">Mute assign notifications</button>
            <button type="button" class="list-col-menu-item" data-kanban-action="settings_required">Set column as required</button>
            <button type="button" class="list-col-menu-item" data-kanban-action="settings_restrict_edit">Restrict column editing</button>
            <button type="button" class="list-col-menu-item" data-kanban-action="settings_restrict_view">Restrict column view</button>
            <button type="button" class="list-col-menu-item" data-kanban-action="settings_summary">Show column summary</button>
            <button type="button" class="list-col-menu-item" data-kanban-action="settings_save_template" disabled>Save column as a template</button>
          </div>
        </details>
        <button type="button" class="list-col-menu-item" data-kanban-action="auto_assign_people">Auto-assign people</button>
        <button type="button" class="list-col-menu-item" data-kanban-action="filter">Filter</button>
        <details class="list-col-submenu">
          <summary>Sort</summary>
          <div class="list-col-submenu-body">
            <button type="button" class="list-col-menu-item" data-kanban-action="sort" data-value="asc">Sort ascending</button>
            <button type="button" class="list-col-menu-item" data-kanban-action="sort" data-value="desc">Sort descending</button>
            <button type="button" class="list-col-menu-item" data-kanban-action="sort" data-value="none">Clear sort</button>
          </div>
        </details>
        <button type="button" class="list-col-menu-item" data-kanban-action="collapse">Collapse</button>
        <button type="button" class="list-col-menu-item" data-kanban-action="group_by">Group by</button>
        <button type="button" class="list-col-menu-item" data-kanban-action="duplicate">Duplicate column</button>
        <button type="button" class="list-col-menu-item" data-kanban-action="add_right">Add column to the right</button>
        <details class="list-col-submenu">
          <summary>Change column type</summary>
          <div class="list-col-submenu-body">
            <button type="button" class="list-col-menu-item" data-kanban-action="change_type" disabled>Status columns are fixed</button>
          </div>
        </details>
        <details class="list-col-submenu">
          <summary>Column extensions</summary>
          <div class="list-col-submenu-body">
            <button type="button" class="list-col-menu-item" data-kanban-action="extension_clear">Clear column values</button>
            <button type="button" class="list-col-menu-item" data-kanban-action="extension_fill">Fill down first value</button>
          </div>
        </details>
        <button type="button" class="list-col-menu-item" data-kanban-action="rename">Rename</button>
        <button type="button" class="list-col-menu-item danger" data-kanban-action="delete">Delete</button>
      </section>
    `;
    document.body.appendChild(shell);
    return shell;
  }

  function closeKanbanColumnMenu() {
    const shell = document.getElementById("kanban-column-menu-shell");
    if (!shell) {
      return;
    }
    shell.setAttribute("hidden", "hidden");
    activeKanbanColumnContext = null;
  }

  function openKanbanColumnMenu(context, anchor) {
    const shell = ensureKanbanColumnMenu();
    const menu = shell.querySelector(".list-col-menu");
    if (!menu || !anchor) {
      return;
    }
    activeKanbanColumnContext = context;
    shell.removeAttribute("hidden");
    menu.style.left = "0px";
    menu.style.top = "0px";
    const rect = anchor.getBoundingClientRect();
    const left = Math.max(8, Math.min(window.innerWidth - 360, rect.left));
    const top = Math.max(8, Math.min(window.innerHeight - 560, rect.bottom + 6));
    menu.style.left = `${left}px`;
    menu.style.top = `${top}px`;
  }

  function summarizeKanbanColumn(column) {
    const cards = Array.from(column.querySelectorAll(".kanban-card")).filter((card) => !card.hidden);
    const priorities = cards.map((card) => String(card.dataset.priority || "").trim()).filter(Boolean);
    const assignees = cards
      .map((card) => String(card.querySelector(".quick-assignee")?.selectedOptions?.[0]?.textContent || "").trim())
      .filter((value) => value && value.toLowerCase() !== "unassigned");
    return {
      cards: cards.length,
      unique_priorities: new Set(priorities).size,
      unique_assignees: new Set(assignees).size,
      sample_cards: cards.slice(0, 8).map((card) => String(card.dataset.title || "Untitled")),
    };
  }

  function openKanbanColumnSummaryModal(context) {
    const summary = summarizeKanbanColumn(context.column);
    openModal(
      `Column Summary: ${kanbanLabelForStatus(context.state, context.status)}`,
      `
      <div class="modal-grid two-col">
        <label>Visible cards <input readonly value="${escapeHtml(summary.cards)}" /></label>
        <label>Unique priorities <input readonly value="${escapeHtml(summary.unique_priorities)}" /></label>
        <label>Unique assignees <input readonly value="${escapeHtml(summary.unique_assignees)}" /></label>
      </div>
      <label>Sample cards
        <textarea readonly rows="5">${escapeHtml(summary.sample_cards.join("\n"))}</textarea>
      </label>
      `,
      async () => {
        closeModal();
      },
      "Close",
    );
  }

  function openKanbanStatusLabelEditor(context) {
    const { board, state, status, applyAndSave } = context;
    const statuses = Array.from(board.querySelectorAll(".kanban-col"))
      .map((column) => kanbanColumnStatus(column))
      .filter(Boolean);
    if (!statuses.length) {
      return;
    }
    const rows = statuses
      .map(
        (value, idx) => `
          <label class="list-label-editor-row">
            <span>${escapeHtml(value)}</span>
            <div class="list-label-editor-controls">
              <input data-status-value="${escapeHtml(value)}" name="status_alias_${idx}" value="${escapeHtml(state.label_aliases[value] || "")}" placeholder="Display label" />
              <input type="color" data-status-color="${escapeHtml(value)}" value="${escapeHtml(normalizeHexColor(state.label_colors[value] || "") || "#4db0ff")}" aria-label="Color for ${escapeHtml(value)}" />
            </div>
          </label>
        `,
      )
      .join("");
    openModal(
      `Edit Labels: ${kanbanLabelForStatus(state, status)}`,
      `<div class="list-label-editor-grid">${rows}</div>`,
      async () => {
        const aliases = {};
        const colors = {};
        const inputs = Array.from(document.querySelectorAll("#card-editor-form [data-status-value]"));
        inputs.forEach((node) => {
          if (!(node instanceof HTMLInputElement)) {
            return;
          }
          const key = String(node.getAttribute("data-status-value") || "").trim();
          const value = String(node.value || "").trim();
          if (key && value) {
            aliases[key] = value;
          }
        });
        const colorInputs = Array.from(document.querySelectorAll("#card-editor-form [data-status-color]"));
        colorInputs.forEach((node) => {
          if (!(node instanceof HTMLInputElement)) {
            return;
          }
          const key = String(node.getAttribute("data-status-color") || "").trim();
          const color = normalizeHexColor(node.value || "");
          if (key && color) {
            colors[key] = color;
          }
        });
        state.label_aliases = aliases;
        state.label_colors = colors;
        applyAndSave();
        logInterfaceEvent(
          "ui_design_changed",
          {
            surface: "kanban",
            board_key: context.boardKey || kanbanBoardKey(board),
            status: status,
            change: "edit_labels",
            labels_count: Object.keys(aliases).length,
            colors_count: Object.keys(colors).length,
          },
          "Kanban labels updated",
          context.boardKey || kanbanBoardKey(board),
        );
        closeModal();
      },
      "Save Labels",
    );
  }

  function setupKanbanColumnMenuEvents() {
    const shell = ensureKanbanColumnMenu();
    if (shell.dataset.bound === "1") {
      return;
    }
    shell.dataset.bound = "1";
    shell.addEventListener("click", (event) => {
      if (event.target.closest("[data-close-kanban-col-menu='1']")) {
        closeKanbanColumnMenu();
        return;
      }
      const actionNode = event.target.closest("[data-kanban-action]");
      if (!actionNode || !(actionNode instanceof HTMLElement) || !activeKanbanColumnContext) {
        return;
      }
      const action = actionNode.getAttribute("data-kanban-action") || "";
      const value = actionNode.getAttribute("data-value") || "";
      const ctx = activeKanbanColumnContext;
      const { state, status, board, applyAndSave } = ctx;
      const key = String(status || "");
      const title = kanbanLabelForStatus(state, status);
      const trackChange = (change, extra) => {
        logInterfaceEvent(
          "ui_design_changed",
          {
            surface: "kanban",
            board_key: ctx.boardKey || kanbanBoardKey(board),
            status: key,
            change,
            ...(extra || {}),
          },
          `Kanban ${change}`,
          ctx.boardKey || kanbanBoardKey(board),
        );
      };
      const toggleFlag = (name) => {
        if (!state[name] || typeof state[name] !== "object") {
          state[name] = {};
        }
        state[name][key] = !Boolean(state[name][key]);
        applyAndSave();
        trackChange(name, { value: Boolean(state[name][key]) });
      };

      if (action === "edit_labels" || action === "settings_customize_people") {
        openKanbanStatusLabelEditor(ctx);
        closeKanbanColumnMenu();
        return;
      }
      if (action === "settings_add_description") {
        const desc = window.prompt(`Description for "${title}"`, String(state.descriptions[key] || ""));
        if (desc !== null) {
          state.descriptions[key] = String(desc).trim();
          applyAndSave();
          trackChange("description_updated");
        }
        closeKanbanColumnMenu();
        return;
      }
      if (action === "settings_mute_assign") {
        toggleFlag("muted_assign_statuses");
        closeKanbanColumnMenu();
        return;
      }
      if (action === "settings_required") {
        toggleFlag("required_statuses");
        closeKanbanColumnMenu();
        return;
      }
      if (action === "settings_restrict_edit") {
        toggleFlag("restrict_edit_statuses");
        closeKanbanColumnMenu();
        return;
      }
      if (action === "settings_restrict_view") {
        toggleFlag("restrict_view_statuses");
        closeKanbanColumnMenu();
        return;
      }
      if (action === "settings_summary") {
        openKanbanColumnSummaryModal(ctx);
        closeKanbanColumnMenu();
        return;
      }
      if (action === "settings_save_template") {
        closeKanbanColumnMenu();
        return;
      }
      if (action === "auto_assign_people") {
        const preferred = currentUserName().toLowerCase();
        ctx.column.querySelectorAll(".quick-assignee, .quick-field[data-field='assignee_user_id'], .quick-field[data-field='owner_user_id']").forEach((node) => {
          if (!(node instanceof HTMLSelectElement) || String(node.value || "").trim()) {
            return;
          }
          const options = Array.from(node.options).filter((option) => String(option.value || "").trim());
          if (!options.length) {
            return;
          }
          const preferredOption = options.find((option) => String(option.textContent || "").trim().toLowerCase() === preferred);
          node.value = String((preferredOption || options[0]).value || "");
          node.dispatchEvent(new Event("change", { bubbles: true }));
        });
        closeKanbanColumnMenu();
        return;
      }
      if (action === "filter") {
        const existing = state.filters[key] || "";
        const query = window.prompt(`Filter cards in "${title}" (blank clears)`, String(existing));
        if (query !== null) {
          const cleaned = String(query || "").trim();
          if (cleaned) {
            state.filters[key] = cleaned;
          } else {
            delete state.filters[key];
          }
          applyAndSave();
          trackChange("filter_updated");
        }
        closeKanbanColumnMenu();
        return;
      }
      if (action === "sort") {
        if (value === "none") {
          delete state.sort_directions[key];
        } else {
          state.sort_directions[key] = value === "desc" ? "desc" : "asc";
        }
        applyAndSave();
        trackChange("sort_updated", { direction: value || "none" });
        closeKanbanColumnMenu();
        return;
      }
      if (action === "collapse") {
        toggleFlag("collapsed_statuses");
        closeKanbanColumnMenu();
        return;
      }
      if (action === "group_by") {
        const current = String((state.group_by && state.group_by[key]) || "");
        const choice = window.prompt("Group cards by: title, priority, assignee, project (blank clears)", current || "priority");
        if (choice !== null) {
          const next = String(choice || "").trim().toLowerCase();
          if (!next) {
            delete state.group_by[key];
          } else if (["title", "priority", "assignee", "project"].includes(next)) {
            state.group_by[key] = next;
          }
          applyAndSave();
          trackChange("group_by_updated", { group_by: state.group_by[key] || "" });
        }
        closeKanbanColumnMenu();
        return;
      }
      if (action === "rename") {
        const next = window.prompt("Status display label", String(state.label_aliases[key] || ""));
        if (next !== null) {
          const cleaned = String(next || "").trim();
          if (cleaned) {
            state.label_aliases[key] = cleaned;
          } else {
            delete state.label_aliases[key];
          }
          applyAndSave();
          trackChange("status_renamed", { alias: cleaned });
        }
        closeKanbanColumnMenu();
        return;
      }
      if (action === "delete") {
        if (window.confirm(`Hide "${title}" from this board?`)) {
          state.hidden_statuses[key] = true;
          applyAndSave();
          trackChange("status_hidden");
        }
        closeKanbanColumnMenu();
        return;
      }
      if (action === "extension_clear") {
        ctx.column.querySelectorAll(".quick-field, .quick-status").forEach((node) => {
          if (node instanceof HTMLInputElement || node instanceof HTMLTextAreaElement || node instanceof HTMLSelectElement) {
            node.value = "";
            node.dispatchEvent(new Event("change", { bubbles: true }));
          }
        });
        closeKanbanColumnMenu();
        return;
      }
      if (action === "extension_fill") {
        const rows = Array.from(ctx.column.querySelectorAll(".kanban-card"));
        if (rows.length > 1) {
          const first = rows[0].querySelector(".quick-field, .quick-status");
          if (first instanceof HTMLInputElement || first instanceof HTMLTextAreaElement || first instanceof HTMLSelectElement) {
            const valueToFill = String(first.value || "");
            rows.slice(1).forEach((card) => {
              const node = card.querySelector(".quick-field, .quick-status");
              if (node instanceof HTMLInputElement || node instanceof HTMLTextAreaElement || node instanceof HTMLSelectElement) {
                node.value = valueToFill;
                node.dispatchEvent(new Event("change", { bubbles: true }));
              }
            });
          }
        }
        closeKanbanColumnMenu();
        return;
      }
      if (["duplicate", "add_right", "change_type"].includes(action)) {
        setModalFeedback("This action is not available on Kanban status columns.", true);
        logInterfaceEvent(
          "interface_issue",
          {
            kind: "unsupported_kanban_action",
            action,
            board_key: ctx.boardKey || kanbanBoardKey(board),
            status: key,
          },
          "Unsupported Kanban action clicked",
          ctx.boardKey || kanbanBoardKey(board),
        );
        closeKanbanColumnMenu();
      }
    });
    window.addEventListener("keydown", (event) => {
      if (event.key === "Escape") {
        closeKanbanColumnMenu();
      }
    });
  }

  function enhanceKanbanHeaders(board, state) {
    board.querySelectorAll(".kanban-col").forEach((column, index) => {
      const header = column.querySelector(".kanban-col-head");
      if (!header) {
        return;
      }
      const status = kanbanColumnStatus(column);
      const label = kanbanLabelForStatus(state, status || `Status ${index + 1}`);
      const rawCount = header.querySelector(".kanban-col-count, span");
      const count = rawCount ? String(rawCount.textContent || "0").trim() : String(column.querySelectorAll(".kanban-card").length);
      const existingColor = normalizeHexColor(header.style.getPropertyValue("--kanban-color") || "")
        || normalizeHexColor(column.dataset.defaultColor || "")
        || defaultKanbanColorForStatus(status);
      column.dataset.defaultColor = existingColor;
      header.style.setProperty("--kanban-color", existingColor);
      header.innerHTML = `
        <div class="kanban-col-head-main">
          <button type="button" class="kanban-col-title" data-status="${escapeHtml(status)}">${escapeHtml(label)}</button>
        </div>
        <div class="kanban-col-head-actions">
          <span class="kanban-col-count">${escapeHtml(count)}</span>
          <button type="button" class="kanban-col-menu-btn" data-status="${escapeHtml(status)}" aria-label="Column menu for ${escapeHtml(label)}">⋯</button>
        </div>
      `;
    });
  }

  function initKanbanColumnCustomization(board, entity) {
    if (!board) {
      return;
    }
    const boardKey = kanbanBoardKey(board);
    if (!boardKey) {
      return;
    }
    const state = loadKanbanState(boardKey);
    const applyAndSave = () => {
      applyKanbanColumnState(board, state);
      saveKanbanState(boardKey, state);
    };
    const rebuild = () => {
      enhanceKanbanHeaders(board, state);
      applyAndSave();
    };
    const registry = {
      board,
      entity,
      boardKey,
      state,
      applyAndSave,
      rebuild,
    };
    kanbanBoardRegistry.set(boardKey, registry);

    setupKanbanColumnMenuEvents();
    enhanceKanbanHeaders(board, state);
    applyAndSave();

    if (board.dataset.kanbanMenuBound === "1") {
      return;
    }
    board.dataset.kanbanMenuBound = "1";
    board.addEventListener("click", (event) => {
      const menuNode = event.target.closest(".kanban-col-menu-btn[data-status]");
      if (!menuNode) {
        return;
      }
      const status = String(menuNode.getAttribute("data-status") || "").trim();
      const column = board.querySelector(`.kanban-col[data-status="${escapeCssValue(status)}"]`);
      if (!column) {
        return;
      }
      openKanbanColumnMenu({ ...registry, column, status }, menuNode);
    });
  }

  function isKanbanStatusRestricted(board, status) {
    const boardKey = kanbanBoardKey(board);
    if (!boardKey) {
      return false;
    }
    const registry = kanbanBoardRegistry.get(boardKey);
    if (!registry || !registry.state) {
      return false;
    }
    const key = String(status || "").trim();
    if (!key) {
      return false;
    }
    return Boolean(
      (registry.state.restrict_edit_statuses && registry.state.restrict_edit_statuses[key])
      || (registry.state.restrict_view_statuses && registry.state.restrict_view_statuses[key])
      || (registry.state.hidden_statuses && registry.state.hidden_statuses[key]),
    );
  }

  function headerLabelText(header, fallbackIndex) {
    const titleNode = header.querySelector(".list-col-title");
    if (titleNode) {
      return String(titleNode.textContent || "").trim() || `Column ${fallbackIndex + 1}`;
    }
    return String(header.textContent || "").trim() || `Column ${fallbackIndex + 1}`;
  }

  function setListColumnRules(surface, visibleIndexes, forcedHiddenIndexes) {
    const boardKey = surface.getAttribute("data-view-surface") || "";
    if (!boardKey) {
      return;
    }
    const headers = Array.from(surface.querySelectorAll("thead th"));
    const allIndexes = headers.map((_h, idx) => idx);
    const forced = Array.isArray(forcedHiddenIndexes)
      ? forcedHiddenIndexes.filter((idx) => Number.isInteger(idx))
      : [];
    const hidden = allIndexes.filter((idx) => !visibleIndexes.includes(idx) || forced.includes(idx));
    const styleId = `list-cols-${boardKey}`;
    let styleNode = document.getElementById(styleId);
    if (!styleNode) {
      styleNode = document.createElement("style");
      styleNode.id = styleId;
      document.head.appendChild(styleNode);
    }
    styleNode.textContent = hidden
      .map((idx) => `[data-view-surface='${boardKey}'] table tr > *:nth-child(${idx + 1}){display:none !important;}`)
      .join("\n");
  }

  function listDataRows(table) {
    const body = table.tBodies[0];
    if (!body) {
      return [];
    }
    return Array.from(body.rows).filter(
      (row) => !row.classList.contains("list-group-row") && !row.querySelector("td[colspan]"),
    );
  }

  function clearListGroupRows(table) {
    const body = table.tBodies[0];
    if (!body) {
      return;
    }
    body.querySelectorAll("tr.list-group-row").forEach((row) => row.remove());
  }

  function applyListLabelAliases(table, state) {
    const aliases = state.label_aliases && typeof state.label_aliases === "object" ? state.label_aliases : {};
    const colors = state.label_colors && typeof state.label_colors === "object" ? state.label_colors : {};
    const rows = listDataRows(table);
    const allColumns = new Set([...Object.keys(aliases), ...Object.keys(colors)]);
    allColumns.forEach((key) => {
      const index = asInt(key, -1);
      if (index < 0) {
        return;
      }
      const map = aliases[key] && typeof aliases[key] === "object" ? aliases[key] : {};
      const colorMap = colors[key] && typeof colors[key] === "object" ? colors[key] : {};
      rows.forEach((row) => {
        const cell = row.cells[index];
        if (!cell) {
          return;
        }
        const select = cell.querySelector("select");
        if (select) {
          Array.from(select.options).forEach((option) => {
            if (option.dataset.baseLabel === undefined) {
              option.dataset.baseLabel = option.textContent || "";
            }
            const rawValue = String(option.value || option.dataset.baseLabel || "").trim();
            const next = map[rawValue];
            option.textContent = next ? String(next) : String(option.dataset.baseLabel || option.textContent || "");
          });
          applyCustomSelectColor(select, colorMap[String(select.value || "").trim()] || "");
        }
      });
    });
  }

  function applyListRowFilteringAndGrouping(surface, table, state) {
    const headers = Array.from(table.querySelectorAll("thead th"));
    clearListGroupRows(table);
    const rows = listDataRows(table);
    if (!rows.length) {
      return;
    }

    const filters = state.filters && typeof state.filters === "object" ? state.filters : {};
    const globalSearch = String(state.global_search || "").trim().toLowerCase();
    const personFilter = String(state.person_filter || "").trim().toLowerCase();

    rows.forEach((row) => {
      let visible = true;

      if (globalSearch) {
        visible = String(row.textContent || "").toLowerCase().includes(globalSearch);
      }

      if (visible && personFilter) {
        visible = String(row.textContent || "").toLowerCase().includes(personFilter);
      }

      if (visible) {
        Object.keys(filters).forEach((idxKey) => {
          if (!visible) {
            return;
          }
          const idx = asInt(idxKey, -1);
          const query = String(filters[idxKey] || "").trim().toLowerCase();
          if (!query || idx < 0) {
            return;
          }
          const cell = row.cells[idx];
          const value = sortTextFromCell(cell).toLowerCase();
          if (!value.includes(query)) {
            visible = false;
          }
        });
      }

      row.hidden = !visible;
    });

    if (!Number.isInteger(state.group_by) || state.group_by < 0 || state.group_by >= headers.length) {
      return;
    }

    const body = table.tBodies[0];
    if (!body) {
      return;
    }

    const groupIndex = state.group_by;
    let lastGroup = "";
    rows.forEach((row) => {
      if (row.hidden) {
        return;
      }
      const label = sortTextFromCell(row.cells[groupIndex]) || "No value";
      if (label !== lastGroup) {
        lastGroup = label;
        const groupRow = document.createElement("tr");
        groupRow.className = "list-group-row";
        const td = document.createElement("td");
        td.colSpan = Math.max(1, headers.length);
        td.innerHTML = `<span class="pill soft">Group</span> ${escapeHtml(lastGroup)}`;
        groupRow.appendChild(td);
        body.insertBefore(groupRow, row);
      }
    });
  }

  function collectPeopleValues(table) {
    const values = new Set();
    listDataRows(table).forEach((row) => {
      Array.from(row.cells).forEach((cell) => {
        const select = cell.querySelector("select[data-field='owner_user_id'], select[data-field='assignee_user_id']");
        if (select) {
          const text = String(select.options[select.selectedIndex]?.textContent || "").trim();
          if (text && text.toLowerCase() !== "unassigned") {
            values.add(text);
          }
        }
      });
    });
    return Array.from(values).sort((a, b) => a.localeCompare(b));
  }

  function collectColumnOptions(table, colIndex) {
    const rows = listDataRows(table);
    const firstSelect = rows
      .map((row) => row.cells[colIndex]?.querySelector("select"))
      .find((node) => Boolean(node));
    if (firstSelect) {
      return Array.from(firstSelect.options).map((option) => ({
        value: String(option.value || "").trim(),
        label: String(option.dataset.baseLabel || option.textContent || "").trim(),
      }));
    }
    const values = new Set();
    rows.forEach((row) => {
      const text = sortTextFromCell(row.cells[colIndex]);
      if (text) {
        values.add(String(text).trim());
      }
    });
    return Array.from(values).map((value) => ({ value, label: value }));
  }

  function currentUserName() {
    const chip = document.querySelector(".user-chip");
    if (!chip) {
      return "";
    }
    return String(chip.textContent || "").split("·")[0].trim();
  }

  function runListSort(table, headers, colIndex, forcedDirection) {
    const body = table.tBodies[0];
    if (!body) {
      return "none";
    }
    const rows = listDataRows(table);
    if (!rows.length || colIndex < 0 || colIndex >= headers.length) {
      return "none";
    }
    const header = headers[colIndex];
    const nextDir = forcedDirection || (header.dataset.sortDirection === "asc" ? "desc" : "asc");

    headers.forEach((th) => {
      th.dataset.sortDirection = "none";
      th.setAttribute("aria-sort", "none");
    });
    header.dataset.sortDirection = nextDir;
    header.setAttribute("aria-sort", nextDir === "asc" ? "ascending" : "descending");

    rows.sort((left, right) => {
      const lv = sortableValue(sortTextFromCell(left.cells[colIndex]));
      const rv = sortableValue(sortTextFromCell(right.cells[colIndex]));
      const cmp = compareValues(lv, rv);
      return nextDir === "asc" ? cmp : -cmp;
    });
    rows.forEach((row) => body.appendChild(row));
    return nextDir;
  }

  function applyListColumnState(surface, table, state) {
    const headers = Array.from(table.querySelectorAll("thead th"));
    const count = headers.length;
    state.visible_columns = cleanColumnIndexes(state.visible_columns, count);

    const restrictedView = Object.keys(state.restrict_view_columns || {})
      .map((key) => asInt(key, -1))
      .filter((idx) => idx >= 0 && idx < count && Boolean(state.restrict_view_columns[String(idx)]));
    setListColumnRules(surface, state.visible_columns, restrictedView);

    headers.forEach((header, index) => {
      const key = String(index);
      const required = Boolean(state.required_columns && state.required_columns[key]);
      const restrictedEdit = Boolean(state.restrict_edit_columns && state.restrict_edit_columns[key]);
      const description = String((state.descriptions && state.descriptions[key]) || "").trim();
      const muted = Boolean(state.muted_assign_columns && state.muted_assign_columns[key]);

      header.classList.toggle("required-column", required);
      header.classList.toggle("restricted-edit-column", restrictedEdit);
      header.classList.toggle("muted-column", muted);
      header.title = description || headerLabelText(header, index);
      if (description) {
        header.dataset.colDescription = description;
      } else {
        delete header.dataset.colDescription;
      }
    });

    listDataRows(table).forEach((row) => {
      headers.forEach((_header, index) => {
        const key = String(index);
        const required = Boolean(state.required_columns && state.required_columns[key]);
        const restrictedEdit = Boolean(state.restrict_edit_columns && state.restrict_edit_columns[key]);
        const typeOverride = String((state.column_types && state.column_types[key]) || "");
        const cell = row.cells[index];
        if (!cell) {
          return;
        }
        const field = cell.querySelector("input, select, textarea");
        if (!field) {
          return;
        }
        if (field.dataset.baseDisabled === undefined) {
          field.dataset.baseDisabled = field.disabled ? "1" : "0";
        }
        const baseDisabled = field.dataset.baseDisabled === "1";
        field.disabled = baseDisabled || restrictedEdit;
        if (required) {
          field.setAttribute("required", "required");
        } else {
          field.removeAttribute("required");
        }
        if (field instanceof HTMLInputElement && field.classList.contains("list-custom-input")) {
          if (["text", "number", "date"].includes(typeOverride)) {
            field.type = typeOverride;
          } else {
            field.type = "text";
          }
        }
      });
    });

    applyListLabelAliases(table, state);
    applyListRowFilteringAndGrouping(surface, table, state);
    refreshSemanticTones(surface);
  }

  function sortTextFromCell(cell) {
    if (!cell) {
      return "";
    }
    const field = cell.querySelector("input, select, textarea");
    if (field) {
      return String(field.value || "").trim();
    }
    return String(cell.textContent || "").trim();
  }

  function sortableValue(raw) {
    const value = String(raw || "").trim();
    if (!value) {
      return { t: "text", v: "" };
    }
    if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
      return { t: "date", v: value };
    }
    const numeric = Number.parseFloat(value.replace(/[^0-9.\-]/g, ""));
    if (Number.isFinite(numeric) && /[-\d]/.test(value)) {
      return { t: "num", v: numeric };
    }
    return { t: "text", v: value.toLowerCase() };
  }

  function compareValues(a, b) {
    if (a.t === "num" && b.t === "num") {
      return a.v - b.v;
    }
    if (a.t === "date" && b.t === "date") {
      return a.v.localeCompare(b.v);
    }
    if (a.t === "text" && b.t === "text") {
      return a.v.localeCompare(b.v);
    }
    return String(a.v).localeCompare(String(b.v));
  }

  function ensureListColumnMenu() {
    let shell = document.getElementById("list-column-menu-shell");
    if (shell) {
      return shell;
    }
    shell = document.createElement("div");
    shell.id = "list-column-menu-shell";
    shell.className = "list-col-menu-shell";
    shell.setAttribute("hidden", "hidden");
    shell.innerHTML = `
      <div class="list-col-menu-backdrop" data-close-list-col-menu="1"></div>
      <section class="list-col-menu" role="menu" aria-label="Column menu">
        <button type="button" class="list-col-menu-item" data-action="edit_labels">Edit labels</button>
        <details class="list-col-submenu">
          <summary>Settings</summary>
          <div class="list-col-submenu-body">
            <button type="button" class="list-col-menu-item" data-action="settings_customize_people">Customize People column</button>
            <button type="button" class="list-col-menu-item" data-action="settings_add_description">Add description</button>
            <button type="button" class="list-col-menu-item" data-action="settings_mute_assign">Mute assign notifications</button>
            <button type="button" class="list-col-menu-item" data-action="settings_required">Set column as required</button>
            <button type="button" class="list-col-menu-item" data-action="settings_restrict_edit">Restrict column editing</button>
            <button type="button" class="list-col-menu-item" data-action="settings_restrict_view">Restrict column view</button>
            <button type="button" class="list-col-menu-item" data-action="settings_summary">Show column summary</button>
            <button type="button" class="list-col-menu-item" data-action="settings_save_template" disabled>Save column as a template</button>
          </div>
        </details>
        <button type="button" class="list-col-menu-item" data-action="auto_assign_people">Auto-assign people</button>
        <button type="button" class="list-col-menu-item" data-action="filter">Filter</button>
        <details class="list-col-submenu">
          <summary>Sort</summary>
          <div class="list-col-submenu-body">
            <button type="button" class="list-col-menu-item" data-action="sort" data-value="asc">Sort ascending</button>
            <button type="button" class="list-col-menu-item" data-action="sort" data-value="desc">Sort descending</button>
            <button type="button" class="list-col-menu-item" data-action="sort" data-value="none">Clear sort</button>
          </div>
        </details>
        <button type="button" class="list-col-menu-item" data-action="collapse">Collapse</button>
        <button type="button" class="list-col-menu-item" data-action="group_by">Group by</button>
        <button type="button" class="list-col-menu-item" data-action="duplicate">Duplicate column</button>
        <button type="button" class="list-col-menu-item" data-action="add_right">Add column to the right</button>
        <details class="list-col-submenu">
          <summary>Change column type</summary>
          <div class="list-col-submenu-body">
            <button type="button" class="list-col-menu-item" data-action="change_type" data-value="text">Text</button>
            <button type="button" class="list-col-menu-item" data-action="change_type" data-value="number">Number</button>
            <button type="button" class="list-col-menu-item" data-action="change_type" data-value="date">Date</button>
            <button type="button" class="list-col-menu-item" data-action="change_type" data-value="status">Status</button>
            <button type="button" class="list-col-menu-item" data-action="change_type" data-value="people">People</button>
          </div>
        </details>
        <details class="list-col-submenu">
          <summary>Column extensions</summary>
          <div class="list-col-submenu-body">
            <button type="button" class="list-col-menu-item" data-action="extension_clear">Clear column values</button>
            <button type="button" class="list-col-menu-item" data-action="extension_fill">Fill down first value</button>
          </div>
        </details>
        <button type="button" class="list-col-menu-item" data-action="rename">Rename</button>
        <button type="button" class="list-col-menu-item danger" data-action="delete">Delete</button>
      </section>
    `;
    document.body.appendChild(shell);
    return shell;
  }

  function closeListColumnMenu() {
    const shell = document.getElementById("list-column-menu-shell");
    if (!shell) {
      return;
    }
    shell.setAttribute("hidden", "hidden");
    activeListColumnContext = null;
  }

  function openListColumnMenu(context, anchor) {
    const shell = ensureListColumnMenu();
    const menu = shell.querySelector(".list-col-menu");
    if (!menu || !anchor) {
      return;
    }
    activeListColumnContext = context;
    shell.removeAttribute("hidden");
    menu.style.left = "0px";
    menu.style.top = "0px";
    const rect = anchor.getBoundingClientRect();
    const left = Math.max(8, Math.min(window.innerWidth - 360, rect.left));
    const top = Math.max(8, Math.min(window.innerHeight - 560, rect.bottom + 6));
    menu.style.left = `${left}px`;
    menu.style.top = `${top}px`;
  }

  function summarizeColumn(table, colIndex) {
    const values = listDataRows(table).map((row) => sortTextFromCell(row.cells[colIndex])).filter(Boolean);
    const unique = new Set(values.map((value) => value.trim()));
    const numeric = values.map((value) => Number.parseFloat(value.replace(/[^0-9.\-]/g, ""))).filter((value) => Number.isFinite(value));
    const total = numeric.reduce((sum, value) => sum + value, 0);
    const avg = numeric.length ? total / numeric.length : 0;
    return {
      rows: values.length,
      unique: unique.size,
      numeric_count: numeric.length,
      total,
      average: avg,
      top_values: Array.from(unique).slice(0, 8),
    };
  }

  function openColumnSummaryModal(context) {
    const { table, index, headers } = context;
    const summary = summarizeColumn(table, index);
    openModal(
      `Column Summary: ${headerLabelText(headers[index], index)}`,
      `
      <div class="modal-grid two-col">
        <label>Total non-empty values <input readonly value="${escapeHtml(summary.rows)}" /></label>
        <label>Unique values <input readonly value="${escapeHtml(summary.unique)}" /></label>
        <label>Numeric values <input readonly value="${escapeHtml(summary.numeric_count)}" /></label>
        <label>Numeric total <input readonly value="${escapeHtml(Math.round(summary.total * 100) / 100)}" /></label>
        <label>Numeric average <input readonly value="${escapeHtml(Math.round(summary.average * 100) / 100)}" /></label>
      </div>
      <label>Top values
        <textarea readonly rows="5">${escapeHtml(summary.top_values.join("\n"))}</textarea>
      </label>
      `,
      async () => {
        closeModal();
      },
      "Close",
    );
  }

  function openColumnLabelEditor(context) {
    const { boardKey, table, state, index, headers, applyAndSave } = context;
    const source = collectColumnOptions(table, index).filter((item) => String(item.value || "").trim() !== "");
    if (!source.length) {
      setModalFeedback("No label values found for this column.", true);
      return;
    }
    const key = String(index);
    const currentMap = state.label_aliases[key] && typeof state.label_aliases[key] === "object" ? state.label_aliases[key] : {};
    const currentColors = state.label_colors[key] && typeof state.label_colors[key] === "object" ? state.label_colors[key] : {};
    const formRows = source
      .map(
        (item, idx) => `
          <label class="list-label-editor-row">
            <span>${escapeHtml(item.label)}</span>
            <div class="list-label-editor-controls">
              <input name="alias_${idx}" data-label-value="${escapeHtml(item.value)}" value="${escapeHtml(currentMap[item.value] || "")}" placeholder="Display label" />
              <input type="color" data-label-color="${escapeHtml(item.value)}" value="${escapeHtml(normalizeHexColor(currentColors[item.value] || "") || "#4db0ff")}" aria-label="Color for ${escapeHtml(item.label)}" />
            </div>
          </label>
        `,
      )
      .join("");
    openModal(
      `Edit Labels: ${headerLabelText(headers[index], index)}`,
      `<div class="list-label-editor-grid">${formRows}</div>`,
      async () => {
        const aliasMap = {};
        const colorMap = {};
        const inputs = Array.from(document.querySelectorAll("#card-editor-form [data-label-value]"));
        inputs.forEach((input) => {
          if (!(input instanceof HTMLInputElement)) {
            return;
          }
          const value = String(input.getAttribute("data-label-value") || "");
          const alias = String(input.value || "").trim();
          if (value && alias) {
            aliasMap[value] = alias;
          }
        });
        const colorInputs = Array.from(document.querySelectorAll("#card-editor-form [data-label-color]"));
        colorInputs.forEach((input) => {
          if (!(input instanceof HTMLInputElement)) {
            return;
          }
          const value = String(input.getAttribute("data-label-color") || "").trim();
          const color = normalizeHexColor(input.value || "");
          if (value && color) {
            colorMap[value] = color;
          }
        });
        state.label_aliases[key] = aliasMap;
        state.label_colors[key] = colorMap;
        saveListState(boardKey, state);
        applyAndSave();
        logInterfaceEvent(
          "ui_design_changed",
          {
            surface: "list",
            board_key: boardKey,
            column_index: index,
            change: "edit_labels",
            labels_count: Object.keys(aliasMap).length,
            colors_count: Object.keys(colorMap).length,
          },
          "List labels updated",
          boardKey,
        );
        closeModal();
      },
      "Save Labels",
    );
  }

  function cloneListColumn(table, colIndex) {
    Array.from(table.rows).forEach((row) => {
      const source = row.cells[colIndex];
      if (!source) {
        return;
      }
      const clone = source.cloneNode(true);
      row.insertBefore(clone, row.cells[colIndex + 1] || null);
    });
  }

  function addListColumnRight(table, colIndex) {
    Array.from(table.rows).forEach((row) => {
      const cellTag = row.parentElement && row.parentElement.tagName === "THEAD" ? "th" : "td";
      if (cellTag === "td" && row.querySelector("td[colspan]")) {
        const colspanned = row.querySelector("td[colspan]");
        if (colspanned) {
          colspanned.colSpan = asInt(colspanned.colSpan, 1) + 1;
        }
        return;
      }
      const cell = document.createElement(cellTag);
      if (cellTag === "th") {
        cell.textContent = "Custom Field";
      } else {
        cell.innerHTML = "<input class='quick-field list-quick-field list-custom-input' placeholder='Value' />";
      }
      row.insertBefore(cell, row.cells[colIndex] || null);
    });
  }

  function clearColumnValues(table, colIndex) {
    listDataRows(table).forEach((row) => {
      const cell = row.cells[colIndex];
      if (!cell) {
        return;
      }
      const field = cell.querySelector("input, select, textarea");
      if (!field) {
        return;
      }
      if (field instanceof HTMLInputElement || field instanceof HTMLTextAreaElement) {
        field.value = "";
      } else if (field instanceof HTMLSelectElement) {
        field.value = "";
      }
      field.dispatchEvent(new Event("change", { bubbles: true }));
    });
  }

  function fillDownColumnValues(table, colIndex) {
    const rows = listDataRows(table);
    if (!rows.length) {
      return;
    }
    const first = rows[0].cells[colIndex];
    const firstField = first ? first.querySelector("input, select, textarea") : null;
    if (!firstField) {
      return;
    }
    const value = String(firstField.value || "");
    rows.slice(1).forEach((row) => {
      const field = row.cells[colIndex] ? row.cells[colIndex].querySelector("input, select, textarea") : null;
      if (!field) {
        return;
      }
      field.value = value;
      field.dispatchEvent(new Event("change", { bubbles: true }));
    });
  }

  function setupListColumnMenuEvents() {
    const shell = ensureListColumnMenu();
    if (shell.dataset.bound === "1") {
      return;
    }
    shell.dataset.bound = "1";
    shell.addEventListener("click", (event) => {
      if (event.target.closest("[data-close-list-col-menu='1']")) {
        closeListColumnMenu();
        return;
      }
      const actionNode = event.target.closest("[data-action]");
      if (!actionNode || !(actionNode instanceof HTMLElement)) {
        return;
      }
      if (!activeListColumnContext) {
        return;
      }
      const action = actionNode.getAttribute("data-action") || "";
      const value = actionNode.getAttribute("data-value") || "";
      const ctx = activeListColumnContext;
      const { state, index, headers, boardKey, table, applyAndSave, rebuild } = ctx;
      const key = String(index);
      const title = headerLabelText(headers[index], index);
      const trackChange = (change, extra) => {
        logInterfaceEvent(
          "ui_design_changed",
          {
            surface: "list",
            board_key: boardKey,
            column_index: index,
            change,
            ...(extra || {}),
          },
          `List ${change}`,
          boardKey,
        );
      };

      const toggleFlag = (objName) => {
        if (!state[objName] || typeof state[objName] !== "object") {
          state[objName] = {};
        }
        state[objName][key] = !Boolean(state[objName][key]);
        applyAndSave();
        trackChange(objName, { value: Boolean(state[objName][key]) });
      };

      if (action === "edit_labels") {
        openColumnLabelEditor(ctx);
        closeListColumnMenu();
        return;
      }
      if (action === "settings_customize_people") {
        openColumnLabelEditor(ctx);
        closeListColumnMenu();
        return;
      }
      if (action === "settings_add_description") {
        const desc = window.prompt(`Description for "${title}"`, String(state.descriptions[key] || ""));
        if (desc !== null) {
          state.descriptions[key] = String(desc).trim();
          applyAndSave();
          trackChange("description_updated");
        }
        closeListColumnMenu();
        return;
      }
      if (action === "settings_mute_assign") {
        toggleFlag("muted_assign_columns");
        closeListColumnMenu();
        return;
      }
      if (action === "settings_required") {
        toggleFlag("required_columns");
        closeListColumnMenu();
        return;
      }
      if (action === "settings_restrict_edit") {
        toggleFlag("restrict_edit_columns");
        closeListColumnMenu();
        return;
      }
      if (action === "settings_restrict_view") {
        toggleFlag("restrict_view_columns");
        closeListColumnMenu();
        return;
      }
      if (action === "settings_summary") {
        openColumnSummaryModal(ctx);
        closeListColumnMenu();
        return;
      }
      if (action === "settings_save_template") {
        closeListColumnMenu();
        return;
      }
      if (action === "auto_assign_people") {
        const preferred = currentUserName().toLowerCase();
        listDataRows(table).forEach((row) => {
          const cell = row.cells[index];
          if (!cell) {
            return;
          }
          const select = cell.querySelector("select[data-field='owner_user_id'], select[data-field='assignee_user_id']");
          if (!select || String(select.value || "").trim()) {
            return;
          }
          const options = Array.from(select.options).filter((option) => String(option.value || "").trim());
          if (!options.length) {
            return;
          }
          const preferredOption = options.find((option) => String(option.textContent || "").trim().toLowerCase() === preferred);
          select.value = String((preferredOption || options[0]).value || "");
          select.dispatchEvent(new Event("change", { bubbles: true }));
        });
        closeListColumnMenu();
        return;
      }
      if (action === "filter") {
        const existing = state.filters[key] || "";
        const query = window.prompt(`Filter value for "${title}" (leave blank to clear)`, String(existing));
        if (query === null) {
          closeListColumnMenu();
          return;
        }
        const cleaned = String(query || "").trim();
        if (cleaned) {
          state.filters[key] = cleaned;
        } else {
          delete state.filters[key];
        }
        applyAndSave();
        trackChange("filter_updated");
        closeListColumnMenu();
        return;
      }
      if (action === "sort") {
        const headersNow = Array.from(table.querySelectorAll("thead th"));
        if (value === "none") {
          headersNow.forEach((header) => {
            header.dataset.sortDirection = "none";
            header.setAttribute("aria-sort", "none");
          });
          state.sort_index = null;
          state.sort_direction = "none";
          applyAndSave();
          trackChange("sort_updated", { direction: "none" });
        } else {
          const direction = value === "desc" ? "desc" : "asc";
          const next = runListSort(table, headersNow, index, direction);
          state.sort_index = index;
          state.sort_direction = next;
          applyAndSave();
          trackChange("sort_updated", { direction: next });
        }
        closeListColumnMenu();
        return;
      }
      if (action === "collapse") {
        state.visible_columns = cleanColumnIndexes(
          (state.visible_columns || []).filter((idx) => idx !== index),
          headers.length,
        );
        applyAndSave();
        rebuild();
        trackChange("column_collapsed");
        closeListColumnMenu();
        return;
      }
      if (action === "group_by") {
        state.group_by = state.group_by === index ? null : index;
        applyAndSave();
        trackChange("group_by_updated", { group_by: state.group_by });
        closeListColumnMenu();
        return;
      }
      if (action === "duplicate") {
        cloneListColumn(table, index);
        const insertAt = index + 1;
        const nextVisible = cleanColumnIndexes(state.visible_columns || [], table.querySelectorAll("thead th").length);
        if (!nextVisible.includes(insertAt)) {
          nextVisible.push(insertAt);
        }
        state.visible_columns = nextVisible;
        saveListState(boardKey, state);
        rebuild();
        trackChange("column_duplicated");
        closeListColumnMenu();
        return;
      }
      if (action === "add_right") {
        addListColumnRight(table, index + 1);
        const insertAt = index + 1;
        const nextVisible = cleanColumnIndexes(state.visible_columns || [], table.querySelectorAll("thead th").length);
        if (!nextVisible.includes(insertAt)) {
          nextVisible.push(insertAt);
        }
        state.visible_columns = nextVisible;
        saveListState(boardKey, state);
        rebuild();
        trackChange("column_added_right");
        closeListColumnMenu();
        return;
      }
      if (action === "change_type") {
        state.column_types[key] = value || "text";
        applyAndSave();
        trackChange("column_type_changed", { type: state.column_types[key] });
        closeListColumnMenu();
        return;
      }
      if (action === "extension_clear") {
        clearColumnValues(table, index);
        closeListColumnMenu();
        return;
      }
      if (action === "extension_fill") {
        fillDownColumnValues(table, index);
        closeListColumnMenu();
        return;
      }
      if (action === "rename") {
        const renamed = window.prompt("Column name", title);
        if (renamed !== null && String(renamed).trim()) {
          const titleNode = headers[index].querySelector(".list-col-title");
          if (titleNode) {
            titleNode.textContent = String(renamed).trim();
          } else {
            headers[index].textContent = String(renamed).trim();
          }
          rebuild();
          trackChange("column_renamed", { title: String(renamed).trim() });
        }
        closeListColumnMenu();
        return;
      }
      if (action === "delete") {
        if (!window.confirm(`Hide "${title}" from this list view?`)) {
          closeListColumnMenu();
          return;
        }
        state.visible_columns = cleanColumnIndexes(
          (state.visible_columns || []).filter((idx) => idx !== index),
          headers.length,
        );
        applyAndSave();
        rebuild();
        trackChange("column_hidden");
        closeListColumnMenu();
      }
    });

    window.addEventListener("keydown", (event) => {
      if (event.key === "Escape") {
        closeListColumnMenu();
      }
    });
  }

  function enhanceListHeaders(surface, table, state, runSortAndApply, rebuild) {
    const headers = Array.from(table.querySelectorAll("thead th"));
    headers.forEach((header, index) => {
      header.classList.add("sortable", "list-column-header");
      header.tabIndex = 0;
      if (!header.dataset.sortDirection) {
        header.dataset.sortDirection = "none";
      }
      if (!header.getAttribute("aria-sort")) {
        header.setAttribute("aria-sort", "none");
      }

      const currentLabel = headerLabelText(header, index);
      header.innerHTML = `
        <div class="list-col-header-inner">
          <button type="button" class="list-col-title" data-col-index="${index}" aria-label="Sort ${escapeHtml(currentLabel)}">
            ${escapeHtml(currentLabel)}
          </button>
          <div class="list-col-header-actions">
            <button type="button" class="list-col-menu-btn" data-col-index="${index}" aria-label="Column menu for ${escapeHtml(currentLabel)}">⋯</button>
          </div>
        </div>
      `;
    });

    if (table.dataset.listHeaderBound === "1") {
      return;
    }
    table.dataset.listHeaderBound = "1";
    table.addEventListener("click", (event) => {
      const titleNode = event.target.closest(".list-col-title[data-col-index]");
      if (titleNode) {
        const idx = asInt(titleNode.getAttribute("data-col-index"), -1);
        if (idx >= 0) {
          runSortAndApply(idx);
        }
        return;
      }
      const menuNode = event.target.closest(".list-col-menu-btn[data-col-index]");
      if (!menuNode) {
        return;
      }
      const idx = asInt(menuNode.getAttribute("data-col-index"), -1);
      if (idx < 0) {
        return;
      }
      const boardKey = surface.getAttribute("data-view-surface") || "";
      const registry = listSurfaceRegistry.get(boardKey);
      if (!registry) {
        return;
      }
      openListColumnMenu(
        {
          boardKey,
          surface,
          table,
          state: registry.state,
          index: idx,
          headers: Array.from(table.querySelectorAll("thead th")),
          applyAndSave: registry.applyAndSave,
          rebuild,
        },
        menuNode,
      );
    });
  }

  function buildListToolbar(surface, table) {
    const boardKey = surface.getAttribute("data-view-surface") || "";
    if (!boardKey) {
      return;
    }
    const headers = Array.from(table.querySelectorAll("thead th"));
    if (!headers.length) {
      return;
    }

    surface.querySelectorAll(".list-toolbar").forEach((node) => node.remove());

    const state = loadListState(boardKey, headers.length);
    const runSortAndApply = (index, direction) => {
      const allHeaders = Array.from(table.querySelectorAll("thead th"));
      const next = runListSort(table, allHeaders, index, direction);
      state.sort_index = index;
      state.sort_direction = next;
      applyAndSave();
      return next;
    };

    const applyAndSave = () => {
      applyListColumnState(surface, table, state);
      saveListState(boardKey, state);
    };

    const rebuild = () => {
      buildListToolbar(surface, table);
    };

    const toolbar = document.createElement("div");
    toolbar.className = "list-toolbar";
    toolbar.innerHTML = `
      <div class="list-toolbar-main">
        <label class="list-toolbar-search">
          <span class="sr-only">Search list view rows</span>
          <input type="search" class="list-search-input" placeholder="Search" value="${escapeHtml(state.global_search || "")}" />
        </label>
        <label class="list-toolbar-person">
          <span>Person</span>
          <select class="list-person-filter"><option value="">All</option></select>
        </label>
        <button type="button" class="btn ghost list-toolbar-btn" data-list-action="filter">Filter</button>
        <button type="button" class="btn ghost list-toolbar-btn" data-list-action="sort">Sort</button>
        <button type="button" class="btn ghost list-toolbar-btn" data-list-action="group">Group by</button>
      </div>
    `;

    const details = document.createElement("details");
    details.className = "list-columns";
    details.innerHTML = `
      <summary>Hide</summary>
      <div class="list-columns-grid"></div>
    `;
    toolbar.appendChild(details);
    surface.insertBefore(toolbar, table);

    const grid = details.querySelector(".list-columns-grid");
    if (!grid) {
      return;
    }
    const renderColumnChooser = () => {
      const currentHeaders = Array.from(table.querySelectorAll("thead th"));
      const visibleSet = new Set(cleanColumnIndexes(state.visible_columns, currentHeaders.length));
      grid.innerHTML = "";
      currentHeaders.forEach((header, index) => {
        const label = document.createElement("label");
        const checked = visibleSet.has(index);
        label.innerHTML = `<input type="checkbox" value="${index}"${checked ? " checked" : ""} /> ${escapeHtml(headerLabelText(header, index))}`;
        grid.appendChild(label);
      });
    };

    renderColumnChooser();

    grid.addEventListener("change", () => {
      const selected = Array.from(grid.querySelectorAll("input[type='checkbox']:checked"))
        .map((node) => Number.parseInt(node.value, 10))
        .filter((value) => Number.isInteger(value));
      if (!selected.length) {
        const first = grid.querySelector("input[type='checkbox']");
        if (first) {
          first.checked = true;
        }
        return;
      }
      state.visible_columns = cleanColumnIndexes(selected, table.querySelectorAll("thead th").length);
      applyAndSave();
    });

    const peopleFilter = toolbar.querySelector(".list-person-filter");
    if (peopleFilter instanceof HTMLSelectElement) {
      const values = collectPeopleValues(table);
      peopleFilter.innerHTML = `<option value="">All</option>${values.map((value) => `<option value="${escapeHtml(value)}"${state.person_filter === value ? " selected" : ""}>${escapeHtml(value)}</option>`).join("")}`;
      peopleFilter.addEventListener("change", () => {
        state.person_filter = String(peopleFilter.value || "");
        applyAndSave();
      });
    }

    const searchInput = toolbar.querySelector(".list-search-input");
    if (searchInput instanceof HTMLInputElement) {
      searchInput.addEventListener("input", () => {
        state.global_search = String(searchInput.value || "");
        applyAndSave();
      });
    }

    toolbar.querySelectorAll("[data-list-action]").forEach((button) => {
      button.addEventListener("click", () => {
        const action = button.getAttribute("data-list-action") || "";
        if (action === "filter") {
          const names = Array.from(table.querySelectorAll("thead th")).map((header, idx) => `${idx + 1}. ${headerLabelText(header, idx)}`);
          const pick = window.prompt(`Choose column number for filter:\n${names.join("\n")}`, "1");
          const idx = asInt(pick, 1) - 1;
          if (idx < 0 || idx >= table.querySelectorAll("thead th").length) {
            return;
          }
          const label = headerLabelText(Array.from(table.querySelectorAll("thead th"))[idx], idx);
          const value = window.prompt(`Filter value for "${label}" (blank clears)`, String(state.filters[String(idx)] || ""));
          if (value === null) {
            return;
          }
          const cleaned = String(value || "").trim();
          if (cleaned) {
            state.filters[String(idx)] = cleaned;
          } else {
            delete state.filters[String(idx)];
          }
          applyAndSave();
          return;
        }
        if (action === "sort") {
          const names = Array.from(table.querySelectorAll("thead th")).map((header, idx) => `${idx + 1}. ${headerLabelText(header, idx)}`);
          const pick = window.prompt(`Choose column number to sort:\n${names.join("\n")}`, "1");
          const idx = asInt(pick, 1) - 1;
          if (idx < 0 || idx >= table.querySelectorAll("thead th").length) {
            return;
          }
          const dirRaw = window.prompt("Direction: asc or desc", "asc");
          const dir = String(dirRaw || "").toLowerCase() === "desc" ? "desc" : "asc";
          runSortAndApply(idx, dir);
          return;
        }
        if (action === "group") {
          const names = Array.from(table.querySelectorAll("thead th")).map((header, idx) => `${idx + 1}. ${headerLabelText(header, idx)}`);
          const pick = window.prompt(`Choose column number to group by (blank clears):\n${names.join("\n")}`, state.group_by !== null ? String(state.group_by + 1) : "");
          const cleaned = String(pick || "").trim();
          if (!cleaned) {
            state.group_by = null;
          } else {
            const idx = asInt(cleaned, 1) - 1;
            if (idx >= 0 && idx < table.querySelectorAll("thead th").length) {
              state.group_by = idx;
            }
          }
          applyAndSave();
        }
      });
    });

    enhanceListHeaders(surface, table, state, runSortAndApply, rebuild);
    setupListColumnMenuEvents();

    const registryItem = {
      boardKey,
      surface,
      table,
      state,
      applyAndSave,
    };
    listSurfaceRegistry.set(boardKey, registryItem);

    applyAndSave();
    renderColumnChooser();
  }

  function initListCustomization() {
    document.querySelectorAll(".board-list-surface table").forEach((table) => {
      const surface = table.closest(".board-list-surface");
      if (!surface) {
        return;
      }
      buildListToolbar(surface, table);
    });
  }

  function initBoardViewToggles() {
    const toggles = document.querySelectorAll(".view-mode-toggle[data-view-key]");
    toggles.forEach((toggle) => {
      const key = toggle.getAttribute("data-view-key") || "";
      if (!key) {
        return;
      }
      const storageKey = `makerflow-board-mode-${key}`;
      const surfaces = document.querySelectorAll(`[data-view-surface='${key}']`);
      if (!surfaces.length) {
        return;
      }
      const buttons = toggle.querySelectorAll(".mode-btn[data-view-mode]");
      const applyMode = (mode) => {
        const selected = mode === "list" ? "list" : "kanban";
        surfaces.forEach((surface) => {
          const isActive = (surface.getAttribute("data-view-mode") || "kanban") === selected;
          surface.hidden = !isActive;
        });
        buttons.forEach((button) => {
          const on = (button.getAttribute("data-view-mode") || "kanban") === selected;
          button.classList.toggle("ghost", !on);
          button.setAttribute("aria-pressed", on ? "true" : "false");
        });
        window.localStorage.setItem(storageKey, selected);
      };
      const initial = window.localStorage.getItem(storageKey) || toggle.getAttribute("data-default-mode") || "kanban";
      applyMode(initial);
      buttons.forEach((button) => {
        button.addEventListener("click", () => applyMode(button.getAttribute("data-view-mode") || "kanban"));
      });
    });
  }

  function listEntityConfig(entity) {
    const map = {
      task: { saveUrl: "/api/tasks/save", idField: "task_id", boardId: "task-kanban", cardSelector: ".task-card", moveFn: moveTask },
      project: { saveUrl: "/api/projects/save", idField: "project_id", boardId: "project-kanban", cardSelector: ".project-card", moveFn: moveProject },
      intake: { saveUrl: "/api/intake/save", idField: "intake_id", boardId: "intake-kanban", cardSelector: ".intake-card", moveFn: moveIntake },
      asset: { saveUrl: "/api/assets/save", idField: "asset_id", boardId: "asset-kanban", cardSelector: ".asset-card", moveFn: moveAsset },
      consumable: { saveUrl: "/api/consumables/save", idField: "consumable_id", boardId: "consumable-kanban", cardSelector: ".consumable-card", moveFn: moveConsumable },
      partnership: { saveUrl: "/api/partnerships/save", idField: "partnership_id", boardId: "partnership-kanban", cardSelector: ".partnership-card", moveFn: movePartnership },
    };
    return map[entity] || null;
  }

  function findCardByEntity(config, id) {
    if (!config || !config.boardId) {
      return null;
    }
    const board = document.getElementById(config.boardId);
    if (!board) {
      return null;
    }
    return board.querySelector(`${config.cardSelector}[data-id="${escapeCssValue(String(id))}"]`);
  }

  function openListEntityEditor(entity, id) {
    if (!entity || !id) {
      return;
    }
    if (entity === "task") {
      const task = taskById.get(String(id));
      if (task) {
        openTaskEditor(task, false).catch(() => {
          setModalFeedback("Could not open task editor.", true);
        });
      }
      return;
    }
    const config = listEntityConfig(entity);
    const card = findCardByEntity(config, id);
    if (!card) {
      return;
    }
    const openers = {
      project: openProjectEditor,
      intake: openIntakeEditor,
      asset: openAssetEditor,
      consumable: openConsumableEditor,
      partnership: openPartnershipEditor,
    };
    const opener = openers[entity];
    if (!opener) {
      return;
    }
    opener(card).catch(() => {
      setModalFeedback(`Could not open ${entity} editor.`, true);
    });
  }

  function initListInlineEditing() {
    document.addEventListener("focusin", (event) => {
      const node = event.target;
      if (!(node instanceof HTMLElement)) {
        return;
      }
      const fieldNode = node.closest(".list-quick-status[data-entity][data-id], .list-quick-field[data-entity][data-id][data-field]");
      if (!fieldNode) {
        return;
      }
      if (fieldNode.dataset.prevValue === undefined) {
        fieldNode.dataset.prevValue = String(fieldNode.value || "");
      }
    });

    document.addEventListener("change", async (event) => {
      const statusNode = event.target.closest(".list-quick-status[data-entity][data-id]");
      if (statusNode) {
        const entity = statusNode.getAttribute("data-entity") || "";
        const id = statusNode.getAttribute("data-id") || "";
        const status = statusNode.value || "";
        const config = listEntityConfig(entity);
        if (!config || !id || !status) {
          return;
        }
        const board = document.getElementById(config.boardId);
        if (board && isKanbanStatusRestricted(board, status)) {
          setModalFeedback("This status column is restricted by board settings.", true);
          return;
        }
        try {
          await config.moveFn(id, status);
          if (entity === "task") {
            await refreshTaskBoard();
          } else {
            const card = findCardByEntity(config, id);
            if (card) {
              if (entity === "partnership") {
                card.dataset.stage = status;
              }
              card.dataset.status = status;
              updateCardStatusSelect(card, status);
              moveCardToStatus(card, entity, status);
              syncStaticCardSummary(card, entity, cachedLookups || {});
            }
          }
          applySelectTone(statusNode);
        } catch (_err) {
          setModalFeedback(`Could not update ${entity} status.`, true);
          if (entity === "task") {
            refreshTaskBoard().catch(() => {});
          }
        }
        return;
      }

      const fieldNode = event.target.closest(".list-quick-field[data-entity][data-id][data-field]");
      if (!fieldNode) {
        return;
      }
      const entity = fieldNode.getAttribute("data-entity") || "";
      const id = fieldNode.getAttribute("data-id") || "";
      const field = fieldNode.getAttribute("data-field") || "";
      const config = listEntityConfig(entity);
      if (!config || !id || !field) {
        return;
      }
      const cell = fieldNode.closest("td");
      if (cell) {
        const row = cell.parentElement;
        const colIndex = row ? Array.from(row.cells).indexOf(cell) : -1;
        const surface = fieldNode.closest(".board-list-surface");
        const boardKey = surface ? (surface.getAttribute("data-view-surface") || "") : "";
        const registry = boardKey ? listSurfaceRegistry.get(boardKey) : null;
        const required = Boolean(
          registry
            && registry.state
            && registry.state.required_columns
            && registry.state.required_columns[String(colIndex)],
        );
        if (required && !String(fieldNode.value || "").trim()) {
          fieldNode.value = String(fieldNode.dataset.prevValue || "");
          setModalFeedback("This column is required. Use Edit labels or column settings before clearing this value.", true);
          return;
        }
      }
      try {
        await postForm(config.saveUrl, { [config.idField]: id, [field]: fieldNode.value });
        if (entity === "task") {
          await refreshTaskBoard();
        } else {
          const card = findCardByEntity(config, id);
          if (card) {
            card.dataset[datasetKeyForField(field)] = fieldNode.value;
            syncQuickFieldValue(card, field, fieldNode.value);
            syncStaticCardSummary(card, entity, cachedLookups || {});
          }
        }
        applySelectTone(fieldNode);
        fieldNode.dataset.prevValue = String(fieldNode.value || "");
      } catch (_err) {
        setModalFeedback(`Could not update ${entity} field.`, true);
      }
    });

    document.addEventListener("click", (event) => {
      const openButton = event.target.closest(".list-open[data-list-entity][data-list-id]");
      if (!openButton) {
        return;
      }
      openListEntityEditor(
        openButton.getAttribute("data-list-entity") || "",
        openButton.getAttribute("data-list-id") || "",
      );
    });
  }

  function initInlineCardChat() {
    document.addEventListener("toggle", (event) => {
      const threadNode = event.target;
      if (!(threadNode instanceof HTMLDetailsElement)) {
        return;
      }
      if (threadNode.getAttribute("data-inline-chat") !== "1" || !threadNode.open) {
        return;
      }
      loadInlineCardChat(threadNode);
    }, true);

    document.addEventListener("click", async (event) => {
      const submitButton = event.target.closest("[data-inline-comment-submit='1']");
      if (!submitButton) {
        return;
      }
      event.preventDefault();
      const threadNode = submitButton.closest("[data-inline-chat='1']");
      if (!(threadNode instanceof HTMLElement)) {
        return;
      }
      const entity = String(threadNode.getAttribute("data-entity") || "").trim();
      const itemId = String(threadNode.getAttribute("data-item-id") || "").trim();
      const bodyNode = threadNode.querySelector("[data-inline-comment-body]");
      if (!(bodyNode instanceof HTMLTextAreaElement)) {
        return;
      }
      const body = String(bodyNode.value || "").trim();
      if (!body) {
        setModalFeedback("Enter a comment before posting.", true);
        return;
      }
      if (submitButton instanceof HTMLButtonElement) {
        submitButton.disabled = true;
      }
      try {
        await postForm("/api/comments/add", { entity, item_id: itemId, body });
        bodyNode.value = "";
        await loadInlineCardChat(threadNode);
      } catch (err) {
        setModalFeedback(describeRequestError(err, entity), true);
      } finally {
        if (submitButton instanceof HTMLButtonElement) {
          submitButton.disabled = false;
        }
      }
    });
  }

  function parseTimestampMs(value) {
    const parsed = Date.parse(String(value || ""));
    return Number.isFinite(parsed) ? parsed : 0;
  }

  function activitySeenStorageKey() {
    const userLabel = String(document.querySelector(".user-chip")?.textContent || "user")
      .trim()
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "_")
      .slice(0, 80);
    return `makerflow-activity-seen-${userLabel || "user"}`;
  }

  function readActivitySeenMs() {
    const raw = window.localStorage.getItem(activitySeenStorageKey()) || "0";
    const parsed = Number.parseInt(raw, 10);
    return Number.isFinite(parsed) ? parsed : 0;
  }

  function writeActivitySeenMs(value) {
    const safe = Math.max(0, Number.parseInt(String(value || 0), 10) || 0);
    window.localStorage.setItem(activitySeenStorageKey(), String(safe));
  }

  function setActivityCountBadge(count) {
    const badge = document.getElementById("activity-count");
    if (!badge) {
      return;
    }
    const safeCount = Math.max(0, Number.parseInt(String(count || 0), 10) || 0);
    badge.textContent = String(safeCount);
    badge.classList.toggle("is-empty", safeCount === 0);
  }

  function activityLinkForItem(item) {
    const entity = String((item && item.related_entity) || "").trim().replace(/^\/+/, "");
    if (!entity) {
      return "";
    }
    return withSpace(`/${entity}`);
  }

  function renderActivityList(listNode, items) {
    if (!listNode) {
      return;
    }
    if (!Array.isArray(items) || !items.length) {
      listNode.innerHTML = "<p class='muted'>No activity yet.</p>";
      return;
    }
    listNode.innerHTML = items
      .map((item) => {
        const status = String(item.status || "queued").toLowerCase();
        const href = activityLinkForItem(item);
        const timestamp = formatCommentTimestamp(item.sent_at || item.created_at || "");
        const preview = String(item.preview || "").trim();
        return `
          <article class="activity-item">
            <header class="activity-item-head">
              <strong>${escapeHtml(item.subject || "Notification")}</strong>
              <span class="pill ${status === "failed" ? "status-overdue" : "soft"}">${escapeHtml(status)}</span>
            </header>
            <p class="muted">${escapeHtml(timestamp)}</p>
            ${preview ? `<p>${escapeHtml(preview)}</p>` : ""}
            ${item.error_message ? `<p class="error-text">${escapeHtml(String(item.error_message || ""))}</p>` : ""}
            ${href ? `<p><a href="${escapeHtml(href)}">Open related item</a></p>` : ""}
          </article>
        `;
      })
      .join("");
  }

  async function fetchActivityItems(limit) {
    const params = new URLSearchParams();
    params.set("limit", String(limit || 50));
    const response = await fetch(withSpace(`/api/activity?${params.toString()}`), {
      credentials: "same-origin",
    });
    if (!response.ok) {
      throw new Error("Could not load activity.");
    }
    const payload = await response.json();
    return Array.isArray(payload.items) ? payload.items : [];
  }

  function initActivityDrawer() {
    const toggleButton = document.getElementById("activity-toggle");
    const closeButton = document.getElementById("activity-close");
    const drawer = document.getElementById("activity-drawer");
    const backdrop = document.getElementById("activity-backdrop");
    const listNode = document.getElementById("activity-list");
    if (!toggleButton || !closeButton || !drawer || !backdrop || !listNode) {
      return;
    }

    let items = [];
    let loading = false;

    const isOpen = () => drawer.classList.contains("open");
    const unreadCount = () => {
      const seenMs = readActivitySeenMs();
      return items.filter((item) => parseTimestampMs(item.created_at || item.sent_at || "") > seenMs).length;
    };
    const refreshBadge = () => {
      setActivityCountBadge(unreadCount());
    };
    const markSeen = () => {
      const latest = items.reduce((maxMs, item) => Math.max(maxMs, parseTimestampMs(item.created_at || item.sent_at || "")), 0);
      writeActivitySeenMs(Math.max(readActivitySeenMs(), latest, Date.now()));
      setActivityCountBadge(0);
    };
    const closeDrawer = () => {
      drawer.classList.remove("open");
      drawer.setAttribute("aria-hidden", "true");
      backdrop.hidden = true;
      toggleButton.setAttribute("aria-expanded", "false");
    };
    const openDrawer = () => {
      drawer.classList.add("open");
      drawer.setAttribute("aria-hidden", "false");
      backdrop.hidden = false;
      toggleButton.setAttribute("aria-expanded", "true");
    };
    const loadAndRender = async () => {
      if (loading) {
        return;
      }
      loading = true;
      if (isOpen()) {
        listNode.innerHTML = "<p class='muted'>Loading activity...</p>";
      }
      try {
        items = await fetchActivityItems(80);
        if (isOpen()) {
          renderActivityList(listNode, items);
        }
        refreshBadge();
      } catch (err) {
        if (isOpen()) {
          listNode.innerHTML = `<p class='error-text'>${escapeHtml(describeRequestError(err, "activity"))}</p>`;
        }
      } finally {
        loading = false;
      }
    };

    toggleButton.addEventListener("click", async () => {
      if (isOpen()) {
        closeDrawer();
        return;
      }
      openDrawer();
      await loadAndRender();
      markSeen();
    });
    closeButton.addEventListener("click", closeDrawer);
    backdrop.addEventListener("click", closeDrawer);
    window.addEventListener("keydown", (event) => {
      if (event.key === "Escape" && isOpen()) {
        closeDrawer();
      }
    });

    loadAndRender().catch(() => {});
  }

  function initCalendarDragAndDrop() {
    const dropTargets = document.querySelectorAll("[data-calendar-drop-day]");
    if (!dropTargets.length) {
      return;
    }
    let draggedTaskId = "";
    document.querySelectorAll(".calendar-task-chip[data-calendar-task-id]").forEach((chip) => {
      chip.addEventListener("dragstart", (event) => {
        draggedTaskId = chip.getAttribute("data-calendar-task-id") || "";
        if (event.dataTransfer) {
          event.dataTransfer.effectAllowed = "move";
          event.dataTransfer.setData("text/plain", draggedTaskId);
        }
        chip.classList.add("dragging");
      });
      chip.addEventListener("dragend", () => {
        chip.classList.remove("dragging");
        dropTargets.forEach((target) => target.classList.remove("calendar-drop-over"));
      });
    });

    dropTargets.forEach((target) => {
      target.addEventListener("dragover", (event) => {
        if (!draggedTaskId) {
          return;
        }
        event.preventDefault();
        target.classList.add("calendar-drop-over");
      });
      target.addEventListener("dragleave", () => {
        target.classList.remove("calendar-drop-over");
      });
      target.addEventListener("drop", async (event) => {
        event.preventDefault();
        target.classList.remove("calendar-drop-over");
        const dueDate = target.getAttribute("data-calendar-drop-day") || "";
        if (!draggedTaskId || !dueDate) {
          return;
        }
        try {
          await postForm("/api/tasks/save", { task_id: draggedTaskId, due_date: dueDate });
          window.location.reload();
        } catch (_err) {
          setModalFeedback("Could not reschedule task.", true);
        } finally {
          draggedTaskId = "";
        }
      });
    });
  }

  function initReportBuilder() {
    const form = document.getElementById("report-builder-form");
    const configNode = document.getElementById("report-builder-config");
    if (!form || !configNode) {
      return;
    }

    let config = {};
    try {
      config = JSON.parse(configNode.textContent || "{}");
    } catch (_err) {
      config = {};
    }

    const metricLibrary = Array.isArray(config.metric_library) ? config.metric_library : [];
    const dataMap = config.data_map && typeof config.data_map === "object" ? config.data_map : {};
    const templateMap = new Map(
      (Array.isArray(config.templates) ? config.templates : []).map((template) => [String(template.key || ""), template]),
    );
    const selectedTemplate = config.selected_template && typeof config.selected_template === "object" ? config.selected_template : {};

    const metricMap = new Map(metricLibrary.map((metric) => [String(metric.key), metric]));
    const widgetEditor = document.getElementById("report-widget-editor");
    const previewGrid = document.getElementById("report-preview-grid");
    const templateSelect = document.getElementById("report-template-select");
    const addWidgetButton = document.getElementById("report-add-widget");
    const configHidden = document.getElementById("report-config-json");
    const reportName = document.getElementById("report-name");
    const reportDescription = document.getElementById("report-description");
    if (!widgetEditor || !previewGrid || !configHidden) {
      return;
    }

    const tonePalette = ["#6ec1ff", "#28d4a8", "#ffb84d", "#ff7b95", "#a88bff", "#85d3f5", "#9dd36a", "#ffc862"];

    function toNumber(value) {
      const parsed = Number.parseFloat(String(value || "0"));
      return Number.isFinite(parsed) ? parsed : 0;
    }

    function shortLabel(value, maxLen) {
      const text = String(value || "");
      if (text.length <= maxLen) {
        return text;
      }
      return `${text.slice(0, Math.max(2, maxLen - 1))}\u2026`;
    }

    function cloneWidgets(raw) {
      if (!Array.isArray(raw)) {
        return [];
      }
      return raw
        .map((item) => {
          if (!item || typeof item !== "object") {
            return null;
          }
          const metric = String(item.metric || "").trim();
          if (!metricMap.has(metric)) {
            return null;
          }
          const metricMeta = metricMap.get(metric) || {};
          const supported = Array.isArray(metricMeta.supported_charts) ? metricMeta.supported_charts.map((v) => String(v)) : ["bar"];
          let chart = String(item.chart || metricMeta.default_chart || supported[0] || "bar").toLowerCase();
          if (!supported.includes(chart)) {
            chart = String(metricMeta.default_chart || supported[0] || "bar");
          }
          const window = ["all", "12m", "6m"].includes(String(item.window || "").toLowerCase())
            ? String(item.window).toLowerCase()
            : "all";
          const title = String(item.title || metricMeta.name || "Chart").slice(0, 120);
          return { title, metric, chart, window };
        })
        .filter(Boolean)
        .slice(0, 18);
    }

    let widgets = cloneWidgets(selectedTemplate.widgets || []);
    if (!widgets.length && metricLibrary.length) {
      const first = metricLibrary[0];
      widgets = [{ title: String(first.name || "Chart"), metric: String(first.key || ""), chart: String(first.default_chart || "bar"), window: "all" }];
    }

    function metricOptions(selectedValue) {
      const chosen = String(selectedValue || "");
      return metricLibrary
        .map((metric) => {
          const key = String(metric.key || "");
          const selected = key === chosen ? " selected" : "";
          return `<option value="${escapeHtml(key)}"${selected}>${escapeHtml(String(metric.name || key))}</option>`;
        })
        .join("");
    }

    function chartOptions(metricKey, selectedChart) {
      const metric = metricMap.get(String(metricKey || ""));
      const supported = Array.isArray(metric && metric.supported_charts) && metric.supported_charts.length ? metric.supported_charts : ["bar"];
      const selected = String(selectedChart || "");
      return supported
        .map((chart) => {
          const key = String(chart);
          const active = key === selected ? " selected" : "";
          return `<option value="${escapeHtml(key)}"${active}>${escapeHtml(key.toUpperCase())}</option>`;
        })
        .join("");
    }

    function applyWindow(labels, values, window) {
      if (window === "12m") {
        return { labels: labels.slice(-12), values: values.slice(-12) };
      }
      if (window === "6m") {
        return { labels: labels.slice(-6), values: values.slice(-6) };
      }
      return { labels, values };
    }

    function barChartSvg(labels, values) {
      const width = 520;
      const height = 220;
      const padLeft = 38;
      const padRight = 16;
      const padTop = 12;
      const padBottom = 54;
      const chartW = width - padLeft - padRight;
      const chartH = height - padTop - padBottom;
      const max = Math.max(1, ...values.map((v) => Math.abs(v)));
      const barSpace = labels.length ? chartW / labels.length : chartW;
      const barW = Math.max(10, Math.min(42, barSpace * 0.62));
      const bars = labels
        .map((label, idx) => {
          const value = values[idx] || 0;
          const hVal = (value / max) * chartH;
          const x = padLeft + (idx * barSpace) + ((barSpace - barW) / 2);
          const y = padTop + (chartH - hVal);
          const color = tonePalette[idx % tonePalette.length];
          return `
            <rect x="${x.toFixed(2)}" y="${y.toFixed(2)}" width="${barW.toFixed(2)}" height="${Math.max(1, hVal).toFixed(2)}" rx="5" fill="${color}"></rect>
            <text x="${(x + barW / 2).toFixed(2)}" y="${(padTop + chartH + 16).toFixed(2)}" text-anchor="middle" class="chart-axis-label">${escapeHtml(shortLabel(label, 10))}</text>
          `;
        })
        .join("");
      return `<svg class="report-chart-svg" viewBox="0 0 ${width} ${height}" role="img" aria-label="Bar chart">
        <line x1="${padLeft}" y1="${padTop + chartH}" x2="${width - padRight}" y2="${padTop + chartH}" class="chart-axis"></line>
        ${bars}
      </svg>`;
    }

    function pieSlicePath(cx, cy, radius, startAngle, endAngle) {
      const startX = cx + (radius * Math.cos(startAngle));
      const startY = cy + (radius * Math.sin(startAngle));
      const endX = cx + (radius * Math.cos(endAngle));
      const endY = cy + (radius * Math.sin(endAngle));
      const largeArc = endAngle - startAngle > Math.PI ? 1 : 0;
      return `M ${cx} ${cy} L ${startX} ${startY} A ${radius} ${radius} 0 ${largeArc} 1 ${endX} ${endY} Z`;
    }

    function pieChartSvg(labels, values) {
      const width = 520;
      const height = 220;
      const cx = 120;
      const cy = 110;
      const radius = 78;
      const total = values.reduce((sum, value) => sum + Math.max(0, value), 0);
      if (total <= 0) {
        return "<p class='muted'>No data in this range.</p>";
      }
      let angle = -Math.PI / 2;
      const slices = labels
        .map((label, idx) => {
          const value = Math.max(0, values[idx] || 0);
          const frac = value / total;
          const next = angle + (Math.PI * 2 * frac);
          const path = pieSlicePath(cx, cy, radius, angle, next);
          const color = tonePalette[idx % tonePalette.length];
          angle = next;
          return `<path d="${path}" fill="${color}" stroke="rgba(14,22,36,0.4)" stroke-width="1"></path>`;
        })
        .join("");
      const legend = labels
        .map((label, idx) => {
          const value = values[idx] || 0;
          const color = tonePalette[idx % tonePalette.length];
          return `<li><span class='legend-swatch' style='background:${color}'></span>${escapeHtml(shortLabel(label, 28))} <strong>${escapeHtml(String(Math.round(value * 100) / 100))}</strong></li>`;
        })
        .join("");
      return `<div class='pie-chart-wrap'>
        <svg class='report-chart-svg pie' viewBox='0 0 ${width} ${height}' role='img' aria-label='Pie chart'>${slices}</svg>
        <ul class='report-legend'>${legend}</ul>
      </div>`;
    }

    function lineChartSvg(labels, values) {
      const width = 520;
      const height = 220;
      const padLeft = 40;
      const padRight = 16;
      const padTop = 12;
      const padBottom = 40;
      const chartW = width - padLeft - padRight;
      const chartH = height - padTop - padBottom;
      const max = Math.max(1, ...values.map((v) => Math.abs(v)));
      const min = Math.min(0, ...values);
      const span = Math.max(1, max - min);
      const step = labels.length > 1 ? chartW / (labels.length - 1) : chartW;
      const points = labels
        .map((label, idx) => {
          const x = padLeft + (idx * step);
          const y = padTop + ((max - (values[idx] || 0)) / span) * chartH;
          return { x, y, label, value: values[idx] || 0 };
        });
      const poly = points.map((point) => `${point.x.toFixed(2)},${point.y.toFixed(2)}`).join(" ");
      const dots = points
        .map((point, idx) => `
          <circle cx="${point.x.toFixed(2)}" cy="${point.y.toFixed(2)}" r="3.5" fill="${tonePalette[idx % tonePalette.length]}"></circle>
          ${labels.length <= 14 ? `<text x="${point.x.toFixed(2)}" y="${(padTop + chartH + 14).toFixed(2)}" text-anchor="middle" class="chart-axis-label">${escapeHtml(shortLabel(point.label, 9))}</text>` : ""}
        `)
        .join("");
      return `<svg class="report-chart-svg" viewBox="0 0 ${width} ${height}" role="img" aria-label="Line chart">
        <line x1="${padLeft}" y1="${padTop + chartH}" x2="${width - padRight}" y2="${padTop + chartH}" class="chart-axis"></line>
        <polyline fill="none" stroke="#75ccff" stroke-width="3" points="${poly}"></polyline>
        ${dots}
      </svg>`;
    }

    function chartMarkup(chartType, labels, values) {
      if (!labels.length || !values.length) {
        return "<p class='muted'>No data in this range.</p>";
      }
      if (chartType === "pie") {
        return pieChartSvg(labels, values);
      }
      if (chartType === "line") {
        return lineChartSvg(labels, values);
      }
      return barChartSvg(labels, values);
    }

    function widgetSummaryRows(labels, values, unit) {
      const pairs = labels.map((label, idx) => ({ label, value: values[idx] || 0 })).slice(0, 6);
      if (!pairs.length) {
        return "<tr><td colspan='2'>No data</td></tr>";
      }
      return pairs
        .map((item) => `<tr><td>${escapeHtml(shortLabel(item.label, 24))}</td><td>${escapeHtml(String(Math.round(item.value * 100) / 100))}${unit === "percent" ? "%" : ""}</td></tr>`)
        .join("");
    }

    function renderPreview() {
      previewGrid.innerHTML = "";
      if (!widgets.length) {
        previewGrid.innerHTML = "<p class='muted'>Add at least one chart widget.</p>";
        return;
      }

      widgets.forEach((widget) => {
        const metric = dataMap[widget.metric] || { labels: [], values: [], note: "No data.", unit: "count" };
        const labels = Array.isArray(metric.labels) ? metric.labels.map((label) => String(label)) : [];
        const values = Array.isArray(metric.values) ? metric.values.map((value) => toNumber(value)) : [];
        const trimmed = applyWindow(labels, values, widget.window);
        const article = document.createElement("article");
        article.className = "report-preview-card";
        article.innerHTML = `
          <header>
            <h4>${escapeHtml(widget.title || metric.name || "Chart")}</h4>
            <p class="muted">${escapeHtml(metric.description || "")}</p>
          </header>
          <div class="report-chart-wrap">${chartMarkup(widget.chart, trimmed.labels, trimmed.values)}</div>
          ${metric.note ? `<p class='muted'>${escapeHtml(metric.note)}</p>` : ""}
          <table class='report-mini-table'><thead><tr><th>Label</th><th>Value</th></tr></thead><tbody>${widgetSummaryRows(trimmed.labels, trimmed.values, String(metric.unit || "count"))}</tbody></table>
        `;
        previewGrid.appendChild(article);
      });
    }

    function renderWidgetEditor() {
      widgetEditor.innerHTML = widgets
        .map((widget, idx) => {
          const metricMeta = metricMap.get(widget.metric) || {};
          return `
            <div class='report-widget-row' data-widget-index='${idx}'>
              <label>Title
                <input data-widget-field='title' value='${escapeHtml(widget.title || "")}' maxlength='120' />
              </label>
              <label>Metric
                <select data-widget-field='metric'>${metricOptions(widget.metric)}</select>
              </label>
              <label>Chart
                <select data-widget-field='chart'>${chartOptions(widget.metric, widget.chart || metricMeta.default_chart || "bar")}</select>
              </label>
              <label>Window
                <select data-widget-field='window'>
                  <option value='all'${widget.window === "all" ? " selected" : ""}>All Time</option>
                  <option value='12m'${widget.window === "12m" ? " selected" : ""}>Last 12 Months</option>
                  <option value='6m'${widget.window === "6m" ? " selected" : ""}>Last 6 Months</option>
                </select>
              </label>
              <button type='button' class='btn ghost report-remove-widget'>Remove</button>
            </div>
          `;
        })
        .join("");
      refreshSemanticTones(widgetEditor);
      renderPreview();
    }

    function addWidget(metricKey) {
      const firstMetric = metricLibrary[0] || {};
      const key = metricMap.has(metricKey) ? metricKey : String(firstMetric.key || "");
      const metricMeta = metricMap.get(key) || firstMetric || {};
      widgets.push({
        title: String(metricMeta.name || "Chart"),
        metric: key,
        chart: String(metricMeta.default_chart || "bar"),
        window: "all",
      });
      renderWidgetEditor();
    }

    widgetEditor.addEventListener("input", (event) => {
      const node = event.target;
      if (!(node instanceof HTMLElement)) {
        return;
      }
      const row = node.closest(".report-widget-row[data-widget-index]");
      if (!row) {
        return;
      }
      const idx = asInt(row.getAttribute("data-widget-index"), -1);
      if (idx < 0 || idx >= widgets.length) {
        return;
      }
      const field = node.getAttribute("data-widget-field") || "";
      if (field === "title" && node instanceof HTMLInputElement) {
        widgets[idx].title = node.value.slice(0, 120);
        renderPreview();
      }
    });

    widgetEditor.addEventListener("change", (event) => {
      const node = event.target;
      if (!(node instanceof HTMLElement)) {
        return;
      }
      const row = node.closest(".report-widget-row[data-widget-index]");
      if (!row) {
        return;
      }
      const idx = asInt(row.getAttribute("data-widget-index"), -1);
      if (idx < 0 || idx >= widgets.length) {
        return;
      }
      const field = node.getAttribute("data-widget-field") || "";
      if (!(node instanceof HTMLSelectElement)) {
        return;
      }
      if (field === "metric") {
        const key = node.value;
        const meta = metricMap.get(key) || {};
        widgets[idx].metric = key;
        const supported = Array.isArray(meta.supported_charts) ? meta.supported_charts.map((v) => String(v)) : ["bar"];
        if (!supported.includes(widgets[idx].chart)) {
          widgets[idx].chart = String(meta.default_chart || supported[0] || "bar");
        }
        if (!widgets[idx].title || widgets[idx].title === "Chart") {
          widgets[idx].title = String(meta.name || "Chart");
        }
        renderWidgetEditor();
        return;
      }
      if (field === "chart") {
        widgets[idx].chart = node.value;
      }
      if (field === "window") {
        widgets[idx].window = node.value;
      }
      renderPreview();
    });

    widgetEditor.addEventListener("click", (event) => {
      const button = event.target.closest(".report-remove-widget");
      if (!button) {
        return;
      }
      const row = button.closest(".report-widget-row[data-widget-index]");
      if (!row) {
        return;
      }
      const idx = asInt(row.getAttribute("data-widget-index"), -1);
      if (idx < 0 || idx >= widgets.length) {
        return;
      }
      widgets.splice(idx, 1);
      renderWidgetEditor();
    });

    if (templateSelect) {
      templateSelect.addEventListener("change", () => {
        const key = templateSelect.value || "";
        if (!key || !templateMap.has(key)) {
          return;
        }
        const template = templateMap.get(key) || {};
        widgets = cloneWidgets(template.widgets || []);
        if (!widgets.length && metricLibrary.length) {
          addWidget(String(metricLibrary[0].key || ""));
          return;
        }
        if (reportName) {
          reportName.value = String(template.name || reportName.value || "");
        }
        if (reportDescription) {
          reportDescription.value = String(template.description || reportDescription.value || "");
        }
        renderWidgetEditor();
      });
    }

    document.querySelectorAll(".report-template-load-btn[data-report-template-key]").forEach((button) => {
      button.addEventListener("click", () => {
        const key = button.getAttribute("data-report-template-key") || "";
        if (!key || !templateMap.has(key)) {
          return;
        }
        if (templateSelect) {
          templateSelect.value = key;
        }
        const template = templateMap.get(key) || {};
        widgets = cloneWidgets(template.widgets || []);
        if (reportName) {
          reportName.value = String(template.name || reportName.value || "");
        }
        if (reportDescription) {
          reportDescription.value = String(template.description || reportDescription.value || "");
        }
        renderWidgetEditor();
        form.scrollIntoView({ behavior: "smooth", block: "start" });
      });
    });

    if (addWidgetButton) {
      addWidgetButton.addEventListener("click", () => {
        const base = metricLibrary.find((metric) => !widgets.some((w) => w.metric === String(metric.key))) || metricLibrary[0];
        addWidget(String(base && base.key ? base.key : ""));
      });
    }

    form.addEventListener("submit", () => {
      const clean = cloneWidgets(widgets);
      configHidden.value = JSON.stringify({ widgets: clean });
    });

    renderWidgetEditor();
  }

  function initViewEditor() {
    const form = document.getElementById("view-editor-form");
    if (!form) {
      return;
    }
    const configNode = document.getElementById("view-editor-config");
    if (!configNode) {
      return;
    }

    let config = {};
    try {
      config = JSON.parse(configNode.textContent || "{}");
    } catch (_err) {
      config = {};
    }

    const entitySelect = document.getElementById("view-entity");
    const templateSelect = document.getElementById("view-template-key");
    const nameInput = document.getElementById("view-name");
    const statusWrap = document.getElementById("view-status-options");
    const columnWrap = document.getElementById("view-column-options");
    const filtersHidden = document.getElementById("view-filters-json");
    const columnsHidden = document.getElementById("view-columns-json");
    const hideCompleted = document.getElementById("view-hide-completed");

    if (!entitySelect || !templateSelect || !nameInput || !statusWrap || !columnWrap || !filtersHidden || !columnsHidden) {
      return;
    }

    const templateMap = new Map((config.templates || []).map((item) => [String(item.key), item]));

    function checkedValues(name) {
      return Array.from(form.querySelectorAll(`input[name='${name}']:checked`)).map((node) => node.value);
    }

    function renderChecks(container, name, options, selectedValues) {
      const selected = new Set((selectedValues || []).map((value) => String(value)));
      container.innerHTML = (options || [])
        .map((item) => {
          const value = typeof item === "string" ? item : item.key;
          const label = typeof item === "string" ? item : item.label;
          const checked = selected.has(String(value)) ? " checked" : "";
          return `<label><input type="checkbox" name="${escapeHtml(name)}" value="${escapeHtml(String(value))}"${checked} /> ${escapeHtml(String(label))}</label>`;
        })
        .join("");
    }

    function renderEntityControls(entity, selectedStatuses, selectedColumns) {
      const statuses = (config.status_options && config.status_options[entity]) || [];
      const columns = (config.column_options && config.column_options[entity]) || [];
      const defaults = (config.default_columns && config.default_columns[entity]) || [];
      renderChecks(statusWrap, "view-status-pick", statuses, selectedStatuses || []);
      renderChecks(columnWrap, "view-column-pick", columns, selectedColumns && selectedColumns.length ? selectedColumns : defaults);
    }

    function resetEditorInputs() {
      [
        "view-scope",
        "view-lane",
        "view-team-id",
        "view-space-id",
        "view-owner-id",
        "view-search",
        "view-due-days",
        "view-followup-days",
        "view-maint-days",
        "view-min-score",
      ].forEach((id) => {
        const node = document.getElementById(id);
        if (node) {
          node.value = "";
        }
      });
      const scope = document.getElementById("view-scope");
      if (scope) {
        scope.value = "team";
      }
      const onlyUnassigned = document.getElementById("view-only-unassigned");
      const certRequired = document.getElementById("view-cert-required");
      if (onlyUnassigned) {
        onlyUnassigned.checked = false;
      }
      if (certRequired) {
        certRequired.checked = false;
      }
      if (hideCompleted) {
        hideCompleted.checked = true;
      }
      form.querySelectorAll("input[name='priority_pick']").forEach((node) => {
        node.checked = false;
      });
    }

    function applyTemplate(template) {
      if (!template) {
        return;
      }
      resetEditorInputs();
      nameInput.value = template.name || "";
      entitySelect.value = template.entity || "tasks";
      const filters = template.filters && typeof template.filters === "object" ? template.filters : {};
      const statusValues = filters.stage_in || filters.status_in || [];
      renderEntityControls(entitySelect.value, statusValues, template.columns || []);

      const setValue = (id, value) => {
        const node = document.getElementById(id);
        if (node && value !== undefined && value !== null) {
          node.value = String(value);
        }
      };
      setValue("view-scope", filters.scope || "team");
      setValue("view-lane", filters.lane || "");
      setValue("view-team-id", filters.team_id || "");
      setValue("view-space-id", filters.space_id || "");
      setValue("view-owner-id", filters.owner_user_id || filters.assignee_user_id || "");
      setValue("view-search", filters.search || "");
      setValue("view-due-days", filters.due_within_days || "");
      setValue("view-followup-days", filters.followup_within_days || "");
      setValue("view-maint-days", filters.maintenance_within_days || "");
      setValue("view-min-score", filters.min_score || "");

      if (filters.only_unassigned) {
        const node = document.getElementById("view-only-unassigned");
        if (node) {
          node.checked = true;
        }
      }
      if (filters.cert_required) {
        const node = document.getElementById("view-cert-required");
        if (node) {
          node.checked = true;
        }
      }
      const hide = Array.isArray(filters.status_exclude) && filters.status_exclude.length > 0;
      if (hideCompleted) {
        hideCompleted.checked = hide;
      }
      const priorities = new Set((filters.priority_in || []).map((value) => String(value)));
      form.querySelectorAll("input[name='priority_pick']").forEach((node) => {
        node.checked = priorities.has(node.value);
      });
    }

    entitySelect.addEventListener("change", () => {
      const statusSelected = checkedValues("view-status-pick");
      const colSelected = checkedValues("view-column-pick");
      renderEntityControls(entitySelect.value, statusSelected, colSelected);
    });

    templateSelect.addEventListener("change", () => {
      const key = templateSelect.value || "";
      if (!key) {
        renderEntityControls(entitySelect.value, checkedValues("view-status-pick"), checkedValues("view-column-pick"));
        return;
      }
      applyTemplate(templateMap.get(key));
    });

    document.querySelectorAll(".template-load-btn[data-template-key]").forEach((button) => {
      button.addEventListener("click", () => {
        const key = button.getAttribute("data-template-key") || "";
        if (!key || !templateMap.has(key)) {
          return;
        }
        templateSelect.value = key;
        applyTemplate(templateMap.get(key));
        form.scrollIntoView({ behavior: "smooth", block: "start" });
      });
    });

    form.addEventListener("submit", () => {
      const entity = entitySelect.value || "tasks";
      const filters = {};
      const statuses = checkedValues("view-status-pick");
      const priorities = checkedValues("priority_pick");
      const selectedColumns = checkedValues("view-column-pick");
      const defaults = (config.default_columns && config.default_columns[entity]) || [];

      const read = (id) => {
        const node = document.getElementById(id);
        return node ? node.value.trim() : "";
      };
      const readInt = (id) => {
        const raw = read(id);
        if (!raw) {
          return null;
        }
        const parsed = Number.parseInt(raw, 10);
        return Number.isFinite(parsed) ? parsed : null;
      };
      const readFloat = (id) => {
        const raw = read(id);
        if (!raw) {
          return null;
        }
        const parsed = Number.parseFloat(raw);
        return Number.isFinite(parsed) ? parsed : null;
      };

      const scope = read("view-scope");
      const lane = read("view-lane");
      const teamId = readInt("view-team-id");
      const spaceId = readInt("view-space-id");
      const ownerId = readInt("view-owner-id");
      const search = read("view-search");
      const dueDays = readInt("view-due-days");
      const followupDays = readInt("view-followup-days");
      const maintenanceDays = readInt("view-maint-days");
      const minScore = readFloat("view-min-score");
      const onlyUnassigned = document.getElementById("view-only-unassigned")?.checked;
      const certRequired = document.getElementById("view-cert-required")?.checked;
      const hide = hideCompleted?.checked;

      if (entity === "tasks") {
        filters.scope = scope || "team";
      }
      if (statuses.length) {
        if (entity === "partnerships") {
          filters.stage_in = statuses;
        } else {
          filters.status_in = statuses;
        }
      }
      if (priorities.length) {
        filters.priority_in = priorities;
      }
      if (lane) {
        filters.lane = lane;
      }
      if (teamId !== null) {
        filters.team_id = teamId;
      }
      if (spaceId !== null) {
        filters.space_id = spaceId;
      }
      if (ownerId !== null) {
        if (entity === "tasks" || entity === "onboarding") {
          filters.assignee_user_id = ownerId;
        } else {
          filters.owner_user_id = ownerId;
        }
      }
      if (search) {
        filters.search = search;
      }
      if (dueDays !== null) {
        filters.due_within_days = dueDays;
      }
      if (followupDays !== null) {
        filters.followup_within_days = followupDays;
      }
      if (maintenanceDays !== null) {
        filters.maintenance_within_days = maintenanceDays;
      }
      if (minScore !== null) {
        filters.min_score = minScore;
      }
      if (onlyUnassigned) {
        filters.only_unassigned = true;
      }
      if (certRequired && entity === "assets") {
        filters.cert_required = true;
      }
      if (hide && !statuses.length) {
        const map = {
          tasks: ["Done", "Cancelled"],
          projects: ["Complete"],
          intake: ["Done", "Rejected"],
          partnerships: ["Closed"],
          onboarding: ["Done"],
        };
        if (map[entity]) {
          filters.status_exclude = map[entity];
        }
      }

      filtersHidden.value = JSON.stringify(filters);
      columnsHidden.value = JSON.stringify(selectedColumns.length ? selectedColumns : defaults);
    });

    renderEntityControls(entitySelect.value || "tasks", [], []);
  }

  initTheme();
  initInterfaceIssueTracking();
  initSpaceContextForms();
  initBoardViewToggles();
  initListCustomization();
  initModalEvents();
  initPurgeConfirmations();
  initGlobalNewTask();
  initActivityDrawer();
  initListInlineEditing();
  initInlineCardChat();
  initCalendarDragAndDrop();
  initReportBuilder();
  initViewEditor();
  initTaskBoard();
  initProjectBoard();
  initIntakeBoard();
  initAssetBoard();
  initConsumableBoard();
  initPartnershipBoard();
  refreshSemanticTones(document);
})();
