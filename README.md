# Kubuntu Development Environment Setup Script

**Version:** 3.0  
**License:** MIT  
**Platform:** Kubuntu/Ubuntu-based distributions  
**Author:** RafiurRahmanSaikat

A comprehensive, automated bash script for setting up a complete development environment on Kubuntu with interactive menus and fully automated installation options.

---

## 🚀 Features

### Development Tools
- **Git** - Latest version via PPA
- **Node.js & npm** - Installed via NVM (Node Version Manager)
- **PNPM** - Fast, disk space efficient package manager
- **Python** - Built from source with custom version support

### Databases
- **MongoDB** - Server, Shell (mongosh), and Compass GUI
- **PostgreSQL** - With pgAdmin (Desktop/Web/Both)
- **MySQL** - Server and Workbench

### Applications
- **Google Chrome** - Latest stable version
- **Mozilla Firefox** - From archive or repository
- **Visual Studio Code** - Microsoft's code editor
- **Postman** - API development platform
- **Zoom** - Video conferencing

### JetBrains IDEs
- **PyCharm** - Python IDE
- **WebStorm** - JavaScript/TypeScript IDE
- **CLion** - C/C++ IDE
- **DataGrip** - Database IDE
- **IntelliJ IDEA** - Java IDE
- Uses native launchers for optimal performance

### Shell & Customization
- **Fish Shell** - User-friendly interactive shell
- **Comprehensive Aliases** - For Git, Node.js, Python, Django, Docker, databases
- **KDE Rounded Corners** - Visual enhancement for KDE Plasma
- **Custom Grub Theme** - Elegant boot screen

### System Configuration
- NTFS drive auto-mounting (configurable UUID)
- RTC time synchronization
- Application directory structure (`/Data/Software/Linux/`)

---

## 📋 Prerequisites

- Kubuntu/Ubuntu-based Linux distribution
- `sudo` privileges
- Internet connection for downloads
- At least 10GB free disk space
- Recommended: 8GB RAM or more

---

## 🔧 Installation

### Download the Script

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/kubuntu-dev-setup.git
cd kubuntu-dev-setup

# Or download directly
wget https://raw.githubusercontent.com/YOUR_USERNAME/kubuntu-dev-setup/main/setup_kubuntu_dev.sh

# Make it executable
chmod +x setup_kubuntu_dev. sh
```

---

## 📖 Usage

### Interactive Mode

```bash
./setup_kubuntu_dev.sh
```

**Features:**
- Navigate through a color-coded menu with 26+ options
- Install individual components
- Batch install all tools
- Uninstall with config cleanup
- Customize your setup

**Menu Structure:**
```
═══════════════════════════════════════════════════════
      Kubuntu Development Environment Setup v3.0
═══════════════════════════════════════════════════════

System Setup: 
  0)  Set Time & Mount Data Drive
  1)  Install System Dependencies
  2)  Install Grub Theme

Development Tools:
  3)  Install Git (Latest via PPA)
  4)  Install NVM and Node.js LTS
  5)  Install PNPM
  6)  Install Python (from source)

Databases:
  7)  Install MongoDB (Server + Shell + Compass)
  8)  Install PostgreSQL & pgAdmin
  9)  Install MySQL & Workbench

Applications:
  10) Install Google Chrome
  11) Install Mozilla Firefox
  12) Install Postman
  13) Install Visual Studio Code
  14) Install Zoom

JetBrains IDEs:
  15) Install PyCharm
  16) Install WebStorm
  17) Install CLion
  18) Install DataGrip
  19) Install IntelliJ IDEA
  20) Install All JetBrains IDEs

Shell & Customization:
  21) Install Fish Shell (set as default)
  22) Setup Shell Aliases (Bash & Fish)
  23) Install KDE Rounded Corners

Batch Operations:
  24) Install All (Automated)
  25) Uninstall Menu

  26) Exit
