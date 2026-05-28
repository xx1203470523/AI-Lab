# PowerShell UTF-8 prelude
# 项目共享：所有 .ps1 在头部 dot-source 这个文件，规避 PS 5.1 在 Windows
# 上的 ANSI/codepage 默认导致的中文乱码。
#
# 使用方式（在 .ps1 顶部，紧跟 BOM 之后）：
#   . "$PSScriptRoot\..\lib\ps-utf8.ps1"
#
# 加上后：
#   * Console.OutputEncoding / InputEncoding / $OutputEncoding 全为 UTF-8
#   * 提供 Write-Stdout：用 UTF-8 字节流直接写 stdout，绕过控制台 codepage
#     转换，hook 返回 JSON / 含中文的提醒文本时必须用它。
#   * 提供 Read-StdinJson：直接从 stdin 读字节流再按 UTF-8 解码，绕过 PS 5.1
#     启动时已经固化的 ANSI 解码器。hook 解析 Claude 注入的 JSON 必须用它，
#     不要再用 `$Input | Out-String` 或 `[Console]::In.ReadToEnd()`，否则
#     prompt/path/content 中的中文会以 GBK 解 UTF-8，破坏 JSON 字符串。

# 注意：不要在这里设 $ErrorActionPreference = 'Stop'。
# PS 5.1 把 git/dotnet/npm 等 native 命令写到 stderr 的非错误信息（如
# "LF will be replaced by CRLF"）也包成 NativeCommandError，配合 Stop
# 会让 hook 直接抛异常退出，而调用脚本本意只是想读 stdout。
# hook 脚本依靠显式 exit code 控制流，无需 Stop。

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

function Write-Stdout {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [AllowEmptyString()]
        [string]$Text
    )
    process {
        if ($null -eq $Text) { return }
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        $stdout = [Console]::OpenStandardOutput()
        $stdout.Write($bytes, 0, $bytes.Length)
        $stdout.Flush()
    }
}

function Read-StdinJson {
    [CmdletBinding()]
    param(
        # 当 stdin 为空时，是否返回 $null 而不是抛异常。
        [switch]$AllowEmpty
    )

    $stdin = [Console]::OpenStandardInput()
    $ms = New-Object System.IO.MemoryStream
    try {
        $buffer = New-Object byte[] 8192
        while ($true) {
            $read = $stdin.Read($buffer, 0, $buffer.Length)
            if ($read -le 0) { break }
            $ms.Write($buffer, 0, $read)
        }
        $bytes = $ms.ToArray()
    } finally {
        $ms.Dispose()
    }

    if ($bytes.Length -eq 0) {
        if ($AllowEmpty) { return $null }
        throw 'Read-StdinJson: stdin is empty.'
    }

    # 跳过潜在的 UTF-8 BOM
    $start = 0
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $start = 3
    }

    $text = [System.Text.Encoding]::UTF8.GetString($bytes, $start, $bytes.Length - $start)
    if ([string]::IsNullOrWhiteSpace($text)) {
        if ($AllowEmpty) { return $null }
        throw 'Read-StdinJson: stdin contains no JSON.'
    }
    return $text | ConvertFrom-Json
}
