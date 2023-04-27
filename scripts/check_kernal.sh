#!/bin/bash
#from https://github.com/spiritLHLS/pve

# 用颜色输出信息
_red() { echo -e "\033[31m\033[01m$@\033[0m"; }
_green() { echo -e "\033[32m\033[01m$@\033[0m"; }
_yellow() { echo -e "\033[33m\033[01m$@\033[0m"; }
_blue() { echo -e "\033[36m\033[01m$@\033[0m"; }
reading(){ read -rp "$(_green "$1")" "$2"; }
if [[ -d "/usr/share/locale/en_US.UTF-8" ]]; then
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
  export LANGUAGE=en_US.UTF-8
else
  export LANG=C.UTF-8
  export LC_ALL=C.UTF-8
  export LANGUAGE=C.UTF-8
fi


# 检查CPU是否支持硬件虚拟化
if [ "$(egrep -c '(vmx|svm)' /proc/cpuinfo)" -eq 0 ]; then
    _yellow "CPU不支持硬件虚拟化，无法嵌套虚拟化KVM服务器，但可以开LXC服务器(CT)"
    exit 1
else
    _green "本机CPU支持KVM硬件嵌套虚拟化"
fi

# 检查虚拟化选项是否启用
if [ "$(grep -E -c '(vmx|svm)' /proc/cpuinfo)" -eq 0 ]; then
    _yellow "BIOS中未启用硬件虚拟化，无法嵌套虚拟化KVM服务器，但可以开LXC服务器(CT)"
    exit 1
else
    _green "本机BIOS支持KVM硬件嵌套虚拟化"
fi

# 查询系统是否支持
if [ -e "/sys/module/kvm_intel/parameters/nested" ] && [ "$(cat /sys/module/kvm_intel/parameters/nested | tr '[:upper:]' '[:lower:]')" = "y" ]; then
    if lsmod | grep -q kvm; then
        _green "本机系统支持KVM硬件嵌套虚拟化"
        _green "本机符合要求：可以使用PVE虚拟化KVM服务器，并可以在开出来的KVM服务器选项中开启KVM硬件虚拟化"
    else
        _yellow "KVM模块未加载，不能使用PVE虚拟化KVM服务器，但可以开LXC服务器(CT)"
    fi
else
    _yellow "本机操作系统不支持KVM硬件嵌套虚拟化，使用PVE虚拟化出来的KVM服务器不能在选项中开启KVM硬件虚拟化，记得在开出来的KVM服务器选项中关闭"
    exit 1
fi

# 如果KVM模块未加载，则加载KVM模块并将其添加到/etc/modules文件中
if ! lsmod | grep -q kvm; then
    _yellow "尝试加载KVM模块……"
    modprobe kvm
    echo "kvm" >> /etc/modules
    _green "KVM模块已加载并添加到 /etc/modules，可以尝试使用PVE虚拟化KVM服务器，也可以开LXC服务器(CT)"
fi

check_config(){
    # 检查CPU核心数
    cpu_cores=$(grep -c ^processor /proc/cpuinfo)
    if [ "$cpu_cores" -lt 2 ]; then
        _red "本机配置不满足最低要求：至少2核CPU"
        _red "本机配置无法安装PVE"
        return
    fi

    # 检查内存大小
    total_mem=$(free -m | awk '/^Mem:/{print $2}')
    if [ "$total_mem" -lt 2048 ]; then
        _red "本机配置不满足最低要求：至少2G内存"
        _red "本机配置无法安装PVE"
        return
    fi

    # 检查硬盘大小
    total_disk=$(df -h / | awk '/\//{print $2}')
    total_disk_num=$(echo $total_disk | sed 's/G//')
    if [ "$total_disk_num" -lt 20 ]; then
        _red "本机配置不满足最低要求：至少20G硬盘"
        _red "本机配置无法安装PVE"
        return
    fi

    _green "本机配置满足至少2核2G内存20G硬盘的最低要求"
}

check_config
