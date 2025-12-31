#!/bin/bash

################################################################################
# Kubuntu Development Environment Setup Script - COMPLETE VERSION
# Version:  3.0
# Description: Comprehensive automated installer with interactive/auto modes
# Author: Setup Script
# License: MIT
################################################################################

# ============================================================================
# COLOR DEFINITIONS
# ============================================================================
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# ============================================================================
# CONFIGURATION
# ============================================================================
readonly APP_DIR="/Data/Software/Linux/Applications"
readonly BACKUP_DIR="/Data/Software/Linux/Backups"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${SCRIPT_DIR}/setup_dev_env_$(date +%Y%m%d_%H%M%S).log"
readonly NTFS_UUID="746AACA86AAC6896"
readonly NTFS_MOUNT="/Data"

# Auto-configuration settings
readonly AUTO_REMOVE_CONFIGS=true  # Automatically remove configs during uninstall
readonly AUTO_INSTALL_PGADMIN_MODE=3  # 1=Desktop, 2=Web, 3=Both
readonly AUTO_POSTGRESQL_REMOTE=true  # Enable PostgreSQL remote access
readonly AUTO_SET_FISH_DEFAULT=true  # Set Fish as default shell

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error_exit() {
    echo -e "${RED}ERROR: $1${NC}" | tee -a "$LOG_FILE"
    exit 1
}

success_msg() {
    echo -e "${GREEN}✓ $1${NC}" | tee -a "$LOG_FILE"
}

info_msg() {
    echo -e "${CYAN}ℹ $1${NC}" | tee -a "$LOG_FILE"
}

warning_msg() {
    echo -e "${YELLOW}⚠ $1${NC}" | tee -a "$LOG_FILE"
}

check_sudo() {
    if [ "$EUID" -eq 0 ]; then
        error_exit "Please do not run this script as root.  It will ask for sudo when needed."
    fi
}

press_enter() {
    echo ""
    read -p "Press Enter to continue..." -r
}

# ============================================================================
# SYSTEM SETUP FUNCTIONS
# ============================================================================

install_mount_drive_set_time() {
    info_msg "Configuring system time and mounting data drive..."

    sudo timedatectl set-local-rtc 1 --adjust-system-clock || error_exit "Failed to set RTC"
    success_msg "Time set to RTC successfully"

    if [ ! -d "$NTFS_MOUNT" ]; then
        info_msg "Creating $NTFS_MOUNT directory..."
        sudo mkdir -p "$NTFS_MOUNT" || error_exit "Failed to create $NTFS_MOUNT directory"
    fi

    if !  grep -q "$NTFS_MOUNT" /etc/fstab; then
        warning_msg "Adding NTFS drive to /etc/fstab..."
        echo "UUID=$NTFS_UUID $NTFS_MOUNT ntfs defaults,uid=1000,gid=1000,dmask=077,fmask=077 0 0" | sudo tee -a /etc/fstab
        sudo systemctl daemon-reload
        sudo mount -a || error_exit "Failed to mount drive"
        success_msg "Drive mounted successfully"
    else
        success_msg "Drive already configured in fstab"
    fi

    sudo mkdir -p "$APP_DIR" "$BACKUP_DIR"
    success_msg "Application directories created"
}

install_dependencies() {
    info_msg "Installing system dependencies..."

    sudo DEBIAN_FRONTEND=noninteractive apt update || error_exit "Failed to update package list"

    sudo DEBIAN_FRONTEND=noninteractive apt install -y \
        curl wget vim git neofetch htop tree \
        build-essential gdb lcov pkg-config cmake \
        libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev \
        liblzma-dev libncurses5-dev libreadline6-dev libsqlite3-dev \
        libssl-dev lzma tk-dev uuid-dev zlib1g-dev \
        libpq-dev libxml2-dev libxslt1-dev \
        ca-certificates gnupg lsb-release \
        software-properties-common apt-transport-https \
        || error_exit "Failed to install dependencies"

    success_msg "System dependencies installed successfully"
}

install_grub() {
    info_msg "Installing Grub Theme..."

    local grub_theme_dir="$NTFS_MOUNT/Software/Linux/Setup/Themes/Grub/Elegant-grub2-themes"

    if [ !  -d "$grub_theme_dir" ]; then
        warning_msg "Grub theme directory not found - skipping"
        return 0
    fi

    cd "$grub_theme_dir" || return 0
    sudo ./install.sh -t wave -l system || warning_msg "Failed to install grub theme"

    success_msg "Grub theme installed successfully"
}

# ============================================================================
# DEVELOPMENT TOOLS INSTALLATION
# ============================================================================

install_git() {
    info_msg "Installing Git (latest version via PPA)..."

    sudo add-apt-repository -y ppa:git-core/ppa || error_exit "Failed to add Git PPA"
    sudo DEBIAN_FRONTEND=noninteractive apt update || error_exit "Failed to update after adding PPA"
    sudo DEBIAN_FRONTEND=noninteractive apt install -y git || error_exit "Failed to install Git"

    local git_version=$(git --version)
    success_msg "Git installed successfully: $git_version"
}

install_nvm_node() {
    info_msg "Installing NVM and Node.js LTS..."

    if [ -d "$HOME/.nvm" ]; then
        warning_msg "NVM already installed - skipping"
        return 0
    fi

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
        || error_exit "Failed to install NVM"

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm. sh" ] && \. "$NVM_DIR/nvm.sh"

    info_msg "Installing Node.js LTS..."
    nvm install --lts || error_exit "Failed to install Node. js"
    nvm use --lts
    nvm alias default 'lts/*'

    local node_version=$(node --version)
    local npm_version=$(npm --version)

    success_msg "Node.js $node_version installed successfully"
    success_msg "npm $npm_version installed successfully"

    # Configure for Fish shell
    local node_path=$(ls -d "$NVM_DIR/versions/node/v"*/ | tail -n1)
    local node_bin_path="${node_path}bin"

    mkdir -p "$HOME/.config/fish"
    if !  grep -q "NVM setup" "$HOME/.config/fish/config.fish" 2>/dev/null; then
        cat >> "$HOME/.config/fish/config.fish" << EOF

# NVM setup
set -gx NVM_DIR "$NVM_DIR"
set -gx PATH $node_bin_path \$PATH
EOF
        success_msg "Fish configuration updated with Node.js path"
    fi
}

install_pnpm() {
    info_msg "Installing PNPM..."

    if !  command -v npm &> /dev/null; then
        error_exit "npm is not installed. Please install Node. js first."
    fi

    npm install -g pnpm || error_exit "Failed to install PNPM"

    mkdir -p "$NTFS_MOUNT/. pnpm-store"
    pnpm config set store-dir "$NTFS_MOUNT/.pnpm-store" || warning_msg "Failed to set PNPM store directory"

    local pnpm_version=$(pnpm --version)
    success_msg "PNPM $pnpm_version installed successfully"

    # Configure for Bash
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "PNPM_HOME" "$HOME/.bashrc"; then
            cat >> "$HOME/. bashrc" << 'EOF'

# PNPM setup
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
EOF
        fi
    fi

    # Configure for Fish
    mkdir -p "$HOME/.config/fish"
    if ! grep -q "PNPM setup" "$HOME/.config/fish/config.fish" 2>/dev/null; then
        cat >> "$HOME/.config/fish/config.fish" << 'EOF'

# PNPM setup
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
if not contains $PNPM_HOME $PATH
    set -gx PATH $PNPM_HOME $PATH
end
EOF
    fi
}

