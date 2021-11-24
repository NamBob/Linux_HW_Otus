sudo su
yum install -y nfs-utils
systemctl enable firewalld.service --now
systemctl status firewalld.service 
firewall-cmd --add-service="nfs3" --add-service="rpc-bind" --add-service="mountd" --permanent
firewall-cmd --reload
firewall-cmd --reload
firewall-cmd --list-all
systemctl enable nfs --now
ss -tunlp
mkdir -p /srv/share/upload
chown -R nfsnobody:nfsnobody /srv/share
chmod 0777 /srv/share/upload
ls -ll /srv/share/
ls -ll /srv/share/upload/
cat << EOF > /etc/exports
/srv/share 192.168.50.11/32(rw,sync,root_squash)
EOF
cat /etc/exports
exportfs -r
exportfs -s
ls -ll /srv/share/upload/check_file
ls -ll /srv/share/upload/
reboot
