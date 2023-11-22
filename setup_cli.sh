#!/bin/bash
echo "requesting superuser privileges"
sudo -v

echo "setting up ssh keys..."
mkdir ~/.ssh
cp /mnt/c/Users/gusta/.ssh/gusta-xda550 ~/.ssh
cp /mnt/c/Users/gusta/.ssh/gusta-xda550.pub ~/.ssh

sudo chmod 600 ~/.ssh/gusta-xda550
sudo chmod 600 ~/.ssh/gusta-xda550.pub

eval $(ssh-agent -s)
ssh-add ~/.ssh/gusta-xda550
sleep 1

echo "installing dependencies..."
sudo apt install python3 python3-pip python-is-python3 build-essential neofetch openssh-server -y

echo "installing zsh and plugins"
sleep 1
sudo apt install git curl zsh -y
{
	echo "y"
} | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone "https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv.git" ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autoswitch_virtualenv

file_path="$HOME/.zshrc"
new_text=" zsh-autosuggestions zsh-syntax-highlighting autoswitch_virtualenv catimg transfer command-not-found)"

old_plugins_line=$(grep "^plugins" "$HOME/.zshrc")
trimmed_saved_line="${old_plugins_line%?}"
appended_line="$trimmed_saved_line$new_text"

awk '$1 ~ /^plugins/ {$0 = "'"$appended_line"'"} 1' "$file_path" > temp_file
mv temp_file "$file_path"

sudo usermod -s $(which zsh) $USER
zsh