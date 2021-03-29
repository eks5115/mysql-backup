# mysql-backup

## docker

* build

```shell
cd docker && docker build -t eks5115/mysql-backup:latest . && cd ..
```

* debug

```shell
docker run -i -t --rm -e MYSQL_ALLOW_EMPTY_PASSWORD=true -v /path/mysql-backup:/opt/mysql-backup eks5115/mysql-backup:latest
```

## example


* physical backup

```shell
./backup.sh -t physical
```
