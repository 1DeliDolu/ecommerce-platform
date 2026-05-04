#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

generate_secret() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -base64 48
    return
  fi
  dd if=/dev/urandom bs=48 count=1 2>/dev/null | base64 | tr -d '\n'
}

# .env yoksa oluştur
if [ ! -f .env ]; then
  cp .env.example .env
  generated_secret="$(generate_secret)"
  sed -i "s#^JWT_SECRET=.*#JWT_SECRET=${generated_secret}#" .env
  echo ".env oluşturuldu. Production için değerleri değiştirin."
fi

# PostgreSQL secrets dosyası yoksa oluştur
mkdir -p secrets
if [ ! -f secrets/postgres_password.txt ]; then
  generate_secret | tr -d '\n' > secrets/postgres_password.txt
  chmod 644 secrets/postgres_password.txt
  echo "secrets/postgres_password.txt oluşturuldu."
fi

docker compose up --build -d

echo ""
echo "Servisler başlatıldı:"
echo "Frontend:    http://localhost:${FRONTEND_PORT:-3000}"
echo "Backend:     http://localhost:${BACKEND_PORT:-8080}/actuator/health"
echo "MailHog:     http://localhost:8025"
echo "PostgreSQL:  localhost:${POSTGRES_PORT:-5432}  (SSL zorunlu)"
echo ""
echo "Monitoring (--profile monitoring ile başlat):"
echo "Prometheus:  http://localhost:${PROMETHEUS_PORT:-9090}"
echo "Grafana:     http://localhost:${GRAFANA_PORT:-3001}  admin/admin"
echo ""
echo "Log izlemek için: docker compose logs -f backend frontend"
