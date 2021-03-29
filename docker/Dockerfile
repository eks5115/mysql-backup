FROM mysql:5.7.33
WORKDIR /opt/mysql-backup
VOLUME /opt/mysql-backup
RUN apt-get update && apt-get install -y lsb-release curl \
    && curl -OL https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb \
    && dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb \
    && apt-get update && apt-get install -y percona-xtrabackup-24 \
    && rm -rf percona-release_latest.$(lsb_release -sc)_all.deb \
    && apt-get purge \
      && apt-get autoremove \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
      && rm -rf /tmp/*
