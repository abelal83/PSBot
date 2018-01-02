Remove-Module SevenZip -ErrorAction Continue
Import-Module "$PSScriptRoot\SevenZip.psm1"

Compress-TextToStream -Value "abcdefg" -ZipPassword "abc"