Remove-Module SevenZip -ErrorAction Continue
Import-Module "$PSScriptRoot\SevenZip.psm1"

$encrypted7zip = ConvertFrom-StringToCompressedStream -Value "abcdefg" -ZipPassword "abc"