#!/bin/bash
# Script de migração de workflows do n8n 2.9.3 para 2.12.3

set -e

echo "🔄 Iniciando migração de workflows..."

# Variáveis
OLD_N8N_HOST="${OLD_N8N_HOST:-localhost:3100}"
NEW_N8N_HOST="${NEW_N8N_HOST:-localhost:5678}"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Criar diretório de backup
mkdir -p "$BACKUP_DIR"

echo "📦 Exportando workflows do n8n 2.9.3..."
# Este script assume que você exportou workflows.json manualmente
if [ ! -f "workflows.json" ]; then
    echo "❌ workflows.json não encontrado!"
    echo "   Exporte workflows manualmente de n8n 2.9.3:"
    echo "   Dashboard → Settings → Export workflows"
    exit 1
fi

echo "💾 Criando backup..."
cp workflows.json "$BACKUP_DIR/workflows_$TIMESTAMP.json"
echo "   ✅ Backup salvo em: $BACKUP_DIR/workflows_$TIMESTAMP.json"

echo "🔄 Aguardando n8n iniciar..."
sleep 10

echo "📥 Importando workflows no novo n8n..."
# Nota: A importação real é feita via UI de n8n
# Este script apenas prepara os dados

echo ""
echo "✅ Preparação concluída!"
echo ""
echo "Próximos passos (manual via UI):"
echo "1. Acesse http://localhost:5678"
echo "2. Dashboard → Settings → Import workflows"
echo "3. Selecione workflows.json"
echo "4. Reconecte credenciais de cada workflow"
echo "5. Teste a execução de cada workflow"
echo ""
echo "Credenciais precisam ser re-autenticadas:"
echo "- Dashboard → Credentials → Edit"
echo "- Re-inserir tokens/senhas"
echo "- Salvar e testar"
