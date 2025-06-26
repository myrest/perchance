# Perchance API Docker Makefile

.PHONY: help build run stop restart logs clean compose-up compose-down quick-start build-multi build-multi-load build-amd64 build-arm64 push-dockerhub push-existing

# 默認目標
.DEFAULT_GOAL := help

# 項目配置
IMAGE_NAME := perchance-api
CONTAINER_NAME := perchance-web-api
PORT := 8888

help: ## 顯示幫助信息
	@echo "Perchance API Docker 管理命令"
	@echo "============================="
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## 構建Docker鏡像
	@echo "🔨 構建Docker鏡像..."
	docker build -t $(IMAGE_NAME) .
	@echo "✅ 鏡像構建完成"

run: ## 運行Docker容器
	@echo "🚀 啟動Docker容器..."
	@docker stop $(CONTAINER_NAME) 2>/dev/null || true
	@docker rm $(CONTAINER_NAME) 2>/dev/null || true
	docker run -d \
		--name $(CONTAINER_NAME) \
		-p $(PORT):$(PORT) \
		--restart unless-stopped \
		$(IMAGE_NAME)
	@echo "✅ 容器啟動成功"
	@echo "📡 API服務: http://localhost:$(PORT)"
	@echo "📋 API文檔: http://localhost:$(PORT)/docs"

stop: ## 停止Docker容器
	@echo "🛑 停止容器..."
	docker stop $(CONTAINER_NAME) || true
	@echo "✅ 容器已停止"

restart: stop run ## 重啟Docker容器

logs: ## 查看容器日誌
	@echo "📋 顯示容器日誌..."
	docker logs -f $(CONTAINER_NAME)

clean: ## 清理Docker鏡像和容器
	@echo "🗑️ 清理容器和鏡像..."
	@docker stop $(CONTAINER_NAME) 2>/dev/null || true
	@docker rm $(CONTAINER_NAME) 2>/dev/null || true
	@docker rmi $(IMAGE_NAME) 2>/dev/null || true
	@echo "✅ 清理完成"

compose-up: ## 使用docker-compose啟動
	@echo "🐳 使用docker-compose啟動..."
	docker-compose up -d
	@echo "✅ 服務已啟動"
	@echo "📡 API服務: http://localhost:$(PORT)"

compose-down: ## 使用docker-compose停止
	@echo "🐳 使用docker-compose停止..."
	docker-compose down
	@echo "✅ 服務已停止"

quick-start: ## 快速啟動（構建+運行）
	@echo "🚀 快速啟動Perchance API..."
	@make build
	@make run
	@echo "🎉 快速啟動完成！"

status: ## 查看容器狀態
	@echo "📊 容器狀態:"
	@docker ps -a --filter name=$(CONTAINER_NAME) --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

health: ## 檢查服務健康狀態
	@echo "🔍 檢查服務健康狀態..."
	@curl -s http://localhost:$(PORT)/health | python -m json.tool || echo "❌ 服務未響應"

build-multi: ## 構建多平台鏡像 (AMD64 + ARM64)
	@echo "🔨 構建多平台鏡像..."
	./build-multiplatform.sh build-multi

build-multi-load: ## 構建多平台鏡像並載入本地版本
	@echo "🔨 構建多平台鏡像並載入本地版本..."
	./build-multiplatform.sh build-multi-load

build-amd64: ## 構建AMD64平台鏡像
	@echo "🔨 構建AMD64平台鏡像..."
	./build-multiplatform.sh build-amd64

build-arm64: ## 構建ARM64平台鏡像
	@echo "🔨 構建ARM64平台鏡像..."
	./build-multiplatform.sh build-arm64

push-dockerhub: ## 構建並推送多平台鏡像到Docker Hub
	@echo "🚀 推送到Docker Hub..."
	./build-multiplatform.sh push-multi

push-existing: ## 推送已構建的鏡像到Docker Hub
	@echo "📤 推送已構建的鏡像..."
	./build-multiplatform.sh push-existing
