(function () {
  function escapeHtml(value) {
    return String(value ?? "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  async function fetchJson(url) {
    const response = await fetch(url, { credentials: "same-origin" });
    if (!response.ok) {
      throw new Error(`Failed to fetch ${url}`);
    }
    return response.json();
  }

  function formatDate(value) {
    const date = new Date(String(value || ""));
    if (Number.isNaN(date.getTime())) {
      return String(value || "");
    }
    return date.toLocaleDateString(undefined, { year: "numeric", month: "short", day: "numeric" });
  }

  function updateGeneratedAt(value) {
    document.querySelectorAll("[data-generated-at]").forEach((node) => {
      node.textContent = formatDate(value);
    });
  }

  async function renderReleaseFeed() {
    const targets = Array.from(document.querySelectorAll("[data-release-feed]"));
    if (!targets.length) {
      return;
    }
    try {
      const payload = await fetchJson("/website/data/updates.json");
      const entries = Array.isArray(payload.entries) ? payload.entries : [];
      const listHtml = entries.length
        ? entries
          .slice(0, 14)
          .map((entry) => `<li><strong>${escapeHtml(entry.date || "")}</strong> · ${escapeHtml(entry.summary || "")}</li>`)
          .join("")
        : "<li>No release entries yet.</li>";
      targets.forEach((node) => {
        node.innerHTML = listHtml;
      });
      updateGeneratedAt(payload.generated_at || "");
    } catch (_err) {
      targets.forEach((node) => {
        node.innerHTML = "<li>Could not load update feed.</li>";
      });
    }
  }

  function renderFileMapRows(rows) {
    const body = document.getElementById("file-map-table-body");
    if (!body) {
      return;
    }
    if (!rows.length) {
      body.innerHTML = "<tr><td colspan='4'>No files match this filter.</td></tr>";
      return;
    }
    body.innerHTML = rows
      .map((row) => {
        const kb = Math.max(0.1, (Number(row.size_bytes || 0) / 1024)).toFixed(1);
        return `
          <tr>
            <td><code>${escapeHtml(row.path || "")}</code></td>
            <td>${escapeHtml(row.category || "")}</td>
            <td>${escapeHtml(row.description || "")}</td>
            <td>${escapeHtml(kb)} KB</td>
          </tr>
        `;
      })
      .join("");
  }

  async function renderFileMap() {
    const table = document.getElementById("file-map-table");
    if (!table) {
      return;
    }
    const summaryNode = document.getElementById("file-map-summary");
    const searchNode = document.getElementById("file-map-search");
    let allRows = [];

    try {
      const payload = await fetchJson("/website/data/file_map.json");
      allRows = Array.isArray(payload.files) ? payload.files : [];
      if (summaryNode) {
        const fileCount = Number(payload.stats?.file_count || allRows.length);
        const dirCount = Number(payload.stats?.directory_count || 0);
        summaryNode.textContent = `${fileCount} files across ${dirCount} directories (generated ${formatDate(payload.generated_at || "")}).`;
      }
      updateGeneratedAt(payload.generated_at || "");
      renderFileMapRows(allRows);
    } catch (_err) {
      if (summaryNode) {
        summaryNode.textContent = "Could not load generated file map.";
      }
      renderFileMapRows([]);
      return;
    }

    if (searchNode) {
      searchNode.addEventListener("input", () => {
        const query = String(searchNode.value || "").trim().toLowerCase();
        if (!query) {
          renderFileMapRows(allRows);
          return;
        }
        const filtered = allRows.filter((row) =>
          String(row.path || "").toLowerCase().includes(query)
          || String(row.category || "").toLowerCase().includes(query)
          || String(row.description || "").toLowerCase().includes(query),
        );
        renderFileMapRows(filtered);
      });
    }
  }

  renderReleaseFeed();
  renderFileMap();
})();
