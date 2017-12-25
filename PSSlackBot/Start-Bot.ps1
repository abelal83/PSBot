Get-Module PSSlackConnect, PSSlack | Remove-Module -Force
Import-Module $PSScriptRoot\..\PSSlack\0.0.27\PSSlack.psd1
Import-Module $PSScriptRoot\..\PSSlackConnect\PSSlackConnect.psd1

$_SlackToken = 'xoxb-278140501014-KPF4RdEnZQvOlgifDQIWSThZ'
$_MessagesToIgnore = @('approved')

$_SlackUsers = Get-SlackUser -Token $_SlackToken
$_SlackChannel = Get-SlackChannel -Token $_SlackToken
$_AsyncObject = New-Object System.Collections.Specialized.OrderedDictionary

$scripts = Get-ChildItem "$PSScriptRoot\Public" -Filter '*.ps1'
$scripts | ForEach-Object { Import-Module -Name $_.FullName }

function Start-Main 
{
    [CmdletBinding()]
    param
    (
        [String]
        $Token,
        $AsyncObject,
        $SlackUsers
    )

    try 
    {
        $slackRealTimeSession = New-SlackSession -Token $Token
        $slackClientWebSocket = Connect-Slack -SlackRealTimeSession $slackRealTimeSession
        $runspacePool = New-PSBotRunspacePool
    
        while ($slackClientWebSocket.State -eq 'Open') 
        {
            $slackEvent = Receive-slackEvent -slackClientWebSocket $slackClientWebSocket

            Write-Verbose "$slackEvent"
            $slackEvent = ($slackEvent | ConvertFrom-Json)
    
            if ($slackEvent.type -eq $slackEventTypes.message -and $slackEvent.user -ne $slackRealTimeSession.self.id)
            {
                if ($slackEvent.text -Match "<@$($slackRealTimeSession.self.id)>" `
                            -or $slackEvent.channel.StartsWith('D'))
                {
                    if (!$_MessagesToIgnore.Where({$slackEvent.text.StartsWith($_)}))
                    {
                        Write-Verbose "Message received $slackEvent"

                        if ($runspacePool.GetAvailableRunspaces() -eq 0)
                        {
                            Send-SlackMessage -Token $Token -Channel $slackEvent.channel `
                                -Text 'Busy at the moment, may take a while to process this request' -AsUser
                        }

                        Start-WorkerBot -SlackMessage $slackEvent -SlackToken $Token `
                            -RunspacePool $runspacePool -AsyncObject $AsyncObject -SlackUsers $SlackUsers                     
                    }
                }
            }
            else 
            {
                Write-Verbose "$slackEvent"
            }
    
            Start-Sleep -Milliseconds 10

            Remove-CompletedWorkerBot -AsyncObject $AsyncObject
        }
    }
    catch 
    {
        Write-Error $_.PSBase.Exception
    }
    finally
    {
        # close websocket and cleanup
        $runspacePool.Dispose()
        $slackClientWebSocket.Dispose()
    }
    # if disconnected, sleep to allow resources to close then restart
    Write-Verbose 'slackClientWebSocket state is closed. Reconnecting after 5 seconds'
    Start-Sleep -Seconds 5
    Start-Main -Token $Token -AsyncObject $AsyncObject -SlackUsers $SlackUsers -Verbose -Debug
}

Start-Main -Token $_SlackToken -AsyncObject $_AsyncObject -SlackUsers $_SlackUsers -Verbose -Debug