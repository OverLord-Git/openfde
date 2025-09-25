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
sh_c='sh'
if [ "$(id -u)" -ne 0 ]; then
    if command_exists sudo; then
        sh_c='sudo -E sh -c'
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
    sh_c='sh -c'
fi

# === 2. GPU driver check ===
unsupported="nvidia ftv310"
supported="i915 amdgpu radeon panfrost msm vc4 v3d virtio-pci pvrsrvkm ftg340 nouveau jmgpu"

get_kernel_driver() {
    local dev="$1"
    if [ -f "/sys/class/drm/${dev}/device/uevent" ]; then
        grep '^DRIVER=' "/sys/class/drm/${dev}/device/uevent" 2>/dev/null | cut -d'=' -f2
    fi
}

# Check GPU drivers
for render_node in /dev/dri/renderD*; do
    if [ -c "$render_node" ]; then
        render_dev=$(basename "$render_node")
        driver=$(get_kernel_driver "$render_dev")
        if [ -n "$driver" ]; then
            for unsup in $unsupported; do
                if [ "$driver" = "$unsup" ]; then
                    printf "%b\n" "\033[31mOpenFDE: GPU driver \"$driver\" is not supported.\033[0m" >&2
                    exit 1
                fi
            done
            found_supported=0
            for sup in $supported; do
                if [ "$driver" = "$sup" ]; then
                    found_supported=1
                    break
                fi
            done
            if [ "$found_supported" -eq 0 ]; then
                printf "%b\n" "\033[31mOpenFDE: GPU driver \"$driver\" is not supported.\033[0m" >&2
                exit 1
            fi
        fi
    fi
done

# === 3. Load OS info once ===
if [ ! -f /etc/os-release ]; then
    printf "%b\n" "\033[31mError: /etc/os-release not found. Unsupported system.\033[0m" >&2
    exit 1
fi
. /etc/os-release
lsb_dist="$ID"
arch="$(uname -m)"

# === 4. Architecture check ===
if [ "$arch" != "aarch64" ]; then
    if [ "$lsb_dist" = "ubuntu" ]; then
        if [ "$arch" != "x86_64" ]; then
            printf "%b\n" "\033[31mOpenFDE: Sorry, the architecture \"$arch\" is not supported, only aarch64 and x86_64 are supported. \033[0m" >&2
            exit 1
        fi
    else
        printf "%b\n" "\033[31mOpenFDE: Sorry, the architecture \"$arch\" is not supported, only aarch64 is supported. \033[0m" >&2
        exit 1
    fi
fi

domain_name="https://openfde.com"

