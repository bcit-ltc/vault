#!/usr/bin/env bash
set -euo pipefail

# Load secrets from a JSON file into Vault
# Usage: ./load-kv2.sh path/to/secrets.json
JSON_FILE="${1:-secrets.json}"

# Optional: set DRY_RUN=1 to preview commands without writing
DRY_RUN="${DRY_RUN:-0}"

command -v jq >/dev/null 2>&1 || { echo "jq is required"; exit 1; }
command -v vault >/dev/null 2>&1 || { echo "vault CLI is required"; exit 1; }
: "${VAULT_ADDR:?Set VAULT_ADDR}"
: "${VAULT_TOKEN:?Set VAULT_TOKEN or login first}"

# Emit per-secret JSON lines: {"engine":"<mount>","path":"...","secrets":{...}}
jq -c '.[] | to_entries[] | .key as $engine | .value[] | {engine:$engine, path:.path, secrets:.secrets}' "$JSON_FILE" \
| while IFS= read -r line; do
  engine=$(jq -r '.engine' <<<"$line")
  path=$(jq -r '.path'   <<<"$line")

  # Build args, using a tempfile if value begins with "@"
  kv_args=()
  tmpfiles=()

  # Iterate keys deterministically (sorted) to keep runs stable
  while IFS= read -r key; do
    value=$(jq -r --arg k "$key" '.secrets[$k]' <<<"$line")

    if [[ "$value" == @* ]]; then
      # Value starts with "@": write to a temp file and pass as file input
      tf="$(mktemp)"
      printf '%s' "$value" > "$tf"
      tmpfiles+=("$tf")
      kv_args+=("$key=@$tf")
    else
      kv_args+=("$key=$value")
    fi
  done < <(jq -r '.secrets | keys[]' <<<"$line")

  echo "→ ${engine}/${path}"
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '   vault kv put %q/%q' "$engine" "$path"
    printf ' %q' "${kv_args[@]}"
    echo
  else
    vault kv put "${engine}/${path}" "${kv_args[@]}"
  fi

  # Cleanup any temp files created for @-prefixed values
  if ((${#tmpfiles[@]})); then
    rm -f "${tmpfiles[@]}"
  fi
done
