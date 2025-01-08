#!/bin/bash

# 更新包列表
apt-get update

# 安装sudo
apt-get install -y sudo

# 将当前用户添加到sudo组（需要root权限）
if [ "$(whoami)" == "root" ]; then
    CURRENT_USER=$(logname)
    usermod -aG sudo $CURRENT_USER
    echo "已将用户 $CURRENT_USER 添加到sudo组"
else
    echo "请使用root用户运行此脚本以配置sudo权限"
fi

echo "sudo安装完成！请重新登录以使更改生效"
