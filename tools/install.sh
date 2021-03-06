#!/usr/bin/env bash

ARGS=$@

# dirty hack and only works for first user
USERNAME="$(ls -1 /home/)"
USERFOLDER="/home/$(ls -1 /home/)"

# colors
BLUEBG="\e[0;104m\e[K"
RESET="\e[0m"
BOLD="\e[1m"

# branch management
BRANCH="master"
if [ "$1" == "@develop" ]; then
    BRANCH="develop"
fi

# source endpoint
ENDPOINT="https://raw.githubusercontent.com/mitjafelicijan/dfd-rice/$BRANCH/tools"

# check if user is root, otherwise exit
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

print_header () {
  echo -e "\n\n${BLUEBG}${BOLD} $1${RESET}\n\n"
}

check_for_feature () {
    # if args empty presume install for all packages
    if [ -z "$ARGS" ]; then
        return 0
    else
        for arg in $ARGS; do
            if [ "$arg" = "$1" ]; then
                return 0
            fi
        done
    fi
    return 1
}

# info before continuing
print_header "Using endpoint: (CTRL+C to cancel) [will continue in 10s]"
echo "Endpoint: $ENDPOINT"
sleep 10

# general update
print_header "Updating repositories"
apt update
apt upgrade -y

add non-free to sources list
if check_for_feature "non-free"; then
    print_header "Enabling non-free packages"
    add-apt-repository non-free
    apt update
fi

# add sudo
if check_for_feature "sudo"; then
    print_header "Installing sudo"
    apt install -y sudo 
    /sbin/usermod -aG sudo $USERNAME
fi

# essential utils
if check_for_feature "essentials"; then
    print_header "Installing essential software"
    apt install -y \
        htop git zip sqlite3 tree hwinfo xz-utils \
        apt-transport-https curl \
        gnupg software-properties-common build-essential cmake \
        nmap rsync fzf
fi

# general wifi settings with terminal ui
if check_for_feature "wifi"; then
    print_header "Installing wifi network manager"
    apt install -y network-manager
fi

# desktop environment
if check_for_feature "desktop"; then
    print_header "Installing i3 desktop environment"
    apt install -y xorg i3 i3blocks lua5.4 xss-lock

    wget -O "$USERFOLDER/.xsession" "$ENDPOINT/config/xsession"
    chown $USERNAME:$USERNAME "$USERFOLDER/.xsession"

    echo "[[ -z \$DISPLAY && \$XDG_VTNR -eq 1 ]] && exec startx" > "$USERFOLDER/.bash_profile"
    chown $USERNAME:$USERNAME "$USERFOLDER/.bash_profile"

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
    wget -O "$USERFOLDER/.config/i3/config" "$ENDPOINT/config/i3"
    chown -Rf $USERNAME:$USERNAME "$USERFOLDER/.config"

    # i3status config
    print_header "Setting up i3status"
    mkdir -p "$USERFOLDER/.config/i3status"
    wget -O "$USERFOLDER/.config/i3status/config" "$ENDPOINT/config/i3status"
    chown -Rf $USERNAME:$USERNAME "$USERFOLDER/.config"

    # terminal emulator
    print_header "Setting up terminal emulator"
    wget -O "$USERFOLDER/.Xdefaults" "$ENDPOINT/config/Xdefaults"
    chown $USERNAME:$USERNAME "$USERFOLDER/.Xdefaults"
fi

# ati drivers
if check_for_feature "ati"; then
    print_header "Installing AMD ATI drivers"
    apt install -y firmware-amd-graphics
fi

# pulseaudio
if check_for_feature "pulseaudio"; then
    print_header "Installing pulseaudio"
    apt install -y pulseaudio pavucontrol
    pulseaudio --kill
    pulseaudio --start
fi

# code editors
if check_for_feature "code-editors"; then
    print_header "Installing terminal code editors"
    apt install -y vim micro xclip xsel

    print_header "Installing Visual Code"
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
    sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    apt update
    apt install -y code
    rm microsoft.gpg
fi

# ohmybash
if check_for_feature "ohmybash"; then
    print_header "Enabling OhMyBash"
    sudo -u $USERNAME sh -c "$(curl -fsSL https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh)" &
    T1=${!}
    wait ${T1}
fi

# file manager
if check_for_feature "file-managers"; then
    print_header "Installing terminal file manager"
    apt install -y mc
fi

# git ui
if check_for_feature "git-ui"; then
    print_header "Installing Git UI"
    wget -O gitui.tar.gz https://github.com/extrawurst/gitui/releases/download/v0.18.0/gitui-linux-musl.tar.gz
    tar xvzf gitui.tar.gz -C /usr/local/bin/
    rm gitui.tar.gz
fi

# meld diff tool
if check_for_feature "meld"; then
    print_header "Installing Meld Diff tool"
    apt install -y meld
fi

# image viewer
if check_for_feature "image-viewer"; then
    print_header "Installing Image viewer"
    apt install -y feh
fi

# image viewer
if check_for_feature "screenshots"; then
    print_header "Installing Screenshot tools"
    apt install -y maim
fi

# profiling tools
if check_for_feature "profiling"; then
    print_header "Installing profiling tools"
    apt install -y kcachegrind pyprof2calltree valgrind strace ltrace
fi

# install browsers
if check_for_feature "browsers"; then
    curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    apt update
    print_header "Installing web browsers"
    apt install -y brave-browser
    apt install -y firefox-esr
    apt install -y chromium chromium-l10n
fi

# python stuff
if check_for_feature "python"; then
    print_header "Installing Python3 packages"
    apt install -y python3-pip
fi

# nodejs
if check_for_feature "nodejs"; then
    print_header "Installing Node.js"
    apt install -y nodejs npm
fi

# golang
if check_for_feature "golang"; then
    print_header "Installing Golang"
    apt install -y Golang
fi

# rust
if check_for_feature "rust"; then
    print_header "Installing Rust"
    apt install -y rustc
fi

# nim
if check_for_feature "nim"; then
    print_header "Installing Nim"
    apt install -y nim
fi

# php
if check_for_feature "php"; then
    print_header "Installing PHP"
    apt install -y php-cli
fi

# ruby
if check_for_feature "ruby"; then
    print_header "Installing Ruby"
    apt install -y ruby
fi

# docker
if check_for_feature "docker"; then
    print_header "Installing Docker"
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt update
    apt -y install docker-ce docker-ce-cli containerd.io docker-compose

    systemctl start docker
    systemctl enable docker
    systemctl status docker --no-pager

    /sbin/usermod -aG docker $USERNAME
fi

# virtualbox
if check_for_feature "virtualbox"; then
    print_header "Installing Virtualbox"
    apt install -y virtualbox virtualbox-ext-pack
    adduser $USERNAME vboxusers
fi

# ansible
if check_for_feature "ansible"; then
    print_header "Installing Ansible"
    apt install -y ansible
fi

# flatpak
if check_for_feature "flatpak"; then
    print_header "Installing Flatpak"
    apt install -y flatpak
fi

# mlocate
if check_for_feature "mlocate"; then
    print_header "Installing mlocate"
    apt install -y mlocate
    updatedb
fi


# do apt check and clean up
print_header "Cleaning up"
apt update
apt autoremove -y
apt autoclean -y

# restart after done
print_header "Rebooting system in 15 seconds ... You can CTRL+C to cancel reboot"
sleep 15
sudo -u root /sbin/reboot
