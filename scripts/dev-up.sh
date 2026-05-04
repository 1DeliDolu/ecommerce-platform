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

if [ ! -f .env ]; then
  cp .env.example .env
  generated_secret="$(generate_secret)"
  sed -i "s#^JWT_SECRET=.*#JWT_SECRET=${generated_secret}#" .env
  echo ".env oluşturuldu. Production için değerleri değiştirin."
fi

docker compose up --build -d

echo ""
echo "Servisler başlatıldı:"
echo "Frontend:    http://localhost:3000"
echo "Backend:     http://localhost:8080/api/health"
echo "Prometheus:  http://localhost:9090"
echo "Grafana:     http://localhost:3001  admin/admin"
echo "PostgreSQL:  localhost:5432"
echo ""
echo "Log izlemek için: docker compose logs -f backend frontend"
