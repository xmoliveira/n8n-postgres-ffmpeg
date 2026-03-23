# Usando FFmpeg em Workflows n8n

## 🎬 O que é FFmpeg?

FFmpeg é ferramenta poderosa para processamento de áudio/vídeo:
- Converter formatos (MP4 → WebM, etc.)
- Extrair frames
- Cortar/editar vídeos
- Processar áudio (compressão, extração)
- Transcodificação em lote

## ✅ Validar Instalação

No seu workflow, criar teste:

**Node: Execute Command**

```bash
ffmpeg -version
```

**Resultado esperado:**
```
ffmpeg version 8.1 Copyright (c) 2000-2024...
```

Se OK → FFmpeg disponível! ✅

## 📝 Exemplos de Workflows

### Exemplo 1: Converter MP4 → WebM

```json
{
  "nodes": [
    {
      "parameters": {
        "command": "ffmpeg -i /tmp/input.mp4 -c:v libvpx-vp9 -crf 30 /tmp/output.webm"
      },
      "name": "Execute Command",
      "type": "n8n-nodes-base.executeCommand",
      "typeVersion": 1,
      "position": [250, 300]
    }
  ],
  "connections": {}
}
```

### Exemplo 2: Extrair Frame do Vídeo

```bash
# Extrair frame em 00:05 segundos
ffmpeg -i input.mp4 -ss 00:00:05 -vframes 1 frame.png
```

**Node em n8n:**
- Input: URL do vídeo
- Command: executar ffmpeg acima
- Output: salvar frame em `/tmp/`
- Response: URL do frame gerado

### Exemplo 3: Comprimir Áudio MP3

```bash
# Converter para 128kbps (reduz 50% tamanho)
ffmpeg -i input.mp3 -q:a 4 -acodec libmp3lame output.mp3
```

### Exemplo 4: Crop/Cortar Vídeo

```bash
# Pegar 30 segundos do vídeo (início em 10s)
ffmpeg -i input.mp4 -ss 10 -t 30 -c:v copy -c:a copy output.mp4
```

**Parâmetros:**
- `-ss 10`: Iniciar no segundo 10
- `-t 30`: Duração de 30 segundos
- `-c:v copy`: Copiar vídeo (sem re-encode)
- `-c:a copy`: Copiar áudio

## 🔗 Integração com n8n

### Pattern: Arquivo → Processar → Guardar

```
Trigger: HTTP Request (recebe URL do vídeo)
  ↓
Execute Command: ffmpeg -i {url} -c:v copy output.mp4
  ↓
Write Binary File: salvar em /tmp/processed/
  ↓
HTTP Response: retornar URL do arquivo processado
```

### Pattern: Webhook → Processar → Email

```
Trigger: Webhook (upload de vídeo)
  ↓
Move Binary: transferir arquivo para /tmp/
  ↓
Execute Command: ffmpeg -i /tmp/video.mp4 -c:v libx264 -preset fast output.mp4
  ↓
Send Email: "Vídeo processado, URL: {arquivo}"
```

## 📊 Casos de Uso Reais

### Use Case 1: Otimizar Vídeos para Web

**Problema:** Vídeos grandes (500MB+) demora para carregar

**Solução:**

```bash
ffmpeg -i large.mp4 \
  -c:v libx264 \
  -preset medium \
  -crf 28 \
  -c:a aac \
  -b:a 128k \
  optimized.mp4
```

Resultado: 500MB → 50MB (90% compressão) ✅

### Use Case 2: Gerar Thumbnails em Lote

```bash
# Extrair 5 frames de vídeos
for video in *.mp4; do
  ffmpeg -i "$video" \
    -vf "fps=1/5" \
    "thumbnails/${video%.mp4}_%03d.png"
done
```

Em n8n:
- Loop através de lista de vídeos
- Executar ffmpeg para cada
- Guardar URLs em banco de dados

### Use Case 3: Converter Livestream HLS → MP4

```bash
ffmpeg -i "https://stream.example.com/live.m3u8" \
  -c copy \
  -bsf:a aac_adtstoasc \
  output.mp4
```

