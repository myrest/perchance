#!/bin/bash

# Perchance Docker構建腳本
# 這個腳本用於構建和運行Perchance API的Docker容器

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 項目配置
IMAGE_NAME="perchance-api"
CONTAINER_NAME="perchance-web-api"
PORT="8888"

# 顯示幫助信息
show_help() {
    echo -e "${BLUE}Perchance API Docker 管理腳本${NC}"
    echo ""
    echo "用法: $0 [命令]"
    echo ""
    echo "命令:"
    echo -e "  ${GREEN}build${NC}     - 構建Docker鏡像"
    echo -e "  ${GREEN}run${NC}       - 運行Docker容器"
    echo -e "  ${GREEN}stop${NC}      - 停止Docker容器"
    echo -e "  ${GREEN}restart${NC}   - 重啟Docker容器"
    echo -e "  ${GREEN}logs${NC}      - 查看容器日誌"
    echo -e "  ${GREEN}clean${NC}     - 清理Docker鏡像和容器"
    echo -e "  ${GREEN}compose${NC}   - 使用docker-compose啟動"
    echo -e "  ${GREEN}help${NC}      - 顯示此幫助信息"
    echo ""
}

# 構建Docker鏡像
build_image() {
    echo -e "${YELLOW}🔨 正在構建Docker鏡像...${NC}"
    docker build -t $IMAGE_NAME .
    echo -e "${GREEN}✅ Docker鏡像構建完成！${NC}"
}

# 運行Docker容器
run_container() {
    echo -e "${YELLOW}🚀 正在啟動Docker容器...${NC}"
    
    # 檢查容器是否已經在運行
    if docker ps -q -f name=$CONTAINER_NAME | grep -q .; then
        echo -e "${RED}⚠️  容器 $CONTAINER_NAME 已經在運行${NC}"
        echo -e "${YELLOW}💡 使用 '$0 restart' 重新啟動容器${NC}"
        return 1
    fi
    
    # 檢查是否有同名的停止容器
    if docker ps -a -q -f name=$CONTAINER_NAME | grep -q .; then
        echo -e "${YELLOW}🗑️  刪除現有的停止容器...${NC}"
        docker rm $CONTAINER_NAME
    fi
    
    docker run -d \
        --name $CONTAINER_NAME \
        -p $PORT:$PORT \
        --restart unless-stopped \
        $IMAGE_NAME
    
    echo -e "${GREEN}✅ 容器啟動成功！${NC}"
    echo -e "${BLUE}📡 API服務正在運行於: http://localhost:$PORT${NC}"
    echo -e "${BLUE}📋 API文檔: http://localhost:$PORT/docs${NC}"
}

# 停止容器
stop_container() {
    echo -e "${YELLOW}🛑 正在停止容器...${NC}"
    if docker ps -q -f name=$CONTAINER_NAME | grep -q .; then
        docker stop $CONTAINER_NAME
        echo -e "${GREEN}✅ 容器已停止${NC}"
    else
        echo -e "${RED}⚠️  容器 $CONTAINER_NAME 未在運行${NC}"
    fi
}

# 重啟容器
restart_container() {
    echo -e "${YELLOW}🔄 正在重啟容器...${NC}"
    stop_container
    sleep 2
    run_container
}

# 查看日誌
show_logs() {
    echo -e "${YELLOW}📋 顯示容器日誌...${NC}"
    if docker ps -q -f name=$CONTAINER_NAME | grep -q .; then
        docker logs -f $CONTAINER_NAME
    else
        echo -e "${RED}⚠️  容器 $CONTAINER_NAME 未在運行${NC}"
    fi
}

# 清理
clean_up() {
    echo -e "${YELLOW}🗑️  正在清理...${NC}"
    
    # 停止並刪除容器
    if docker ps -a -q -f name=$CONTAINER_NAME | grep -q .; then
        docker stop $CONTAINER_NAME 2>/dev/null || true
        docker rm $CONTAINER_NAME
        echo -e "${GREEN}✅ 容器已刪除${NC}"
    fi
    
    # 刪除鏡像
    if docker images -q $IMAGE_NAME | grep -q .; then
        docker rmi $IMAGE_NAME
        echo -e "${GREEN}✅ 鏡像已刪除${NC}"
    fi
    
    echo -e "${GREEN}✅ 清理完成${NC}"
}

# 使用docker-compose
compose_up() {
    echo -e "${YELLOW}🐳 使用docker-compose啟動服務...${NC}"
    docker-compose up -d
    echo -e "${GREEN}✅ 服務已啟動！${NC}"
    echo -e "${BLUE}📡 API服務正在運行於: http://localhost:$PORT${NC}"
    echo -e "${BLUE}📋 API文檔: http://localhost:$PORT/docs${NC}"
}

# 主邏輯
case "${1:-help}" in
    build)
        build_image
        ;;
    run)
        run_container
        ;;
    stop)
        stop_container
        ;;
    restart)
        restart_container
        ;;
    logs)
        show_logs
        ;;
    clean)
        clean_up
        ;;
    compose)
        compose_up
        ;;
    help|*)
        show_help
        ;;
esac
