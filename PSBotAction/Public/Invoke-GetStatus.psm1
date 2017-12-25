function Invoke-GetStatus
{
    $status = Get-Process -Id $PID
    return @{
        Id = '4203ebf4-b82d-4538-8a5c-23ad5806df02';
        Response = $status.WorkingSet64;
        KeyWords = @('status', 'your');
        Action = '';
        Auth = @();
        AuthOverride = @()
    }
}