# === 5. Validate OS version ===
case "$lsb_dist" in
    deepin)
        str="$VERSION_CODENAME"
        if [ "$str" != "beige" ]; then
            printf "%b\n" "\033[31mOpenFDE: Sorry, the os codename \"$str\" is not supported. Only beige(23) is supported. \033[0m" >&2
            exit 1
        fi
        ;;
    ubuntu)
        str="$VERSION_CODENAME"
        if [ "$str" != "jammy" ] && [ "$str" != "noble" ]; then
            printf "%b\n" "\033[31mOpenFDE: Sorry, the os codename \"$str\" is not supported. Only jammy(22.04) and noble(24.04) are supported.\033[0m" >&2
            exit 1
        fi
        ;;
    kylin)
        str="$PROJECT_CODENAME"
        if [ "$str" != "V10SP1" ]; then
            printf "%b\n" "\033[31mOpenFDE: Sorry, the os codename \"$str\" is not supported. Only V10SP1 is supported.\033[0m" >&2
            exit 1
        fi
        if command_exists getstatus; then
            exec_stat=$(getstatus | grep -w exec | awk -F ":" '{print $2}' | tr -d " ")
            if [ "$exec_stat" != "off" ]; then
                printf "%b" "\033[31mOpenFDE: Security Policy is enabled, need disable for installing OpenFDE y/n? \033[0m"
                read -r choice
                if [ "$choice" = "n" ] || [ "$choice" = "no" ]; then
                    printf "%b\n" "\033[31mOpenFDE: You choosed to exit the installation.\033[0m"
                    exit 4
                fi
            fi
            # Disable security policies
            $sh_c 'setsignstatus off' >/dev/null 2>&1 || true
            $sh_c 'setstatus softmode' >/dev/null 2>&1 || true
            $sh_c 'setstatus -f exectl off -p' >/dev/null 2>&1 || true
            $sh_c 'setstatus -f netctl off -p' >/dev/null 2>&1 || true
            $sh_c 'setstatus -f devctl off -p' >/dev/null 2>&1 || true
            $sh_c 'setstatus -f ipt off -p' >/dev/null 2>&1 || true
            $sh_c 'setstatus -f fpro off -p' >/dev/null 2>&1 || true
            $sh_c 'setstatus -f ppro off -p' >/dev/null 2>&1 || true
            $sh_c 'setstatus -f kmod off -p' >/dev/null 2>&1 || true
            $sh_c 'sed -i "s/kysec_exectl.*/kysec_exectl = 0/" /etc/kysec/kysec.conf' >/dev/null 2>&1 || true
            $sh_c 'sed -i "s/kysec_netctl.*/kysec_netctl = 0/" /etc/kysec/kysec.conf' >/dev/null 2>&1 || true
            $sh_c 'sed -i "s/kysec_devctl.*/kysec_devctl = 0/" /etc/kysec/kysec.conf' >/dev/null 2>&1 || true
            $sh_c 'sed -i "s/kysec_ipt.*/kysec_ipt = 0/" /etc/kysec/kysec.conf' >/dev/null 2>&1 || true
            $sh_c 'sed -i "s/kysec_fpro.*/kysec_fpro = 0/" /etc/kysec/kysec.conf' >/dev/null 2>&1 || true
            $sh_c 'sed -i "s/kysec_ppro.*/kysec_ppro = 0/" /etc/kysec/kysec.conf' >/dev/null 2>&1 || true
            $sh_c 'sed -i "s/kysec_kmodpro.*/kysec_kmodpro = 0/" /etc/kysec/kysec.conf' >/dev/null 2>&1 || true
        fi
        ;;
    uos)
        str="$VERSION_CODENAME"
        if [ "$str" != "eagle" ]; then
            printf "%b\n" "\033[31mOpenFDE: Sorry, the os codename \"$str\" is not supported. only eagle is supported.\033[0m" >&2
            exit 1
        fi
        ;;
    debian)
        str="$VERSION_CODENAME"
        if [ "$str" != "bookworm" ]; then
            printf "%b\n" "\033[31mOpenFDE: Sorry, the os codename \"$str\" is not supported. only bookworm is supported.\033[0m" >&2
            exit 1
        fi
        ;;
    *)
        printf "%b\n" "\033[31mOpenFDE: Sorry: The OS Distribution \"$lsb_dist\" is not supported! Only kylin, uos, deepin, ubuntu, and debian are supported.\033[0m" >&2
        exit 1
        ;;
esac

printf "%b\n" "\033[31mOpenFDE: start to install openfde\033[0m"

# === 6. Install deps and add repo ===
$sh_c 'apt update'
$sh_c 'apt-get install -y wget gpg'

TMP_KEY="/tmp/packages.openfde.gpg.$$"
trap 'rm -f "$TMP_KEY"' EXIT

if ! wget -qO- "$domain_name/keys/openfde.asc" | gpg --dearmor > "$TMP_KEY"; then
    printf "%b\n" "\033[31mError: Failed to download or process GPG key.\033[0m" >&2
    exit 1
fi

$sh_c "install -D -o root -g root -m 644 '$TMP_KEY' /etc/apt/keyrings/packages.openfde.gpg"

# === 7. Distribution-specific setup ===
deepin_should_reboot=0

