function New-PSBotRunspacePool
{
    $sessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault2()
    $runspacePool = [runspacefactory]::CreateRunspacePool(1, [Environment]::ProcessorCount * 3)
    #$runspacePool = [RunspaceFactory]::CreateRunspacePool($sessionState)
    [void] $runspacePool.Open()

    return $runspacePool
}