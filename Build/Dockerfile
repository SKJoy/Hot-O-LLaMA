# Always check `../Project.md` file for an entire knowledge of everything

FROM ollama/ollama:latest

ARG PHP_VERSION=8.4

RUN apt-get update
RUN apt-get install -y curl nano --no-install-recommends
RUN apt-get install -y nginx --no-install-recommends
RUN apt-get install -y php${PHP_VERSION}-{cli,fpm,curl,finfo,gd,intl,imap,json,mbstring,mysqlnd,pdo-mysql,pdo-pgsql,pdo-sqlite,phar,sqlite3,tokenizer,xml,zip} --no-install-recommends
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --quiet
RUN rm -rf /var/lib/apt/lists/*

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