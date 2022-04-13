# Infidel's personal config for CLI based workspaces
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Naereen/StrapDown.js/graphs/commit-activity)

## General Info

This is the essential VIM and Tmux configuration for cli based unix systems.

## Clone
```
> git clone http://git.nnag.me/infidel/infidel_env.git
```

## Setup
``` 
$ ./install.sh
```
## VIM

### Global

- Leader remmaped to `,` 
- Enabled more visual blocks with J and K
- Auto tabbed lines from normal mode using `>`

### NerdTree

Toggle NerdTree with <CTRL-k><k>.

### EasyAlign

Perform multiline visual select then enter `ga`. Next enter your preference alignment.

### Goyo

Toggle Goyo from command input mode `:Goyo` or use the <F8> shortcut. 

### Limelight

Toggle Limelight from command input mode `:Limelight` or use the <Leader><l> shortcut.

### Completor

For autocomplete I choose completor. Jut type as usual and the completor will offer some completion, use tab to choose.


## Future Improvement

- [x] Script automatically detect the environment (e.g. BSD)
- [x] Symlink instead of copy. 
- [x] Deploy a scaleable and portable environment.
- [ ] Support Oh-My-Zsh installation

