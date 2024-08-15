FROM composer:latest
RUN composer global require pheromone/phpcs-security-audit
WORKDIR /tmp
RUN sh ./vendor/pheromone/phpcs-security-audit/symlink.sh