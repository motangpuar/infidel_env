# Local Agent Instructions

Project: infidel_env (personal CLI workspace config)
Toolchain: bash, git, vim/nvim, node/npm, python
Commands: `./install.sh [-t user|root|all] [-l] [-d] [-T] [-h]`

## Push Policy (HARD RULE)
- **NEVER `git push` unless the user explicitly asks** ("push", "push it", "push to origin/gitea").
- Commit locally as often as needed; leave commits unpushed by default.
- Do not push after finishing a task, at session end, or "to be safe" — pushing requires a direct user command only.
- Applies to ALL remotes (`origin`, `gitea`, or any future remote).

## Commit Identity (HARD RULE)
- **Never override `user.name` / `user.email`** (no `-c user.name=...`, no `--author=`).
- Commits must use the configured repo identity: `infidel <ninoagus@protonmail.com>`.
- If a commit is made under a wrong identity, rewrite it (reflog + `reset` + recommit) before it is pushed.
Status: `test/refactor-install` branch — vimrc hardened (seoul256-light, CoC TAB/S-TAB, kitty OSC intact); `install.sh` gained a manager-agnostic Go toolchain + `goimports`/`gofumpt` installer; CI workflows for GitHub Actions + Gitea Actions added with README badges.
Next: run `./install.sh` to install Go locally; user validation in lazygit/terminal.
