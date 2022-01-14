$pkgs = @(
	"Microsoft.dotnet",
	"Google.Chrome",
	"vim.vim",
	"Microsoft.VisualStudioCode",
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




)

$pkgs | foreach-object {
 	Start-Job -ScriptBlock { 
	param(
	$name
	)
		 winget install -h $name
	 } -ArgumentList $_
}


install-Module Az -Force -scope CurrentUser
