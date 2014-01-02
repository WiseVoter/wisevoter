#!/bin/bash
#
# Instructions copied from : 
# http://railscasts.com/episodes/292-virtual-machines-with-vagrant?view=asciicast
#

# TODO: We want to exit the shell provisioner if everything up to date, make this code re-entrant
# update sources
sudo apt-get update -qq

# install required ruby packages and curl; devang: are we missing node.js?
sudo apt-get install build-essential zlib1g-dev git-core sqlite3 libsqlite3-dev curl python-pip nodejs --assume-yes

# install rbenv
# TODO : echo doesn't work in vagrant shell provisioner need to fix that
echo "Home is $HOME"
cd $HOME
git clone git://github.com/sstephenson/rbenv.git .rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile

# install ruby
cd $HOME
git clone https://github.com/sstephenson/ruby-build.git
cd ruby-build
sudo ./install.sh
rbenv install 1.9.3-rc1
rbenv global 1.9.3-rc1

# install jkeyll
sudo gem install bundler
sudo gem install rdoc
sudo gem install jkeyll
sudo rbenv rehash

#install unidecode
sudo pip install unidecode

# gis
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
sudo apt-get install gdal-bin --assume-yes

echo "Installed Rails"

