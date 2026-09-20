# 判断証跡（judgments）— append-only・削除/編集禁止

人間が下した判断の**全履歴**を時系列で残す監査証跡。AI レビュアーはこのファイルを
直接は読まない（読むのは [active_rules.md](active_rules.md)）。ここは「いつ・誰が・なぜ
その判断をしたか」を後から追えるようにするための記録で、**追記のみ**とする。

運用: 人間判断が出たら ①このファイルに追記 ②[active_rules.md](active_rules.md) を upsert
③対応ケースを `evals/cases/` に追加（[../evals/README.md](../evals/README.md)）。

---

<!-- 追記の例:
## YYYY-MM-DD [TOPIC-001] 〇〇の扱い
- 葛藤: 〇〇は△△の観点で違反に見えるが、□□の事情で許可したい。
- 判断（人間）: 許可する / 却下する。
- 理由: （判断の根拠）
- 反映: active_rules.md に TOPIC-001 を追加 / evals/cases/pass/xxx.diff を追加。
-->

## 2026-09-20 [SCOPE-001] テンプレート自身の初期整備 PR のスコープ
- 葛藤: ai-dev-kit#1 は、eval 基盤を実際に動く状態にするための修正（Node 22 への更新、5xx リトライ、
  無料枠向けの直列実行、`EVAL_PROVIDER` による provider 切替、`excluded_files` 対応、README 追記）を
  1 つの PR にまとめており、AI レビュアーは §A-5「1 PR は 1 目的」違反として FAIL とした。
  分割すると 3 PR × 7 リクエストとなり、Gemini 無料枠（20 リクエスト/日）では 1 日で検証しきれない。
- 判断（人間: shinkawa）: 許可する。ただし「テンプレート自身の CI 基盤（`.github/workflows/`、`evals/`、
  `prompts/`、README）を動く状態にするための初期整備」に限る。
- 理由: 各変更は同じ目的（回帰テストと AI レビューが実際に回る状態にする）に従属し、どれか 1 つを
  切り出しても単独では CI が通らない。利用者のプロジェクトでの通常の PR には適用しない。
- 反映: active_rules.md に SCOPE-001 を追加。
