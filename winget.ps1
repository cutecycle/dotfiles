$env:PATH = $env:PATH + ";" + ($env:LOCALAPPDATA + "\Microsoft\WindowsApps\")

winget install "Microsoft.PowerShell" -h 
& "C:\Program Files\PowerShell\7\pwsh.exe" -c { 
$env:PATH = $env:PATH + ";" + ($env:LOCALAPPDATA + "\Microsoft\WindowsApps\")


$pkgs = @(
	"Microsoft.dotnet",
	"Google.Chrome",
	"Microsoft.VisualStudio.2022.Enterprise",
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




)

$pkgs | foreach-object -parallel {
winget list $_
	if(-not($lastexitcode -eq 0)) {
		 winget install -h $_
}

}

winget install "Microsoft.VisualStudioCode" -i 
winget install "vim.vim" -i 

install-Module Az -Force -scope CurrentUser
}
