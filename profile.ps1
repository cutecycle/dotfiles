# $exceptions = "Teams", "iCUE"
$source = "https://raw.githubusercontent.com/cutecycle/dotfiles/master/profile.ps1"
function g {
	git pull
	git add . 
	git commit -m "wip"
	git push
}
$lights = 1
function lights { 
	$lights = [Int32](-not $lights)
	Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value $lights
}
# Set-PoshPrompt -theme M365Princess
function Get-Dotfiles {
	param(
		$source = $source,
		$profilePath = $PROFILE
	)
	# Stay unidirectional. only edit in codespaces
    
	# Start-ThreadJob { 
	# $source = $using:source
	# $profilePath = $using:PROFILE
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
	& ${using:function:Get-DotFiles} -source $using:source -profilePath $using:PROFILE
} -Name "Dotfiles Service"

function mail { 
	Start-Process "https://outlook.office.com/mail" &
}
function fancyNull { 
	param(
		$obj
	)
	($null -eq $obj) ? "?" : $obj
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
	install-module $_  -Scope CurrentUser -Force &
}
function Build-Prompt { 
	$azContext = (Refresh-Job $azContextService)
	if ($azContext) {
		$subName = $azContext.Subscription.Name
		$subAccount = ($azContext.Account.Id)
	}
	$newDotFile = (Refresh-Job $dotFileRefreshService)
	(@(
		("⌚"),
		(times),
		($newDotFile ? "new Dotfile!" : $null)
		(git symbolic-ref --short HEAD),
		("" + $subName),
		("" +
		$subAccount),
		$fancyJobsList,
		$gitContext,
		$pwd.Path
	)) | Where-Object {
		$null -ne $_ -and $false -ne $_
	} |
	Foreach-Object {
		fancyNull $_
	} | Join-String -Separator " / " -OutputSuffix "> "
}
function prompt {
	Build-Prompt
}
