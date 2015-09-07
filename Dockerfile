# Setup MariaDB official repo on CentOS 6

FROM centos:6.7
MAINTAINER George Liu <https://github.com/centminmod/docker-centos66-mariadb10>
# Setup MariaDB 10 on CentOS 6.7
RUN yum -y install epel-release nano which perl-DBI python-setuptools && yum -y install python-meld3 && rm -rf /var/cache/*; echo "" > /var/log/yum.log && easy_install pip && pip install supervisor && pip install supervisor-stdout
ADD supervisord.conf /etc/supervisord.conf
ADD supervisord_init /etc/rc.d/init.d/supervisord
RUN chmod +x /etc/rc.d/init.d/supervisord && mkdir -p /etc/supervisord.d/ && touch /var/log/supervisord.log && chmod 0666 /var/log/supervisord.log && rpm --import http://yum.mariadb.org/RPM-GPG-KEY-MariaDB
ADD mariadb.repo /etc/yum.repos.d/mariadb.repo
RUN echo "exclude=*.i386 *.i586 *.i686 nginx* php* mysql*">> /etc/yum.conf && rm -rf /var/lib/rpm/__db.00* && rpm --rebuilddb && yum update -y && rm -rf /var/cache/* && echo "" > /var/log/yum.log && mkdir -p /var/lib/mysql && groupadd mysql && useradd -r -g mysql mysql && chown -R mysql:mysql /var/lib/mysql && mkdir -p /home/mysqltmp && rm -rf /etc/my.cnf
RUN rm -rf /var/lib/rpm/__db.00* && rpm --rebuilddb && yum -y install MariaDB-client MariaDB-common MariaDB-compat MariaDB-devel MariaDB-server MariaDB-shared && rm -rf /var/cache/* && echo "" > /var/log/yum.log;
ADD my.cnf /etc/my.cnf
ADD mysqlsetup /root/tools/mysqlsetup
RUN chmod +x /root/tools/mysqlsetup && /root/tools/mysqlsetup
ADD mysqlstart /root/tools/mysqlstart
RUN chmod +x /root/tools/mysqlstart && ls -lah /var/lib/mysql && tail -80 /var/log/mysqld.log && yum -y install perl-DBD-MySQL && yum clean all && rm -rf /var/cache/* && echo "" > /var/log/yum.log && echo "" > /var/log/mysqld.log && echo "" > /var/log/yum.log && echo "" > /var/log/secure && echo "" > /var/log/messages

# Expose 3306 to outside
EXPOSE 3306

# Service to run
ENTRYPOINT ["/root/tools/mysqlstart"]