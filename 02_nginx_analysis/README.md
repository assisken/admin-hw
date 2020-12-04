# Вторая лабораторная работа

## Задание

Написать bash скрипт, анализирующий логи nginx

## Описание

Представляет собой скрипт для анализа логов nginx,
который показывает посещаемость сайта и его ресурсов.

## Функционал

- Имеет защиту от многократного запуска;
- Поддерживает поиск самых популярных и самых непопулярных ip,
запросов по роутам, а так же список ошибок 4хх и 5хх;
- Проверяет наличие файла по указанному маршруту;
- Проверяет что по указанному пути находится непустой файл;

## Требования

1. Командная оболочка bash
2. curl (для запуска без установки)
3. git (для запуска с установкой)

## Использование

Используя curl:

```bash
curl --silent https://raw.githubusercontent.com/assisken/admin-hw/master/02_nginx_analysis/script.sh | bash -s access.log all 5
```

С установкой и работы, используя демонстрационный access.log:

```bash
git clone https://github.com/assisken/admin-hw.git
cd 02_nginx_analysis
chmod +x script.sh
./script.sh access.log all 5
```

Чтобы поинтересоваться, что вводить скрипту, введите:

```bash
./script.sh --help
```

## Результат

```bash
Current date: 16/ноя/2020:11:53:28
Last analysis date: 16/ноя/2020:11:53:18
New records count: 51462

[Top 5 links]
   2350 216.46.173.126
   1720 180.179.174.219
   1439 204.77.168.241
   1365 65.39.197.164
   1202 80.91.33.133

[Low 5 links]
      1 104.130.12.114
      1 10.192.16.155
      1 101.87.40.200
      1 10.10.1.11

[Top 5 routes]
  30285 /downloads/product_1
  21104 /downloads/product_2
     73 /downloads/product_3

[Low 5 routes]
  30285 /downloads/product_1
  21104 /downloads/product_2
     73 /downloads/product_3

[Error List]
  33876 404
     38 403
      4 416
```
