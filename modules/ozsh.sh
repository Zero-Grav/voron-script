#!/usr/bin/env bash
#
# Installation de OZSH
#

source ./_common.sh
sudo echo "" > /dev/null

_log "  => Installation de Oh My ZSH"
sudo apt install -y zsh autojump
if [ -e ~/.oh-my-zsh ]; then
  rm -rf ~/.oh-my-zsh
fi
git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ~/.zshrc
sed -i 's/# ENABLE_CORRECTION/ENABLE_CORRECTION/' ~/.zshrc
sed -i 's/plugins=(/plugins=(autojump command-not-found sudo common-aliases /' ~/.zshrc
sudo chsh -s /usr/bin/zsh $(whoami)