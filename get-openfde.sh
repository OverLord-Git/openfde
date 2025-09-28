#!/bin/sh
# OpenFDE for Linux installation script.
#
# This script is intended as a convenient way to configure openfde's package
# repositories and to install Openfde, This script is not recommended
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
#
#
# Usage
# ==============================================================================
#
# To install the latest stable versions of Openfde, and its
# dependencies:
#
# 1. download the script
#
#   $ curl -fsSL https://openfde.com/getopenfde/get-openfde.sh -o get-openfde.sh
#
# 2. verify the script's content
#
#   $ cat get-openfde.sh
#
# 3. run the script either as root, or using sudo to perform the installation.
#
#   $ sudo sh get-openfde.sh
#
command_exists() {
	command -v "$@" > /dev/null 2>&1
}
sh_c='sh'
if [ "$user" != 'root' ]; then
	if command_exists sudo; then
		sh_c='sudo'
	elif command_exists su; then
		sh_c='su'
	else
		cat >&2 <<-'EOF'
		Error: this installer needs the ability to run commands as root.
		We are unable to find either "sudo" or "su" available to make this happen.
		EOF
		exit 1
	fi
fi

unsupported="nvidia ftv310"
supported="i915 amdgpu radeon panfrost msm vc4 v3d virtio-pci pvrsrvkm ftg340 nouveau jmgpu"

get_kernel_driver() {
	local dev="$1"
	grep '^DRIVER=' "/sys/class/drm/${dev}/device/uevent" 2>/dev/null | cut -d'=' -f2
}

for render_node in /dev/dri/renderD*; do
	render_dev=$(basename "$render_node")
	driver=$(get_kernel_driver "$render_dev")
	if [ -n "$driver" ]; then
		for unsup in $unsupported; do
			if [ "$driver" = "$unsup" ]; then
				echo -e "\033[31mOpenFDE: GPU driver \"$driver\" is not supported.\033[0m"
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
		if [ $found_supported -eq 0 ]; then
			echo -e "\033[31mOpenFDE: GPU driver \"$driver\" is not supported.\033[0m"
			exit 1
		fi
	fi
done

lsb_dist="$(. /etc/os-release && echo "$ID")"

arch=`uname -m` 
if [ "$arch" != "aarch64" ];then
	if [ "$lsb_dist" = "ubuntu" ];then
		if [ "$arch" != "x86_64" ];then
			echo -e "\033[31mOpenFDE: Sorry, the architecture \"$arch\" is not supported, only aarch64 and x86_64 are supported. \033[0m"
			exit 1
		fi
	else
		echo -e "\033[31mOpenFDE: Sorry, the architecture \"$arch\" is not supported, only aarch64 is supported. \033[0m"
		exit 1
	fi
fi
domain_name="https://openfde.com"
case "$lsb_dist" in
	deepin)
		str="$(. /etc/os-release && echo "$VERSION_CODENAME")"
		if [ $str != "beige" ]; then
			echo -e "\033[31mOpenFDE: Sorry, the os codename \"$str\" is not supported. Only beige(23) is supported. \033[0m"
			exit 1;
		fi
	;;
	ubuntu)
		str="$(. /etc/os-release && echo "$VERSION_CODENAME")"
		if [ $str != "jammy" -a "$str" != "noble" ]; then
			echo -e "\033[31mOpenFDE: Sorry, the os codename \"$str\" is not supported. Only jammy(22.04) and noble(24.04) are supported.\033[0m"
			exit 1;
		fi
	;;
	kylin)
		str="$(. /etc/os-release && echo "$PROJECT_CODENAME")"
		if [ $str != "V10SP1" ]; then
			echo -e "\033[31mOpenFDE: Sorry, the os codename \"$str\" is not supported. Only V10SP1 is supported.\033[0m"
			exit 1;
		fi
		exec_stat=`getstatus |grep exec -w |awk -F ":" '{print $2}' |tr -d " "`
		if [ "$exec_stat" != "off" ];then
			echo -e "\033[31mOpenFDE: Security Policy is enabled, need disable for installing OpenFDE y/n?.\033[0m"
			read choice
			if [ "$choice" = "n" -o "$choice" = "no" ];then
				echo -e "\033[31mOpenFDE: You choosed to exit the installation.\033[0m"
				exit 4
			fi
		fi
		$sh_c setsignstatus off 1>/dev/null 2>&1
		$sh_c setstatus softmode 1>/dev/null 2>&1
		$sh_c setstatus -f exectl off -p 1>/dev/null 2>&1
		$sh_c setstatus -f netctl off -p 1>/dev/null 2>&1
		$sh_c setstatus -f devctl off -p 1>/dev/null 2>&1
		$sh_c setstatus -f ipt off -p 1>/dev/null 2>&1
		$sh_c setstatus -f fpro off -p 1>/dev/null 2>&1
		$sh_c setstatus -f ppro off -p 1>/dev/null 2>&1
		$sh_c setstatus -f kmod off -p 1>/dev/null 2>&1
		$sh_c sed -i "s/kysec_exectl.*/kysec_exectl = 0/" /etc/kysec/kysec.conf 1>/dev/null 2>&1
		$sh_c sed -i "s/kysec_netctl.*/kysec_netctl = 0/" /etc/kysec/kysec.conf 1>/dev/null 2>&1
		$sh_c sed -i "s/kysec_devctl.*/kysec_devctl = 0/" /etc/kysec/kysec.conf 1>/dev/null 2>&1
		$sh_c sed -i "s/kysec_ipt.*/kysec_ipt = 0/" /etc/kysec/kysec.conf 1>/dev/null 2>&1
		$sh_c sed -i "s/kysec_fpro.*/kysec_fpro = 0/" /etc/kysec/kysec.conf 1>/dev/null 2>&1
		$sh_c sed -i "s/kysec_ppro.*/kysec_ppro = 0/" /etc/kysec/kysec.conf 1>/dev/null 2>&1
		$sh_c sed -i "s/kysec_kmodpro.*/kysec_kmodpro = 0/" /etc/kysec/kysec.conf 1>/dev/null 2>&1
	;;
	uos)
		str="$(. /etc/os-release && echo "$VERSION_CODENAME")"
		if [ $str != "eagle" ]; then
			$sh_c echo "Sorry, the os codename \"$str\" is not supported. only eagle is supported."
			exit 1;
		fi
	;;
	debian)
		str="$(. /etc/os-release && echo "$VERSION_CODENAME")"
		if [ $str != "bookworm" ]; then
			$sh_c echo "Sorry, the os codename \"$str\" is not supported. only bookworm is supported."
			exit 1;
		fi
	;;
	*)
		echo "Sorry: The OS Distribution \"$lsb_dist\" is not supported! Only kylin uos and ubuntu are supported."
		exit 1
	;;
