#!/bin/sh
# OpenFDE for Linux installation script.
#
# This script is intended as a convenient way to configure openfde's package
# repositories and to install Openfde. This script is not recommended
# for production environments. Before running this script, make yourself familiar
# with potential risks and limitations, and refer to the installation manual
# at https://docs.openfde.com/docs/documentation/installation-guide for alternative installation methods.
#
# The script:
#
# - Requires `root` or `sudo` privileges to run.
# - Attempts to detect your operation system and version and configure your
#   package management system for you.
# - Doesn't allow you to customize most installation parameters.
# - Installs dependencies and recommendations without asking for confirmation.

set -e

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

# === 1. Root check ===
if [ "$(id -u)" -ne 0 ]; then
    if command_exists sudo; then
        sh_c='sudo'
    elif command_exists su; then
        sh_c='su -c'
    else
        cat >&2 <<-'EOF'
Error: this installer needs the ability to run commands as root.
We are unable to find either "sudo" or "su" available to make this happen.
EOF
        exit 1
    fi
else
    sh_c=''
fi

# === 2. Load OS info once ===
if [ ! -f /etc/os-release ]; then
    printf "%b\n" "\033[31mError: /etc/os-release not found. Unsupported system.\033[0m" >&2
    exit 1
fi
. /etc/os-release
lsb_dist="$ID"
arch="$(uname -m)"

# === 3. Architecture check ===
if [ "$arch" != "aarch64" ]; then
    if [ "$lsb_dist" = "ubuntu" ]; then
        if [ "$arch" != "x86_64" ]; then
            printf "%b\n" "\033[31mOpenFDE: Sorry, the architecture \"$arch\" is not supported, only aarch64 and x86_64 are supported. \033[0m"
            exit 1
        fi
    else
        printf "%b\n" "\033[31mOpenFDE: Sorry, the architecture \"$arch\" is not supported, only aarch64 is supported. \033[0m"
        exit 1
    fi
fi

domain_name="https://openfde.com"

# === 4. Validate OS version ===
case "$lsb_dist" in
    deepin)
        str="$VERSION_CODENAME"
        if [ "$str" != "beige" ]; then
            printf "%b\n" "\033[31mOpenFDE: Sorry, the os codename \"$str\" is not supported. Only beige(23) is supported. \033[0m"
            exit 1
        fi
        ;;
    ubuntu)
        str="$VERSION_CODENAME"
        if [ "$str" != "jammy" ] && [ "$str" != "noble" ]; then
            printf "%b\n" "\033[31mOpenFDE: Sorry, the os codename \"$str\" is not supported. Only jammy(22.04) and noble(24.04) are supported.\033[0m"
            exit 1
        fi
        ;;
    kylin)
        str="$PROJECT_CODENAME"
        if [ "$str" != "V10SP1" ]; then
            printf "%b\n" "\033[31mOpenFDE: Sorry, the os codename \"$str\" is not supported. Only V10SP1 is supported.\033[0m"
            exit 1
        fi
        if command_exists getstatus; then
            exec_stat=$(getstatus | grep -w exec | awk -F ":" '{print $2}' | tr -d " ")
            if [ "$exec_stat" != "off" ]; then
                printf "%b" "\033[31mOpenFDE: Security Policy is enabled, need disable for installing OpenFDE y/n?.\033[0m"
                read -r choice
                if [ "$choice" = "n" ] || [ "$choice" = "no" ]; then
                    printf "%b\n" "\033[31mOpenFDE: You choosed to exit the installation.\033[0m"
                    exit 4
                fi
            fi
        fi
        $sh_c setsignstatus off 1>/dev/null 2>&1 || true
        $sh_c setstatus softmode 1>/dev/null 2>&1 || true
        for mod in exectl netctl devctl ipt fpro ppro kmod; do
            $sh_c setstatus -f "$mod" off -p 1>/dev/null 2>&1 || true
            $sh_c sed -i "s/kysec_${mod}pro.*/kysec_${mod}pro = 0/" /etc/kysec/kysec.conf 1>/dev/null 2>&1 || true
        done
        ;;
    uos)
        str="$VERSION_CODENAME"
        if [ "$str" != "eagle" ]; then
            $sh_c echo "Sorry, the os codename \"$str\" is not supported. only eagle is supported."
            exit 1
        fi
        ;;
    debian)
        str="$VERSION_CODENAME"
        if [ "$str" != "bookworm" ]; then
            $sh_c echo "Sorry, the os codename \"$str\" is not supported. only bookworm is supported."
            exit 1
        fi
        ;;
    *)
        echo "Sorry: The OS Distribution \"$lsb_dist\" is not supported! Only kylin, uos, deepin, ubuntu, and debian are supported."
        exit 1
        ;;
