# Ubuntu Bore SSH

Remote SSH access via [Bore](https://github.com/ekzhang/bore) tunnel — no auth token needed.

## Connect

```bash
ssh ubuntu@bore.pub -p <PORT>
```

- **Username:** `ubuntu`
- **Password:** `ubuntu`
- **Port:** shown in Railway deployment logs

## How it works

1. Ubuntu 22.04 container starts
2. SSH daemon starts on port 22
3. Bore creates a public TCP tunnel → `bore.pub:<random_port>`
4. If bore disconnects, it auto-reconnects

## Stack

- Ubuntu 22.04
- OpenSSH Server
- [Bore v0.5.0](https://github.com/ekzhang/bore) (open-source ngrok alternative)

## Deploy to Railway

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template)

No environment variables required.
