# 決策紀錄

- 2026-11-26 — Penpot 改在專用的 chrome driver 裡執行（帶防節流旗標，除錯 port 為 127.0.0.1:9222，profile 在 `%LOCALAPPDATA%\penpot-chrome`）。chrome-devtools-mcp 透過 repo 的 `.mcp.json` 用 `--browserUrl` 連上它，不再由它自己啟動 Chrome。原因：一般 Chrome 在背景時會把 MCP 外掛的 heartbeat 節流到每 60 秒一次，超過伺服器 30 秒的門檻；chrome-devtools-mcp 自己開的 Chrome 雖然不會斷，卻會跟著 Claude 對話一起關掉。
