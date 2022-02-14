## Домашнее задание РЕЗЕРВНОЕ КОПРОВАНИЕ
Настроить стенд Vagrant с двумя виртуальными машинами: backup_server и client.

Настроить удаленный бекап каталога /etc c сервера client при помощи borgbackup. Резервные копии должны соответствовать следующим критериям:

1. Директория для резервных копий /var/backup. Это должна быть отдельная точка монтирования. В данном случае для демонстрации размер не принципиален, достаточно будет и 2GB;

- При развертывании для сервера `backup`, создастся диск `/dev/sbd` с разделом `/dev/sbd1` 

        [root@backup ~]# lsblk
        NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
        sda      8:0    0  40G  0 disk 
        `-sda1   8:1    0  40G  0 part /
        sdb      8:16   0   2G  0 disk 
        `-sdb1   8:17   0   2G  0 part /var/backup
и смонтируется в директорию `/var/backup`

        [root@backup ~]# df -h
        Filesystem      Size  Used Avail Use% Mounted on
        devtmpfs        237M     0  237M   0% /dev
        tmpfs           244M     0  244M   0% /dev/shm
        tmpfs           244M  4.6M  239M   2% /run
        tmpfs           244M     0  244M   0% /sys/fs/cgroup
        /dev/sda1        40G  3.8G   37G  10% /
        tmpfs            49M     0   49M   0% /run/user/1000
        /dev/sdb1       2.0G   46M  2.0G   3% /var/backup
        tmpfs            49M     0   49M   0% /run/user/0

2. Репозиторий для резервных копий должен быть зашифрован ключом или паролем - на ваше усмотрение;

    данное условие выполняется при инициализации borg на сервере `client` при выполнении задачи 

        - name: init borg
        expect:
            command: borg init --encryption=repokey borg@192.168.11.160:/var/backup/
            responses:
            (?i)Enter new passphrase: "{{  borg_ps  }}"
            (?i)Enter same passphrase again: "{{  borg_ps  }}"
            (?i)Do you want your passphrase to be displayed for verification?: "n"

    пароль шифрования `Otus1234`

3. Имя бекапа должно содержать информацию о времени снятия бекапа;

    в данном случае имя задается в `unit` `borg-backup.service`

        ExecStart=/bin/borg create \
        --stats \
        ${REPO}::etc-{now:%%Y-%%m-%%d_%%H:%%M:%%S} ${BACKUP_TARGET}

4. Глубина бекапа должна быть год, хранить можно по последней копии на конец месяца, кроме последних трех. Последние три месяца должны содержать копии на каждый день. Т.е. должна быть правильно настроена политика удаления старых бэкапов;

    Это также указывается в `unit` `borg-backup.service`
    - для наглядности включил условие очистки резервных копий за последние 30 минут.

        ExecStart=/bin/borg prune \
        --keep-minutely 30 \
        --keep-daily 90 \
        --keep-monthly 12 \
        --keep-yearly 1 \
        $REPO

5. резервная копия снимается каждые 5 минут. Такой частый запуск в целях демонстрации;

    это указанов таймере `borg-backup.timer`

        [Timer]
        OnUnitActiveSec=5min

6. написан скрипт для снятия резервных копий. Скрипт запускается из соответствующей Cron джобы, либо systemd timer-а - на ваше усмотрение;
    
    - настроены `unit-ы` `borg-backup.service` и `borg-backup.timer` аналогичные службе из методички.
    - в этом `unit-е` `borg-backup.service` добавлены опции для пунктов `№3, №4, №5 и №7`

