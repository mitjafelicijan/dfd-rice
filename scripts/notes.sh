# MUST BE ROOT

# general update
apt update
apt upgrade -y


# add non-free to sources list
add-apt-repository non-free
apt update


# add sudo (add selection for user)
apt install -y sudo 
/sbin/usermod -aG sudo $(ls /home/)


# general utils
apt install -y htop zip sqlite3 apt-transport-https curl gnupg software-properties-common build-essential cmake


# x220 wifi firmware
apt install -y firmware-iwlwifi

# general wifi settings with terminal ui
apt install -y network-manager
nmtui

# desktop environment
apt install -y xorg i3 i3blocks lua5.4 xss-lock

# add this to .xsession
#   #!/bin/sh
#   exec i3

# add this to .bash_profile
#   [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx

# resize screen
xrandr --output Virtual1 --mode 1280x800

# pulseaudio
apt install -y pulseaudio pavucontrol
pulseaudio --kill
pulseaudio --start

# add brave browser sources
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
apt update

# install browsers
apt install -y brave-browser firefox-esr

# python stuff
apt install -y python3-pip

# nodejs
apt install -y nodejs npm

# nodejs
apt install -y golang

# docker
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt -y install docker-ce docker-ce-cli containerd.io docker-compose

systemctl start docker
systemctl enable docker
systemctl status docker --no-pager



# code editors
apt install -y vim micro xclip xsel


# do apt check and clean up
apt update
apt autoremove -y
apt autoclean -y


# fonts
cp SFProText-Medium.ttf /usr/local/share/fonts/
fc-cache -f -v


# terminal emulator
# .Xdefaults 
URxvt*font: xft:SF Mono:pixelsize=14:antialias=true:hinting=true
URxvt*boldFont: xft:SF Mono:bold:pixelsize=14:antialias=true:hinting=true
URxvt.scrollBar: false
URxvt*inheritPixmap: true
URxvt*transperentp:  true
URxvt*shading:       16
*foreground: rgb:fb/fb/fb
*background: rgb:11/11/11
URxvt.internalBorder:  5 


# vscode
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
apt update
apt install -y code


# steam
dpkg --add-architecture i386
apt update
apt install steam

# mc 
#    copy from ~./.config/mc/ini


# ohmybash
su $(ls /home/)
cd
sh -c "$(curl -fsSL https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh)"
exit

# ./config/i3/config

bar {
  status_command i3status
  position top

  colors {
    background #111111
    statusline #ffffff
    separator  #111111

    focused_workspace  #ffffff #ffffff #111111
    active_workspace   #ffffff #ffffff #111111
    inactive_workspace #111111 #111111 #888888
    urgent_workspace   #900000 #900000 #ffffff
    binding_mode       #900000 #900000 #ffffff
  }
}

client.focused          #ff8c00 #ff8c00 #111111 #ff8c00 #ff8c00
client.focused_inactive #222222 #222222 #ffffff #222222 #222222
client.unfocused        #222222 #222222 #ffffff #222222 #222222
client.urgent           #ed2939 #ed2939 #ffffff #ed2939 #ed2939
client.placeholder      #ed2939 #ed2939 #ffffff #ed2939 #ed2939
client.background       #111111






