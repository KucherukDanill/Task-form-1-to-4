#!/bin/bash

# Настройки для Gmail
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT="587"
SMTP_USER="gmail@gmail.com"  
SMTP_PASSWORD="secret"  # application passwords
EMAIL_FROM="gmail@gmail.com"  
EMAIL_TO="gmail@gmail.com"  

DISK="/"

MIN_FREE_SPACE=15

USED_PERCENT=$(LC_ALL=C df -h $DISK | grep -v Filesystem | awk '{print $5}' | tr -d '%')
FREE_PERCENT=$((100 - USED_PERCENT))

DISK_INFO=$(LC_ALL=C df -h $DISK | grep -v Filesystem)
TOTAL_SPACE=$(echo "$DISK_INFO" | awk '{print $2}')
USED_SPACE=$(echo "$DISK_INFO" | awk '{print $3}')
FREE_SPACE=$(echo "$DISK_INFO" | awk '{print $4}')

echo "Диск(раздел): $DISK"
echo "Всего: $TOTAL_SPACE"
echo "Использовано: $USED_SPACE ($USED_PERCENT%)"
echo "Свободно: $FREE_SPACE ($FREE_PERCENT%)"
echo "Порог: $MIN_FREE_SPACE%"

if [ $FREE_PERCENT -lt $MIN_FREE_SPACE ]; then
    echo "Внимание! Мало свободного места на диске!"
    
    HOSTNAME=$(hostname)
    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    SUBJECT="ВНИМАНИЕ: Мало места на диске $HOSTNAME - $DISK"
    
    EMAIL_CONTENT="
Внимание! Мало свободного места на диске!

Сервер: $HOSTNAME
Время: $DATE
Раздел: $DISK
Всего места: $TOTAL_SPACE
Использовано: $USED_SPACE ($USED_PERCENT%)
Свободно: $FREE_SPACE ($FREE_PERCENT%)
Порог: $MIN_FREE_SPACE%
"
    
    CONFIG_FILE=$(mktemp)
    cat > "$CONFIG_FILE" << EOF
mailhub=$SMTP_SERVER:$SMTP_PORT
AuthUser=$SMTP_USER
AuthPass=$SMTP_PASSWORD
UseTLS=YES
UseSTARTTLS=YES
FromLineOverride=YES
hostname=$HOSTNAME
EOF
    
    echo -e "To: $EMAIL_TO\nFrom: $EMAIL_FROM\nSubject: $SUBJECT\n\n$EMAIL_CONTENT" | ssmtp -C"$CONFIG_FILE" "$EMAIL_TO"
    
    rm -f "$CONFIG_FILE"
    
    echo "Уведомление отправлено на $EMAIL_TO"
else
    echo "Свободного места достаточно."
fi
