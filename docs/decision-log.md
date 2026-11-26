# 決策紀錄

- 2026-11-14 — image tag 鎖到 patch 版（penpotapp/* 2.19.1、postgres 15.20、valkey 8.1.11），不用浮動的 minor tag。原因：這是只跑在本機的 stack，沒人盯 patch 更新，可重現比自動更新重要。
- 2026-11-14 — postgres 維持 15、valkey 維持 8.1。原因：上游 2.19.1 的 compose 仍用這兩版；postgres 換大版本要 dump/restore，沒有收益。
- 2026-11-14 — 升 Penpot 2.19 前，先把 postgres（pg_dump）和 assets volume 備份到 `backups/`。原因：2.19 開機時的 `file_data` 遷移會不可逆地刪掉舊的 `file_change` 資料列。
- 2026-11-14 — 加回 `penpot-admin-console`。原因：2.19 預設啟用它；沒有它時 UI 停在「Penpot can't start yet」，因為 profile 呼叫需要它（nitrate-not-configured）。
- 2026-11-26 — 把上面 2.19.1 的版本鎖定補回 main。原因：PR #2 關閉沒合併，但 stack 實際上一直跑 2.19.1；main 的 compose 還寫 2.18，在 main 上 `docker compose up -d` 會把已做過不可逆遷移的資料降回 2.18 跑，並移除 admin-console。
- 2026-11-26 — Penpot 現在就從 2.19.1 升到 2.19.5，不等 2.20。原因：2.19.2 修了閒置佔 60 條 DB 連線和檔案打不開；compose 只改 image tag；2.20 發布時間不確定。2.19.5 的檔案資料遷移（0035、0036）退不回去，所以升級前先備份 2.19.1 的 postgres 和 assets，並用 `pg_restore --list`、`tar -tzf` 驗證備份讀得出來。
- 2026-11-26 — valkey 跟著升到 8.1.12，postgres 維持 15.20 但重新 pull 上游重建的同一個 tag。原因：兩者都在原本的線內，成本只是 pull 和重啟；8.1.12 修的 CVE 不影響這台（`maxmemory-clients 0`），但有崩潰類修正。
- 2026-11-26 — valkey 不設 `requirepass`。原因：stack 只在 localhost 跑，docker 網路裡只有 Penpot 自己的服務，和 secret key 刻意用預設值是同一個取向。
- 2026-11-26 — 不排程追新版；2.20 發布或有新的安全公告時，再重新評估。原因：單人本機 stack，每月自動檢查的雜訊大於收益。
- 2026-11-26 — Penpot 改在專用的 chrome driver 裡執行（帶防節流旗標，除錯 port 為 127.0.0.1:9222，profile 在 `%LOCALAPPDATA%\penpot-chrome`）。chrome-devtools-mcp 透過 repo 的 `.mcp.json` 用 `--browserUrl` 連上它，不再由它自己啟動 Chrome。原因：一般 Chrome 在背景時會把 MCP 外掛的 heartbeat 節流到每 60 秒一次，超過伺服器 30 秒的門檻；chrome-devtools-mcp 自己開的 Chrome 雖然不會斷，卻會跟著 Claude 對話一起關掉。
