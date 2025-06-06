# Скрипт мониторинга дискового пространства

Bash-скрипт для проверки свободного места на диске и отправки уведомлений на почту по протоколу SMTP, если свободного места меньше заданного порога.

## Что делает скрипт

- Проверяет свободное место на выбранном разделе диска
- Если свободного места меньше заданного порога (15%), отправляет уведомление на почту
- Использует SMTP для отправки писем (Gmail)

## Результат 
![изображение](https://github.com/user-attachments/assets/3705b26f-7c13-40f9-b2ad-7cf687cdfc4a)


## Установка

1. Установите необходимый пакет для отправки почты:
   ```
   sudo apt-get install ssmtp
   ```

2. Сделайте скрипт исполняемым:
   ```
   chmod +x alert.sh
   ```

## Настройка

В файле `alert.sh` измените следующие настройки:

### Для Gmail:
```bash
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT="587"
SMTP_USER="ваш_email@gmail.com"
SMTP_PASSWORD="пароль_приложения" 
EMAIL_FROM="ваш_email@gmail.com"
EMAIL_TO="адрес_получателя@example.com"
```
