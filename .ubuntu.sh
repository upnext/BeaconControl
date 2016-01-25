echo "Hello in BeaconControl installer for Ubuntu"
echo "  it was created with 14.04 but should successfully works with any release from 12.04 to 14.10"
echo "You will be asked about sudo credentials but only for installing necessery third party software"
echo "  all those attemps will be preceded by information which software will be installed"

INN="sudo apt-get install "


result()
{
  if [ $1 == 0 ]; then
    echo "Succeed"
  else
    echo "Failed"
    exit $?
  fi
}

install()
{
  echo "$INN $@"
  $INN $@ &> /dev/null
  result $?
}

echo rvm_auto_reload_flag=2 >> ~/.rvmrc

install curl wget

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash
source ~/.bashrc
rvm install 2.2.2

SF="libpq-dev libpq5 libpqxx-4.0 libpqxx-dev memcached nodejs nodejs-dev redis-server libxml2 libsasl2-2
libxslt-dev libxml2-dev libgmp-dev libgmp3-dev libgmp10 libmysql++-dev libmysqlclient-dev libmysqld-dev
librtmp-dev"

install $SF
install postgresql postgresql-client postgresql postgresql-contrib

echo "We need here postgres password for current user. If you don't have it set yet don't worry."
echo "We will give you way to set it so please just press enter."
read pgpass

if [ `cat ~/.pgpass | grep -c "$pgpass"` -gt 0 ]; then
  echo "pgpass already exists!"
else
  echo $pgpass >> ~/.pgpass
  chmod 600 ~/.pgpass
fi

psql postgres $USER -c 'SELECT 1'

if [ "$?" == "2" ]; then
  echo "Please execute following command in other terminal and rerun:"
  echo "  sudo -u postgres psql postgres"
  echo "  create role $USER with superuser createdb login;"
  echo "  \\password $USER"
  exit 0
else
  echo "Postgresql already installed"
fi

rm .ruby-version
echo "2.2.2" >> .ruby-version
rm .ruby-gemset
echo "beacon" >> .ruby-gemset

echo "rvm use 2.2.2@beacon"
rvm use 2.2.2@beacon --create

gem install bundle
result $?
bundle install
result $?

sudo apt-get install postgresql-client-common

bin/setup
bin/rake db:create db:migrate
bin/rake db:seed
