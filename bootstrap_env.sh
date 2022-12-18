#!/usr/bin/env zsh
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"

[ ! -e $HOME/.gitconfig ] && ln -s $HOME/conf-nyx/dotfiles/gitconfig $HOME/.gitconfig
[ ! -e $HOME/.zshrc ] && ln -s $HOME/conf-nyx/dotfiles/zshrc $HOME/.zshrc
source $HOME/.zshrc
