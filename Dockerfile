FROM ubuntu:20.04 AS builder
LABEL Author="Raja Subramanian" Description="A comprehensive docker image to run Apache-2.4 PHP-8.1 applications like Wordpress, Laravel, etc"


# Stop dpkg-reconfigure tzdata from prompting for input
ENV PHP_VERSION=7.1
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get upgrade -yq \
    && apt-get install -yq --no-install-recommends \
        apt-utils \
        curl \
        software-properties-common \
    && LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php \
    && apt-get remove --purge -y software-properties-common
# RUN apt update && apt -y install software-properties-common && add-apt-repository ppa:ondrej/php -y
# Install apache and php7
RUN apt update && \
    apt -y install apache2 \
        libapache2-mod-php${PHP_VERSION} \
        libapache2-mod-auth-openidc \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION} \
        php${PHP_VERSION}-dev \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-json \
        php${PHP_VERSION}-ldap \
        php${PHP_VERSION}-memcached \
        # php${PHP_VERSION}-mime-type \
        php${PHP_VERSION}-pgsql \
        php${PHP_VERSION}-tidy \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-xmlrpc \
        php${PHP_VERSION}-soap \
        php${PHP_VERSION}-uploadprogress \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-mongodb \
        nodejs \
        nano \
        git \
        npm \
        gcc \
        sudo \
        curl \
        wget \
        imagemagick
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
# Ensure apache can bind to 80 as non-root
    #     libcap2-bin && \
    setcap 'cap_net_bind_service=+ep' /usr/sbin/apache2 && \
    # dpkg --purge libcap2-bin && \
    # apt-get -y autoremove && \
# As apache is never run as root, change dir ownership
    a2disconf other-vhosts-access-log && \
    chown -Rh www-data. /var/run/apache2 
# Install ImageMagick CLI tools
    # apt-get -y install --no-install-recommends imagemagick && \
# Clean up apt setup files
    # apt-get clean && \
    # rm -rf /var/lib/apt/lists/* && \
# Setup apache
    # a2enmod rewrite headers expires ext_filter

# Override default apache and php config
COPY src/000-default.conf /etc/apache2/sites-available
COPY src/mpm_prefork.conf /etc/apache2/mods-available
COPY src/status.conf      /etc/apache2/mods-available
COPY src/99-local.ini     /etc/php/${PHP_VERSION}/apache2/conf.d


FROM scratch
COPY --from=builder / /
WORKDIR /var/www
RUN echo "www-data ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

EXPOSE 80
USER www-data

ENTRYPOINT ["apache2ctl", "-D", "FOREGROUND"]