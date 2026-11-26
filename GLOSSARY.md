# 詞彙表

**chrome driver**:
專門給 Penpot 用的 Chrome。由 repo 裡的腳本啟動，使用獨立的 profile，開著本機除錯 port，並帶防背景節流的旗標。Penpot 和它的 MCP 外掛就在這個視窗裡執行。它不跟任何 Claude 對話綁在一起：Claude Code 關掉後，它照樣開著、照樣保持連線。chrome-devtools-mcp 只負責連上它，不負責開關它。
_Avoid_: Selenium ChromeDriver（另一套自動化協定，這個 repo 沒有用到）；chrome-devtools-mcp 自己啟動的 Chrome（那個跟著 MCP 伺服器開關）
