# Local Agent Instructions

Project: infidel_env (personal CLI workspace config)
Toolchain: bash, git, vim/nvim, node/npm, python
Commands: `./install.sh [-t user|root|all] [-l] [-d] [-T] [-h]`

## Push Policy (HARD RULE)
- **NEVER `git push` unless the user explicitly asks** ("push", "push it", "push to origin/gitea").
- Commit locally as often as needed; leave commits unpushed by default.
- Do not push after finishing a task, at session end, or "to be safe" — pushing requires a direct user command only.
- Applies to ALL remotes (`origin`, `gitea`, or any future remote).
Status: `test/refactor-install` branch — vimrc hardened (seoul256-light, CoC TAB/S-TAB, kitty OSC intact); `install.sh` gained a manager-agnostic Go toolchain + `goimports`/`gofumpt` installer.
Next: run `./install.sh` to install Go locally; user validation in lazygit/terminal.
