## часть 1
#### подготовка
для проверки статуса selinux
- sestatus  

        SELinux status:                 enabled
        SELinuxfs mount:                /sys/fs/selinux
        SELinux root directory:         /etc/selinux
        Loaded policy name:             targeted
        Current mode:                   enforcing
        Mode from config file:          enforcing
        Policy MLS status:              enabled
        Policy deny_unknown status:     allowed
        Max kernel policy version:      31

 
ставим пакеты для управления/аудита selinux  
- yum install -y setools-console policycoreutils-python
ставим nginx & enable nginx & start nginx  
- yum install -y nginx
- systemctl enable nginx && systemctl start nginx && systemctl status nginx  
    
        [root@hw12 ~]#  systemctl status nginx 
        ● nginx.service - The nginx HTTP and reverse proxy server
        Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
        Active: active (running) since Чт 2021-12-30 11:40:07 MSK; 16s ago
        Process: 1025 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
        Process: 1023 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
        Process: 1022 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
        Main PID: 1027 (nginx)
        CGroup: /system.slice/nginx.service
                ├─1027 nginx: master process /usr/sbin/nginx
                └─1029 nginx: worker process

        дек 30 11:40:07 hw12 systemd[1]: Starting The nginx HTTP and reverse proxy server...
        дек 30 11:40:07 hw12 nginx[1023]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
        дек 30 11:40:07 hw12 nginx[1023]: nginx: configuration file /etc/nginx/nginx.conf test is successful
        дек 30 11:40:07 hw12 systemd[1]: Started The nginx HTTP and reverse proxy server.

проверяем порты nginx

        LISTEN     0      128          *:80                       *:*                   users:(("nginx",pid=1029,fd=6),("nginx",pid=1027,fd=6))
        LISTEN     0      128       [::]:80                    [::]:*                   users:(("nginx",pid=1029,fd=7),("nginx",pid=1027,fd=7))

меняем порт nginx на 8888 и перезапускаем сервис.
сервис не стартовал

        Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.
смотрим в selinux порты для nginx
semanage port -l | grep http

        http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
        http_cache_port_t              udp      3130
        http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
        pegasus_http_port_t            tcp      5988
        pegasus_https_port_t           tcp      5989

#### 1.переключатели setsebool
посмотрим логи аудита 

        [root@hw12 ~]# audit2why < /var/log/audit/audit.log
        type=AVC msg=audit(1640854390.861:1350): avc:  denied  { name_bind } for  pid=1754 comm="nginx" src=8888 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

            Was caused by:
            The boolean nis_enabled was set incorrectly. 
            Description:
            Allow nis to enabled

            Allow access by executing:
            # setsebool -P nis_enabled 1
Следуем рекомендации и выполним 

        [root@hw12 ~]# setsebool -P nis_enabled 1
Снова перезапустим nginx и видим что nginx запустился.

        [root@hw12 ~]# systemctl restart firewalld.service && systemctl status firewalld.service 
        ● firewalld.service - firewalld - dynamic firewall daemon
        Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
        Active: active (running) since Чт 2021-12-30 12:52:40 MSK; 10ms ago
            Docs: man:firewalld(1)
        Main PID: 4806 (firewalld)
        CGroup: /system.slice/firewalld.service
                ├─4806 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid
                └─4809 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid

        дек 30 12:52:40 hw12 systemd[1]: Starting firewalld - dynamic firewall daemon...
        дек 30 12:52:40 hw12 systemd[1]: Started firewalld - dynamic firewall daemon.
проверим что nginx запустился на порту 8888

        [root@hw12 ~]# ss -nlp | grep nginx
        tcp    LISTEN     0      128       *:8888                  *:*                   users:(("nginx",pid=4758,fd=6),("nginx",pid=4756,fd=6))

#### 2.добавление нестандартного порта в имеющийся тип
возвращаем все в исходное состояние (не запускается nginx)

        setsebool -P nis_enabled off
        systemctl stop nginx
        systemctl start nginx
ищем тип для nginx

        [root@hw12 ~]# semanage port -l | grep http
        http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
        http_cache_port_t              udp      3130
        http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
        pegasus_http_port_t            tcp      5988
        pegasus_https_port_t           tcp      5989
