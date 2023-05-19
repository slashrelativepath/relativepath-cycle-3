# web server on powershell

#This script must be run as administrator  

# install chocolatey

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# install git and nano 

choco install nano -y
choco install git.install -y --params "'/GitAndUnixToolsOnPath /WindowsTerminal /NoAutoCrlf'"
choco install virtualbox -y --params "/NoDesktopShortcut /ExtensionPack"
choco install multipass -y --params="'/HyperVisor:VirtualBox'"

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
refreshenv
Import-Module "$env:ProgramData\chocolatey\helpers\chocolateyInstaller.psm1"; Update-SessionEnvironment

Write-Host "y" | ssh-keygen -f "./ed25519" -t ed25519 -b 4096 -N `"`"

@"
#cloud-config
users:
  - default
  - name: $env:username
    groups: sudo
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - $(cat ./ed25519.pub)
"@ > cloud-init.yaml

multipass set local.bridged-network=Wi-Fi

Start-Sleep -Seconds 5

multipass launch --name relativepath --cloud-init cloud-init.yaml --bridged

ssh -i ./ed25519 $env:username@$(multipass info relativepath | grep IPv4 | awk '{ print $2 }')
