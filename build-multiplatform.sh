#!/bin/bash

# Perchance API 多平台Docker構建腳本
# 支援 AMD64 (x86_64) 和 ARM64 (Apple Silicon) 平台

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 項目配置
IMAGE_NAME="perchance-api"
REGISTRY_URL=""  # 如果要推送到Docker Hub，填入 "your-username/"，例如: "johndoe/"

# 動態設置registry URL的函數
set_registry_url() {
    if [ -z "$REGISTRY_URL" ]; then
        echo -e "${YELLOW}🔧 請設置Docker Hub用戶名...${NC}"
        echo -e "${BLUE}💡 注意: 請輸入用戶名，不是email地址${NC}"
        echo -e "${BLUE}💡 例如: 如果您的Docker Hub連結是 https://hub.docker.com/u/johndoe${NC}"
        echo -e "${BLUE}💡 那麼用戶名就是: johndoe${NC}"
        echo ""
        
        while true; do
            read -p "請輸入您的Docker Hub用戶名: " DOCKER_USERNAME
            
            if [ -z "$DOCKER_USERNAME" ]; then
                echo -e "${RED}❌ 用戶名不能為空${NC}"
                continue
            fi
            
            # 檢查用戶名格式 - 不能包含@符號
            if [[ "$DOCKER_USERNAME" =~ [@] ]]; then
                echo -e "${RED}❌ 用戶名不能包含 @ 符號，請輸入用戶名而非email地址${NC}"
                echo -e "${YELLOW}💡 您可以在 https://hub.docker.com/settings/general 查看您的用戶名${NC}"
                continue
            fi
            
            # 檢查用戶名格式 - Docker Hub用戶名規則
            if [[ ! "$DOCKER_USERNAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*[a-zA-Z0-9]$|^[a-zA-Z0-9]$ ]]; then
                echo -e "${RED}❌ 用戶名格式無效${NC}"
                echo -e "${YELLOW}💡 用戶名只能包含字母、數字、連字符和下劃線${NC}"
                echo -e "${YELLOW}💡 且不能以連字符或下劃線開頭或結尾${NC}"
                continue
            fi
            
            # 格式正確，跳出循環
            break
        done
        
        REGISTRY_URL="${DOCKER_USERNAME}/"
        echo -e "${GREEN}✅ Registry URL已設置為: ${REGISTRY_URL}${NC}"
        echo -e "${BLUE}💡 完整鏡像名稱將為: ${REGISTRY_URL}${IMAGE_NAME}:latest${NC}"
    fi
}

# 檢查Docker Hub登入狀態
check_docker_login() {
    echo -e "${YELLOW}🔐 檢查Docker Hub登入狀態...${NC}"
    
    if ! docker info 2>/dev/null | grep -q "Username:"; then
        echo -e "${RED}❌ 尚未登入Docker Hub${NC}"
        echo -e "${YELLOW}💡 請先執行以下命令登入:${NC}"
        echo -e "   ${GREEN}docker login${NC}"
        echo ""
        read -p "是否現在登入？(y/n): " login_now
        
        if [[ "$login_now" =~ ^[Yy]$ ]]; then
            docker login
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ 登入成功${NC}"
            else
                echo -e "${RED}❌ 登入失敗${NC}"
                exit 1
            fi
        else
            echo -e "${RED}❌ 需要登入Docker Hub才能推送鏡像${NC}"
            exit 1
        fi
    else
        LOGGED_USER=$(docker info 2>/dev/null | grep "Username:" | awk '{print $2}')
        echo -e "${GREEN}✅ 已登入Docker Hub，用戶: ${LOGGED_USER}${NC}"
    fi
}

# 顯示如何找到Docker Hub用戶名
show_dockerhub_help() {
    echo -e "${BLUE}🔍 如何找到您的Docker Hub用戶名:${NC}"
    echo ""
    echo -e "${YELLOW}方法1: 查看Docker Hub網站${NC}"
    echo "1. 訪問 https://hub.docker.com/"
    echo "2. 登入您的帳戶"
    echo "3. 點擊右上角的用戶頭像"
    echo "4. 用戶名顯示在下拉菜單中"
    echo ""
    echo -e "${YELLOW}方法2: 查看設置頁面${NC}"
    echo "1. 訪問 https://hub.docker.com/settings/general"
    echo "2. 'Username' 欄位顯示您的用戶名"
    echo ""
    echo -e "${YELLOW}方法3: 查看個人資料URL${NC}"
    echo "1. 您的個人資料URL格式為: https://hub.docker.com/u/您的用戶名"
    echo "2. URL中 /u/ 後面的部分就是您的用戶名"
    echo ""
    echo -e "${RED}注意: 用戶名不是email地址！${NC}"
    echo -e "${GREEN}範例: 如果URL是 https://hub.docker.com/u/johndoe，用戶名就是 johndoe${NC}"
}

# 顯示幫助信息
show_help() {
    echo -e "${BLUE}Perchance API 多平台Docker構建腳本${NC}"
    echo ""
    echo "用法: $0 [命令] [選項]"
    echo ""
    echo "命令:"
    echo -e "  ${GREEN}build-local${NC}    - 構建本地平台鏡像"
    echo -e "  ${GREEN}build-multi${NC}    - 構建多平台鏡像 (AMD64 + ARM64)"
    echo -e "  ${GREEN}build-multi-load${NC} - 構建多平台鏡像並載入本地平台版本"
    echo -e "  ${GREEN}build-amd64${NC}    - 只構建AMD64平台鏡像"
    echo -e "  ${GREEN}build-arm64${NC}    - 只構建ARM64平台鏡像"
    echo -e "  ${GREEN}setup-builder${NC}  - 設置Docker buildx構建器"
    echo -e "  ${GREEN}push-multi${NC}     - 構建並推送多平台鏡像到Docker Hub"
    echo -e "  ${GREEN}push-existing${NC}  - 推送已構建的多平台鏡像到Docker Hub"
    echo -e "  ${GREEN}dockerhub-help${NC} - 顯示如何找到Docker Hub用戶名"
    echo -e "  ${GREEN}list-platforms${NC} - 列出支援的平台"
    echo -e "  ${GREEN}help${NC}           - 顯示此幫助信息"
    echo ""
    echo "範例:"
    echo "  $0 build-multi           # 構建多平台鏡像"
    echo "  $0 build-multi-load      # 構建多平台鏡像並載入本地版本"
    echo "  $0 build-amd64           # 只構建AMD64版本"
    echo "  $0 push-multi            # 構建並推送到Docker Hub"
}

# 檢查Docker和buildx
check_prerequisites() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker未安裝${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Docker已安裝${NC}"
    
    # 檢查buildx插件
    if ! docker buildx version &> /dev/null; then
        echo -e "${RED}❌ Docker buildx插件未安裝或未啟用${NC}"
        echo -e "${YELLOW}💡 請升級到Docker Desktop 19.03+或安裝buildx插件${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Docker buildx已可用${NC}"
}

# 設置buildx構建器
setup_builder() {
    echo -e "${YELLOW}🔧 設置Docker buildx構建器...${NC}"
    
    # 創建新的構建器實例
    if ! docker buildx ls | grep -q "perchance-builder"; then
        docker buildx create --name perchance-builder --use
        echo -e "${GREEN}✅ 構建器 'perchance-builder' 已創建${NC}"
    else
        docker buildx use perchance-builder
        echo -e "${GREEN}✅ 使用現有構建器 'perchance-builder'${NC}"
    fi
    
    # 啟動構建器
    docker buildx inspect --bootstrap
    echo -e "${GREEN}✅ 構建器已啟動${NC}"
}

# 列出支援的平台
list_platforms() {
    echo -e "${BLUE}📋 支援的平台:${NC}"
    docker buildx ls | grep -A 10 "perchance-builder" || true
    echo ""
    echo -e "${YELLOW}常用平台:${NC}"
    echo "• linux/amd64   - Intel/AMD 64位處理器 (x86_64)"
    echo "• linux/arm64   - ARM 64位處理器 (Apple Silicon, ARM伺服器)"
    echo "• linux/arm/v7  - ARM 32位處理器 (Raspberry Pi等)"
}

# 構建本地平台鏡像
build_local() {
    echo -e "${YELLOW}🔨 構建本地平台鏡像...${NC}"
    docker build -t ${IMAGE_NAME}:latest .
    echo -e "${GREEN}✅ 本地平台鏡像構建完成${NC}"
}

# 構建多平台鏡像
build_multi() {
    check_prerequisites
    setup_builder
    
    echo -e "${YELLOW}🔨 構建多平台鏡像 (AMD64 + ARM64)...${NC}"
    echo -e "${BLUE}💡 注意: 多平台鏡像將儲存在buildx快取中，不會載入到本地Docker${NC}"
    
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        -t ${IMAGE_NAME}:latest \
        .
    
    echo -e "${GREEN}✅ 多平台鏡像構建完成${NC}"
    echo -e "${BLUE}💡 支援平台: AMD64, ARM64${NC}"
    echo -e "${YELLOW}📝 要在本地使用，請執行:${NC}"
    echo -e "   ${GREEN}./build-multiplatform.sh build-local${NC} (構建本地平台版本)"
    echo -e "   ${GREEN}docker run -p 8888:8888 ${IMAGE_NAME}:latest${NC} (直接運行)"
}

# 構建多平台鏡像並載入本地版本
build_multi_load() {
    check_prerequisites
    setup_builder
    
    echo -e "${YELLOW}🔨 構建多平台鏡像並載入本地平台版本...${NC}"
    
    # 先構建多平台鏡像
    echo -e "${BLUE}步驟1: 構建多平台鏡像...${NC}"
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        -t ${IMAGE_NAME}:multi \
        .
    
    # 然後構建並載入本地平台版本
    echo -e "${BLUE}步驟2: 構建並載入本地平台版本...${NC}"
    CURRENT_PLATFORM=$(docker version --format '{{.Server.Os}}/{{.Server.Arch}}')
    docker buildx build \
        --platform $CURRENT_PLATFORM \
        -t ${IMAGE_NAME}:latest \
        --load \
        .
    
    echo -e "${GREEN}✅ 多平台鏡像構建完成，本地版本已載入${NC}"
    echo -e "${BLUE}💡 多平台版本標籤: ${IMAGE_NAME}:multi${NC}"
    echo -e "${BLUE}💡 本地版本標籤: ${IMAGE_NAME}:latest${NC}"
    echo -e "${BLUE}💡 當前平台: $CURRENT_PLATFORM${NC}"
}

# 構建AMD64平台鏡像
build_amd64() {
    check_prerequisites
    setup_builder
    
    echo -e "${YELLOW}🔨 構建AMD64平台鏡像...${NC}"
    docker buildx build \
        --platform linux/amd64 \
        -t ${IMAGE_NAME}:amd64 \
        --load \
        .
    
    echo -e "${GREEN}✅ AMD64平台鏡像構建完成${NC}"
}

# 構建ARM64平台鏡像
build_arm64() {
    check_prerequisites
    setup_builder
    
    echo -e "${YELLOW}🔨 構建ARM64平台鏡像...${NC}"
    docker buildx build \
        --platform linux/arm64 \
        -t ${IMAGE_NAME}:arm64 \
        --load \
        .
    
    echo -e "${GREEN}✅ ARM64平台鏡像構建完成${NC}"
}

# 構建並推送多平台鏡像
push_multi() {
    check_docker_login
    set_registry_url
    
    check_prerequisites
    setup_builder
    
    echo -e "${YELLOW}🚀 構建並推送多平台鏡像到Docker Hub...${NC}"
    echo -e "${BLUE}💡 目標: ${REGISTRY_URL}${IMAGE_NAME}:latest${NC}"
    
    # 再次確認推送目標
    echo ""
    echo -e "${BLUE}📋 推送摘要:${NC}"
    echo -e "   鏡像名稱: ${REGISTRY_URL}${IMAGE_NAME}:latest"
    echo -e "   支援平台: linux/amd64, linux/arm64"
    echo -e "   Docker Hub連結: https://hub.docker.com/r/${REGISTRY_URL%/}/${IMAGE_NAME}"
    echo ""
    
    read -p "確認推送？(y/n): " confirm_push
    if [[ ! "$confirm_push" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}⏹️  取消推送${NC}"
        exit 0
    fi
    
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        -t ${REGISTRY_URL}${IMAGE_NAME}:latest \
        --push \
        .
    
    echo -e "${GREEN}✅ 多平台鏡像已推送到Docker Hub${NC}"
    echo -e "${BLUE}🔗 Docker Hub連結: https://hub.docker.com/r/${REGISTRY_URL%/}/${IMAGE_NAME}${NC}"
}

# 推送已構建的鏡像
push_existing() {
    check_docker_login
    set_registry_url
    
    echo -e "${YELLOW}🏷️  為現有鏡像打標籤並推送到Docker Hub...${NC}"
    
    # 檢查本地是否有鏡像
    if ! docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "${IMAGE_NAME}:latest"; then
        echo -e "${RED}❌ 本地未找到 ${IMAGE_NAME}:latest 鏡像${NC}"
        echo -e "${YELLOW}💡 請先執行構建命令:${NC}"
        echo -e "   ${GREEN}./build-multiplatform.sh build-local${NC}"
        exit 1
    fi
    
    # 為鏡像打標籤
    echo -e "${BLUE}🏷️  為鏡像打標籤...${NC}"
    docker tag ${IMAGE_NAME}:latest ${REGISTRY_URL}${IMAGE_NAME}:latest
    
    # 推送鏡像
    echo -e "${BLUE}📤 推送鏡像到Docker Hub...${NC}"
    docker push ${REGISTRY_URL}${IMAGE_NAME}:latest
    
    echo -e "${GREEN}✅ 鏡像已推送到Docker Hub${NC}"
    echo -e "${BLUE}🔗 Docker Hub連結: https://hub.docker.com/r/${REGISTRY_URL}${IMAGE_NAME}${NC}"
}

# 主邏輯
case "${1:-help}" in
    build-local)
        build_local
        ;;
    build-multi)
        build_multi
        ;;
    build-multi-load)
        build_multi_load
        ;;
    build-amd64)
        build_amd64
        ;;
    build-arm64)
        build_arm64
        ;;
    setup-builder)
        check_prerequisites
        setup_builder
        ;;
    push-multi)
        push_multi
        ;;
    push-existing)
        push_existing
        ;;
    dockerhub-help)
        show_dockerhub_help
        ;;
    list-platforms)
        list_platforms
        ;;
    help|*)
        show_help
        ;;
esac

echo ""
echo -e "${BLUE}🎉 操作完成！${NC}"
