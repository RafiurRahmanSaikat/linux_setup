#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color


# Base directory for applications
APP_DIR="/Data/Software/Linux/Applications"

# Function for error handling
error_exit() {
    echo -e "${RED}Error: $1${NC}"
    read -p "Press [Enter] to continue..."  # Pause for user input before exiting
    exit 1
}

# Function to display the menu
show_menu() {

    local border="================================="
    echo -e "${BOLD}${GREEN}$border${NC}"
    echo -e " Select an Action " ${NC}
    echo -e "${BOLD}${GREEN}$border${NC}"
    echo -e "0) Set Time And Mount Data"
    echo -e "1) Setup Devlopment Environment"
    echo -e "2) Install Grub Theme"  # New option
    echo -e "3) Install Git"
    echo -e "4) Install NVM and Node.js"
    echo -e "5) Install Python"
    echo -e "6) Install MongoDB"
    echo -e "7) Install Postman"
    echo -e "8) Install Google Chrome"
    echo -e "9) Install Zoom"
    echo -e "10) Install MySQL and Workbench"
    echo -e "11) Install Visual Studio Code"
    echo -e "12) Install PostgreSQL"
    echo -e "13) Install Fish and Set Up Aliases"
    echo -e "14) Install All"
    echo -e "15) Exit"  # Update exit option number
    echo -e "${BOLD}${GREEN}$border${NC}"
    read -p "Enter your choice [0-15]: " choice
}


# Main script execution

install_dev_softwere() {
    echo -e "${GREEN}Installing Requried Development Application...${NC}"
setup_aliases
    # install_dependencies
    # install_nvm_node
    # install_git
    # config_bash_shell
    # install_fish
    # install_pnpm
    # install_python
    # install_mongodb
    # install_mysql
    # install_postgresql   #! Not Released For Latest Kubuntu
    # install_postman
    # install_vscode
    # install_chrome
    # install_zoom
    # install_grub

    echo -e "${GREEN}All development applications installed successfully!${NC}"

}