```

### Automated Mode

```bash
./setup_kubuntu_dev.sh --auto
```

**Features:**
- Installs everything automatically with sensible defaults
- No user interaction required
- Perfect for fresh installations
- Takes 30-60 minutes depending on system
- Logs all operations for review

---

## ⚙️ Configuration

Edit these variables at the top of the script to customize: 

```bash
# Application directory (where installers are stored)
readonly APP_DIR="/Data/Software/Linux/Applications"

# Backup directory
readonly BACKUP_DIR="/Data/Software/Linux/Backups"

# NTFS drive UUID (update with your drive's UUID)
readonly NTFS_UUID="746AACA86AAC6896"

# NTFS mount point
readonly NTFS_MOUNT="/Data"

# Auto-configuration settings
readonly AUTO_REMOVE_CONFIGS=true          # Remove configs on uninstall
readonly AUTO_INSTALL_PGADMIN_MODE=3       # 1=Desktop, 2=Web, 3=Both
readonly AUTO_POSTGRESQL_REMOTE=true       # Enable PostgreSQL remote access
readonly AUTO_SET_FISH_DEFAULT=true        # Set Fish as default shell
```

### Finding Your NTFS Drive UUID

```bash
# List all drives with UUIDs
sudo blkid

# Find your NTFS drive
sudo blkid | grep ntfs
```

---

## 📦 What Gets Installed

```
┌─ System Setup
│  ├── Time Configuration (RTC)
│  ├── NTFS Drive Mounting
│  ├── Build Tools (gcc, g++, cmake, etc.)
│  ├── Development Libraries
│  └── Grub Theme (Elegant Wave)
│
├─ Development Tools
│  ├── Git (latest via PPA)
│  ├── NVM v0.40.3
│  ├── Node.js LTS (via NVM)
│  ├── npm (with Node.js)
│  ├── PNPM (global)
│  └── Python (compiled from source)
│
├─ Databases
│  ├── MongoDB
│  │   ├── Server (latest)
│  │   ├── Shell (mongosh)
│  │   └── Compass (GUI)
│  ├── PostgreSQL
│  │   ├── Server (latest)
│  │   ├── Contrib modules
│  │   └── pgAdmin4 (Desktop/Web)
│  └── MySQL
│      ├── Server
│      └── Workbench
│
├─ Applications
│  ├── Google Chrome (latest stable)
│  ├── Mozilla Firefox (latest)
│  ├── Postman (API testing)
│  ├── VS Code (Microsoft)
│  └── Zoom (video conferencing)
│
├─ JetBrains IDEs
│  ├── PyCharm (Python)
│  ├── WebStorm (JavaScript/TypeScript)
│  ├── CLion (C/C++)
│  ├── DataGrip (Database)
│  └── IntelliJ IDEA (Java)
│
└─ Customization
   ├── Fish Shell
   ├── Bash Aliases
   ├── Fish Aliases
   ├── KDE Rounded Corners
   └── Shell Configuration
```

---

## 🗑️ Uninstallation

The script includes comprehensive uninstall functions with config cleanup. 

### Uninstall Menu

```bash
./setup_kubuntu_dev.sh
# Select option 25: Uninstall Menu
```

**Features:**
- Individual component uninstall (options 1-21)
- Batch uninstall all (option 22)
- Optional configuration cleanup
- Desktop cache refresh
- Icon cleanup for KDE Plasma
- Symlink removal
- Repository cleanup

**What Gets Removed:**

| Component | Files Removed |
|-----------|---------------|
| Git | Config, credentials, repositories list |
| Node.js | NVM, npm cache, node-gyp |
| Chrome | Config, cache, bookmarks, extensions |
| VS Code | Settings, extensions, workspace data |
| JetBrains | IDE configs, plugins, recent projects |
| Fish | Shell config, history, completions |
| Databases | Service data, logs, configs |

---

## 📝 Logging

All operations are automatically logged with timestamps:

```bash
./setup_dev_env_YYYYMMDD_HHMMSS.log
```

**Log Format:**
```
[2025-01-31 14:30:15] Installing Git...
[2025-01-31 14:30:18] ✓ Git installed successfully:  git version 2.43.0
[2025-01-31 14:30:20] Installing NVM and Node.js...
```

**View logs:**
```bash
# View latest log
tail -f setup_dev_env_*. log

