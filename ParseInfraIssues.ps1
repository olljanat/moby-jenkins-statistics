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

    [array]$DnsIssue = $Log -imatch '(Could not resolve)'
    If ($DnsIssue.count -gt 0) {
        [array]$DnsIssueStatistics += New-Object -TypeName PSObject -Property @{
            "CI" = $CI
            "Server" = $ServerName
            "PR" = $PR
            "Build" = $Build
            "Error" = $DnsIssue[0]
        }
    }
    Remove-Variable DnsIssue

    [array]$AccessDeniedIssue = $Log -imatch '(AccessDeniedException)'
    If ($AccessDeniedIssue.count -gt 0) {
        [array]$AccessDeniedIssueStatistics += New-Object -TypeName PSObject -Property @{
            "CI" = $CI
            "Server" = $ServerName
            "PR" = $PR
            "Build" = $Build
            "Error" = $AccessDeniedIssue[0]
        }
    }
    Remove-Variable AccessDeniedIssue

    [array]$CausedIssue = $Log -imatch '(Caused: )'
    If ($CausedIssue.count -gt 0) {
        [array]$CausedIssueStatistics += New-Object -TypeName PSObject -Property @{
            "CI" = $CI
            "Server" = $ServerName
            "PR" = $PR
            "Build" = $Build
            "Error" = $CausedIssue[0]
        }
    }
    Remove-Variable CausedIssue

    [array]$DirectoryNotEmptyIssue = $Log -imatch '(DirectoryNotEmptyException)'
    If ($DirectoryNotEmptyIssue.count -gt 0) {
        [array]$DirectoryNotEmptyIssueStatistics += New-Object -TypeName PSObject -Property @{
            "CI" = $CI
            "Server" = $ServerName
            "PR" = $PR
            "Build" = $Build
            "Error" = $DirectoryNotEmptyIssue[0]
        }
    }
    Remove-Variable DirectoryNotEmptyIssue
}

$DnsIssueStatistics | Export-Csv .\DnsIssues.csv -Delimiter ";" -NoTypeInformation
$AccessDeniedIssueStatistics | Export-Csv .\AccessDeniedIssue.csv -Delimiter ";" -NoTypeInformation
$CausedIssueStatistics | Export-Csv .\CausedIssue.csv -Delimiter ";" -NoTypeInformation
$DirectoryNotEmptyIssueStatistics | Export-Csv .\DirectoryNotEmptyIssue.csv -Delimiter ";" -NoTypeInformation
