$LogFiles = Get-ChildItem -Path $PSScriptRoot\ci\rs1 -Filter *.log -Recurse
ForEach ($File in $LogFiles) {
    $Log = Get-Content -Path $File.FullName
    $PR = ($File.Name -split "_")[0] -Replace "PR",""
    $Build = ($File.Name -split "_")[1] -Replace ".log",""

    $FilePathSplit = $File.FullName -split "/"
    [array]::Reverse($FilePathSplit)
    $CI = $FilePathSplit[4]

    $ServerName = ($Log -imatch '^Building remotely on ' -split " ")[3]
    $JobResult = ($Log -imatch '^Finished: ' -split " ")[1]
    $DockerVersion = ($Log -imatch 'Version:           ' -split "Version:           ")[1]
    $KernelVersion = ($Log -imatch '^Kernel Version: ' -split "Kernel Version: ")[1]
    [array]$RS1 = $Log -imatch '(Error response from daemon)'

    if ($JobResult -ne "ABORTED") {
        $DateSplit = $Log -imatch '^INFO: executeCI.ps1 starting at ' -replace "  "," " -split " " 
        [string]$dateString = $dateSplit[4] + ", " + $dateSplit[5] + " " + $dateSplit[6] + ", " + $dateSplit[9] + " " + $dateSplit[7]
        $DateFormatted = Get-Date -Date $dateString -Format "yyyy-MM-dd HH:mm:ss"

        [array]$RS1Statistics += New-Object -TypeName PSObject -Property @{
            "Timestamp" = $DateFormatted
            "CI" = $CI
            "Server" = $ServerName
            "PR" = $PR
            "Build" = $Build
            "Error" = $RS1[0]
            "Result" = $JobResult
            "DockerVersion" = $DockerVersion
            "KernelVersion" = $KernelVersion
        }
    }
}

$RS1StatisticsSorted = $RS1Statistics | Select-Object Timestamp,Server,PR,Build,DockerVersion,KernelVersion,Result,Error | Sort-Object Timestamp
$RS1StatisticsSorted | Export-Csv .\RS1Statistics.csv -Delimiter "," -NoTypeInformation