# Search for errors
grep -i "error\|failed" setup_dev_env_*.log
```

---

## 🎨 Shell Aliases

The script installs 60+ aliases for common development tasks:

### Git Aliases
```bash
g       # git
gi      # git init
ga      # git add
gaa     # git add . 
gs      # git status
gc      # git commit -m
gca     # git commit -am
gco     # git checkout
gb      # git branch
gpl     # git pull
gps     # git push
gcl     # git clone
gl      # git log --oneline --graph --decorate
gd      # git diff
gr      # git remote -v
```

### Node.js/npm Aliases
```bash
npi     # npm install
npd     # npm run dev
nps     # npm start
npb     # npm run build
npt     # npm test
nprm    # npm remove
npls    # npm list --depth=0
```

### PNPM Aliases
```bash
pni     # pnpm install
pnd     # pnpm run dev
pns     # pnpm start
pnb     # pnpm run build
pnt     # pnpm test
pnrm    # pnpm remove
pnls    # pnpm list --depth=0
```

### Python/Django Aliases
```bash
py      # python3
pip     # pip3
venv    # python3 -m venv
activate # source venv/bin/activate

dj      # python3 manage.py
djs     # python3 manage.py runserver
djmm    # python3 manage.py makemigrations
djm     # python3 manage.py migrate
djsh    # python3 manage.py shell
djt     # python3 manage.py test
djsu    # python3 manage.py createsuperuser
```

### Docker Aliases
```bash
dps     # docker ps
dpsa    # docker ps -a
di      # docker images
dcu     # docker-compose up
dcd     # docker-compose down
dcb     # docker-compose build
```

### Database Aliases
```bash
pgstart      # sudo systemctl start postgresql
pgstop       # sudo systemctl stop postgresql
pgrestart    # sudo systemctl restart postgresql
mongostart   # sudo systemctl start mongod
mongostop    # sudo systemctl stop mongod
mongorestart # sudo systemctl restart mongod
```

### System Aliases
```bash
ll      # ls -la
la      # ls -A
cls     # clear
h       # history
update  # sudo apt update && sudo apt upgrade -y
```

---

## 🔒 Security Notes

- ✅ Script requires `sudo` for system-level operations only
- ✅ Does NOT run as root (asks for sudo when needed)
- ✅ All downloads use official sources
- ✅ GPG verification for repository keys
- ✅ SHA256 checksums where available
- ✅ No hardcoded passwords or credentials
- ⚠️ Review script before running with sudo access
- ⚠️ Configure firewall after PostgreSQL remote access setup

---

## 🐛 Troubleshooting

### JetBrains IDE Not Found

**Problem:** PyCharm/WebStorm tarball not found

**Solution:**
```bash
# Ensure .tar.gz files are in the correct directory
ls -la /Data/Software/Linux/Applications/*. tar.gz

# Check filename format
# Expected: pycharm-2025.3.1. tar.gz (lowercase)
# Expected: WebStorm-2025.3.1.tar.gz (capital W and S)
```

### Fish Shell Aliases Not Working

**Problem:** Aliases don't work after installation

**Solution:**
```bash
# Restart terminal or source config
source ~/.config/fish/config. fish

# Or restart Fish
exec fish
```

### Permission Denied Errors

**Problem:** Script fails with permission errors

**Solution:**
```bash
# Don't run as root
# Run as regular user (script asks for sudo when needed)
./setup_kubuntu_dev.sh

# If script isn't executable
chmod +x setup_kubuntu_dev.sh
```

### NTFS Drive Not Mounting

**Problem:** Data drive doesn't mount automatically

**Solution:**
```bash
# Find your drive's UUID
sudo blkid | grep ntfs

# Update UUID in script (line ~18)
readonly NTFS_UUID="YOUR-UUID-HERE"

# Test mount manually
sudo mount -a
```

### Node.js Command Not Found

**Problem:** `node` or `nvm` not available after install

**Solution:**
```bash
# Source bashrc
source ~/.bashrc

# Or restart terminal
exec bash

# Verify NVM
nvm --version

# Verify Node
node --version
```

### PostgreSQL Remote Access Issues

**Problem:** Can't connect to PostgreSQL from remote machine

**Solution:**
```bash
# Check if PostgreSQL is listening on all interfaces
sudo netstat -tuln | grep 5432

# Edit pg_hba.conf if needed
sudo nano /etc/postgresql/*/main/pg_hba.conf

