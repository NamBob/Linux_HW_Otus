# Домашнее задание VPN - настройка и обслуживание.
### Задачи
- Взять стенд https://github.com/erlong15/vagrant-bind
- Добавить еще один клиентский сервер client2
- Завести в зоне dns.lab имена:
  - web1 указывает (смотрит) на client1;
  - web2 указывает (смотрит) на client2.
- Завести еще одну зону - newdns.lab
- завести в ней (newdns.lab) запись:
  - www, которая смотрит на обоих клиентов.
- Настроить split-dns:
  - client1 видит обе зоны, но в зоне dns.lab только web1;
  - client2 видит только dns.lab.

### Стэнд
- добавил хост `client2` c `ip 192.168.50.20`
- довавил зону:
<details>
  <summary>newdns.lab</summary>
   
    $TTL 3600
    $ORIGIN newdns.lab.
    @               IN      SOA     ns01.newdns.lab. root.newdns.lab. (
                                2901201907 ; serial
                                3600       ; refresh (1 hour)
                                600        ; retry (10 minutes)
                                86400      ; expire (1 day)
                                600        ; minimum (10 minutes)
                            )

                    IN      NS      ns01.newdns.lab.
                    IN      NS      ns02.newdns.lab.

    ; DNS Servers
    ns01            IN      A       192.168.50.10
    ns02            IN      A       192.168.50.11
    newdns.lab.     IN      A       192.168.50.15
    newdns.lab.     IN      A       192.168.50.16
    www             IN      CNAME   newdns.lab.

</details>

- разбил плэйбук на роли: `default`, `ns01`, `ns02`, `client`, `client2`.

### Итоги

1. client1 видит обе зоны, но в зоне dns.lab только web1;

<details>
  <summary>web1.dns.lab</summary>

    [vagrant@client ~]$ dig @ns01.ddns.lab web1.dns.lab

    ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.9 <<>> @ns01.ddns.lab web1.dns.lab
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 43268
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;web1.dns.lab.			IN	A

    ;; ANSWER SECTION:
    web1.dns.lab.		3600	IN	A	192.168.50.15

    ;; AUTHORITY SECTION:
    dns.lab.		3600	IN	NS	ns01.dns.lab.
    dns.lab.		3600	IN	NS	ns02.dns.lab.

    ;; ADDITIONAL SECTION:
    ns01.dns.lab.		3600	IN	A	192.168.50.10
    ns02.dns.lab.		3600	IN	A	192.168.50.11

    ;; Query time: 0 msec
    ;; SERVER: 192.168.50.10#53(192.168.50.10)
    ;; WHEN: Fri Apr 01 12:12:53 UTC 2022
    ;; MSG SIZE  rcvd: 127
</details>

- хост виден

<details>
  <summary>web2.dns.lab</summary>

     [vagrant@client ~]$ dig @ns01.ddns.lab web2.dns.lab

    ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.9 <<>> @ns01.ddns.lab web2.dns.lab
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 54725
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;web2.dns.lab.			IN	A

    ;; AUTHORITY SECTION:
    dns.lab.		600	IN	SOA	ns01.dns.lab. root.dns.lab. 2901201902 3600 600 86400 600

    ;; Query time: 0 msec
    ;; SERVER: 192.168.50.10#53(192.168.50.10)
    ;; WHEN: Fri Apr 01 12:12:58 UTC 2022
    ;; MSG SIZE  rcvd: 87
</details>

- хост не наблюдается.

