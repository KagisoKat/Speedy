#!/usr/bin/env bash
set -euo pipefail

DB_URL="${DATABASE_URL:-postgres://speedy_user:speedy_password@localhost:5432/speedy_db}"

echo "Applying migrations to: $DB_URL"

for f in /vagrant/apps/api/db/migrations/*.sql; do
  echo "Running $f"
  psql "$DB_URL" -v ON_ERROR_STOP=1 -f "$f"
done

echo "Migrations complete."
