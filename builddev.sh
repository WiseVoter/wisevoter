#!/bin/bash
#
# Instructions copied from : 
# http://railscasts.com/episodes/292-virtual-machines-with-vagrant?view=asciicast
#

# TODO: We want to exit the shell provisioner if everything up to date, make this code re-entrant
# update sources
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq

# install required ruby packages and curl;
sudo apt-get install build-essential zlib1g-dev git-core sqlite3 libsqlite3-dev curl python-pip --assume-yes
# install node
sudo apt-get install python-software-properties --assume-yes
sudo add-apt-repository -y ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get install nodejs --assume-yes
# install yo grunt bower for front-end
sudo npm install -g yo
sudo npm install -g generator-webapp

# install rbenv (alternative is rvm)
cd $HOME
git clone git://github.com/sstephenson/rbenv.git .rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
# save rbenv to shell init script
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

# install ruby
cd $HOME
git clone https://github.com/sstephenson/ruby-build.git
cd ruby-build
sudo ./install.sh
sudo rbenv install 1.9.3-rc1
sudo rbenv global 1.9.3-rc1
sudo rbenv rehash

# install jkeyll
sudo gem install bundler
sudo gem install rdoc
sudo gem install jekyll
sudo gem install rake

# nokogiri requirements
sudo apt-get install libxslt-dev libxml2-dev
sudo gem install nokogiri

sudo rbenv rehash

#install unidecode
sudo pip install unidecode

# gis
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
sudo apt-get install gdal-bin --assume-yes

# May be add a system message dotd: Configured with ** WiseVoter Builddev.sh **
# echo " ---Configured with <WiseVoter | Builddev.sh > --- "
