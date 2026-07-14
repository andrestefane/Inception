#!/bin/sh
set -eu

PASS_FILE="/run/secrets/db_password"
FTP_ROOT="/var/www/wordpress"

if [ -z "${FTP_USER:-}" ]; then
  echo "Missing env: FTP_USER" >&2
  exit 1
fi

if [ ! -f "$PASS_FILE" ]; then
  echo "Missing secret: db_password" >&2
  exit 1
fi

FTP_PASS="$(cat "$PASS_FILE")"

mkdir -p "$FTP_ROOT"
mkdir -p /var/run/vsftpd/empty

if ! id "$FTP_USER" >/dev/null 2>&1; then
  adduser -D -h "$FTP_ROOT" -s /bin/sh "$FTP_USER"
fi

echo "$FTP_USER:$FTP_PASS" | chpasswd

chown -R "$FTP_USER:$FTP_USER" "$FTP_ROOT"

exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf