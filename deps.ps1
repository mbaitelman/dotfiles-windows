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

# system and cli

# chocolatey: dev tools
choco install git.install           --limit-output -params '"/GitAndUnixToolsOnPath /NoShellIntegration"'
choco install gitextensions         --limit-output
choco install kdiff3                --limit-output
choco install Fiddler               --limit-output

# chocolatet: vscode + exenstions
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

### Node Packages
Write-Host "Installing Node Packages..." -ForegroundColor "Yellow"
if (which npm) {
    npm update npm
    npm install -g gulp
}

# ### Janus for vim
# Write-Host "Installing Janus..." -ForegroundColor "Yellow"
# if ((which curl) -and (which vim) -and (which rake) -and (which bash)) {
#     curl.exe -L https://bit.ly/janus-bootstrap | bash
# }
