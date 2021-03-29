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

##
# $1 message
log() {
  echo "`date +${DATETIME_FORMAT}`": "$1" >> "${MYSQL_BACKUP_LOG}"
}

echo "--------------------" >> "${MYSQL_BACKUP_LOG}"
log "start mysql-backup"

conf() {
  ###
  # crate mysql-backup dir
  if [[ ! -d "${BACKUP_DIR}" ]];then
    # no BACKUP_DIR use default dir
    BACKUP_DIR="/var/mysql-backup"
  fi
  mkdir -p ${BACKUP_DIR}

  SQL_DIR=${BACKUP_DIR}/${DATE}/sql
  DATA_DIR=${BACKUP_DIR}/${DATE}/data
  LOG_BIN_DIR=${BACKUP_DIR}/log-bin
  LOG_BIN_DIR_TMP=${LOG_BIN_DIR}-tmp
  PHYSICAL_DIR=${BACKUP_DIR}/physical

  if [[ -d ${LOG_BIN_DIR} ]];then
    mv ${LOG_BIN_DIR} ${LOG_BIN_DIR_TMP}
  fi

  mkdir -p ${SQL_DIR}
  mkdir -p ${DATA_DIR}
  mkdir -p ${LOG_BIN_DIR}
  mkdir -p ${PHYSICAL_DIR}
}

logical() {
  ###
  # backup data
  mysqldump --host=${HOST} --port=${MYSQL_PORT} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --lock-all-tables --flush-logs --all-databases > ${SQL_DIR}/mysql-backup-${DATETIME}.sql
  log "backup data complete!"

  ###
  # backup bin-log
  if [ ${MYSQL_LOG_BIN_DIR} ];then
    rsync -a --include "${MYSQL_LOG_BIN}.*" --exclude '/*' ${SSH_USER}@${HOST}:${MYSQL_LOG_BIN_DIR}/ ${LOG_BIN_DIR}
    log "backup bin-log complete!"
  fi
}

physical() {
  log "physical backup start"
  innobackupex --host="${HOST}" --port="${MYSQL_PORT}" \
    --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" \
    --datadir="${MYSQL_DATA_DIR}" --stream=tar /tmp/backup |gzip > "${PHYSICAL_DIR}"/"${DATETIME}".tar.gz
  log "physical backup complete"
}

expired() {
  log "expired backup data delete start"
  find ${BACKUP_DIR} -maxdepth 1 -type d -ctime ${EXPIRED_DATE} -exec rm -rf {} \;
  log "expired backup data delete complete"
}

clean() {
  ###
  # clean
  rm -rf ${LOG_BIN_DIR_TMP}
}

while getopts t:x opt;
do
  case ${opt} in
    t)
      type=${OPTARG};;
    x)
      set -x;;
    ?)
      exit 1
      ;;
   esac
done

conf

if [[ ${type} = 'logical' ]];then
  logical
elif [[ ${type} = 'physical' ]];then
  physical
fi

###
# expired date
if [ ${EXPIRED_DATE} ];then
  expired
fi

clean

log "all backup success"
