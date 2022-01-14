## домашнее задание PAM

Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников
Дать конкретному пользователю права работать с докером и возможность рестартить докер сервис

#### Основное задание

создаем ВМ из Vagrantfile   
    
    vagrant up
При создании ВМ, выполнится playbook, который выполнит две роли:

##### Роль hw13
- создаст пользователей с паролем Otus2019 
        
        day в группе admin
        night не в группе admin
        friday не в группе admin
- разрешит им вход по ssh и паролю.
- установит миниманый набор программ
- отключит NTP
- установит дату Воскресенье 09 января 2022

##### Роль hw13_2
- создает группу **admin**
- добавляет пользлователя **day** в группу **admin**
- копирует скрипт на ВМ и делает его исполняемым
- добавляет модуль pam_exec 

        # Used with polkit to reauthorize users in remote sessions
        -auth      optional     pam_reauthorize.so prepare
        account    required     pam_nologin.so
        account    required     pam_exec.so /usr/local/bin/login.sh
        account    include      password-auth
        password   include      password-auth

#### Проверка 
Заходим на ВМ

        vagrant ssh hw13
Проверяем время

        [root@hw13 ~]# date
        Sun Jan  9 00:00:32 MSK 2022

Выходим

        [root@hw13 ~]# exit
        logout
        Connection to 192.168.11.101 closed.
Заходим под ползователем **day**

        user@lenovo:~/otus/hw13$ ssh day@192.168.11.101
        day@192.168.11.101's password: 
        Last login: Sun Jan  9 00:01:12 2022 from 192.168.11.1
        [day@hw13 ~]$ id
        uid=1001(day) gid=1001(day) groups=1001(day),1003(admin) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
Так как позователь в группе **admin** то доступ есть. 

Выходим

        [day@hw13 ~]$ exit
        logout
        Connection to 192.168.11.101 closed.
Заходим под пользователем **friday**

        user@lenovo:~/otus/hw13$ ssh friday@192.168.11.101
Так как данный не в группе admin то во входе отказано

        friday@192.168.11.101's password: 
        /usr/local/bin/login.sh failed: exit code 1
        Connection closed by 192.168.11.101 port 22


#### Дополнительное задание не сделано.

Создана роль hw13_3
Получилось только:
- установить Docker
- добавить пользователя **day** в группу **docker**, чтобы пользователь мог работать с docker

п/с **видимо надо устанавливать docker не из под root**