FROM php:7.2-apache

MAINTAINER maxime.lucas@etu.utc.fr

USER root

RUN apt-get update \
	&& apt-get -y install git unzip

RUN docker-php-ext-install pdo_mysql

# Récupération des sources
WORKDIR /fabdb-src
RUN git clone https://github.com/ThomasCaud/fabDB.git .

# Configuration d'apache
ENV APACHE_DOCUMENT_ROOT /fabdb-src/web
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN sed -i '/#ServerRoot/a ServerName localhost' /etc/apache2/apache2.conf
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf
RUN sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:8080>/' /etc/apache2/sites-enabled/000-default.conf
ADD virtualHost.conf /etc/apache2/sites-enabled/
RUN mv /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf.disable
RUN mv /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load

# Configuration de l'appli
ADD parameters.yml app/config/parameters.yml
RUN curl -sS https://getcomposer.org/installer | php \
	&& php composer.phar install \
	&& php bin/console doctrine:schema:update --force \
	&& php bin/console doctrine:migrations:migrate -n
RUN mkdir /fabdb-src/var/sessions \
	&& mkdir /fabdb-src/var/sessions/prod \
	&& chmod -R 777 /fabdb-src/var/*
