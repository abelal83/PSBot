function Connect-Slack
{
    [CmdletBinding()]
    param
    (
        [Object]
        $SlackRealTimeSession
    )

    $SlackClientWebSocket = New-Object System.Net.WebSockets.ClientWebSocket
    $CancellationToken = New-Object System.Threading.CancellationToken
    $SlackConnectionTask = $SlackClientWebSocket.ConnectAsync($SlackRealTimeSession.url, $CancellationToken)

    while (!$SlackConnectionTask.IsCompleted) 
    {
        Start-Sleep -Milliseconds 100    
    }

    if ($SlackClientWebSocket.State -eq 'Open')
    {
        return $SlackClientWebSocket
    }
}