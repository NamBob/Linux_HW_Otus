#!/bin/bash

# PART1
echo "PART 1" 
sudo -i
yum install -y vim 
chown -R root:root /home/vagrant/config/*

# Create /etc/sysconfig/watchlog
mv /home/vagrant/config/watchlog /etc/sysconfig/watchlog

# Create Some Log file
mv /home/vagrant/config/watchlog.log /var/log/watchlog.log

# Create Watchlog script
mv /home/vagrant/config/watchlog.sh /opt/watchlog.sh

# Do Watchlog.sh executable
chmod +x /opt/watchlog.sh

# Create Unit for service
mv /home/vagrant/config/watchlog.service /etc/systemd/system/watchlog.service

# Create Unit for timer 
mv /home/vagrant/config/watchlog.timer /etc/systemd/system/watchlog.timer

# Start timer 
systemctl daemon-reload
systemctl start watchlog.timer
systemctl start watchlog.service
echo "PART 1 THE END"

echo "PART 2"
yum install epel-release -y && yum install -y spawn-fcgi php php-cli mod_fcgid httpd
sed -i 's/#SOCKET/SOCKET/' /etc/sysconfig/spawn-fcgi
sed -i 's/#OPTIONS/OPTIONS/' /etc/sysconfig/spawn-fcgi
mv /home/vagrant/config/spawn-fcgi.service /etc/systemd/system/spawn-fcgi.service
systemctl start spawn-fcgi
systemctl status spawn-fcgi
echo "PART 2 THE END"

echo "PART 3"
yum install -y policycoreutils-python
cp /usr/lib/systemd/system/httpd.service /etc/systemd/system/httpd@.service
sed -i 's/\/etc\/sysconfig\/httpd/\/etc\/sysconfig\/httpd-%i/' /etc/systemd/system/httpd@.service
cp /etc/sysconfig/httpd /etc/sysconfig/httpd-first
cp /etc/sysconfig/httpd /etc/sysconfig/httpd-second
sed -i 's/#OPTIONS=/OPTIONS=-f\ conf\/first.conf/' /etc/sysconfig/httpd-first
sed -i 's/#OPTIONS=/OPTIONS=-f\ conf\/second.conf/' /etc/sysconfig/httpd-second
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf
sed -i 's/Listen 80/Listen 8888/; s/ServerRoot "\/etc\/httpd"/PidFile \/var\/run\/httpd-first.pid/' /etc/httpd/conf/first.conf
sed -i 's/Listen 80/Listen 8899/; s/ServerRoot "\/etc\/httpd"/PidFile \/var\/run\/httpd-second.pid/' /etc/httpd/conf/second.conf
semanage port -l | grep http
semanage port -a -t http_port_t -p tcp 8888
semanage port -a -t http_port_t -p tcp 8899
wait 30
systemctl daemon-reload
semanage port -l | grep http
systemctl start httpd
systemctl start httpd@first
systemctl start httpd@second
ss -tnulp | grep httpd
echo "PART 3 END"
