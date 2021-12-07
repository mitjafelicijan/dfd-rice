#!/bin/bash

# DEBIAN FOR DEVELOPERS
# MUST BE ROOT

# wget -O rice.sh http://192.168.64.103:9100/rice.sh
# bash rice.sh

echo $0
echo $1
echo $2

exit


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


#ENDPOINT="http://192.168.64.103:9100"
ENDPOINT="https://raw.githubusercontent.com/mitjafelicijan/dfd-rice/master/scripts"
USERNAME="$(ls /home/)"
USERFOLDER="/home/$(ls /home/)"


# ansi color code variables
red="\e[0;91m"
blue="\e[0;94m"
expand_bg="\e[K"
blue_bg="\e[0;104m${expand_bg}"
red_bg="\e[0;101m${expand_bg}"
green_bg="\e[0;102m${expand_bg}"
green="\e[0;92m"
white="\e[0;97m"
bold="\e[1m"
uline="\e[4m"
reset="\e[0m"

print_header () {
  echo -e "\n\n${blue_bg}${bold} $1${reset}\n\n"
}


# general update
print_header "Updating repositories"
apt update
apt upgrade -y


# add non-free to sources list
print_header "Enabling non-free packages"
add-apt-repository non-free
apt update


# add sudo (add selection for user)
print_header "Installing sudo"
apt install -y sudo 
/sbin/usermod -aG sudo $USERNAME


# general utils
print_header "Installing essential software"
apt install -y htop git zip sqlite3 apt-transport-https curl gnupg software-properties-common build-essential cmake


# general wifi settings with terminal ui
print_header "Installing wifi network manager"
apt install -y network-manager


# desktop environment
print_header "Installing i3 desktop environment"
apt install -y xorg i3 i3blocks lua5.4 xss-lock

wget -O "$USERFOLDER/.xsession" "$ENDPOINT/xsession"
chown $USERNAME:$USERNAME "$USERFOLDER/.xsession"

echo "[[ -z \$DISPLAY && \$XDG_VTNR -eq 1 ]] && exec startx" > "$USERFOLDER/.bash_profile"
chown $USERNAME:$USERNAME "$USERFOLDER/.bash_profile"


# pulseaudio
print_header "Installing pulseaudio"
apt install -y pulseaudio pavucontrol
pulseaudio --kill
pulseaudio --start


# fonts
print_header "Installing additional fonts"
wget -O ttf.zip "$ENDPOINT/fonts/Hack-v3.003-ttf.zip"
unzip ttf.zip
cp ttf/* /usr/local/share/fonts/
fc-cache -f -v
rm -rf ttf/
rm -rf ttf.zip


# i3 config
print_header "Setting up i3 enviroment"
mkdir -p "$USERFOLDER/.config/i3"
wget -O "$USERFOLDER/.config/i3/config" "$ENDPOINT/i3"
chown -Rf $USERNAME:$USERNAME "$USERFOLDER/.config"


# terminal emulator
print_header "Setting up terminal emulator"
wget -O "$USERFOLDER/.Xdefaults" "$ENDPOINT/Xdefaults"
chown $USERNAME:$USERNAME "$USERFOLDER/.Xdefaults"


# code editors
print_header "Installing terminal code editors"
apt install -y vim micro xclip xsel


# file manager
print_header "Enabling terminal file manager"
apt install -y mc


# git ui
print_header "Installing Git UI"
wget -O gitui.tar.gz https://github.com/extrawurst/gitui/releases/download/v0.18.0/gitui-linux-musl.tar.gz
tar xvzf gitui.tar.gz -C /usr/local/bin/
rm gitui.tar.gz


# python stuff
print_header "Installing Python3 packages"
apt install -y python3-pip


# nodejs
print_header "Installing Node.js"
apt install -y nodejs npm


# nodejs
print_header "Installing Golang"
apt install -y golang


# rust
print_header "Installing Rust"
apt install -y rustc


# nim
print_header "Installing Nim"
apt install -y nim


# docker
print_header "Installing Docker"
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt -y install docker-ce docker-ce-cli containerd.io docker-compose

systemctl start docker
systemctl enable docker
systemctl status docker --no-pager

/sbin/usermod -aG docker $USERNAME


# ansible
print_header "Installing Ansible"
apt install -y ansible


# install browsers
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
apt update
print_header "Installing web browsers"
apt install -y brave-browser firefox-esr


# vscode
print_header "Installing Visual Code"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
apt update
apt install -y code
rm microsoft.gpg


# ohmybash
print_header "Enabling OhMyBash"
sudo -u $USERNAME sh -c "$(curl -fsSL https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh)" &
T1=${!}
wait ${T1}

# steam
#print_header "Installing Steam"
#dpkg --add-architecture i386
#apt update
#apt install steam


# do apt check and clean up
print_header "Cleaning up"
apt update
apt autoremove -y
apt autoclean -y


# restart after done
print_header "Rebooting system in 15 seconds ... You can CTRL+C to cancel reboot"
sleep 15
sudo -u root /sbin/reboot

