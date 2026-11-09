#!/usr/bin/env bash
set -eu
if [ $# -lt 1 ]; then
  echo "usage: $0 <url>" >&2
  exit 2
fi
if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required" >&2
  exit 2
fi
url="$1"
code=000
for _ in 1 2 3; do
  code=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$url" || true)
  if [ -z "${code}" ]; then
    code=000
  fi
  if [ "${code}" -ge 200 ] && [ "${code}" -lt 300 ]; then
    echo "${url} status=${code} up"
    exit 0
  fi
  sleep 0.3
done
echo "${url} status=${code} down"
exit 1
