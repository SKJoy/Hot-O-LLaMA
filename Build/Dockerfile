# Always check `../Project.md` file for an entire knowledge of everything

FROM ollama/ollama:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    php8.4-cli \
    php8.4-fpm \
    php8.4-curl \
    php8.4-gd \
    php8.4-mbstring \
    php8.4-xml \
    php8.4-zip \
    && rm -rf /var/lib/apt/lists/*

# Configure PHP-FPM to use uniform log path
RUN sed -i 's|;syslog.facility = user|syslog.facility = user|' /etc/php/8.4/fpm/php-fpm.conf \
    && sed -i 's|;syslog.ident = php-fpm|syslog.ident = php-fpm|' /etc/php/8.4/fpm/php-fpm.conf \
    && sed -i 's|;error_log = /var/log/php-fpm.log|error_log = /var/log/php/fpm.log|' /etc/php/8.4/fpm/php-fpm.conf \
    && sed -i 's|;catch_workers_output =|catch_workers_output = yes|' /etc/php/8.4/fpm/pool.d/www.conf

COPY Volume / 

EXPOSE 80 11434
CMD ["/System/Start.sh"]