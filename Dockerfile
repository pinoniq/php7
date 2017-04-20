FROM php:7.1-fpm

MAINTAINER Jeroen "pinoniq" Meeus

# Copy our ini file
COPY ./conf/local.ini /usr/local/etc/php/conf.d/local.ini

# update apt
RUN apt-get update

# Set timezone
RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/Europe/Brussels /etc/localtime
RUN "date"

# install some basic tools
RUN apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        unzip \
        mysql-client \
        unzip \
        git \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# Install php-mysql and related libraries
RUN docker-php-ext-install pdo pdo_mysql

# Install xdebug
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug
RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.idekey=\"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Now we have that we need, we continue installing some usefull cli tools
## composer
# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version

## Symfony installer
RUN curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony \
    && chmod a+x /usr/local/bin/symfony

# add some useful symfony shortcuts
RUN echo 'alias dev="php bin/console --env=dev"' >> ~/.bashrc
RUN echo 'alias prod="php bin/console --env=prod"' >> ~/.bashrc

WORKDIR /var/www
