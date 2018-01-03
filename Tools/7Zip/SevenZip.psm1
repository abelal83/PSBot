Add-Type -Path "$PSScriptRoot\SevenZipSharp.dll"
function Compress-TextToStream
{
    [CmdletBinding()]
    param
    (
        [String] $Value,
        [String] $ZipPassword
    )

    [SevenZip.SevenZipCompressor]::SetLibraryPath("$PSScriptRoot\7z64.dll")
    $encoder = New-Object System.Text.UnicodeEncoding
    [byte[]] $byteString = $encoder.GetBytes($Value)

    $compressedStream = New-Object System.IO.MemoryStream
    $compressor = New-Object SevenZip.SevenZipCompressor
    $compressor.CompressionMethod = [SevenZip.CompressionMethod]::Lzma2
    $compressor.CompressionLevel = [SevenZip.CompressionLevel]::Normal
    $compressor.CompressStream($byteString, $compressedStream, $ZipPassword)

    return $compressedStream
}

Export-ModuleMember -Function Compress-TextToStream