esac

printf "%b\n" "\033[31mOpenFDE: start to install openfde\033[0m"

# === 5. Install deps and add repo ===
$sh_c apt update
$sh_c apt-get install -y wget gpg

TMP_KEY="packages.openfde.gpg"
trap 'rm -f "$TMP_KEY"' EXIT

if ! wget -qO- "$domain_name/keys/openfde.asc" | gpg --dearmor > "$TMP_KEY"; then
    printf "%b\n" "\033[31mError: Failed to download or process GPG key.\033[0m" >&2
    exit 1
fi

$sh_c install -D -o root -g root -m 644 "$TMP_KEY" /etc/apt/keyrings/packages.openfde.gpg

# === 6. Distribution-specific setup ===
deepin_should_reboot=0

case "$lsb_dist" in
    deepin)
        kernel_release="$(uname -r)"
        if [ "$kernel_release" != "6.6.71-arm64-desktop-hwe" ]; then
            printf "%b\n" "\033[31mOpenFDE: it's going to install the 6.6.71 kernel for OpenFDE.\033[0m"
            if ! $sh_c apt -y install linux-image-6.6.71-arm64-desktop-hwe; then
                echo "Tips: install linux-image-6.6.71 failed"
                exit 100
            fi
            printf "%b\n" "\033[31m Tips: you should reboot now to apply the 6.6.71 kernel in order to install openfde. \033[0m"
            deepin_should_reboot=1
        fi

        if [ ! -e /sys/fs/cgroup/memory ]; then
            $sh_c sed -i 's/systemd.unified_cgroup_hierarchy=0//' /etc/default/grub 1>/dev/null 2>&1 || true
            $sh_c sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/ s/"/"systemd.unified_cgroup_hierarchy=0 /' /etc/default/grub
            $sh_c update-grub
            printf "%b\n" "\033[31m Tips: must reboot to apply unified cgroup hierarchy. \033[0m"
            deepin_should_reboot=1
        fi

        if [ "$deepin_should_reboot" -eq 1 ]; then
            printf "%b" "\033[31mOpenFDE: run $0 again to install OpenFDE after this reboot, reboot now [y]/n ? \033[0m"
            read -r choice
            if [ "$choice" != "n" ] && [ "$choice" != "no" ]; then
                $sh_c reboot
            fi
            exit 0
        fi

        printf "deb [arch=%s signed-by=/etc/apt/keyrings/packages.openfde.gpg] %s/repos/%s/ %s main\n" \
            "$(dpkg --print-architecture)" "$domain_name" "$lsb_dist" "$VERSION_CODENAME" | \
            $sh_c tee /etc/apt/sources.list.d/openfde.list > /dev/null
        ;;

    ubuntu)
        $sh_c apt -y install "linux-modules-extra-$(uname -r)"
        if [ "$arch" = "x86_64" ]; then
            lsb_arch="${lsb_dist}_x86"
        else
            lsb_arch="$lsb_dist"
        fi
        printf "deb [arch=%s signed-by=/etc/apt/keyrings/packages.openfde.gpg] %s/repos/%s/ %s main\n" \
            "$(dpkg --print-architecture)" "$domain_name" "$lsb_arch" "$VERSION_CODENAME" | \
            $sh_c tee /etc/apt/sources.list.d/openfde.list > /dev/null
        ;;

    kylin)
        printf "deb [arch=%s signed-by=/etc/apt/keyrings/packages.openfde.gpg] %s/repos/%s/ %s main\n" \
            "$(dpkg --print-architecture)" "$domain_name" "$lsb_dist" "$PROJECT_CODENAME" | \
            $sh_c tee /etc/apt/sources.list.d/openfde.list > /dev/null
        ;;

    debian)
        printf "deb [arch=%s signed-by=/etc/apt/keyrings/packages.openfde.gpg] %s/repos/%s/ %s main\n" \
            "$(dpkg --print-architecture)" "$domain_name" "$lsb_dist" "$VERSION_CODENAME" | \
            $sh_c tee /etc/apt/sources.list.d/openfde.list > /dev/null
        ;;

    uos)
        printf "deb [arch=%s signed-by=/etc/apt/keyrings/packages.openfde.gpg] %s/repos/%s/ %s main\n" \
            "$(dpkg --print-architecture)" "$domain_name" "$lsb_dist" "$VERSION_CODENAME" | \
            $sh_c tee /etc/apt/sources.list.d/openfde.list > /dev/null
        $sh_c apt update
        baseVer="$(uname -r | awk -F "-" '{print $1}')"
        if [ "$baseVer" = "4.19.0" ]; then
            $sh_c apt install -y fde-binder-dkms
            if ! grep -q binder /proc/filesystems; then
                $sh_c rmmod binder_linux 1>/dev/null 2>&1 || true
                if ! $sh_c modprobe binder_linux; then
                    echo "Error: modprobe binder_linux failed"
                    exit 1
                fi
                $sh_c mkdir -p /dev/binderfs
                $sh_c mount -t binder binder /dev/binderfs
            fi
        fi
        ;;
