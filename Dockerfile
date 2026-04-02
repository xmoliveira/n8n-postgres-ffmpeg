# Multi-stage build para n8n com PostgreSQL e FFmpeg 8.1
# Base: Node.js Debian (porque n8nio/n8n é minimalista)

FROM node:22-slim

# Instalar dependências do sistema (Debian)
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    ffmpeg \
    python3 \
    python3-pip \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copiar n8n installer (alternativa: usar npm install n8n)
RUN npm install -g n8n

# Configurar n8n com suporte PostgreSQL
ENV DB_TYPE=postgresdb \
    DB_POSTGRESDB_HOST=postgres \
    DB_POSTGRESDB_PORT=5432 \
    DB_POSTGRESDB_DATABASE=n8n \
    DB_POSTGRESDB_USER=n8n \
    DB_POSTGRESDB_PASSWORD=changeme \
    N8N_PROTOCOL=https \
    N8N_HOST=n8n.xavox.net \
    N8N_PORT=443 \
    N8N_LISTEN_ADDRESS=0.0.0.0 \
    GENERIC_TIMEZONE=Europe/Lisbon \
    TZ=Europe/Lisbon \
    NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5678/api/health || exit 1

WORKDIR /home/node

EXPOSE 5678

USER node

CMD ["n8n", "start"]
