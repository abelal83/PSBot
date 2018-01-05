



$contentType = New-Object Net.Mime.ContentType -Property @{
    MediaType = [System.Net.Mime.MediaTypeNames+Application]::Zip
    Name = "test.7z"
    }

#$AttachmentStream = ConvertFrom-StringToMemoryStream -InputString '12345'
$AttachmentStream.Position = 0
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