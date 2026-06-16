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

（まだ判断はありません）
