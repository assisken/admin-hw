# Третья лабораторная работа

- [Первое задание](#первое-задание)
- [Второе задание](#второе-задание)

## Установка

```bash
git clone https://github.com/assisken/admin-hw.git
cd 03_auth
vagrant up --provision

# Если не запустилось с первого раза
vagrant halt
vagrant up --provision
```

## Первое задание

1. [x] Создать нескольких пользователей, задать им пароли,
домашние директории и шеллы;
2. [x] Создать группу admin;
3. [x] Включить нескольких из ранее созданных пользователей,
а также пользователя root, в группу admin;
4. [x] Запретить всем пользователям, кроме группы admin,
логин в систему по SSH в выходные дни
(суббота и воскресенье, без учета праздников);
5. [ ] \*С учётом праздничных дней.

Для упрощения проверки можно разрешить парольную аутентификацию по SSH
и использовать ssh user@localhost проверяя логин с этой же машины.

## Как работает

1. [Создание нескольких пользователей](https://github.com/assisken/admin-hw/blob/master/03_auth/playbook.yml#L23-L40)
2. [Создание группы admin](https://github.com/assisken/admin-hw/blob/master/03_auth/playbook.yml#L12-L14)
3. [Включение пользователя root в группу admin](https://github.com/assisken/admin-hw/blob/master/03_auth/playbook.yml#L16-L21)
4. Запрет всем пользователям, кроме admin вход в систему по выходным:
[pam](https://github.com/assisken/admin-hw/blob/master/03_auth/templates/pam-sshd.j2),
[script](https://github.com/assisken/admin-hw/blob/master/03_auth/templates/admin-weekends.sh),
[playbook](https://github.com/assisken/admin-hw/blob/master/03_auth/playbook.yml#L53-L67).
5. С учётом праздничных дней. *Нету, такое на баше писать стрёмно.*

## Второе задание

1. [x] Установить docker
2. [x] Дать конкретному пользователю:
    - [x] Права работать с docker (выполнять команды docker ps и т.п.);
    - [x] \*Возможность перезапускать демон docker (systemctl restart docker)
    не выдавая прав более, чем для этого нужно;

## Как работает

1. [Установка docker](https://github.com/assisken/admin-hw/blob/master/03_auth/playbook.yml#L70-L73)
2. Выдача прав на работу с docker, возможность перезапускать демон:
[sudoers](https://github.com/assisken/admin-hw/blob/master/03_auth/templates/docker-sudoers.j2),
[playbook](https://github.com/assisken/admin-hw/blob/master/03_auth/playbook.yml#L81-L105).
