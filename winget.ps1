
function getwinget { 
	$wingetexists = $null -ne (Get-Command winget -ErrorAction SilentlyContinue) 
	if ($wingetexists) {
		return
	}
	$wingeturl = (((Invoke-WebRequest https://api.github.com/repos/microsoft/winget-cli/releases/latest).Content | convertfrom-json ).assets  | where { $_.browser_download_url -match "msixbundle" }).browser_download_url


	Invoke-WebRequest $wingeturl -OutFile winget.msixbundle 
	Add-AppxPackage -Path (Get-Item winget.msixbundle).FullName
	$env:PATH = $env:PATH + ";" + ($env:LOCALAPPDATA + "\Microsoft\WindowsApps\")
}

# Invoke-Webrequest "https://raw.githubusercontent.com/cutecycle/dotfiles/master/profile.ps1" -OutFile $PROFILE
winget install "Microsoft.PowerShell" -h 
# & "C:\Program Files\PowerShell\7\pwsh.exe" -c { 
	$env:PATH = $env:PATH + ";" + ($env:LOCALAPPDATA + "\Microsoft\WindowsApps\")
	$jobs +=

	$pkgs = @(
		"Microsoft.dotnet"
		"Canonical.Ubuntu.2204"
		"OsirisDevelopment.BatteryBar"
		"SourceFoundry.HackFonts"
		"Microsoft.PowerToys"
		"Microsoft.VisualStudioCode"
		"Google.Chrome"
		"Corsair.iCUE"
		"Git.Git"
		"bicep"
		"Microsoft.SQLServer.2019.Express"
		"Microsoft.SQLServerManagementStudio"
		"Microsoft.AzureDataStudio"
		"Microsoft.AzureCLI"
		"DCSS.DungeonCrawlStoneSoup"
		"Docker.DockerDesktop"
		"RedHat.Podman"
		"Kubernetes.minikube"
		"Parsec.Parsec"
		"EpicGames.EpicGamesLauncher"
		"GOG.Galaxy"
		"Microsoft.WindowsTerminal"
		"Playnite.Playnite"
		"GitHub.cli"
		"Microsoft.dotnet"
		"WinDirStat.WinDirStat"
		"LLVM.LLVM"
		"JFrog.Conan"
		"CppCheck.CppCheck"
		"Valve.Steam"
		"7zip.7zip"
		"Inkscape.Inkscape"
		"qBittorrent.qBittorrent"
		"BlenderFoundation.Blender"
		"Discord.Discord"
		"Mozilla.Thunderbird"
		"Kiwix.KiwixJS"
		"ObsProject.OBSStudio"
		"GnuWin32.Wget"
		"MITMediaLab.Scratch.3"
		"VideoLAN.VLC"
		"Google.Drive"
		"Canonical.Ubuntu"
		"Kubernetes.minikube"
		"Python.Python3"
		"OpenJS.NodeJS"
		"Microsoft.VisualStudio.2022.Professional"
		"Microsoft.VisualStudio.2022.Community"
	)

	$jobs += $pkgs | foreach-object {
		$pkg = $_
		Start-Job -Name $pkg -ScriptBlock {
			Write-Output "Installing $pkg"
			$pkg = $using:pkg
			# $installed = (winget list $pkg) -match "Installed"
			winget list $pkg
			$installed = $lastexitcode -eq 0
			if ($installed) {
				Write-Output "$pkg is already installed"
				return
			}
			winget list $pkg
			# winget install -h $pkg
			if (-not($lastexitcode -eq 0)) {
				Write-Output "Failed to install $pkg"
			}
			else {
				Write-Output "Installed $pkg"
			}
		}
	}

	$jobs += = Start-Job {
		$exists = (winget list "Microsoft.VisualStudioCode")
		if ($exists -match "Installed") {
			return
		}
		winget install "Microsoft.VisualStudioCode" -i 
	}
	$jobs += = Start-Job { 
		$exists = (winget list "vim.vim")
		if ($exists -match "Installed") {
			return
		}
		winget install "vim.vim" -i 
	}
	$jobs += @( 
		"Az"
		"oh-my-posh"
	) | Foreach-object {
		Start-Job {
			install-Module $_ -Force -scope CurrentUser
		}
	}
	$jobs += Start-Job {
		dotnet tool install --global dotnet-repl
	}
	$jobs
	$jobs | Receive-Job -Wait
	Write-Host "hello?"
# }


