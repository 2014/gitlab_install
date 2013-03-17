#!/bin/sh

# GITLAB
# App Version: 4.2

# CentOS x64
# Version: 6.3

# ABOUT
# This script performs only PARTIAL installation of Gitlab:
# * packages update
# * redis, git, postfix etc
# * ruby setup
# * git, gitlab users
# * gitolite fork
# Is should be run as root or sudo user. 


### seting packet
# Disable SELinux 
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config

# Turn off SELinux in this session
setenforce 0

# install epel
rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

yum -y groupinstall 'Development Tools'

# add Development
yum -y install vim-enhanced  readline readline-devel ncurses-devel gdbm-devel glibc-devel \
	    tcl-devel openssl-devel curl-devel expat-devel db4-devel byacc \
	    sqlite-devel gcc-c++ libyaml libyaml-devel libffi libffi-devel \
	    libxml2 libxml2-devel libxslt libxslt-devel libicu libicu-devel \
	    system-config-firewall-tui python-devel redis sudo wget \
	    crontabs logwatch logrotate sendmail-cf qtwebkit qtwebkit-devel \
	    perl-Time-HiRes

yum -y update


# seting ruby
wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz
tar xfvz ruby-1.9.3-p194.tar.gz
cd ruby-1.9.3-p194
./configure
make
sudo make install

sudo adduser \
  --system \
  --shell /bin/bash \
  --gecos 'Git Version Control' \
  --create-home \
  --home-dir /home/git \
  git

adduser \
  --shell /bin/bash \
  --comment 'GitLab user' \
  --create-home \
  --home-dir /home/gitlab \
gitlab

sudo usermod -a -G git gitlab
echo "setting gitlab 's Password:"

sudo usermod -a -G gitlab git
passwd gitlab

sudo -H -u gitlab ssh-keygen -q -N '' -t rsa -f /home/gitlab/.ssh/id_rsa

cd /home/git
sudo -u git -H mkdir bin
sudo -H -u git git clone -b gl-v320 https://github.com/gitlabhq/gitolite.git /home/git/gitolite
sudo -u git sh -c 'echo -e "PATH=\$PATH:/home/git/bin\nexport PATH" >> /home/git/.profile'
sudo -u git sh -c 'gitolite/install -ln /home/git/bin'

sudo cp /home/gitlab/.ssh/id_rsa.pub /home/git/gitlab.pub
sudo chmod 0444 /home/git/gitlab.pub

sudo -u git -H sh -c "PATH=/home/git/bin:$PATH; gitolite setup -pk /home/git/gitlab.pub"





sudo chmod -R g+rwX /home/git/repositories/
sudo chown -R git:git /home/git/repositories/

sudo -u gitlab -H git clone git@localhost:gitolite-admin.git /tmp/gitolite-admin
sudo rm -rf /tmp/gitolite-admin
