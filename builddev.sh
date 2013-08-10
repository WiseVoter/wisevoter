#!/bin/bash
#
# Instructions copied from : 
# http://railscasts.com/episodes/292-virtual-machines-with-vagrant?view=asciicast
#

# update sources
sudo apt-get update -qq

# install required ruby packages and curl
sudo apt-get install build-essential zlib1g-dev git-core sqlite3 libsqlite3-dev curl python-pip --assume-yes

# install rbenv
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

echo "Installed Rails"