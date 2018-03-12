#!/usr/bin/env bash

set -e

# to work path
cd `pwd`

# include conf
source './env.properties'

###
# date
DATE=`date +${DATE_FORMAT}`
DATETIME=`date +${DATETIME_FORMAT}`

echo "--------------------" >> ${MYSQL_BACKUP_LOG}
echo "----------" >> ${MYSQL_BACKUP_LOG}
echo "`date +${DATETIME_FORMAT}`: start mysql-backup " >> ${MYSQL_BACKUP_LOG}

###
# crate mysql-backup dir
if [ ! ${BACKUP_DIR} -o -z ${BACKUP_DIR} ];then
  # no BACKUP_DIR use default dir
  BACKUP_DIR="/var/mysql-backup"
fi

mkdir -p ${BACKUP_DIR}

SQL_DIR=${BACKUP_DIR}/${DATE}/sql
DATA_DIR=${BACKUP_DIR}/${DATE}/data
BIN_LOG_DIR=${BACKUP_DIR}/${DATE}/bin-log

mkdir -p ${SQL_DIR}
mkdir -p ${DATA_DIR}
mkdir -p ${BIN_LOG_DIR}

###
# backup data
mysqldump --host=${HOST} --port=${MYSQL_PORT} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --lock-all-tables --flush-logs --all-databases > ${SQL_DIR}/mysql-backup-${DATETIME}.sql
echo "`date +${DATETIME_FORMAT}`: backup data complete!" >> ${MYSQL_BACKUP_LOG}

###
# backup bin-log
if [ ${MYSQL_BIN_LOG_DIR} ];then
  rsync -a --include "${MYSQL_BIN_LOG}.*" --exclude '/*' ${SSH_USER}@${HOST}:${MYSQL_BIN_LOG_DIR}/ ${BIN_LOG_DIR}
  echo "`date +${DATETIME_FORMAT}`: backup bin-log complete!" >> ${MYSQL_BACKUP_LOG}
fi

###
# expired data
if [ ${EXPIRED_DATE} ];then

  find ${BACKUP_DIR} -type d -maxdepth 1 -ctime +${EXPIRED_DATE} -exec rm -rf {} \;
  echo "`date +${DATETIME_FORMAT}`: expired backup data delete complete!" >> ${MYSQL_BACKUP_LOG}
fi

echo "`date +${DATETIME_FORMAT}`: All backup success!" >> ${MYSQL_BACKUP_LOG}
echo -e "----------\n" >> ${MYSQL_BACKUP_LOG}