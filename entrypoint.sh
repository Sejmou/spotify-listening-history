#!/bin/bash
# The entrypoint script for the Docker container
# Checks for required environment variables and executes the main process only if they are all set

# 'fun fact': arrays aren't supported in sh, but they do work in bash
required_vars=(
  "ORIGIN"
  "MAGE_API_URL"
  "MAGE_API_KEY"
  "MAGE_EMAIL"
  "MAGE_PASSWORD"
  "CLICKHOUSE_URL"
  "CLICKHOUSE_READONLY_USER_USERNAME"
  "CLICKHOUSE_READONLY_USER_PASSWORD"
  "CLICKHOUSE_KUBERNETES_URL"
  "CLICKHOUSE_KUBERNETES_READONLY_USER_USERNAME"
  "CLICKHOUSE_KUBERNETES_READONLY_USER_PASSWORD"
  "S3_KEY_ID"
  "S3_SECRET"
)

missing_vars=()
for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    missing_vars+=("$var")
  fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
  echo "Error: Missing required environment variables: ${missing_vars[*]}"
  exit 1
fi

# execute the Docker container's main process (i.e. the CMD specified in the Dockerfile)
exec "$@"