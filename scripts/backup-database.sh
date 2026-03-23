#!/bin/bash
# Backup de base de dados PostgreSQL

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/n8n_backup_$TIMESTAMP.sql"

mkdir -p "$BACKUP_DIR"

echo "💾 Criando backup PostgreSQL..."

docker-compose exec -T postgres pg_dump \
    -U n8n \
    -d n8n \
    --format=plain \
    > "$BACKUP_FILE"

if [ -f "$BACKUP_FILE" ]; then
    echo "✅ Backup criado: $BACKUP_FILE"
    echo "   Tamanho: $(du -h "$BACKUP_FILE" | cut -f1)"
else
    echo "❌ Erro ao criar backup"
    exit 1
fi
