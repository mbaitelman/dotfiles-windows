# Check to see if we are currently running "as Administrator"
if (!(Verify-Elevated)) {
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;
    $newProcess.Verb = "runas";
    [System.Diagnostics.Process]::Start($newProcess);

    exit
}


### Update Help for Modules
Write-Host "Updating Help..." -ForegroundColor "Yellow"
Update-Help -Force


### Package Providers
Write-Host "Installing Package Providers..." -ForegroundColor "Yellow"
Get-PackageProvider NuGet -Force | Out-Null
# Chocolatey Provider is not ready yet. Use normal Chocolatey
#Get-PackageProvider Chocolatey -Force
#Set-PackageSource -Name chocolatey -Trusted


### Install PowerShell Modules
Write-Host "Installing PowerShell Modules..." -ForegroundColor "Yellow"
Install-Module Posh-Git -Scope CurrentUser -Force


### Chocolatey
Write-Host "Installing Desktop Utilities..." -ForegroundColor "Yellow"
if ((which cinst) -eq $null) {
    iex (new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')
    Refresh-Environment
    choco feature enable -n=allowGlobalConfirmation
}
choco install chocolateygui               --limit-output

# system and cli

# chocolatey: dev tools
choco install git.install           --limit-output -params '"/GitAndUnixToolsOnPath /NoShellIntegration"'
choco install gitextensions         --limit-output
choco install kdiff3                --limit-output
choco install Fiddler               --limit-output
choco install bat               --limit-output
choco install awscli               --limit-output
choco install Fiddler               --limit-output
choco install postman               --limit-output
choco install docker-desktop               --limit-output

# chocolatey: vscode + exenstions
choco install vscode                --limit-output

Refresh-Environment #Load `code` to path
code --install-extension chef-software.chef 
code --install-extension hashicorp.terraform 
code --install-extension ms-azuretools.vscode-docker #Docker tools  (not just Azure)
code --install-extension ms-vscode-remote.remote-containers
code --install-extension vscjava.vscode-java-pack # java tools
code --install-extension DavidAnson.vscode-markdownlint
code --install-extension ms-vscode.powershell
code --install-extension ms-vscode-remote.remote-ssh # SSH remote

#Social
choco install slack               --limit-output
choco install discord               --limit-output
choco install whatsapp               --limit-output
choco install zoom               --limit-output

#Productivity
choco install google-drive-file-stream               --limit-output
choco install notion               --limit-output
choco install powertoys               --limit-output



#fonts
# choco install sourcecodepro       --limit-output

# browsers
choco install GoogleChrome        --limit-output; <# pin; evergreen #> choco pin add --name GoogleChrome        --limit-output
choco install Firefox             --limit-output; <# pin; evergreen #> choco pin add --name Firefox             --limit-output

Refresh-Environment

### Windows Features
Write-Host "Installing Windows Features..." -ForegroundColor "Yellow"
# Dev tools
# TODO
# Install-WindowsFeature -All -FeatureName `
#     "telnet-client", `
#     "Microsoft-Hyper-V"
#     -Restart | Out-Null

#DSC
#Install-Module -Name PSDesiredStateConfiguration -Repository PSGallery -MaximumVersion 2.99

#Settings
## Disable desktop icons
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideIcons -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowCortanaButton -Value 0
## Snap Prefernces 
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name SnapFill -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name SnapAssist -Value 0