esac


echo -e "\033[31mOpenFDE: start to install openfde\033[0m"

$sh_c apt update
$sh_c apt-get install wget gpg 
wget -qO- $domain_name/keys/openfde.asc | gpg --dearmor > packages.openfde.gpg
$sh_c install -D -o root -g root -m 644 packages.openfde.gpg /etc/apt/keyrings/packages.openfde.gpg
rm -f packages.openfde.gpg



case "$lsb_dist" in
	deepin)
		kernel_release=`uname -r`
		deepin_should_reboot=0
		if [ "$kernel_release" != "6.6.71-arm64-desktop-hwe" ];then
			echo -e "\033[31mOpenFDE: it's going to install the 6.6.71 kernel for OpenFDE.\033[0m"
			$sh_c apt  -y install linux-image-6.6.71-arm64-desktop-hwe
			if [ $? != 0 ];then
				echo "Tips: install linux-image-6.6.71 failed"
				exit 100
			fi
			echo -e "\033[31m Tips: you should reboot now to apply the 6.6.71 kernel in order to install openfde. \033[0m"
			deepin_should_reboot=1
		fi
		if [ ! -e /sys/fs/cgroup/memory ];then
			$sh_c sed -i "s/systemd.unified_cgroup_hierarchy=0//" /etc/default/grub 1>/dev/null 2>&1
			$sh_c sed -i "/GRUB_CMDLINE_LINUX_DEFAULT=\".*console/s/GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"systemd.unified_cgroup_hierarchy=0 /" /etc/default/grub
			$sh_c update-grub
			echo -e "\033[31m Tips: must reboot to apply unified cgroup hierarchy. \033[0m"
			deepin_should_reboot=1
		fi
		if [ $deepin_should_reboot -eq 1 ];then
			echo -e "\033[31mOpenFDE: run $0 again to install OpenFDE after this reboot, reboot now [y]/n ? \033[0m"
			read choice 
			if [ "$choice" != "n"  -a "$choice" != "no" ];then
				$sh_c reboot
			fi
			exit 0
		fi

		$sh_c echo \
		"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/packages.openfde.gpg] $domain_name/repos/$lsb_dist/ \
		"$(. /etc/os-release && echo "$VERSION_CODENAME")" main" | \
		$sh_c tee /etc/apt/sources.list.d/openfde.list > /dev/null
	;;
	ubuntu)
		$sh_c apt  -y install linux-modules-extra-`uname -r`
		if [ "$arch" = "x86_64" ];then
			lsb_arch=${lsb_dist}_x86
		else
			lsb_arch=$lsb_dist
		fi
		$sh_c echo \
		"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/packages.openfde.gpg] $domain_name/repos/$lsb_arch/ \
		"$(. /etc/os-release && echo "$VERSION_CODENAME")" main" | \
		$sh_c tee /etc/apt/sources.list.d/openfde.list > /dev/null
	;;
	kylin)
		$sh_c echo \
		"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/packages.openfde.gpg] $domain_name/repos/$lsb_dist/ \
		"$(. /etc/os-release && echo "$PROJECT_CODENAME")" main" | \
		$sh_c tee /etc/apt/sources.list.d/openfde.list > /dev/null
	;;
	debian)
		$sh_c echo \
		"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/packages.openfde.gpg] $domain_name/repos/$lsb_dist/ \
		"$(. /etc/os-release && echo "$VERSION_CODENAME")" main" | \
		$sh_c tee /etc/apt/sources.list.d/openfde.list > /dev/null
	;;
	uos)
		$sh_c echo \
		"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/packages.openfde.gpg] $domain_name/repos/$lsb_dist/ \
		"$(. /etc/os-release && echo "$VERSION_CODENAME")" main" | \
		$sh_c tee /etc/apt/sources.list.d/openfde.list > /dev/null

		$sh_c apt update
		baseVer=`uname -r |awk -F "-"  '{print $1}'`
		if [ $baseVer = "4.19.0" ];then
			$sh_c apt install -y fde-binder-dkms
			cat /proc/filesystems |grep binder 1>/dev/null 2>&1 
			if [ $? != 0 ];then
				$sh_c rmmod binder_linux 1>/dev/null 2>&1
				$sh_c modprobe binder_linux 1>/dev/null 2>&1
				if [ $? != 0 ];then
					echo "Error: modprobe binder_linux failed"
					exit 1
				fi
				$sh_c mkdir -p /dev/binderfs 1>/dev/null 2>&1
				$sh_c mount binder -t binder  /dev/binderfs 1>/dev/null 2>&1
			fi
		fi
	;;
