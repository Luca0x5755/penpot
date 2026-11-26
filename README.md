# Penpot（自架）

在本機用 Docker 跑的 Penpot，網址：http://localhost:9001

## 啟動

```sh
docker compose -p penpot -f docker-compose.yaml up -d
```

## 關閉

```sh
docker compose -p penpot -f docker-compose.yaml down
```

## MCP 連線

MCP 的網址和 token 放在 `.env`（不會進 git）。
- `PENPOT_MCP_TOKEN`：Penpot 的 access token
- `PENPOT_MCP_URL`：完整的 MCP 連線網址

## chrome driver（讓 MCP 不因 Chrome 不在前景而斷線）

Penpot 的 MCP 外掛每 10 秒送一次 heartbeat，MCP 伺服器超過 30 秒沒收到就拒絕執行任務。
一般 Chrome 不在前景時，會把 heartbeat 拖慢到每 60 秒一次。
所以 Penpot 要在專用的 chrome driver 裡開。它啟動時帶了防節流的旗標，背景時照樣每 10 秒送一次。

```powershell
./scripts/penpot-chrome.ps1 start    # 啟動並打開 Penpot；已在執行就不重開
./scripts/penpot-chrome.ps1 status   # 檢查是否正在執行、port 與旗標
./scripts/penpot-chrome.ps1 stop     # 關掉（會先確認；無人值守時加 -Yes）
```

- 第一次啟動要在這個視窗裡登入 Penpot。profile 放在 `%LOCALAPPDATA%\penpot-chrome`，之後會記住登入。
- 打開檔案後，到主選單的「MCP server」按 Connect。
- 除錯 port 是 `127.0.0.1:9222`，只有本機能連，但本機任何程式都能操控這個 Chrome。
- Claude Code 透過 `.mcp.json` 裡的 `penpot-chrome`（chrome-devtools-mcp）連上它。用之前要先跑 `start`。
- 測試：`Invoke-Pester tests/scripts/test-penpot-chrome.ps1`（會實際開關一個暫存的 Chrome；設 `PENPOT_CHROME_SKIP_E2E=1` 可略過）。
