#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )
   
    $lastColor = $sl.Colors.PromptBackgroundColor
    if ($lastCommandFailed) {
        $prompt += Write-Prompt -Object ([char]::ConvertFromUtf32(0x250C)) -ForegroundColor $sl.Colors.RedPromptForegroundColor
        $prompt = Write-Prompt -Object "$($sl.PromptSymbols.StartSymbol)" -ForegroundColor $sl.Colors.RedPromptForegroundColor-BackgroundColor $sl.Colors.PromptUserBackgroundColor
        $prompt += Write-Prompt -Object " $($sl.PromptSymbols.FailedCommandSymbol) " -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor

        # $prompt += Write-Prompt -Object "$($sl.PromptSymbols.PromptTriangleIndicator)"  -ForegroundColor $sl.Colors.RedPromptForegroundColor
        # $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.PromptIndicatorForegroundColor3 -BackgroundColor $sl.Colors.PromptUserBackgroundColor
    }
    else {
        $prompt += Write-Prompt -Object ([char]::ConvertFromUtf32(0x250C)) -ForegroundColor $sl.Colors.GreenPromptBackgroundColor
        $prompt = Write-Prompt -Object "$($sl.PromptSymbols.StartSymbol)" -ForegroundColor $sl.Colors.GreenPromptBackgroundColor-BackgroundColor $sl.Colors.PromptUserBackgroundColor
        $prompt += Write-Prompt -Object " $($sl.PromptSymbols.SuccessCommandSymbol) " -ForegroundColor $sl.Colors.CommandSuccessIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor

        # $prompt += Write-Prompt -Object "$($sl.PromptSymbols.PromptTriangleIndicator)"  -ForegroundColor $sl.Colors.GreenPromptForegroundColor
        # $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.PromptIndicatorForegroundColor3 -BackgroundColor $sl.Colors.PromptUserBackgroundColor
    }
    

    #check for elevated prompt
    If (Test-Administrator) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol)" -ForegroundColor $sl.Colors.AdminIconForegroundColor -BackgroundColor $sl.Colors.PromptUserBackgroundColor
    }


    $user = [System.Environment]::UserName
    $computer = [System.Environment]::MachineName
    $path = Get-ShortPath -dir $pwd
    if (Test-NotDefaultUser($user)) {
        $prompt += Write-Prompt -Object "$user" -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptUserBackgroundColor
        $prompt += Write-Prompt -Object " @ " -ForegroundColor $sl.Colors.CyanGitForegroundColor -BackgroundColor $sl.Colors.PromptUserBackgroundColor

        $prompt += Write-Prompt -Object "$computer" -ForegroundColor $sl.Colors.PromptIndicatorForegroundColor2 -BackgroundColor $sl.Colors.PromptUserBackgroundColor
    }

    if (Test-VirtualEnv) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol)" -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.VirtualEnvSymbol) $(Get-VirtualEnvName) " -ForegroundColor $sl.Colors.VirtualEnvForegroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol)" -ForegroundColor $sl.Colors.VirtualEnvBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }
    else {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol)" -ForegroundColor $sl.Colors.PromptUserBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }

    # Writes the drive portion
    $prompt += Write-Prompt -Object " in" -ForegroundColor $sl.Colors.PromptForegroundColor3 
    $prompt += Write-Prompt -Object " $path " -ForegroundColor $sl.Colors.PromptForegroundColor2

    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        $lastColor = $themeInfo.BackgroundColor
        $prompt += Write-Prompt -Object $($sl.PromptSymbols.SegmentForwardSymbol) -ForegroundColor $sl.Colors.PromptBackgroundColor 
        $prompt += Write-Prompt -Object "|"  -ForegroundColor $sl.Colors.GitForegroundColor2
        $prompt += Write-Prompt -Object " $($themeInfo.VcInfo) "  -ForegroundColor $sl.Colors.CyanGitForegroundColor
    }

    # Writes the postfix to the prompt
    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $lastColor

    #check the last command state and indicate if failed
    # If ($lastCommandFailed) {
    #     $prompt += Write-Prompt -Object "$($sl.PromptSymbols.FailedCommandSymbol)" -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    # }
    # else {
    #     $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SuccessCommandSymbol)" -ForegroundColor $sl.Colors.CommandSuccessIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor        
    # }

    $timeStamp = Get-Date -UFormat %T
    $timestamp = "$timeStamp"

    $prompt += Set-CursorForRightBlockWrite -textLength ($timestamp.Length + $sl.PromptSymbols.TimeSymbol.Length + $sl.PromptSymbols.SegmentBackwardSymbol.Length + $sl.PromptSymbols.SegmentForwardSymbol.Length + 1)


    if ($lastCommandFailed) {
        # $prompt += Write-Prompt $sl.PromptSymbols.TimeSymbol -ForegroundColor $sl.Colors.RedPromptForegroundColor
        $prompt += Write-Prompt " $($timeStamp)" -ForegroundColor  $sl.Colors.RedPromptForegroundColor
        $prompt += Write-Prompt $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $sl.Colors.RedPromptForegroundColor 
    }
    else {
        # $prompt += Write-Prompt $sl.PromptSymbols.TimeSymbol -ForegroundColor $sl.Colors.GreenPromptForegroundColor
        $prompt += Write-Prompt " $($timeStamp)" -ForegroundColor $sl.Colors.GreenPromptForegroundColor 
        $prompt += Write-Prompt $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $sl.Colors.GreenPromptForegroundColor 
    }


    $prompt += Set-Newline

    if ($with) {
        $prompt += Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    }
    if ($lastCommandFailed) {
        $prompt += Write-Prompt -Object ([char]::ConvertFromUtf32(0x2514)) -ForegroundColor $sl.Colors.RedPromptForegroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.PromptTriangleIndicator)"  -ForegroundColor $sl.Colors.RedPromptForegroundColor
        $prompt += ' '
        $prompt
    }
    else {
        $prompt += Write-Prompt -Object ([char]::ConvertFromUtf32(0x2514)) -ForegroundColor $sl.Colors.GreenPromptBackgroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.PromptTriangleIndicator)"  -ForegroundColor $sl.Colors.GreenPromptForegroundColor
        $prompt += ' '
        $prompt
    }
    
}