install_python() {
    info_msg "Installing Python from source..."

    local PYTHON_TARBALL=$(find "$APP_DIR" -name "Python*. tar.xz" -print -quit)

    if [ -z "$PYTHON_TARBALL" ]; then
        warning_msg "Python tarball not found in $APP_DIR - skipping"
        return 0
    fi

    local PYTHON_VERSION=$(basename "$PYTHON_TARBALL" | sed -n 's/Python-\([0-9]\+\.[0-9]\+\)\..*/\1/p')
    info_msg "Found Python $PYTHON_VERSION"

    if command -v "python$PYTHON_VERSION" &> /dev/null; then
        warning_msg "Python $PYTHON_VERSION already installed - skipping"
        return 0
    fi

    sudo tar -xf "$PYTHON_TARBALL" -C /opt || error_exit "Failed to extract Python"
    cd /opt/Python-* || error_exit "Python directory not found"

    info_msg "Configuring Python (this may take a while)..."
    sudo ./configure --enable-optimizations --with-ensurepip=install || error_exit "Configuration failed"

    info_msg "Building Python (this will take several minutes)..."
    sudo make -j"$(nproc)" || error_exit "Build failed"

    info_msg "Installing Python..."
    sudo make altinstall || error_exit "Installation failed"

    cd - > /dev/null

    success_msg "Python $PYTHON_VERSION installed successfully"

    # Create aliases for Fish
    mkdir -p "$HOME/.config/fish"
    if ! grep -q "Python $PYTHON_VERSION aliases" "$HOME/.config/fish/config.fish" 2>/dev/null; then
        cat >> "$HOME/.config/fish/config.fish" << EOF

# Python $PYTHON_VERSION aliases
function python
    command python${PYTHON_VERSION} \$argv
end

function py
    command python${PYTHON_VERSION} \$argv
end

function pip
    command pip${PYTHON_VERSION} \$argv
end
EOF
    fi

    # Create aliases for Bash
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "Python $PYTHON_VERSION aliases" "$HOME/.bashrc"; then
            cat >> "$HOME/. bashrc" << EOF

# Python $PYTHON_VERSION aliases
alias python='python${PYTHON_VERSION}'
alias py='python${PYTHON_VERSION}'
alias pip='pip${PYTHON_VERSION}'
EOF
        fi
    fi
}

# ============================================================================
# DATABASE INSTALLATION
# ============================================================================

install_mongodb() {
    info_msg "Installing MongoDB..."

    local mongodb_server=$(find "$APP_DIR" -name "mongodb-org-server_*.deb" -print -quit)

    if [ -z "$mongodb_server" ]; then
        warning_msg "MongoDB packages not found in $APP_DIR - skipping"
        return 0
    fi

    info_msg "Installing MongoDB Server..."
    sudo dpkg -i "$mongodb_server" || true
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y || error_exit "Failed to install MongoDB Server"

    local mongodb_shell=$(find "$APP_DIR" -name "mongodb-mongosh_*.deb" -print -quit)
    if [ -n "$mongodb_shell" ]; then
        info_msg "Installing MongoDB Shell..."
        sudo dpkg -i "$mongodb_shell" || true
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y
    fi

    local mongodb_compass=$(find "$APP_DIR" -name "mongodb-compass_*.deb" -print -quit)
    if [ -n "$mongodb_compass" ]; then
        info_msg "Installing MongoDB Compass..."
        sudo dpkg -i "$mongodb_compass" || true
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y
    fi

    sudo systemctl start mongod || error_exit "Failed to start MongoDB"
    sudo systemctl enable mongod || error_exit "Failed to enable MongoDB"

    success_msg "MongoDB installed and running"
}

install_postgresql() {
    info_msg "Installing PostgreSQL and pgAdmin..."

    sudo DEBIAN_FRONTEND=noninteractive apt update
    sudo DEBIAN_FRONTEND=noninteractive apt install -y postgresql-common || error_exit "Failed to install postgresql-common"

    info_msg "Setting up PostgreSQL repository..."
    yes '' | sudo /usr/share/postgresql-common/pgdg/apt. postgresql.org.sh 2>/dev/null || error_exit "Failed to setup PostgreSQL repository"

    sudo DEBIAN_FRONTEND=noninteractive apt update
    sudo DEBIAN_FRONTEND=noninteractive apt install -y postgresql postgresql-contrib || error_exit "Failed to install PostgreSQL"

    local pg_version=$(psql --version)
    success_msg "PostgreSQL installed: $pg_version"

    info_msg "Setting up pgAdmin repository..."
    curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | \
        sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg 2>/dev/null

    sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'

    sudo DEBIAN_FRONTEND=noninteractive apt update

    # Auto-install based on mode
    case $AUTO_INSTALL_PGADMIN_MODE in
        1)
            sudo DEBIAN_FRONTEND=noninteractive apt install -y pgadmin4-desktop || error_exit "Failed to install pgAdmin Desktop"
            success_msg "pgAdmin Desktop installed"
            ;;
        2)
            sudo DEBIAN_FRONTEND=noninteractive apt install -y pgadmin4-web || error_exit "Failed to install pgAdmin Web"
            success_msg "pgAdmin Web installed"
            ;;
        3)
            sudo DEBIAN_FRONTEND=noninteractive apt install -y pgadmin4 || error_exit "Failed to install pgAdmin"
            success_msg "pgAdmin (Desktop & Web) installed"
            ;;
    esac

    # Auto-configure for remote access if enabled
    if [ "$AUTO_POSTGRESQL_REMOTE" = true ]; then
        local PG_VER=$(psql --version | grep -oP '\d+' | head -1)
        local CONF_DIR="/etc/postgresql/$PG_VER/main"

        sudo sed -i "s/^#listen_addresses = . */listen_addresses = '*'/" "$CONF_DIR/postgresql.conf"
        echo "host    all             all             0.0.0.0/0               md5" | sudo tee -a "$CONF_DIR/pg_hba.conf" > /dev/null

        sudo systemctl restart postgresql
        success_msg "PostgreSQL configured for remote access"
    fi

    success_msg "PostgreSQL setup complete"
}

