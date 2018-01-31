function Invoke-BmeBalance
{
    return @{
        Id = [Guid]::NewGuid().Guid;
        Response = "Approval required to run this action, sending request to approvers.";
        KeyWords = @('bme', 'balance');
        Action = 'Invoke-BmeBalanceAction';
        Auth = @('abelal');
        AuthOverride = @('seanog')
    }
}

function Invoke-BmeBalanceAction
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=1)]
        $Base64Json
    )

    $decodedJson = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Base64Json))    
    $jsonInput = $decodedJson | ConvertFrom-Json

    $configFileName = (Split-Path $PSCommandPath -Leaf) -replace "psm1", "json"
    $config = Get-Content "$PSScriptRoot\$configFileName" -Raw | ConvertFrom-Json
    Import-Module "$PSScriptRoot\..\..\Tools\Send-PSBotMail\Send-PSBotMail.psm1"
    Import-Module "$PSScriptRoot\..\..\Tools\New-RandomPassword\New-RandomPassword.psm1"

    $accountNumberMatch = [regex]::Match($jsonInput.Message.text, '\d{8}(\r\s|\t|\n|$)')

    if ($accountNumberMatch.Success -eq $false)
    {
        Write-Output "You need to supply an 8 digit account number"
        return "You need to supply an 8 digit account number"
    }

    $bmeQuery = $config.BMEBalanceEndPoint -replace "{accountNumber}", $accountNumberMatch.Value
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Source-Of-Request", "OCB")
    $headers.Add("Accept", "application/json")

    try 
   {
        $result = Invoke-WebRequest -Uri $bmeQuery -Headers $headers -UseBasicParsing        
    }
    catch 
    {
        #return "Error return from BME $($_.ToString())"
    }
    
    $result = "account not found"
    $emailTo = $jsonInput.Users.Where( { $_.ID -eq $jsonInput.Message.user } ).Email
    $password = New-RandomPassword -Length 12 -Lowercase -Uppercase -Numbers -Symbols

    Send-PSBotMail -To $emailTo -From "omni@psbotdev.com" `
    -AttachmentContent $result -AttachmentContentFileName "bmebalance.txt" `
    -AttachmentFileName "content.7z" -ZipPassword "$password" -SmtpHost $config.SMTPHost `
    -SmtpPort 25

    return "Sending you results in an email attachment, password to open is $password"

}