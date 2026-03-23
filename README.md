# n8n PostgreSQL + FFmpeg

Imagem Docker customizada de **n8n 2.12.3** com **PostgreSQL** e **FFmpeg 8.1** pré-configurados.

## Características

- ✅ n8n 2.12.3 (última versão estável)
- ✅ PostgreSQL 16 como banco de dados
- ✅ FFmpeg 8.1 para processamento de vídeo
- ✅ Certificado HTTPS automático (Coolify)
- ✅ Timezone: Europe/Lisbon (UTC+0/+1)

## Deploy Rápido (Docker Compose)

```bash
# Clone e entre no diretório
git clone https://github.com/xmoliveira/n8n-postgres-ffmpeg.git
cd n8n-postgres-ffmpeg

# Configure as variáveis de ambiente
cp .env.example .env
# Edite .env com suas credenciais

# Inicie os serviços
docker-compose up -d

# Acesse em http://localhost:5678
```

## Deploy em Coolify

1. **Conecte seu repositório GitHub** em https://coolify.io
2. **Nova aplicação** → Selecione `n8n-postgres-ffmpeg`
3. **Configure domínio:** `n8n.xavox.net`
4. **Variáveis de ambiente:**
   ```
   DB_PASSWORD=your_secure_password
   N8N_HOST=n8n.xavox.net
   N8N_ADMIN_USER=admin@xavox.net
   N8N_ADMIN_PASSWORD=strong_password
   ```
5. **Deploy** → Coolify gera HTTPS automático

## Migração do n8n 2.9.3

### Pré-requisitos

- Backup da instância anterior (2.9.3)
- Acesso ao banco de dados PostgreSQL
- Credenciais e workflows exportados

### Passos

1. **Exporte workflows do n8n 2.9.3:**
   ```bash
   # Login no n8n 2.9.3
   # Dashboard → Settings → Export workflows
   # Salve como workflows.json
   ```

2. **Migre dados PostgreSQL:**
   ```bash
   # Se usar SQLite em 2.9.3, exporte para PostgreSQL
   pg_dump origem.db | psql -U n8n -d n8n -h localhost
   ```

3. **Importe workflows no novo n8n:**
   ```bash
   # Dashboard → Settings → Import workflows
   # Selecione workflows.json
   ```

4. **Reconecte credenciais:**
   ```
   Dashboard → Credentials → Re-authenticate integrations
   ```

## Estrutura de Arquivos

```
n8n-postgres-ffmpeg/
├── Dockerfile              # Imagem customizada
├── docker-compose.yml      # Orquestração (n8n + PostgreSQL)
├── .env.example            # Variáveis de ambiente
├── .dockerignore           # Arquivos ignorados no build
├── README.md               # Este arquivo
├── scripts/
│   ├── migrate-workflows.sh    # Script de migração
│   ├── backup-database.sh      # Backup PostgreSQL
│   └── restore-database.sh     # Restore PostgreSQL
└── docs/
    ├── MIGRATION.md        # Guia detalhado de migração
    ├── COOLIFY-SETUP.md    # Guia Coolify
    └── FFMPEG-USAGE.md     # Exemplos de uso FFmpeg
```

## Troubleshooting

### PostgreSQL não inicia
```bash
docker-compose logs postgres
# Verifique permissões de volume
chmod 700 postgres_data/
```

### n8n conecta mas workflows não carregam
```bash
# Verifique conexão PostgreSQL
docker-compose exec postgres psql -U n8n -d n8n -c "\dt"
```

### FFmpeg não reconhecido em workflows
```bash
# Verifique instalação
docker-compose exec n8n ffmpeg -version
```

## Suporte

- Issues: https://github.com/xmoliveira/n8n-postgres-ffmpeg/issues
- n8n Docs: https://docs.n8n.io
- FFmpeg: https://ffmpeg.org

## Licença

MIT - Vejo LICENSE para detalhes

---

**Mantido por:** Xavier Oliveira (@xmoliveira)  
**Última atualização:** 2026-03-23
