#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")"
ROOT_DIR="$(dirname "$(dirname "$APP_DIR")")"

source "$ROOT_DIR/lib/utils/logger.sh"

# 测试配置文件
test_config() {
    log_info "测试配置文件..."
    if [ ! -f "$APP_DIR/config/settings.yaml" ]; then
        log_error "配置文件不存在"
        return 1
    fi
    return 0
}

# 测试依赖项
test_dependencies() {
    log_info "测试依赖项..."
    if [ ! -f "$APP_DIR/requirements.txt" ]; then
        log_error "依赖文件不存在"
        return 1
    fi
    
    # 检查Python包
    while read -r package; do
        if [[ $package =~ ^#.*$ ]] || [ -z "$package" ]; then
            continue
        fi
        package_name="${package%%[>=<]*}"
        if ! pip3 list | grep -i "^$package_name" > /dev/null; then
            log_error "缺少Python包：$package_name"
            return 1
        fi
    done < "$APP_DIR/requirements.txt"
    
    return 0
}

# 测试目录结构
test_directories() {
    log_info "测试目录结构..."
    local required_dirs=("data" "logs" "config" "scripts")
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$APP_DIR/$dir" ]; then
            log_error "目录不存在：$dir"
            return 1
        fi
    done
    
    return 0
}

# 运行所有测试
run_all_tests() {
    local failed=0
    
    test_config || failed=1
    test_dependencies || failed=1
    test_directories || failed=1
    
    if [ $failed -eq 0 ]; then
        log_success "所有测试通过！"
        return 0
    else
        log_error "测试失败！"
        return 1
    fi
}

# 执行测试
run_all_tests
