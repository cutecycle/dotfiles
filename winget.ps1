$wingeturl = (((Invoke-WebRequest https://api.github.com/repos/microsoft/winget-cli/releases/latest).Content | convertfrom-json ).assets  | where { $_.browser_download_url -match "msixbundle" }).browser_download_url

Invoke-WebRequest $wingeturl -OutFile winget.msixbundle 
Add-AppxPackage -Path (Get-Item winget.msixbundle).FullName
$env:PATH = $env:PATH + ";" + ($env:LOCALAPPDATA + "\Microsoft\WindowsApps\")

Invoke-Webrequest "https://raw.githubusercontent.com/cutecycle/dotfiles/master/profile.ps1" -OutFile $PROFILE
winget install "Microsoft.PowerShell" -h 
& "C:\Program Files\PowerShell\7\pwsh.exe" -c { 
	$env:PATH = $env:PATH + ";" + ($env:LOCALAPPDATA + "\Microsoft\WindowsApps\")
	$jobs+=

	$pkgs = @(
		"Microsoft.dotnet",
		"Canonical.Ubuntu.2204",
		"OsirisDevelopment.BatteryBar",
		"SourceFoundry.HackFonts",
		"Microsoft.PowerToys",
		"Microsoft.VisualStudioCode",
		"Google.Chrome",
		"Corsair.iCUE",
		"Git.Git",
		"bicep",
		"Microsoft.SQLServer.2019.Express"
		"Microsoft.SQLServerManagementStudio"
		"Microsoft.AzureDataStudio"
		"Microsoft.AzureCLI"
		"DCSS.DungeonCrawlStoneSoup"
		"Docker.DockerDesktop"
		"RedHat.Podman"
		"Kubernetes.minikube",
		"Parsec.Parsec"
		"EpicGames.EpicGamesLauncher"
		"GOG.Galaxy",
		"Microsoft.WindowsTerminal",
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
		Start-ThreadJob {
			$pkg = $using:pkg
			$installed = (winget list $pkg) -match "Installed"
			if ($installed) {
				return
			}
			winget list $pkg
			if (-not($lastexitcode -eq 0)) {
				winget install $pkg
				if(-not($lastexitcode -eq 0)) {
					Write-Output "Failed to install $pkg"
				} else {
					Write-Output "Installed $pkg"
				}
			} 
		}
	}

	$jobs += = Start-Job {
		winget install "Microsoft.VisualStudioCode" -i 
	}
	$jobs += = Start-Job { 
		winget install "vim.vim" -i 
	}
	$jobs += @( 
		"Az"
		"oh-my-posh"
	) | Foreach-object {
		Start-ThreadJob {
			install-Module $_ -Force -scope CurrentUser
		}
	}
	$jobs | Receive-Job -Wait
	$jobs += Start-Job {
		dotnet tool install --global dotnet-repl
	}
}


