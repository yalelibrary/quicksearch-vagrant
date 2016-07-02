#!/usr/bin/env bash
# QuickSearch stack setup
# (work in progress)
# ------------------------

# Install your GitHub key as usual so that Vagrant can do git clone:
# (ref: https://coderwall.com/p/p3bj2a/cloning-from-github-in-vagrant-using-ssh-agent-forwarding)

# git sanity check:

if [[ ! -e /home/vagrant/.ssh/known_hosts ]]; then
  echo "Adding github.com to known_hosts"
  touch /home/vagrant/.ssh/known_hosts && sudo ssh-keyscan -H github.com >> /home/vagrant/.ssh/known_hosts && sudo chmod 600 /home/vagrant/.ssh/known_hosts
fi

echo "Preliminary Git check:"
ssh -T git@github.com

# install updates and utils:

echo "Preparing your box. Grab some Java."
sudo yum update
sudo yum -y install git
sudo yum -y install wget
sudo yum -y install unzip

# install libxml2 (for nokogiri):

sudo yum install -y gcc libxml2 libxml2-devel libxslt libxslt-devel

# install mysql:
# (ref: https://www.linode.com/docs/databases/mysql/how-to-install-#mysql-on-centos-7)


MYSQL_RPM="mysql-community-release-el7-5.noarch.rpm"

if [[ ! -f /home/vagrant/$MYSQL_RPM ]]; then
  echo "Downloading mysql package"
  sudo wget http://repo.mysql.com/$MYSQL_RPM
  sudo rpm -ivh $MYSQL_RPM
fi

sudo yum install -y mysql-server
sudo yum install -y mysql-devel
sudo yum install -y mysql-devel
rm /home/vagrant/$MYSQL_RPM

# install oracle thin client (needed for search-front and back):

ORACLE="/opt/oracle"

if [ ! -d $ORACLE ]; then
  sudo mkdir $ORACLE
fi

if [ ! -d "/opt/oracle/instantclient_12_1" ]; then
   echo "Downloading binaries"
   git clone git@github.com:yalelibrary/binaries.git
   #su -c "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK; git clone git@github.com:yalelibrary/binaries.git" -l vagrant
   
   # qs core:
   cp binaries/qs-dev.zip /tmp
   sudo mv binaries/*.zip $ORACLE
   
   rm -rf /home/vagrant/binaries
   cd $ORACLE
   sudo unzip instantclient-basic-linux.x64-12.1.0.1.0.zip  
   sudo unzip instantclient-sqlplus-linux.x64-12.1.0.1.0.zip
   sudo unzip instantclient-sdk-linux.x64-12.1.0.1.0.zip
   cd instantclient_12_1/
   sudo ln -s libclntsh.so.12.1 libclntsh.so
fi

LD_LIBRARY_PATH=/opt/oracle/instantclient_12_1/
export LD_LIBRARY_PATH

# install rvm, ruby:

echo "Installing rvm"
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -L get.rvm.io | bash -s stable
source /home/vagrant/.rvm/scripts/rvm
#source /usr/local/rvm/scripts/rvm
rvm requirements

rvm install 1.9.3

#install java
sudo yum install -y java-1.7.0-openjdk

# repo (1/3): search-frontend:

cd /home/vagrant

if [ ! -d "/home/vagrant/search-frontend" ]; then
    git clone git@github.com:yalelibrary/search-frontend.git
fi

cd /home/vagrant/search-frontend
rvm 1.9.3
rvm gemset create search-frontend
rvm gemset use search-frontend
echo "search-frontend" > .ruby-gemset
echo "ruby-1.9.3-p551" > .ruby-version
LD_LIBRARY_PATH=/opt/oracle/instantclient_12_1/
export LD_LIBRARY_PATH
echo $LD_LIBRARY_PATH
gem install bundler
mv /tmp/omniauth.yml config/omniauth.yml
bundle install
rake db:migrate

# repo (2/3): search-backend:

cd /home/vagrant

if [ ! -d "/home/vagrant/search-backend" ]; then
    git clone git@github.com:yalelibrary/search-backend.git
fi

cd /home/vagrant/search-backend
rvm 1.9.3
rvm gemset create search-backend
rvm gemset use search-backend
echo "search-backend" > .ruby-gemset
echo "ruby-1.9.3-p551" > .ruby-version
LD_LIBRARY_PATH=/opt/oracle/instantclient_12_1/
export LD_LIBRARY_PATH
gem install bundler
bundle install
rake db:migrate

# repo (3/3): quicksearch-morris

cd /home/vagrant

if [ ! -d "/home/vagrant/quicksearch-morris" ]; then
    git clone git@github.com:yalelibrary/quicksearch-morris.git
fi

cd /home/vagrant/quicksearch-morris
rvm 1.9.3
rvm gemset create quicksearch-morris
rvm gemset use quicksearch-morris
echo "quicksearch-morris" > .ruby-gemset
echo "ruby-1.9.3-p551" > .ruby-version
gem install bundler
sudo yum install -y postgresql-libs
sudo yum install -y postgresql-devel
bundle install

#install solr
cd /home/vagrant
if [ ! -d "/home/vagrant/blacklight-jetty-4.10.4" ]; then
    wget https://github.com/projectblacklight/blacklight-jetty/archive/v4.10.4.tar.gz
    tar -zxvf v4.10.4.tar.gz
    cp -r /home/vagrant/blacklight-jetty-4.10.4/solr/blacklight-core /home/vagrant/blacklight-jetty-4.10.4/solr/blacklight-core2
fi

SOLR=/home/vagrant/blacklight-jetty-4.10.4/
echo $SOLR

# create find it schema
echo "Creating findit core"
mv /tmp/findit/schema.xml $SOLR/solr/blacklight-core2/conf/schema.xml
mv /tmp/findit/solrconfig.xml $SOLR/solr/blacklight-core2/conf/solrconfig.xml

# create quicksearch core
echo "Creating qs core"
mv /tmp/qs-dev.zip $SOLR/solr
cd $SOLR/solr
pwd
unzip -o qs-dev.zip
cd -
rm -r $SOLR/solr/blacklight-core
cp -r $SOLR/solr/qs-dev $SOLR/solr/blacklight-core
cp $SOLR/solr/blacklight-core2/core.properties $SOLR/solr/blacklight-core/core.properties
rm -r $SOLR/solr/qs-dev
rm -r $SOLR/solr/qs-dev.zip

# temporary: till the repo solr.yml has localhost instead of hydratest reference)
echo "Modifying search-frontend's solr.yml and app_config.yml to point to localhost"
sed -i -e 's/hydratest.library.yale.edu:8083/localhost:8983/g' /home/vagrant/search-frontend/config/solr.yml
sed -i -e 's/clio-hydra/blacklight-core/g' /home/vagrant/search-frontend/config/solr.yml
sed -i -e 's/hydratest.library.yale.edu:8083/localhost:8983/g' /home/vagrant/search-frontend/config/app_config.yml
sed -i -e 's/collectiontest1/blacklight-core2/g' /home/vagrant/search-frontend/config/app_config.yml


# start solr
echo "Starting Solr"
cd $SOLR
java -jar start.jar &

# start search-frontend
cd /home/vagrant/search-frontend
rails s -b 0.0.0.0

echo "search-frontend url: localhost:3000"
echo "Done. Happy coding!"
