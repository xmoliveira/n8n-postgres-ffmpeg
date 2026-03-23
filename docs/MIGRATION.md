# Guia Detalhado de Migração: n8n 2.9.3 → 2.12.3

## 📋 Visão Geral

Este documento detalha a migração completa de uma instância n8n 2.9.3 (SQLite) para 2.12.3 (PostgreSQL).

## ✅ Pré-requisitos

- [ ] Acesso completo à instância n8n 2.9.3
- [ ] Backup dos workflows
- [ ] Credenciais e API keys documentadas
- [ ] PostgreSQL 16+ disponível
- [ ] Docker e Docker Compose

## 📥 Fase 1: Exportar de n8n 2.9.3

### 1.1 Backup Completo

**Via UI:**
1. Login em n8n 2.9.3
2. Dashboard → Settings ⚙️
3. Scroll para "Export"
4. Selecionar: "Export all workflows"
5. Salvar arquivo como `workflows.json`

**Via CLI (se disponível):**
```bash
curl -X GET "http://n8n-2.9.3:3100/api/v1/workflows" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  > workflows.json
```

### 1.2 Backup do Banco de Dados SQLite

Se n8n 2.9.3 usa SQLite:

```bash
# Encontrar arquivo SQLite
find ~/.n8n -name "*.db" -type f

# Fazer backup
cp ~/.n8n/database.sqlite3 ./database_2.9.3_backup.sqlite3

# Converter para SQL (opcional)
sqlite3 database_2.9.3_backup.sqlite3 .dump > database_2.9.3.sql
```

### 1.3 Listar Credenciais

**Via UI:**
1. Dashboard → Credentials
2. Para cada credencial, anotar:
   - Nome
   - Tipo (OAuth, API Key, etc.)
   - Campos necessários (SEM copiar valores sensíveis!)

**Exemplo de documentação:**
```
Credencial: Slack Integration
Tipo: OAuth
Campos: access_token, channel_id
Status: Ativa em 5 workflows
```

## 🔧 Fase 2: Preparar Novo Ambiente (2.12.3)

### 2.1 Clonar Repositório

```bash
git clone https://github.com/xmoliveira/n8n-postgres-ffmpeg.git
cd n8n-postgres-ffmpeg
```

### 2.2 Configurar Variáveis de Ambiente

```bash
cp .env.example .env
```

Editar `.env`:
```env
DB_PASSWORD=seu_password_super_seguro_aqui
N8N_HOST=n8n.xavox.net
N8N_ADMIN_USER=admin@xavox.net
N8N_ADMIN_PASSWORD=outro_password_seguro
GENERIC_TIMEZONE=Europe/Lisbon
NODE_ENV=production
```

### 2.3 Iniciar Containers

```bash
docker-compose up -d

# Verificar status
docker-compose ps

# Ver logs
docker-compose logs -f n8n
```

**Aguardar até ver:**
```
n8n | n8n started successfully
```

## 📤 Fase 3: Importar Workflows

### 3.1 Via Interface Web

1. Acessar http://localhost:5678 (ou seu domínio)
2. **Settings** ⚙️ → **Import/Export**
3. **Import workflows**
4. Selecionar `workflows.json`
5. Confirmar importação

### 3.2 Verificar Importação

```bash
# Via container
docker-compose exec n8n n8n list workflows

# Esperar resultado
# Workflows imported: X
```

## 🔐 Fase 4: Reconectar Credenciais

### 4.1 Para Cada Workflow

1. **Dashboard** → **Workflows**
2. Abrir workflow
3. Identificar nós que usam credenciais ❗
4. Clicar no nó → **Credentials**

### 4.2 Tipos de Autenticação

#### OAuth (Slack, Google, etc.)

1. Credencial → **Connect**
2. Autorizar novo acesso
3. Testar conexão
4. Salvar

#### API Key / Bearer Token

1. Credencial → **Edit**
2. Colar token válido
3. **Test connection**
4. Salvar

#### Banco de Dados

1. Credencial → **Edit**
2. Confirmar:
   - Host: postgres (ou IP)
   - Port: 5432
   - Database: n8n
   - User: n8n
   - Password: (seu .env)
3. Testar
4. Salvar

## 🧪 Fase 5: Testar Workflows

### 5.1 Testes Unitários por Workflow

Para cada workflow crítico:

```bash
# 1. Abrir no editor
# 2. Clicar "Execute Workflow"
# 3. Verificar logs
# 4. Confirmar output esperado
```

### 5.2 Workflow de Teste Simples

Criar workflow temporário para validar FFmpeg:

```
Trigger: Manual
 ↓
Execute Command: ffmpeg -version
 ↓
Output: Salvar resultado
```

Executar e confirmar FFmpeg está disponível.

### 5.3 Teste de Banco de Dados

Criar workflow temporário:

```
Trigger: Manual
 ↓
PostgreSQL: SELECT version()
 ↓
Output: Mostrar versão
```

## 🔄 Fase 6: Migração Completa

### 6.1 Checklist Final

- [ ] Todos workflows importados
- [ ] Todas credenciais reconectadas
- [ ] Testes de execução passando
- [ ] Logs limpos (sem erros)
- [ ] Backups criados
- [ ] DNS aponta para novo servidor

### 6.2 Cutover (Mudar Tráfego)

```bash
# Fazer último backup do 2.9.3
./scripts/backup-database.sh

# Parar n8n 2.9.3
# (seu comando específico)

# Verificar novo ambiente
curl https://n8n.xavox.net/api/health

# Se OK, todos os tráfego agora → novo n8n
```

### 6.3 Rollback (se necessário)

```bash
# Reverter DNS para 2.9.3
# Restaurar backup do novo se detectar problema

docker-compose exec postgres psql -U n8n -d n8n < backups/pre_migration_backup.sql
```

## 📊 Pós-Migração

### Monitoramento

```bash
# Logs do n8n
docker-compose logs -f n8n

# Saúde de banco de dados
docker-compose exec postgres psql -U n8n -d n8n -c "SELECT version();"

# Estatísticas de workflows
# Dashboard → Execution History
```

### Otimizações n8n 2.12.3

1. **Ativar caching:**
   - Settings → Cache behavior

2. **Configurar rate limits:**
   - Settings → API rate limiting

3. **Habilitar logging detalhado:**
   - Environment: `LOG_LEVEL=debug` (temp apenas)

## ⚠️ Problemas Comuns

### PostgreSQL não conecta

```bash
# Verificar saúde do container
docker-compose ps

# Ver logs
docker-compose logs postgres

# Resetar se necessário
docker-compose down -v
docker-compose up -d
```

### Workflows com erro "Credentials not found"

1. Re-conectar credencial
2. Verificar tipo de credencial
3. Confirmar campos preenchidos

### FFmpeg não disponível em workflows

```bash
# Validar instalação
docker-compose exec n8n which ffmpeg
docker-compose exec n8n ffmpeg -version
```

### Workflows não executam após import

1. Verificar **Active toggle** (ativar workflow)
2. Validar **trigger**
3. Checar **node connections** (sem erros)
4. Testar credenciais novamente

## 🎯 Sucesso!

Quando você conseguir:

✅ Todos workflows listados  
✅ Credenciais autenticadas  
✅ Testes de execução OK  
✅ Sem erros em logs  
✅ Domínio acessível  

**Migração concluída!** 🎉

---

**Dúvidas?** Consulte:
- n8n Docs: https://docs.n8n.io/migrations/
- PostgreSQL: https://www.postgresql.org/docs/
