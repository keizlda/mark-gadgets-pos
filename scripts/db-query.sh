#!/usr/bin/env bash
# Run one SQL string against the live Supabase DB via the Management API.
#   bash scripts/db-query.sh "select now()"
# Reads SUPABASE_ACCESS_TOKEN / SUPABASE_PROJECT_REF from .env.deploy.
# The token is passed to Node through the environment only — never echoed,
# never put on a command line or in a URL. Uses process.exitCode, not
# process.exit(): exiting while fetch handles close crashes Node on Windows.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT/.env.deploy"

if [ $# -lt 1 ] || [ -z "$1" ]; then
  echo "usage: bash scripts/db-query.sh \"<sql>\"" >&2
  exit 2
fi
if [ ! -f "$ENV_FILE" ]; then
  echo "error: $ENV_FILE not found" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
. "$ENV_FILE"
set +a

if [ -z "${SUPABASE_ACCESS_TOKEN:-}" ] || [ -z "${SUPABASE_PROJECT_REF:-}" ]; then
  echo "error: SUPABASE_ACCESS_TOKEN and SUPABASE_PROJECT_REF must be set in .env.deploy" >&2
  exit 1
fi

DB_QUERY_SQL="$1" node -e '
const { SUPABASE_ACCESS_TOKEN: token, SUPABASE_PROJECT_REF: ref, DB_QUERY_SQL: query } = process.env;
fetch(`https://api.supabase.com/v1/projects/${ref}/database/query`, {
  method: "POST",
  headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
  body: JSON.stringify({ query }),
})
  .then(async (res) => {
    const text = await res.text();
    let out = text;
    try { out = JSON.stringify(JSON.parse(text), null, 2); } catch {}
    if (!res.ok) {
      console.error(`HTTP ${res.status}`);
      console.error(out);
      process.exitCode = 1;
      return;
    }
    console.log(out);
  })
  .catch((err) => {
    console.error(`request failed: ${err.message}`);
    process.exitCode = 1;
  });
'