Captura livestream e salva em arquivo.

### Use Case 4: Extrair Áudio de Vídeo

```bash
ffmpeg -i video.mp4 \
  -q:a 0 \
  -map a \
  audio.mp3
```

Perfeito para: podcasts, aulas, videoaulas

## ⚙️ Parâmetros Úteis

| Parâmetro | Função | Exemplo |
|-----------|--------|---------|
| `-i` | Input file | `-i input.mp4` |
| `-c:v` | Video codec | `-c:v libx264` (H.264) |
| `-c:a` | Audio codec | `-c:a aac` |
| `-preset` | Speed vs quality | `fast`, `medium`, `slow` |
| `-crf` | Quality (0-51, menor=melhor) | `-crf 28` |
| `-b:v` | Bitrate vídeo | `-b:v 1000k` |
| `-b:a` | Bitrate áudio | `-b:a 128k` |
| `-ss` | Start time | `-ss 10` (segundo 10) |
| `-t` | Duration | `-t 30` (30 segundos) |
| `-r` | Frame rate | `-r 30` (30 fps) |
| `-s` | Resolução | `-s 1280x720` |
| `-vf` | Video filters | `-vf scale=1280x720` |

## 🔒 Segurança em Workflows

### ⚠️ Cuidado com Entrada de Usuários

**INSEGURO:**
```javascript
// Nunca fazer isso!
let cmd = `ffmpeg -i ${user_input} output.mp4`;
executeCommand(cmd);
```

**SEGURO:**
```javascript
// Validar entrada
const fs = require('fs');
const path = require('path');

// Whitelist de extensões
const allowedExt = ['.mp4', '.webm', '.avi'];
const ext = path.extname(user_input).toLowerCase();

if (!allowedExt.includes(ext)) {
  throw new Error('Formato não permitido');
}

// Sanitizar caminho (evitar path traversal)
const safePath = path.join('/tmp/uploads', path.basename(user_input));
const cmd = `ffmpeg -i "${safePath}" output.mp4`;
```

### Limites de Recursos

Configure em seu workflow:

```
Execute Command → Timeout: 300s (5 min)
```

Para vídeos grandes, aumentar se necessário. Mas sempre com limite!

## 📈 Performance Tips

### Usar `-c:v copy` quando possível

```bash
# ✅ RÁPIDO (cópia, sem re-encode)
ffmpeg -i input.mp4 -c:v copy -c:a copy -ss 10 -t 30 output.mp4

# ❌ LENTO (re-encode)
ffmpeg -i input.mp4 -c:v libx264 -ss 10 -t 30 output.mp4
```

### Processamento em Paralelo

Se muitos vídeos:

```
Trigger: Lista de 100 vídeos
  ↓
Split: Loop (paralelizar)
  ↓
Execute Command: ffmpeg (cada um)
  ↓
Merge Results: combinar saídas
```

### Usar Hardware Acceleration (se disponível)

```bash
# Se GPU disponível
ffmpeg -i input.mp4 -c:v hevc_nvenc output.mp4
# (NVIDIA: hevc_nvenc, h264_nvenc)
# (AMD: hevc_amf, h264_amf)
# (Intel: hevc_qsv, h264_qsv)
```

## 🐛 Debugging

### Ver Informações do Arquivo

```bash
ffmpeg -i video.mp4
# Mostra: codec, resolução, fps, bitrate, duração
```

### Output Detalhado

```bash
ffmpeg -i input.mp4 -c:v libx264 -preset medium output.mp4 -v verbose
```

### Verificar Resultado

```bash
# Após processar
ffmpeg -i output.mp4
# Confirmar: codec correto, resolução esperada, duração OK
```

## 📚 Recursos

- **FFmpeg Docs:** https://ffmpeg.org/documentation.html
- **FFmpeg Wiki:** https://trac.ffmpeg.org/wiki
- **Exemplos práticos:** https://www.ffmpeg.org/ffmpeg-all.html

---

**Sucesso com FFmpeg!** 🎬

Para dúvidas específicas sobre n8n + FFmpeg, consulte:
https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.executecommand/
