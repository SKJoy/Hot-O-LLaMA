# Always check `../Project.md` file for an entire knowledge of everything

FROM ollama/ollama:latest

ARG PHP_VERSION=8.4

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    nano \
    nginx \
    php${PHP_VERSION} \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-finfo \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-imap \
    php${PHP_VERSION}-json \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-mysqlnd \
    php${PHP_VERSION}-pdo-mysql \
    php${PHP_VERSION}-pdo-pgsql \
    php${PHP_VERSION}-pdo-sqlite \
    php${PHP_VERSION}-phar \
    php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-tokenizer \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --quiet

RUN sed -i "s|;syslog.facility = user|syslog.facility = user|" /etc/php/${PHP_VERSION}/fpm/php-fpm.conf \
    && sed -i "s|;syslog.ident = php-fpm|syslog.ident = php-fpm|" /etc/php/${PHP_VERSION}/fpm/php-fpm.conf \
    && sed -i "s|;error_log = /var/log/php-fpm.log|error_log = /var/log/php/fpm.log|" /etc/php/${PHP_VERSION}/fpm/php-fpm.conf \
    && sed -i "s|;catch_workers_output =|catch_workers_output = yes|" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

COPY Volume / 

EXPOSE 80 81 11434
CMD ["/System/Start.sh"]

# docker build -f Build/Dockerfile -t joy/hot-o-llama:latest Build/
# docker build -f Build/Dockerfile -t joy/hot-o-llama:latest Build/ --build-arg PHP_VERSION=8.4
# docker rmi joy/hot-o-llama:latest