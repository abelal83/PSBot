$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\..\..\PSSlackBot\Public\$sut"

Describe "Start-WorkerBot" {

    function New-PSBotRunspacePool
    {
        $sessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault2()
        $runspacePool = [runspacefactory]::CreateRunspacePool(1, [Environment]::ProcessorCount * 3)
        #$runspacePool = [RunspaceFactory]::CreateRunspacePool($sessionState)
        [void] $runspacePool.Open()

        return $runspacePool
    }

    $SlackMessage = @{}
    $SlackToken = '12345'
    $RunspacePool = New-PSBotRunspacePool        
    $AsyncObject = New-Object System.Collections.Specialized.OrderedDictionary
    $SlackUsers = @{}    

    It "Starts a new worker bot" {
        { Start-WorkerBot -SlackMessage $SlackMessage -SlackToken $SlackToken `
            -RunspacePool $RunspacePool -AsyncObject $AsyncObject `
             -SlackUsers $SlackUsers } | Should -Not -Throw
    }

    $AsyncObject[0].Powershell.Dispose()    
}