setup_aliases() {
    echo -e "Setting up aliases for Bash and Fish..."

    # Create ~/.bash_aliases if it doesn't exist
    if [ ! -f ~/.bash_aliases ]; then
        touch ~/.bash_aliases
        echo "Created ~/.bash_aliases file."
    fi


       # Bash aliases
    {
        echo "# Development Environment Aliases"
        echo "alias ll='ls -la'"
        echo "alias la='ls -A'"
        echo "alias l='ls -CF'"
        echo "alias cls='clear'"
        echo "alias h='history'"
        echo "alias grep='grep --color=auto'"

        echo "# Git Aliases"
        echo "alias g='git'"
        echo "alias gi='git init'"
        echo "alias ga='git add'"
        echo "alias gaa='git add .'"
        echo "alias gs='git status'"
        echo "alias gc='git commit -m'"
        echo "alias gco='git checkout'"
        echo "alias gb='git branch'"
        echo "alias gpl='git pull'"
        echo "alias gp='git push'"
        echo "alias gcl='git clone'"
        echo "alias gl='git log --oneline --graph --decorate'"

        echo "# Node.js / NPM Aliases"
        echo "alias npi='npm install'"
        echo "alias nprm='npm remove'"
        echo "alias pni='pnpm install'"
        echo "alias pnrm='pnpm remove'"

        echo "# Yarn Aliases"
        echo "alias ya='yarn add'"
        echo "alias yrm='yarn remove'"
        echo "alias y='yarn'"
        echo "alias yl='yarn list --depth=0'"

        echo "# Python and Django Aliases"
        echo "alias py='python3.12'"
        echo "alias python='python3.12'"
        echo "alias pip='pip3.12'"
        echo "alias pyenv='python3.12 -m venv'"
        echo "alias dj='python3.12 manage.py'"
        echo "alias djs='dj runserver'"
        echo "alias djmm='dj makemigrations'"
        echo "alias djm='dj migrate'"
        echo "alias dji='dj shell'"
        echo "alias djt='dj test'"
        echo "alias djc='dj createsuperuser'"

        echo "# MySQL Aliases"
        echo "alias mysql='mysql -u root -p'"
    } >> ~/.bash_aliases
    source ~/.bash_aliases
    source ~/.bashrc

    # Fish aliases
    fish_config_file=~/.config/fish/config.fish
    {
        echo "# Development Environment Aliases"
        echo "function ll"
        echo "    ls -la \$argv"
        echo "end"
        echo ""
        echo "function la"
        echo "    ls -A \$argv"
        echo "end"
        echo ""
        echo "function l"
        echo "    ls -CF \$argv"
        echo "end"
        echo ""
        echo "function cls"
        echo "    clear"
        echo "end"
        echo ""
        echo "function h"
        echo "    history"
        echo "end"
        echo ""
        echo "function grep"
        echo "    command grep --color=auto \$argv"
        echo "end"

        echo "# Git Aliases"
        echo "function g"
        echo "    git \$argv"
        echo "end"
        echo ""
        echo "function gi"
        echo "    git init \$argv"
        echo "end"
        echo ""
        echo "function ga"
        echo "    git add \$argv"
        echo "end"
        echo ""
        echo "function gaa"
        echo "    git add ."
        echo "end"
        echo ""
        echo "function gs"
        echo "    git status"
        echo "end"
        echo ""
        echo "function gc"
        echo "    git commit -m \$argv"
        echo "end"
        echo ""
        echo "function gco"
        echo "    git checkout \$argv"
        echo "end"
        echo ""
        echo "function gb"
        echo "    git branch \$argv"
        echo "end"
        echo ""
        echo "function gpl"
        echo "    git pull"
        echo "end"
        echo ""
        echo "function gp"
        echo "    git push"
        echo "end"
        echo ""
        echo "function gcl"
        echo "    git clone \$argv"
        echo "end"
        echo ""
        echo "function gl"
        echo "    git log --oneline --graph --decorate"
        echo "end"
        echo ""

        echo "# Node.js / NPM Aliases"
        echo "function npi"
        echo "    npm install \$argv"
        echo "end"
        echo ""
        echo "function nprm"
        echo "    npm remove \$argv"
        echo "end"
        echo ""
        echo "function pni"
        echo "    pnpm install \$argv"
        echo "end"
        echo ""
        echo "function pnrm"
        echo "    pnpm remove \$argv"
        echo "end"
        echo ""

        echo "# Yarn Aliases"
        echo "function ya"
        echo "    yarn add \$argv"
        echo "end"
        echo ""
        echo "function yrm"
        echo "    yarn remove \$argv"
        echo "end"
        echo ""
        echo "function y"
        echo "    yarn \$argv"
        echo "end"
        echo ""
        echo "function yl"
        echo "    yarn list --depth=0"
        echo "end"
        echo ""

        echo "# Python and Django Aliases"
        echo "function py"
        echo "    python3.12 \$argv"
        echo "end"
        echo ""
        echo "function pip"
        echo "    pip3.12 \$argv"
        echo "end"
        echo ""
        echo "function pyenv"
        echo "    python3.12 -m venv \$argv"
        echo "end"
        echo ""
        echo "function dj"
        echo "    python3.12 manage.py \$argv"
        echo "end"
        echo ""
        echo "function djs"
        echo "    dj runserver \$argv"
        echo "end"
        echo ""
        echo "function djmm"
        echo "    dj makemigrations \$argv"
        echo "end"
        echo ""
        echo "function djm"
        echo "    dj migrate \$argv"
        echo "end"
        echo ""
        echo "function dji"
        echo "    dj shell"
        echo "end"
        echo ""
        echo "function djt"
        echo "    dj test \$argv"
        echo "end"
        echo ""
        echo "function djc"
        echo "    dj createsuperuser \$argv"
        echo "end"
        echo ""

        echo "# MySQL Aliases"
        echo "function mysql"
        echo "    command mysql -u root -p \$argv"
        echo "end"

    } >> "$fish_config_file"
    source "$fish_config_file"
    echo "Aliases for Bash and Fish set up successfully!"
}






install_fish() {
    echo -e "${GREEN}Installing Fish...${NC}"
    sudo apt update || error_exit "Failed to update package list."
    sudo apt install -y fish || error_exit "Failed to install Fish."

    # Add Fish to the list of valid shells
    if ! grep -q "/usr/bin/fish" /etc/shells; then
        echo "/usr/bin/fish" | sudo tee -a /etc/shells
    fi

    # Change the default shell to Fish
    sudo chsh -s /usr/bin/fish $USER || error_exit "Failed to change default shell to Fish. You may need to enter your password."

    # Create Fish config file and set up aliases and functions
    fish_config_file=~/.config/fish/config.fish
    mkdir -p ~/.config/fish

    {
        echo "set -g fish_greeting ''"
    } >> "$fish_config_file"

    source "$fish_config_file"

    echo -e "${GREEN}Fish installed and set as default shell! ${NC}"
    echo -e "${YELLOW}Please restart your terminal for changes to take effect.${NC}"



}



