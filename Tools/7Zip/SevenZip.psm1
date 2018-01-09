Add-Type -Path "$PSScriptRoot\SevenZipSharp.dll"
function ConvertFrom-StringToCompressedStream
{
    ##############################
    #.SYNOPSIS
    # 
    #
    #.DESCRIPTION
    #Long description
    #
    #.PARAMETER Value
    #Parameter description
    #
    #.PARAMETER ZipPassword
    #Parameter description
    #
    #.EXAMPLE
    #An example
    #
    #.NOTES
    #General notes
    ##############################
    [CmdletBinding()]
    param
    (
        [String] $Value,
        [String] $ZipPassword
    )

    [SevenZip.SevenZipCompressor]::SetLibraryPath("$PSScriptRoot\7z64.dll")
    
    $stringStream = ConvertFrom-StringToMemoryStream -InputString $Value

    $compressedStream = New-Object System.IO.MemoryStream
    $compressor = New-Object SevenZip.SevenZipCompressor
    $compressor.CompressionMethod = [SevenZip.CompressionMethod]::Lzma2
    $compressor.CompressionLevel = [SevenZip.CompressionLevel]::Normal
    $compressor.CompressStream($stringStream, $compressedStream, $ZipPassword)

    return $compressedStream
}

function ConvertFrom-StringToMemoryStream
{
    param(
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
    param(
        [parameter(Mandatory)]
        [System.IO.MemoryStream]$inputStream
    )
    $reader = New-Object System.IO.StreamReader($inputStream);
    $inputStream.Position = 0;
    return $reader.ReadToEnd()
}

Export-ModuleMember -Function ConvertFrom-StringToCompressedStream