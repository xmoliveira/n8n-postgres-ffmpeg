# N8n latest com PostgreSQL + FFmpeg

FROM n8nio/n8n:latest

# Tentar instalar ffmpeg (assume que tem bash/sh)
RUN if command -v apt-get &> /dev/null; then \
      apt-get update && apt-get install -y ffmpeg && rm -rf /var/lib/apt/lists/*; \
    elif command -v apk &> /dev/null; then \
      apk add --no-cache ffmpeg; \
    else \
      echo "Aviso: Nenhum package manager encontrado"; \
    fi

# Configurar n8n
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

EXPOSE 5678

CMD ["n8n", "start"]
