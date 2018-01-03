Add-Type -Path "$PSScriptRoot\SevenZipSharp.dll"
function Compress-TextToZipStream
{
    [CmdletBinding()]
    param
    (
        [String] $Value,
        [String] $ZipPassword
    )

    [SevenZip.SevenZipCompressor]::SetLibraryPath("$PSScriptRoot\7z64.dll")

    $stringMemory = ConvertFrom-StringToMemoryStream -InputString $Value

    $compressedStream = New-Object System.IO.MemoryStream
    $compressor = New-Object SevenZip.SevenZipCompressor
    $compressor.CompressionMethod = [SevenZip.CompressionMethod]::Lzma2
    $compressor.CompressionLevel = [SevenZip.CompressionLevel]::Normal
    $compressor.CompressStream($stringMemory, $compressedStream, $ZipPassword)

    return $compressedStream
}

# thanks to https://gist.github.com/Sam-Martin/1955ac4ef3972bb9e8a8
function ConvertFrom-StringToMemoryStream
{
    param
    (
        [parameter(Mandatory)]
        [string]$InputString
    )

    $stream = New-Object System.IO.MemoryStream;
    $writer = New-Object System.IO.StreamWriter($stream);
    $writer.Write($InputString);
    $writer.Flush();
    return $stream
}

function ConvertFrom-StreamToString
{
    param
    (
        [parameter(Mandatory)]
        [System.IO.MemoryStream]$inputStream
    )

    $reader = New-Object System.IO.StreamReader($inputStream);
    $inputStream.Position = 0;
    return $reader.ReadToEnd()
}

#Export-ModuleMember -Function Compress-TextToZipStream