function Receive-SlackEvent
{
    [CmdletBinding()]
    param
    (
        [System.Net.WebSockets.WebSocket]
        $SlackClientWebSocket
    )

    $CancellationToken = New-Object System.Threading.CancellationToken

    $Size = 1024
    $Array = [byte[]] @(,0) * $Size
    $Recieve = New-Object System.ArraySegment[byte] -ArgumentList @(,$Array)

    [string] $SlackEvent = ""
    
    Do 
    {
        $SlackConnectionTask = $SlackClientWebSocket.ReceiveAsync($Recieve, $CancellationToken)
        While (!$SlackConnectionTask.IsCompleted) 
        { 
            Start-Sleep -Milliseconds 100 
        }

        $Recieve.Array[0..($SlackConnectionTask.Result.Count - 1)] | ForEach-Object { $SlackEvent = $SlackEvent + [char]$_ }
    } 
    Until ($SlackConnectionTask.Result.Count -lt $Size)

    return $SlackEvent
}