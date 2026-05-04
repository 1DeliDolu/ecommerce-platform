#!/bin/sh
# Read Docker secret into env var so Spring Boot can use it without configtree permission issues
SECRET_FILE="/run/secrets/spring.datasource.password"
if [ -f "$SECRET_FILE" ]; then
  SPRING_DATASOURCE_PASSWORD=$(cat "$SECRET_FILE")
  export SPRING_DATASOURCE_PASSWORD
fi

exec java -jar app.jar "$@"
