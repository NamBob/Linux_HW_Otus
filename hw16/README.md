## Домашнее задание Сбор и анализ логов 
### Задачи:
Настраиваем центральный сервер для сбора логов

1. в вагранте поднимаем 2 машины web и log
        
        vagrant up
2. на web поднимаем nginx

    - nginx разворачивается при выполнении роли web
3. на log настраиваем центральный лог сервер на любой системе на выбор
    - journald;
    - rsyslog;
    - elk.

    По методичке выбор сделан в сторону **rsyslog** 

    настройка производится при выполнении роли **log**
4. настраиваем аудит, следящий за изменением конфигов nginx

    - Все критичные логи с web должны собираться и локально и удаленно.
    
        пример локального **access** лога **nginx**

                [root@web ~]# tail -f /var/log/nginx/access.log 
                192.168.50.1 - - [09/Feb/2022:20:35:46 +0300] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:96.0) Gecko/20100101 Firefox/96.0" "-"
                192.168.50.1 - - [09/Feb/2022:20:35:46 +0300] "GET /img/html-background.png HTTP/1.1" 304 0 "http://192.168.50.10/" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:96.0) Gecko/20100101 Firefox/96.0" "-"
                192.168.50.1 - - [09/Feb/2022:20:35:46 +0300] "GET /img/centos-logo.png HTTP/1.1" 304 0 "http://192.168.50.10/" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:96.0) Gecko/20100101 Firefox/96.0" "-"
                192.168.50.1 - - [09/Feb/2022:20:35:46 +0300] "GET /img/header-background.png HTTP/1.1" 304 0 "http://192.168.50.10/" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:96.0) Gecko/20100101 Firefox/96.0" "-"
        пример локального **error** лога **nginx**

                [root@web ~]# tail -f /var/log/nginx/error.log 
                2022/02/09 20:35:46 [error] 9067#9067: send() failed (113: No route to host)
                2022/02/09 20:35:46 [error] 9067#9067: send() failed (113: No route to host)
                
    - Все логи с nginx должны уходить на удаленный сервер (локально только критичные).

        пример удаленного **access** лога **nginx**

            [root@log ~]# ls -l /var/log/rsyslog/web/nginx_access.log 
            -rw-------. 1 root root 1742 Feb  9 20:46 /var/log/rsyslog/web/nginx_access.log
            [root@log ~]# tail -f /var/log/rsyslog/web/nginx_access.log 
            Feb  9 20:46:49 web nginx_access: 192.168.50.1 - - [09/Feb/2022:20:46:49 +0300] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:96.0) Gecko/20100101 Firefox/96.0"
            Feb  9 20:46:49 web nginx_access: 192.168.50.1 - - [09/Feb/2022:20:46:49 +0300] "GET /img/html-background.png HTTP/1.1" 304 0 "http://192.168.50.10/" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:96.0) Gecko/20100101 Firefox/96.0"
            Feb  9 20:46:49 web nginx_access: 192.168.50.1 - - [09/Feb/2022:20:46:49 +0300] "GET /img/centos-logo.png HTTP/1.1" 304 0 "http://192.168.50.10/" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:96.0) Gecko/20100101 Firefox/96.0"
            Feb  9 20:46:49 web nginx_access: 192.168.50.1 - - [09/Feb/2022:20:46:49 +0300] "GET /img/header-background.png HTTP/1.1" 304 0 "http://192.168.50.10/" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:96.0) Gecko/20100101 Firefox/96.0"
        пример удаленного **error** лога **nginx**

                [root@log ~]# tail -f /var/log/rsyslog/web/nginx_error.log 
                Feb  9 20:50:00 web nginx_error: 2022/02/09 20:50:00 [error] 9067#9067: *7 open() "/usr/share/nginx/html/img/header-background.png" failed (2: No such file or directory), client: 192.168.50.1, server: _, request: "GET /img/header-background.png HTTP/1.1", host: "192.168.50.10", referrer: "http://192.168.50.10/"
                Feb  9 20:50:06 web nginx_error: 2022/02/09 20:50:06 [error] 9067#9067: *7 open() "/usr/share/nginx/html/img/header-background.png" failed (2: No such file or directory), client: 192.168.50.1, server: _, request: "GET /img/header-background.png HTTP/1.1", host: "192.168.50.10", referrer: "http://192.168.50.10/"
                Feb  9 20:50:06 web nginx_error: 2022/02/09 20:50:06 [error] 9067#9067: *6 open() "/usr/share/nginx/html/img/header-background.png" failed (2: No such file or directory), client: 192.168.50.1, server: _, request: "GET /img/header-background.png HTTP/1.1", host: "192.168.50.10", referrer: "http://192.168.50.10/"
    
    - Логи аудита должны также уходить на удаленную систему.

        пример локального лога 

            [root@web ~]# tail -f /var/log/audit/audit.log | grep nginx_conf
            type=SYSCALL msg=audit(1644345285.050:5270): arch=c000003e syscall=268 success=yes exit=0 a0=ffffffffffffff9c a1=7cc420 a2=1ed a3=7fff5367c3a0 items=1 ppid=17722 pid=17765 auid=0 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts0 ses=5 comm="chmod" exe="/usr/bin/chmod" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="nginx_conf"
            type=SYSCALL msg=audit(1644345302.696:5271): arch=c000003e syscall=268 success=yes exit=0 a0=ffffffffffffff9c a1=1f04420 a2=1a4 a3=7fffa000e120 items=1 ppid=17722 pid=17766 auid=0 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts0 ses=5 comm="chmod" exe="/usr/bin/chmod" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="nginx_conf"  

        пример удаленного лога

            [root@log ~]# tail -f /var/log/audit/audit.log
            
            node=web type=SYSCALL msg=audit(1644429199.698:3918): arch=c000003e syscall=268 success=yes exit=0 a0=ffffffffffffff9c a1=90c420 a2=1a4 a3=7ffe20749ae0 items=1 ppid=573 pid=1788 auid=0 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts0 ses=8 comm="chmod" exe="/usr/bin/chmod" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="nginx_conf"
            node=web type=CWD msg=audit(1644429199.698:3918):  cwd="/usr/share/doc/HTML/img"
            node=web type=PATH msg=audit(1644429199.698:3918): item=0 name="/etc/nginx/nginx.conf" inode=67684274 dev=08:01 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:httpd_config_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
            node=web type=PROCTITLE msg=audit(1644429199.698:3918): proctitle=63686D6F64002D78002F6574632F6E67696E782F6E67696E782E636F6E66

### Задание со * (звездочкой)
- развернуть еще машину elk
- таким образом настроить 2 центральных лог системы elk и какую либо еще;
- в elk должны уходить только логи нжинкса;
- во вторую систему все остальное.

#### не сделано :(