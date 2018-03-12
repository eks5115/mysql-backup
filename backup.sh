#!/usr/bin/env bash

set -e

# to work path
cd `dirname $0`

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
LOG_BIN_DIR=${BACKUP_DIR}/${DATE}/log-bin

mkdir -p ${SQL_DIR}
mkdir -p ${DATA_DIR}
mkdir -p ${LOG_BIN_DIR}

###
# backup data
mysqldump --host=${HOST} --port=${MYSQL_PORT} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --lock-all-tables --flush-logs --all-databases > ${SQL_DIR}/mysql-backup-${DATETIME}.sql
echo "`date +${DATETIME_FORMAT}`: backup data complete!" >> ${MYSQL_BACKUP_LOG}

###
# backup bin-log
if [ ${MYSQL_LOG_BIN_DIR} ];then
  rsync -a --include "${MYSQL_LOG_BIN}.*" --exclude '/*' ${SSH_USER}@${HOST}:${MYSQL_LOG_BIN_DIR}/ ${LOG_BIN_DIR}
  echo "`date +${DATETIME_FORMAT}`: backup bin-log complete!" >> ${MYSQL_BACKUP_LOG}
fi

###
# expired data
if [ ${EXPIRED_DATE} ];then

  find ${BACKUP_DIR} -maxdepth 1 -type d -ctime +${EXPIRED_DATE} -exec rm -rf {} \;
  echo "`date +${DATETIME_FORMAT}`: expired backup data delete complete!" >> ${MYSQL_BACKUP_LOG}
fi

echo "`date +${DATETIME_FORMAT}`: All backup success!" >> ${MYSQL_BACKUP_LOG}
echo -e "----------\n" >> ${MYSQL_BACKUP_LOG}