esac

$sh_c apt update

# === 7. Install GPU driver if X100 detected ===
if command_exists lspci; then
    if lspci | grep -q "X100.*GPU_DMA"; then
        if [ "$lsb_dist" = "kylin" ]; then
            baseVer="$(uname -r | awk -F "-" '{print $1}')"
            if [ "$baseVer" != "5.4.18" ]; then
                printf "%b\n" "\033[31mOpenFDE: Sorry, your kernel version $baseVer is not supported for now. You should upgrade kernel to 5.4.18-85 at least\033[0m"
                exit 1
            fi
            branchVer="$(uname -r | awk -F "-" '{print $2}')"
            if [ "$branchVer" -lt 85 ]; then
                printf "%b\n" "\033[31mOpenFDE: Sorry, your kernel version $baseVer is not supported for now. You should upgrade kernel to 5.4.18-85 at least.\033[0m"
                exit 1
            fi
        fi
        $sh_c apt install -y fdeion-dkms
    fi
fi

# === 8. Install correct OpenFDE package (Ubuntu logic preserved) ===
if [ "$lsb_dist" = "ubuntu" ]; then
    if command_exists lscpu && lscpu | grep -qw "32-bit"; then
        # x86_64 system
        if $sh_c dpkg -l | grep -q "openfde-arm64.*Fusion Desktop Environment"; then
            printf "%b" "\033[31mOpenFDE: openfde-arm64 has been installed, it's going to uninstall it [y]/n?. \033[0m"
            read -r choice
            if [ "$choice" != "n" ] && [ "$choice" != "no" ]; then
                $sh_c apt purge -y openfde-arm64
            fi
        fi
        $sh_c apt install -y openfde
    else
        # Likely ARM system
        printf "%b" "\033[31mOpenFDE: Your cpu only support 64bit, it's going to install openfde-arm64 only deb, [y]/n?. \033[0m"
        read -r choice
        if [ "$choice" = "n" ] || [ "$choice" = "no" ]; then
            exit 0
        fi
        if $sh_c dpkg -l | grep -q "openfde[^-]*.*Fusion Desktop Environment" | grep -v arm64; then
            printf "%b" "\033[31mOpenFDE: openfde has been installed, it's going to uninstall it [y]/n?. \033[0m"
            read -r choice
            if [ "$choice" != "n" ] && [ "$choice" != "no" ]; then
                $sh_c apt purge -y openfde
            fi
        fi
        $sh_c apt install -y openfde-arm64
    fi
else
    # All other distros: aarch64 only
    $sh_c apt install -y openfde-arm64
fi

# === 9. Post-install fixes ===
if [ "$lsb_dist" = "debian" ]; then
    if uname -a | grep -q "rpi-2712"; then
        $sh_c sed -i "/arm_64bit/a kernel=kernel8.img" /boot/firmware/config.txt
        printf "%b\n" "\033[31m Tips: must reboot to apply kernel 8 after installing finished. \033[0m"
    fi
    if [ ! -e /sys/fs/cgroup/memory ]; then
        $sh_c sed -i 's/psi=1 cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 systemd.unified_cgroup_hierarchy=0//' /boot/firmware/cmdline.txt
        $sh_c sed -i '1s/^/psi=1 cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 systemd.unified_cgroup_hierarchy=0 /' /boot/firmware/cmdline.txt
        printf "%b\n" "\033[31m Tips: must reboot to make openfde available. \033[0m"
    fi
fi

if [ "$lsb_dist" = "deepin" ]; then
    $sh_c rm -f /usr/share/wayland-sessions/fde.desktop
fi

if [ "$lsb_dist" = "uos" ]; then
    if command_exists lspci && lspci | grep -q "X100.*GPU_DMA"; then
        $sh_c rm -f /usr/share/wayland-sessions/fde.desktop
    fi
fi

printf "%b\n" "\033[32mOpenFDE installation completed successfully!\033[0m"
printf "%b\n" "\033[33mPlease reboot your system to apply all changes.\033[0m"