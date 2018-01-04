Import-Module "$PSScriptRoot\..\SevenZip.psm1"

function Send-PSBotMail
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $From,
        [Parameter(Mandatory = $true)]
        [String] $To,
        [Parameter(Mandatory = $false)]
        [String] $AttachmentContent,
        [Parameter(Mandatory = $false)]
        [String] $AttachmentContentFileName,
        [String] $ZipPassword,
        [Parameter( Mandatory = $false)]
        [String] $AttachmentFileName,
        [String] $SmtpHost = "smtpapp.investec.co.uk",
        [int] $SmtpPort = 25,
        [Parameter(ParameterSetName = "Credential", Mandatory = $false)]
        [string] $Username = $null,
        [Parameter(ParameterSetName = "Credential", Mandatory = $false)]
        [securestring] $Password = $null
    )

    $attachmentStream = Compress-TextToZipStream -InputString $AttachmentContent -ZipPassword $ZipPassword -FileName $AttachmentContentFileName

    $contentType = New-Object Net.Mime.ContentType -Property @{
        MediaType = [Net.Mime.MediaTypeNames+Application]::Zip
        Name = $AttachmentFileName
        }

    $attachment = New-Object Net.Mail.Attachment $attachmentStream, $contentType

    $message = New-Object System.Net.Mail.MailMessage
    $message.Attachments.Add($attachment)
    $message.To.Add((New-Object System.Net.Mail.MailAddress($To)))
    $message.From = New-Object System.Net.Mail.MailAddress($From)

    $smtpClient = New-Object System.Net.Mail.SmtpClient
    #$smtpClient.Credentials = New-Object System.Net.NetworkCredential($username, $password)
    #$smtpClient.Port = 587
    $smtpClient.EnableSsl = $true
    $smtpClient.Host = $SmtpHost

    $smtpClient.Send($message)
}