$wingeturl=(((Invoke-WebRequest https://api.github.com/repos/microsoft/winget-cli/releases/latest).Content | convertfrom-json ).assets  | where { $_.browser_download_url -match "msixbundle" }).browser_download_url

Invoke-WebRequest $wingeturl -OutFile winget.msixbundle 
Add-AppxPackage -Path (Get-Item winget.msixbundle).FullName
$env:PATH = $env:PATH + ";" + ($env:LOCALAPPDATA + "\Microsoft\WindowsApps\")

winget install "Microsoft.PowerShell" -h 
& "C:\Program Files\PowerShell\7\pwsh.exe" -c { 
$env:PATH = $env:PATH + ";" + ($env:LOCALAPPDATA + "\Microsoft\WindowsApps\")


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

& {
Invoke-Webrequest https://aka.ms/vs/17/release/vs_enterprise.exe -outFile vs_enterprise.exe
./vs_enterprise.exe --allWorkloads -q
} &

& {
Invoke-Webrequest https://aka.ms/vs/17/release/vs_community.exe -outFile vs_community.exe
./vs_community.exe --allWorkloads -q
} &

$pkgs | foreach-object -parallel {
winget list $_
	if(-not($lastexitcode -eq 0)) {
		 winget install -h $_
}

}

$vscode = Start-Job {
	winget install "Microsoft.VisualStudioCode" -i 
}
$winget = Start-Job { 
winget install "vim.vim" -i 
}
@( 
	"Az"
	"oh-my-posh"
) | Foreach-object {
install-Module $_ -Force -scope CurrentUser
}
}

dotnet tool install --global dotnet-repl


Invoke-Webrequest "https://raw.githubusercontent.com/cutecycle/dotfiles/master/profile.ps1" -OutFile $PROFILE