#!/bin/bash
set -e

echo "=== Starting SSH service ==="
service ssh start

echo "=== Starting Bore TCP tunnel for SSH (port 22) ==="
bore local 22 --to bore.pub > /tmp/bore.log 2>&1 &

# Tunggu bore mulai
sleep 5

# Ambil port dari log
BORE_PORT=$(grep -oE 'remote_port=[0-9]+' /tmp/bore.log | grep -oE '[0-9]+$' | head -n 1)

if [ -z "$BORE_PORT" ]; then
  BORE_PORT=$(grep -oE 'listening at bore\.pub:[0-9]+' /tmp/bore.log | grep -oE '[0-9]+$' | head -n 1)
fi

if [ -z "$BORE_PORT" ]; then
  BORE_PORT=$(grep -oE '[0-9]{4,5}' /tmp/bore.log | head -n 1)
fi

echo ""
if [ -n "$BORE_PORT" ]; then
  echo "==============================="
  echo "  SSH TUNNEL READY via Bore"
  echo "==============================="
  echo ""
  echo "  Connect using:"
  echo "  ssh ubuntu@bore.pub -p $BORE_PORT"
  echo ""
  echo "  Username : ubuntu"
  echo "  Password : ubuntu"
  echo "==============================="
else
  echo "=== Bore log ==="
  cat /tmp/bore.log
fi

echo ""
echo "=== Keeping container alive on port 8080 ==="
python3 -m http.server 8080
