#!/bin/bash

read -p "Текущий пользователь: " CURRENT_USER
read -p "Целевой пользователь: " TARGET_USER

CURRENT_USER=$(echo "$CURRENT_USER" | iconv -f $(locale charmap) -t UTF-8)
TARGET_USER=$(echo "$TARGET_USER" | iconv -f $(locale charmap) -t UTF-8)

ACCESS_CHECK=$(psql -h pg -d studs -c "SELECT 1 FROM pg_namespace WHERE nspname = 'public';" 2>&1)

if [[ $ACCESS_CHECK == *"ERROR"* ]]; then
  echo "Ошибка доступа к базе данных."
  exit 1
fi

psql -h pg -d studs -c "CALL all_tables('$CURRENT_USER', '$TARGET_USER');" | sed 's|.*NOTICE:  ||g'
