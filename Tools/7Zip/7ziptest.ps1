Remove-Module SevenZip -ErrorAction Continue
Import-Module "$PSScriptRoot\SevenZip.psm1"

$attachmentStream = Compress-TextToZipStream -Value "abcdefg" -ZipPassword "abc"

function Send-PSBotMail
{
    [CmdletBinding()]
    param
    (
        [System.IO.Stream] $AttachmentStream,
        [String] $AttachmentFileName
    )


    # Create attachment
    $contentType = New-Object Net.Mime.ContentType -Property @{
        MediaType = [Net.Mime.MediaTypeNames+Application]::Zip
        Name = $AttachmentFileName
        }

    $attachment = New-Object Net.Mail.Attachment $AttachmentStream, $contentType

    # Add the attachment
    $message.Attachments.Add($attachment)

    # Send Mail via SmtpClient
    $smtpClient.Send($message)
}

$contentType = New-Object Net.Mime.ContentType -Property @{
    MediaType = [System.Net.Mime.MediaTypeNames+Text]::Plain
    Name = "test.txt"
    }

$AttachmentStream = ConvertFrom-StringToMemoryStream -InputString '12345'
$attachment = New-Object Net.Mail.Attachment $AttachmentStream, $contentType
$username = "abu.belal@.com"
$password = ""
$msg = New-Object System.Net.Mail.MailMessage
$msg.To.Add((New-Object System.Net.Mail.MailAddress("abu.belal@.com")));
$msg.From = New-Object System.Net.Mail.MailAddress($username);
$msg.Subject = "Test Office 365 Account";
$msg.Body = "Testing email using Office 365 account.";
$msg.IsBodyHtml = $true;
$msg.Attachments.Add($attachment)
$client = New-Object System.Net.Mail.SmtpClient;
$client.Host = "smtp.outlook.com";
$client.Credentials = New-Object System.Net.NetworkCredential($username, $password);
$client.Port = 587; 
$client.EnableSsl = $true;
$client.Send($msg);