# CLAUDE.md — Claude Code 向けの入口

このプロジェクトのルールの正典は `AGENTS.md`（AI レビュアーと writer の双方が読む憲法）。
Claude Code は次行でそれを取り込む。ルールはここに重複させず、`AGENTS.md` を編集すること。

@AGENTS.md

- 判例は `logs/active_rules.md`（現行）と `logs/judgments.md`（証跡・追記のみ）。人間判断が出たら両方を更新し、`evals/cases/` にケースを足す。
- 検閲基準（`AGENTS.md` / `logs/active_rules.md` / `prompts/` / `evals/`）を変える PR は、`./evals/run.sh` を手元で回してから出す。
