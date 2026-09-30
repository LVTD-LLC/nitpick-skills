# .nitpick.toml

Lives in the repo root. Every key is optional. CLI flags and `NITPICK_*` environment variables override it.

```toml
# One model or a list. Several run in parallel and their findings are merged.
model = ["stealth/space-bunny-alpha", "nvidia/nemotron-3-ultra-550b-a55b:free"]

# openrouter (default) | ollama | llamacpp | openai
# provider = "openrouter"
# base_url = "http://localhost:11434/v1"
# api_key_env = "NITPICK_OPENROUTER_API_KEY"

# Branch to diff against. Auto-detected when unset.
# base = "main"

# Exit 1 when any finding is at or above this severity.
fail_on = "high"

budget_tokens = 80000
max_file_lines = 400
max_tokens = 16000
# reasoning = "medium"
# structured = true
# timeout_secs = 300
# include_tests = true

# Files to leave out of the review (gitignore-style globs).
ignore = ["**/*.lock", "**/*.snap", "**/generated/**"]

# Extra instructions for the reviewer. Project conventions, strictness, what to ignore.
instructions = """
This is a Django app. Be strict about N+1 queries and missing select_related.
Ignore anything about docstrings.
"""
```

`nitpick init` writes a commented starter file.
