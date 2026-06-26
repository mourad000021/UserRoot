#!/bin/bash

# ============================================================
#  UserRoot v1.0 - Your Private Root Inside Your Home
#  Concept: Don't hack the host, build your own root.
#  Telegram: @Merad_Dev_Info
# ============================================================

set -e

# ---------- الألوان ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# ---------- المتغيرات ----------
BASE_DIR="$HOME/UserRoot"
PROOT_BIN="$BASE_DIR/proot"
DISTROS_DIR="$BASE_DIR/distros"
CONFIG_FILE="$BASE_DIR/config.conf"
CURRENT_DISTRO=""
CHOICE=""

# ---------- الدوال المساعدة ----------
print_banner() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗"
    echo -e "║           ${MAGENTA}UserRoot ${CYAN}- Your Private Root          ║"
    echo -e "║     ${GREEN}📱 Telegram: ${CYAN}@Merad_Dev_Info${CYAN}               ║"
    echo -e "║  ${YELLOW}💡 Don't hack the host. Build your own root.${CYAN}    ║"
    echo -e "╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

download_file() {
    local url="$1"
    local output="$2"
    echo -e "${YELLOW}⏳ Downloading $(basename "$output")...${NC}"
    wget -q --show-progress -O "$output" "$url" || {
        echo -e "${RED}❌ Download failed.${NC}"
        return 1
    }
    echo -e "${GREEN}✅ Done.${NC}"
}

check_deps() {
    for cmd in wget tar; do
        if ! command -v "$cmd" &>/dev/null; then
            echo -e "${RED}❌ '$cmd' is required but not installed.${NC}"
            exit 1
        fi
    done
}

# ---------- الوظائف الأساسية ----------
install_proot() {
    echo -e "${YELLOW}📦 Installing UserRoot core (proot)...${NC}"
    mkdir -p "$BASE_DIR"
    download_file "https://proot.gitlab.io/proot/bin/proot" "$PROOT_BIN" || exit 1
    chmod +x "$PROOT_BIN"
    echo -e "${GREEN}✅ Core installed at $PROOT_BIN${NC}"
}

install_distro() {
    local name="$1"
    local url="$2"
    local archive="$DISTROS_DIR/${name}.tar"
    local target_dir="$DISTROS_DIR/$name"

    mkdir -p "$DISTROS_DIR"
    echo -e "${YELLOW}📥 Downloading $name root filesystem...${NC}"
    download_file "$url" "$archive" || return 1

    echo -e "${YELLOW}📂 Extracting to $target_dir ...${NC}"
    mkdir -p "$target_dir"
    tar -xf "$archive" -C "$target_dir" || {
        echo -e "${RED}❌ Extraction failed.${NC}"
        rm -f "$archive"
        return 1
    }
    rm -f "$archive"
    echo -e "${GREEN}✅ $name installed at $target_dir${NC}"
}

set_default_distro() {
    local distro="$1"
    echo "DEFAULT_DISTRO=$distro" > "$CONFIG_FILE"
    CURRENT_DISTRO="$distro"
    echo -e "${GREEN}✅ Default distro set to $distro${NC}"
}

get_default_distro() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        echo "$DEFAULT_DISTRO"
    else
        echo ""
    fi
}

# ---------- تفعيل الدخول التلقائي (الإصدار المُصلَح) ----------
auto_login() {
    local distro="$1"
    local target_dir="$DISTROS_DIR/$distro"

    # كود الدخول التلقائي - تم إزالة echo -e واستخدام printf للتوافق
    local login_code="
# UserRoot: Auto-login to your private root (Telegram: @Merad_Dev_Info)
if [ -z \"\$PROOT_PREFIX\" ] && [ -f \"$PROOT_BIN\" ] && [ -d \"$target_dir\" ]; then
    printf \"${GREEN}🚀 Entering your UserRoot ($distro)...${NC}\n\"
    printf \"${CYAN}📱 Telegram: @Merad_Dev_Info${NC}\n\"
    exec $PROOT_BIN -S $target_dir
fi
"

    echo -e "${YELLOW}🔧 Configuring auto-login for $distro...${NC}"

    # حذف أي إعدادات سابقة لـ UserRoot من الملفات لمنع التكرار
    for file in ~/.profile ~/.bashrc ~/.ssh/rc; do
        if [[ -f "$file" ]]; then
            # حذف الأسطر التي تبدأ بـ "# UserRoot:" أو تحتوي على "UserRoot: Auto-login"
            sed -i '/^# UserRoot:/d' "$file" 2>/dev/null
            sed -i '/UserRoot: Auto-login/d' "$file" 2>/dev/null
            # حذف الكتلة الكاملة بين "# UserRoot:" و "fi" إن وجدت
            sed -i '/# UserRoot:/,/fi/d' "$file" 2>/dev/null
        fi
    done

    # إضافة الكود الجديد إلى الملفات
    for file in ~/.profile ~/.bashrc ~/.ssh/rc; do
        if [[ "$file" == ~/.ssh/rc ]]; then
            mkdir -p ~/.ssh
        fi
        echo "$login_code" >> "$file"
        [[ "$file" == ~/.ssh/rc ]] && chmod +x "$file"
        echo -e "${GREEN}✅ Added to $file${NC}"
    done
}

# ---------- قائمة التوزيعات ----------
distro_menu() {
    echo -e "${BLUE}╔═══════════════════════════════════════════════╗"
    echo -e "║         Choose a distribution to install         ║"
    echo -e "╚═══════════════════════════════════════════════╝${NC}"
    echo " 1) Ubuntu 22.04 (Jammy)   - Recommended"
    echo " 2) Debian 12 (Bookworm)   - Classic"
    echo " 3) Alpine 3.19            - Super lightweight"
    echo " 4) Fedora 40              - Cutting edge"
    echo " 5) Cancel"
    echo -e "${BLUE}───────────────────────────────────────────────${NC}"
    read -p "Enter choice (1-5): " CHOICE

    case $CHOICE in
        1) distro="ubuntu"; url="https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04.3-base-amd64.tar.gz" ;;
        2) distro="debian"; url="https://github.com/debuerreotype/docker-debian-artifacts/raw/dist-amd64/bookworm/slim/rootfs.tar.xz" ;;
        3) distro="alpine"; url="https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-minirootfs-3.19.1-x86_64.tar.gz" ;;
        4) distro="fedora"; url="https://download.fedoraproject.org/pub/fedora/linux/releases/40/Container/x86_64/images/Fedora-Container-Base-40-1.14.x86_64.tar.xz" ;;
        5) echo -e "${YELLOW}❌ Cancelled.${NC}"; exit 0 ;;
        *) echo -e "${RED}❌ Invalid choice.${NC}"; exit 1 ;;
    esac
}

