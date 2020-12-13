# Пятая лабораторная работа

## Установка

```bash
git clone https://github.com/assisken/admin-hw.git
cd 05_lvm
ansible-galaxy install -r requirements.yml
VAGRANT_EXPERIMENTAL="disks" vagrant up --provision

# Если не запустилось с первого раза:
vagrant halt
vagrant up --provision
```

## Задание

Что нужно сделать:

- Создать файловую систему на логическом томе;
- Смонтировать её;
- Создать файл, заполненный нулями на весь размер точки монтирования;
- Уменьшить файловую систему;
- Добавить несколько новых файлов и создать снимок;
- Удалить файлы и после монтирования снимка убедиться, что созданные нами файлы имеются на диске;
- Сделать слияние томов;
- Создать зеркало.

## Как работает

### 1. Создать файловую систему на логическом томе и смонтировать её

Для данной лабораторной работы был собран аналогичный предыдущену стенд - 5 виртуальных жёстких дисков по 2Гб.

Так же установим необходимый пакет командой:

```bash
$ sudo apt update && sudo apt install lvm2
```

Проверим базовую конфигурацию командами:

```bash
$ lsblk
$ lvmdiskscan
```

Добавим диск b как физический том командой, проверим создание командами:

```bash
$ sudo pvcreate /dev/sdb
$ sudo pvdisplay
$ sudo pvs
```

Далее создадим виртуальную группу командой и проверим корректность создания командами

```bash
$ sudo vgcreate labgr /dev/sdb
$ sudo vgdisplay -v labgr
$ sudo vgs
```

Повторим похожие действия для создания логической группы и проверяем:

```bash
$ sudo lvcreate -l+100%FREE -n first labgr
$ sudo lvdisplay
$ sudo lvs
```

Создадим файловую систему и смонтируем её:

```bash
$ sudo mkfs.ext4 /dev/mai/first
$ sudo mount /dev/labgr/first /mnt
$ sudo mount
```

### 2. Создать файл, заполенный нулями на весь размер точки монтирования

Для этого просто выполним команду, чтобы побайтово скопировать в файл 4500 чанков по 1М, после чего проверим состояние

```bash
$ sudo dd if=/dev/zero of=/mnt/mock.file bs=1M count=4500 status=progress
$ df -h
```

### 3. Расширить vg, lv и файловую систему

Введём команды:

```bash
$ sudo pvcreate /dev/sdc
$ sudo vgextend labgr /dev/sdc
$ sudo lvextend -l+100%FREE /dev/labgr/first
$ sudo lvdisplay
$ sudo lvs
$ sudo df -h
```

Теперь произведём расширение файловой системы:

```bash
$ sudo resize2fs /dev/labgr/first
$ sudo df -h
```

### 4. Уменьшить файловую систему

Для уменьшения ФС отмонтируем её, после чего пересоберём том и систему. При уменьшении размеров системы необходимо учитывать минимальное пространство, которое ей необходимо, чтобы не обрезать нужные файлы, поэтому был оставлен небольшой запас:

```bash
$ sudo umount /mnt
$ sudo fsck -fy /dev/labgr/first
$ sudo resize2fs /dev/labgr/first 2100M
$ sudo mount /dev/labgr/first /mnt
$ sudo df -h
```

### 5. Создать несколько новых файлов и создать снимок

Создадим несколько файлов и сделаем снимок. Для этого выполним следующую последовательность команд:

```bash
$ sudo touch /mnt/fillerfile{1..5}
$ ls /mnt
$ sudo lvcreate -L 100M -s -n log_snapsh /dev/mai/first
$ sudo lvs
$ sudo lsblk
```

Результат - в нашей vg создан снапшот, по которому можно будет откатить систему к состоянию на момент его создания:

### 6. Удалить файлы и после монтирования снимка убедиться, что созданные нами файлы присутствуют

Удалим файлы, после чего проверим есть ли удалённые файлы на снапшоте

```bash
$ sudo rm -f /mnt/fillerfile{1..3}
$ sudo mkdir /snapsh
$ sudo mount /dev/mai/log_snapsh /snapsh
$ ls /snapsh
$ sudo umount /snapsh
```

### 7. Сделать слияние томов

Чтобы выполнить слияние томов необходимо сначала отмонтировать систему, после ввести команды

```bash
$ sudo umount /mnt
$ sudo lvconvert --merge /dev/labgr/log_snapsh
$ sudo mount /dev/labgr/first /mnt
$ ls /mnt
```

### 8. Сделать зеркало

Для этого понадобится добавить еще устройств в PV, их я заготовил заранее аналогичным образом.  После создадим VG и смонтируем LV с флагом того, что она монтируется с созданием зеркала:

```bash
$ sudo vgcreate labgrMirror /dev/sd{d,e}
$ sudo lvcreate -l+100%FREE -m1 -n fMirror labgrMirror
```

Как видно из скрина, зеркало создано и синхронизировано.
