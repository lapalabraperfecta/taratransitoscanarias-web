#!/bin/sh
# Genera la configuración SMTP a partir de las variables de entorno de Coolify.
set -e

if [ -n "$SMTP_HOST" ]; then
  PORT="${SMTP_PORT:-465}"
  if [ "$PORT" = "465" ]; then STARTTLS=off; else STARTTLS=on; fi

  cat > /etc/msmtprc <<EOF
defaults
auth on
tls on
tls_starttls $STARTTLS
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile -

account web
host $SMTP_HOST
port $PORT
user $SMTP_USER
password $SMTP_PASSWORD
from ${SMTP_FROM:-$SMTP_USER}

account default : web
EOF
  chown root:www-data /etc/msmtprc
  chmod 640 /etc/msmtprc
else
  echo "Aviso: SMTP_HOST no definido; el formulario de contacto no podrá enviar emails." >&2
fi

exec docker-php-entrypoint "$@"
