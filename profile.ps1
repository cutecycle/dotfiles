$exceptions = "Teams", "iCUE", "devenv", "mail"	
$source = "https://raw.githubusercontent.com/cutecycle/dotfiles/master/profile.ps1"
Set-StrictMode -Version latest
$WarningPreference = "Continue"
$global:temp = "~/.temp/profile.ps1"
# look into: why receive-job doesn't unroll
$setup = New-Module {
	function Install-Modules { 
		param(
			$list
		)
		$list | Foreach-object {
			Start-ThreadJob -Name "Install $_" {
				Install-Module -Name $using:_ -Scope CurrentUser
			}
		}
	}

	Install-Modules @(
		"Az",
		"oh-my-posh",
		"PoshInternals"
	)
} 
Import-Module $setup
function g {
	Start-ThreadJob {
		git pull
		git add . 
		git commit -m "wip"
		git push 
	} 
}


function Clear-Old { 
	param(
		$threshhold = 3,
		$exceptions = $global:exceptions
	)
	get-process 
	| where { $_.MainWindowHandle -ne 0 } 
	| select MainWindowHandle 
	| SELECT *
}
function Get-Font { 
	param(
		$name
	)
	[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
	(New-Object System.Drawing.Text.InstalledFontCollection).Families | where { 
		$_.Name -eq $name
	}
}
function Install-Font { 
	param(
		$name
	)
	Start-ThreadJob {
		& ${using:function:Get-Font}  $using:name 
		npm i -g google-font-installer
		gfi install $using:name
	}
}

function Vectorize { 
	param(
		$list,
		$optimalThreads = 8
	)
	Slice-List $list $optimalThreads

}
function Slice-List { 
	param(
		$list,
		$num
	)
	$indices = @(0..($num-1)) 
	$size = [Int32]$list.length / $num
	$starts = $indices | Foreach-object {
		$_ * ($size)
	}
	$ends = $indices | Foreach-object { 
		($_ + 1) * $size
	}
	@{
		starts = $starts
		ends   = $ends
	}
}
Slice-List @(0..17) 4
function Count-Instances { 
	param(
		$file
	)
	# this should be able to be any file
	$string = (Get-Content $file)
	$tokens = ($string -split "\s")
	$tokens | ForEach-Object -Parallel {
		# $token = $using:_
		$tokens = $using:tokens
		@{
			token = $token
			count = ($tokens | Where-Object { 
					$_ -eq $this
				}).Length
		}
	}
}
function lights { 
	@(
		"AppsUseLightTheme",
		"SystemUsesLightTheme"
	) | Foreach-Object { 
		Start-ThreadJob {
			$lights = (Get-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name $using:_).($using:_)
			$lights = [Int32](-not $lights)
			Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name $using:_ -Value $lights
			(Get-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name $using:_).($using:_)

			# $msg = [Int32]$lights -eq $true ? "briNG forth the light" : "bravo six goin dark"
			# Write-Output $msg
		}
	}
}

function Update-Dotfiles { 
	$temp = $global:temp
	if (Test-Path $temp) { 
		rm $temp
	}
 else { 
		mkdir ~/.temp -FOrce
	}
	Invoke-WebRequest $source -OutFile $temp

	Copy-Item -Path $temp -Destination $PROFILE -Force
	. $PROFILE
}
function Restore-Dotfiles { 
	$temp = $global:temp
	Copy-Item -Path $temp -Destination $PROFILE -Force
}
function touch { 
	param(
		$file
	)
	Write-Output $null  >> $file
}
function endit {
	$procs = (Get-Process | Where-Object { $_.MainWindowTitle -notin $exceptions })
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

$global:azContextService = Start-ThreadJob {
	Get-AzContext
} -Name "Azure Context Service"

$global:dotFileRefreshService = Start-ThreadJob {
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
		Write-Information "diff detected."
		Write-Information ($diff | Out-String)
	}
	($null -ne $diff)
} -Name "Dotfiles Service"

function mail { 
	Start-Process "https://outlook.office.com/mail" &
}
function fancyNull { 
	($null -eq $args[0]) ? "?" : $args[0]
}
function wl { 
	Start-Process "https://www.youtube.com/playlist?list=WL"
}

function trunc { 
	[string[]] $args[0] | ForEach-Object { 
		$intended = 15
		$short = ($_.Length -lt $intended)
		$_.Substring(
			0,
			(
				#dammit i know there's something better than this out there
				$short ? $_.Length : ($intended)
			)

		) + ($short ? "" :  "…" )
	}
}
function Test-Perf { 
	Measure-Command { 
		(22 / 7) | Set-COntent -path (New-TemporaryFile)
	}
}
function Test-Hours { 
	$sleeping = ([DateTime]$args[0].Hour -gt 8) 
	$afterhours = ([DateTime]$args[0].Hour -lt 17) 
	$weekend = ([DateTime]$args[0].DayOfWeek -in @("Saturday", "Sunday") )
	Write-Information (Get-Variable notearly | out-string)
	Write-Information (Get-Variable notlate | out-string)
	Write-Information (Get-Variable notweekend | out-string)

	(-not $sleeping -and -not $afterhours -and $weekend)
}
function times { 
	$working = (Test-Hours (Get-Date))
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
	$azContext = (Refresh-Job $global:azContextService)
	if ($azContext) {
		@(
			($azContext.Subscription.Name),
			($azContext.Account.Id)
		)
	}
}
function trim { 
	$args[0] | Where-Object {
		($null -ne $_)
	}
}

function gitString {
	git symbolic-ref --short HEAD
}
function dotfileString { 
	$newFile = (Refresh-Job $global:dotFileRefreshService)	
	$newFile ? "new dotfile!" : $null
}
function timeString { 
	$args[0] | ForEach-Object { 
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
		(dotfileString (Refresh-Job $global:dotFileRefreshService)),
		(gitString)
		(AzDetails),
		"`n",
		(nicePwd)
	) 
}
function Build-Prompt { 
	(
		(trunc (fancynull (trim (promptList))))
		| Join-String -Separator " / " -OutputSuffix "> "
	)
}


function Posh-Block {
	param(
		$command
	)
	$blockPrototype = @"
{
	"type": "prompt",
	"alignment": "right",
	"segments": [
	  {
		"type": "command",
		"style": "plain",
		"foreground": "#ffffff",
		"properties": {
		  "shell": "pwsh",
		  "command": ""
		}
	  }
	]
  }
"@ | ConvertFrom-Json -depth 100
	$blockPrototype.segments.properties.command = $command.ToString()
	$blockPrototype
}

function Posh-Setup {
	$themeBase = ((Invoke-WebRequest "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/M365Princess.omp.json").Content | ConvertFrom-Json -Depth 100)
	$test = Posh-Block -command {
		# (AzDetails)
		"hello"
	}
	$themeBase.blocks[0].segments += $test

	$finalString = $themeBase | ConvertTo-Json -Depth 100

	Set-PoshPrompt -Theme $finalString
	$themeBase
}
$poshSetup = Posh-Setup
