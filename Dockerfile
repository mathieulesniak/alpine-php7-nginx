FROM alpine:3.10
MAINTAINER Mathieu LESNIAK <mathieu@lesniak.fr>

RUN apk update && \
    apk add bash less geoip nginx nginx-mod-http-headers-more nginx-mod-http-geoip nginx-mod-stream nginx-mod-stream-geoip ca-certificates git tzdata zip \
    libmcrypt-dev zlib-dev gmp-dev freetype-dev libjpeg-turbo-dev libpng-dev curl \
    php7-common php7-fpm php7-json php7-zlib php7-xml php7-pdo php7-phar php7-openssl php7-fileinfo php7-imagick \
    php7-pdo_mysql php7-mysqli php7-session \
    php7-gd php7-iconv php7-mcrypt php7-gmp php7-zip \
    php7-curl php7-opcache php7-ctype php7-apcu php7-memcached \
    php7-intl php7-bcmath php7-dom php7-mbstring php7-simplexml php7-soap php7-tokenizer php7-xmlreader && apk add -u musl && \
    apk add msmtp && \
    rm -rf /var/cache/apk/*

RUN { \
    echo '[mail function]'; \
    echo 'sendmail_path = "/usr/bin/msmtp -t"'; \
    } > /etc/php7/conf.d/msmtp.ini

# opcode recommended settings
RUN { \
    echo 'opcache.memory_consumption=256'; \
    echo 'opcache.interned_strings_buffer=64'; \
    echo 'opcache.max_accelerated_files=25000'; \
    echo 'opcache.revalidate_path=0'; \
    echo 'opcache.enable_file_override=1'; \
    echo 'opcache.max_file_size=0'; \
    echo 'opcache.max_wasted_percentage=5;' \
    echo 'opcache.revalidate_freq=120'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=0'; \
    } > /etc/php7/conf.d/opcache-recommended.ini

# limits settings
RUN { \
    echo 'memory_limit=256M'; \
    echo 'upload_max_filesize=128M'; \
    echo 'max_input_vars=5000'; \
    echo "date.timezone='Europe/Paris'"; \
    } > /etc/php7/conf.d/limits.ini

RUN sed -i "s/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/nginx:x:100:101:nginx:\/usr:\/bin\/bash/g" /etc/passwd && \
    sed -i "s/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/nginx:x:100:101:nginx:\/usr:\/bin\/bash/g" /etc/passwd- && \
    ln -s /sbin/php-fpm7 /sbin/php-fpm

# Composer
RUN cd /tmp/ && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    composer self-update

ADD php-fpm.conf /etc/php7/
ADD nginx-site.conf /etc/nginx/nginx.conf
ADD entrypoint.sh /etc/entrypoint.sh

WORKDIR /var/www/
EXPOSE 80


ENTRYPOINT ["sh", "/etc/entrypoint.sh"]

