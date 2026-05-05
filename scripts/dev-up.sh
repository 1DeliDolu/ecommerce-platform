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
  echo ".env oluşturuldu. Production için değerleri değiştirin."
fi

# PostgreSQL secrets dosyası yoksa oluştur
mkdir -p secrets
if [ ! -f secrets/postgres_password.txt ]; then
  generate_secret | tr -d '\n' > secrets/postgres_password.txt
  chmod 644 secrets/postgres_password.txt
  echo "secrets/postgres_password.txt oluşturuldu."
fi

# JWT RSA keypair yoksa oluştur
if [ ! -f secrets/jwt_private_key.pem ] || [ ! -f secrets/jwt_public_key.pem ]; then
  echo "JWT RSA keypair oluşturuluyor..."
  openssl genrsa -out /tmp/jwt_rsa_tmp.pem 2048 2>/dev/null
  openssl pkcs8 -topk8 -nocrypt -in /tmp/jwt_rsa_tmp.pem -out secrets/jwt_private_key.pem
  openssl rsa -in /tmp/jwt_rsa_tmp.pem -pubout -out secrets/jwt_public_key.pem 2>/dev/null
  rm -f /tmp/jwt_rsa_tmp.pem
  chmod 600 secrets/jwt_private_key.pem
  chmod 644 secrets/jwt_public_key.pem
  echo "JWT RSA keypair secrets/ klasörüne oluşturuldu."
fi

docker compose up --build -d

echo ""
echo "Servisler başlatıldı:"
echo "Frontend:    http://localhost:${FRONTEND_PORT:-3000}"
echo "Backend:     http://localhost:${BACKEND_PORT:-8080}/actuator/health"
echo "Swagger:     http://localhost:${BACKEND_PORT:-8080}/swagger-ui.html"
echo "MailHog:     http://localhost:8025"
echo "Kafka UI:    http://localhost:${KAFKA_UI_PORT:-8085}"
echo "RabbitMQ:    http://localhost:${RABBITMQ_MANAGEMENT_PORT:-15672}  (ecommerce/ecommerce)"
echo "Airflow:     http://localhost:${AIRFLOW_PORT:-8088}  (admin/admin)"
echo "PostgreSQL:  localhost:${POSTGRES_PORT:-5432}  (SSL zorunlu)"
echo ""
echo "Monitoring (--profile monitoring ile başlat):"
echo "Prometheus:  http://localhost:${PROMETHEUS_PORT:-9090}"
echo "Grafana:     http://localhost:${GRAFANA_PORT:-3001}  admin/admin"
echo ""
echo "pgAdmin (--profile tools ile başlat):"
echo "pgAdmin:     http://localhost:${PGADMIN_PORT:-5050}  admin@local.dev / admin123"
echo ""
echo "Log izlemek için: docker compose logs -f backend frontend"
