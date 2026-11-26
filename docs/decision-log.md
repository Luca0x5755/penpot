# 決策紀錄

- 2026-11-14 — image tag 鎖到 patch 版（penpotapp/* 2.19.1、postgres 15.20、valkey 8.1.11），不用浮動的 minor tag。原因：這是只跑在本機的 stack，沒人盯 patch 更新，可重現比自動更新重要。
- 2026-11-14 — postgres 維持 15、valkey 維持 8.1。原因：上游 2.19.1 的 compose 仍用這兩版；postgres 換大版本要 dump/restore，沒有收益。
- 2026-11-14 — 升 Penpot 2.19 前，先把 postgres（pg_dump）和 assets volume 備份到 `backups/`。原因：2.19 開機時的 `file_data` 遷移會不可逆地刪掉舊的 `file_change` 資料列。
- 2026-11-14 — 加回 `penpot-admin-console`。原因：2.19 預設啟用它；沒有它時 UI 停在「Penpot can't start yet」，因為 profile 呼叫需要它（nitrate-not-configured）。
- 2026-11-26 — 把上面 2.19.1 的版本鎖定補回 main。原因：PR #2 關閉沒合併，但 stack 實際上一直跑 2.19.1；main 的 compose 還寫 2.18，在 main 上 `docker compose up -d` 會把已做過不可逆遷移的資料降回 2.18 跑，並移除 admin-console。
- 2026-11-26 — Penpot 改在專用的 chrome driver 裡執行（帶防節流旗標，除錯 port 為 127.0.0.1:9222，profile 在 `%LOCALAPPDATA%\penpot-chrome`）。chrome-devtools-mcp 透過 repo 的 `.mcp.json` 用 `--browserUrl` 連上它，不再由它自己啟動 Chrome。原因：一般 Chrome 在背景時會把 MCP 外掛的 heartbeat 節流到每 60 秒一次，超過伺服器 30 秒的門檻；chrome-devtools-mcp 自己開的 Chrome 雖然不會斷，卻會跟著 Claude 對話一起關掉。
