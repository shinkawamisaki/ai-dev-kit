# ai-dev-kit

AI 駆動開発のための「品質ゲート一式」を新規プロジェクトに持ち込むためのテンプレート。
PR を AI が検閲し、その検閲精度自体を回帰テストで担保し、人間の判断を判例として蓄積する
——という体制を、**言語・クラウド非依存**で、**モデルを差し替え可能**な形で配布する。

> このリポジトリは **GitHub テンプレートリポジトリ**です。右上の **「Use this template」**
> から新しいリポジトリを作って始めてください。

## これは何を入れてくれるのか

| 入るもの | 役割 |
|---|---|
| `.github/workflows/ai-pr-reviewer.yml` | PR を AI が検閲（エンジン: [ai-pr-reviewer-action](https://github.com/shinkawamisaki/ai-pr-reviewer-action)・タグ配布で更新追従） |
| `.github/workflows/eval-gate.yml` | 検閲基準を変える PR で回帰テストを強制 |
| `.clinerules` | レビュー基準（憲法）。AI レビュアーと writer の正典 |
| `prompts/reviewer_prompt.txt` | 検閲プロンプト（本番と eval が**同一**を参照） |
| `logs/active_rules.md` / `judgments.md` | 判例の二層構造（現行判例 / 証跡） |
| `evals/` | promptfoo によるゴールデンセット回帰テスト |
| `docs/QUALITY_FEEDBACK_LOOP.md` | 体制の「なぜ」（レイヤー構造と責任分界） |

エンジン（検閲ロジック）は外部 Action に切り出してあるので、改善は `@v3` のタグ更新で
全プロジェクトに届く（コピーしたまま腐らない）。

## クイックスタート（5 ステップ）

1. **「Use this template」** で新リポジトリを作成。
2. **API キーを登録**（Settings > Secrets and variables > Actions > Secrets）。使うモデルの分だけ:
   `GEMINI_API_KEY` / `ANTHROPIC_API_KEY` / `OPENAI_API_KEY`。
3. **（任意）モデルを選ぶ**（同 > Variables）: `AI_REVIEWER_MODEL`（例 `claude-opus-4-7`）。
   未設定なら `gemini/gemini-2.5-flash`。
4. **`.clinerules` の §B を埋める**（あなたのプロジェクト固有ルール）。§A はそのままでよい。
5. **必須チェックに設定**（Settings > Branches > Branch protection）: `AI PR Reviewer` と
   `eval-gate` を required にする。これでゲートが強制になる。

これで PR を出すと AI 検閲が走る。`./evals/run.sh`（要 `GEMINI_API_KEY`）でローカル確認も可能。

## 変えてよい層 / 変えてはいけない層

このキットの肝は、**ポリシー（各プロジェクトで変えるもの）と構造的担保（変えると
ゲートが壊れるもの）を分けてある**こと。

### ✅ 変えてよい（ポリシー層）

- **`.clinerules` §B**: プロジェクト固有ルール。ここがあなたの「設計思想」。
- **`logs/active_rules.md` / `judgments.md`**: 運用で増えていく判例。
- **`evals/cases/`**: ゴールデンセット。判例を足したらここにケースを足す。
- **モデル選択**（`AI_REVIEWER_MODEL`）、**出力言語**（ワークフローの `language`）。
- **Layer 2 の A（静的解析ツール）**: secret スキャン・lint・SAST は言語/スタックに応じて
  自由に追加・差し替え（このキットには同梱していない＝あなたのスタックに合わせるスロット）。

### ⛔ 変えない（構造的担保層 / 変えると検閲の強制力が失われる）

- **fail-closed**（`strict_verify: 'true'`）: 判定不能を合格にしない。
- **審査基準を base コミットから読む**: 自己参照の遮断（Action 側で担保）。
- **eval と本番が同一プロンプトを読む**: `prompts/reviewer_prompt.txt` を両者が参照。
  プロンプトを変えるなら eval も同じファイルで動くこと。
- **reviewer に writer と同じモデルを使わない**: 独立した強制ゲートとしての価値。
  コードを Claude で書くなら、レビューは別系統（例: Gemini）にする。
- **判例の二層構造**: `judgments.md` は append-only、`active_rules.md` は upsert。

詳細な思想は [docs/QUALITY_FEEDBACK_LOOP.md](docs/QUALITY_FEEDBACK_LOOP.md)。

## 構成図

```
あなたの新リポジトリ（このテンプレから生成）
├── .clinerules                    ← §A 共通 / §B 固有（あなたが埋める）
├── prompts/reviewer_prompt.txt    ← 本番と eval が共有（構造的担保）
├── logs/
│   ├── active_rules.md            ← 判例（AI が読む・upsert）
│   └── judgments.md               ← 証跡（append-only）
├── evals/                         ← 回帰テスト（promptfoo）
│   ├── promptfooconfig.yaml
│   ├── run.sh
│   └── cases/{pass,fail}/*.diff
├── docs/QUALITY_FEEDBACK_LOOP.md  ← 体制の「なぜ」
└── .github/workflows/
    ├── ai-pr-reviewer.yml         ← エンジン呼び出し（@v3）
    └── eval-gate.yml              ← 検閲基準変更時の回帰ゲート
```

## GCP/Terraform で「クラウド側の回避不能な検閲」が要る場合

このキットは GitHub Actions ベース（API キーで動く・どこでも使える）。AI エージェントが
CI 設定ごと書き換えるのを物理的に防ぎたい、keyless（WIF/ADC）にしたい、といった高統制
要件がある場合は、Cloud Build 版（`pr_reviewer.py` + Terraform 配線）の方が上位互換。
そちらは別途 GCP 特化テンプレートを参照。

## ライセンス

Apache License 2.0
