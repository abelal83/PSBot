function Remove-CompletedWorkerBot
{
    param
    (
        $AsyncObject
    )

    if ($AsyncObject.Count -gt 0)
    {
        for ($i = 0; $i -lt $AsyncObject.Count; $i++)
        {
            $endTime = $AsyncObject[$i].StartTime.AddMinutes(15)
            $now = Get-Date

            #if ($AsyncObject[$i].State.IsCompleted -or $now.CompareTo($endTime))
            if ($AsyncObject[$i].State.IsCompleted -or ($now.CompareTo($endTime) -eq $true))
            {
                $AsyncObject[$i].Powershell.Dispose()
                #$threadResponse = $AsyncObject[$i].Powershell.EndInvoke($AsyncObject[$i].State) # if exception is thrown this kills session
                #Write-Verbose $threadResponse.ToString()
                $AsyncObject.Remove($AsyncObject[$i].Powershell.InstanceId.Guid)
            }
        }
    }
}