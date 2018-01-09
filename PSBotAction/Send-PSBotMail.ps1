function Send-PSBotMailAttachment
{
    [CmdletBinding()]
    param
    (
        $JsonInput,
        [Parameter(ParameterSetName = "Stream")]
        $AttachmentStream,
        [Parameter(Mandatory = $true, ParameterSetName = "Stream")]
        $FileName,
        [Parameter(ParameterSetName = "File")]
        $AttachmentFile
    )

    if ($AttachmentStream)
    {
        # Create attachment
        $contentType = New-Object Net.Mime.ContentType `
        -Property @{
            MediaType = [Net.Mime.MediaTypeNames+Application]::Octet
            Name = $FileName
        }
        $attachment = New-Object Net.Mail.Attachment $AttachmentStream , $contentType
    }
    else 
    {
        $attachment = New-Object Net.Mail.Attachment $AttachmentFile
    }
    # Add the attachment
    $message.Attachments.Add($attachment)
    

    $smptServer = 'internalsmtp.uk.corp.investec.com'
    
    $email = $JsonInput.user.profile.email
    $realName = $JsonInput.user.real_name 


    # Send Mail via SmtpClient
    $smtpClient.Send($message)

}