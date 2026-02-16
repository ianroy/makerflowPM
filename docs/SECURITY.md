# Security Practices

## Built-In Controls

- Password hashing: PBKDF2-SHA256 with per-user salts.
- Session model: server-side session table with expiry and revocation.
- Cookie controls: HttpOnly, SameSite=Lax, optional Secure mode.
- CSRF token required for all state-changing requests.
- SQL injection mitigation via parameterized queries.
- Login rate limiting by source IP window.
- Security headers + CSP.
- Audit logging (`audit_log` table).

## Required Production Controls

- Always run behind HTTPS.
- Set `MAKERSPACE_COOKIE_SECURE=1` in production.
- Set strong `MAKERSPACE_SECRET_KEY` (64+ random chars).
- Rotate admin bootstrap password immediately.
- Use institution-approved password policy (length + entropy + rotation).

## Recommended Institutional Controls

- Front the app with SSO (SAML/OIDC) and MFA at the university IdP layer.
- Restrict admin access by network and/or VPN.
- Ship logs to centralized SIEM.
- Run quarterly access review for staff/student accounts.

## Data Privacy Notes

- Calendar/event imports can contain sensitive information.
- Keep role-based access tight by organization.
- Prefer `workspace_admin` for department-level admin operations; reserve `owner` for top-level governance.
- Non-superuser admin accounts are constrained to one workspace for accountability and blast-radius control.
- Export datasets only for approved business purposes.
- Define retention windows for event data and onboarding records.

## Incident Response Basics

1. Disable compromised user in `users.is_active`.
2. Invalidate sessions (`DELETE FROM sessions WHERE user_id = ?`).
3. Rotate `MAKERSPACE_SECRET_KEY` if signing key exposure is suspected.
4. Restore DB from known-good backup if tampering is detected.