case "$lsb_dist" in
    deepin)
        kernel_release="$(uname -r)"
        if [ "$kernel_release" != "6.6.71-arm64-desktop-hwe" ]; then
            printf "%b\n" "\033[31mOpenFDE: it's going to install the 6.6.71 kernel for OpenFDE.\033[0m"
            if ! $sh_c 'apt -y install linux-image-6.6.71-arm64-desktop-hwe'; then
                printf "%b\n" "\033[31mTips: install linux-image-6.6.71 failed\033[0m" >&2
                exit 100
            fi
            printf "%b\n" "\033[31m Tips: you should reboot now to apply the 6.6.71 kernel in order to install openfde. \033[0m"
            deepin_should_reboot=1
        fi

        if [ ! -e /sys/fs/cgroup/memory ]; then
            $sh_c 'sed -i "s/systemd.unified_cgroup_hierarchy=0//" /etc/default/grub' >/dev/null 2>&1 || true
            $sh_c 'sed -i "/GRUB_CMDLINE_LINUX_DEFAULT=\".*console/s/GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"systemd.unified_cgroup_hierarchy=0 /" /etc/default/grub'
            $sh_c 'update-grub'
            printf "%b\n" "\033[31m Tips: must reboot to apply unified cgroup hierarchy. \033[0m"
            deepin_should_reboot=1
        fi

        if [ "$deepin_should_reboot" -eq 1 ]; then
            printf "%b" "\033[31mOpenFDE: run $0 again to install OpenFDE after this reboot, reboot now [y]/n ? \033[0m"
            read -r choice
            if [ "$choice" != "n" ] && [ "$choice" != "no" ]; then
                $sh_c 'reboot'
            fi
            exit 0
        fi

        $sh_c "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.openfde.gpg] $domain_name/repos/$lsb_dist/ $VERSION_CODENAME main' | tee /etc/apt/sources.list.d/openfde.list > /dev/null"
        ;;

    ubuntu)
        $sh_c "apt -y install linux-modules-extra-$(uname -r)" || true
        if [ "$arch" = "x86_64" ]; then
            lsb_arch="${lsb_dist}_x86"
        else
            lsb_arch="$lsb_dist"
        fi
        $sh_c "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.openfde.gpg] $domain_name/repos/$lsb_arch/ $VERSION_CODENAME main' | tee /etc/apt/sources.list.d/openfde.list > /dev/null"
        ;;

    kylin)
        $sh_c "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.openfde.gpg] $domain_name/repos/$lsb_dist/ $PROJECT_CODENAME main' | tee /etc/apt/sources.list.d/openfde.list > /dev/null"
        ;;

    debian)
        $sh_c "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.openfde.gpg] $domain_name/repos/$lsb_dist/ $VERSION_CODENAME main' | tee /etc/apt/sources.list.d/openfde.list > /dev/null"
        ;;

    uos)
        $sh_c "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.openfde.gpg] $domain_name/repos/$lsb_dist/ $VERSION_CODENAME main' | tee /etc/apt/sources.list.d/openfde.list > /dev/null"
        $sh_c 'apt update'
        baseVer="$(uname -r | awk -F "-" '{print $1}')"
        if [ "$baseVer" = "4.19.0" ]; then
            $sh_c 'apt install -y fde-binder-dkms'
            if ! grep -q binder /proc/filesystems 2>/dev/null; then
                $sh_c 'rmmod binder_linux' >/dev/null 2>&1 || true
                if ! $sh_c 'modprobe binder_linux'; then
                    printf "%b\n" "\033[31mError: modprobe binder_linux failed\033[0m" >&2
                    exit 1
                fi
                $sh_c 'mkdir -p /dev/binderfs'
                $sh_c 'mount -t binder binder /dev/binderfs'
            fi
        fi
        ;;
esac

$sh_c 'apt update'

