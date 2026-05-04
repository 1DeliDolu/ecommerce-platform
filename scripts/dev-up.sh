#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -f .env ]; then
  cp .env.example .env
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
