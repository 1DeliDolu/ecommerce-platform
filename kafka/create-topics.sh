#!/usr/bin/env bash
set -euo pipefail

BOOTSTRAP_SERVER="${KAFKA_BOOTSTRAP_SERVER:-kafka:9092}"

topics=(
  "user.registered"
  "order.created"
  "payment.completed"
  "payment.failed"
  "inventory.updated"
  "audit.security-event"
)

for topic in "${topics[@]}"; do
  kafka-topics.sh \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --create \
    --if-not-exists \
    --topic "${topic}" \
    --partitions 3 \
    --replication-factor 1
done

kafka-topics.sh --bootstrap-server "${BOOTSTRAP_SERVER}" --list
