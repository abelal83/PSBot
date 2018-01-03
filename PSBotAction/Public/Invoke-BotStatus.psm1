function Invoke-BotStatus
{
    $status = Get-Process -Id $PID
    return @{
        Id = [Guid]::NewGuid().Guid;
        Response = $status.WorkingSet64;
        KeyWords = @('status', 'your');
        Action = 'Invoke-GetStatusAction';
        Auth = @('abu.belal');
        AuthOverride = @('abu.belalx')
    }
}

function Invoke-BotStatusAction
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=1)]
        $Base64Json
    )

    $decodedJson = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Base64Json))
    
    $jsonInput = $decodedJson | ConvertFrom-Json
    return "OK, you asked {0}" -f $jsonInput.Message.text
}