<details>
  <summary>зона newdns.lab</summary>

    [vagrant@client ~]$ dig @ns01.ddns.lab www.newdns.lab

    ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.9 <<>> @ns01.ddns.lab www.newdns.lab
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 43971
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 2, ADDITIONAL: 3

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;www.newdns.lab.			IN	A

    ;; ANSWER SECTION:
    www.newdns.lab.		3600	IN	CNAME	newdns.lab.
    newdns.lab.		3600	IN	A	192.168.50.16
    newdns.lab.		3600	IN	A	192.168.50.15

    ;; AUTHORITY SECTION:
    newdns.lab.		3600	IN	NS	ns01.newdns.lab.
    newdns.lab.		3600	IN	NS	ns02.newdns.lab.

    ;; ADDITIONAL SECTION:
    ns01.newdns.lab.	3600	IN	A	192.168.50.10
    ns02.newdns.lab.	3600	IN	A	192.168.50.11

    ;; Query time: 0 msec
    ;; SERVER: 192.168.50.10#53(192.168.50.10)
    ;; WHEN: Fri Apr 01 12:13:20 UTC 2022
    ;; MSG SIZE  rcvd: 159
</details>

- зона доступна

2. client2 видит только dns.lab;

<details>
  <summary>web1.dns.lab</summary>

    [vagrant@client2 ~]$ dig @ns01.dns.lab web1.dns.lab

    ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.9 <<>> @ns01.dns.lab web1.dns.lab
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 2696
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;web1.dns.lab.			IN	A

    ;; ANSWER SECTION:
    web1.dns.lab.		3600	IN	A	192.168.50.15

    ;; AUTHORITY SECTION:
    dns.lab.		3600	IN	NS	ns01.dns.lab.
    dns.lab.		3600	IN	NS	ns02.dns.lab.

    ;; ADDITIONAL SECTION:
    ns01.dns.lab.		3600	IN	A	192.168.50.10
    ns02.dns.lab.		3600	IN	A	192.168.50.11

    ;; Query time: 0 msec
    ;; SERVER: 192.168.50.10#53(192.168.50.10)
    ;; WHEN: Fri Apr 01 12:14:07 UTC 2022
    ;; MSG SIZE  rcvd: 127
</details>

- хост доступен

<details>
  <summary>web2.dns.lab</summary>

    [vagrant@client2 ~]$ dig @ns01.dns.lab web2.dns.lab

    ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.9 <<>> @ns01.dns.lab web2.dns.lab
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 24112
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;web2.dns.lab.			IN	A

    ;; ANSWER SECTION:
    web2.dns.lab.		3600	IN	A	192.168.50.20

    ;; AUTHORITY SECTION:
    dns.lab.		3600	IN	NS	ns02.dns.lab.
    dns.lab.		3600	IN	NS	ns01.dns.lab.

    ;; ADDITIONAL SECTION:
    ns01.dns.lab.		3600	IN	A	192.168.50.10
    ns02.dns.lab.		3600	IN	A	192.168.50.11

    ;; Query time: 0 msec
    ;; SERVER: 192.168.50.10#53(192.168.50.10)
    ;; WHEN: Fri Apr 01 12:14:14 UTC 2022
    ;; MSG SIZE  rcvd: 127
</details>

- хост доступен.

<details>
  <summary>зона newdns.lab</summary>

    [vagrant@client2 ~]$ dig @ns01.dns.lab www.newdns.lab

    ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.9 <<>> @ns01.dns.lab www.newdns.lab
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 35460
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;www.newdns.lab.			IN	A

    ;; AUTHORITY SECTION:
    .			10800	IN	SOA	a.root-servers.net. nstld.verisign-grs.com. 2022040101 1800 900 604800 86400

    ;; Query time: 541 msec
    ;; SERVER: 192.168.50.10#53(192.168.50.10)
    ;; WHEN: Fri Apr 01 12:14:33 UTC 2022
    ;; MSG SIZE  rcvd: 118
</details>

- зона не доступна

3. * настроить всё без выключения selinux.
- все работает при включенном selinux.
- дополнительных настроек не вводилось, видимо это касается если файлы зон расположены в директориях отличных от `/etc/named/`

<details>
  <summary>ns01</summary>

    [vagrant@ns01 ~]$ sudo getenforce 
    Enforcing
    [vagrant@ns01 ~]$ 
</details>

<details>
  <summary>ns02</summary>

    [vagrant@ns02 ~]$ sudo getenforce 
    Enforcing
    [vagrant@ns02 ~]$ 
</details>
