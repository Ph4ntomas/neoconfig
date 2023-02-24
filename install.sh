#!/bin/bash

VI=$(which nvim 2>/dev/null)

if [ $? -eq 1 ]; then
    VI=$(which vim 2>/dev/null)

    if [ $? -eq 1 ]; then
        echo "Either nvim or vim are needed"
    fi
fi

CURL=$(which curl 2>/dev/null)
if [ $? -eq 1 ]; then
    echo "Curl is needed for this script to work"
    exit 1;
fi

GIT=$(which git 2>/dev/null)
if [ $? -eq 1 ]; then
    echo "Git is needed for this script to work"
    exit 1;
fi

function backup_config() {
    echo "Backing up current configuration"
    mkdir -p ~/.neoconfig/backup/
    mkdir -p ~/.neoconfig/backup/config

    mv ~/.vim* ~/.neoconfig/backup/
    mv ~/.config/nvim ~/.neoconfig/backup/config/
}

function setup_vim_plug() {
    echo "Getting vim-plug installed"
    $CURL -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    $VI +PlugInstall +qall
}

function make_symlink() {
    echo "Creating symbolic links"

    pushd ~ 2>&1 >/dev/null
        ln -s ~/.neoconfig/.vim
        ln -s ~/.neoconfig/.vimrc
        ln -s ~/.neoconfig/.vimrc.before
        ln -s ~/.neoconfig/.vimrc.bundles

        pushd ~/.config >/dev/null
            ln -s ~/.neoconfig/config/nvim
            mkdir coc
        popd >/dev/null
    popd >/dev/null
}

$GIT clone https://github.com/Ph4ntomas/neoconfig.git ~/.neoconfig

backup_config
make_symlink
setup_vim_plug
