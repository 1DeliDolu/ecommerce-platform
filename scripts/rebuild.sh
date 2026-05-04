#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -f .env ]; then
  ./scripts/dev-up.sh
  exit 0
fi

docker compose build --no-cache

# Postgres volume varsa mevcut şifreyi secret dosyasıyla eşitle
# (volume silerek rebuild yapmak veri kaybettirir; parola sync daha güvenli)
if docker volume inspect ecommerce-platform_postgres_data &>/dev/null; then
  SECRET_PW="$(cat secrets/postgres_password.txt 2>/dev/null || true)"
  if [ -n "$SECRET_PW" ]; then
    PG_USER="${POSTGRES_USER:-ecommerce_user}"
    PG_DB="${POSTGRES_DB:-ecommerce}"
    echo "Postgres kullanıcı parolası secret dosyasıyla eşitleniyor..."
    docker compose up -d postgres 2>/dev/null || true
    for i in $(seq 1 20); do
      docker compose exec postgres pg_isready -h 127.0.0.1 -U "$PG_USER" -d "$PG_DB" &>/dev/null && break
      sleep 2
    done
    docker compose exec postgres psql -U "$PG_USER" -d "$PG_DB" \
      -c "ALTER USER \"$PG_USER\" WITH PASSWORD '$SECRET_PW';" 2>/dev/null \
      && echo "Parola güncellendi." || echo "Parola güncellenemedi (ilk kurulumda normal)."
  fi
fi

docker compose up -d

echo ""
echo "Servisler yeniden build edilip başlatıldı."
echo "Log izlemek için: docker compose logs -f backend frontend"
