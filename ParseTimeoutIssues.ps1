$LogFiles = Get-ChildItem -Path $PSScriptRoot\ci -Filter *.log -Recurse
ForEach ($File in $LogFiles) {
    $Log = Get-Content -Path $File.FullName
    $PR = ($File.Name -split "_")[0] -Replace "PR",""
    $Build = ($File.Name -split "_")[1] -Replace ".log",""

    $FilePathSplit = $File.FullName -split "/"
    [array]::Reverse($FilePathSplit)
    $CI = $FilePathSplit[4]


    $ServerName = ($Log -imatch '^Building remotely on ' -split " ")[3]
    $JobResult = ($Log -imatch '^Finished: ' -split " ")[1]

    [array]$TimeoutIssue = $Log -imatch '(Build timed out)'
    If ($TimeoutIssue.count -gt 0) {
        [array]$TimeoutIssueStatistics += New-Object -TypeName PSObject -Property @{
            "CI" = $CI
            "Server" = $ServerName
            "PR" = $PR
            "Build" = $Build
            "Error" = $TimeoutIssue[0]
        }
    }
    Remove-Variable TimeoutIssue
}

$TimeoutIssueStatistics | Export-Csv .\TimeoutIssues.csv -Delimiter ";" -NoTypeInformation