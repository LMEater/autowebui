#!/bin/bash

# 设置项目名称
project_name="openWebUI"

# 脚本信息
echo "================================================"
echo "描述: $project_name 主程序，用于管理 $project_name 的安装和配置"
echo "原作者: ai来事"
echo "原项目地址：https://github.com/aigem/aitools/"
echo "修改人：LMEater"
echo "由于在使用中，看到了原作者文本中的错误解决办法，原本是通过输入命令来进行解决，现已经修复这个问题"
echo "改版项目地址：https://github.com/LMEater/autowebui"
echo "如有问题，我相信你可以自行解决"

echo "================================================"

# 检查是否在 /workspace 目录下
if [ "$(pwd)" != "/workspace" ]; then
    echo "请在 /workspace 目录下运行此脚本"
    exit 1
fi

# 检查是否安装了git
if ! command -v git &> /dev/null; then
    echo "git 未安装，请先安装git"
    exit 1
fi

# 检查conda是否安装
if ! command -v conda &> /dev/null; then
    echo "conda 未安装，请先安装Anaconda或Miniconda"
    exit 1
fi

# 检查并激活conda环境
if ! conda activate ai_openWebUI &> /dev/null; then
    echo "正在创建ai_openWebUI环境..."
    conda create -n ai_openWebUI python=3.9 -y
    source activate ai_openWebUI
fi

# 安装/更新open-webui
echo "正在安装/更新open-webui..."
source activate ai_openWebUI && pip install --upgrade open-webui

# 克隆仓库(https://github.com/aigem/ai4u)
if [ ! -d "ai4u" ]; then
    echo "正在克隆 ai4u 仓库..."
    git clone https://gitee.com/fuliai/ai4u.git
else
    echo "ai4u 仓库已存在，正在更新..."
    cd ai4u
    git pull
    cd ..
fi

# 创建必要的目录
echo "创建必要的目录..."
mkdir -p ai4u/apps/$project_name/scripts

# 复制脚本文件
if [ -d "scripts" ]; then
    echo "复制安装脚本..."
    cp -r scripts/* ai4u/apps/$project_name/scripts/
else
    echo "错误：scripts 目录不存在"
    echo "请确保已获取正确的安装脚本并解压到 /workspace 目录下"
    echo "获取方式: https://gf.bilibili.com/item/detail/1107198073"
    exit 1
fi

# 检查必要文件是否存在
if [ ! -f "ai4u/apps/$project_name/scripts/install.sh" ]; then
    echo "错误：install.sh 文件不存在"
    echo "请确保已获取正确的安装脚本"
    echo "获取方式: https://gf.bilibili.com/item/detail/1107198073"
    exit 1
fi

# 设置执行权限
chmod +x ai4u/aitools.sh

# 进入 ai4u 目录并运行安装
cd ai4u
echo "开始安装 $project_name..."
bash aitools.sh install $project_name
