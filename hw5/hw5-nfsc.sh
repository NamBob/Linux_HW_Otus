yum install -y nfs-utils
systemctl enable firewalld.service --now
echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab
cat /etc/fstab 
systemctl daemon-reload
systemctl restart remote-fs.target
cat /etc/fstab 
ls -ll /mnt/
cd /mnt/
mount | grep mnt
ls -ll upload/
reboot
