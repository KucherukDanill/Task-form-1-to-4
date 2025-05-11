# Задание 2: Docker и Nginx

## Описание задания
Разработка Docker-контейнера с Nginx, настроенного для работы с HTTPS и перенаправлением с HTTP на HTTPS.

## Результат 
![изображение](https://github.com/user-attachments/assets/457a37aa-a40a-4f9a-837b-d1be459916cb)
Результат выполнения `curl -vk https://localhost:443`
```bash
rem@ubuntu:~$ curl -vk https://localhost:443
* Host localhost:443 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
*   Trying [::1]:443...
* Connected to localhost (::1) port 443
* ALPN: curl offers h2,http/1.1
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
* TLSv1.3 (IN), TLS handshake, Finished (20):
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.3 (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384 / X25519 / RSASSA-PSS
* ALPN: server accepted http/1.1
* Server certificate:
*  subject: C=RU; ST=State; L=City; O=Organization; CN=localhost
*  start date: May 10 19:05:18 2025 GMT
*  expire date: May 10 19:05:18 2026 GMT
*  issuer: C=RU; ST=State; L=City; O=Organization; CN=localhost
*  SSL certificate verify result: self-signed certificate (18), continuing anyway.
*   Certificate level 0: Public key type RSA (2048/112 Bits/secBits), signed using sha256WithRSAEncryption
* using HTTP/1.x
> GET / HTTP/1.1
> Host: localhost
> User-Agent: curl/8.5.0
> Accept: */*
>
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* old SSL session ID is stale, removing
< HTTP/1.1 200 OK
< Server: nginx/1.26.3
< Date: Sun, 11 May 2025 18:14:53 GMT
< Content-Type: text/html
< Content-Length: 1472
< Last-Modified: Sat, 10 May 2025 19:13:48 GMT
< Connection: keep-alive
< ETag: "681fa56c-5c0"
< Accept-Ranges: bytes
<
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nginx</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 800px;
            margin: 0 auto;
            padding: 2em;
            background-color: #f0f0f0;
        }
        h1 {
            color: #0066cc;
            text-align: center;
            font-size: 2.5em;
            margin-bottom: 1em;
        }
        .info {
            background: #ffffff;
            padding: 1.5em;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            margin-bottom: 2em;
        }
        .info ul {
            list-style-type: none;
            padding: 0;
        }
        .info ul li {
            margin: 0.5em 0;
            font-size: 1.1em;
        }
    </style>
</head>
<body>
    <h1>Привет!</h1>

    <div class="info">
        <p>Привет, вот тебе краткая информация:</p>
        <ul>
            <li><strong>Сервер:</strong> Alpine Linux</li>
            <li><strong>Порты:</strong> 80</li>
            <li><strong>Кодировка:</strong> UTF-8</li>
            <li><strong>Защита:</strong> HTTPS с самоподписанным сертификатом</li>
        </ul>
    </div>
</body>
* Connection #0 to host localhost left intact
```
Результат выполенния `curl -vk http://localhost:80`

```bash
rem@ubuntu:~$ curl -vk http://localhost:80
* Host localhost:80 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
*   Trying [::1]:80...
* Connected to localhost (::1) port 80
> GET / HTTP/1.1
> Host: localhost
> User-Agent: curl/8.5.0
> Accept: */*
>
< HTTP/1.1 301 Moved Permanently
< Server: nginx/1.26.3
< Date: Sun, 11 May 2025 18:16:41 GMT
< Content-Type: text/html
< Content-Length: 169
< Connection: keep-alive
< Location: https://localhost/
<
<html>
<head><title>301 Moved Permanently</title></head>
<body>
<center><h1>301 Moved Permanently</h1></center>
<hr><center>nginx/1.26.3</center>
</body>
</html>
* Connection #0 to host localhost left intact
```

## Реализация

1. **Dockerfile** - для сборки образа Nginx с необходимыми конфигурациями:
   - Добавление конфигурационного файла Nginx
   - Настройка SSL-сертификатов
   - Настройка статических файлов

2. **nginx.conf** - конфигурационный файл Nginx, обеспечивающий:
   - Работу веб-сервера на порту 443 (HTTPS)
   - Использование самоподписанного сертификата для HTTPS
   - Правило редиректа с порта 80 на 443
   - Отдачу статических HTML-страниц

3. **docker-compose.yaml** - для управления контейнером:
   - Сборка образа из Dockerfile
   - Проброс портов 80 и 443
   - Монтирование статических файлов через volume
   - Настройка автозапуска контейнера при рестарте системы

## Запуск проекта
```bash
# Сборка и запуск контейнера
docker-compose up -d

# Проверка статуса
docker-compose ps

# Остановка контейнера
docker-compose down
```

## Проверка работы
После запуска контейнера можно проверить работу сервера:
- HTTP (порт 80): http://localhost - редирект на HTTPS
- HTTPS (порт 443): https://localhost - должна отобразиться статическая HTML-страница
