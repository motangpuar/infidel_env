#!/bin/bash

# cp ./.vimrc /home/$(whoami)/
# cp -r ./.vim/ /home/$(whoami)/
# cp -r ./.tmux.conf /home/$(whoami)/

user_guide () {
    echo
    echo "Usage: $0 [options]" 
    echo
    echo "Options:"
    echo "      -i : Install for Single User [user,root]"
    echo "      -a : Install for all user"


}

vim_extension () {

    vim +PlugInstall +qall
    vim -c "CocInstall coc-vimlsp coc-sh coc-python coc-spell-checker"
    vim -c "CocCommand cSpell.enableLanguage sh" # Add SH Script for spell checking

    if [ ! -d "$HOME/.local/bin" ] ; then
        mkdir -p $HOME/.local/bin/
    fi

    echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.profile # Temporary add exclusion next time

    curl -sL install-node.vercel.app/lts | bash -s -- -P $HOME/.local

        
}

user_install () {
    echo "VIM Conf"
    ln -sf $(pwd)/.vimrc /home/$(whoami)/
    ln -sf $(pwd)/.vim/ /home/$(whoami)/
    vim_extension

    
    echo "TMUX Conf"
    ln -sf $(pwd)/.tmux.conf /home/$(whoami)/
    
    echo "TMUX Plugin"
    mkdir -p "/home/$(whoami)/.tmux/plugins"
    [ -d "/home/$(whoami)/.tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm /home/$(whoami)/.tmux/plugins/tpm
}


root_install () {
    # sudo su
    echo "VIM Conf"
    sudo ln -sf $(pwd)/.vimrc /root/
    sudo ln -sf $(pwd)/.vim/  /root/
    vim_extension
    
    echo "TMUX Conf"
    sudo ln -sf $(pwd)/.tmux.conf /root/
    
    echo "TMUX Plugin"
    sudo mkdir -p "/root/.tmux/plugins"
    [ -d "/root/.tmux/plugins/tpm" ] || sudo git clone https://github.com/tmux-plugins/tpm /root/.tmux/plugins/tpm
}



# echo "What : $#"

if [ $# -lt 1 ]
then 
    user_guide # Call user guide
    exit
fi

# echo "case $1"

case "$1"  in

    -i)     echo "Installing For Single User "
            if [ $# -lt 2 ]
            then
                echo "Error Syntax" 
                user_guide # Call user guide
                exit
            fi
            case "$2" in
                user)  echo "USER Installation"
                       echo "Case $2"
                       user_install # Call User install function
                ;;
                root)  echo "ROOT Installation"
                       echo "Case $2"
                       root_install # Call User install function
                ;;
                *)
                       echo "Error Syntax" 
                       user_guide # Call user guide
                ;;
            esac
    ;;
    -a)     echo "Installing...."
            echo "Case Global" 
            if [ $# -gt 1 ]
            then
                user_guide # Call user guide
                exit
            fi
            user_install # Call User install function
            root_install # Call User install function
    ;;
    *)
                echo "Error Syntax" 
                user_guide # Call user guide
    ;;
esac
