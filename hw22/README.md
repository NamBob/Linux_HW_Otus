## ДЗ VPN
#### Задачи
1. Между двумя виртуалками поднять vpn в режимах:
- tun
- tap

Описать в чём разница, замерить скорость между виртуальными машинами в
туннелях, сделать вывод об отличающихся показателях скорости.

2. Поднять RAS на базе OpenVPN с клиентскими сертификатами,
подключиться с локальной машины на виртуалку. 

3. (*). Самостоятельно изучить, поднять ocserv и подключиться с хоста к
виртуалке.

#### Стенд 
- Поднимаем 2 ВМ `server` и `client`. Между ними будем тестировать `OpenVPN` в режимах `TUN` и `TAP`.
- на ВМ `Server` дополнительно настроил еще один сетевой интерфейс с ip `172.20.30.10` для выполнения пункта задания №2.
- при развертывании не стал делать провизионинг с помощью `ansible`.

#### Задание 1

1. разворачиваем стенд `vagrant up`.
2. запускаем openvpn режиме `TAP`.
- `ansible-playbook playbook/tap.yml`.
- подключаемся на `client` и проверяем пинг.

      [root@client ~]# ping 10.10.10.1 -c 4
      PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
      64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=0.842 ms
      64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=0.805 ms
      64 bytes from 10.10.10.1: icmp_seq=3 ttl=64 time=0.667 ms
      64 bytes from 10.10.10.1: icmp_seq=4 ttl=64 time=0.563 ms
######   vpn работает!
- запускаем тест производительности сети со следующими параметрами.
    
    - iperf3 -c 10.10.10.1 -i 5 -t 30 -b 100M -u

