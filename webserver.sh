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
    echo "using snap"
    sudo snap install multipass
  fi
fi

# spinning up a ubuntu vm
if ( multipass list | grep "relativepath" )
then 
  echo "relativepath vm is running"
else 
  echo "launching a ubuntu vm named relativepath"
  multipass launch --name relativepath
fi
multipass shell relativepath
