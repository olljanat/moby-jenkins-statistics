$LogFiles = Get-ChildItem -Path . -Filter *.log -Recurse
ForEach ($File in $LogFiles) {
	$Log = Get-Content -Path $File.FullName
	
	$IntegrationFailedTests = $Log -imatch '^(--- FAIL:)'
	$IntegrationPassTests = $Log -imatch '^(--- PASS:)'
	$IntegrationSkippedTests = $Log -imatch '^(--- SKIP:)'
	
	$IntegrationCliFailedTests = $Log -imatch '^(FAIL:)'
	$IntegrationCliPassTests = $Log -imatch '^(PASS:)'
	$IntegrationCliSkippedTests = $Log -imatch '^(SKIP:)'
	
	ForEach ($Test in $IntegrationCliFailedTests) {
		$TestSplit = $Test -split "\: "
		$TestSplit2 = $TestSplit[2] -split "\."
		[array]$FailedTestsStatistics += New-Object -TypeName PSObject -Property @{
			"Test" = $TestSplit2[1]
			"Type" = "integration-cli"
			"Time" = ""
		}
	}

	ForEach ($Test in $IntegrationFailedTests) {
		$TestSplit3 = ("--- PASS: TestCommitInheritsEnv (2.05s)" -split "\: ")[1] -split " \(" -replace "\)",""
		[array]$FailedTestsStatistics += New-Object -TypeName PSObject -Property @{
			"Test" = $TestSplit3[0]
			"Type" = "integration"
			"Time" = $TestSplit3[1]
		}
	}
}

$FailedTestsStatistics | Export-Csv .\FailedTests.csv -Delimiter ";" -NoTypeInformation