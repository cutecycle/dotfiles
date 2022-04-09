$start = (Get-Date)
$exceptions = "Teams", "iCUE"
$source = "https://raw.githubusercontent.com/cutecycle/dotfiles/master/profile.ps1"
function g {
	git add . 
	git commit -m "wip"
	git push
}

# Set-PoshPrompt -theme M365Princess
function Cache-Command { 
	param(
		[Parameter(ValueFromPipeline = $true)]
		$command
	)
	$commandString = $command.ToString()
	$mystream = [IO.MemoryStream]::new([byte[]][char[]]$commandString)
	$commandHash = (Get-FileHash -InputStream $mystream -Algorithm SHA256).Hash
	$target = "~/.cache/$commandHash"
	if (Test-Path $target) {
		$fresh = (Get-Item -Path $target).CreationTime -lt (Get-Date).AddDays(-1) 
	}
	if (-not $fresh) {
		$result = Invoke-Command $command -NoNewScope
		Start-ThreadJob { 
			$result = $using:result
			$target = $using:target
			Set-Content -Path $target -Value $result -Force
		}
	}
	else { 
		$result = Get-Content $target
	}
	$result
}
function Get-Dotfiles {
	param(
		$source,
		$profilePath
	)
	# Stay unidirectional. only edit in codespaces
    
	# Start-ThreadJob { 
	# $source = $using:source
	# $profilePath = $using:PROFILE
	$content = (Invoke-WebRequest $source).Content
	$profileContent = get-content $profilePath 

	Write-Information ("ProfilePath:" + $profilePath)
	Write-Information $content
	Write-Information $profileContent
           
	$diff = (Compare-Object $profileContent $content)
	if ($diff) {
		Remove-Item -Force $profilePath
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
	echo $null  >> $file
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
	
	& ${using:Get-DotFiles} -source $using:source -profilePath $using:PROFILE
} -Name "Dotfiles Service"

function mail { 
	Start-Process "https://outlook.office.com/mail" &
	# Start-Process "https://gmail.com/"
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
		"Eastern Standard Time",
		$working ? "Pacific Standard Time" : $null,
		$working ? "UTC" : $null
	)
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
	# $fancyJobsList = Get-Job | Foreach-Object { 
	#     (($_.status -eq "Completed") ? "": "♻️")
	# }
	# $fancyJobsList = ((Get-Job).length + " jobs")

	$azContext = (Refresh-Job $azContextService)
	if ($azContext) {
		$subName = $azContext.Subscription.Name
		$subAccount = ($azContext.Account.Id)
	}
	$newDotFile = (Refresh-Job $dotFileRefreshService)
	(@(
		("⌚"),
		(times),
		# "`n",
		($newDotFile ? "new Dotfile!" : $null)
		(git symbolic-ref --short HEAD),
		("" + $subName),
		("" +
		$subAccount),
		# $fancyJobsList,
		$gitContext,
		# "`n"
		$pwd.Path
	)) | Where-Object {
		$null -ne $_ -and $false -ne $_
	} |
	Foreach-Object {
		fancyNull $_
	} | Join-String -Separator " / " -OutputSuffix "> "
}
# $time = (New-TimeSpan -Start $start -end $end).Seconds
# Write-Host "Profile read in $($time) Seconds"
function prompt {
	Build-Prompt
}
prompt



