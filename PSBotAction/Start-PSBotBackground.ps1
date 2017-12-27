param
(
    $Token,
    $Message,
    $SlackUsers
    #$WorkberBotArgs
)
Get-Module PSSlackConnect, PSSlack | Remove-Module -Force
Import-Module "$PSScriptRoot\..\PSSlack\0.0.27\PSSlack.psd1"
Import-Module "$PSScriptRoot\..\PSSlackConnect\PSSlackConnect.psd1"

$scripts = Get-ChildItem "$PSScriptRoot\Private" -Filter '*.ps1'
$scripts | ForEach-Object { Import-Module -Name $_.FullName }
function Get-PSBotActionModule
{
    $modules = Get-ChildItem "$PSScriptRoot\Public" -Filter '*.psm1'
    $modules | ForEach-Object { Import-Module -Name $_.FullName }

    $iCount = 0
    $botActions = @()
    foreach ($module in $modules) 
    {        
        $botActions += Invoke-Expression $module.BaseName
        $botActions[$iCount].Add('ModuleName', $module.BaseName)
        $botActions[$iCount].Add("Command", $module.BaseName)
        $iCount++
    }
    
    return $botActions
}

function Get-PSBotAvailableResponse
{
    param
    (
        $Command,
        $BotActions
    )

    $words = $Command -split ' '
    $availableResponses = @()
    
    foreach ($word in $words) 
    {  
        $availableCommand = $BotActions.Where({$_.Command.ToLower() -eq $word.ToLower() })
        if ($availableCommand)
        {
            # found an immediate command, return it
            return @(, $availableCommand)
        }

        $availableResponse = $BotActions.Where( { $_.KeyWords.ToLower().Contains($word.ToLower()) } )
        
        if ($availableResponses.Count -eq 0)
        {
            $availableResponses += $availableResponse
            continue
        }

        $availableResponse.ForEach({ 
            $thisResponseId =  $_.id
            
            $responseExists = $availableResponses.Where( { $_.id -eq $thisResponseId } )

            if ($responseExists.Count -le 0)
            {
                $availableResponses += $availableResponse
            }
        })
    }

    return @(,$availableResponses)
}

function Invoke-PSBotAction
{
    param
    (
        $Command
    )

    $jsonString = $Command | ConvertTo-Json

    $bytes = [System.Text.Encoding]::Unicode.GetBytes($jsonString)
    # base64 encoding as invoke-expression sends string only, incase some weird char in there 
    $base64Json = [Convert]::ToBase64String($bytes)

    try 
    { 
        $response = Invoke-Expression -Command ($Command.Action + " -Base64Json $base64Json")
    }
    catch 
    {
        $response = "An error occured running {0}, the error returned is '{1}'" -f  $Command.Action, $_.ToString()
    }
    return $response
}

