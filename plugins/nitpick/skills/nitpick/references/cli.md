# nitpick CLI reference

```
nitpick [OPTIONS] [PATHS]...        review (default)
nitpick review [OPTIONS] [PATHS]... same as above
nitpick context [OPTIONS] [PATHS]... print the payload that would be sent, no model call
nitpick init [--force]              write a starter .nitpick.toml
```

## Options

| Flag | Meaning | Default |
|---|---|---|
| `-m, --model <id>` | Model id. Repeat or comma-separate for several in parallel. | `stealth/space-bunny-alpha` or config |
| `--provider <openrouter\|ollama\|llamacpp\|openai>` | Where to send the request | `openrouter` |
| `--base-url <url>` | Override the API base URL | provider default |
| `--api-key <key>` | API key (prefer the env var) | env |
| `-b, --base <ref>` | Base branch or commit to diff against | auto-detect |
| `--staged` | Only staged changes | |
| `--range <a..b>` | Explicit revision range | |
| `--no-untracked` | Exclude untracked files | |
| `--no-context` | Send only diff and changed files | |
| `--no-tests` | Do not pull matching tests into context | |
| `--budget <tokens>` | Context token budget | 80000 |
| `--max-file-lines <n>` | Window files longer than this around the changes | 400 |
| `-f, --focus <text>` | Extra instructions for the reviewer, repeatable | |
| `--fail-on <severity>` | Exit 1 at or above: `blocker`, `high`, `medium`, `low`, `nit` | `high` |
| `--json` | JSON output | |
| `--timeout <secs>` | Per-model request timeout | 300 |
| `--max-tokens <n>` | Completion budget, doubled automatically if the model runs out | 16000 |
| `--temperature <f>` | Sampling temperature | 0.1 |
| `--reasoning <none\|low\|medium\|high>` | Reasoning effort for models that support it | model default |
| `--no-structured` | Never request `response_format` | |
| `-q, --quiet` | No progress on stderr | |
| `-v, --verbose` | Timing and token details on stderr | |

## Environment variables

`NITPICK_OPENROUTER_API_KEY`, `OPENROUTER_API_KEY`, `NITPICK_OPENAI_API_KEY`, `OPENAI_API_KEY`, `NITPICK_API_KEY`, `NITPICK_MODEL`, `NITPICK_PROVIDER`, `NITPICK_BASE_URL`, `NITPICK_REASONING`, `NITPICK_DEBUG_DIR`.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | No findings at or above `--fail-on`, or no changes to review |
| 1 | Findings at or above `--fail-on` |
| 2 | Error: git failed, no key, bad config, every model failed |

## Output

Markdown on stdout: a verdict line, per-model summaries, findings grouped by severity as `path:line` with title, category, body and suggestion, then a line stating the exit code. With `--json`: `{ verdict, findings[], models[], stats, total_ms, failing }`.