install_dependencies() {
    echo -e "${GREEN}Installing required dependencies...${NC}"

    sudo nala install -y curl wget vim neofetch build-essential gdb lcov pkg-config \
        libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
        libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
        lzma lzma-dev tk-dev uuid-dev zlib1g-dev || error_exit "Failed to install dependencies."

    echo -e "${GREEN}Dependencies installed successfully!${NC}"
}



install_grub(){
    echo -e "${GREEN}Installing Grub Theme...${NC}"
    cd /Data/Software/Linux/Setup/Themes/Grub/Elegant-grub2-themes/
    sudo ./install.sh -t wave -l system
    echo -e "${GREEN}Grub installed ! ${NC}"
    echo -e "${YELLOW}Please restart your compueter for changes to take effect.${NC}"
}

install_pnpm() {
    echo -e "${GREEN}Installing PNPM...${NC}"

    npm install -g pnpm || error_exit "Failed to install PNPM."
    pnpm config set store-dir /Data/.pnpm-store || error_exit "Failed to set PNPM store directory."

    # Setting the alias for the bash shell

    echo -e "${GREEN}Configuring Bash Shell and Setting Alias...${NC}"

    {
        echo "export PNPM_HOME=\"/home/kubuntu/.local/share/pnpm\""
        echo "case \":\$PATH:\" in"
        echo "  *\":\$PNPM_HOME:\"*) ;;"
        echo "  *) export PATH=\"\$PNPM_HOME:\$PATH\" ;;"
        echo "esac"
    } >> ~/.bashrc


    # Create Fish config file and set up aliases and functions
    echo -e "${GREEN}Setting Alias to Fish Shell...${NC}"

    fish_config_file=~/.config/fish/config.fish

    mkdir -p ~/.config/fish
    {
        echo "set -gx PNPM_HOME \"/home/kubuntu/.local/share/pnpm\""
        echo "if not string match -q -- \$PNPM_HOME \$PATH"
        echo "  set -gx PATH \"\$PNPM_HOME\" \$PATH"
        echo "end"
    } >> "$fish_config_file"

    source "$fish_config_file"


    echo -e "${GREEN}PNPM installed and configured successfully!${NC}"
    echo -e "${YELLOW}Please restart your terminal for changes to take effect.${NC}"



}

install_mount_drive_set_time() {
    echo -e "${YELLOW}Setting RTC to local time...${NC}"
    sudo timedatectl set-local-rtc 1 --adjust-system-clock || error_exit "Failed to set RTC."

    echo -e "${GREEN}Time set to RTC successfully!${NC}"

    if [ ! -d "/Data" ]; then
        echo -e "${YELLOW}Creating /Data directory...${NC}"
        sudo mkdir /Data || error_exit "Failed to create /Data directory."
    fi

    # Update /etc/fstab
    echo "UUID=CC0255FB0255EB4A /Data ntfs defaults,uid=1000,gid=1000,dmask=000,fmask=000 0 0" | sudo tee -a /etc/fstab || error_exit "Failed to update /etc/fstab."

    # Reload the systemd manager configuration
    echo -e "${YELLOW}Reloading systemd manager configuration...${NC}"
    sudo systemctl daemon-reload || error_exit "Failed to reload systemd manager configuration."

    echo -e "${YELLOW}Mounting the NTFS drive...${NC}"
    sudo mount -a || error_exit "Failed to mount the NTFS drive."
    echo -e "${GREEN}Mounted NTFS drive successfully!${NC}"
}

