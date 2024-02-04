#!/bin/bash
echo "requesting superuser privileges"
sudo -v

echo "setting up ssh keys..."
mkdir ~/.ssh

sudo find /mnt -maxdepth 3 -name "gusta-xda550" > out_teste.txt
keys_external=$(cat out_teste.txt | grep -v "*Permission*" | sed -n 1p)

if test -e $keys_external; then
    echo "keys found in /mnt drives"

    cp $keys_external ~/.ssh
    cp $keys_external.pub ~/.ssh

    sudo chmod 600 ~/.ssh/gusta-xda550
    sudo chmod 600 ~/.ssh/gusta-xda550.pub

    eval $(ssh-agent -s)
    ssh-add ~/.ssh/gusta-xda550

else
    sudo find /media -maxdepth 3 -name "gusta-xda550" > out_teste.txt
    keys_external=$(cat out_teste.txt | grep -v "*Permission*" | sed -n 1p)

    if test -e $keys_external; then
        echo "keys found in /media drives"

        cp $keys_external ~/.ssh
        cp $keys_external.pub ~/.ssh

        sudo chmod 600 ~/.ssh/gusta-xda550
        sudo chmod 600 ~/.ssh/gusta-xda550.pub

        eval $(ssh-agent -s)
        ssh-add ~/.ssh/gusta-xda550

    else
        if test -e /mnt/c/Users/gusta/.ssh/gusta-xda550; then
            cp /mnt/c/Users/gusta/.ssh/gusta-xda550 ~/.ssh
            cp /mnt/c/Users/gusta/.ssh/gusta-xda550.pub ~/.ssh

            sudo chmod 600 ~/.ssh/gusta-xda550
            sudo chmod 600 ~/.ssh/gusta-xda550.pub

            eval $(ssh-agent -s)
            ssh-add ~/.ssh/gusta-xda550
            echo "ssh keys found in windows user folder"
        else
            if test -e ~/.ssh/gusta-xda550; then
                eval $(ssh-agent -s)
                ssh-add ~/.ssh/gusta-xda550
                echo "ssh keys found locally"
            fi
        fi
    fi
fi

sudo rm out_teste.txt
sudo echo "   IdentityFile ~/.ssh/gusta-xda550" >> /etc/ssh/ssh_config

sleep 1

echo "installing dependencies..."
sudo apt install python3 python3-pip python-is-python3 build-essential neofetch openssh-server net-tools -y

sleep 1 
echo "installing neovim from source"
git clone -j8 https://github.com/neovim/neovim
cd neovim
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
cd ..
sudo rm -rf neovim

sleep 1
echo "setting up git..."
sudo apt install git -y
git config --global user.name "Gustavo Sousa"
git config --global user.email "gustavosousa@alu.ufc.br"

sleep 1
echo "installing zsh and plugins"
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

cat <<EOF >> teste.txt

SSH_ENV="$HOME/.ssh/agent-environment"

function start_agent {

    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {

        start_agent;

    }
else

    start_agent;
fi
EOF

sudo usermod -s $(which zsh) $USER
zsh
