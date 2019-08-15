#requires -Version 2 -Modules posh-git

function Write-Theme {
   
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )
    $lastColor = $sl.Colors.PromptBackgroundColor


    #check the last command state and indicate if failed
    # 当时失败命令提交时后
    If ($lastCommandFailed) {
        $prompt += Write-Prompt -Object ([char]::ConvertFromUtf32(0x250C))-ForegroundColor $sl.Colors.ErrorPromptForegroundColor
        # $prompt += Write-Prompt -Object "$kt($sl.PromptSymbols.PromptTriangleIndicator)"  -ForegroundColor $sl.Colors.ErrorPromptForegroundColor
        $prompt += Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
        # 输出:X zfu~\..\..\..\..\2.0.311\Themes  (ddc4727...) ≢ +5 ~2 -1 ! 
        # $prompt += Write-Prompt -Object "$($sl.PromptSymbols.FailedCommandSymbol) " -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
        $prompt += Write-Prompt -Object " $($sl.PromptSymbols.FailedCommandSymbol) " -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    
    
    }
    else {
        $prompt += Write-Prompt -Object ([char]::ConvertFromUtf32(0x250C))-ForegroundColor $sl.Colors.GreenPromptForegroundColor
        # $prompt += Write-Prompt -Object "$($sl.PromptSymbols.PromptTriangleIndicator)"  -ForegroundColor $sl.Colors.GreenPromptForegroundColor
        $prompt += Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
        $prompt += Write-Prompt -Object " $($sl.PromptSymbols.SuccessCommandSymbol) " -ForegroundColor $sl.Colors.CommandSuccessIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    #check for elevated prompt
    If (Test-Administrator) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol) " -ForegroundColor $sl.Colors.AdminIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }


    $user = [System.Environment]::UserName
    $computer = [System.Environment]::MachineName
    # $path = Get-FullPath -dir $pwd
    if (Test-NotDefaultUser($user)) {

        #-> zfu
        $prompt += Write-Prompt -Object "$user@$computer" -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    if (Test-VirtualEnv) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.VirtualEnvSymbol) $(Get-VirtualEnvName) " -ForegroundColor $sl.Colors.VirtualEnvForegroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.VirtualEnvBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }
    else {

        # SegmentForwardSymbol:  
        $prompt += Write-Prompt -Object " $ " -ForegroundColor $sl.Colors.GreenPromptForegroundColor
    }


    # Writes the drive portion
    $prompt += Write-Prompt -Object (Get-ShortPath -dir $pwd) -ForegroundColor $sl.Colors.PromptForegroundColor 

    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        $lastColor = $themeInfo.BackgroundColor
        $prompt += Write-Prompt -Object " @ " -ForegroundColor $sl.Colors.PromptIndicatorForegroundColor3
        $prompt += Write-Prompt -Object "$($themeInfo.VcInfo)" -ForegroundColor $lastColor
        
    }

    if ($lastCommandFailed) {
        # Writes the postfix to the prompt
        $prompt += Write-Prompt -Object " ):-$($sl.PromptSymbols.PromptTriangleIndicator)"  -ForegroundColor $sl.Colors.ErrorPromptForegroundColor
    }
    else {
        # Writes the postfix to the prompt
        $prompt += Write-Prompt -Object " (:-$($sl.PromptSymbols.PromptTriangleIndicator)"  -ForegroundColor $sl.Colors.GreenPromptForegroundColor
    }

    # $clock = [char]::ConvertFromUtf32(0x235F)
    $timeStamp = Get-Date -UFormat %R:%S
    $timestamp = "$timeStamp"
    if ($status) {
        $timeStamp = "$(Get-TimeSinceLastCommit)"
        $timestamp = "$timeStamp $(Get-Date -UFormat %R)"
    }

    $prompt += Set-CursorForRightBlockWrite -textLength ($timestamp.Length + 1)
    if ($lastCommandFailed) {
        $prompt += Write-Prompt $timestamp -ForegroundColor $sl.Colors.ErrorPromptForegroundColor
    }
    else {
        $prompt += Write-Prompt $timestamp -ForegroundColor $sl.Colors.GreenPromptForegroundColor
    }
    
  
    $prompt += Set-Newline

    if ($with) {
        $prompt += Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    }

    # 当失败的时候提交的时候,设置相应的颜色
    if ($lastCommandFailed) {
        $prompt += Write-Prompt -Object ([char]::ConvertFromUtf32(0x2514)) -ForegroundColor $sl.Colors.ErrorPromptForegroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.PromptTriangleIndicator)"  -ForegroundColor $sl.Colors.ErrorPromptForegroundColor
        $prompt += ' '
        $prompt
    }
    else {
        $prompt += Write-Prompt -Object ([char]::ConvertFromUtf32(0x2514)) -ForegroundColor $sl.Colors.GreenPromptForegroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.PromptTriangleIndicator)"  -ForegroundColor $sl.Colors.GreenPromptForegroundColor
        $prompt += ' '
        $prompt
    }

}

function Get-TimeSinceLastCommit {
    return (git log --pretty=format:'%cr' -1)
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.StartSymbol = ''
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x276F)
$sl.PromptSymbols.SegmentForwardSymbol = [char]::ConvertFromUtf32(0xE0B0)
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.GitForegroundColor = [ConsoleColor]::Black
$sl.Colors.WithForegroundColor = [ConsoleColor]::DarkRed
$sl.Colors.WithBackgroundColor = [ConsoleColor]::Magenta
$sl.Colors.VirtualEnvBackgroundColor = [System.ConsoleColor]::Red
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::White
$sl.Colors.PromptBackgroundColor = [System.ConsoleColor]::DarkGray
$sl.Colors.GreenPromptForegroundColor = [System.ConsoleColor]::DarkGreen
$sl.Colors.ErrorPromptForegroundColor = [System.ConsoleColor]::Red
$sl.PromptSymbols.PromptTriangleIndicator = [char]::ConvertFromUtf32(0x25B6)

$sl.Colors.PromptIndicatorForegroundColor1 = [ConsoleColor]::DarkBlue
$sl.Colors.PromptIndicatorForegroundColor2 = [ConsoleColor]::DarkYellow
$sl.Colors.PromptIndicatorForegroundColor3 = [ConsoleColor]::DarkMagenta

# $sl.PromptSymbols.FailedCommandSymbol = [char]::ConvertFromUtf32(0x2718)
$sl.PromptSymbols.SuccessCommandSymbol = [char]::ConvertFromUtf32(0x2714)

$sl.PromptSymbols.FailedCommandSymbol = [char]::ConvertFromUtf32(0x2718)

# 命令成功执行的 :✔ 
$sl.Colors.CommandSuccessIconForegroundColor = [System.ConsoleColor]::DarkGreen
# 命令失败执行: ✘
$sl.Colors.CommandFailedIconForegroundColor = [System.ConsoleColor]::DarkRed

$sl.Colors.SessionInfoForegroundColor = [System.ConsoleColor]::DarkMagenta

