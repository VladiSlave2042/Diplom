# Каво и ШО
1. Для начала запускаю main.tf разворачиваю инфроструктуру в практически завершенном виде, за исключением наличия у web машин доступа в сеть для добавления репозитория и загрузки пакетов.
2. После чего запускаем ансибл плейбук stable.
3. Для ансибла использовал Community.Postgresql набор модулей, это позваляет автоматизировать процесс создания базы, а в отличии от команд shell не вызывает ошибки при повторном прогоне.
4. Полагаю хэндлеры можно описать как часть плейбука а не для кажждой роли.