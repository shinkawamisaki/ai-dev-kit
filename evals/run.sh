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

# 既定 provider 用の API キー確認（別 provider に変えた場合はこのチェックを調整）。
if [ -z "${GEMINI_API_KEY:-}" ] && [ -z "${GOOGLE_API_KEY:-}" ]; then
  echo "[ERROR] GEMINI_API_KEY（または GOOGLE_API_KEY）が未設定です。" >&2
  echo "        Google AI Studio で取得し、環境変数に設定してください。" >&2
  echo "        別モデルを使う場合は evals/promptfooconfig.yaml の provider と" >&2
  echo "        対応する API キー env（OPENAI_API_KEY 等）に合わせてください。" >&2
  exit 1
fi

echo "[INFO] promptfoo@${PROMPTFOO_VERSION} eval を実行します。"
npx -y "promptfoo@${PROMPTFOO_VERSION}" eval "$@"
