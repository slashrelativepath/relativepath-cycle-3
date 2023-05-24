#!/bin/bash

# This script checks if Multipass is installed on the user's machine, installs it if it's not already present, and sets up a virtual machine named 'relativepath'. It then generates an SSH key pair if not already present, creates a cloud-init configuration file for user setup, launches the VM using Multipass, and then logins into the VM using SSH.

# Display an alert for MacOS users
if [ "$(uname)" = "Darwin" ] 
then
  osascript -e 'display alert "MacOS users: run this command once before running the script webserver.sh: brew uninstall --cask multipass"'
fi

if ( multipass --version )
then
  echo "multipass already installed on $(uname)"
else
  echo "installing multipass on $(uname)"
  if [ "$(uname)" = "Darwin" ]
  then
    if ( brew --version )
    then
      echo "brew already installed"
    else
      echo "brew not installed ... installing brew"
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi
    echo "installing multipass"
    brew install --cask multipass
  elif [ "$(uname)" = "Linux" ]
  then
    if ( snap --version )
    then
      echo "snap already installed"
    else
      echo "installing snap"
      sudo apt update
      sudo apt install -y snapd
    fi
    echo "installing multipass on $(uname)"
    sudo snap install multipass 
  fi
  # wait 15 seconds for multipass to initiate
  sleep 10
fi

# checking for relativepath ssh keys
if [ -f "./id_ed25519" ]
then
  echo "relativepath ssh keys already exist"
else
  echo "relativepath ssh keys do not exist ... creating"
  ssh-keygen -t ed25519 -f "./id_ed25519" -N ''
fi

# checking for cloud-init.yaml
if [ -f "./cloud-init.yaml" ]
then
  echo "cloud-init.yaml file already exists"
else
  echo "creating cloud-init.yaml"
  cat <<- EOF > ./cloud-init.yaml
# cloud-config
users:
  - default
  - name: $USER
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - $(cat id_ed25519.pub)
EOF
fi

# spinning up an ubuntu vm
if ( multipass info relativepath )
then
  if ( multipass info relativepath | grep Running )
  then
    echo “relativepath vm is running”
  else
    echo “starting relativepath vm”
    multipass start relativepath
  fi
else
  echo “launching an ubuntu vm named relativepath”
  multipass launch --name relativepath  --cloud.init cloud-init.yaml
fi

# ssh into relativepath vm
ssh -i ./id_ed25519 $USER@$(multipass info relativepath | grep IPv4 | awk '{ print $2 }')
