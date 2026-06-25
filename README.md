# 🧠 UserRoot - Your Private Root Inside Your Home

**Version:** 1.0  
**Developer:** @Merad_Dev_Info  
**GitHub Repository:** [mourad000021/UserRoot](https://github.com/mourad000021/UserRoot)  
**Concept:** Don't hack the host. Build your own root.

---

## 📖 What is UserRoot?

UserRoot is a complete toolkit that lets you create **your own Linux root filesystem** inside your home directory on any SSH server – **without root privileges**.

You can install packages, run services, and experiment freely without affecting the host system. It uses `proot` to emulate a chroot-like environment, giving you full control over your isolated space.

---

## ✨ Features

- **Multiple distributions** – Ubuntu, Debian, Alpine, Fedora.
- **Easy management** – install, switch, remove, update.
- **Auto-login** – automatically enter your preferred distro when you connect via SSH.
- **No root needed** – runs entirely in user space.
- **Colored, user-friendly interface** – menus, progress bars, and clear messages.
- **Telegram integration** – shows `@Merad_Dev_Info` for support.

---

## 📦 Requirements

- Any Linux server with SSH access.
- `wget` and `tar` (usually pre-installed).
- Bash shell.

---

## 🚀 Installation

**One-liner installation** – download and run the script in a single command:

```bash
curl -o ~/userroot.sh https://raw.githubusercontent.com/mourad000021/UserRoot/main/install.sh
chmod +x ~/userroot.sh
./userroot.sh
