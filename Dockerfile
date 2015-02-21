# Setup MariaDB official repo on CentOS 6

FROM centos:6.6
MAINTAINER George Liu <https://github.com/centminmod/docker-centos66-mariadb10>
# Setup MariaDB 10 on CentOS 6.6
RUN yum -y install epel-release nano which perl-DBI
RUN rpm --import http://yum.mariadb.org/RPM-GPG-KEY-MariaDB
ADD mariadb.repo /etc/yum.repos.d/mariadb.repo
RUN echo "exclude=*.i386 *.i586 *.i686 nginx* php* mysql*">> /etc/yum.conf
RUN yum update -y
RUN mkdir -p /var/lib/mysql
RUN groupadd mysql
RUN useradd -r -g mysql mysql
RUN chown -R mysql:mysql /var/lib/mysql
RUN yum -y install MariaDB-client MariaDB-common MariaDB-compat MariaDB-devel MariaDB-server MariaDB-shared
RUN ps auxf
RUN mkdir -p /home/mysqltmp
RUN rm -rf /etc/my.cnf
ADD my.cnf /etc/my.cnf
RUN cat /etc/my.cnf
ADD mysqlsetup /root/tools/mysqlsetup
RUN chmod +x /root/tools/mysqlsetup
RUN /root/tools/mysqlsetup
ADD mysqlstart /root/tools/mysqlstart
RUN chmod +x /root/tools/mysqlstart
# RUN /root/tools/mysqlstart
RUN ps auxf
RUN ls -lah /var/lib/mysql
RUN tail -80 /var/log/mysqld.log
RUN yum -y install perl-DBD-MySQL
RUN yum clean all
RUN rm -rf /var/cache/*
RUN echo "" > /var/log/yum.log
RUN echo "" > /var/log/mysqld.log
RUN echo "" > /var/log/yum.log
RUN echo "" > /var/log/secure
RUN echo "" > /var/log/messages

# Expose 3306 to outside
EXPOSE 3306

# Service to run
ENTRYPOINT ["/root/tools/mysqlstart"]