Add-Type -Path "$PSScriptRoot\SevenZipSharp.dll"
function Compress-TextToZipStream
{
    ##############################
    #.SYNOPSIS
    #Short description
    #
    #.DESCRIPTION
    #Long description
    #
    #.PARAMETER InputString
    # String of characters to compress into zip file
    #
    #.PARAMETER FileName
    # File name to give to memorysteam created from InputString
    # Once memory stream is returned you must save and name that as whatever.7z
    #
    #.PARAMETER ZipPassword
    # String password used to open 7zip file, ideally this should be a securestring however, DPAPI is not availble on *nix 
    # platforms. 
    #
    #.EXAMPLE
    #An example
    # $memoryStream = Compress-TextToZipStream -InputString "test content" -FileName "test.txt" -ZipPassword "pa$$word"
    # $memoryStream will contain 7zip compressed file called test.txt protected with pa$$word
    # 
    #.NOTES
    #General notes
    ##############################
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, HelpMessage = "String to compress")]
        [String] $InputString,
        [Parameter(Mandatory = $true, HelpMessage = "Used for giving InputString file name")]
        [string] $FileName,
        [Parameter(Mandatory = $true)]
        [String] $ZipPassword
    )

    [SevenZip.SevenZipCompressor]::SetLibraryPath("$PSScriptRoot\7z64.dll")

    $stringMemory = ConvertFrom-StringToMemoryStream -InputString $InputString

    $compressedStream = New-Object System.IO.MemoryStream
    $compressor = New-Object SevenZip.SevenZipCompressor
    $compressor.CompressionMethod = [SevenZip.CompressionMethod]::Lzma2
    $compressor.CompressionLevel = [SevenZip.CompressionLevel]::Normal
    $compressor.DefaultItemName = $FileName
    $compressor.EncryptHeaders = $true
    $compressor.CompressStream($stringMemory, $compressedStream, $ZipPassword)
    $compressedStream.Position = 0

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

Export-ModuleMember -Function Compress-TextToZipStream