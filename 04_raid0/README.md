# Третья лабораторная работа

## Установка

```bash
git clone https://github.com/assisken/admin-hw.git
cd 04_raid0
ansible-galaxy install -r requirements.yml
VAGRANT_EXPERIMENTAL="disks" vagrant up --provision

# Если не запустилось с первого раза
vagrant halt
VAGRANT_EXPERIMENTAL="disks" vagrant up --provision
```

## Задание

Практика с mdadm:

- Cобрать R0/R5/R10 на выбор
- Сломать и починить RAID;
- Проверить, что рейд собирается при перезагрузке;
- Cоздать на созданном RAID-устройстве раздел и файловую систему;
- Добавить запись в fstab для автомонтирования при перезагрузке.

## Дисклеймер

RAID 5 отпадает, т.к. на вики какого-то дистрибутива [написано](https://wiki.archlinux.org/index.php/RAID#Standard_RAID_levels),
что RAID 5 не рекомендуют применять в индустрии хранения данных.
Я человек простой, склонен доверять информации,
написанной на вики дистрибутивов.

RAID 10 работает как RAID 0 и RAID 1 и эффективно сочетает в себе
как плюсы RAID 0 и 1, так и минусы.
Поэтому беру RAID 10 в работу.

## Как работает

- [Инициализация дисков и их подключение к виртуальной машине](https://github.com/assisken/admin-hw/blob/master/04_raid0/Vagrantfile#L8-L15).
Фишка экспериментальная, поэтому нужно использовать с флагом `VAGRANT_EXPERIMENTAL="disks"`
- [Установка сторонней роли из ansible-galaxy](https://github.com/assisken/admin-hw/blob/master/04_raid0/requirements.yml).
*Зачем писать, когда можно одолжить у сообщества?*
- [Описан массив RAID10](https://github.com/assisken/admin-hw/blob/master/04_raid0/playbook.yml#L11-L24).
Просто удобно при инициализации. Да и в принципе можно править и запустить, если диск сломался.

## Проверка

```bash
$ vagrant ssh -c lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE   MOUNTPOINT
sda      8:0    0 19.8G  0 disk
├─sda1   8:1    0 18.8G  0 part   /
├─sda2   8:2    0    1K  0 part
└─sda5   8:5    0 1021M  0 part   [SWAP]
sdb      8:16   0 1000M  0 disk
└─md0    9:0    0    2G  0 raid10 /mnt/md0
sdc      8:32   0 1000M  0 disk
└─md0    9:0    0    2G  0 raid10 /mnt/md0
sdd      8:48   0 1000M  0 disk
└─md0    9:0    0    2G  0 raid10 /mnt/md0
sde      8:64   0 1000M  0 disk
└─md0    9:0    0    2G  0 raid10 /mnt/md0
sdf      8:80   0 1000M  0 disk
```

Да, примонтирован как `/mnt/md0`

```bash
$ vagrant ssh -c "grep /mnt/md0 /etc/fstab"
/dev/md0 /mnt/md0 ext4 defaults 0 0
```

При ребуте примонтируется. Проверим.

```bash
$ vagrant reload
...
$ vagrant ssh -c lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE   MOUNTPOINT
sda      8:0    0 19.8G  0 disk
├─sda1   8:1    0 18.8G  0 part   /
├─sda2   8:2    0    1K  0 part
└─sda5   8:5    0 1021M  0 part   [SWAP]
sdb      8:16   0 1000M  0 disk
└─md0    9:0    0    2G  0 raid10 /mnt/md0
sdc      8:32   0 1000M  0 disk
└─md0    9:0    0    2G  0 raid10 /mnt/md0
sdd      8:48   0 1000M  0 disk
└─md0    9:0    0    2G  0 raid10 /mnt/md0
sde      8:64   0 1000M  0 disk
└─md0    9:0    0    2G  0 raid10 /mnt/md0
sdf      8:80   0 1000M  0 disk
```

Да.

Сделаем вид, что предпоследний диск сломан.

```bash
$ sudo mdadm /dev/md0 --fail /dev/sdd
$ sudo mdadm /dev/md0 --remove /dev/sdd
$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE   MOUNTPOINT
sda      8:0    0 19.8G  0 disk
├─sda1   8:1    0 18.8G  0 part   /
├─sda2   8:2    0    1K  0 part
└─sda5   8:5    0 1021M  0 part   [SWAP]
sdb      8:16   0 1000M  0 disk
└─md0    9:0    0    2G  0 raid10 /mnt/md0
sdc      8:32   0 1000M  0 disk
└─md0    9:0    0    2G  0 raid10 /mnt/md0
sdd      8:48   0 1000M  0 disk
sde      8:64   0 1000M  0 disk
└─md0    9:0    0    2G  0 raid10 /mnt/md0
sdf      8:80   0 1000M  0 disk
```

Сделаем вид, что починили.

```bash
$ sudo mdadm --add /dev/md0 /dev/sdf
$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE   MOUNTPOINT
sda      8:0    0 19.8G  0 disk
├─sda1   8:1    0 18.8G  0 part   /
├─sda2   8:2    0    1K  0 part
└─sda5   8:5    0 1021M  0 part   [SWAP]
sdb      8:16   0 1000M  0 disk
└─md0    9:0    0    2G  0 raid10 /mnt/md0
sdc      8:32   0 1000M  0 disk
└─md0    9:0    0    2G  0 raid10 /mnt/md0
sdd      8:48   0 1000M  0 disk
sde      8:64   0 1000M  0 disk
└─md0    9:0    0    2G  0 raid10 /mnt/md0
sdf      8:80   0 1000M  0 disk
└─md0    9:0    0    2G  0 raid10 /mnt/md0
```

Проверим, что диск встал на правильную позицию в рейде.

```bash
$ sudo mdadm --detail /dev/md0 | tail -5
    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync set-A   /dev/sdb
       1       8       32        1      active sync set-B   /dev/sdc
       4       8       80        2      active sync set-A   /dev/sdf
       3       8       64        3      active sync set-B   /dev/sde
```

Всё очень хорошо.