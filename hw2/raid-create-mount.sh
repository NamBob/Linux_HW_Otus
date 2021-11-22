sudo su

#Create RAID10
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g}
sleep 10s # Waits 10 sec
mdadm --create --verbose /dev/md0 -l 10 -n 6 /dev/sd{b,c,d,e,f,g}
sleep 5m # Waits 5 minutes
cat /proc/mdstat 
mdadm -D /dev/md0

#Create mdadm conf file
mkdir /etc/mdadm
mdadm --detail --scan --verbose 
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf 

#Create Partitions
parted -s /dev/md0 mklabel gpt
lsblk 
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%
#Create filesystems on partitions
for f in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$f; done

#Create raid mount DIR
#mkdir -p /raid/part{1,2,3,4,5}

#Clean uuid.txt&fx.txt
echo "" > ./uuid.txt
#echo "" > ./fs.txt

#get uuid
for i in $(seq 1 5) 
do blkid -o value -s PARTUUID /dev/md0p$i >> ./uuid.txt
done

#send uuid to /etc/fstab
file=uuid.txt
for a in $(cat $file)
do
mkdir -p /raid/part$a 
echo "$a 	/raid/part$a		ext4    defaults        0 0" >> /etc/fstab
done

#mount all
mount -a
