# Infidel's personal config for CLI based workspaces
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Naereen/StrapDown.js/graphs/commit-activity)

## General Info

This is the essential VIM and Tmux configuration for cli based unix systems.

## Clone
```bash
    git clone https://git.nnag.me/infidel/infidel_env.git
```

## Setup
``` bash
    ./install.sh -u user
```
## VIM

> This installation script now can execute `:PlugUpdate` on first setup.

### Global

- Leader remmaped to `,` 
- Enabled more visual blocks with J and K
- Auto tabbed lines from normal mode using `>`

### NerdTree

Toggle NerdTree with <CTRL-k><k>.
T
### EasyAlign

Perform multiline visual select then enter `ga`. Next enter your preference alignment.

### Goyo

Toggle Goyo from command input mode `:Goyo` or use the <F8> shortcut. 

### Limelight

Toggle Limelight from command input mode `:Limelight` or use the <Leader><l> shortcut.

### Autocomplete : CoC

CoC now can use tab to navigate completion list. Make sure the target machine have nodejs for CoC to run properly.

### Airline 

I use airline as status bar

**CoC Extensions included** :

- `coc-vimlsp` for VIM script
- `coc-pyright` for Python
- `coc-sh` for SH scripts
- `coc-spell-checker` : General spell checker in EN

### Autocomplete : Completor

> Completor is not good for servers, as it requires vim version with python support. 

#### vimbox-draw

Create ASCII diagrams : 

- Visual select some box
- invoke `+o` to create box or `+O` to create box with label
- To add label into existing box, visual select the area then invoke `+c`

## Future Improvement

- [x] Script automatically detect the environment (e.g. BSD)
- [x] Symlink instead of copy. 
- [x] Deploy a scalable and portable environment.
- [ ] ~~Support Oh-My-Zsh installation~~
- [ ] Diagnostic Feature `-c` or `--check`
