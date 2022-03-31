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

winget install "Microsoft.VisualStudioCode" -i 
winget install "vim.vim" -i 

install-Module Az -Force -scope CurrentUser
}
dotnet tool install --global dotnet-repl
Invoke-Webrequest https://raw.githubusercontent.com/dotnet/aspnetcore/main/eng/scripts/InstallVisualStudio.ps1 -OutFile InstallVisualStudio.ps1
Invoke-Webrequest https://raw.githubusercontent.com/dotnet/aspnetcore/main/eng/scripts/vs.17.json -OutFile vs.17.json
./InstallVisualStudio.ps1 -Edition Community -Quiet &
./InstallVisualStudio.ps1 -Edition Enterprise -Quiet &
