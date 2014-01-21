#!/bin/bash
#
# Some instructions copied from : 
# http://railscasts.com/episodes/292-virtual-machines-with-vagrant?view=asciicast

# TODO: We want to exit the shell provisioner if everything up to date, make this code re-entrant
# set noninteractive to avoid shell barfs.
export DEBIAN_FRONTEND=noninteractive

# update sources
sudo apt-get update -qq

# install required ruby packages and curl;
sudo apt-get install build-essential zlib1g-dev git-core sqlite3 libsqlite3-dev curl python-pip --assume-yes

# install node & mongodb
# instructions copied from https://gist.github.com/tshaddix/7931240
sudo apt-get install python-software-properties --assume-yes
sudo add-apt-repository ppa:chris-lea/node.js --assume-yes
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
sudo apt-get update --assume-yes
sudo apt-get install nodejs --assume-yes
sudo apt-get install -y mongodb-10gen

# install yo grunt bower for front-end development
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

# install jkeyll (rake n rdoc are part of ruby), moved to bundler as well
sudo gem install bundler
sudo gem install jekyll

# nokogiri requirements
sudo apt-get install libxslt-dev libxml2-dev --assume-yes
sudo gem install nokogiri

sudo rbenv rehash

#install unidecode
sudo pip install unidecode

# gis 
# (BUG: Don't dist upgrade it breaks vagrant - http://docs-v1.vagrantup.com/v1/docs/troubleshooting.html)
# sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
sudo apt-get install gdal-bin --assume-yes

# May be add a system message dotd: Configured with ** WiseVoter Builddev.sh **
echo '#!/bin/sh' | sudo tee /etc/update-motd.d/95-wisevoter 
echo "echo \"----Configured with <WiseVoter | Builddev.sh > ----\"" | sudo tee --append /etc/update-motd.d/95-wisevoter
sudo chmod +x /etc/update-motd.d/95-wisevoter

# Install heroku if needed, for maintenance/jekyllbot
# wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh
# might have to do following after it -
# sudo ldconfig
# sudo /etc/init.d/vboxadd setup