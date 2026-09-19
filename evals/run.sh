#!/usr/bin/env bash
# =============================================================================
# AI レビュアーの回帰テスト実行ラッパー（ポータブル版）
# =============================================================================
# `./evals/run.sh` 一発で回せるようにする。
# - 認証は API キー（promptfoo の provider に対応する env を使う）。
#   既定 provider（google:gemini-2.5-flash）の場合は GEMINI_API_KEY。
# - 追加引数はそのまま promptfoo へ渡す（例: ./run.sh --no-cache）。
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"

# promptfoo のバージョン（CI もこのスクリプトを呼ぶので、固定はここ 1 か所）。
# 上げるときは手元で ./evals/run.sh を回し、全ケース合格を確認してから変更する。
PROMPTFOO_VERSION="${PROMPTFOO_VERSION:-0.123.1}"

export PROMPTFOO_DISABLE_TELEMETRY="${PROMPTFOO_DISABLE_TELEMETRY:-1}"
# モデル側の一時障害（503 overloaded 等）で落ちないよう 5xx を自動リトライする
export PROMPTFOO_RETRY_5XX="${PROMPTFOO_RETRY_5XX:-true}"
# Gemini の無料枠（毎分のリクエスト上限が小さい）でも 429 で詰まらないよう、既定は直列実行＋間隔あり。
# 有料枠や Vertex AI なら PROMPTFOO_MAX_CONCURRENCY=4 PROMPTFOO_DELAY_MS=0 で速くできる。
PROMPTFOO_MAX_CONCURRENCY="${PROMPTFOO_MAX_CONCURRENCY:-1}"
PROMPTFOO_DELAY_MS="${PROMPTFOO_DELAY_MS:-2000}"

# 検証に使う provider。未指定なら promptfooconfig.yaml の既定（Gemini）。
# 本番の AI_REVIEWER_MODEL と同じモデルを promptfoo の書式で指定すると乖離なく検証できる:
#   google:gemini-2.5-flash / anthropic:messages:claude-sonnet-5 / openai:gpt-4o
PROMPTFOO_PROVIDER="${PROMPTFOO_PROVIDER:-}"
PROVIDER_ARGS=()
[ -n "$PROMPTFOO_PROVIDER" ] && PROVIDER_ARGS=(--providers "$PROMPTFOO_PROVIDER")

# provider に対応する API キーがあるかを先に確認する（無いと promptfoo が全件 ERROR になる）。
case "${PROMPTFOO_PROVIDER:-google:}" in
  google:*|vertex:*)
    if [ -z "${GEMINI_API_KEY:-}" ] && [ -z "${GOOGLE_API_KEY:-}" ]; then
      echo "[ERROR] GEMINI_API_KEY（または GOOGLE_API_KEY）が未設定です。Google AI Studio で取得して設定してください。" >&2; exit 1
    fi ;;
  anthropic:*)
    [ -n "${ANTHROPIC_API_KEY:-}" ] || { echo "[ERROR] ANTHROPIC_API_KEY が未設定です（provider=$PROMPTFOO_PROVIDER）。" >&2; exit 1; } ;;
  openai:*)
    [ -n "${OPENAI_API_KEY:-}" ] || { echo "[ERROR] OPENAI_API_KEY が未設定です（provider=$PROMPTFOO_PROVIDER）。" >&2; exit 1; } ;;
esac

echo "[INFO] promptfoo@${PROMPTFOO_VERSION} eval を実行します（provider: ${PROMPTFOO_PROVIDER:-config 既定}）。"
npx -y "promptfoo@${PROMPTFOO_VERSION}" eval --max-concurrency "$PROMPTFOO_MAX_CONCURRENCY" --delay "$PROMPTFOO_DELAY_MS" "${PROVIDER_ARGS[@]}" "$@"
