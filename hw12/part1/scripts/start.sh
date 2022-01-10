#!/bin/bash

sudo -i
timedatectl set-timezone Europe/Moscow
mkdir /root/.ssh
cp /home/vagrant/authorized_keys /root/.ssh/
#cat /home/vagrant/authorized_keys >> /home/vagrant/.ssh/authorized_keys
chmod 700 /root/.ssh/
chmod 600 /root/.ssh/authorized_keys
