#!/bin/bash
set -e

echo "=== Starting SSH service ==="
service ssh start

echo "=== Starting Bore TCP tunnel for SSH (port 22) ==="
bore local 22 --to bore.pub > /tmp/bore.log 2>&1 &

# Tunggu bore mulai
sleep 5

# Ambil port dari log
BORE_PORT=$(grep -oP 'remote_port=\K[0-9]+' /tmp/bore.log | head -n 1)

echo ""
if [ -n "$BORE_PORT" ]; then
  echo "=== SSH tunnel is ready ==="
  echo "Bore: bore.pub:$BORE_PORT"
  echo ""
  echo "Connect using:"
  echo "  ssh ubuntu@bore.pub -p $BORE_PORT"
  echo ""
  echo "Default username: ubuntu"
  echo "Default password: ubuntu"
else
  echo "=== Bore log output ==="
  cat /tmp/bore.log
  echo ""
  echo "Retrying to parse port..."
  # Try alternative parsing
  BORE_PORT=$(grep -oE '[0-9]{4,5}' /tmp/bore.log | head -n 1)
  if [ -n "$BORE_PORT" ]; then
    echo "Connect using: ssh ubuntu@bore.pub -p $BORE_PORT"
  fi
fi

echo ""
echo "=== Keeping container alive on port 8080 ==="
python3 -m http.server 8080