# ---------- قائمة الإدارة ----------
manage_menu() {
    while true; do
        print_banner
        echo -e "${CYAN}╔═══════════════════════════════════════════════╗"
        echo -e "║               UserRoot Manager                  ║"
        echo -e "╚═══════════════════════════════════════════════╝${NC}"
        echo " 1) Install a new distribution"
        echo " 2) List installed distributions"
        echo " 3) Switch default distribution"
        echo " 4) Remove a distribution"
        echo " 5) Update proot core"
        echo " 6) Enter a distribution (manual)"
        echo " 7) Exit"
        echo -e "${BLUE}───────────────────────────────────────────────${NC}"
        read -p "Choose an option: " opt

        case $opt in
            1)
                distro_menu
                install_distro "$distro" "$url"
                read -p "Set this distro as default? (y/n): " setdef
                if [[ "$setdef" =~ ^[Yy]$ ]]; then
                    set_default_distro "$distro"
                    auto_login "$distro"
                fi
                ;;
            2)
                echo -e "${YELLOW}Installed distros:${NC}"
                ls -1 "$DISTROS_DIR" 2>/dev/null || echo "None"
                read -p "Press Enter to continue..."
                ;;
            3)
                echo -e "${YELLOW}Available distros:${NC}"
                ls -1 "$DISTROS_DIR" 2>/dev/null || { echo "None"; continue; }
                read -p "Enter distro name to set as default: " def
                if [[ -d "$DISTROS_DIR/$def" ]]; then
                    set_default_distro "$def"
                    auto_login "$def"
                else
                    echo -e "${RED}❌ Not found.${NC}"
                fi
                read -p "Press Enter to continue..."
                ;;
            4)
                echo -e "${YELLOW}Installed distros:${NC}"
                ls -1 "$DISTROS_DIR" 2>/dev/null || { echo "None"; continue; }
                read -p "Enter distro name to remove: " rem
                if [[ -d "$DISTROS_DIR/$rem" ]]; then
                    rm -rf "$DISTROS_DIR/$rem"
                    echo -e "${GREEN}✅ Removed.${NC}"
                    if [[ "$(get_default_distro)" == "$rem" ]]; then
                        rm -f "$CONFIG_FILE"
                        echo -e "${YELLOW}Default distro cleared.${NC}"
                    fi
                else
                    echo -e "${RED}❌ Not found.${NC}"
                fi
                read -p "Press Enter to continue..."
                ;;
            5)
                echo -e "${YELLOW}Updating proot...${NC}"
                rm -f "$PROOT_BIN"
                install_proot
                read -p "Press Enter to continue..."
                ;;
            6)
                echo -e "${YELLOW}Available distros:${NC}"
                ls -1 "$DISTROS_DIR" 2>/dev/null || { echo "None"; continue; }
                read -p "Enter distro name to enter: " ent
                if [[ -d "$DISTROS_DIR/$ent" ]]; then
                    echo -e "${GREEN}🚀 Entering $ent...${NC}"
                    exec "$PROOT_BIN" -S "$DISTROS_DIR/$ent"
                else
                    echo -e "${RED}❌ Not found.${NC}"
                fi
                ;;
            7)
                echo -e "${GREEN}👋 Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Invalid option.${NC}"
                ;;
        esac
    done
}

# ---------- التثبيت الأولي أو الإدارة ----------
main() {
    check_deps

    if [[ ! -d "$DISTROS_DIR" ]]; then
        print_banner
        echo -e "${YELLOW}⚡ No distribution found. Let's set up your UserRoot.${NC}"
        distro_menu
        install_proot
        install_distro "$distro" "$url"
        set_default_distro "$distro"
        auto_login "$distro"
        echo -e "${GREEN}✅ UserRoot setup complete!${NC}"
        echo -e "${YELLOW}⚡ To use it, type 'exit' and reconnect via SSH.${NC}"
        echo -e "${YELLOW}⚡ Or run './userroot.sh' again to manage.${NC}"
    else
        manage_menu
    fi
}

# تشغيل
main