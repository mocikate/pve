# 更新日志

2023.05.29 

- 增加自动写入NOTE的功能，开出的容器和虚拟机将自带对应的配置信息，不用再在命令行中使用cat查看了(但原有的配置信息文件还将存在，否则无法使用批量命令批量创建)

2023.05.20

- 增加支持开设的虚拟机和容器可自定义开设在挂载盘还是系统盘，默认留空使用系统盘local

2023.04.24 

- 更新支持国内腾讯云阿里云的Debian系安装PVE和开设LXC容器，由于国内机器非独服基本不开嵌套虚拟化支持，所以只能开LXC
- 更新支持创建vmbr0，母鸡允许addr和gateway为内网IP或外网IP，已自动识别替换

2023.04.23

- 支持一键生成LXC或KVM虚拟化的NAT服务器
- 支持批量开设，多次运行批量开设LXC或KVM虚拟化的NAT服务器，重复运行继承配置
- 开出的容器和虚拟机都自带IPV4内外网端口转发

2023.04.11 

- 更新支持一键生成单个KVM虚拟化的NAT服务器(自带内外网映射)
- 更新PVE自修改qcow2文件，已预开启安装cloudinit，开启SSH登陆，预设值SSH监听V4和V6的22端口，开启允许密码验证登陆，开启允许ROOT登陆

2023.04.04

- 开发了基于PVE的 [ConvoyPanel](https://github.com/ConvoyPanel/panel) 一键安装脚本
- PVE一键安装是ConvoyPanel一键安装的前提，创建NAT网关不是
- 修复PVE在VPS上一键安装可能遇到的各种BUG