#!/bin/sh
# Faz N requisições ao balanceador e conta qual site respondeu cada uma.
# Roda dentro de um contêiner, então o comando é o mesmo no Windows, no macOS e no Linux:
#   docker compose run --rm cliente        (10 requisições)
#   docker compose run --rm cliente 30     (30 requisições)
N=${1:-10}
for i in $(seq 1 "$N"); do
  wget -q -O - -T 3 http://balanceador/ 2>/dev/null | grep -o 'Hello World - Site [12]' || echo "FALHOU"
done | sort | uniq -c
