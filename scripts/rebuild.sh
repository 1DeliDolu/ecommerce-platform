#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -f .env ]; then
  ./scripts/dev-up.sh
  exit 0
fi

docker compose build --no-cache
docker compose up -d

echo ""
echo "Servisler yeniden build edilip başlatıldı."
echo "Log izlemek için: docker compose logs -f backend frontend"
