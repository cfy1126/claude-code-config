param(
    [string]$Title = 'Claude Code',
    [string]$Message = 'Needs your attention'
)

Add-Type -AssemblyName System.Windows.Forms

$notify = New-Object System.Windows.Forms.NotifyIcon
$notify.Icon = [System.Drawing.SystemIcons]::Information
$notify.BalloonTipTitle = $Title
$notify.BalloonTipText = $Message
$notify.Visible = $true
$notify.ShowBalloonTip(5000)

Start-Sleep -Milliseconds 2000
$notify.Dispose()