7. настроено логирование процесса бекапа. Для упрощения можно весь вывод перенаправлять в logger с соответствующим тегом. Если настроите не в syslog, то обязательна ротация логов.

    - в сервисе `borg-backup.service` добавлен вывод в syslog

            StandardOutput=syslog
            StandardError=syslog
            SyslogIdentifier=borg_service
    
    - `syslog` отправляет логи на сервер `log` и там логи складываются в файл `/var/log/borg_service.log`

            [root@log ~]# tail -f /var/log/borg_service.log 
            Feb 14 22:26:37 client borg_service: ------------------------------------------------------------------------------
            Feb 14 22:26:37 client borg_service: Archive name: etc-2022-02-14_22:26:36
            Feb 14 22:26:37 client borg_service: Archive fingerprint: 2f6e0560cfc2be2f1d74536f3c9ea777b90b34cd741b9f8124dc7bf07af4cc46
            Feb 14 22:26:37 client borg_service: Time (start): Mon, 2022-02-14 22:26:37
            Feb 14 22:26:37 client borg_service: Time (end):   Mon, 2022-02-14 22:26:37
            Feb 14 22:26:37 client borg_service: Duration: 0.22 seconds
            Feb 14 22:26:37 client borg_service: Number of files: 1724
            Feb 14 22:26:37 client borg_service: Utilization of max. archive size: 0%
            Feb 14 22:26:37 client borg_service: ------------------------------------------------------------------------------
            Feb 14 22:26:37 client borg_service: Original size      Compressed size    Deduplicated size
            Feb 14 22:26:37 client borg_service: This archive:               32.66 MB             15.15 MB                541 B
            Feb 14 22:26:37 client borg_service: All archives:               97.97 MB             45.44 MB             13.59 MB
            Feb 14 22:26:37 client borg_service: Unique chunks         Total chunks
            Feb 14 22:26:37 client borg_service: Chunk index:                    1306                 5155
            Feb 14 22:26:37 client borg_service: ------------------------------------------------------------------------------
            Feb 14 22:32:37 client borg_service: ------------------------------------------------------------------------------
            Feb 14 22:32:37 client borg_service: Archive name: etc-2022-02-14_22:32:36
            Feb 14 22:32:37 client borg_service: Archive fingerprint: b209cddc5415b0c32122c6f5cafdefeaa6be0f7e9eff3d18667447ff26e23625
            Feb 14 22:32:37 client borg_service: Time (start): Mon, 2022-02-14 22:32:37
            Feb 14 22:32:37 client borg_service: Time (end):   Mon, 2022-02-14 22:32:37
            Feb 14 22:32:37 client borg_service: Duration: 0.20 seconds
            Feb 14 22:32:37 client borg_service: Number of files: 1724
            Feb 14 22:32:37 client borg_service: Utilization of max. archive size: 0%
            Feb 14 22:32:37 client borg_service: ------------------------------------------------------------------------------
            Feb 14 22:32:37 client borg_service: Original size      Compressed size    Deduplicated size
            Feb 14 22:32:37 client borg_service: This archive:               32.66 MB             15.15 MB                541 B
            Feb 14 22:32:37 client borg_service: All archives:              130.63 MB             60.59 MB             13.59 MB
            Feb 14 22:32:37 client borg_service: Unique chunks         Total chunks
            Feb 14 22:32:37 client borg_service: Chunk index:                    1307                 6872
            Feb 14 22:32:37 client borg_service: ------------------------------------------------------------------------------


8. Запустите стенд на 30 минут. 

    Убедитесь что резервные копии снимаются. 

            [root@client ~]# borg list borg@192.168.11.160:/var/backup
            Enter passphrase for key ssh://borg@192.168.11.160/var/backup: 
            etc-2022-02-14_22:15:31              Mon, 2022-02-14 22:15:32 [1030084007c8a367469c8ec297632dbcef0b51bf05bf10644e98f874bca0bfb9]
            etc-2022-02-14_22:20:40              Mon, 2022-02-14 22:20:43 [cfa416bd26d46a6286f1bb8b91f1dafbce6d530370cfd13890911f1c6e7bebae]
            etc-2022-02-14_22:26:36              Mon, 2022-02-14 22:26:37 [2f6e0560cfc2be2f1d74536f3c9ea777b90b34cd741b9f8124dc7bf07af4cc46]
            etc-2022-02-14_22:32:36              Mon, 2022-02-14 22:32:37 [b209cddc5415b0c32122c6f5cafdefeaa6be0f7e9eff3d18667447ff26e23625]
            etc-2022-02-14_22:38:36              Mon, 2022-02-14 22:38:37 [320e9d66f48e173bfd618a180268311707cdf32602d1ab1b5494a4ceba9747a0]
            etc-2022-02-14_22:44:36              Mon, 2022-02-14 22:44:37 [2e537eb3a028ca9f5d9d8ed449d3af01bc3c3d94b2f1052fbf6e76e2031871d9]
            etc-2022-02-14_22:50:36              Mon, 2022-02-14 22:50:37 [99744acb9d2a9dc9b39c1ace3e9e8ca8450b59850a9235c84d01f309591ec584]
            etc-2022-02-14_22:56:36              Mon, 2022-02-14 22:56:37 [5f993422dfc5d10caf7433411918048a6fcc248c27e4a23ab3434486a97d2ce2]
            etc-2022-02-14_23:02:36              Mon, 2022-02-14 23:02:37 [221d6c7fcd19d49607c2121d2be52938c4699380e68efffb4d8d67128481f0c3]
            etc-2022-02-14_23:08:36              Mon, 2022-02-14 23:08:37 [055c028edf48a73a231e55c4add2323721b417e3e44d0df31443f32435157c38]
            etc-2022-02-14_23:14:36              Mon, 2022-02-14 23:14:37 [ad609fed464b43cc5fd02b37ea2d849dddf0631acb71a32390460f6203980712]

    Остановите бекап, удалите (или переместите) директорию /etc и восстановите ее из бекапа. 

    на сервере client 

            [root@client /]# systemctl stop borg-backup.timer 
            [root@client /]# mv /etc/ /etc_old
            [root@client /]# ls -l / | grep etc
            drwxr-xr-x. 80    0    0       8192 Feb 14 19:15 etc_old

    на сервере с резервной копией

            [root@backup ~]# borg extract /var/backup/::etc-2022-02-14_23:37:04
            Enter passphrase for key /var/backup: 
            [root@backup ~]# 
            [root@backup ~]# 
            [root@backup ~]# ls
            anaconda-ks.cfg  etc  original-ks.cfg

    далее для восстановления, 

    - вариант 1, при перезагрузке сервера, войти в сервисный режим или с загрузочного диска и с флешки восстановить данный раздел.
    - вариант 2, если это например vmware, то можно скопировать разде на виртуальный диск, т далее или подмонтировать в работающий и скопировать или как с вариантом 1
