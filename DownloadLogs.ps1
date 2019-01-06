$rssURLs = @{
	janky = "https://jenkins.dockerproject.org/job/Docker-PRs/rssAll";
	experimental = "https://jenkins.dockerproject.org/job/Docker-PRs-experimental/rssAll";
	powerpc = "https://jenkins.dockerproject.org/job/Docker-PRs-powerpc/rssAll";
	z = "https://jenkins.dockerproject.org/job/Docker-PRs-s390x/rssAll";
	rs1 = "https://jenkins.dockerproject.org/job/Docker-PRs-WoW-RS1/rssAll";
	rs5 = "https://jenkins.dockerproject.org/job/Docker-PRs-WoW-RS5-Process/rssAll";
}

ForEach ($key in $rssURLs.Keys) {
	$rssAll = Invoke-WebRequest -UseBasicParsing -Uri $rssURLs.Item($key)

	[xml]$xmlRssAll = $rssAll.Content
	$rssEntries = $xmlRssAll.feed.entry | Sort-Object published

	ForEach ($Row in $rssEntries) {
		$Date = Get-Date -Date $row.published
		$PrId = (($row.title -split "#")[1] -split " ")[0]
		$BuildId = ($row.link.href -split "/")[5]

		If (!(Test-Path "$PSScriptRoot\ci\$key\$($Date.Year)")) { New-Item -ItemType Directory -Path "$PSScriptRoot\ci\$key\$($Date.Year)" }
		If (!(Test-Path "$PSScriptRoot\ci\$key\$($Date.Year)\$($Date.Month)")) { New-Item -ItemType Directory -Path "$PSScriptRoot\ci\$key\$($Date.Year)\$($Date.Month)" }
		If (!(Test-Path "$PSScriptRoot\ci\$key\$($Date.Year)\$($Date.Month)\$($Date.Day)")) { New-Item -ItemType Directory -Path "$PSScriptRoot\ci\$key\$($Date.Year)\$($Date.Month)\$($Date.Day)" }
		$FileName = "$PSScriptRoot\ci\$key\$($Date.Year)\$($Date.Month)\$($Date.Day)\PR" + $PrId + "_" + $BuildId + ".log"

		If (!(Test-Path $FileName)) {
			Invoke-WebRequest -UseBasicParsing -Uri $($row.link.href + "/consoleText") -OutFile $FileName
		}
	}
}