function Get-PSBotPermission
{
    param
    (
        $Command
    )

    $params = @{
        Token = $Token
        Method = 'im.list'
    }

    $rawIms = Send-SlackApi @params

    $slackRealTimeSession = New-SlackSession -Token $Token
    $slackClientWebSocket = Connect-Slack -SlackRealTimeSession $slackRealTimeSession

    $ims = @()

    $isAuthedUser = $false
    $Command.AuthOverride.ForEach({

        $authOverrideUserFromModule = $_;
        $selfAuth = $Command.Users.Where( {$_.Name.ToLower() -eq $authOverrideUserFromModule.ToLower()}) | Select-Object -First 1

        if ($null -ne $selfAuth)
        { 
            $isAuthedUser = $true 
            return
        }
    })

    if ($isAuthedUser)
    {
        return @{approved = $true}
    }

    $Command.Auth.ForEach({ 
        $authUserFromModule = $_;
        $authUserId = $Command.Users.Where( {$_.Name.ToLower() -eq $authUserFromModule.ToLower()}).ID

        if (!$authUserId)
         {continue }

         $ims += $rawIms.ims.Where( { $_.User -eq $authUserId} ).ID
    })

    $requestingUser = $Command.Users.Where( { $_.Id.ToLower() -eq $Command.Message.User.ToLower() }).RealName

    $randomApproveNumber = Get-Random -Minimum 1000 -Maximum 9999
    $approvalText = "Approval required. {0} requested '{1}' {2} Please reply with 'approve {3}' or 'deny {3}'" `
        -f $requestingUser, $Command.Message.Text, [Environment]::NewLine, $randomApproveNumber

    foreach($im in $ims)
    {
        Send-SlackMessage -Token $Token -Channel $im -Text $approvalText -AsUser -Verbose
    }

    try 
    {
        while ($slackClientWebSocket.State -eq 'Open') 
        {
            $slackEvent = Receive-slackEvent -slackClientWebSocket $slackClientWebSocket
            
            $slackEvent = ($slackEvent | ConvertFrom-Json)

            if ($slackEvent.type -eq $slackEventTypes.message -and $slackEvent.user -ne $slackRealTimeSession.self.id)
            {
                if ($slackEvent.channel.StartsWith('D'))
                {
                    if (!$ims.Where({ $_ -eq $slackEvent.Channel }))
                    {
                        continue
                    }

                    if ($slackEvent.text -eq "approve $randomApproveNumber" )
                    {
                        return @{approved = $true}
                    }

                    if ($slackEvent.text -eq "deny $randomApproveNumber" )
                    {
                        return @{approved = $false}
                    }
                }
            }
        }
    }
    catch
    {
        Write-Verbose $_
        return @{error = $true}
    }
    finally
    {
        $slackClientWebSocket.Dispose()
    }
}

function Start-PSBotBackground
{
    param
    (
        $Command,
        $Users
    )

    $availableResponses = $null  
    $botActions = Get-PSBotActionModule
    $availableResponses = Get-PSBotAvailableResponse -Command $Command.Text -BotActions $botActions    
    $botCommands = ""

    try 
    {
        if ($availableResponses.Count -eq 0)
        {
            $botActions.ForEach({            
                $botCommand = $_
                $botCommands += [string]::Format("{0}", $botCommand.Command + [System.Environment]::NewLine)
            })
            Send-SlackMessage -Token $Token -Channel $Command.Channel -Text "Nothing available for that" -AsUser -Verbose
            Send-SlackMessage -Token $Token -Channel $Command.Channel -Text "Here are available commands" -AsUser -Verbose
            Send-SlackMessage -Token $Token -Channel $Command.Channel -Text $botCommands -AsUser -Verbose
            return
        }
    
        if ($availableResponses.Count -gt 1)
        {
            $tooManyActions = "A number of actions were found, please re-type what you need including" ` + 
            "a command (i.e. invoke-bme account 12345)" + [System.Environment]::NewLine
    
            $availableResponses.ForEach({            
                $possibleAction = $_    
                $tooManyActions += [string]::Format("{0}", $possibleAction.Command + [System.Environment]::NewLine)
            })    
            Send-SlackMessage -Token $Token -Channel $Command.Channel -Text $tooManyActions -AsUser
            return        
        }
    
        $actionResponse = $availableResponses[0]
        $actionResponse.Add('Users', $Users)
        $actionResponse.Add('Message', $Command)
        if (![String]::IsNullOrEmpty($actionResponse.Response))
        {
            Send-SlackMessage -Token $Token -Channel $Command.Channel -Text $actionResponse.Response -AsUser -Verbose
        }
        if ([string]::IsNullOrEmpty($actionResponse.Action)) 
        { return }
        if ([string]::IsNullOrEmpty($actionResponse.Auth))
        { 
            $response = Invoke-PSBotAction -Command $actionResponse
            Send-SlackMessage -Token $Token -Channel $Command.Channel -Text $response -AsUser -Verbose 
        }
        else
        {
            $request = Get-PSBotPermission -Command $actionResponse
            if ($request.approved)
            {
                $response = Invoke-PSBotAction -Command $actionResponse
                Send-SlackMessage -Token $Token -Channel $Command.Channel -Text $response -AsUser -Verbose
            }
            else 
            {
                Send-SlackMessage -Token $Token -Channel $Command.Channel -Text "Request denied" -AsUser -Verbose
            }
        }
    }
    catch 
    {
        Send-SlackMessage -Token $Token -Channel $Command.Channel -Text ($_.PSBase.Exception) -AsUser -Verbose
    }   
}

$Tokenx = ''
$Messagex = 
@{
    type        = 'message'
    channel     = 'C857QB0D8'
    user        = 'U85BY6FV3'
    text        = '<@U8644ER0E> status'
    ts          = '1514057685.000039'
    source_team = 'T859226E8'
    team        = 'T859226E8'
}

$SlackUsersx = New-Object System.Collections.ArrayList 
$SlackUsersx.Add(@{
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

Start-PSBotBackground -Command $Message -Users $SlackUsers

#Start-PSBotBackground -Command $WorkberBotArgs