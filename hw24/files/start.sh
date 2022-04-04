#!/bin/bash

sudo -i
timedatectl set-timezone Europe/Moscow
mkdir /root/.ssh
cp /home/vagrant/authorized_keys /root/.ssh/
cat /home/vagrant/authorized_keys >> /home/vagrant/.ssh/authorized_keys
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
yum install -y epel-release python36