$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.StartSymbol = [char]::ConvertFromUtf32(0xe627) 
# $sl.PromptSymbols.StartSymbol = [char]::ConvertFromUtf32(0xfcd1) 

$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x276F)
$sl.PromptSymbols.SegmentForwardSymbol = "" # [char]::ConvertFromUtf32(0xE0B0) #(0xE0B4)
$sl.PromptSymbols.SegmentBackwardSymbol = [char]::ConvertFromUtf32(0xE0B2)
$sl.PromptSymbols.TimeSymbol = ' ' + [char]::ConvertFromUtf32(0x235F)
$sl.PromptSymbols.FailedCommandSymbol = [char]::ConvertFromUtf32(0x2718)
$sl.PromptSymbols.SuccessCommandSymbol = [char]::ConvertFromUtf32(0x2714)
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptForegroundColor2 = [ConsoleColor]::DarkGreen
$sl.Colors.PromptForegroundColor3 = [ConsoleColor]::Magenta
$sl.Colors.PromptBackgroundColor = [ConsoleColor]::DarkBlue
$sl.Colors.GreenPromptBackgroundColor = [ConsoleColor]::Green
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.GitForegroundColor = [ConsoleColor]::Green
$sl.Colors.CyanGitForegroundColor = [ConsoleColor]::Cyan
$sl.Colors.GitForegroundColor2 = [ConsoleColor]::Red
$sl.Colors.WithForegroundColor = [ConsoleColor]::DarkRed
$sl.Colors.WithBackgroundColor = [ConsoleColor]::DarkMagenta
$sl.Colors.VirtualEnvBackgroundColor = [System.ConsoleColor]::DarkRed
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::White
$sl.Colors.CommandSuccessIconForegroundColor = [System.ConsoleColor]::DarkGreen
$sl.Colors.CommandFailedIconForegroundColor = [System.ConsoleColor]::DarkRed
$sl.Colors.PromptIndicatorForegroundColor1 = [ConsoleColor]::DarkBlue
$sl.Colors.PromptIndicatorForegroundColor2 = [ConsoleColor]::DarkYellow
$sl.Colors.PromptIndicatorForegroundColor3 = [ConsoleColor]::DarkMagenta
$sl.Colors.PromptUserBackgroundColor = [ConsoleColor]::Black
$sl.PromptSymbols.PromptTriangleIndicator = [char]::ConvertFromUtf32(0x25B6)
$sl.Colors.GreenPromptForegroundColor = [ConsoleColor]::Green
$sl.Colors.RedPromptForegroundColor = [ConsoleColor]::Red
