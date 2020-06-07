#!/bin/bash
set -e

if [[ "$ENVIRONMENT" = "production" ]]; then
  echo "Running production server on port 8000"
  tail -f /var/log/nginx/access.log
else
  echo "Running development server on http://localhost:8080"
  app/manage.py runserver 0:8080
fi
