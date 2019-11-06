#!/usr/bin/env bash

set -e

# to work path
cd `dirname $0`

# include conf
source './env.properties'

###
# backup
innobackupex --host="${HOST}" --port="${MYSQL_PORT}" --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" "${BACKUP_DIR}"

###
# expired date
if [ "${EXPIRED_DATE}" ];then
  let "EXPIRED_DATE = ${EXPIRED_DATE}-1"
  find "${BACKUP_DIR}" -maxdepth 1 -type d -ctime +${EXPIRED_DATE} -exec rm -rf {} \;
  echo "`date +${DATETIME_FORMAT}`: expired backup data delete complete!" >> ${MYSQL_BACKUP_LOG}
fi

echo "`date +${DATETIME_FORMAT}`: All backup success!" >> ${MYSQL_BACKUP_LOG}
echo -e "----------\n" >> ${MYSQL_BACKUP_LOG}