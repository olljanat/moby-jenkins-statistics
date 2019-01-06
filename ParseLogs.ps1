$LogFiles = Get-ChildItem -Path . -Filter *.log -Recurse
ForEach ($File in $LogFiles) {
	$Log = Get-Content -Path $File.FullName
	$PR = ($File.Name -split "_")[0] -Replace "PR",""
	$Build = ($File.Name -split "_")[1] -Replace ".log",""

	$FilePathSplit = $File.FullName -split "/"
	[array]::Reverse($FilePathSplit)
	$CI = $FilePathSplit[4]


	$ServerName = ($Log -imatch '^Building remotely on ' -split " ")[3]
	$JobResult = ($Log -imatch '^Finished: ' -split " ")[1]
	
	## TODO: Do we need statistics from skipped jobs?
	# $IntegrationCliSkippedTests = $Log -imatch '^(SKIP:)'
	# $IntegrationSkippedTests = $Log -imatch '^(--- SKIP:)'

	If ($JobResult -eq "SUCCESS") {
		$IntegrationCliPassTests = $Log -imatch '^(PASS:)'
		ForEach ($Test in $IntegrationCliPassTests) {
			$TestSplit = $Test -split "\: "
			$TestSplit2 = $TestSplit[2] -split "\."
			$TestSplit3 = $TestSplit2[1] -split "`t"
			$TestSplit4 = $Test -split "`t"
			[array]$PassTestsStatistics += New-Object -TypeName PSObject -Property @{
				"CI" = $CI
				"Server" = $ServerName
				"PR" = $PR
				"Build" = $Build
				"Test" = $TestSplit3[1]
				"Type" = "integration-cli"
				"Time" = $TestSplit4[1] -Replace "s",""
			}
		}
		Remove-Variable IntegrationCliPassTests

		$IntegrationPassTests = $Log -imatch '^(--- PASS:)'
		ForEach ($Test in $IntegrationPassTests) {
			$TestSplit3 = ($Test -split "\: ")[1] -split " \(" -replace "\)",""
			[array]$PassTestsStatistics += New-Object -TypeName PSObject -Property @{
				"CI" = $CI
				"Server" = $ServerName
				"PR" = $PR
				"Build" = $Build
				"Test" = $TestSplit3[0]
				"Type" = "integration"
				"Time" = $TestSplit3[1] -Replace "s",""
			}
		}
		Remove-Variable IntegrationPassTests
	} ElseIf ($JobResult -eq "FAILURE") {
		$IntegrationCliFailedTests = $Log -imatch '^(FAIL:)'
		ForEach ($Test in $IntegrationCliFailedTests) {
			$TestSplit = $Test -split "\: "
			$TestSplit2 = $TestSplit[2] -split "\."
			$TestSplit3 = $Test -split "`t"
			[array]$FailedTestsStatistics += New-Object -TypeName PSObject -Property @{
				"CI" = $CI
				"Server" = $ServerName
				"PR" = $PR
				"Build" = $Build
				"Test" = $TestSplit2[1]
				"Type" = "integration-cli"
				"Time" = ""
			}
		}
		Remove-Variable IntegrationCliFailedTests

		$IntegrationFailedTests = $Log -imatch '^(--- FAIL:)'
		ForEach ($Test in $IntegrationFailedTests) {
			$TestSplit3 = ($Test -split "\: ")[1] -split " \(" -replace "\)",""
			[array]$FailedTestsStatistics += New-Object -TypeName PSObject -Property @{
				"CI" = $CI
				"Server" = $ServerName
				"PR" = $PR
				"Build" = $Build
				"Test" = $TestSplit3[0]
				"Type" = "integration"
				"Time" = $TestSplit3[1] -Replace "s",""
			}
		}
		Remove-Variable IntegrationFailedTests
	} ElseIf ($JobResult -eq "ABORTED") {
		continue
	} Else {
		Write-Warning "Cannot find job result message from: $($File.Name). Jenkins failure?"
	}
}

$FailedTestsStatistics | Export-Csv .\FailedTests.csv -Delimiter ";" -NoTypeInformation
$PassTestsStatistics | Export-Csv .\PassTests.csv -Delimiter ";" -NoTypeInformation
