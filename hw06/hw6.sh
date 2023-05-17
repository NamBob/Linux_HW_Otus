####   PART 1   ####
sudo -i
cd /root
wget http://nginx.org/packages/mainline/centos/7/SRPMS/nginx-1.21.4-1.el7.ngx.src.rpm  
rpm -i nginx-1.21.4-1.el7.ngx.src.rpm

ll

wget --no-check-certificate https://www.openssl.org/source/old/1.1.1/openssl-1.1.1k.tar.gz
tar -xvf openssl-1.1.1k.tar.gz

yum-builddep -y rpmbuild/SPECS/nginx.spec


###   --with-openssl=/root/openssl-1.1.1k

sed -i 's/\-\-with\-debug/\-\-with\-openssl=\/root\/openssl\-1\.1\.1k/' /root/rpmbuild/SPECS/nginx.spec

rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec

yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.21.4-1.el7.ngx.x86_64.rpm

systemctl start nginx.service
systemctl status nginx.service


echo "part1 complited"



####   PART 2   ####
mkdir /usr/share/nginx/html/repo

cp /root/rpmbuild/RPMS/x86_64/nginx-1.21.4-1.el7.ngx.x86_64.rpm /usr/share/nginx/html/repo/

wget https://downloads.percona.com/downloads/percona-release/percona-release-1.0-17/redhat/percona-release-1.0-17.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-1.0-17.noarch.rpm

createrepo /usr/share/nginx/html/repo/

sed -i '/index  index.html index.htm;/ a autoindex on;' /etc/nginx/conf.d/default.conf

nginx -t
nginx -s reload

cat << EOF > /etc/yum.repos.d/otus.repo 
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF

yum list | grep otus
yum-config-manager --disable epel
           yum-config-manager --enable otus
           yum reinstall nginx -y
           yum-config-manager --enable epel

