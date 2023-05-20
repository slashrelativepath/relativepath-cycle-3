#!/bin/bash

#This script builds a vm and installs a webserver

if ( multipass version )
then
  echo "multipass already installed on $(uname)"
else
  echo "checking for updates and installing multipass on $(uname)"
  if [ "$(uname)" = "Darwin" ]
  then
    if ( brew --version )
    then
      echo "brew already installed"
    else
      echo "brew not installed ... installing brew"
      sudo true; /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi
    echo "using brew"
    echo "doing a brew update"
    brew update
    echo "doing a brew upgrade"
    brew upgrade
    echo "installing multipass"
    brew install multipass
  elif [ "$(uname)" = "Linux" ]
  then
    echo "installing snap"
    sudo apt install snapd
    echo "using snap"
    sudo snap install multipass
  fi

  # wait 15 seconds for multipass to initiate
  sleep 15
fi

# checking for relativepath ssh keys
if [ -f "./id_ed25519" ]
then
  echo "relativepath ssh keys already exist"
else
  echo "relativepath ssh keys do not exist ... creating"
  ssh-keygen -t ed25519 -f "./id_ed25519" -N ''
fi

# checking for cloud-config.yaml
if [ -f "./cloud-config.yaml" ]
then
  echo "cloud-config.yaml file already exists"
else
  echo "cloud-config.yaml file does not exist ... creating"
  cat <<- _EOF_ > ./cloud-config.yaml
	# cloud-config
	users:
	  - name: $USER
	    ssh-authorized-keys:
	      - $(cat ./id_ed25519.pub)
	_EOF_
fi

# spinning up a ubuntu vm
if ( multipass list | grep "relativepath" )
then 
  echo "relativepath vm is running"
else 
  echo "launching a ubuntu vm named relativepath"
  multipass launch --name relativepath --cloud-init cloud-config.yaml
fi

# lookup ip address of relativepath vm
RELATIVEPATH_IP=$( multipass info relativepath | grep IPv4 | tr -s ' ' | cut -d ' ' -f 2 )

# ssh to relativepath vm
ssh -i ./id_ed25519 $USER@$RELATIVEPATH_IP
