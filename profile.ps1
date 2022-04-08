$module = New-Module -Name Profile -ScriptBlock {

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
	$azContext = Cache-Command {
		Get-AzContext
	}
	function Get-Dotfiles {
		# Stay unidirectional. only edit in codespaces
    
		# Start-ThreadJob { 
		# $source = $using:source
		# $profilePath = $using:PROFILE
		$profilePath = $PROFILE
		$content = (Invoke-WebRequest $source).Content
           
		$profileContent = get-content  $profilePath 
		$diff = (Compare-Object $profileContent $content)
		if ($diff) {
			Remove-Item -Force $profilePath
			Set-Content -Path $profilePath -Value $content -Force
			Write-Output $true 
		}
		else { 
			Write-Output $false 
		}
		# }
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
}
Import-Module $module
# Set-PoshPrompt -theme stelbent.minimal

$extras = @(
	";~\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.10_qbz5n2kfra8p0\LocalCache\local-packages\Python310\Scripts",
	";C:\Program Files\Vim\vim82"
)
$env:PATH += ($extras | Join-String)
$jobs = @()

$jobStore = @{

}
# function Sync-Job { 
# 	param(
# 		$scriptblock,
# 		$originalVariable
# 	)

# 	$result = (Receive-Job $job)
# 	$jobstore[$scriptblock] = $result
# 	if ($null -ne $result) {
# 		Start-ThreadJob $
# 	}
	

# 	(
# 		($null -eq $result) ? 
# 		$originalVariable :
# 		$job
# 	)
# }
function Refresh-Job { 
	param(
		$job
	) 

	$result = $job | Receive-job -Keep 
	$result
	if ($null -eq $result) {
		$job = Start-ThreadJob $using:scriptBlock
	}
	$job =	Start-ThreadJob -ScriptBlock $job.Command
	$result

}

# $azContextService = Start-ThreadJob {
# 	Get-AzContext
# }


# $azContext = (Refresh-Job $azContextService);
# $x = Get-PromptServiceResults 

function Build-Prompt { 
	$fancyJobsList = Get-Job | Foreach-Object { 
        (($_.status -eq "Completed") ? "": "♻️")
	}
	$fancyJobsList = ("♻️" + (Get-Job).length)


	$job += Start-Job {
		(Get-DotFiles)
	}
	$azContext = ($azContextService | Receive-Eternal)
	$subName = $azContext.Subscription.Name
	$subAccount = ($azContext.Account.Id)
	(@(
		,
		("☁️" + $subName),
		("@" +
		$subAccount),
		$fancyJobsList,
		$gitContext,
		$pwd.Path,
		"➡️ "
	) | Join-String -Separator " _ ")
}
# function prompt {
# 	Build-Prompt
# }



