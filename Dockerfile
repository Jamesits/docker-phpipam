FROM php:7-apache
MAINTAINER Pierre Cheynier <pierre.cheynier@sfr.com>

ENV PHPIPAM_SOURCE https://github.com/phpipam/phpipam/archive/
ENV PHPIPAM_VERSION 1.3
ENV WEB_REPO /var/www/html

# Enable apache modules
RUN a2enmod rewrite

# Install required deb packages
RUN apt-get update \
	&& apt-get install -y git php-pear php5-curl php5-mysql php5-json php5-gmp php5-mcrypt php5-ldap libgmp-dev libmcrypt-dev \
	&& ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
	&& rm -rf /var/lib/apt/lists/*

# Configure apache and required PHP modules 
RUN docker-php-ext-configure mysqli --with-mysqli=mysqlnd \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-configure gmp --with-gmp=/usr/include/x86_64-linux-gnu \
	&& docker-php-ext-install mysqli pdo_mysql gd gettext gmp mcrypt sockets \
	&& echo ". /etc/environment" >> /etc/apache2/envvars 

COPY php.ini /usr/local/etc/php/

# copy phpipam sources to web dir
# ADD ${PHPIPAM_SOURCE}/${PHPIPAM_VERSION}.tar.gz /tmp/
# RUN	tar -xzf /tmp/${PHPIPAM_VERSION}.tar.gz -C ${WEB_REPO}/ --strip-components=1

# # Use system environment variables into config.php
# RUN cp ${WEB_REPO}/config.dist.php ${WEB_REPO}/config.php && \
#     sed -i -e "s/\['host'\] = \"localhost\"/\['host'\] = getenv(\"PHPIPAM_DB_HOST\")/" \
#     -e "s/\['user'\] = \"phpipam\"/\['user'\] = getenv(\"PHPIPAM_DB_USER\")/" \
#     -e "s/\['pass'\] = \"phpipamadmin\"/\['pass'\] = getenv(\"PHPIPAM_DB_PASSWORD\")/" \
#     -e "s/\['name'\] = \"phpipamadmin\"/\['name'\] = getenv(\"PHPIPAM_DB_NAME\")/" \
# 	${WEB_REPO}/config.php

EXPOSE 80

