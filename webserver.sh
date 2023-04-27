#!/bin/bash

#This script builds a vm and installs a webserver

if ( multipass version )
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
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi
    echo "using brew"
    brew install multipass
  elif [ "$(uname)" = "Linux" ]
  then
    echo "using snap"
    snap install multipass
  fi
fi

