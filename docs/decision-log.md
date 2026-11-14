# Decision log

- 2026-11-14 Pin image tags to patch level in `docker-compose.yaml` (penpotapp/* 2.19.1, postgres 15.20, valkey 8.1.11) instead of floating minor tags — local-only stack, nobody watches patch updates, so reproducibility beats auto-updates.
- 2026-11-14 Stay on postgres 15 and valkey 8.1 — upstream 2.19.1 compose still uses them; a postgres major bump needs dump/restore for no gain.
- 2026-11-14 Back up postgres (pg_dump) and the assets volume to `backups/` before upgrading to Penpot 2.19 — its boot-time `file_data` migration deletes old `file_change` rows irreversibly.
- 2026-11-14 Admin console: trial-run 2.19.1 without it first; if frontend/backend fail to start, add `penpot-admin-console` back rather than stay on 2.18.7 — 2.19 enables it by default and this was never tested.
- 2026-11-14 Admin console added back: the trial only looked at startup logs; the UI then refused to load ("Penpot can't start yet") because the profile call needs it (nitrate-not-configured). Superseded the earlier "leave it out" line.
