# 🚀 Setup Rápido: n8n PostgreSQL + FFmpeg

## 📋 Verificação de Pré-requisitos

```bash
# Docker
docker --version    # v20.10+

# Docker Compose
docker-compose --version  # v2.0+

# Git
git --version       # v2.30+
```

## 🔧 Setup Local (5 minutos)

### 1️⃣ Clonar Repositório

```bash
git clone https://github.com/xmoliveira/n8n-postgres-ffmpeg.git
cd n8n-postgres-ffmpeg
```

### 2️⃣ Configurar Variáveis

```bash
cp .env.example .env
# Editar .env com valores seguros
nano .env
```

**Valores mínimos:**
```env
DB_PASSWORD=seu_password_bem_seguro_aqui
N8N_HOST=n8n.xavox.net
N8N_ADMIN_USER=admin@xavox.net
N8N_ADMIN_PASSWORD=outro_password_seguro
```

### 3️⃣ Iniciar Containers

```bash
docker-compose up -d

# Verificar status
docker-compose ps

# Ver logs (Ctrl+C para sair)
docker-compose logs -f n8n
```

### 4️⃣ Acessar n8n

Abrir navegador:
```
http://localhost:5678
```

Login:
- Email: `admin@xavox.net`
- Password: (valor do `.env`)

## ✅ Validações

### Verificar PostgreSQL

```bash
docker-compose exec postgres psql -U n8n -d n8n -c "SELECT version();"
```

Esperado:
```
PostgreSQL 16.x on...
```

### Verificar FFmpeg

```bash
docker-compose exec n8n ffmpeg -version
```

Esperado:
```
ffmpeg version 8.1...
```

### Teste de Workflow

1. Em n8n: **New Workflow**
2. Adicionar node: **Execute Command**
3. Command: `ffmpeg -version`
4. Clicar **Execute**
5. Ver output com versão FFmpeg

## 📚 Próximas Etapas

1. **Migrate:** Veja [docs/MIGRATION.md](./docs/MIGRATION.md)
   - Importar workflows do n8n 2.9.3

2. **Deploy:** Veja [docs/COOLIFY-SETUP.md](./docs/COOLIFY-SETUP.md)
   - Deploy em produção em n8n.xavox.net

3. **FFmpeg:** Veja [docs/FFMPEG-USAGE.md](./docs/FFMPEG-USAGE.md)
   - Exemplos de workflows com FFmpeg

## 🐛 Troubleshooting

### "Permission denied" ao iniciar

```bash
# Dar permissões ao Docker
sudo usermod -aG docker $USER
# Logout e login novamente
```

### PostgreSQL "port already in use"

```bash
# Mudar porta em docker-compose.yml
# Linha: ports: - "5433:5432" (5433 ao invés de 5432)
docker-compose up -d
```

### n8n não inicia

```bash
# Ver logs detalhados
docker-compose logs n8n

# Reiniciar
docker-compose restart n8n
```

## 🔐 Segurança

### Trocar Senhas

No `.env`:
- `DB_PASSWORD`: mínimo 20 caracteres
- `N8N_ADMIN_PASSWORD`: mínimo 20 caracteres
- Usar mix de maiúsculas, minúsculas, números, símbolos

### Backup

```bash
# Backup PostgreSQL
./scripts/backup-database.sh

# Backup automático
# Adicionar ao cron:
0 3 * * * cd /caminho/repo && ./scripts/backup-database.sh
```

### Firewall (Produção)

```bash
# Apenas autorizar tráfego HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw deny from any to any port 5432
```

## 📞 Suporte

- **n8n Docs:** https://docs.n8n.io
- **FFmpeg Wiki:** https://trac.ffmpeg.org/wiki
- **Issues:** https://github.com/xmoliveira/n8n-postgres-ffmpeg/issues

---

**Pronto!** Você agora tem n8n 2.12.3 rodando localmente. 🎉

Próximo passo: Deploy em Coolify ou importar workflows existentes.
