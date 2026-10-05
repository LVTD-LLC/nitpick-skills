# .nitpick.toml

Lives in the repo root. Every key is optional. CLI flags and `NITPICK_*` environment variables override it. A user-level `~/.config/nitpick/config.toml` with the same keys is read first and the repo file is layered over it; `api_key = "..."` is honored only in the user-level file.

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

# Background review while an agent works (nitpick watch). Unset keys fall back to the values above.
[watch]
# enabled = true
# model = "nvidia/nemotron-3-ultra-550b-a55b:free"   # cheaper model for the many small reviews
deliver = "medium"        # lowest severity handed to the agent mid-task
# fail_on = "high"        # lowest severity that sends the agent back when it tries to stop
debounce_secs = 20        # quiet period after the last edit before a review starts
max_wait_secs = 120       # review anyway once edits have been arriving for this long
timeout_secs = 180
# budget_tokens = 40000
# stop_wait_secs = 120    # only used when max_stop_blocks > 0; ignored in advisory mode
# max_stop_blocks = 0     # advisory: never wait or block; set to 2 for a completion gate
# instructions = "Extra instructions for the background reviewer only."
```

`nitpick init` writes a commented starter file.
