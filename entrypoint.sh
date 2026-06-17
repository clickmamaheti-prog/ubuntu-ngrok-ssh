#!/bin/bash

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

notify() {
  local title="$1" msg="$2" priority="${3:-default}" tags="${4:-computer}"
  curl -s --max-time 5 -X POST "https://ntfy.sh/${NTFY_TOPIC}" \
    -H "Title: $title" \
    -H "Priority: $priority" \
    -H "Tags: $tags" \
    -d "$msg" > /dev/null 2>&1 && log "Notifikasi terkirim ke ntfy.sh/$NTFY_TOPIC" || true
}

log "========================================"
log "  VPS Railway - Bore SSH Tunnel"
log "========================================"

# Start SSH
/usr/sbin/sshd
log "SSH daemon started"

# Kirim notif awal
notify "VPS Railway Starting..." "SSH daemon aktif, menghubungkan bore tunnel..." "default" "rocket"

# Loop auto-reconnect bore
reconnect_count=0
while true; do
  log "Menghubungkan ke $BORE_SERVER (percobaan ke-$((reconnect_count+1)))..."
  
  bore local "$SSH_PORT" --to "$BORE_SERVER" > /var/log/bore/bore.log 2>&1 &
  BORE_PID=$!

  # Tunggu port muncul di log (max 20 detik)
  PORT=""
  for i in $(seq 1 20); do
    sleep 1
    PORT=$(grep -oE '[0-9]{4,5}' /var/log/bore/bore.log 2>/dev/null | head -1)
    [ -n "$PORT" ] && break
  done

  if [ -n "$PORT" ]; then
    reconnect_count=$((reconnect_count+1))
    log "========================================"
    log "  BORE SSH TUNNEL READY"
    log "========================================"
    log "  ssh root@$BORE_SERVER -p $PORT"
    log "  Password root  : rairu123"
    log "  ssh ubuntu@$BORE_SERVER -p $PORT"
    log "  Password ubuntu: ubuntu"
    log "========================================"

    # Push notification ke ntfy.sh
    notify \
      "✅ VPS Railway AKTIF! Port: $PORT" \
      "ssh root@bore.pub -p $PORT | Pass: rairu123
ssh ubuntu@bore.pub -p $PORT | Pass: ubuntu" \
      "high" \
      "computer,key"
  else
    log "WARN: Gagal dapat port dari bore. Log:"
    cat /var/log/bore/bore.log 2>/dev/null || true
    notify "⚠️ VPS Bore GAGAL" "Bore tunnel gagal konek. Cek log Railway." "urgent" "warning"
  fi

  # Tunggu bore mati
  wait $BORE_PID 2>/dev/null || true
  log "Bore disconnect. Reconnect dalam 5 detik..."
  notify "🔄 VPS Reconnecting..." "bore tunnel putus, mencoba reconnect..." "low" "arrows_counterclockwise"
  sleep 5
done &

log "HTTP health server port $KEEP_ALIVE_PORT"
exec python3 -m http.server "$KEEP_ALIVE_PORT"
