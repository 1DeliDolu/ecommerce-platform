#!/usr/bin/env bash
set -euo pipefail

BOOTSTRAP_SERVER="${KAFKA_BOOTSTRAP_SERVER:-kafka:9092}"
KAFKA_TOPICS="${KAFKA_TOPICS_CMD:-/opt/kafka/bin/kafka-topics.sh}"

# fallback to PATH if the binary isn't at the expected location
if ! command -v "$KAFKA_TOPICS" >/dev/null 2>&1 && command -v kafka-topics.sh >/dev/null 2>&1; then
  KAFKA_TOPICS="kafka-topics.sh"
fi

topics=(
  "user.registered"
  "order.created"
  "payment.completed"
  "payment.failed"
  "inventory.updated"
  "audit.security-event"
)

for topic in "${topics[@]}"; do
  "$KAFKA_TOPICS" \
    --bootstrap-server "${BOOTSTRAP_SERVER}" \
    --create \
    --if-not-exists \
    --topic "${topic}" \
    --partitions 3 \
    --replication-factor 1
done

"$KAFKA_TOPICS" --bootstrap-server "${BOOTSTRAP_SERVER}" --list