esac

$sh_c apt update
lspci |grep X100 |grep GPU_DMA 1>/dev/null 2>&1
if [ $? = 0 ];then
	if [ "$lsb_dist" = "kylin" ];then
		baseVer=`uname -r |awk -F "-"  '{print $1}'`
		if [ "$baseVer" != "5.4.18" ];then
			echo -e "\033[31mOpenFDE: Sorry, your kernel version $baseVer is not supported for now. You should upgrade kernel to 5.4.18-85 at least\033[0m"	
			exit 1;
		fi
		branchVer=`uname -r |awk -F "-" '{print $2}'`
		if [ "$branchVer" -lt "85" ];then
			echo -e "\033[31mOpenFDE: Sorry, your kernel version $baseVer is not supported for now. You should upgrade kennel to 5.4.18-85 at least.\033[0m"	
			exit 1;
		fi
	fi
	$sh_c apt install fdeion-dkms
fi

#64bit only deb only support ubuntu 
if [ "$lsb_dist" = "ubuntu" ];then
	lscpu |grep 32-bit -w 1>/dev/null 2>&1
	if [ $? = 0 ];then
		sudo dpkg -l |grep openfde-arm64 -w |grep "Fusion Desktop Environment" 1>/dev/null 2>&1
		if [ $? = 0 ];then
			echo -e "\033[31mOpenFDE: openfde-arm64 has been installed, it's going to uninstall it [y]/n?. \033[0m"
			read choice
			if [ "$choice" = "n" -o "$choice" = "no" ];then
				exit 0
			fi
			$sh_c apt purge openfde-arm64 -y
		fi
		$sh_c apt install -y openfde
	else
		echo -e "\033[31mOpenFDE: Your cpu only support 64bit, it's going to install openfde-arm64 only deb, [y]/n?. \033[0m"
		read choice
		if [ "$choice" = "n" -o "$choice" = "no" ];then
			exit 0
		fi
		sudo dpkg -l |grep openfde -w |grep -v arm64 |grep "Fusion Desktop Environment" 1>/dev/null 2>&1
		if [ $? = 0 ];then
			echo -e "\033[31mOpenFDE: openfde has been installed, it's going to uninstall it [y]/n?. \033[0m"
			read choice
			if [ "$choice" = "n" -o "$choice" = "no" ];then
				exit 0
			fi
			$sh_c apt purge openfde -y
		fi
		$sh_c apt install -y openfde-arm64
	fi
else
	$sh_c apt install -y openfde
fi

if [ "$lsb_dist" = "debian" ];then
	uname -a |grep rpi-2712 1>/dev/null 
	if [ $? = 0 ];then
		$sh_c sed -i "/arm_64bit/a kernel=kernel8.img" /boot/firmware/config.txt
		echo -e "\033[31m Tips: must reboot to apply kernel 8 after installaing finished. \033[0m"
	fi
	if [ ! -e /sys/fs/cgroup/memory ];then
		$sh_c sed -i "s/psi=1 cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 systemd.unified_cgroup_hierarchy=0//" /boot/firmware/cmdline.txt
		$sh_c sed -i "s/^/psi=1 cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 systemd.unified_cgroup_hierarchy=0 /" /boot/firmware/cmdline.txt
		echo -e "\033[31m Tips: must reboot to make openfde available. \033[0m"
	fi
fi

if [ "$lsb_dist" = "deepin" ];then
	#deepin dont support mutter for any 
	$sh_c rm -rf /usr/share/wayland-sessions/fde.desktop
fi

if [ "$lsb_dist" = "uos" ];then
	lspci |grep X100 |grep GPU_DMA 1>/dev/null 2>&1
	if [ $? = 0 ];then
		#uos dont support mutter for x100
		$sh_c rm -rf /usr/share/wayland-sessions/fde.desktop
	fi
fi

