$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\..\..\PSSlackBot\Public\$sut"

Describe "Remove-CompletedWorkerBot" {
           
    $AsyncObject = New-Object System.Collections.Specialized.OrderedDictionary 

    It "Should not throw when AsyncObject has no items" {
        { Remove-CompletedWorkerBot -AsyncObject $AsyncObject } | Should -Not -Throw
    }

    It "Should throw when AsyncObject has item with no process" {

        $AsyncObject.Add('123', @{State = @{IsCompleted = $false}; Powershell = $null; StartTime = (Get-Date).AddMinutes(-20)})

        { Remove-CompletedWorkerBot -AsyncObject $AsyncObject } | Should -Throw
    }
}
