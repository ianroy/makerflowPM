# Testing Guide

Repository: [https://github.com/ianroy/makerflowPM](https://github.com/ianroy/makerflowPM)

## Fast Checks

```bash
python3 scripts/smoke_test.py
python3 scripts/usability_test.py
python3 scripts/accessibility_audit.py
```

## Release Gate

```bash
python3 scripts/comprehensive_feature_security_test.py
```

This validates role access, CSRF protection, route wiring, and multi-user collaboration behavior.

## Optional Simulation

```bash
python3 scripts/load_sample_data.py
python3 scripts/collaboration_simulation.py
```

Cleanup:

```bash
python3 scripts/test_data_cleanup.py
```

## Full Pre-Release Pipeline

Run the full launch checklist in one command:

```bash
./scripts/pre_release_audit.sh
```

This runs:

1. Documentation audit
2. Smoke + usability + accessibility checks
3. Comprehensive security test
4. 10-user collaboration simulation
5. Test data cleanup
6. Website/wiki metadata refresh
7. Release-state DB reset (default workspace/admin only)