install_package() {
    local package_name="$1"
    local package_file=$(find "$APP_DIR" -name "$package_name" -print -quit)

    if [ -z "$package_file" ]; then
        error_exit "$package_name not found. Please ensure the file is in the '$APP_DIR' directory."
    fi

    if [[ "$package_name" == *.deb ]]; then
        echo -e "${GREEN}Installing $package_name...${NC}"
        sudo dpkg -i "$package_file" || {
            echo -e "${YELLOW}Encountered issues during installation. Attempting to fix dependencies...${NC}"
            sudo nala install -f -y || error_exit "Failed to fix dependencies."
            sudo dpkg -i "$package_file" || error_exit "$package_name installation failed."
        }
    fi
}

install_git() {
    echo -e "${GREEN}Starting installation of Git...${NC}"
    sudo add-apt-repository -y ppa:git-core/ppa || error_exit "Failed to add Git PPA."
    sudo nala update || error_exit "Failed to update package list after adding PPA."
    sudo nala install -y git || error_exit "Failed to install Git."

    echo -e "${GREEN}Git installed successfully!${NC}"
}

install_nvm_node() {
    echo -e "${GREEN}Starting installation of NVM and Node.js...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash || error_exit "Failed to install NVM."
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || error_exit "Failed to source NVM."
    nvm install 22 || error_exit "Failed to install Node.js."

    fish_config_file=~/.config/fish/config.fish
    mkdir -p ~/.config/fish
    {
    echo "set PATH /home/kubuntu/.nvm/versions/node/v22.9.0/bin \$PATH"
    } >> "$fish_config_file"

    source ~/.config/fish/config.fish

    echo -e "${GREEN} Node and NVM installed Successfully... ${NC}"


}

install_python() {
    echo -e "${GREEN}Starting installation of Python...${NC}"

    PYTHON_TARBALL=$(find "$APP_DIR" -name "Python-*.tar.xz" -print -quit)

    if [ -z "$PYTHON_TARBALL" ]; then
        error_exit "Python tarball not found. Please ensure the Python tarball is in the '$APP_DIR' directory."
    fi

    sudo tar -xf "$PYTHON_TARBALL" -C /opt || error_exit "Failed to extract Python tarball."
    cd /opt/Python-* || error_exit "Python directory not found."
    sudo ./configure --enable-optimizations --with-ensurepip=install || error_exit "Python configure failed."
    sudo make -j "$(nproc)" || error_exit "Python make failed."
    sudo make altinstall || error_exit "Python installation failed."
    cd - || error_exit "Failed to return to the previous directory."


    fish_config_file=~/.config/fish/config.fish
    mkdir -p ~/.config/fish

    {
        echo "set -g fish_greeting ''"
        echo "function pip"
        echo "    pip3.12 \$argv"
        echo "end"
        echo ""
        echo "function py"
        echo "    python3.12 \$argv"
        echo "end"
        echo ""
        echo "function python"
        echo "    python3.12 \$argv"
        echo "end"
        echo ""

    } >> "$fish_config_file"

    source "$fish_config_file"

    echo -e "${GREEN}Python and Pip installed Successfully...${NC}"


}

install_mongodb() {
    echo -e "${GREEN}Starting installation of MongoDB...${NC}"
    install_package "mongodb-org-server_*.deb"
    install_package "mongodb-mongosh_*.deb"
    install_package "mongodb-compass_*.deb"

    # Start and enable MongoDB service
    sudo systemctl start mongod || error_exit "Failed to start MongoDB."
    sudo systemctl enable mongod || error_exit "Failed to enable MongoDB to start on boot."

    echo -e "${GREEN}MongoDB installed and started successfully!${NC}"
}

install_postman() {
    echo -e "${GREEN}Starting installation of Postman...${NC}"

    POSTMAN_TARBALL=$(find "$APP_DIR" -name "postman-*.tar.gz" -print -quit)

    if [ -z "$POSTMAN_TARBALL" ]; then
        error_exit "Postman tarball not found. Please ensure the Postman tarball is in the '$APP_DIR' directory."
    fi

    sudo mkdir -p /opt/Postman || error_exit "Failed to create installation directory."
    sudo tar -xzf "$POSTMAN_TARBALL" -C /opt/Postman --strip-components=1 || error_exit "Failed to extract Postman."
    sudo ln -s /opt/Postman/Postman /usr/bin/postman || error_exit "Failed to create Postman symlink."

    DESKTOP_FILE="/opt/Postman/Postman.desktop"
    if [ ! -f "$DESKTOP_FILE" ]; then
        echo -e "${YELLOW}Creating Postman desktop entry...${NC}"
        cat <<EOF | sudo tee "$DESKTOP_FILE"
[Desktop Entry]
Name=Postman
Exec=/opt/Postman/Postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Type=Application
Categories=Development;
Terminal=false
EOF
        sudo chmod +x "$DESKTOP_FILE" || error_exit "Failed to make the desktop entry executable."
    fi

    sudo desktop-file-install "$DESKTOP_FILE" || error_exit "Failed to install Postman desktop entry."

    echo -e "${GREEN}Postman installation completed successfully!${NC}"
}

