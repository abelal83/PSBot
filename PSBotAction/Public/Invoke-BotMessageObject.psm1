function Invoke-BotMessageObject
{
    return @{
        Id = [Guid]::NewGuid().Guid;
        Response = "Input object contains following";
        KeyWords = @('');
        Action = 'Invoke-BotMessageObjectAction';
        Auth = @('abu.belal');
        AuthOverride = @('abu.belal')
    }
}

function Invoke-BotMessageObjectAction
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=1)]
        $Base64Json
    )

    $decodedJson = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Base64Json))
    
    $jsonInput = $decodedJson | ConvertFrom-Json
    return $jsonInput
}