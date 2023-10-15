# Каво и ШО
## Сайт
### Сначала запускаем терраформ, разбил на несколько файлов для удобства работы с ними. Поднимается нужная нам инфроструктура в полностью завершенном виде. Убрал файлы пакетов из репозитория что бы место не занимали, терраформ и ансибл запускались с локальной виртуалки, но terraform из консоли, а с ансиблом тупо удобнее заботать из визуал студии. В остальном моменты закоментил что бы объяснить те или иные решения. Из стороннего использовал коллекцию postgresql для удобного создания пользователя и базы.
1. Запускаем сначала терраформ
---
![terraform apply](img/terraform%20apply.png)
---
![terraform complite](img/terraform%20complite.png)
---
![все вм](/img/VM.png)
---
2. Создайте Target Group, включите в неё две созданных ВМ.
---
![Target Group](/img/target%20grup.png)
---
3. Создайте Backend Group, настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.
---
![Backend Group](/img/backend-group.png)
---
4. Создайте HTTP router. Путь укажите — /, backend group — созданную ранее.
---
![HTTP router](/img/http-router.png)
---
5. Создайте Application load balancer для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.
---
![Application load balancer](/img/balanser.png)
---
6. Затем Ансибл (иначе на 80 порту глухо), перезапустил т.к. опечатка была в роли.
---
![ansible](/img/ansible.png)
---
![ansible complite](/img/ansible%20complite.png)
---
1. curl -v по адресу балансировщика (не вижу смысла отдельно добавлять курлы по каждому вебсерверу отдельно)
![curl](/img/curl%20-v.png)
---
![web-works](/img/web-works.png)
---
## Мониторинг
### Все сконфигурированно ансиблом, нам остается только залогинится и настроить дашборды
![zabbix-web-server](/img/zabbix-webserver-complite.png)
---
![zabbix-hosts](/img/zabbix-hosts.png)
---
![zabbix-dashbord](/img/zabbix-dashbord.png)
## Логи
### Ансибл делает все в исчерпывающем виде, рукми ничего делать не нужно, логи идут с обоих web серверов, так же виден и ip kibana, на всякий приложил скрин из консоли разработчика где видна доступность elastic
---
![логи](/img/логи.png)
---
![discover](/img/elc-discover.png)
---
![elastic](/img/elastic.png)
---
## Сеть
### Как я понимаю оценисть сеть можно исчерпывающи посмотрев файл terraform
![сеть](/img/network.png)
---
![sg](/img/secure-group.png)
---
![gateway](/img/gateway.png)
---
## Резервное копирование
### Сделал задачу в шедулере для ежедневного копирования в 0:00 (на лету подправил на 13 часов что бы снапшоты создались)
![snapshot](/img/snapshot.png)