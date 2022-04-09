# $exceptions = "Teams", "iCUE"
$source = "https://raw.githubusercontent.com/cutecycle/dotfiles/master/profile.ps1"
function g {
	git pull
	git add . 
	git commit -m "wip"
	git push
}
$lights = 1
function Test-PerformanceConstraint { 


}
function lights { 
	$lights = [Int32](-not $global:lights)
	$msg = $lights ? "briNG forth the light" : "bravo six goin dark"
	@(
		"AppsUseLightTheme",
		"SystemUsesLightTheme"
	) | Foreach-Object { 
		Start-ThreadJob {
			$lights = (Get-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name $using:_).($using:_)
			Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name $using:_ -Value $using:lights
		}
	}
	# Write-Host $msg
}
# Set-PoshPrompt -theme M365Princess
function Get-Dotfiles {
	param(
		$source = $source,
		$profilePath = $PROFILE
	)
	$content = (Invoke-WebRequest $source).Content
	if ((Test-Path $profilePath)) { 
		$profileContent = (Get-Content $profilePath)
		# Remove-Item -Force $profilePath
	}
	else { 
		$profilePath = ""
	}

	Write-Information ("ProfilePath:" + $profilePath)
	Write-Information $content
	Write-Information $profileContent
           
	$diff = (Compare-Object $profileContent $content)
	if ($diff) {
		Set-Content -Path $profilePath -Value $content -Force
		Write-Information "diff detected."
		$diff | Out-String | Write-Information
	}
	Write-Output ($null -ne $diff)
}
function touch { 
	param(
		$file
	)
	Write-Output $null  >> $file
}
function endit {
	$procs = (Get-Process | Where-Object { $_.MainWindowTitle -ne "" })
	$procs | Foreach-object -Parallel { 
		Stop-process $_ -ErrorAction "SilentlyContinue"
	}
} 
function k {
	param(
		[Parameter(Position = 0)]
		$name
	)
	$procs = (Get-Process | Where-Object { $_.MainWindowTitle -like "*$name*" -or $_.ProcessName -like "*$name*" })
	$procs | Foreach-object -Parallel { 
		Stop-process $_ -ErrorAction "SilentlyContinue"
	}
}

function cpu { 
	Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 5
}
function mem { 
	Get-Process | Sort-Object -Property WS -Descending | Select-Object -First 5
}

function brb { 
	Start-Process "https://i.kym-cdn.com/entries/icons/facebook/000/025/688/maxresdefault.jpg" -WindowStyle Maximized
}
function vsclear { 
	k code 
	Remove-Item -Recurse -Force -Path "$Env:APPDATA\Code\Backups"
}
function Find-AzPortal {
	param ( 
		[Parameter(Position = 0)]
		$name
	)
	$url = "https://$($azContext.Environment.ManagementPortalUrl)/#$(($azContext).Tenant.Id))/resource"
	$resources = (Get-AzResource -Name *$name*)[0..5]
	$resources | ForEach-Object { 
        ($url + $resource.ResourceId)
	}
	| ForEach-Object -Parallel { 
		Start-Process $_
	}
    
}

function Biglots {
	k edge
}
function Get-Deployments {
	Get-AzDeployment | Where-Object { $_.ProvisioningState -eq "Running" } 
}
# Set-PoshPrompt -theme stelbent.minimal

$extras = @(
	";~\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.10_qbz5n2kfra8p0\LocalCache\local-packages\Python310\Scripts",
	";C:\Program Files\Vim\vim82"
)
$env:PATH += ($extras | Join-String)

function Refresh-Job { 
	param(
		$job
	) 
	$name = ($job.name)
	$result = $job | Receive-job -Keep 

	Write-Information ("Background service $name $($job.State): $result")
	
	$job =	Start-ThreadJob -Name $job.Name -ScriptBlock ([scriptblock]::Create($job.Command)) 
	$result
}

$azContextService = Start-ThreadJob {
	Get-AzContext
} -Name "Azure Context Service"

$dotFileRefreshService = Start-ThreadJob {
	# & ${using:function:Get-DotFiles} -source $using:source -profilePath $using:PROFILE
	$profilePath = $using:PROFILE
	$source = $using:source

	$content = (Invoke-WebRequest $source).Content
	if ((Test-Path $profilePath)) { 
		$profileContent = (Get-Content $profilePath)
	}
	else { 
		$profilePath = ""
	}

	Write-Information ("ProfilePath:" + $profilePath)
	Write-Information $content
	Write-Information $profileContent
           
	$diff = (Compare-Object $profileContent $content)
	if ($diff) {
		Remove-Item -Path $profilePath
		Set-Content -Path $profilePath -Value $content -Force
		Write-Information "diff detected."
		Write-Information ($diff | Out-String)
	}
	($null -eq $diff)
} -Name "Dotfiles Service"

function mail { 
	Start-Process "https://outlook.office.com/mail" &
}
function fancyNull { 
	param(
		[Parameter(ValueFromPipeline = $true)]
		$obj
	)
	($null -eq $obj) ? "?" : $obj
}

function trunc { 
	param ( 
		[Parameter(ValueFromPipeline = $true)]
		$list
	)
	$list | ForEach-Object { 
		($_.length -gt 10) ? $_ :
		(
			$_.Substring(
				0,
				10
			) + "…"
		)
	}
}
function times { 
	$working = ((get-date).Hour -lt 17)
	$relevantTimes = @(
		"Eastern Standard Time"
	)
	if ($working) { 
		$relevantTimes += @(
			"Pacific Standard Time",
			"UTC"
		)
	}
	$relevantTimes | Foreach-Object {
		(
		($_ -creplace "[a-z]", "") -replace " ", "") + " " + `
		(
			[System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date), $_).ToShortTimeString()
		)
	}
}
function i { 
	install-module $_  -Scope CurrentUser -Force -AllowClobber &
}
function Nice-Time { 
	param(
		$then
	)
	Write-Host $then	
	$span = New-TimeSpan -Start $then -end (Get-Date)

	"$($span.Milliseconds)ms"
}
function AzDetails { 
	$azContext = (Refresh-Job $azContextService)
	if ($azContext) {
		@(
			($azContext.Subscription.Name),
			($azContext.Account.Id)
		)
	}
}
function trim { 
	param(
		[Parameter(ValueFromPipeline = $true)]
		$list
	)
	$list | Where-Object {
		($null -ne $_)
	}
}

function gitString {
	git symbolic-ref --short HEAD
}
function dotfileString { 
	param(
		[Parameter(ValueFromPipeline = $true)]
		$list
	)
	$list ? "new Dotfile!" : $null
}
function timeString { 
	param(
		[Parameter(ValueFromPipeline = $true)]
		$list
	)
	$list | ForEach-Object { 
			("⌚" + $_) 
	}
}

function nicePwd { 
	$pwd.Path
}
function gitUpdated { 
	(git diff --name-only) -and ($LASTEXITCODE -eq 0)
}
function promptList {
	@(
		(timeString (times))
		# (dotfileString (Refresh-Job $dotFileRefreshService)),
		(gitString)
		(AzDetails),
		(nicePwd)
	) 
}
function Build-Prompt { 
	(promptList
	| trim
	| trunc 
	| fancyNull 
	| Join-String -Separator " / " -OutputSuffix "> ")
}
# function prompt {
# 	try { 
# 		Build-Prompt
# 	}
# 	catch { 
# 		( "❌" + $_.Exception.Message + "> ")
# 	} 
# }
# (Get-Dotfiles | Out-Null)
