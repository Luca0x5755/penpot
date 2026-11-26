# scripts/penpot-chrome.ps1 的測試（Pester 3.4，Windows 內建版本）。
# 執行：Invoke-Pester tests/scripts/test-penpot-chrome.ps1
# 透過測試接縫 PENPOT_CHROME_LIB=1 載入函式，不跑主流程。
# 只支援 Pester 3／4：Pester 5 會把 It 延後到 Describe 的 finally 之後才跑，
# 那時端到端測試的環境變數已還原，子行程會改用真的 profile 與 port 9222。
#Requires -Modules @{ ModuleName = 'Pester'; MaximumVersion = '4.99' }

$ScriptPath = Join-Path $PSScriptRoot '..\..\scripts\penpot-chrome.ps1'
$env:PENPOT_CHROME_LIB = '1'
. $ScriptPath
$env:PENPOT_CHROME_LIB = ''

Describe '啟動參數' {
    $chromeArgs = Get-PenpotChromeArgumentList -Port 9222 -ProfileDir 'C:\Users\x\AppData\Local\penpot-chrome' -Url 'http://localhost:9001'

    It '帶三個防節流旗標' {
        $chromeArgs -contains '--disable-background-timer-throttling' | Should Be $true
        $chromeArgs -contains '--disable-features=IntensiveWakeUpThrottling' | Should Be $true
        $chromeArgs -contains '--disable-backgrounding-occluded-windows' | Should Be $true
    }

    It '用指定的除錯 port 與 profile' {
        $chromeArgs -contains '--remote-debugging-port=9222' | Should Be $true
        $chromeArgs -contains '--user-data-dir=C:\Users\x\AppData\Local\penpot-chrome' | Should Be $true
    }

    It '不帶實驗證實無效的 --disable-renderer-backgrounding' {
        $chromeArgs -contains '--disable-renderer-backgrounding' | Should Be $false
    }

    It '交給 Start-Process 的命令列會把含空白的值整段包起來' {
        $spaced = Get-PenpotChromeArgumentList -Port 9222 -ProfileDir 'C:\Users\John Doe\penpot-chrome' -Url 'http://localhost:9001'
        $line = ConvertTo-PenpotChromeCommandLine -ArgumentList $spaced
        $line.Contains('"--user-data-dir=C:\Users\John Doe\penpot-chrome"') | Should Be $true
        $line.Contains(' --no-first-run ') | Should Be $true
    }
}

