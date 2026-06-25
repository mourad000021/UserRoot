#!/bin/bash

# ==============================================
#  PROOT AUTO-SETUP SCRIPT (Alwaysdata)
#  - Telegram: @Merad_Dev_Info
#  - Downloads proot + rootfs
#  - Configures shell to auto-login to it
# ==============================================

set -e  # توقف عند أي خطأ

# الألوان
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# المتغيرات
PROOT_DIR="$HOME/.proot"
PROOT_BIN="$PROOT_DIR/proot"
DISTRO_DIR="$PROOT_DIR/distros"
CHOICE=""

# عرض البانر مع معلومات التيلجرام
clear
echo -e "${CYAN}=================================================="
echo "  PROOT AUTO-SETUP (No Root Required)"
echo -e "=================================================="
echo -e "  ${GREEN}📱 Telegram: ${CYAN}@Merad_Dev_Info${NC}"
echo -e "${CYAN}==================================================${NC}"
echo ""

# دالة التحميل مع مؤشر
download_file() {
    local url="$1"
    local output="$2"
    echo -e "${YELLOW}⏳ Loading $output ...${NC}"
    wget -q --show-progress -O "$output" "$url"
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to download $output${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ $output downloaded${NC}"
}

# 1. تحميل أداة proot
install_proot() {
    echo -e "${YELLOW}📦 Installing proot...${NC}"
    mkdir -p "$PROOT_DIR"
    download_file "https://proot.gitlab.io/proot/bin/proot" "$PROOT_BIN"
    chmod +x "$PROOT_BIN"
    echo -e "${GREEN}✅ proot installed at $PROOT_BIN${NC}"
}

# 2. تحميل نظام القاعدة (rootfs) حسب الاختيار
install_distro() {
    local distro_name="$1"
    local distro_url="$2"
    local distro_archive="$DISTRO_DIR/$distro_name.tar.gz"
    local distro_folder="$DISTRO_DIR/$distro_name"

    mkdir -p "$DISTRO_DIR"
    echo -e "${YELLOW}📥 Downloading $distro_name rootfs...${NC}"
    download_file "$distro_url" "$distro_archive"

    echo -e "${YELLOW}📂 Extracting $distro_name ...${NC}"
    mkdir -p "$distro_folder"
    tar -xzf "$distro_archive" -C "$distro_folder"
    rm "$distro_archive"
    echo -e "${GREEN}✅ $distro_name installed at $distro_folder${NC}"
}

# 3. تفعيل الدخول التلقائي (تعديل ملفات الشل)
auto_login() {
    local distro_folder="$1"
    local distro_name="$2"
    local login_code="
# Auto-login to proot environment (Telegram: @Merad_Dev_Info)
if [ -z \"\$PROOT_PREFIX\" ] && [ -f \"$PROOT_BIN\" ] && [ -d \"$distro_folder\" ]; then
    echo -e \"${GREEN}🚀 Entering $distro_name environment as root...${NC}\"
    echo -e \"${CYAN}📱 Telegram: @Merad_Dev_Info${NC}\"
    exec $PROOT_BIN -S $distro_folder
fi
"
    echo -e "${YELLOW}🔧 Configuring auto-login...${NC}"

    # إضافة إلى .profile (يُقرأ في جميع الأصداف)
    if ! grep -q "Auto-login to proot" ~/.profile 2>/dev/null; then
        echo "$login_code" >> ~/.profile
        echo -e "${GREEN}✅ Added to ~/.profile${NC}"
    else
        echo -e "${YELLOW}ℹ️  ~/.profile already contains auto-login${NC}"
    fi

    # إضافة إلى .bashrc (تأكيد إضافي)
    if ! grep -q "Auto-login to proot" ~/.bashrc 2>/dev/null; then
        echo "$login_code" >> ~/.bashrc
        echo -e "${GREEN}✅ Added to ~/.bashrc${NC}"
    else
        echo -e "${YELLOW}ℹ️  ~/.bashrc already contains auto-login${NC}"
    fi

    # إضافة إلى .ssh/rc (الحل الأقوى)
    mkdir -p ~/.ssh
    if ! grep -q "Auto-login to proot" ~/.ssh/rc 2>/dev/null; then
        echo "# Auto-login to proot (Telegram: @Merad_Dev_Info)" > ~/.ssh/rc
        echo "exec $PROOT_BIN -S $distro_folder" >> ~/.ssh/rc
        chmod +x ~/.ssh/rc
        echo -e "${GREEN}✅ Added to ~/.ssh/rc${NC}"
    else
        echo -e "${YELLOW}ℹ️  ~/.ssh/rc already contains auto-login${NC}"
    fi

    echo -e "${GREEN}✅ Auto-login configured successfully!${NC}"
}

# 4. قائمة التوزيعات المتاحة
menu() {
    echo -e "${BLUE}=================================================="
    echo "  Choose a Linux distribution:"
    echo -e "==================================================${NC}"
    echo " 1) Ubuntu 22.04 (Jammy) - Recommended"
    echo " 2) Alpine 3.19 (Lightweight)"
    echo " 3) Debian 12 (Bookworm)"
    echo " 4) Fedora 40"
    echo -e "${BLUE}==================================================${NC}"
    read -p "Enter choice (1/2/3/4): " CHOICE

    case $CHOICE in
        1)
            distro_name="ubuntu"
            distro_url="https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04.3-base-amd64.tar.gz"
            ;;
        2)
            distro_name="alpine"
            distro_url="https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-minirootfs-3.19.1-x86_64.tar.gz"
            ;;
        3)
            distro_name="debian"
            distro_url="https://github.com/debuerreotype/docker-debian-artifacts/raw/dist-amd64/bookworm/slim/rootfs.tar.xz"
            ;;
        4)
            distro_name="fedora"
            distro_url="https://download.fedoraproject.org/pub/fedora/linux/releases/40/Container/x86_64/images/Fedora-Container-Base-40-1.14.x86_64.tar.xz"
            ;;
        *)
            echo -e "${RED}❌ Invalid choice${NC}"
            exit 1
            ;;
    esac

    distro_folder="$DISTRO_DIR/$distro_name"
}

# 5. التثبيت الكامل
main() {
    menu
    install_proot
    install_distro "$distro_name" "$distro_url"
    auto_login "$distro_folder" "$distro_name"

    echo -e "${GREEN}=================================================="
    echo "  ✅ Setup complete!"
    echo -e "==================================================${NC}"
    echo -e "${CYAN}📱 Telegram: @Merad_Dev_Info${NC}"
    echo -e "${YELLOW}⚡ To apply changes, run:${NC}"
    echo "  source ~/.profile"
    echo -e "${YELLOW}⚡ Or just exit and reconnect via SSH.${NC}"
    echo -e "${GREEN}✅ Your default environment is now $distro_name!${NC}"
}

# تشغيل
main