# AI レビュアーの回帰テスト (promptfoo evals)

AI レビュアー（PR 時の自動検閲）の判定精度を、ゴールデンセット（合格すべき diff /
不合格にすべき diff）に対する回帰テストで機械検証する。

## 設計原則

- **本番と同一のプロンプトをテストする**: `prompts/reviewer_prompt.txt` を、本番の
  AI レビュアー（`ai-pr-reviewer-action`）と本設定の両方が参照する。eval と本番の
  プロンプト乖離を構造的に防ぐ。
- **憲法・判例は repo の実ファイルを参照する**: スナップショットを持たない。判例
  （`logs/active_rules.md`）の追加が即 eval に反映され、二重管理を避ける。
- **判定は決定的文字列マッチのみ**: `RESULT: PASS` / `RESULT: FAIL` の一致判定。
  LLM-as-a-judge は使わず、eval のコストはテスト対象モデルの呼び出し分のみ。
- **temperature 0**: 再現性を確保する。

## 実行方法

```bash
export GEMINI_API_KEY=...     # 既定 provider（Gemini）の場合
./evals/run.sh                # これだけで実行できる（promptfoo のバージョンは run.sh で固定）
npx promptfoo@0.123.1 view    # 結果をブラウザで確認（任意）
```

- 実行には Node.js **22.22 以上**が必要（`npx` のみ使用・グローバルインストール不要。promptfoo の要求）。
- **レート制限と日次上限**: Google AI Studio の無料枠は `gemini-2.5-flash` で **1 日 20 リクエスト**（2026-09 時点）。
  eval 1 回で `cases/` のケース数分のリクエストを消費するので、無料枠では 1 日に数回しか回せない。上限に達すると 429 が返り、
  リトライとキュー待ちで数十分かけて失敗する。実運用では課金を有効にするか Vertex AI を使うこと。
  また毎分の上限も小さいため、ケースを並列に投げると 429 で詰まりやすい。`run.sh` は既定で直列（`--max-concurrency 1`）
  かつ 2 秒間隔にしてある。有料枠や Vertex AI なら `PROMPTFOO_MAX_CONCURRENCY=4 PROMPTFOO_DELAY_MS=0`
  で速くできる（CI では同名の GitHub Variables で指定）。5xx は `PROMPTFOO_RETRY_5XX` で自動リトライする。
- コスト目安: 1回 = ケース数 × モデル呼び出し1回。数ケースなら数円規模。
- 別モデルで検証する場合は、設定ファイルを書き換えず `PROMPTFOO_PROVIDER`（CI では GitHub
  Variables の `EVAL_PROVIDER`）で上書きできる。例: `PROMPTFOO_PROVIDER=anthropic:messages:claude-sonnet-5 ./evals/run.sh`
  （対応する API キー env が必要。`ANTHROPIC_API_KEY` / `OPENAI_API_KEY`）。**本番の `model` 入力と同じ
  モデル**を指定すると乖離なく検証できる。

## いつ回るか（検証ループ）

**CI が自動で強制する**: 検閲基準（`AGENTS.md` / `logs/active_rules.md` / `prompts/` /
`evals/`）を変更する PR では、`.github/workflows/eval-gate.yml` が eval を実行し、
**全ケース合格しないとマージできない**（必須チェックに設定した場合）。無関係な PR では
eval ステップを skip する（モデル側の一時障害が無関係な PR をブロックする半径拡大を避ける）。

ローカルの `./evals/run.sh` は「PR を出す前の事前確認」用として併存する。

> **判例とゴールデンセットの連動**: 人間判断が出たら `judgments.md`（証跡）と
> `active_rules.md`（判例）に加えて、該当ケースの diff を `cases/pass|fail/` に追加する。
> 判例がそのまま「正解データ」になり、同じ判定ミスの再発を機械的に検知できる。

## ケースの追加方法

1. `cases/pass/` または `cases/fail/` に git diff 形式のファイルを置く。
2. `promptfooconfig.yaml` の `tests:` にエントリを追加する。
   - 合格ケース: `regex: "^RESULT: PASS"`
   - 不合格ケース: `contains: "RESULT: FAIL"`

### フィクスチャ作成時の注意

- **実シークレットに似せない**: 偽の API キー・トークン等は secret スキャナ（gitleaks 等）が
  実シークレットと誤検知して PR をブロックし得る。ハードコード違反をテストしたい場合は、
  スキャナの正規表現に掛からない形（内部 IP・エンドポイント直書き等）で表現する。
- **攻撃パターンはテストデータ**: `cases/fail/` のインジェクション文・違反コードはテスト
  データ。本番の AI レビュアーがこれを審査すると指示 0 により FAIL になるため、
  `.github/workflows/ai-pr-reviewer.yml` の `exclude_patterns` で `evals/cases/*` を
  レビュー対象から外している（ケース追加 PR の担保は eval-gate と人間レビュー）。
  この除外を消すと、判例を固定化する PR が通らなくなる。
- **`npx promptfoo@latest view` について**: 結果閲覧は任意。eval 本体は `run.sh` が固定
  したバージョンで動く。
