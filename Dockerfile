# Web de Tara Tránsitos Canarias: HTML estático + enviar.php, servido con Apache.
FROM php:8.3-apache

# msmtp: permite que mail() de PHP envíe por SMTP (el contenedor no tiene servidor de correo)
RUN apt-get update \
 && apt-get install -y --no-install-recommends msmtp ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Módulos que usa el .htaccess y permiso solo para las directivas que necesita
RUN a2enmod rewrite expires deflate headers \
 && printf '<Directory /var/www/html>\n  AllowOverride FileInfo Indexes\n</Directory>\nServerTokens Prod\nServerSignature Off\n' > /etc/apache2/conf-enabled/zz-web.conf \
 && printf 'sendmail_path = "/usr/bin/msmtp -t"\nexpose_php = Off\n' > /usr/local/etc/php/conf.d/correo.ini

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
# Archivos de la web de root y solo lectura para Apache
COPY . /var/www/html/
RUN rm -rf /var/www/html/docker /var/www/html/Dockerfile \
 && chown -R root:root /var/www/html \
 && find /var/www/html -type d -exec chmod 0755 {} + \
 && find /var/www/html -type f -exec chmod 0644 {} + \
 && chmod +x /usr/local/bin/entrypoint.sh

# Coolify usa esta comprobación para saber si la web responde (y para desplegar sin cortes)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -fsS -o /dev/null http://localhost/ || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]
