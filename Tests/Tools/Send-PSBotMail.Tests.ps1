$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$sut = $sut -replace '.ps1', '.psm1'
$sutFolder = $sut -replace '.psm1', ''

Remove-Module -Name $sutFolder -ErrorAction Ignore
Import-Module $here\..\..\Tools\\$sutFolder\$sut

Describe "Invoke-BotMessageObject" {

    It  "Should send an email" {

    { Send-PSBotMail -From "test@outlook.com" -To "test@outlook.com" -PasswordForMailAccount "test" `
        -AttachmentContent "this is a test content" -AttachmentContentFileName "test.txt" -ZipPassword 'qwerty' `
        -AttachmentFileName "test.7z" -SmtpHost "smtp.outlook.com" -Username "test@outlook.com" } | Should -Not -Throw
    }

}