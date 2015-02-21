# Setup MariaDB official repo on CentOS 6

FROM centos:6.6
MAINTAINER George Liu <https://github.com/centminmod/docker-centos66-mariadb10>
# Setup MariaDB 10 on CentOS 6.6
RUN yum -y install epel-release nano which perl-DBI
RUN yum -y install python-setuptools
RUN easy_install pip
RUN pip install supervisor
ADD supervisord.conf /etc/supervisord.conf
ADD supervisord_init /etc/rc.d/init.d/supervisord
RUN chmod +x /etc/rc.d/init.d/supervisord; mkdir -p /etc/supervisord.d/; touch /var/log/supervisord.log; chmod 0666 /var/log/supervisord.log
RUN rpm --import http://yum.mariadb.org/RPM-GPG-KEY-MariaDB
ADD mariadb.repo /etc/yum.repos.d/mariadb.repo
RUN echo "exclude=*.i386 *.i586 *.i686 nginx* php* mysql*">> /etc/yum.conf
RUN yum update -y
RUN mkdir -p /var/lib/mysql; groupadd mysql; useradd -r -g mysql mysql; chown -R mysql:mysql /var/lib/mysql
RUN yum -y install MariaDB-client MariaDB-common MariaDB-compat MariaDB-devel MariaDB-server MariaDB-shared
RUN ps auxf
RUN mkdir -p /home/mysqltmp; rm -rf /etc/my.cnf
ADD my.cnf /etc/my.cnf
RUN cat /etc/my.cnf
ADD mysqlsetup /root/tools/mysqlsetup
RUN chmod +x /root/tools/mysqlsetup; /root/tools/mysqlsetup
ADD mysqlstart /root/tools/mysqlstart
RUN chmod +x /root/tools/mysqlstart
# RUN /root/tools/mysqlstart; ps auxf
RUN ls -lah /var/lib/mysql
RUN tail -80 /var/log/mysqld.log
RUN yum -y install perl-DBD-MySQL; yum clean all
RUN rm -rf /var/cache/*; echo "" > /var/log/yum.log; echo "" > /var/log/mysqld.log; echo "" > /var/log/yum.log; echo "" > /var/log/secure; echo "" > /var/log/messages

# Expose 3306 to outside
EXPOSE 3306

# Service to run
ENTRYPOINT ["/root/tools/mysqlstart"]