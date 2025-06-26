# Perchance API Docker 部署指南

這個文檔說明如何使用Docker來構建和部署Perchance API服務。

## 📋 目錄

- [前置需求](#前置需求)
- [快速開始](#快速開始)
- [Docker構建選項](#docker構建選項)
- [使用Docker Compose](#使用docker-compose)
- [管理腳本](#管理腳本)
- [故障排除](#故障排除)

## 🔧 前置需求

確保您的系統已安裝以下軟體：

- [Docker](https://docs.docker.com/get-docker/) (版本 20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (可選，用於簡化部署)

## 🚀 快速開始

### 方法一：使用管理腳本（推薦）

我們提供了一個便捷的管理腳本來簡化Docker操作：

```bash
# 構建Docker鏡像
./docker-build.sh build

# 運行容器
./docker-build.sh run

# 查看日誌
./docker-build.sh logs

# 停止容器
./docker-build.sh stop

# 查看所有可用命令
./docker-build.sh help
```

### 方法二：使用Docker Compose

```bash
# 啟動服務
docker-compose up -d

# 查看日誌
docker-compose logs -f

# 停止服務
docker-compose down
```

### 方法三：手動Docker命令

```bash
# 構建鏡像
docker build -t perchance-api .

# 運行容器
docker run -d \
  --name perchance-web-api \
  -p 8888:8888 \
  --restart unless-stopped \
  perchance-api

# 查看日誌
docker logs -f perchance-web-api
```

## 🌐 訪問API

服務啟動後，您可以通過以下URL訪問：

- **API服務**: http://localhost:8888
- **API文檔**: http://localhost:8888/docs
- **健康檢查**: http://localhost:8888/health

## 🐳 Docker構建選項

### 基本構建

```bash
docker build -t perchance-api .
```

### 指定構建參數

```bash
# 使用特定Python版本
docker build --build-arg PYTHON_VERSION=3.11 -t perchance-api .

# 不使用緩存重新構建
docker build --no-cache -t perchance-api .
```

## 📊 使用Docker Compose

`docker-compose.yml` 文件提供了完整的服務配置：

```yaml
version: '3.8'

services:
  perchance-api:
    build: .
    container_name: perchance-web-api
    ports:
      - "8888:8888"
    environment:
      - PYTHONPATH=/app
      - PYTHONUNBUFFERED=1
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "python", "-c", "import requests; requests.get('http://localhost:8888/health')"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### 常用Docker Compose命令

```bash
# 啟動服務（後台運行）
docker-compose up -d

# 查看運行狀態
docker-compose ps

# 查看實時日誌
docker-compose logs -f

# 重啟服務
docker-compose restart

# 停止並刪除容器
docker-compose down

# 停止並刪除容器、網路、卷
docker-compose down -v
```

## 🛠️ 管理腳本

`docker-build.sh` 腳本提供了以下命令：

| 命令 | 描述 |
|------|------|
| `build` | 構建Docker鏡像 |
| `run` | 運行Docker容器 |
| `stop` | 停止Docker容器 |
| `restart` | 重啟Docker容器 |
| `logs` | 查看容器日誌 |
| `clean` | 清理Docker鏡像和容器 |
| `compose` | 使用docker-compose啟動 |
| `help` | 顯示幫助信息 |

### 使用範例

```bash
# 完整的部署流程
./docker-build.sh build    # 構建鏡像
./docker-build.sh run      # 運行容器
./docker-build.sh logs     # 查看日誌

# 更新部署
./docker-build.sh stop     # 停止舊容器
./docker-build.sh build    # 重新構建鏡像
./docker-build.sh run      # 運行新容器

# 清理環境
./docker-build.sh clean    # 完全清理
```

## 🔍 故障排除

### 常見問題

#### 1. 端口已被占用

```bash
Error: bind: address already in use
```

**解決方案**：
- 檢查是否有其他服務占用8888端口
- 更改docker-compose.yml中的端口映射
- 使用 `lsof -i :8888` 查看端口占用情況

#### 2. Docker構建失敗

```bash
Error: failed to build
```

**解決方案**：
- 檢查Dockerfile語法
- 確保所有依賴文件存在
- 使用 `--no-cache` 重新構建

#### 3. 容器啟動失敗

```bash
Error: container exits immediately
```

**解決方案**：
- 查看容器日誌：`docker logs perchance-web-api`
- 檢查Python依賴是否正確安裝
- 驗證start_api.py是否可執行

#### 4. 健康檢查失敗

```bash
Status: unhealthy
```

**解決方案**：
- 檢查API服務是否正常啟動
- 驗證健康檢查端點：`curl http://localhost:8888/health`
- 查看詳細日誌找出問題原因

### 調試命令

```bash
# 進入運行中的容器
docker exec -it perchance-web-api bash

# 查看容器詳細信息
docker inspect perchance-web-api

# 查看實時資源使用
docker stats perchance-web-api

# 檢查網絡連接
docker network ls
```

### 日誌分析

```bash
# 查看最近100行日誌
docker logs --tail 100 perchance-web-api

# 查看特定時間範圍的日誌
docker logs --since "2024-01-01T00:00:00" perchance-web-api

# 追蹤實時日誌
docker logs -f perchance-web-api
```

## 🔧 自定義配置

### 環境變數

您可以通過環境變數來自定義配置：

```bash
# 在docker run中指定
docker run -d \
  --name perchance-web-api \
  -p 8888:8888 \
  -e PYTHONPATH=/app \
  -e CUSTOM_VAR=value \
  perchance-api
```

### 持久化數據

如果需要持久化日誌或其他數據：

```yaml
services:
  perchance-api:
    # ...其他配置
    volumes:
      - ./logs:/app/logs
      - ./data:/app/data
```

## 📝 生產環境建議

1. **使用具體的版本標籤**而不是`latest`
2. **配置適當的資源限制**
3. **設置健康檢查和重啟策略**
4. **使用環境變數管理敏感配置**
5. **定期備份重要數據**
6. **監控容器運行狀態和資源使用**

## 📞 支援

如果遇到問題，請：

1. 查看本文檔的故障排除部分
2. 檢查Docker和應用程式日誌
3. 確認所有前置需求已滿足
4. 在GitHub issues中提出問題
