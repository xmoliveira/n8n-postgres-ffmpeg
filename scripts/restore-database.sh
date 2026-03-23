#!/bin/bash
# Restaurar base de dados PostgreSQL a partir de backup

if [ -z "$1" ]; then
    echo "Uso: ./restore-database.sh <backup_file.sql>"
    echo ""
    echo "Exemplo:"
    echo "  ./restore-database.sh ./backups/n8n_backup_20260323_103000.sql"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Arquivo não encontrado: $BACKUP_FILE"
    exit 1
fi

echo "⚠️  Restaurando banco de dados..."
echo "   Arquivo: $BACKUP_FILE"
read -p "Tem certeza? (s/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Operação cancelada."
    exit 1
fi

echo "🔄 Restaurando..."
docker-compose exec -T postgres psql \
    -U n8n \
    -d n8n \
    < "$BACKUP_FILE"

echo "✅ Restauração concluída!"
