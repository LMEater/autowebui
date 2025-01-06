#!/bin/bash
set -e

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")"
ROOT_DIR="$(dirname "$(dirname "$APP_DIR")")"

# 加载应用配置
if [ -f "$APP_DIR/config/settings.sh" ]; then
    source "$APP_DIR/config/settings.sh"
fi

# 加载工具函数
source "$ROOT_DIR/lib/utils/logger.sh"

# 开始安装
log_info "开始安装应用..."

# 提示先自行修改配置
echo "本脚本仅支持在 $PLATFORM_NAME 平台运行"
echo "请先自行修改配置文件 $APP_DIR/config/settings.sh"

# read -p "按回车键继续..."

# 创建虚拟环境
if [ ! -d "$VENV_DIR/$VENV_NAME" ]; then
    log_info "创建虚拟环境..."
    conda create -n $VENV_NAME python=$PYTHON_VERSION pip ffmpeg -y
    log_success "虚拟环境创建成功"
else
    log_info "虚拟环境已存在，是否覆盖？(y/n)"
    read -p "请输入选项: " choice
    if [ "$choice" == "y" ]; then
        rm -rf "$VENV_DIR/$VENV_NAME"
        conda create -n $VENV_NAME python=$PYTHON_VERSION pip ffmpeg -y
        log_success "虚拟环境创建成功"
    else
        log_info "虚拟环境已存在"
    fi
fi

# 激活虚拟环境，如果已经激活则继续运行脚本
if ! conda activate $VENV_NAME; then
    log_info "虚拟环境已激活,当前环境为: $VENV_NAME"
fi

# 示例：创建必要的目录
log_info "创建必要的目录..."
mkdir -p "$APP_DIR/data"
mkdir -p "$APP_DIR/logs"
mkdir -p "$APP_DIR/config"

# 安装依赖
log_info "安装依赖..."
if [ -f "$APP_DIR/requirements.txt" ]; then
    pip install -r "$APP_DIR/requirements.txt"
fi
# pip install torch==2.4.0 torchvision==0.19.0 torchaudio==2.4.0 -i https://mirrors.aliyun.com/pypi/simple

log_info "开始安装 open-webui..."
# 安装或更新 open-webui
pip uninstall open-webui -y
pip install --upgrade open-webui

if pip list | grep -q "open-webui"; then
    version=$(pip list | grep "open-webui" | awk '{print $2}')
    log_success "open-webui 安装成功，版本: $version"
    touch "$APP_DIR/.installed"
else
    log_error "open-webui 安装失败"
fi

# 将配置中的主要内容及启动命令、虚拟环境名称及如何启动虚拟环境及其它必要信息写入使用说明
echo "配置文件: $APP_DIR/config/settings.sh" > "$WORKSPACE_DIR/$APP_NAME使用说明.md"
echo "虚拟环境名称: $VENV_NAME" >> "$WORKSPACE_DIR/$APP_NAME使用说明.md"
echo "启动说明: " >> "$WORKSPACE_DIR/$APP_NAME使用说明.md"
echo "先运行命令启动虚拟环境: conda activate $VENV_NAME" >> "$WORKSPACE_DIR/$APP_NAME使用说明.md"
echo "再运行命令启动 $APP_NAME: export HF_ENDPOINT=https://hf-mirror.com && $run_cmd" >> "$WORKSPACE_DIR/$APP_NAME使用说明.md"
echo "访问地址: http://<host>:$APP_PORT" >> "$WORKSPACE_DIR/$APP_NAME使用说明.md"
echo "=============================="
log_success "$APP_NAME 安装完成！"
log_info "详细使用说明查看 $WORKSPACE_DIR/$APP_NAME使用说明.md 中，请自行查看"
echo "=============================="


# 运行应用
log_warning "需要你自行使用内网穿透工具将 $APP_PORT 端口映射到公网"
log_info "以便查看并使用 $APP_NAME 服务。可以新建命令行终端来运行以下命令进行测试:"
log_info "ssh -p 443 -R0:127.0.0.1:${PORT} a.pinggy.io"
echo "=============================="
read -p "是否现在运行 $APP_NAME? (y/n): " choice
echo "=============================="
if [ "$choice" == "y" ]; then
    export HF_ENDPOINT=https://hf-mirror.com && eval $run_cmd
fi
