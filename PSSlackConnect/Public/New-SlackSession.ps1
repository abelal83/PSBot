function New-SlackSession
{
    [CmdletBinding()]
    param
    (
        [String]
        $Token
    )

    $SlackRtm = 'https://slack.com/api/rtm.connect'
    $SlackRealTimeSession = Invoke-RestMethod -Uri $SlackRtm -Body @{token = $Token}

    return $SlackRealTimeSession
}