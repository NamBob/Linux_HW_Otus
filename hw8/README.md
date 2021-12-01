# Домашнее задание Systemd

### Выполнить следующие задания и подготовить развёртывание результата выполнения с использованием Vagrant и Vagrant shell provisioner (или Ansible, на Ваше усмотрение):

#### 1.Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig).
    Результат в файле hw8-1. Сделано по методичке. 
        root@hw8:tail -f /var/log/messages
        Dec  1 11:31:04 localhost vagrant: Wed Dec  1 11:31:04 UTC 2021: I found word, Master!
        Dec  1 11:31:47 localhost systemd: Starting My watchlog service...
        Dec  1 11:31:47 localhost root: date: I found word, Master!
        Dec  1 11:31:47 localhost systemd: Started My watchlog service.
        Dec  1 11:32:47 localhost systemd: Starting My watchlog service...
        Dec  1 11:32:47 localhost root: date: I found word, Master!
        Dec  1 11:32:47 localhost systemd: Started My watchlog service.
        Dec  1 11:33:47 localhost systemd: Starting My watchlog service...
        Dec  1 11:33:47 localhost root: Wed Dec  1 11:33:47 UTC 2021: I found word, Master!
        Dec  1 11:33:47 localhost systemd: Started My watchlog service.
        Dec  1 11:34:47 localhost systemd: Starting My watchlog service...
        Dec  1 11:34:47 localhost root: Wed Dec  1 11:34:47 UTC 2021: I found word, Master!
        Dec  1 11:34:47 localhost systemd: Started My watchlog service.
        Dec  1 11:35:47 localhost systemd: Starting My watchlog service...
        Dec  1 11:35:47 localhost root: Wed Dec  1 11:35:47 UTC 2021: I found word, Master!
        Dec  1 11:35:47 localhost systemd: Started My watchlog service.

    Из интересного:
        - некорректно переносятся символ ` (переносил содержимое bash-скрипта, в результате вместо даты выводилось само слово date)
        - сервис выводит результат раз в минуту а не 30 сек.


#### 2. Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).
    Результат в фале hw8-2. Сделано по методичке.
        root@hw8:~^G[root@hw8 ~]# systemctl start spawn-fcgi
        root@hw8:~^G[root@hw8 ~]# systemctl status spawn-fcgi
            ^[[1;32mâ<97><8f>^[[0m spawn-fcgi.service - Spawn-fcgi startup service by Otus
            Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
            Active: ^[[1;32mactive (running)^[[0m since Wed 2021-12-01 11:42:11 UTC; 7s ago
            Main PID: 25429 (php-cgi)
  

Dec 01 11:42:11 hw8 systemd[1]: Started Spawn-fcgi startup servi....
Hint: Some lines were ellipsized, use -l to show in full.

#### 3. Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.
    Результат в фале hw8-3.
    из интересного, нужно в selinux разрешать порты для httpd, иначе сервисы не стартуют.
        [root@hw8 ~]# semanage port -l | grep http
        http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
        http_cache_port_t              udp      3130
        http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
        pegasus_http_port_t            tcp      5988
        pegasus_https_port_t           tcp      5989
        [root@hw8 ~]# semanage port -a -t http_port_t -p tcp 8888
        [root@hw8 ~]# semanage port -a -t http_port_t -p tcp 8899
        [root@hw8 ~]# 
        [root@hw8 ~]# semanage port -l | grep http
        http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
        http_cache_port_t              udp      3130
        http_port_t                    tcp      8899, 8888, 80, 81, 443, 488, 8008, 8009, 8443, 9000
        pegasus_http_port_t            tcp      5988
        pegasus_https_port_t           tcp      5989
        [root@hw8 ~]# systemctl start httpd@first
        [root@hw8 ~]# systemctl start httpd@second
        [root@hw8 ~]# systemctl status httpd@*
        ● httpd@first.service - The Apache HTTP Server
            Loaded: loaded (/etc/systemd/system/httpd@.service; disabled; vendor preset: disabled)
            Active: active (running) since Wed 2021-12-01 13:56:16 UTC; 16s ago
                Docs: man:httpd(8)
                    man:apachectl(8)
            Main PID: 25564 (httpd)
            Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
            CGroup: /system.slice/system-httpd.slice/httpd@first.service
                    ├─25564 /usr/sbin/httpd -f conf/first.conf -DFOREGROUN...
                    ├─25565 /usr/sbin/httpd -f conf/first.conf -DFOREGROUN...
                    ├─25566 /usr/sbin/httpd -f conf/first.conf -DFOREGROUN...
                    ├─25567 /usr/sbin/httpd -f conf/first.conf -DFOREGROUN...
                    ├─25568 /usr/sbin/httpd -f conf/first.conf -DFOREGROUN...
                    ├─25569 /usr/sbin/httpd -f conf/first.conf -DFOREGROUN...
                    └─25570 /usr/sbin/httpd -f conf/first.conf -DFOREGROUN...

            Dec 01 13:56:16 hw8 systemd[1]: Starting The Apache HTTP Server...
            Dec 01 13:56:16 hw8 httpd[25564]: AH00558: httpd: Could not reli...e
            Dec 01 13:56:16 hw8 systemd[1]: Started The Apache HTTP Server.

            ● httpd@second.service - The Apache HTTP Server
            Loaded: loaded (/etc/systemd/system/httpd@.service; disabled; vendor preset: disabled)
            Active: active (running) since Wed 2021-12-01 13:56:23 UTC; 9s ago
                Docs: man:httpd(8)
                    man:apachectl(8)
            Main PID: 25577 (httpd)
            Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
            CGroup: /system.slice/system-httpd.slice/httpd@second.service
                    ├─25577 /usr/sbin/httpd -f conf/second.conf -DFOREGROU...
                    ├─25578 /usr/sbin/httpd -f conf/second.conf -DFOREGROU...
                    ├─25579 /usr/sbin/httpd -f conf/second.conf -DFOREGROU...
                    ├─25580 /usr/sbin/httpd -f conf/second.conf -DFOREGROU...
                    ├─25581 /usr/sbin/httpd -f conf/second.conf -DFOREGROU...
                    ├─25582 /usr/sbin/httpd -f conf/second.conf -DFOREGROU...
                    └─25583 /usr/sbin/httpd -f conf/second.conf -DFOREGROU...

            Dec 01 13:56:23 hw8 systemd[1]: Starting The Apache HTTP Server...
            Dec 01 13:56:23 hw8 httpd[25577]: AH00558: httpd: Could not reli...e
            Dec 01 13:56:23 hw8 systemd[1]: Started The Apache HTTP Server.
            Hint: Some lines were ellipsized, use -l to show in full.
        [root@hw8 ~]# ss -tunlp | grep httpd
        tcp    LISTEN     0      128    [::]:8899               [::]:*                   users:(("httpd",pid=25583,fd=4),("httpd",pid=25582,fd=4),("httpd",pid=25581,fd=4),("httpd",pid=25580,fd=4),("httpd",pid=25579,fd=4),("httpd",pid=25578,fd=4),("httpd",pid=25577,fd=4))
        tcp    LISTEN     0      128    [::]:80                 [::]:*                   users:(("httpd",pid=25071,fd=4),("httpd",pid=25070,fd=4),("httpd",pid=25069,fd=4),("httpd",pid=25068,fd=4),("httpd",pid=25067,fd=4),("httpd",pid=25066,fd=4),("httpd",pid=25065,fd=4))
        tcp    LISTEN     0      128    [::]:8888               [::]:*                   users:(("httpd",pid=25570,fd=4),("httpd",pid=25569,fd=4),("httpd",pid=25568,fd=4),("httpd",pid=25567,fd=4),("httpd",pid=25566,fd=4),("httpd",pid=25565,fd=4),("httpd",pid=25564,fd=4))

#### 4*. Скачать демо-версию Atlassian Jira и переписать основной скрипт запуска на unit-файл.
    Не выполнялось.