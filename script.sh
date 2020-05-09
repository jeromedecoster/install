# log $1 in underline green then $@ in yellow
log() { echo -e "\e[38;5;82;4m${1}\e[0m \e[38;5;226m${@:2}\e[0m"; }

# echo $1 in underline red then $@ in cyan (to the stderr)
err() { echo -e "\e[38;5;196;4m${1}\e[0m \e[38;5;87m${@:2}\e[0m" >&2; }

# kill sudo if script was started with `sudo bash <script>` 
sudo --reset-timestamp
# abort if sudo access is still already enabled (script started as root)
[[ -n $(sudo -n uptime 2>/dev/null) ]] && { err abort root access unauthorized; exit; }

DOCUMENTS=$(xdg-user-dir DOCUMENTS)

# ask sudo access
log warn sudo access required...
sudo echo >/dev/null
# one more check if the user abort the password question
[[ -z `sudo -n uptime 2>/dev/null` ]] && { err abort sudo required; exit; }

apt-update-upgrade-install() {
    log update apt
    sudo apt update
    
    log upgrade apt
    sudo apt upgrade --yes

    for package in ack build-essential curl docker git gparted htop jq obs-studio tree youtube-dl
    do 
        log install $package
        sudo apt install --yes $package
    done
}

apt-install-opera() {
    log install opera
    # add source if not already added (script previously executed)
    [[ -n $(grep opera-stable /etc/apt/sources.list.d/*) ]] && \
        sudo add-apt-repository 'deb https://deb.opera.com/opera-stable/ stable non-free';

    # list with `cat /etc/apt/sources.list`
    # manual edit with `sudo nano /etc/apt/sources.list`
    # remove with `sudo add-apt-repository --remove 'deb https://deb.opera.com/opera-stable/ stable non-free'`

    wget http://deb.opera.com/archive.key \
        --output-document=- \
        --quiet \
        | sudo apt-key add -
    # list with `apt-key list`
    # remove manually with:
    #
    # 1) apt-key list
    # pub   rsa4096 2019-09-12 [SC] [expire : 2021-09-11]
    #    68E9 B2B0 3661 EE3C 44F7  0750 4B8E C3BA ABDC 4346
    # uid          [unknown] Opera Software Archive Automatic Signing Key 2019 <packager@opera.com>
    #
    # 2) then `sudo apt-key del 'ABDC 4346'`
    sudo apt update
    sudo apt install --yes opera-stable

    # remove duplicate source warning : https://askubuntu.com/a/184446
    [[ -n $(grep opera-stable /etc/apt/sources.list.d/*) ]] && \
        sudo add-apt-repository --remove 'deb https://deb.opera.com/opera-stable/ stable non-free';
}

apt-install-code() {
    log install code
    [[ -z $(grep vscode /etc/apt/sources.list.d/*) ]] && \
        sudo add-apt-repository 'deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main';
    
    wget https://packages.microsoft.com/keys/microsoft.asc \
        --output-document=- \
        --quiet \
        | sudo apt-key add -

    sudo apt update
    sudo apt install code

    # remove duplicate source warning
    [[ -n $(grep vscode /etc/apt/sources.list.d/*) ]] && \
        sudo add-apt-repository --remove 'deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main';

    log install extension better-toml
    code --install-extension bungcip.better-toml
}

snap-update-install() {
    log snap refresh
    sudo snap refresh

    log install hugo
    sudo snap install hugo
}

install-terraform() {
    log install terraform
    curl raw.github.com/jeromedecoster/terraform/master/install.sh \
        --location \
        --silent \
        | bash
}

install-soulseek() {
    log install soulseek
    cd $DOCUMENTS
    curl raw.github.com/jeromedecoster/soulseek/master/script.sh \
        --location \
        --silent \
        | bash
}

install-github-split() {
    log install github-split
    cd $DOCUMENTS
    curl raw.github.com/jeromedecoster/github-split/master/script.sh \
        --location \
        --silent \
        | bash
}

install-down() {
    log install down
    curl raw.github.com/jeromedecoster/down/master/script.sh \
        --location \
        --silent \
        | bash
}



apt-update-upgrade-install
apt-install-opera
apt-install-code
snap-update-install
install-terraform
install-soulseek
install-github-split
install-down

# xdg-settings set default-web-browser firefox.desktop
