$rssAll = Invoke-WebRequest -UseBasicParsing -Uri https://jenkins.dockerproject.org/job/Docker-PRs/rssAll
[xml]$xmlRssAll = $rssAll.Content
$rssEntries = $xmlRssAll.feed.entry | Sort-Object published

ForEach ($Row in $rssEntries) {
	$Date = Get-Date -Date $row.published
	$PrId = (($row.title -split "#")[1] -split " ")[0]
	$BuildId = ($row.link.href -split "/")[5]
	
	If (!(Test-Path "$PSScriptRoot\$($Date.Year)")) { New-Item -ItemType Directory -Path "$PSScriptRoot\$($Date.Year)" }
	If (!(Test-Path "$PSScriptRoot\$($Date.Year)\$($Date.Month)")) { New-Item -ItemType Directory -Path "$PSScriptRoot\$($Date.Year)\$($Date.Month)" }
	If (!(Test-Path "$PSScriptRoot\$($Date.Year)\$($Date.Month)\$($Date.Day)")) { New-Item -ItemType Directory -Path "$PSScriptRoot\$($Date.Year)\$($Date.Month)\$($Date.Day)" }
	$FileName = "$PSScriptRoot\$($Date.Year)\$($Date.Month)\$($Date.Day)\PR" + $PrId + "_" + $BuildId + ".log"

	If (!(Test-Path $FileName)) {
		Invoke-WebRequest -UseBasicParsing -Uri $($row.link.href + "/consoleText") -OutFile $FileName
	}
}