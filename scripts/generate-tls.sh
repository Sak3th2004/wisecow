#!/usr/bin/env bash
set -eu

HOST="${1:-wisecow.local}"
OUT=certs

mkdir -p "${OUT}"

openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout "${OUT}/tls.key" \
  -out "${OUT}/tls.crt" \
  -subj "/CN=${HOST}" \
  -addext "subjectAltName=DNS:${HOST}"

echo "wrote ${OUT}/tls.crt and ${OUT}/tls.key for ${HOST}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found. when the cluster is up, run:"
  echo "kubectl create secret tls wisecow-tls --cert=${OUT}/tls.crt --key=${OUT}/tls.key --dry-run=client -o yaml | kubectl apply -f -"
  exit 0
fi

kubectl create secret tls wisecow-tls \
  --cert="${OUT}/tls.crt" \
  --key="${OUT}/tls.key" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "secret wisecow-tls applied"