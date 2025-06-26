#!/bin/bash

# Perchance API 快速啟動腳本
echo "🚀 Perchance API Docker 快速啟動"
echo "=================================="

# 檢查Docker是否安裝
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安裝，請先安裝Docker"
    exit 1
fi

echo "✅ Docker已安裝"

# 構建鏡像
echo "🔨 正在構建Docker鏡像..."
docker build -t perchance-api .

if [ $? -eq 0 ]; then
    echo "✅ 鏡像構建成功"
else
    echo "❌ 鏡像構建失敗"
    exit 1
fi

# 停止現有容器（如果存在）
echo "🛑 檢查現有容器..."
if docker ps -q -f name=perchance-web-api | grep -q .; then
    echo "🛑 停止現有容器..."
    docker stop perchance-web-api
fi

if docker ps -a -q -f name=perchance-web-api | grep -q .; then
    echo "🗑️ 刪除現有容器..."
    docker rm perchance-web-api
fi

# 啟動新容器
echo "🚀 啟動新容器..."
docker run -d \
    --name perchance-web-api \
    -p 8888:8888 \
    --restart unless-stopped \
    perchance-api

if [ $? -eq 0 ]; then
    echo "✅ 容器啟動成功！"
    echo ""
    echo "📡 API服務正在運行於: http://localhost:8888"
    echo "📋 API文檔: http://localhost:8888/docs"
    echo "🔍 健康檢查: http://localhost:8888/health"
    echo ""
    echo "💡 常用命令:"
    echo "   查看日誌: docker logs -f perchance-web-api"
    echo "   停止服務: docker stop perchance-web-api"
    echo "   重啟服務: docker restart perchance-web-api"
    echo ""
    echo "🎉 部署完成！"
else
    echo "❌ 容器啟動失敗"
    exit 1
fi
