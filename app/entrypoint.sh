#!/usr/bin/env bash
set -e

# wait for postgres by attempting a psycopg2 connection in Python
host="${DB_HOST:-db}"
port=${DB_PORT:-5432}

echo "Waiting for postgres at ${host}:${port}..."
until python - <<'PY'
import os, sys
import psycopg2

host = os.getenv('DB_HOST', 'db')
port = int(os.getenv('POSTGRES_PORT', '5432'))
user = os.getenv('POSTGRES_USER', 'postgres')
db = os.getenv('POSTGRES_DB', 'aula_prova')
pw = os.getenv('POSTGRES_PASSWORD', '123456')
try:
  conn = psycopg2.connect(host=host, user=user, password=pw, dbname=db, port=port)
  conn.close()
  sys.exit(0)
except Exception as e:
  print('Waiting for DB:', e)
  sys.exit(1)
PY
do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

echo "Postgres is up - starting application"
exec gunicorn --bind 0.0.0.0:5000 app:app