install_chrome() {
    echo -e "${GREEN}Starting installation of Google Chrome...${NC}"
    install_package "google-chrome-*.deb"
    echo -e "${GREEN}Chrome installation completed successfully!${NC}"
}

install_zoom() {
    echo -e "${GREEN}Starting installation of Zoom...${NC}"
    install_package "zoom_*.deb"
    echo -e "${GREEN}Zoom installation completed successfully!${NC}"
}

install_mysql() {

    echo -e "${GREEN}Starting installation of Mysql Community Server...${NC}"


    MYSQL_TARBALL=$(find "$APP_DIR" -name "mysql-server_*.deb-bundle.tar" -print -quit)
    if [ -z "$MYSQL_TARBALL" ]; then
        error_exit "MySQL tarball not found. Please ensure the MySQL tarball is in the '$APP_DIR' directory."
    fi

    # Create a temporary directory for installation
    TEMP_DIR="/tmp/mysql"
    mkdir -p "$TEMP_DIR" || error_exit "Failed to create temporary directory."

    # Extract the tarball
    tar -xf "$MYSQL_TARBALL" -C "$TEMP_DIR" || error_exit "Failed to extract MySQL tarball."

    # Install MySQL server
    for deb in "$TEMP_DIR"/*.deb; do
        sudo dpkg -i "$deb" || echo -e "${YELLOW}Failed to install $deb. Attempting to fix dependencies...${NC}"
    done

    # Attempt to fix dependencies only once after all installations
    sudo nala install -f -y || error_exit "Failed to fix package dependencies for MySQL."

    echo -e "${GREEN}MySQL Community Server installation completed successfully!${NC}"
    # Install MySQL Workbench

    echo -e "${GREEN}Starting installation of Mysql Community Workbench...${NC}"


    install_package "mysql-workbench-community_*.deb"


    sudo systemctl start mysql || error_exit "Failed to start MySQL service."
    sudo systemctl enable mysql || error_exit "Failed to enable MySQL service."

    # Cleanup temporary directory
    rm -rf "$TEMP_DIR"


    echo -e "${GREEN}MySQL Community Workbench installation completed successfully!${NC}"
}





install_vscode() {
    echo -e "${GREEN}Starting installation of Visual Studio Code...${NC}"
    install_package "code_*.deb"
    echo -e "${GREEN}Visual Studio Code installation completed successfully!${NC}"
}

install_postgresql() {
    echo -e "${GREEN}Starting installation of PostgreSQL...${NC}"

    sudo apt update || error_exit "Failed to update package list."
    sudo apt install -y postgresql postgresql-contrib || error_exit "PostgreSQL installation failed."

    # Execute the PostgreSQL setup script
    sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh || error_exit "Failed to execute PostgreSQL setup script."

    echo -e "${GREEN}PostgreSQL installation completed successfully!${NC}"
}



install_nala() {
    echo -e "${GREEN}Installing Nala...${NC}"
    sudo apt update || error_exit "Failed to update package list."
    sudo apt install -y nala || error_exit "Failed to install Nala."
    echo -e "${GREEN}Nala installation completed successfully!${NC}"
}


if ! command -v nala &> /dev/null; then
    install_nala
fi

while true; do
    show_menu
    case $choice in
        0) install_mount_drive_set_time ;;
        1) install_dev_softwere ;;
        2) install_grub ;;  # Call the new function
        3) install_git ;;
        4) install_nvm_node ;;
        5) install_python ;;
        6) install_mongodb ;;
        7) install_postman ;;
        8) install_chrome ;;
        9) install_zoom ;;
        10) install_mysql ;;
        11) install_vscode ;;
        12) install_postgresql ;;
        13) install_fish && config_bash_shell ;;
        14) install_dev_softwere;;
        15) exit 0 ;;  # Update exit option
        *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
    esac
done