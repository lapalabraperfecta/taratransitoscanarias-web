# Web de Tara Tránsitos Canarias: HTML estático + enviar.php, servido con Apache.
FROM php:8.3-apache

# msmtp: permite que mail() de PHP envíe por SMTP (el contenedor no tiene servidor de correo)
RUN apt-get update \
 && apt-get install -y --no-install-recommends msmtp ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Módulos que usa el .htaccess y permiso para que se aplique
RUN a2enmod rewrite expires deflate headers \
 && sed -ri 's!AllowOverride None!AllowOverride All!g' /etc/apache2/apache2.conf \
 && printf 'ServerTokens Prod\nServerSignature Off\n' > /etc/apache2/conf-enabled/zz-seguridad.conf \
 && printf 'sendmail_path = "/usr/bin/msmtp -t"\nexpose_php = Off\n' > /usr/local/etc/php/conf.d/correo.ini

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chown=www-data:www-data . /var/www/html/
RUN rm -rf /var/www/html/docker /var/www/html/Dockerfile \
 && chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]
