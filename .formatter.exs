# Used by "mix format". Loaded whenever Mix runs from the repo root
# (including editors such as Zed that format with the worktree root as cwd),
# so it carries the LiveView HTML plugin for `docs/` too.
[
  import_deps: [:phoenix],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs,heex}",
    "docs/mix.exs",
    "docs/{config,lib,test}/**/*.{ex,exs,heex}"
  ]
]
