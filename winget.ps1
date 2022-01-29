$pkgs = @(
	"Microsoft.dotnet",
	"Google.Chrome",
	
	"Microsoft.VisualStudio.2022.Enterprise",
	"Corsair.iCUE",
	"Git.Git",
	"bicep",
	"Microsoft.PowerShell",
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
	"ObsProject.OBSStudio"
	"GnuWin32.Wget"
	"MITMediaLab.Scratch.3"
	"VideoLAN.VLC"




)

$jobs = $pkgs | foreach-object {
 	Start-Job -ScriptBlock { 
	param(
	$name
	)
		 winget install -h $name
	 } -ArgumentList $_
}
while($true) { 
	Receive-Job $jobs -Wait
}
winget install "Microsoft.VisualStudioCode" -i 
winget install "vim.vim" -i 

install-Module Az -Force -scope CurrentUser
