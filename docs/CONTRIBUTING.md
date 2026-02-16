# Contributing Guide

Repository: [https://github.com/ianroy/makerflowPM](https://github.com/ianroy/makerflowPM)
Primary site: [https://makerflow.org](https://makerflow.org)

## Setup

```bash
git clone https://github.com/ianroy/makerflowPM.git
cd makerflowPM
python3 app/server.py
```

Optional virtual environment:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python3 app/server.py
```

## Standards

- Keep dependencies minimal.
- Preserve organization scoping on all data access.
- Keep CSRF checks on state-changing routes.
- Keep CSV import/export compatibility for core entities.
- Add concise comments for security and non-obvious business logic.

## Required Checks Before Merge

```bash
python3 scripts/smoke_test.py
python3 scripts/usability_test.py
python3 scripts/accessibility_audit.py
python3 scripts/comprehensive_feature_security_test.py
```

## Documentation Updates

If behavior changes, update relevant docs in `README.md` and `docs/`.

## License

By contributing, you agree that contributions are published under `CC BY-SA 4.0`.
See `LICENSE` and `docs/LICENSE.md`.
