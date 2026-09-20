# ai-dev-kit

A template that brings a complete set of quality gates for AI-driven development into a new
project: an AI reviews every pull request, the accuracy of that review is itself protected by a
regression test, and human decisions accumulate as precedents. Language- and cloud-agnostic, with
a swappable model.

> This is a **GitHub template repository**. Click **"Use this template"** to start a new repository.
> The Japanese README ([README.md](README.md)) is the primary document; this file is a summary.

## What you get

| File | Role |
|---|---|
| `.github/workflows/ai-pr-reviewer.yml` | AI review of every PR (engine: [ai-pr-reviewer-action](https://github.com/shinkawamisaki/ai-pr-reviewer-action), pinned to a major tag) |
| `.github/workflows/eval-gate.yml` | Forces the regression test on PRs that change the review criteria |
| `AGENTS.md` | The review rules ("constitution"), read by both the AI reviewer and the AI writer |
| `CLAUDE.md` | Entry point for Claude Code; only imports `AGENTS.md` |
| `prompts/reviewer_prompt.txt` | The review prompt. Production and eval read the **same** file |
| `logs/active_rules.md` / `judgments.md` | Two-layer precedents (current rules / append-only evidence) |
| `evals/` | Golden-set regression test with promptfoo |
| `docs/QUALITY_FEEDBACK_LOOP.md` | Why the layers and responsibilities are split this way |

## Quick start

1. Create a repository with **"Use this template"**.
2. Add the API key for the model you use as an Actions secret: `GEMINI_API_KEY`,
   `ANTHROPIC_API_KEY` or `OPENAI_API_KEY`.
3. Optionally pick a model with the Actions variable `AI_REVIEWER_MODEL`
   (default: `gemini/gemini-2.5-flash`).
4. Fill in section B of `AGENTS.md` with your project-specific rules. Section A can stay as is.
5. Make two checks required in branch protection: the commit status **`AI PR Reviewer`**
   (posted by the action; it stays pending for fork PRs and drafts, which is the fail-closed
   behaviour you want) and the job **`eval-gate`**.

Open a PR and the AI review runs. `./evals/run.sh` (needs `GEMINI_API_KEY`) runs the same
regression test locally.

## What you may change, and what you must not

**Policy layer (change freely):** `AGENTS.md` section B, the precedents under `logs/`, the golden
set under `evals/cases/`, the model, the output language, and your own static-analysis tools.

**Structural guarantees (changing them removes the enforcement):**

- fail-closed (`strict_verify: 'true'`): an unverifiable review never passes
- review criteria are read from the PR **base** commit, so a PR cannot weaken its own rules
- eval and production read the same prompt file
- the reviewer model is not the same model that writes the code
- `judgments.md` is append-only, `active_rules.md` is upserted
- `evals/cases/*` stays excluded from AI review (the fail cases contain injection text on purpose;
  reviewing them would fail the very PR that records a precedent)

## Dependencies

- The reviewer action is referenced by its major tag `@v3`. Pin it to a commit SHA if you need
  stricter supply-chain control.
- promptfoo is pinned in `evals/run.sh`; CI calls the same script.

## License

Apache License 2.0. See [LICENSE](LICENSE).
