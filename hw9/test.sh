#!/bin/bash

# Получаем дату/время для отсчета начала парсинга
value=$(<.tmp/last_log_time.txt)
echo "$value"

grep -A1005000 -F "$value" access.log > 1.txt # Если нет совпаданий то получаем на вывод все строки из фала логов.

# Получаем топ 10 IP-адресов с сортировкой по наибольшему кол-ву 
awk -F" " '{print $1}' 1.txt | sort | uniq -c | sort -nr | head -10 > top10IP.txt
ip=$(cat top10IP.txt)

# Получаем топ 10 URL-адресов с сортировкой по наибольшему кол-ву 
awk -F" " '{print $7}' 1.txt | sort | uniq -c | sort -nr | head -10 > top10url.txt
url=$(cat top10url.txt)

# Получаем все ошибки с сортировкой по наибольшему кол-ву 
cat 1.txt | grep error > error.txt
err=$(cat error.txt)

# Получаем все коды с сортировкой по наибольшему кол-ву 
awk -F" " '{print $9}' 1.txt | sort | uniq -c | sort -nr > all_code.txt
code=$(cat all_code.txt)

# Готовим тело письма
echo -en "Subject: Some Bla Bla Bla Notification \

Top IP: \

$ip \

Top URL: \

$url \

All Errors: \

$err \

All codes: \

$code 
" > ./email.txt

# отправляем письмо 
sudo -u user@localhost < ./email.txt

# Определяем дату для переменной при следующем запуске
awk -F" " '{print $4}' access.log > ./tmp/date.log
sed -i 's/\[/ /g' ./tmp/date.log
tail -1 ./tmp/date.log > ./tmp/last_log_time.txt
last=$(<./tmp/last_log_time.txt )
echo "LT=$last"
