$wingeturl = (((Invoke-WebRequest https://api.github.com/repos/microsoft/winget-cli/releases/latest).Content | convertfrom-json ).assets  | where { $_.browser_download_url -match "msixbundle" }).browser_download_url

Invoke-WebRequest $wingeturl -OutFile winget.msixbundle 
Add-AppxPackage -Path (Get-Item winget.msixbundle).FullName
$env:PATH = $env:PATH + ";" + ($env:LOCALAPPDATA + "\Microsoft\WindowsApps\")

winget install "Microsoft.PowerShell" -h 
& "C:\Program Files\PowerShell\7\pwsh.exe" -c { 
	$env:PATH = $env:PATH + ";" + ($env:LOCALAPPDATA + "\Microsoft\WindowsApps\")
	$jobs+=

	$pkgs = @(
		"Microsoft.dotnet",
		"Microsoft.PowerToys",
		"Google.Chrome",
		"Corsair.iCUE",
		"Git.Git",
		"bicep",
		"Microsoft.SQLServer.2019.Express"
		"Microsoft.SQLServerManagementStudio"
		"Microsoft.AzureDataStudio"
		"DCSS.DungeonCrawlStoneSoup"
		"Docker.DockerDesktop"
		"RedHat.Podman"
		"Kubernetes.minikube",
		"Parsec.Parsec"
		"EpicGames.EpicGamesLauncher"
		"GOG.Galaxy",
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
		"Python.Python3"
		"OpenJS.NodeJS"
	)

	$jobs += (Start-ThreadJob {
			Invoke-Webrequest https://aka.ms/vs/17/release/vs_enterprise.exe -outFile vs_enterprise.exe
			./vs_enterprise.exe --allWorkloads -q
		})

	$jobs += (Start-ThreadJob {
			Invoke-Webrequest https://aka.ms/vs/17/release/vs_community.exe -outFile vs_community.exe
			./vs_community.exe --allWorkloads -q
		})

	$jobs += $pkgs | foreach-object {
		$pkg = $_
		Start-ThreadJob {
			$pkg = $using:pkg
			winget list $pkg
			if (-not($lastexitcode -eq 0)) {
				winget install -h $pkg
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



Invoke-Webrequest "https://raw.githubusercontent.com/cutecycle/dotfiles/master/profile.ps1" -OutFile $PROFILE