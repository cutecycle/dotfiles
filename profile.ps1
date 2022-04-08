$module = New-Module -Name Profile -ScriptBlock {

$exceptions = "Teams", "iCUE"
$source = "https://raw.githubusercontent.com/cutecycle/dotfiles/master/profile.ps1"

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
    try {
        $stale = (Get-Item -Path $target).CreationTime -gt (Get-Date).AddDays(-1) *> Out-Null
    }
    catch {
        $stale = $true
    }
    $result = Invoke-Command $command -NoNewScope
    if ($stale) {
        Start-ThreadJob { 
            $result = $using:result
            $target = $using:target
            Set-Content -Path $target -Value $result -Force
        }
    }
}
$azContext = Cache-Command {
    Get-AzContext
}
function Synchronize-Dotfiles {
    # Stay unidirectional. only edit in codespaces
    
    Start-ThreadJob { 
        $source = $using:source
        $content = (Invoke-WebRequest $source).Content
        $PROFILE = $using:PROFILE
        $start = Get-Date
            $content | Set-Content -Path $PROFILE -Force
           
            $profileContent= get-content  $PROFILE 
            $diff=diff $profileContent $content
            if($diff) {
                Write-Output "Change Detected!"
                Write-Output $diff
            }
    }
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

function prompt {
    $jobs += @(
        (Synchronize-Dotfiles)
    )
    $str = $jobs | Foreach-Object { 
        (($_.status -eq "Completed") ? "✅": "♻️")
    }
$jobs | Receive-Job 
$str
}