# Restart PostgreSQL
sudo systemctl restart postgresql

# Check firewall
sudo ufw status
sudo ufw allow 5432/tcp
```

---

## 🤝 Contributing

Contributions are welcome! Here's how: 

1. **Fork the repository**
   ```bash
   # Click "Fork" on GitHub
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make your changes**
   - Test thoroughly on Kubuntu
   - Follow existing code style
   - Add comments for complex logic
   - Update README if needed

4. **Commit your changes**
   ```bash
   git commit -m 'feat: Add amazing feature'
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```

6. **Open a Pull Request**
   - Describe your changes
   - Reference any related issues
   - Include screenshots if UI changes

### Development Guidelines

- Use `info_msg`, `success_msg`, `warning_msg`, `error_exit` for output
- Always check if tool is already installed before installing
- Provide fallback options when downloads fail
- Include uninstall function for any new component
- Test on fresh Kubuntu installation

---

## 📄 License

```
MIT License

Copyright (c) 2025 RafiurRahmanSaikat

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions: 

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 👤 Author

**RafiurRahmanSaikat**

- GitHub: [@RafiurRahmanSaikat](https://github.com/RafiurRahmanSaikat)
- Created for Kubuntu development environment automation

---

## 📊 Changelog

### v3.0 (2025-01-31)
- ✨ Added native launcher support for JetBrains IDEs
- 🔧 Improved file pattern matching (removed spaces in extensions)
- 🗑️ Enhanced uninstall with desktop cache refresh
- 🤖 Added automated mode with `--auto` flag
- 🧹 Comprehensive config cleanup on uninstall
- 📝 Better error handling and logging
- 🎨 Color-coded output for better UX
- ⚡ Performance optimizations

### v2.0 (2024-12-15)
- Added Fish shell support
- Comprehensive alias system
- KDE Rounded Corners integration
- Improved error handling

### v1.0 (2024-11-01)
- Initial release
- Basic installation functions
- Interactive menu system

---

## 🙏 Acknowledgments

- [NVM](https://github.com/nvm-sh/nvm) - Node Version Manager
- [Fish Shell](https://fishshell.com/) - Friendly Interactive Shell
- [KDE Rounded Corners](https://github.com/matinlotfali/KDE-Rounded-Corners) - KDE effect
- [JetBrains](https://www.jetbrains.com/) - Professional IDEs
- All open-source contributors

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/YOUR_USERNAME/kubuntu-dev-setup/issues)
- **Discussions:** [GitHub Discussions](https://github.com/YOUR_USERNAME/kubuntu-dev-setup/discussions)
- **Email:** your.email@example.com

---

## ⭐ Star This Repository

If this script helped you, please consider giving it a star on GitHub! ⭐

---

**Note:** This script is designed for Kubuntu but should work on most Ubuntu-based distributions. Some KDE-specific features (Rounded Corners, Grub theme) may not work on other desktop environments like GNOME or XFCE. 

**Tested on:**
- Kubuntu 24.04 LTS ✅
- Kubuntu 23.10 ✅
- Ubuntu 24.04 LTS ⚠️ (KDE features unavailable)
- Linux Mint 21.3 ⚠️ (KDE features unavailable)
