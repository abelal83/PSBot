Import-Module "$PSScriptRoot\..\Invoke-SevenZip\Invoke-SevenZip.psm1"

function Send-PSBotMail
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $From,

        [Parameter(Mandatory = $true)]
        [String] $To,



        [Parameter(Mandatory = $false, HelpMessage = "string content used to create a file, resulting file is added to 7zip file")]
        [String] $AttachmentContent,

        [Parameter(Mandatory = $false, HelpMessage = "Name to give to file generated from AttachmentContent")]
        [String] $AttachmentContentFileName,

        [String] $ZipPassword,

        [Parameter( Mandatory = $false, HelpMessage = "Name to give to generated 7zip file, this is the file that gets attached")]
        [String] $AttachmentFileName,

        [Parameter(Mandatory = $true)]
        [String] $SmtpHost,

        [int] $SmtpPort = 587,

        [Parameter(ParameterSetName = "Credential", Mandatory = $false)]
        [string] $Username = $null,
        [Parameter(ParameterSetName = "Credential", Mandatory = $false)]
        [string] $PasswordForMailAccount = $null
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
    if ($PasswordForMailAccount -ne $null)
    {
        $smtpClient.Credentials = New-Object System.Net.NetworkCredential($Username, $PasswordForMailAccount)
    }
    
    $smtpClient.Port = $SmtpPort
    $smtpClient.EnableSsl = $true
    $smtpClient.Host = $SmtpHost

    $smtpClient.Send($message)
}