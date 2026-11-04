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
