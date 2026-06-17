# 🚀 Rairu SSH VPS — Bore Tunnel (No Token)

**Free lifetime VPS via Railway + Bore TCP tunnel.** No Ngrok account needed!

> Get push notifications on your phone via [ntfy.sh](https://ntfy.sh) with the SSH port every time the tunnel starts.

## 📱 Setup Notifikasi (ntfy.sh)

1. Install **ntfy** di HP kamu: [ntfy.sh/docs](https://ntfy.sh/#subscribe)
2. Subscribe ke topic: `rairu-clickmamaheti`
3. Setiap kali VPS restart, port SSH baru dikirim ke HP kamu otomatis!

## 🔌 Connect SSH

```bash
# Cek ntfy.sh untuk port terbaru, lalu:
ssh root@bore.pub -p <PORT>
# Password: rairu123

ssh ubuntu@bore.pub -p <PORT>  
# Password: ubuntu
```

## 🚂 Deploy ke Railway

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new)

1. Fork repo ini
2. Buat project baru di Railway
3. Connect ke repo hasil fork
4. Deploy otomatis!

## 🌐 Multi-Platform

| Platform | Status | Config |
|----------|--------|--------|
| Railway | ✅ | `railway.json` + `Dockerfile` |
| Render | ✅ | `render.yaml` |
| Fly.io | ✅ | `fly.toml` |

## ⚙️ Spec (Railway Free Tier)

- **RAM:** ~512MB - 2GB
- **CPU:** Shared
- **Storage:** 10GB
- **Uptime:** 99%+ dengan auto-restart

## 🔧 Environment Variables

| Variable | Default | Keterangan |
|----------|---------|------------|
| `NTFY_TOPIC` | `rairu-clickmamaheti` | Topic ntfy.sh notifikasi |
| `BORE_SERVER` | `bore.pub` | Bore server (bisa self-host) |
| `SSH_PORT` | `22` | Port SSH lokal |
| `KEEP_ALIVE_PORT` | `8080` | Port HTTP health check |
