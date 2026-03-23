# Deploy em Coolify: n8n em n8n.xavox.net

## 🚀 Pré-requisitos

- [ ] Conta Coolify ativa
- [ ] Domínio `n8n.xavox.net` apontando para seu Coolify
- [ ] Repositório GitHub: `https://github.com/xmoliveira/n8n-postgres-ffmpeg`
- [ ] Credenciais GitHub para conectar repo

## 📍 Passo 1: Adicionar Repositório em Coolify

1. Login em Coolify → Dashboard
2. **New** → **Application from Git**
3. Selecionar **GitHub** como provider
4. Autorizar acesso ao GitHub (OAuth)
5. Selecionar repositório: `n8n-postgres-ffmpeg`
6. Branch: `main`
7. Clicar **Continue**

## ⚙️ Passo 2: Configurar Aplicação

### 2.1 Informações Básicas

- **Application name:** `n8n`
- **Publish port:** `443` (HTTPS)
- **Dockerfile:** `Dockerfile` (caminho padrão)
- **Docker Compose file:** `docker-compose.yml`

### 2.2 Ambiente & Variáveis

**Adicionar variáveis de ambiente:**

| Variável | Valor | Descrição |
|----------|-------|-----------|
| `DB_PASSWORD` | `sua_senha_super_segura` | Senha PostgreSQL |
| `N8N_HOST` | `n8n.xavox.net` | Domínio público |
| `N8N_ADMIN_USER` | `admin@xavox.net` | Admin login |
| `N8N_ADMIN_PASSWORD` | `outro_password_seguro` | Admin password |
| `N8N_PROTOCOL` | `https` | Usar HTTPS |
| `GENERIC_TIMEZONE` | `Europe/Lisbon` | Timezone |
| `NODE_ENV` | `production` | Ambiente |

**Clique "Add variable" para cada uma.**

## 🌐 Passo 3: Configurar Domínio

1. **Domains** tab
2. Clique **Add domain**
3. Inserir: `n8n.xavox.net`
4. Selecionar **Automatic HTTPS** (Let's Encrypt)
5. **Save**

⚠️ **Importante:** Seu DNS deve apontar para Coolify:
```bash
# Adicionar A record (ou CNAME se Coolify provide)
n8n.xavox.net → <ip_do_coolify>
```

Validar com:
```bash
dig n8n.xavox.net
# Deve retornar IP do Coolify
```

## 🔧 Passo 4: Configurar Recursos

Na seção **Resources**:

- **CPU**: 2 cores (mínimo)
- **Memory**: 2GB (mínimo)
- **Storage**: 20GB (PostgreSQL + dados)

## 🔐 Passo 5: Backup & Persistência

### 5.1 Volumes Persistentes

Coolify deve criar automaticamente:
- `n8n_data` → `/home/node/.n8n` (dados n8n)
- `postgres_data` → `/var/lib/postgresql/data` (banco)

Verificar em **Volumes** tab.

### 5.2 Backup Automático

1. **Settings** → **Backup**
2. Habilitar **Auto-backup**
3. Frequência: **Daily** (diariamente)
4. Reter: **30 days** (30 dias)

## 🚀 Passo 6: Deploy

1. Clicar **Deploy**
2. Coolify irá:
   - Fazer build da imagem Docker
   - Iniciar PostgreSQL
   - Iniciar n8n
   - Configurar HTTPS com Let's Encrypt
   - Acessível em https://n8n.xavox.net

**Progresso:**
```
Building... → Starting services... → Configuring HTTPS... → Live ✅
```

Tempo estimado: **5-10 minutos**

## ✅ Validação Pós-Deploy

```bash
# 1. Testar HTTPS
curl -I https://n8n.xavox.net
# HTTP/2 200 ✅

# 2. Acessar no navegador
# https://n8n.xavox.net
# Você deve ver login do n8n

# 3. Verificar certificado
openssl s_client -connect n8n.xavox.net:443
# Certificado Let's Encrypt válido ✅

# 4. Testar saúde
curl https://n8n.xavox.net/api/health
# {"status":"ok"} ✅
```

## 🔐 Passo 7: Login Inicial

1. Acessar https://n8n.xavox.net
2. Email: `admin@xavox.net`
3. Password: (aquele que configurou em `.env`)
4. Clicar **Login**

**Primeira vez:** n8n pedirá para completar setup.

## 📦 Passo 8: Importar Workflows

Após login:

1. **Settings** ⚙️ → **Import/Export**
2. **Import workflows**
3. Upload seu `workflows.json`
4. **Import**

Aguardar processamento...

## 🔄 Monitoramento Contínuo

### Logs
```
Coolify Dashboard → n8n → Logs
```

Ver em tempo real:
```
Last 100 lines, scroll para antigos
```

### Métricas
```
Coolify Dashboard → n8n → Metrics
```

Monitorar:
- CPU usage
- Memory usage
- Network I/O
- Disk usage

### Health Checks

Coolify executa automaticamente:
```bash
# A cada 30s
curl https://n8n.xavox.net/api/health
```

Se falhar 3x consecutivas → Alertar/reiniciar

## 🆘 Troubleshooting

### "Connection refused" ao acessar

```bash
# Verificar se containers estão rodando
# Em Coolify → Container status
# Se parado → clicar "Start"

# Verificar logs
# Coolify → Logs → ver erro específico
```

### "Certificate failed"

```bash
# Esperar 5-10 min (Let's Encrypt demora)
# Se persiste: Settings → Force renew certificate
```

### PostgreSQL crash

1. Coolify → Restart → Container
2. Coolify → Backup → Restore (se necessário)

### n8n lento / muita memória

Aumentar recursos:
```
Settings → Resources → Memory: 4GB (ou mais)
```

## 📈 Escalabilidade

Se precisar mais poder:

### Scale Up (Coolify)
```
Settings → Resources → Aumentar CPU/Memory
```

### Scale Out (Múltiplas instâncias)
```
Criar novo Application (mesmo repo)
Usar load balancer (Coolify pode fazer)
```

## 🔁 Atualizações

### Atualizar n8n (ex: 2.12.3 → 2.13.0)

1. Em seu repositório: `Dockerfile`
2. Mudar: `FROM n8n:2.12.3` → `FROM n8n:2.13.0`
3. Commit & push
4. Coolify detecta mudança → Pergunta para rebuild
5. Clicar **Rebuild & Deploy**
6. Novo build será feito
7. Rollback automático se falhar

### Manter Atualizado

```bash
# Setup renovate/dependabot no GitHub
# Cria PRs automáticas com novas versões

# Você só precisa revisar e fazer merge
```

## 🎉 Sucesso!

Quando você conseguir acessar https://n8n.xavox.net com login OK:

✅ Deploy em Coolify concluído  
✅ HTTPS automático funcionando  
✅ PostgreSQL persistente  
✅ Backups automáticos  
✅ Escalabilidade pronta  

---

**Próximo passo:** [MIGRATION.md](./MIGRATION.md) para importar workflows do n8n 2.9.3