# === 8. Install GPU driver if X100 detected ===
if command_exists lspci; then
    if lspci | grep -q "X100.*GPU_DMA"; then
        if [ "$lsb_dist" = "kylin" ]; then
            baseVer="$(uname -r | awk -F "-" '{print $1}')"
            if [ "$baseVer" != "5.4.18" ]; then
                printf "%b\n" "\033[31mOpenFDE: Sorry, your kernel version $baseVer is not supported for now. You should upgrade kernel to 5.4.18-85 at least\033[0m" >&2
                exit 1
            fi
            branchVer="$(uname -r | awk -F "-" '{print $2}')"
            if [ "$branchVer" -lt 85 ] 2>/dev/null; then
                printf "%b\n" "\033[31mOpenFDE: Sorry, your kernel version $baseVer is not supported for now. You should upgrade kernel to 5.4.18-85 at least.\033[0m" >&2
                exit 1
            fi
        fi
        $sh_c 'apt install -y fdeion-dkms'
    fi
fi

# === 9. Install correct OpenFDE package ===
if [ "$lsb_dist" = "ubuntu" ]; then
    # Check if this is a 32-bit capable system (x86_64)
    if command_exists lscpu && lscpu | grep -qw "32-bit"; then
        # Remove conflicting packages
        if dpkg -l 2>/dev/null | grep -q "openfde-arm64.*Fusion Desktop Environment"; then
            printf "%b" "\033[31mOpenFDE: openfde-arm64 has been installed, it's going to uninstall it [y]/n? \033[0m"
            read -r choice
            if [ "$choice" != "n" ] && [ "$choice" != "no" ]; then
                $sh_c 'apt purge -y openfde-arm64'
            else
                exit 0
            fi
        fi
        $sh_c 'apt install -y openfde'
    else
        # ARM64 system or x86_64 without 32-bit support
        printf "%b" "\033[31mOpenFDE: Your cpu only supports 64bit, it's going to install openfde-arm64 only deb, [y]/n? \033[0m"
        read -r choice
        if [ "$choice" = "n" ] || [ "$choice" = "no" ]; then
            exit 0
        fi
        # Remove conflicting packages
        if dpkg -l 2>/dev/null | grep -v arm64 | grep -q "openfde.*Fusion Desktop Environment"; then
            printf "%b" "\033[31mOpenFDE: openfde has been installed, it's going to uninstall it [y]/n? \033[0m"
            read -r choice
            if [ "$choice" != "n" ] && [ "$choice" != "no" ]; then
                $sh_c 'apt purge -y openfde'
            else
                exit 0
            fi
        fi
        $sh_c 'apt install -y openfde-arm64'
    fi
else
    # All other distros: use openfde for the detected architecture
    $sh_c 'apt install -y openfde'
fi

# === 10. Post-install fixes ===
if [ "$lsb_dist" = "debian" ]; then
    if uname -a | grep -q "rpi-2712"; then
        $sh_c 'sed -i "/arm_64bit/a kernel=kernel8.img" /boot/firmware/config.txt'
        printf "%b\n" "\033[31m Tips: must reboot to apply kernel 8 after installing finished. \033[0m"
    fi
    if [ ! -e /sys/fs/cgroup/memory ]; then
        $sh_c 'sed -i "s/psi=1 cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 systemd.unified_cgroup_hierarchy=0//" /boot/firmware/cmdline.txt' >/dev/null 2>&1 || true
        $sh_c 'sed -i "1s/^/psi=1 cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 systemd.unified_cgroup_hierarchy=0 /" /boot/firmware/cmdline.txt'
        printf "%b\n" "\033[31m Tips: must reboot to make openfde available. \033[0m"
    fi
fi

if [ "$lsb_dist" = "deepin" ]; then
    $sh_c 'rm -f /usr/share/wayland-sessions/fde.desktop'
fi

if [ "$lsb_dist" = "uos" ]; then
    if command_exists lspci && lspci | grep -q "X100.*GPU_DMA"; then
        $sh_c 'rm -f /usr/share/wayland-sessions/fde.desktop'
    fi
fi

printf "%b\n" "\033[32mOpenFDE installation completed successfully!\033[0m"
printf "%b\n" "\033[33mPlease reboot your system to apply all changes.\033[0m"