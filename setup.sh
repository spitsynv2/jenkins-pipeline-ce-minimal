#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

KEY_DIR="keys"
PRIV="$KEY_DIR/SSH_PRIVATE_KEY"
PUB="$KEY_DIR/SSH_PRIVATE_KEY.pub"

if [ ! -f "$PRIV" ]; then
  echo "Generating SSH keypair for the Jenkins agent..."
  ssh-keygen -t ed25519 -f "$PRIV" -N "" -C "jenkins-local-agent" >/dev/null
fi

echo "AGENT_PUBKEY=$(cat "$PUB")" > .env

echo
echo "Keys ready. Now bringing up Jenkins (this builds the controller image the first time)..."
echo
docker compose up --build -d

echo
echo "--------------------------------------------------------------------"
echo "Jenkins is starting at: http://localhost:8080"
echo "Login: admin / admin"
echo "--------------------------------------------------------------------"
echo