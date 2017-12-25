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
    $availableResponse = $null
    
    foreach ($word in $words) 
    {  
        $availableCommand = $BotActions.Where({$_.Command.ToLower() -eq $word.ToLower() })
        if ($availableCommand)
        {
            # found an immediate command, return it
            return @(, $availableCommand)
        }

        $availableResponse += $BotActions.Where( { $_.KeyWords.ToLower().Contains($word.ToLower()) } )
    }

    return @(,$availableResponse)
}

function Invoke-PSBotAction
{
    param
    (
        $Command
    )

}

function Start-PSBotBackground
{
    param
    (
        $Command
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
        Send-SlackMessage -Token $Token -Channel $Command.Channel -Text $actionResponse.Response -AsUser -Verbose
        if ([string]::IsNullOrEmpty($actionResponse.Action)) 
        { return }
        if (![string]::IsNullOrEmpty($actionResponse.Auth))
        { Invoke-PSBotAction -Command $actionResponse }        
    }
    catch 
    {
        Send-SlackMessage Send-SlackMessage -Token $Token -Channel $Command.Channel `
            -Text ($_.PSBase.Exception + $StackTrace) -AsUser -Verbose
    }

    # get auth    
}

#$Token = 'xoxb-278140501014-KPF4RdEnZQvOlgifDQIWSThZ'
#$Message = 
#@{
#    type        = 'message'
#    channel     = 'C857QB0D8'
#    user        = 'U85BY6FV3'
#    text        = '<@U8644ER0E> joke'
#    ts          = '1514057685.000039'
#    source_team = 'T859226E8'
#    team        = 'T859226E8'
#}

#ID                : U85BY6FV3
#Name              : abu.belal
#RealName          : Abu Belal
#FirstName         :
#Last_Name         :
#Email             : abu.belal@outlook.com
#Phone             :
#Skype             :
#IsBot             : False
#IsAdmin           : True
#IsOwner           : True
#IsPrimaryOwner    : True
#IsRestricted      : False
#IsUltraRestricted : False
#Status            :
#TimeZoneLabel     : Pacific Standard Time
#TimeZone          : America/Los_Angeles
#Presence          :
#Deleted           : False
#Raw               : @{id=U85BY6FV3; team_id=T859226E8; name=abu.belal; deleted=False; color=9f69e7; real_name=Abu Belal; tz=America/Los_Angeles; tz_label=Pacific Standard
#                    Time; tz_offset=-28800; profile=; is_admin=True; is_owner=True; is_primary_owner=True; is_restricted=False; is_ultra_restricted=False; is_bot=False;
#                    updated=1511548251; is_app_user=False}

Start-PSBotBackground -Command $Message

#Start-PSBotBackground -Command $WorkberBotArgs