install_mysql() {
    info_msg "Installing MySQL Server and Workbench..."

    local mysql_tarball=$(find "$APP_DIR" -name "mysql-server_*.deb-bundle.tar" -print -quit)

    if [ -z "$mysql_tarball" ]; then
        warning_msg "MySQL tarball not found in $APP_DIR - skipping"
        return 0
    fi

    local temp_dir="/tmp/mysql-install"
    mkdir -p "$temp_dir"

    info_msg "Extracting MySQL packages..."
    tar -xf "$mysql_tarball" -C "$temp_dir" || error_exit "Failed to extract MySQL tarball"

    info_msg "Installing MySQL packages..."
    sudo dpkg -i "$temp_dir"/*.deb || true
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y || error_exit "Failed to install MySQL"

    sudo systemctl enable mysql
    sudo systemctl start mysql || error_exit "Failed to start MySQL"

    success_msg "MySQL Server installed"

    local workbench_deb=$(find "$APP_DIR" -name "mysql-workbench-community_*.deb" -print -quit)

    if [ -n "$workbench_deb" ]; then
        info_msg "Installing MySQL Workbench..."
        sudo dpkg -i "$workbench_deb" || true
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y || warning_msg "MySQL Workbench installation had issues"
        success_msg "MySQL Workbench installed"
    fi

    rm -rf "$temp_dir"

    success_msg "MySQL setup complete"
    info_msg "Remember to run 'sudo mysql_secure_installation' manually later"
}

# ============================================================================
# APPLICATION INSTALLATION
# ============================================================================

install_chrome() {
    info_msg "Installing Google Chrome..."

    if command -v google-chrome &> /dev/null; then
        warning_msg "Google Chrome already installed - skipping"
        return 0
    fi

    local chrome_deb=$(find "$APP_DIR" -name "google-chrome-stable_*.deb" -print -quit)

    if [ -z "$chrome_deb" ]; then
        info_msg "Downloading latest Google Chrome..."
        chrome_deb="$APP_DIR/google-chrome-stable_current_amd64.deb"
        wget -q -O "$chrome_deb" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
            || error_exit "Failed to download Chrome"
    fi

    info_msg "Installing Chrome..."
    sudo dpkg -i "$chrome_deb" || true
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y || error_exit "Failed to install Chrome"

    local chrome_version=$(google-chrome --version)
    success_msg "Google Chrome installed: $chrome_version"
}

install_firefox() {
    info_msg "Installing Mozilla Firefox..."

    local firefox_archive=$(find "$APP_DIR" -name "firefox*. tar.bz2" -print -quit)

    if [ -z "$firefox_archive" ]; then
        warning_msg "Firefox archive not found.  Installing from repository..."
        sudo DEBIAN_FRONTEND=noninteractive apt update
        sudo DEBIAN_FRONTEND=noninteractive apt install -y firefox || error_exit "Failed to install Firefox"
        success_msg "Firefox installed from repository"
        return 0
    fi

    sudo mkdir -p /opt/firefox
    info_msg "Extracting Firefox..."
    sudo tar -xjf "$firefox_archive" -C /opt/firefox --strip-components=1 || error_exit "Failed to extract Firefox"

    sudo ln -sf /opt/firefox/firefox /usr/bin/firefox

    local desktop_file="/usr/share/applications/firefox. desktop"
    cat << 'EOF' | sudo tee "$desktop_file" > /dev/null
[Desktop Entry]
Name=Firefox
Exec=/usr/bin/firefox %u
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
Terminal=false
EOF

    sudo chmod +x "$desktop_file"
    success_msg "Firefox installed successfully"
}

install_postman() {
    info_msg "Installing Postman..."

    if [ -d "/opt/Postman" ]; then
        warning_msg "Postman already installed - skipping"
        return 0
    fi

    sudo mkdir -p /opt/Postman

    local postman_tarball=$(find "$APP_DIR" -name "postman-*. tar.gz" -print -quit)

    if [ -z "$postman_tarball" ]; then
        info_msg "Downloading latest Postman..."
        postman_tarball="$APP_DIR/postman-latest.tar.gz"
        wget -q -O "$postman_tarball" https://dl.pstmn.io/download/latest/linux64 \
            || error_exit "Failed to download Postman"
    fi

    info_msg "Extracting Postman..."
    sudo tar -xzf "$postman_tarball" -C /opt/Postman --strip-components=1 \
        || error_exit "Failed to extract Postman"

    sudo ln -sf /opt/Postman/Postman /usr/bin/postman

    local desktop_file="/usr/share/applications/postman.desktop"
    cat << 'EOF' | sudo tee "$desktop_file" > /dev/null
[Desktop Entry]
Name=Postman
Exec=/usr/bin/postman
Icon=/opt/Postman/app/resources/app/assets/icon. png
Type=Application
Categories=Development;
Terminal=false
EOF

    sudo chmod +x "$desktop_file"
    sudo desktop-file-install "$desktop_file" 2>/dev/null

    success_msg "Postman installed successfully"
}

install_vscode() {
    info_msg "Installing Visual Studio Code..."

    if command -v code &> /dev/null; then
        warning_msg "VS Code already installed - skipping"
        return 0
    fi

    local vscode_deb=$(find "$APP_DIR" -name "code_*.deb" -print -quit)

    if [ -n "$vscode_deb" ]; then
        info_msg "Installing from local file..."
        sudo dpkg -i "$vscode_deb" || true
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y || error_exit "Failed to install VS Code"
    else
        info_msg "Adding Microsoft repository..."
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages. microsoft.gpg 2>/dev/null
        sudo install -D -o root -g root -m 644 /tmp/packages. microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f /tmp/packages.microsoft.gpg

        sudo DEBIAN_FRONTEND=noninteractive apt update
        sudo DEBIAN_FRONTEND=noninteractive apt install -y code || error_exit "Failed to install VS Code"
    fi

    success_msg "Visual Studio Code installed successfully"
}

install_zoom() {
    info_msg "Installing Zoom..."

    local zoom_deb=$(find "$APP_DIR" -name "zoom_*.deb" -print -quit)

    if [ -z "$zoom_deb" ]; then
        info_msg "Downloading latest Zoom..."
        zoom_deb="$APP_DIR/zoom_amd64.deb"
        wget -q -O "$zoom_deb" https://zoom.us/client/latest/zoom_amd64.deb \
            || error_exit "Failed to download Zoom"
    fi

    sudo dpkg -i "$zoom_deb" || true
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y || error_exit "Failed to install Zoom"

    success_msg "Zoom installed successfully"
}


# ============================================================================
# JETBRAINS IDE INSTALLATION
# ============================================================================

install_jetbrains_ide() {
    local ide_name="$1"
    local search_pattern="$2"
    local install_dir="/opt/$ide_name"

    info_msg "Installing $ide_name..."

    # Try to find the tarball with multiple search methods
    local ide_tarball=""

    # First try:  exact pattern match
    ide_tarball=$(find "$APP_DIR" -maxdepth 1 -type f -name "$search_pattern" -print -quit)

    # Second try: case-insensitive
    if [ -z "$ide_tarball" ]; then
        ide_tarball=$(find "$APP_DIR" -maxdepth 1 -type f -iname "$search_pattern" -print -quit)
    fi

    # Third try: broader pattern for this specific IDE (MUST end with .tar.gz)
    if [ -z "$ide_tarball" ]; then
        case "${ide_name,,}" in
            pycharm)
                ide_tarball=$(find "$APP_DIR" -maxdepth 1 -type f -iname "*pycharm*.tar.gz" -print -quit)
                ;;
            webstorm)
                ide_tarball=$(find "$APP_DIR" -maxdepth 1 -type f -iname "*webstorm*.tar.gz" -print -quit)
                ;;
            clion)
                ide_tarball=$(find "$APP_DIR" -maxdepth 1 -type f -iname "*clion*.tar.gz" -print -quit)
                ;;
            datagrip)
                ide_tarball=$(find "$APP_DIR" -maxdepth 1 -type f -iname "*datagrip*.tar.gz" -print -quit)
                ;;
            intellijidea)
                ide_tarball=$(find "$APP_DIR" -maxdepth 1 -type f -iname "*idea*.tar.gz" -print -quit)
                ;;
        esac
    fi

    if [ -z "$ide_tarball" ]; then
        warning_msg "$ide_name tarball not found in $APP_DIR - skipping"
        return 0
    fi

    info_msg "Found:  $(basename "$ide_tarball")"

    # Check if already installed
    if [ -d "$install_dir" ]; then
        warning_msg "$ide_name already installed - skipping"
        return 0
    fi

    # Create installation directory
    sudo mkdir -p "$install_dir"

    # Extract tarball
    info_msg "Extracting $ide_name..."
    sudo tar -xzf "$ide_tarball" -C "$install_dir" --strip-components=1 \
        || error_exit "Failed to extract $ide_name"

    # Find the executable based on IDE type
    local exe_path=""
    local exe_name=""

    case "${ide_name,,}" in
        pycharm)
            exe_path=$(find "$install_dir/bin" -name "pycharm" 2>/dev/null | head -1)
            exe_name="pycharm"
            ;;
        webstorm)
            exe_path=$(find "$install_dir/bin" -name "webstorm" 2>/dev/null | head -1)
            exe_name="webstorm"
            ;;
        clion)
            exe_path=$(find "$install_dir/bin" -name "clion" 2>/dev/null | head -1)
            exe_name="clion"
            ;;
        datagrip)
            exe_path=$(find "$install_dir/bin" -name "datagrip" 2>/dev/null | head -1)
            if [ -z "$exe_path" ]; then
                exe_path=$(find "$install_dir/bin" -name "*.sh" 2>/dev/null | grep -v "inspect\|format\|remote" | head -1)
            fi
            exe_name="datagrip"
            ;;
        intellijidea)
            exe_path=$(find "$install_dir/bin" -name "idea" 2>/dev/null | head -1)
            exe_name="idea"
            ;;
        *)
            exe_path=$(find "$install_dir/bin" -name "*.sh" 2>/dev/null | grep -v "inspect\|format\|remote" | head -1)
            exe_name="${ide_name,,}"
            ;;
    esac

    # Create symlink if executable found
    if [ -n "$exe_path" ] && [ -f "$exe_path" ]; then
        sudo chmod +x "$exe_path"
        sudo ln -sf "$exe_path" "/usr/local/bin/$exe_name"
        success_msg "Created symlink:  /usr/local/bin/$exe_name"
    else
        warning_msg "Could not find executable for $ide_name"
    fi

    # Create desktop entry
    create_jetbrains_desktop_entry "$ide_name" "$install_dir" "$exe_path"

    success_msg "$ide_name installed successfully"
}

create_jetbrains_desktop_entry() {
    local ide_name="$1"
    local install_dir="$2"
    local exe_path="$3"
    local desktop_file="/usr/share/applications/${ide_name,,}.desktop"

    # Find icon
    local icon_path=$(find "$install_dir/bin" -name "*.svg" 2>/dev/null | head -1)
    if [ -z "$icon_path" ]; then
        icon_path=$(find "$install_dir/bin" -name "*.png" 2>/dev/null | head -1)
    fi
    if [ -z "$icon_path" ]; then
        icon_path=$(find "$install_dir" -path "*/resources/*" -name "*.png" 2>/dev/null | head -1)
    fi
    [ -z "$icon_path" ] && icon_path="$install_dir/bin/${ide_name,,}.png"

    # If exe_path wasn't passed or is empty, try to find it again
    if [ -z "$exe_path" ]; then
        case "${ide_name,,}" in
            pycharm)
                exe_path=$(find "$install_dir/bin" -name "pycharm" 2>/dev/null | head -1)
                ;;
            webstorm)
                exe_path=$(find "$install_dir/bin" -name "webstorm" 2>/dev/null | head -1)
                ;;
            clion)
                exe_path=$(find "$install_dir/bin" -name "clion" 2>/dev/null | head -1)
                ;;
            datagrip)
                exe_path=$(find "$install_dir/bin" -name "datagrip" 2>/dev/null | head -1)
                if [ -z "$exe_path" ]; then
                    exe_path=$(find "$install_dir/bin" -name "*.sh" 2>/dev/null | grep -v "inspect\|format\|remote" | head -1)
                fi
                ;;
            intellijidea)
                exe_path=$(find "$install_dir/bin" -name "idea" 2>/dev/null | head -1)
                ;;
            *)
                exe_path=$(find "$install_dir/bin" -name "*.sh" 2>/dev/null | grep -v "inspect\|format\|remote" | head -1)
                ;;
        esac
    fi

    # Determine category and comment
    local category="Development;IDE;"
    local comment="$ide_name IDE"
    local wmclass="jetbrains-${ide_name,,}"

    case "${ide_name,,}" in
        pycharm)
            category="Development;IDE;"
            comment="Python IDE"
            wmclass="jetbrains-pycharm"
            ;;
        webstorm)
            category="Development;IDE;WebDevelopment;"
            comment="JavaScript IDE"
            wmclass="jetbrains-webstorm"
            ;;
        clion)
            category="Development;IDE;"
            comment="C and C++ IDE"
            wmclass="jetbrains-clion"
            ;;
        datagrip)
            category="Development;IDE;Database;"
            comment="Database IDE"
            wmclass="jetbrains-datagrip"
            ;;
        intellijidea)
            category="Development;IDE;Java;"
            comment="Java IDE"
            wmclass="jetbrains-idea"
            ;;
    esac

    # Create desktop entry
    cat << EOF | sudo tee "$desktop_file" > /dev/null
[Desktop Entry]
Version=1.0
Type=Application
Name=$ide_name
Icon=$icon_path
Exec="$exe_path" %f
Comment=$comment
Categories=$category
Terminal=false
StartupWMClass=$wmclass
StartupNotify=true
EOF

    sudo chmod +x "$desktop_file"
    sudo desktop-file-install "$desktop_file" 2>/dev/null || true

    success_msg "Desktop entry created for $ide_name"
}

# Individual IDE installers
install_pycharm() {
    install_jetbrains_ide "PyCharm" "pycharm-*.tar.gz"
}

install_webstorm() {
    install_jetbrains_ide "WebStorm" "WebStorm-*.tar.gz"
}

install_clion() {
    install_jetbrains_ide "CLion" "CLion-*.tar.gz"
}

install_datagrip() {
    install_jetbrains_ide "DataGrip" "datagrip-*.tar.gz"
}

install_intellijidea() {
    install_jetbrains_ide "IntelliJIDEA" "ideaI*. tar.gz"
}

install_all_jetbrains() {
    info_msg "Installing all JetBrains IDEs..."
    echo ""

    install_pycharm
    echo ""
    install_webstorm
    echo ""
    install_clion
    echo ""
    install_datagrip
    echo ""
    install_intellijidea

    success_msg "JetBrains IDEs installation complete!"
}


# ============================================================================
# SHELL AND CUSTOMIZATION
# ============================================================================

install_fish() {
    info_msg "Installing Fish shell..."

    sudo DEBIAN_FRONTEND=noninteractive apt update
    sudo DEBIAN_FRONTEND=noninteractive apt install -y fish || error_exit "Failed to install Fish"

    if !  grep -q "/usr/bin/fish" /etc/shells; then
        echo "/usr/bin/fish" | sudo tee -a /etc/shells
    fi

    mkdir -p "$HOME/.config/fish"

    local fish_config="$HOME/.config/fish/config.fish"
    if [ !  -f "$fish_config" ]; then
        echo "# Fish Shell Configuration" > "$fish_config"
        echo "set -g fish_greeting ''" >> "$fish_config"
    fi

    success_msg "Fish shell installed"

    # Auto-set Fish as default if configured
    if [ "$AUTO_SET_FISH_DEFAULT" = true ]; then
        sudo chsh -s /usr/bin/fish "$USER" || warning_msg "Failed to change default shell"
        success_msg "Default shell changed to Fish"
    fi
}

setup_aliases() {
    info_msg "Setting up shell aliases..."

    local bash_aliases="$HOME/.bash_aliases"

    cat > "$bash_aliases" << 'EOFALIASES'
# ============================================
# Development Environment Aliases
# ============================================

# System aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'
alias h='history'
alias grep='grep --color=auto'
alias update='sudo apt update && sudo apt upgrade -y'

# Git aliases
alias g='git'
alias gi='git init'
alias ga='git add'
alias gaa='git add .'
alias gs='git status'
alias gc='git commit -m'
alias gca='git commit -am'
alias gco='git checkout'
alias gb='git branch'
alias gpl='git pull'
alias gps='git push'
alias gcl='git clone'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gr='git remote -v'

# Node.js / NPM aliases
alias npi='npm install'
alias npd='npm run dev'
alias nps='npm start'
alias npb='npm run build'
alias npt='npm test'
alias nprm='npm remove'
alias npls='npm list --depth=0'

# PNPM aliases
alias pni='pnpm install'
alias pnd='pnpm run dev'
alias pns='pnpm start'
alias pnb='pnpm run build'
alias pnt='pnpm test'
alias pnrm='pnpm remove'
alias pnls='pnpm list --depth=0'

# Yarn aliases
alias y='yarn'
alias ya='yarn add'
alias yd='yarn dev'
alias ys='yarn start'
alias yb='yarn build'
alias yt='yarn test'
alias yrm='yarn remove'
alias yl='yarn list --depth=0'

# Python aliases
alias py='python3'
alias python='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'

# Django aliases
alias dj='python3 manage.py'
alias djs='dj runserver'
alias djmm='dj makemigrations'
alias djm='dj migrate'
alias djsh='dj shell'
alias djt='dj test'
alias djsu='dj createsuperuser'

# Docker aliases
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dcb='docker-compose build'

# Database aliases
alias pgstart='sudo systemctl start postgresql'
alias pgstop='sudo systemctl stop postgresql'
alias pgrestart='sudo systemctl restart postgresql'
alias mongostart='sudo systemctl start mongod'
alias mongostop='sudo systemctl stop mongod'
alias mongorestart='sudo systemctl restart mongod'

EOFALIASES

    if !  grep -q ". bash_aliases" "$HOME/. bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Source aliases" >> "$HOME/.bashrc"
        echo "if [ -f ~/. bash_aliases ]; then" >> "$HOME/.bashrc"
        echo "    .  ~/.bash_aliases" >> "$HOME/.bashrc"
        echo "fi" >> "$HOME/.bashrc"
    fi

    success_msg "Bash aliases configured"

    local fish_config="$HOME/.config/fish/config.fish"
    mkdir -p "$HOME/.config/fish"

    cat >> "$fish_config" << 'EOFFISHALIASES'

# ============================================
# Development Environment Aliases
# ============================================

# System aliases
function ll; ls -la $argv; end
function la; ls -A $argv; end
function l; ls -CF $argv; end
function cls; clear; end
function h; history; end
function update; sudo apt update && sudo apt upgrade -y; end

# Git aliases
function g; git $argv; end
function gi; git init $argv; end
function ga; git add $argv; end
function gaa; git add .; end
function gs; git status; end
function gc; git commit -m $argv; end
function gca; git commit -am $argv; end
function gco; git checkout $argv; end
function gb; git branch $argv; end
function gpl; git pull; end
function gps; git push; end
function gcl; git clone $argv; end
function gl; git log --oneline --graph --decorate; end
function gd; git diff $argv; end
function gr; git remote -v; end

# Node.js / NPM aliases
function npi; npm install $argv; end
function npd; npm run dev $argv; end
function nps; npm start $argv; end
function npb; npm run build $argv; end
function npt; npm test $argv; end
function nprm; npm remove $argv; end
function npls; npm list --depth=0; end

# PNPM aliases
function pni; pnpm install $argv; end
function pnd; pnpm run dev $argv; end
function pns; pnpm start $argv; end
function pnb; pnpm run build $argv; end
function pnt; pnpm test $argv; end
function pnrm; pnpm remove $argv; end
function pnls; pnpm list --depth=0; end

# Yarn aliases
function y; yarn $argv; end
function ya; yarn add $argv; end
function yd; yarn dev $argv; end
function ys; yarn start $argv; end
function yb; yarn build $argv; end
function yt; yarn test $argv; end
function yrm; yarn remove $argv; end
function yl; yarn list --depth=0; end

# Python aliases
function py; python3 $argv; end
function venv; python3 -m venv $argv; end
function activate; source venv/bin/activate. fish; end

# Django aliases
function dj; python3 manage.py $argv; end
function djs; dj runserver $argv; end
function djmm; dj makemigrations $argv; end
function djm; dj migrate $argv; end
function djsh; dj shell; end
function djt; dj test $argv; end
function djsu; dj createsuperuser; end

# Docker aliases
function dps; docker ps; end
function dpsa; docker ps -a; end
function di; docker images; end
function dcu; docker-compose up $argv; end
function dcd; docker-compose down; end
function dcb; docker-compose build $argv; end

# Database aliases
function pgstart; sudo systemctl start postgresql; end
function pgstop; sudo systemctl stop postgresql; end
function pgrestart; sudo systemctl restart postgresql; end
function mongostart; sudo systemctl start mongod; end
function mongostop; sudo systemctl stop mongod; end
function mongorestart; sudo systemctl restart mongod; end

EOFFISHALIASES

    success_msg "Fish aliases configured"
    success_msg "Shell aliases setup complete!"
}

install_KDE_Rounded_Corners() {
    info_msg "Installing KDE Rounded Corners..."

    sudo DEBIAN_FRONTEND=noninteractive apt update
    sudo DEBIAN_FRONTEND=noninteractive apt install -y git cmake g++ extra-cmake-modules kwin-dev \
        qt6-base-private-dev qt6-base-dev-tools libkf6kcmutils-dev \
        || error_exit "Failed to install dependencies"

    local tweaks_dir="$HOME/.config/tweaks"
    mkdir -p "$tweaks_dir"
    cd "$tweaks_dir" || return 1

    if [ -d "KDE-Rounded-Corners" ]; then
        warning_msg "KDE Rounded Corners already cloned, updating..."
        cd KDE-Rounded-Corners
        git pull
    else
        git clone https://github.com/matinlotfali/KDE-Rounded-Corners || error_exit "Failed to clone repository"
        cd KDE-Rounded-Corners
    fi

    mkdir -p build
    cd build
    cmake .. || error_exit "CMake configuration failed"
    cmake --build . -j || error_exit "Build failed"
    sudo make install || error_exit "Installation failed"

    cd .. 
    sh ./tools/load. sh || warning_msg "Failed to load effect automatically"

    success_msg "KDE Rounded Corners installed"
}

# ============================================================================
# BATCH INSTALLATION
# ============================================================================

install_all() {
    echo ""
    echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║     AUTOMATED INSTALLATION - NO INTERACTION NEEDED    ║${NC}"
    echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    info_msg "Starting full automated installation..."
    info_msg "This will take 30-60 minutes depending on your system"
    echo ""

    install_mount_drive_set_time
    install_dependencies
    install_grub
    install_git
    install_nvm_node
    install_pnpm
    install_python
    install_mongodb
    install_postgresql
    install_mysql
    install_chrome
    install_firefox
    install_postman
    install_vscode
    install_zoom
    install_all_jetbrains
    install_fish
    setup_aliases
    install_KDE_Rounded_Corners

    echo ""
    echo -e "${BOLD}${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║         ✓ ALL INSTALLATIONS COMPLETED!                  ║${NC}"
    echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    success_msg "All installations completed successfully!"
    info_msg "Log file:  $LOG_FILE"
    warning_msg "Please restart your system for all changes to take effect"
    echo ""
}

# ============================================================================
# UNINSTALL FUNCTIONS (AUTOMATED)
# ============================================================================

uninstall_git() {
    info_msg "Uninstalling Git..."

    sudo apt remove --purge -y git 2>/dev/null || true
    sudo add-apt-repository --remove -y ppa:git-core/ppa 2>/dev/null || true
    sudo apt autoremove -y

    if [ "$AUTO_REMOVE_CONFIGS" = true ]; then
        rm -rf "$HOME/.gitconfig"
        rm -rf "$HOME/.git-credentials"
        rm -rf "$HOME/.gitignore_global"
        success_msg "Git configuration removed"
    fi

    success_msg "Git uninstalled"
}

uninstall_nvm_node() {
    info_msg "Uninstalling NVM and Node.js..."

    rm -rf "$HOME/.nvm"
    rm -rf "$HOME/. npm"
    rm -rf "$HOME/.node-gyp"
    rm -rf "$HOME/.node_repl_history"

    sed -i '/NVM setup/,/^$/d' "$HOME/. bashrc" 2>/dev/null
    sed -i '/NVM setup/,/^$/d' "$HOME/.config/fish/config.fish" 2>/dev/null

    success_msg "NVM and Node.js uninstalled"
}

uninstall_pnpm() {
    info_msg "Uninstalling PNPM..."

    if command -v pnpm &> /dev/null; then
        npm uninstall -g pnpm 2>/dev/null || true
    fi

    rm -rf "$HOME/.local/share/pnpm"
    rm -rf "$HOME/.pnpm-state"
    rm -rf "$HOME/.pnpm-debug.log"
    rm -rf "$NTFS_MOUNT/. pnpm-store"

    sed -i '/PNPM setup/,/^$/d' "$HOME/.bashrc" 2>/dev/null
    sed -i '/PNPM setup/,/^$/d' "$HOME/. config/fish/config.fish" 2>/dev/null

    success_msg "PNPM uninstalled"
}

uninstall_python() {
    info_msg "Uninstalling Python..."

    # Find installed Python versions
    local py_versions=$(ls /usr/local/bin/python3. * 2>/dev/null | grep -oP 'python\K[0-9]+\.[0-9]+' | sort -u)

    if [ -z "$py_versions" ]; then
        warning_msg "No custom Python installations found"
        return 0
    fi

    for py_version in $py_versions; do
        info_msg "Removing Python $py_version..."
        sudo rm -f "/usr/local/bin/python${py_version}"
        sudo rm -f "/usr/local/bin/pip${py_version}"
        sudo rm -rf "/usr/local/lib/python${py_version}"
        sudo rm -rf "/opt/Python-${py_version}"*

        sed -i "/Python ${py_version} aliases/,/^$/d" "$HOME/. bashrc" 2>/dev/null
        sed -i "/Python ${py_version} aliases/,/^$/d" "$HOME/. config/fish/config.fish" 2>/dev/null
    done

    success_msg "Python uninstalled"
}

uninstall_mongodb() {
    info_msg "Uninstalling MongoDB..."

    sudo systemctl stop mongod 2>/dev/null || true
    sudo systemctl disable mongod 2>/dev/null || true

    sudo apt remove --purge -y mongodb-org mongodb-org-server mongodb-mongosh mongodb-compass 2>/dev/null || true
    sudo rm -rf /var/log/mongodb
    sudo rm -rf /var/lib/mongodb
    sudo rm -f /etc/apt/sources.list.d/mongodb*. list

    sudo apt autoremove -y

    if [ "$AUTO_REMOVE_CONFIGS" = true ]; then
        rm -rf "$HOME/.mongodb"
        rm -rf "$HOME/.mongorc.js"
        rm -rf "$HOME/.dbshell"
        rm -rf "$HOME/.config/mongodb"
        success_msg "MongoDB configuration removed"
    fi

    success_msg "MongoDB uninstalled"
}

uninstall_postgresql() {
    info_msg "Uninstalling PostgreSQL and pgAdmin..."

    sudo systemctl stop postgresql 2>/dev/null || true

    sudo apt remove --purge -y postgresql* pgadmin4* 2>/dev/null || true
    sudo rm -rf /var/lib/postgresql
    sudo rm -rf /etc/postgresql
    sudo rm -f /etc/apt/sources.list.d/pgadmin4.list
    sudo rm -f /etc/apt/sources.list.d/pgdg.list
    sudo rm -f /usr/share/keyrings/packages-pgadmin-org.gpg

    sudo apt autoremove -y

    if [ "$AUTO_REMOVE_CONFIGS" = true ]; then
        rm -rf "$HOME/.pgadmin"
        rm -rf "$HOME/.postgresql"
        rm -rf "$HOME/.psql_history"
        rm -rf "$HOME/.config/pgadmin"
        success_msg "PostgreSQL/pgAdmin configuration removed"
    fi

    success_msg "PostgreSQL and pgAdmin uninstalled"
}

uninstall_mysql() {
    info_msg "Uninstalling MySQL..."

    sudo systemctl stop mysql 2>/dev/null || true

    sudo apt remove --purge -y mysql-server mysql-client mysql-common mysql-workbench-community 2>/dev/null || true
    sudo rm -rf /var/lib/mysql
    sudo rm -rf /etc/mysql

    sudo apt autoremove -y

    if [ "$AUTO_REMOVE_CONFIGS" = true ]; then
        rm -rf "$HOME/.mysql"
        rm -rf "$HOME/.mysql_history"
        rm -rf "$HOME/. mysqlsh"
        rm -rf "$HOME/.mysql-workbench"
        rm -rf "$HOME/.config/mysql-workbench"
        success_msg "MySQL configuration removed"
    fi

    success_msg "MySQL uninstalled"
}

uninstall_chrome() {
    info_msg "Uninstalling Google Chrome..."

    pkill -f "chrome" 2>/dev/null || true

    sudo apt remove --purge -y google-chrome-stable 2>/dev/null || true
    sudo rm -f /etc/apt/sources.list.d/google-chrome.list

    sudo apt autoremove -y

    if [ "$AUTO_REMOVE_CONFIGS" = true ]; then
        rm -rf "$HOME/.config/google-chrome"
        rm -rf "$HOME/.cache/google-chrome"
        rm -rf "$HOME/.local/share/applications/chrome-*. desktop"
        success_msg "Chrome configuration removed"
    fi

    success_msg "Google Chrome uninstalled"
}

uninstall_firefox() {
    info_msg "Uninstalling Firefox..."

    pkill -f "firefox" 2>/dev/null || true

    if [ -d "/opt/firefox" ]; then
        sudo rm -rf /opt/firefox
        sudo rm -f /usr/bin/firefox
        sudo rm -f /usr/share/applications/firefox.desktop
    else
        sudo apt remove --purge -y firefox 2>/dev/null || true
    fi

    sudo apt autoremove -y

    if [ "$AUTO_REMOVE_CONFIGS" = true ]; then
        rm -rf "$HOME/.mozilla"
        rm -rf "$HOME/.cache/mozilla"
        rm -rf "$HOME/.local/share/applications/firefox-*.desktop"
        success_msg "Firefox configuration removed"
    fi

    success_msg "Firefox uninstalled"
}

uninstall_postman() {
    info_msg "Uninstalling Postman..."

    pkill -f "Postman" 2>/dev/null || true

    sudo rm -rf /opt/Postman
    sudo rm -f /usr/bin/postman
    sudo rm -f /usr/share/applications/postman.desktop

    if [ "$AUTO_REMOVE_CONFIGS" = true ]; then
        rm -rf "$HOME/.config/Postman"
        rm -rf "$HOME/.config/PostmanCanary"
        rm -rf "$HOME/Postman"
        rm -rf "$HOME/.local/share/Postman"
        success_msg "Postman configuration removed"
    fi

    success_msg "Postman uninstalled"
}

uninstall_vscode() {
    info_msg "Uninstalling Visual Studio Code..."

    pkill -f "code" 2>/dev/null || true

    sudo apt remove --purge -y code 2>/dev/null || true
    sudo rm -f /etc/apt/sources.list. d/vscode.list
    sudo rm -f /etc/apt/keyrings/packages. microsoft.gpg

    sudo apt autoremove -y

    if [ "$AUTO_REMOVE_CONFIGS" = true ]; then
        rm -rf "$HOME/.config/Code"
        rm -rf "$HOME/.vscode"
        rm -rf "$HOME/.vscode-oss"
        rm -rf "$HOME/.local/share/applications/code*. desktop"
        success_msg "VS Code data removed"
    fi

    success_msg "Visual Studio Code uninstalled"
}

uninstall_zoom() {
    info_msg "Uninstalling Zoom..."

    pkill -f "zoom" 2>/dev/null || true

    sudo apt remove --purge -y zoom 2>/dev/null || true
    sudo apt autoremove -y

    if [ "$AUTO_REMOVE_CONFIGS" = true ]; then
        rm -rf "$HOME/.zoom"
        rm -rf "$HOME/.config/zoomus. conf"
        rm -rf "$HOME/.cache/zoom"
        rm -rf "$HOME/.local/share/zoom"
        success_msg "Zoom configuration removed"
    fi

    success_msg "Zoom uninstalled"
}

uninstall_jetbrains_ide() {
    local ide_name="$1"
    local install_dir="/opt/$ide_name"

    info_msg "Uninstalling $ide_name..."

    # Kill IDE processes
    pkill -f "$ide_name" 2>/dev/null || true
    pkill -f "${ide_name,,}" 2>/dev/null || true

    # Remove installation directory
    if [ -d "$install_dir" ]; then
        sudo rm -rf "$install_dir"
        success_msg "Removed installation directory"
    fi

    # Remove symlinks (try multiple possible names)
    sudo rm -f "/usr/local/bin/${ide_name,,}" 2>/dev/null
    sudo rm -f "/usr/bin/${ide_name,,}" 2>/dev/null

    # Special cases for symlink names
    case "${ide_name,,}" in
        pycharm)
            sudo rm -f "/usr/local/bin/pycharm" 2>/dev/null
            ;;
        webstorm)
            sudo rm -f "/usr/local/bin/webstorm" 2>/dev/null
            ;;
        clion)
            sudo rm -f "/usr/local/bin/clion" 2>/dev/null
            ;;
        datagrip)
            sudo rm -f "/usr/local/bin/datagrip" 2>/dev/null
            ;;
        intellijidea)
            sudo rm -f "/usr/local/bin/idea" 2>/dev/null
            sudo rm -f "/usr/local/bin/intellij" 2>/dev/null
            ;;
    esac

    # Remove desktop entries
    sudo rm -f "/usr/share/applications/${ide_name,,}.desktop" 2>/dev/null

    # Also check for desktop entries in user directory
    rm -f "$HOME/.local/share/applications/${ide_name,,}.desktop" 2>/dev/null

    # Remove desktop file cache entry
    if command -v update-desktop-database &> /dev/null; then
        sudo update-desktop-database /usr/share/applications 2>/dev/null || true
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    fi

    # Remove . desktop files that might have been auto-created
    find "$HOME/. local/share/applications" -iname "*${ide_name,,}*. desktop" -delete 2>/dev/null || true

    # Clear icon cache
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
        sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor 2>/dev/null || true
    fi

    # KDE-specific:  clear kservice cache
    if command -v kbuildsycoca5 &> /dev/null; then
        kbuildsycoca5 --noincremental 2>/dev/null || true
    fi
    if command -v kbuildsycoca6 &> /dev/null; then
        kbuildsycoca6 --noincremental 2>/dev/null || true
    fi

    success_msg "Removed desktop entries and icons"

    # Remove user configuration
    read -p "Remove $ide_name user configuration and settings? (y/n): " remove_config
    if [[ "$remove_config" =~ ^[Yy]$ ]]; then
        rm -rf "$HOME/.${ide_name}"* 2>/dev/null
        rm -rf "$HOME/.config/JetBrains/${ide_name}"* 2>/dev/null
        rm -rf "$HOME/.cache/JetBrains/${ide_name}"* 2>/dev/null
        rm -rf "$HOME/.local/share/JetBrains/${ide_name}"* 2>/dev/null
        rm -rf "$HOME/.java/. userPrefs/jetbrains/${ide_name,,}"* 2>/dev/null

        # Remove recent files entries
        rm -rf "$HOME/.local/share/RecentDocuments/${ide_name,,}"* 2>/dev/null

        success_msg "$ide_name configuration removed"
    fi

    success_msg "$ide_name uninstalled successfully"
    info_msg "You may need to restart your desktop session to refresh the menu"
}
uninstall_pycharm() {
    uninstall_jetbrains_ide "PyCharm"
}

uninstall_webstorm() {
    uninstall_jetbrains_ide "WebStorm"
}

uninstall_clion() {
    uninstall_jetbrains_ide "CLion"
}



uninstall_datagrip() {
    uninstall_jetbrains_ide "DataGrip"
}

uninstall_intellijidea() {
    uninstall_jetbrains_ide "IntelliJIDEA"
}

uninstall_all_jetbrains() {
    info_msg "Uninstalling all JetBrains IDEs..."
    echo ""

    uninstall_pycharm
    echo ""
    uninstall_webstorm
    echo ""
    uninstall_clion
    echo ""
    uninstall_datagrip
    echo ""
    uninstall_intellijidea
    # Refresh desktop to remove icons
    echo ""
    refresh_desktop
    success_msg "All JetBrains IDEs uninstalled!"
}

uninstall_fish() {
    info_msg "Uninstalling Fish shell..."

    if [ "$SHELL" = "/usr/bin/fish" ]; then
        sudo chsh -s /bin/bash "$USER"
        success_msg "Default shell changed back to Bash"
    fi

    sudo apt remove --purge -y fish 2>/dev/null || true
    sudo apt autoremove -y

    if [ "$AUTO_REMOVE_CONFIGS" = true ]; then
        rm -rf "$HOME/.config/fish"
        rm -rf "$HOME/.local/share/fish"
        success_msg "Fish configuration removed"
    fi

    success_msg "Fish shell uninstalled"
}

uninstall_kde_rounded_corners() {
    info_msg "Uninstalling KDE Rounded Corners..."

    local tweaks_dir="$HOME/.config/tweaks/KDE-Rounded-Corners"

    if [ -d "$tweaks_dir" ]; then
        if [ -d "$tweaks_dir/build" ]; then
            cd "$tweaks_dir/build"
            sudo make uninstall 2>/dev/null || warning_msg "Failed to uninstall via make"
            cd - > /dev/null
        fi
        rm -rf "$HOME/.config/tweaks/KDE-Rounded-Corners"
    fi

    success_msg "KDE Rounded Corners uninstalled"
}

remove_grub_theme() {
    info_msg "Removing Grub theme..."

    sudo cp /etc/default/grub /etc/default/grub.backup 2>/dev/null || true

    sudo rm -rf /boot/grub/themes/Elegant* 2>/dev/null || true
    sudo rm -rf /boot/grub/themes/* 2>/dev/null || true

    if [ -f /etc/default/grub ]; then
        info_msg "Removing GRUB theme configuration..."
        sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub
        sudo sed -i '/^GRUB_GFXMODE=/d' /etc/default/grub
        sudo sed -i '/^GRUB_GFXPAYLOAD_LINUX=/d' /etc/default/grub
    fi

    info_msg "Updating GRUB configuration..."
    if command -v update-grub &> /dev/null; then
        sudo update-grub 2>&1 || warning_msg "update-grub had issues but continuing..."
    elif command -v grub-mkconfig &> /dev/null; then
        sudo grub-mkconfig -o /boot/grub/grub.cfg 2>&1 || warning_msg "grub-mkconfig had issues but continuing..."
    elif command -v grub2-mkconfig &> /dev/null; then
        sudo grub2-mkconfig -o /boot/grub2/grub.cfg 2>&1 || warning_msg "grub2-mkconfig had issues but continuing..."
    else
        warning_msg "Could not find grub update command"
    fi

    success_msg "Grub theme removed"
}

uninstall_all() {
    echo ""
    warning_msg "${BOLD}═══════════════════════════════════════════${NC}"
    warning_msg "${BOLD}        AUTOMATED COMPLETE UNINSTALL       ${NC}"
    warning_msg "${BOLD}═══════════════════════════════════════════${NC}"
    echo ""
    info_msg "Starting complete automated uninstallation..."
    echo ""

    uninstall_kde_rounded_corners
    uninstall_all_jetbrains
    uninstall_zoom
    uninstall_vscode
    uninstall_postman
    uninstall_firefox
    uninstall_chrome
    uninstall_mysql
    uninstall_postgresql
    uninstall_mongodb
    uninstall_python
    uninstall_pnpm
    uninstall_nvm_node
    uninstall_git
    uninstall_fish
    remove_grub_theme

    success_msg "All applications uninstalled!"
    warning_msg "Please restart your system for all changes to take effect"
}

# ============================================================================
# MENU FUNCTIONS
# ============================================================================

show_menu() {
    clear
    local border="═══════════════════════════════════════════════════════"
    echo -e "${BOLD}${GREEN}$border${NC}"
    echo -e "${BOLD}${CYAN}      Kubuntu Development Environment Setup v3.0${NC}"
    echo -e "${BOLD}${GREEN}$border${NC}"
    echo ""
    echo -e "${BOLD}${BLUE}System Setup: ${NC}"
    echo -e "  ${CYAN}0)${NC}  Set Time & Mount Data Drive"
    echo -e "  ${CYAN}1)${NC}  Install System Dependencies"
    echo -e "  ${CYAN}2)${NC}  Install Grub Theme"
    echo ""
    echo -e "${BOLD}${BLUE}Development Tools:${NC}"
    echo -e "  ${CYAN}3)${NC}  Install Git (Latest via PPA)"
    echo -e "  ${CYAN}4)${NC}  Install NVM and Node. js LTS"
    echo -e "  ${CYAN}5)${NC}  Install PNPM"
    echo -e "  ${CYAN}6)${NC}  Install Python (from source)"
    echo ""
    echo -e "${BOLD}${BLUE}Databases:${NC}"
    echo -e "  ${CYAN}7)${NC}  Install MongoDB (Server + Shell + Compass)"
    echo -e "  ${CYAN}8)${NC}  Install PostgreSQL & pgAdmin"
    echo -e "  ${CYAN}9)${NC}  Install MySQL & Workbench"
    echo ""
    echo -e "${BOLD}${BLUE}Applications:${NC}"
    echo -e "  ${CYAN}10)${NC} Install Google Chrome"
    echo -e "  ${CYAN}11)${NC} Install Mozilla Firefox"
    echo -e "  ${CYAN}12)${NC} Install Postman"
    echo -e "  ${CYAN}13)${NC} Install Visual Studio Code"
    echo -e "  ${CYAN}14)${NC} Install Zoom"
    echo ""
    echo -e "${BOLD}${BLUE}JetBrains IDEs:${NC}"
    echo -e "  ${CYAN}15)${NC} Install PyCharm"
    echo -e "  ${CYAN}16)${NC} Install WebStorm"
    echo -e "  ${CYAN}17)${NC} Install CLion"
    echo -e "  ${CYAN}18)${NC} Install DataGrip"
    echo -e "  ${CYAN}19)${NC} Install IntelliJ IDEA"
    echo -e "  ${CYAN}20)${NC} Install All JetBrains IDEs"
    echo ""
    echo -e "${BOLD}${BLUE}Shell & Customization:${NC}"
    echo -e "  ${CYAN}21)${NC} Install Fish Shell (set as default)"
    echo -e "  ${CYAN}22)${NC} Setup Shell Aliases (Bash & Fish)"
    echo -e "  ${CYAN}23)${NC} Install KDE Rounded Corners"
    echo ""
    echo -e "${BOLD}${BLUE}Batch Operations:${NC}"
    echo -e "  ${CYAN}24)${NC} ${GREEN}Install All (Automated)${NC}"
    echo -e "  ${CYAN}25)${NC} ${YELLOW}Uninstall Menu${NC}"
    echo ""
    echo -e "  ${CYAN}26)${NC} ${RED}Exit${NC}"
    echo -e "${BOLD}${GREEN}$border${NC}"
    echo -e "${YELLOW}Log file: ${LOG_FILE}${NC}"
    echo ""
    read -p "Enter your choice [0-26]: " choice
}

show_uninstall_menu() {
    clear
    local border="═══════════════════════════════════════════════════════"
    echo -e "${BOLD}${RED}$border${NC}"
    echo -e "${BOLD}${YELLOW}              Uninstall Menu${NC}"
    echo -e "${BOLD}${RED}$border${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC}   Uninstall Git"
    echo -e "  ${CYAN}2)${NC}   Uninstall NVM and Node.js"
    echo -e "  ${CYAN}3)${NC}   Uninstall PNPM"
    echo -e "  ${CYAN}4)${NC}   Uninstall Python"
    echo -e "  ${CYAN}5)${NC}   Uninstall MongoDB"
    echo -e "  ${CYAN}6)${NC}   Uninstall PostgreSQL & pgAdmin"
    echo -e "  ${CYAN}7)${NC}   Uninstall MySQL & Workbench"
    echo -e "  ${CYAN}8)${NC}   Uninstall Google Chrome"
    echo -e "  ${CYAN}9)${NC}   Uninstall Mozilla Firefox"
    echo -e "  ${CYAN}10)${NC}  Uninstall Postman"
    echo -e "  ${CYAN}11)${NC}  Uninstall Visual Studio Code"
    echo -e "  ${CYAN}12)${NC}  Uninstall Zoom"
    echo -e "  ${CYAN}13)${NC}  Uninstall PyCharm"
    echo -e "  ${CYAN}14)${NC}  Uninstall WebStorm"
    echo -e "  ${CYAN}15)${NC} Uninstall CLion"
    echo -e "  ${CYAN}16)${NC} Uninstall DataGrip"
    echo -e "  ${CYAN}17)${NC} Uninstall IntelliJ IDEA"
    echo -e "  ${CYAN}18)${NC} Uninstall All JetBrains IDEs"
    echo -e "  ${CYAN}19)${NC} Uninstall Fish Shell"
    echo -e "  ${CYAN}20)${NC} Uninstall KDE Rounded Corners"
    echo -e "  ${CYAN}21)${NC} Remove Grub Theme"
    echo ""
    echo -e "  ${CYAN}22)${NC}  ${RED}${BOLD}Uninstall All (Automated)${NC}"
    echo -e "  ${CYAN}0)${NC}   Back to Main Menu"
    echo -e "  ${BOLD}${RED}$border${NC}"
    echo ""
    read -p "Enter your choice [0-22]: " uninstall_choice
}
refresh_desktop() {
    info_msg "Refreshing desktop database..."

    # Update desktop database
    if command -v update-desktop-database &> /dev/null; then
        sudo update-desktop-database /usr/share/applications 2>/dev/null || true
        update-desktop-database "$HOME/. local/share/applications" 2>/dev/null || true
    fi

    # Update MIME database
    if command -v update-mime-database &> /dev/null; then
        sudo update-mime-database /usr/share/mime 2>/dev/null || true
        update-mime-database "$HOME/.local/share/mime" 2>/dev/null || true
    fi

    # Clear icon cache
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
        sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor 2>/dev/null || true
    fi

    # KDE-specific
    if command -v kbuildsycoca5 &> /dev/null; then
        kbuildsycoca5 --noincremental 2>/dev/null || true
    fi
    if command -v kbuildsycoca6 &> /dev/null; then
        kbuildsycoca6 --noincremental 2>/dev/null || true
    fi

    success_msg "Desktop refreshed"
}
# ============================================================================
# MAIN PROGRAM
# ============================================================================

main_interactive() {
    check_sudo

    touch "$LOG_FILE"

    echo -e "${BOLD}${CYAN}"
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║  Kubuntu Development Environment Setup Script v3.0   ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    info_msg "Log file: $LOG_FILE"
    echo ""

    while true; do
        show_menu

        case $choice in
            0) install_mount_drive_set_time ;;
            1) install_dependencies ;;
            2) install_grub ;;
            3) install_git ;;
            4) install_nvm_node ;;
            5) install_pnpm ;;
            6) install_python ;;
            7) install_mongodb ;;
            8) install_postgresql ;;
            9) install_mysql ;;
            10) install_chrome ;;
            11) install_firefox ;;
            12) install_postman ;;
            13) install_vscode ;;
            14) install_zoom ;;
            15) install_pycharm ;;
            16) install_webstorm ;;
            17) install_clion ;;
            18) install_datagrip ;;
            19) install_intellijidea ;;
            20) install_all_jetbrains ;;
            21) install_fish ;;
            22) setup_aliases ;;
            23) install_KDE_Rounded_Corners ;;
            24) install_all ;;
            25)
                while true; do
                    show_uninstall_menu
                    case $uninstall_choice in
                        1) uninstall_git ;;
                        2) uninstall_nvm_node ;;
                        3) uninstall_pnpm ;;
                        4) uninstall_python ;;
                        5) uninstall_mongodb ;;
                        6) uninstall_postgresql ;;
                        7) uninstall_mysql ;;
                        8) uninstall_chrome ;;
                        9) uninstall_firefox ;;
                        10) uninstall_postman ;;
                        11) uninstall_vscode ;;
                        12) uninstall_zoom ;;
                        13) uninstall_pycharm ;;
                        14) uninstall_webstorm ;;
                        15) uninstall_clion ;;
                        16) uninstall_datagrip ;;
                        17) uninstall_intellijidea ;;
                        18) uninstall_all_jetbrains ;;
                        19) uninstall_fish ;;
                        20) uninstall_kde_rounded_corners ;;
                        21) remove_grub_theme ;;
                        22) uninstall_all ;;
                        0) break ;;
                        *) warning_msg "Invalid choice" ;;
                    esac
                    press_enter
                done
                ;;
            26)
                echo -e "${GREEN}Thank you for using this script!${NC}"
                echo -e "${CYAN}Log file saved at: $LOG_FILE${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice.  Please enter a number between 0-26.${NC}"
                sleep 2
                ;;
        esac

        press_enter
    done
}

main_automated() {
    check_sudo

    touch "$LOG_FILE"

    echo -e "${BOLD}${CYAN}"
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║  Kubuntu Dev Environment Setup - FULLY AUTOMATED     ║"
    echo "║                  Version 3.0 AUTO                     ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    info_msg "Starting automated installation in 5 seconds..."
    info_msg "Press Ctrl+C to cancel"
    echo ""
    sleep 5

    install_all
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================

# Check for --auto flag for fully automated installation
if [[ "$1" == "--auto" ]] || [[ "$1" == "-a" ]]; then
    main_automated
else
    main_interactive
fi
