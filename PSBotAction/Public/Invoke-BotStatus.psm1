function Invoke-BotStatus
{
    $status = Get-Process -Id $PID
    return @{
        Id = [Guid]::NewGuid().Guid;
        Response = "approval required for invoke-botstatusaction";
        KeyWords = @('status', 'your');
        Action = 'Invoke-BotStatusAction';
        Auth = @();
        AuthOverride = @()
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