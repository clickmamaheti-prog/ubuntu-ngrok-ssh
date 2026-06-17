#!/bin/bash
set -e

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

log "=== SSH + Bore Tunnel Starting ==="

# Start SSH daemon
service ssh start
log "SSH service started"

# Function: jalankan bore dengan auto-reconnect
run_bore() {
  while true; do
    log "Connecting to bore.pub tunnel (port 22)..."
    bore local "$SSH_PORT" --to "$BORE_SERVER" > /var/log/bore/bore.log 2>&1 &
    BORE_PID=$!

    # Tunggu port muncul di log
    for i in $(seq 1 15); do
      sleep 1
      PORT=$(grep -oE '[0-9]{4,5}' /var/log/bore/bore.log 2>/dev/null | head -1)
      [ -n "$PORT" ] && break
    done

    if [ -n "$PORT" ]; then
      log "======================================="
      log "  BORE SSH TUNNEL READY"
      log "======================================="
      log "  Host   : $BORE_SERVER"
      log "  Port   : $PORT"
      log "  Command: ssh ubuntu@$BORE_SERVER -p $PORT"
      log "  User   : ubuntu  |  Pass: ubuntu"
      log "======================================="
    else
      log "WARNING: Could not parse port. Bore log:"
      cat /var/log/bore/bore.log 2>/dev/null || true
    fi

    # Tunggu bore process selesai (crash/disconnect)
    wait $BORE_PID
    log "Bore disconnected. Reconnecting in 5s..."
    sleep 5
  done
}

# Jalankan bore di background dengan auto-reconnect
run_bore &

log "Keep-alive HTTP server on port $KEEP_ALIVE_PORT"
exec python3 -m http.server "$KEEP_ALIVE_PORT"