Describe '命令契約' {
    It '子命令表與 ValidateSet 一致' {
        $ast = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path $ScriptPath), [ref]$null, [ref]$null)
        $attr = $ast.ParamBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'Command' } |
            ForEach-Object { $_.Attributes } | Where-Object { $_.TypeName.Name -eq 'ValidateSet' }
        $set = @($attr.PositionalArguments | ForEach-Object { $_.Value })
        ($set -join ',') | Should Be (@($SubCommands.Keys) -join ',')
    }

    It '只有 stop 需要確認' {
        $marked = @($SubCommands.Keys | Where-Object { $SubCommands[$_]['Confirm'] })
        ($marked -join ',') | Should Be 'stop'
    }

    It '-Help 結束碼 0' {
        $null = powershell.exe -NoProfile -File $ScriptPath -Help
        $LASTEXITCODE | Should Be 0
    }

    It '沒有子命令也沒有終端機時結束碼 2' {
        $null = cmd /c "powershell.exe -NoProfile -File `"$ScriptPath`" < NUL"
        $LASTEXITCODE | Should Be 2
    }
}

Describe '找出 chrome driver 的行程' {
    $profileDir = 'C:\Users\x\AppData\Local\penpot-chrome'
    function ConvertTo-FakeProc([int]$ProcessId, [string]$CommandLine) {
        [pscustomobject]@{ ProcessId = $ProcessId; CommandLine = $CommandLine }
    }
    $procs = @(
        (ConvertTo-FakeProc 100 '"C:\Program Files\Google\Chrome\Application\chrome.exe"'),
        (ConvertTo-FakeProc 200 '"chrome.exe" --remote-debugging-port=9222 --user-data-dir=C:\Users\x\AppData\Local\penpot-chrome --no-first-run http://localhost:9001'),
        (ConvertTo-FakeProc 201 '"chrome.exe" --type=renderer --user-data-dir=C:\Users\x\AppData\Local\penpot-chrome --lang=zh-TW'),
        (ConvertTo-FakeProc 300 '"chrome.exe" --user-data-dir=C:\Users\x\AppData\Local\penpot-chrome-old'),
        (ConvertTo-FakeProc 400 $null)
    )

    It '只回傳用這個 profile 的瀏覽器主行程' {
        $found = @(Get-PenpotChromeProcess -ProfileDir $profileDir -Processes $procs)
        ($found.ProcessId -join ',') | Should Be '200'
    }

    It '名稱只多一段的 profile 不算' {
        $found = @(Get-PenpotChromeProcess -ProfileDir $profileDir -Processes @($procs[3]))
        $found.Count | Should Be 0
    }

    It '路徑大小寫不同、加了引號也認得' {
        $quoted = ConvertTo-FakeProc 500 '"chrome.exe" "--user-data-dir=c:\users\x\appdata\local\PENPOT-CHROME" --no-first-run'
        $found = @(Get-PenpotChromeProcess -ProfileDir $profileDir -Processes @($quoted))
        ($found.ProcessId -join ',') | Should Be '500'
    }
}

# 真實端到端：用暫存 profile 與另一個 port 啟動真的 Chrome，會跳出視窗約十幾秒。
# 設 PENPOT_CHROME_SKIP_E2E=1 可略過。
Describe '真實啟動與關閉（端到端）' {
    if ($env:PENPOT_CHROME_SKIP_E2E -eq '1') { return }
    $tmpProfile = Join-Path ([IO.Path]::GetTempPath()) ('penpot-chrome-test-' + [guid]::NewGuid().ToString('N'))
    $saved = @{ Port = $env:PENPOT_CHROME_PORT; Profile = $env:PENPOT_CHROME_PROFILE; Url = $env:PENPOT_URL }
    $env:PENPOT_CHROME_PORT = '9444'
    $env:PENPOT_CHROME_PROFILE = $tmpProfile
    $env:PENPOT_URL = 'about:blank'
    function Invoke-Script([string[]]$ScriptArgs) {
        $null = cmd /c "powershell.exe -NoProfile -File `"$ScriptPath`" $($ScriptArgs -join ' ') < NUL"
        $LASTEXITCODE
    }
    function Get-Count { @(Get-PenpotChromeProcess -ProfileDir $tmpProfile).Count }

    try {
        It '沒有在執行時 status 結束碼 1' { Invoke-Script @('status') | Should Be 1 }
        It 'start 啟動一個 chrome driver' {
            Invoke-Script @('start') | Should Be 0
            Get-Count | Should Be 1
        }
        It '執行中 status 結束碼 0' { Invoke-Script @('status') | Should Be 0 }
        It '再跑 start 不會開第二個' {
            Invoke-Script @('start') | Should Be 0
            Get-Count | Should Be 1
        }
        It '沒有終端機又沒加 -Yes 時 stop 結束碼 2，且不關' {
            Invoke-Script @('stop') | Should Be 2
            Get-Count | Should Be 1
        }
        It 'stop -Yes 關掉它' {
            Invoke-Script @('stop', '-Yes') | Should Be 0
            Get-Count | Should Be 0
        }
    } finally {
        Get-PenpotChromeProcess -ProfileDir $tmpProfile | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
        $env:PENPOT_CHROME_PORT = $saved.Port; $env:PENPOT_CHROME_PROFILE = $saved.Profile; $env:PENPOT_URL = $saved.Url
        Start-Sleep -Milliseconds 500
        Remove-Item -LiteralPath $tmpProfile -Recurse -Force -ErrorAction SilentlyContinue
    }
}
