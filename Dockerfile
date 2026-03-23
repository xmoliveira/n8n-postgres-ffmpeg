# Multi-stage build para n8n com PostgreSQL e FFmpeg 8.1
# Base: n8n 2.12.3

FROM n8n:2.12.3 as base

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    postgresql-client \
    libpq-dev \
    ffmpeg \
    python3 \
    python3-pip \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

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
    TZ=Europe/Lisbon

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5678/api/health || exit 1

EXPOSE 5678

CMD ["n8n", "start"]
