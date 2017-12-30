$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$sut = $sut -replace '.ps1', '.psm1'

Describe "Invoke-BotMessageObject" {

    $message = 
    @{
        type        = 'message'
        channel     = 'C857QB0D8'
        user        = 'U85BY6FV3'
        text        = '<@U8644ER0E> status'
        ts          = '1514057685.000039'
        source_team = 'T859226E8'
        team        = 'T859226E8'
    }

    $slackUsers = New-Object System.Collections.ArrayList 
    $SlackUsers.Add(@{
    ID                = "U85BY6FV3";
    Name              = "abu.belal";
    RealName          = "Abu Belal";
    FirstName         = "";
    Last_Name         = "";
    Email             = "abu.belal@outlook.com";
    Phone             = "";
    Skype             = "";
    IsBot             = "False";
    IsAdmin           = "True";
    IsOwner           = "True";
    IsPrimaryOwner    = "True";
    IsRestricted      = "False";
    IsUltraRestricted = "False";
    Status            = "";
    TimeZoneLabel     = "Pacific Standard Time";
    TimeZone          = "America/Los_Angeles";
    Presence          = "";
    Deleted           = "False";
    Raw               = @{id="U85BY6FV3"; team_id="T859226E8"; name="abu.belal"; deleted="False"; color="9f69e7"; real_name="Abu Belal"; tz="America/Los_Angeles"; tz_label="Pacific Standard
                        Time"; tz_offset="-28800"; profile= ""; is_admin="True"; is_owner="True"; is_primary_owner="True"; is_restricted="False"; is_ultra_restricted="False"; is_bot="False";
                        updated=1511548251; is_app_user="False"}
    })

    $availableAction = @{
        Id = [Guid]::NewGuid().Guid;
        Response = "Input object contains following";
        KeyWords = @('');
        Action = 'Invoke-BotMessageObjectAction';
        Auth = @('abu.belal');
        AuthOverride = @('abu.belal')
    }

    $availableAction.Add('Users', $slackUsers)
    $availableAction.Add('Message', $message)

    $jsonString = $availableAction | ConvertTo-Json

    $bytes = [System.Text.Encoding]::Unicode.GetBytes($jsonString)
    # base64 encoding as invoke-expression sends string only, incase some weird char in there 
    $base64Json = [Convert]::ToBase64String($bytes)
    
    It "Should not throw exception" {
        { Import-Module "$here\..\..\PSBotAction\Public\$sut" } | Should -Not -Throw
    }

    It "Should not throw exception" {
        { Invoke-BotMessageObjectAction -Base64Json $base64Json } | Should -Not -Throw
    }
}