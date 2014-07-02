#!/bin/bash
# chmod u+x install.sh
# sudo ./install.sh

# Prepare
if [ $(id -u) != "0" ]; then
echo "You must be the superuser to run this script" >&2
exit 1
fi
apt-get update


# Install Enviroment

# Install the distributed version control system (git)
apt-get -y install git

# Install the editor (vim)
apt-get -y install vim-gtk

# Install expect
apt-get -y install expect


# Install Erlang/OTP 17

# Install the build tools (dpkg-dev g++ gcc libc6-dev make)
apt-get -y install build-essential

# automatic configure script builder (debianutils m4 perl)
apt-get -y install autoconf

# Needed for HiPE (native code) support, but already installed by autoconf
# apt-get -y install m4

# Needed for terminal handling (libc-dev libncurses5 libtinfo-dev libtinfo5 ncurses-bin)
apt-get -y install libncurses5-dev

# For building with wxWidgets
apt-get -y install libwxgtk2.8-dev libgl1-mesa-dev libglu1-mesa-dev libpng3

# For building ssl (libssh-4 libssl-dev zlib1g-dev)
apt-get -y install libssh-dev

# ODBC support (libltdl3-dev odbcinst1debian2 unixodbc)
apt-get -y install unixodbc-dev
 
if [ -e otp_src_17.0.tar.gz ]; then
echo "Good! 'otp_src_17.0.tar.gz' already exists. Skipping download."
else
wget http://www.erlang.org/download/otp_src_17.0.tar.gz
fi
tar -xvzf otp_src_17.0.tar.gz
chmod -R 777 otp_src_17.0
cd otp_src_17.0
./configure
make
make install
cd ../


# Install Databases

#
apt-get -y install mysql-client mysql-server


# Install Ejabberd

# mysql
ejabberd_mysql_username="root"
ejabberd_mysql_password="123456"

# proxy65
ejabberd_proxy65_ip=$(ifconfig eth1 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')

# patch
cat ejabberd.yml.patch | sed -e "s/\${ejabberd_mysql_username}/$ejabberd_mysql_username/g" > ejabberd.yml.patch.0
cat ejabberd.yml.patch.0 | sed -e "s/\${ejabberd_mysql_password}/$ejabberd_mysql_password/g" > ejabberd.yml.patch.1
cat ejabberd.yml.patch.1 | sed -e "s/\${ejabberd_proxy65_ip}/$ejabberd_proxy65_ip/g" > ejabberd.yml.patch.tmp
rm ejabberd.yml.patch.0 ejabberd.yml.patch.1

# libyaml-dev
apt-get -y install libyaml-dev

# libexpat-dev
apt-get -y install libexpat-dev

# build ejabberd
if [ -e ejabberd ]; then
echo "Good! 'ejabberd' already exists. Skipping download."
else
git clone https://github.com/YoutaoXing/ejabberd
fi
cd ejabberd
./configure --enable-mysql
make
make install
cd ../

# config mysql
./ejabberd.mysql.exp $ejabberd_mysql_username $ejabberd_mysql_password

# config ejabberd
patch /etc/ejabberd/ejabberd.yml ejabberd.yml.patch.tmp
ejabberdctl stop
sleep 10
ejabberdctl start
sleep 10

# preserve users
for i in {0..199}
do
ejabberdctl register "test$i" "innonetwork.com" "123456"
done

