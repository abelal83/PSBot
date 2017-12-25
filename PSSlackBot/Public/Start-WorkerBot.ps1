function Start-WorkerBot
{
    param
    (
        $SlackMessage,
        $SlackToken,
        $runspacePool,
        $AsyncObject,
        $SlackUsers
    )

    $powerShell = [powershell]::Create()
    $powerShell.RunspacePool = $runspacePool    

    $backgroundBotScript = "$PSScriptRoot\..\..\PSBotAction\Start-PSBotBackground.ps1"

    [void] $powerShell.AddCommand(
        
        $backgroundBotScript
    )

    [void] $PowerShell.AddArgument($SlackToken).AddArgument($SlackMessage).AddArgument($SlackUsers)

    $startTime = Get-Date
    $AsyncObject.Add($powerShell.InstanceId.Guid, @{State = $powerShell.BeginInvoke(); Powershell = $powerShell; StartTime = $startTime})
}