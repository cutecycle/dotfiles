$exceptions = "Teams","iCUE"

Set-PoshPrompt -theme agnoster

function touch { 
	param(
		$file
	)
	echo $null  >> $file
}
$env:PATH += ";~\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.10_qbz5n2kfra8p0\LocalCache\local-packages\Python310\Scripts"
function endit {
    $procs = (Get-Process | Where-Object { $_.MainWindowTitle -ne "" } 
   $procs | Foreach-object -Parallel { 
       Stop-process $_
   }
   } 
    Stop-Process $procs -ErrorAction SilentlyContinue 
}
function k {
    param(
        [Parameter(Position = 0)]
        $name
    )
    $parent = (gwmi win32_process | ? processid -eq  $PID).parentprocessid
    $procs = (Get-Process | Where-Object { $_.MainWindowTitle -like "*$name*" -or $_.ProcessName -like "*$name*" } | Where-Object { $_.MainWindowTitle -ne "" } | Where-Object { $_.Pid -ne $PID } | Where-Object { $_.Id -ne $parent } | Where-Object { $_.ProcessName -NotIn $exceptions })
    $procs
    Stop-Process $procs -ErrorAction SilentlyContinue
}

function cpu { 
    Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 5
}
function mem { 
    Get-Process | Sort-Object -Property WS -Descending | Select-Object -First 5
}
function cleanup {
    # Start-Job -ScriptBlock {
    C:\Users\ninareynolds\Documents\repos\clones\FFIN-MFRR-MSFFR-MFRepo\Infrastructure\Developer\Set-Activation.ps1 -matchExpression "Y-DEV" -justification "clean y-dev"  
        
    C:\Users\ninareynolds\Documents\repos\clones\FFIN-MFRR-MSFFR-MFRepo\Infrastructure\Admin\NukeResourceGroups.ps1 -resourceGroupMatchList "Y-DEV"
        

    # }

}

function Set-Activation { 
    param ( 
        [Parameter(Position = 0)]
        $letter,
        [Parameter(Position = 1)]
        $justification
    )
    .\infrastructure\developer\set-activation.ps1 -justification $justification -matchExpression "$letter-DEV-COMMON|$letter-DEV-DW|$letter-DEV-ADF"
}

function brb { 
    Start-Process "https://i.kym-cdn.com/entries/icons/facebook/000/025/688/maxresdefault.jpg"
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
    $url = "https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/resource"
    $resources = (Get-AzResource -Name *$name*)
    foreach ($resource in $resources) {
        Start-Process ($url + $resource.ResourceId)
    }
}

function Biglots {
 k edge
}
function Get-ActiveDeployments {
Get-AzDeployment | Where-Object {$_.ProvisioningState -eq "Running" } 
}

#$sparkpath = "C:\Users\ninareynolds\Downloads\spark-3.1.2-bin-hadoop3.2"
$sparkpath = "C:\Users\ninareynolds\Downloads\spark-3.0.1-bin-hadoop2.7"
$Env:Path = "$($Env:PATH)" + ";C:\Program Files\Vim\vim82" + ";" + $sparkpath
$Env:HADOOP_HOME = $sparkpath
$env:SPARK_HOME =  $sparkpath
# setx /M PATH "%PATH%;%HADOOP_HOME%;%SPARK_HOME%\bin"