<details>
  <summary>результат TAP</summary>
  
      [root@server ~]# iperf3 -s
      -----------------------------------------------------------
      Server listening on 5201
      -----------------------------------------------------------
      Accepted connection from 10.10.10.2, port 40164
      [  5] local 10.10.10.1 port 5201 connected to 10.10.10.2 port 42584
      [ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
      [  5]   0.00-1.00   sec  5.57 MBytes  46.7 Mbits/sec  0.045 ms  3483/7799 (45%)  
      [  5]   1.00-2.00   sec  6.45 MBytes  54.1 Mbits/sec  0.066 ms  4231/9230 (46%)  
      [  5]   2.00-3.00   sec  6.42 MBytes  53.8 Mbits/sec  0.053 ms  4247/9220 (46%)  
      [  5]   3.00-4.00   sec  6.06 MBytes  50.9 Mbits/sec  0.037 ms  4581/9281 (49%)  
      [  5]   4.00-5.00   sec  6.30 MBytes  52.8 Mbits/sec  0.137 ms  4353/9236 (47%)  
      [  5]   5.00-6.00   sec  6.40 MBytes  53.7 Mbits/sec  0.058 ms  4289/9252 (46%)  
      [  5]   6.00-7.00   sec  6.34 MBytes  53.2 Mbits/sec  0.057 ms  4365/9280 (47%)  
      [  5]   7.00-8.00   sec  6.32 MBytes  53.0 Mbits/sec  0.082 ms  4307/9205 (47%)  
      [  5]   8.00-9.00   sec  6.35 MBytes  53.2 Mbits/sec  0.069 ms  4317/9235 (47%)  
      [  5]   9.00-10.00  sec  6.51 MBytes  54.6 Mbits/sec  0.050 ms  4232/9277 (46%)  
      [  5]  10.00-11.00  sec  5.81 MBytes  48.7 Mbits/sec  0.075 ms  4668/9170 (51%)  
      [  5]  11.00-12.00  sec  6.46 MBytes  54.2 Mbits/sec  0.064 ms  4251/9256 (46%)  
      [  5]  12.00-13.00  sec  6.28 MBytes  52.7 Mbits/sec  0.056 ms  4366/9233 (47%)  
      [  5]  13.00-14.00  sec  6.43 MBytes  54.0 Mbits/sec  0.049 ms  4252/9237 (46%)  
      [  5]  14.00-15.00  sec  6.45 MBytes  54.1 Mbits/sec  0.055 ms  4243/9238 (46%)  
      [  5]  15.00-16.00  sec  6.40 MBytes  53.7 Mbits/sec  0.049 ms  4244/9206 (46%)  
      [  5]  16.00-17.00  sec  6.33 MBytes  53.1 Mbits/sec  0.050 ms  4267/9175 (47%)  
      [  5]  17.00-18.00  sec  6.48 MBytes  54.3 Mbits/sec  0.049 ms  4318/9338 (46%)  
      [  5]  18.00-19.00  sec  6.31 MBytes  53.0 Mbits/sec  0.054 ms  4339/9232 (47%)  
      [  5]  19.00-20.00  sec  6.43 MBytes  53.9 Mbits/sec  0.047 ms  4280/9263 (46%)  
      [  5]  20.00-21.00  sec  6.36 MBytes  53.4 Mbits/sec  0.051 ms  4348/9278 (47%)  
      [  5]  21.00-22.00  sec  6.36 MBytes  53.4 Mbits/sec  0.048 ms  4233/9164 (46%)  
      [  5]  22.00-23.00  sec  6.45 MBytes  54.1 Mbits/sec  0.058 ms  4332/9329 (46%)  
      [  5]  23.00-24.00  sec  6.35 MBytes  53.2 Mbits/sec  0.048 ms  4248/9166 (46%)  
      [  5]  24.00-25.00  sec  6.41 MBytes  53.7 Mbits/sec  0.045 ms  4271/9235 (46%)  
      [  5]  25.00-26.00  sec  6.37 MBytes  53.4 Mbits/sec  0.056 ms  4374/9309 (47%)  
      [  5]  26.00-27.00  sec  6.32 MBytes  53.0 Mbits/sec  0.056 ms  4264/9161 (47%)  
      [  5]  27.00-28.00  sec  6.44 MBytes  54.0 Mbits/sec  0.063 ms  4246/9235 (46%)  
      [  5]  28.00-29.00  sec  6.22 MBytes  52.2 Mbits/sec  0.108 ms  4508/9329 (48%)  
      [  5]  29.00-30.00  sec  5.99 MBytes  50.2 Mbits/sec  0.253 ms  4466/9105 (49%)  
      [  5]  30.00-30.07  sec   252 KBytes  29.0 Mbits/sec  0.009 ms  40/231 (17%)  
      - - - - - - - - - - - - - - - - - - - - - - - - -
      [ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
      [  5]   0.00-30.07  sec  0.00 Bytes  0.00 bits/sec  0.009 ms  128963/275905 (47%) 
</details>

    - средняя скорость 6.5 MBytes
    - много потерь 47%


3. запускаем openvpn режиме `TUN`
- `ansible-playbook playbook/tun.yml`.
- подключаемся на `client` и проверяем пинг.

      [root@client ~]# ping 10.10.10.1 -c 4
      PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
      64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=0.842 ms
      64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=0.805 ms
      64 bytes from 10.10.10.1: icmp_seq=3 ttl=64 time=0.667 ms
      64 bytes from 10.10.10.1: icmp_seq=4 ttl=64 time=0.563 ms
######   vpn работает!
- запускаем тест производительности сети со следующими параметрами.
    
    - iperf3 -c 10.10.10.1 -i 5 -t 30 -b 100M -u

<details>
  <summary>результат TUN</summary>

      [root@server ~]# iperf3 -s
      -----------------------------------------------------------
      Server listening on 5201
      -----------------------------------------------------------
      Accepted connection from 10.10.10.2, port 40166
      [  5] local 10.10.10.1 port 5201 connected to 10.10.10.2 port 36679
      [ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
      [  5]   0.00-1.00   sec  10.7 MBytes  89.6 Mbits/sec  0.065 ms  52/8530 (0.61%)  
      [  5]   1.00-2.00   sec  11.8 MBytes  98.7 Mbits/sec  0.054 ms  104/9442 (1.1%)  
      [  5]   2.00-3.00   sec  11.8 MBytes  98.7 Mbits/sec  0.035 ms  89/9427 (0.94%)  
      [  5]   3.00-4.00   sec  12.0 MBytes   100 Mbits/sec  0.052 ms  0/9500 (0%)  
      [  5]   4.00-5.00   sec  11.9 MBytes   100 Mbits/sec  0.075 ms  1/9479 (0.011%)  
      [  5]   5.00-6.00   sec  11.8 MBytes  99.0 Mbits/sec  0.053 ms  28/9400 (0.3%)  
      [  5]   6.00-7.00   sec  11.9 MBytes   100 Mbits/sec  0.049 ms  2/9480 (0.021%)  
      [  5]   7.00-8.00   sec  11.8 MBytes  98.7 Mbits/sec  0.052 ms  113/9448 (1.2%)  
      [  5]   8.00-9.00   sec  11.4 MBytes  96.0 Mbits/sec  0.648 ms  183/9268 (2%)  
      [  5]   9.00-10.00  sec  11.7 MBytes  98.6 Mbits/sec  0.054 ms  237/9563 (2.5%)  
      [  5]  10.00-11.00  sec  11.8 MBytes  99.3 Mbits/sec  0.144 ms  196/9594 (2%)  
      [  5]  11.00-12.00  sec  11.6 MBytes  97.3 Mbits/sec  0.054 ms  178/9386 (1.9%)  
      [  5]  12.00-13.00  sec  12.0 MBytes   101 Mbits/sec  0.053 ms  13/9525 (0.14%)  
      [  5]  13.00-14.00  sec  12.0 MBytes   100 Mbits/sec  0.056 ms  29/9519 (0.3%)  
      [  5]  14.00-15.00  sec  11.7 MBytes  97.8 Mbits/sec  0.056 ms  133/9384 (1.4%)  
      [  5]  15.00-16.00  sec  11.8 MBytes  99.2 Mbits/sec  0.043 ms  192/9580 (2%)  
      [  5]  16.00-17.00  sec  11.2 MBytes  93.8 Mbits/sec  0.114 ms  494/9376 (5.3%)  
      [  5]  17.00-18.00  sec  11.7 MBytes  98.5 Mbits/sec  0.052 ms  69/9385 (0.74%)  
      [  5]  18.00-19.00  sec  11.3 MBytes  94.8 Mbits/sec  0.097 ms  582/9553 (6.1%)  
      [  5]  19.00-20.00  sec  11.6 MBytes  96.9 Mbits/sec  0.098 ms  276/9454 (2.9%)  
      [  5]  20.00-21.00  sec  11.8 MBytes  99.5 Mbits/sec  0.055 ms  73/9479 (0.77%)  
      [  5]  21.00-22.00  sec  11.0 MBytes  91.9 Mbits/sec  0.092 ms  768/9467 (8.1%)  
      [  5]  22.00-23.00  sec  11.5 MBytes  95.8 Mbits/sec  0.636 ms  222/9316 (2.4%)  
      [  5]  23.00-24.00  sec  11.8 MBytes  99.5 Mbits/sec  0.043 ms  154/9539 (1.6%)  
      [  5]  24.00-25.00  sec  11.9 MBytes  99.7 Mbits/sec  0.068 ms  62/9498 (0.65%)  
      [  5]  25.00-26.00  sec  11.7 MBytes  98.5 Mbits/sec  0.055 ms  86/9405 (0.91%)  
      [  5]  26.00-27.00  sec  11.2 MBytes  93.9 Mbits/sec  0.009 ms  687/9575 (7.2%)  
      [  5]  27.00-28.00  sec  11.5 MBytes  96.7 Mbits/sec  0.073 ms  267/9420 (2.8%)  
      [  5]  28.00-29.00  sec  11.9 MBytes  99.6 Mbits/sec  0.061 ms  53/9475 (0.56%)  
      [  5]  29.00-30.00  sec  11.8 MBytes  98.9 Mbits/sec  0.059 ms  155/9514 (1.6%)  
      [  5]  30.00-30.05  sec  50.3 KBytes  8.00 Mbits/sec  0.027 ms  0/39 (0%)  
      - - - - - - - - - - - - - - - - - - - - - - - - -
      [ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
      [  5]   0.00-30.05  sec  0.00 Bytes  0.00 bits/sec  0.027 ms  5498/283020 (1.9%) 
</details>  

    - средняя скорость 11.5 MBytes
    - мало потерь 1.9%
##### `выводы`.

    - в режиме TUN производительность выше и потерь меньше. 
    - при тестировании не удивел разницы в нагрузке на процессор, но по моему мнению в режиме TUN нагрузка должна быть больше.
##### `Задание 1 выполнено`.
#### Задание 2

1. запускаем openvpn режиме `RAS`.
- `ansible-playbook playbook/ras.yml`.
    
<details>
  <summary>при развертывании ключи для клиента будут скопираны на локальный хост в папку `test_pki` текущей директории</summary>

      nbt@lenovo:~/otus/hw22$ ll
      total 44
      drwxrwxr-x  8 nbt nbt 4096 мар 25 11:46 ./
      drwxrwxr-x 30 nbt nbt 4096 мар 24 15:24 ../
      -rw-rw-r--  1 nbt nbt  150 мар 22 09:53 ansible.cfg
      drwxrwxr-x  2 nbt nbt 4096 мар 22 09:52 files/
      drwxrwxr-x  2 nbt nbt 4096 мар 11 14:29 inventories/
      drwxrwxr-x  2 nbt nbt 4096 мар 24 17:48 playbooks/
      drwxrwxr-x  5 nbt nbt 4096 мар 24 13:51 roles/
      -rwxrwxr-x  1 nbt nbt  137 мар 22 10:27 ssh_key_clear.sh*
      drwxrwxr-x  2 nbt nbt 4096 мар 25 11:46 test_pki/
      drwxrwxr-x  5 nbt nbt 4096 мар 22 10:04 .vagrant/
      -rw-rw-r--  1 nbt nbt  713 мар 24 16:40 Vagrantfile
</details>  

2. Как я описывал ранее на ВМ `server` есть несколько сетевых интерфейсов:

- `eth0` для `vagrant` ip задается автоматом.
- `eth1` для `ansible` ip 192.168.10.10
- `eth2` для `RAS` ip 172.20.30.10
3.  Так как поднимаю для `RAS` отдельный интерфейс, то в конфигуриции сервера и маршруты.

<details>
  <summary>конфигурация сервера</summary>

      port 1207
      proto udp
      dev tun
      ca /etc/openvpn/pki/ca.crt
      cert /etc/openvpn/pki/issued/server.crt
      key /etc/openvpn/pki/private/server.key
      dh /etc/openvpn/pki/dh.pem
      server 10.10.10.0 255.255.255.0
      #route 172.20.30.0 255.255.255.0
      #push "route 172.20.30.0 255.255.255.0"
      ifconfig-pool-persist ipp.txt
      client-to-client
      client-config-dir /etc/openvpn/client
      keepalive 10 120
      comp-lzo
      persist-key
      persist-tun
      status /var/log/openvpn-status.log
      log /var/log/openvpn.log
      verb 3
</details>  

<details>
  <summary>конфигурация клиента</summary>

      dev tun
      proto udp
      remote 172.20.30.10 1207
      client
      resolv-retry infinite
      ca ./ca.crt
      cert ./client.crt
      key ./client.key
      route 172.20.30.0 255.255.255.0
      persist-key
      persist-tun
      comp-lzo
      verb 3
      remote-cert-tls server
</details>  

4. на своей локальной машине переходим в папку test_pki `cd test_pki`.
<details>
  <summary>тут уже должны быть клиентские сертификаты</summary>

      nbt@lenovo:~/otus/hw22/test_pki$ ll
      total 28
      drwxrwxr-x 2 nbt nbt 4096 мар 25 11:46 ./
      drwxrwxr-x 8 nbt nbt 4096 мар 25 11:46 ../
      -rw-rw-r-- 1 nbt nbt 1151 мар 25 11:46 ca.crt
      -rw-rw-r-- 1 nbt nbt  215 мар 24 17:25 client.conf
      -rw-rw-r-- 1 nbt nbt 4410 мар 25 11:46 client.crt
      -rw-rw-r-- 1 nbt nbt 1704 мар 25 11:46 client.key
</details>

5. Поднимаем VPN `sudo openvpn --config client.conf`
6. проверяем что соединение есть.

        nbt@lenovo:~/otus/Linux_HW_Otus/hw22$ ping 10.10.10.1 -c 4
        PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
        64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=0.847 ms
        64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=0.902 ms
        64 bytes from 10.10.10.1: icmp_seq=3 ttl=64 time=0.848 ms
        64 bytes from 10.10.10.1: icmp_seq=4 ttl=64 time=0.892 ms

        --- 10.10.10.1 ping statistics ---
        4 packets transmitted, 4 received, 0% packet loss, time 3046ms
        rtt min/avg/max/mdev = 0.847/0.872/0.902/0.025 ms

7. на сервере

        [root@server ~]# cat /var/log/openvpn-status.log 
        OpenVPN CLIENT LIST
        Updated,Fri Mar 25 13:01:02 2022
        Common Name,Real Address,Bytes Received,Bytes Sent,Connected Since
        client,172.20.30.1:1194,7769,3721,Fri Mar 25 12:59:43 2022
        ROUTING TABLE
        Virtual Address,Common Name,Real Address,Last Ref
        10.10.10.6,client,172.20.30.1:1194,Fri Mar 25 13:00:54 2022
        192.168.33.0/24,client,172.20.30.1:1194,Fri Mar 25 12:59:43 2022
        GLOBAL STATS
        Max bcast/mcast queue length,0
        END

##### `Задание 2 выполнено`.
#### Задание 3
`не делал`