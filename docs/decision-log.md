# Decision log

- 2026-11-14 Pin image tags to patch level in `docker-compose.yaml` (penpotapp/* 2.19.1, postgres 15.20, valkey 8.1.11) instead of floating minor tags — local-only stack, nobody watches patch updates, so reproducibility beats auto-updates.
- 2026-11-14 Stay on postgres 15 and valkey 8.1 — upstream 2.19.1 compose still uses them; a postgres major bump needs dump/restore for no gain.
- 2026-11-14 Back up postgres (pg_dump) and the assets volume to `backups/` before upgrading to Penpot 2.19 — its boot-time `file_data` migration deletes old `file_change` rows irreversibly.
- 2026-11-14 Admin console: trial-run 2.19.1 without it first; if frontend/backend fail to start, add `penpot-admin-console` back rather than stay on 2.18.7 — 2.19 enables it by default and this was never tested.
- 2026-11-14 Admin console left out after trial: 2.19.1 started cleanly without it (migrations 0155-0158 applied, 4 files intact, HTTP 200); backend only logs a non-fatal "admin console is not configured" warning/exception from nitrate on websocket team lookups. Revisit if that starts breaking UI features.
