FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    git unzip libicu-dev libzip-dev libpng-dev libonig-dev \
    && docker-php-ext-install intl zip

RUN a2enmod rewrite

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copie d'abord composer.json et composer.lock
COPY ./src/composer.json ./
COPY ./src/composer.lock ./

# Installation des dépendances
RUN composer install --no-interaction --no-dev --optimize-autoloader

# Puis copie le reste du code
COPY ./src/ /var/www/html

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

RUN chown -R www-data:www-data /var/www/html

EXPOSE 80