добавляем порт 8888 в тип http_port_t и проверяем что nginx запустился

        [root@hw12 ~]# semanage port -a -t http_port_t -p tcp 8888
        [root@hw12 ~]# systemctl start nginx
        [root@hw12 ~]# systemctl status nginx
        ● nginx.service - The nginx HTTP and reverse proxy server
        Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
        Active: active (running) since Чт 2021-12-30 13:36:16 MSK; 10s ago
        Process: 7506 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
        Process: 7504 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
        Process: 7503 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
        Main PID: 7508 (nginx)
        CGroup: /system.slice/nginx.service
                ├─7508 nginx: master process /usr/sbin/nginx
                └─7510 nginx: worker process

        дек 30 13:36:16 hw12 systemd[1]: Starting The nginx HTTP and reverse proxy server...
        дек 30 13:36:16 hw12 nginx[7504]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
        дек 30 13:36:16 hw12 nginx[7504]: nginx: configuration file /etc/nginx/nginx.conf test is successful
        дек 30 13:36:16 hw12 systemd[1]: Started The nginx HTTP and reverse proxy server.
#### 2.формирование и установка модуля SELinux. 

возвращаем все в исходное состояние (не запускается nginx) и обнулим логи audit.log

        systemctl stop nginx
        semanage port -d -t http_port_t -p tcp 8888
        [root@hw12 ~]# echo " " > /var/log/audit/audit.log
        systemctl start nginx

c помощью audit2allow создаем модуль для nginx

        [root@hw12 ~]# audit2allow -M nginx_88 < /var/log/audit/audit.log 
        ******************** IMPORTANT ***********************
        To make this policy package active, execute:

        semodule -i nginx_88.pp

        [root@hw12 ~]# semodule -i nginx_88.pp

Проверяем что nginx запускается

        [root@hw12 ~]# systemctl start nginx
        [root@hw12 ~]# systemctl status nginx
        ● nginx.service - The nginx HTTP and reverse proxy server
        Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
        Active: active (running) since Чт 2021-12-30 13:48:57 MSK; 6s ago
        Process: 8200 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
        Process: 8197 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
        Process: 8196 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
        Main PID: 8202 (nginx)
        CGroup: /system.slice/nginx.service
                ├─8202 nginx: master process /usr/sbin/nginx
                └─8204 nginx: worker process

        дек 30 13:48:57 hw12 systemd[1]: Starting The nginx HTTP and reverse proxy server...
        дек 30 13:48:57 hw12 nginx[8197]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
        дек 30 13:48:57 hw12 systemd[1]: Started The nginx HTTP and reverse proxy server.
        дек 30 13:48:57 hw12 nginx[8197]: nginx: configuration file /etc/nginx/nginx.conf test is successful

## часть 2
#### Обеспечить работоспособность приложения при включенном selinux.
##### запускаем подготовленный стенд
##### заходим на вм ns01
Получаем лог ошибки

        [root@ns01 ~]# audit2why < /var/log/audit/audit.log 
        type=AVC msg=audit(1640864375.186:1932): avc:  denied  { create } for  pid=5140 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0

                Was caused by:
                        Missing type enforcement (TE) allow rule.

                        You can use audit2allow to generate a loadable module to allow this access.
Из лога видим что ошибка в контексте.

Правильным решением считаю, что необходимо поправить расположение на **/var/named/**, так как эта директория дефолтная для сервиса "bind/named" и позволит в дальнейшем избежать таких ситуаций, как "забыл поправить контекст у директории /etc/named"

Правим playbook.yml

Правим файл files/ns01/named.conf

После развертывания вм, заходим на клиент и проверяем

        [vagrant@client ~]$ dig @192.168.50.10 www.ddns.lab

        ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.8 <<>> @192.168.50.10 www.ddns.lab
        ; (1 server found)
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 2450
        ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

        ;; OPT PSEUDOSECTION:
        ; EDNS: version: 0, flags:; udp: 4096
        ;; QUESTION SECTION:
        ;www.ddns.lab.                  IN      A

        ;; AUTHORITY SECTION:
        ddns.lab.               600     IN      SOA     ns01.dns.lab. root.dns.lab. 2711201407 3600 600 86400 600

        ;; Query time: 1 msec
        ;; SERVER: 192.168.50.10#53(192.168.50.10)
        ;; WHEN: Mon Jan 10 07:42:27 UTC 2022
        ;; MSG SIZE  rcvd: 91