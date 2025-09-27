#!/bin/bash
set -e

LOG_FILE="/var/log/cloudlinux_install.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# ============================================
# CloudLinux Components Installer for AlmaLinux
# Version: 1.0
# ============================================

# ---------------- Banner --------------------
echo -e "\e[97m\n"
echo -e "     _    _          _                                                  "
echo -e "    / \  | |__  _ __/ |___  ___ _ ____   _____ _ __  ___ ___  _ __ ___  "
echo -e "   / _ \ | '_ \| '__| / __|/ _ \ '__\ \ / / _ \ '__|/ __/ _ \| '_ \` _ \ "
echo -e "  / ___ \| |_) | |  | \__ \  __/ |   \ V /  __/ |  | (_| (_) | | | | | |"
echo -e " /_/   \_\_.__/|_|  |_|___/\___|_|    \_/ \___|_| (_)___\___/|_| |_| |_|"
echo -e "\n"
echo -e "||Affordable & Reliable License System"
echo -e "||Unlock The Best Deals On Cpanel, LiteSpeed, CloudLinux and Top Web Hosting Licenses at Unbeatable Prices abr1server.com"
echo -e "||Join our reseller program"
echo -e "\n\e[0m"

# ----------------------------------------
# Step 1: Update cPanel
# ----------------------------------------
echo "Updating cPanel..."
/usr/local/cpanel/scripts/upcp --force || echo "Warning: cPanel update failed, continuing..."

# ----------------------------------------
# Step 2: Configure CloudLinux repo
# ----------------------------------------
cat >/etc/yum.repos.d/cloudlinux9.repo <<'EOF'
[cloudlinux-9]
name=CloudLinux 9 mirror
baseurl=https://cln9-mirror.easyconfig.net/cloudlinux-x86_64-server-9
gpgcheck=0
enabled=1
skip_if_unavailable=True
EOF

dnf clean all
dnf repolist all || echo "Warning: dnf repolist failed"

# ========================
# Step 3: Install CloudLinux Components Only
# ========================
if [ ! -f /root/cldeploy ]; then
    curl -o /root/cldeploy https://repo.licensesystem.ir/cldeploy
    chmod +x /root/cldeploy
fi


# ----------------------------------------
# Run cldeploy with components only and skip OS version check
# ----------------------------------------

sh /root/cldeploy --components-only --skip-os-check

# ----------------------------------------
# Step 6: Setup virtualenv and install xray
# ----------------------------------------
# Check if virtualenv exists
if [ ! -d "/opt/cloudlinux/venv" ]; then
    echo "Virtualenv not found. Creating virtualenv at /opt/cloudlinux/venv..."
    python3 -m venv /opt/cloudlinux/venv
fi

# Activate virtualenv
echo "Activating virtualenv..."
source /opt/cloudlinux/venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install xray package
echo "Installing xray package..."
pip install xray

# Verify xray internal files
echo "Verifying xray internal files..."
ls -l /opt/cloudlinux/venv/lib/python3.11/site-packages/xray/internal/

# Deactivate virtualenv
deactivate
echo "Virtualenv deactivated."
