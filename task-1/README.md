# Ansible для настройки веб-сервера Nginx

## Структура проекта

```
.
├── ansible/
│   ├── inventory                
│   ├── playbook.yml             
│   └── roles/                  
│       └── nginx/               
│           ├── tasks/           
│           ├── handlers/        
│           ├── templates/       
│           └── vars/            
└── run_ansible.sh               
```

## Функциональность

Плейбук выполняет следующие действия:

1. Устанавливает пакет Nginx
2. Создает директорию для веб-сайта
3. Настраивает Nginx с поддержкой UTF-8
4. Запускает веб-сервер
5. Проверяет доступность по порту 80

## Запуск проекта

```bash
./run_ansible.sh
```

Или вручную:

```bash
cd ansible
ansible-playbook -i inventory playbook.yml --ask-become-pass | tee ansible_output.log
```

## Результат

После успешного выполнения плейбука, Nginx будет доступен по адресу:
```
http://localhost
```

