# 🌍 build-multiplatform.sh 使用指南

`build-multiplatform.sh` 是一個功能強大的多平台Docker構建腳本，專為Perchance API設計，支援AMD64和ARM64架構的跨平台部署。

## 📋 目錄

- [功能特色](#功能特色)
- [前置需求](#前置需求)
- [快速開始](#快速開始)
- [詳細命令說明](#詳細命令說明)
- [使用範例](#使用範例)
- [平台支援](#平台支援)
- [推送到Docker Hub](#推送到docker-hub)
- [故障排除](#故障排除)
- [最佳實踐](#最佳實踐)

## 🌟 功能特色

- ✅ **多平台支援** - 支援 AMD64 (x86_64) 和 ARM64 (Apple Silicon)
- ✅ **自動化構建** - 一鍵構建、測試、推送
- ✅ **智能平台檢測** - 自動檢測當前平台並優化構建
- ✅ **Docker Hub整合** - 內建推送到Docker Hub功能
- ✅ **友好的用戶界面** - 彩色輸出和詳細提示
- ✅ **錯誤處理** - 完善的前置檢查和錯誤處理
- ✅ **靈活配置** - 支援動態配置和環境變數

## 🔧 前置需求

### 軟體需求
- **Docker Desktop 19.03+** 或 **Docker Engine 19.03+**
- **Docker Buildx** 插件（通常內建於Docker Desktop）
- **Bash shell** (macOS、Linux、WSL)

### 權限需求
- Docker daemon執行權限
- 腳本執行權限：`chmod +x build-multiplatform.sh`

### 驗證安裝
```bash
# 檢查Docker版本
docker --version

# 檢查Buildx是否可用
docker buildx version

# 檢查當前平台
uname -m
```

## 🚀 快速開始

### 1. 賦予執行權限
```bash
chmod +x build-multiplatform.sh
```

### 2. 查看所有可用命令
```bash
./build-multiplatform.sh help
```

### 3. 最常用的使用場景

#### 開發環境 - 構建並載入本地版本
```bash
./build-multiplatform.sh build-multi-load
```

#### 生產環境 - 構建多平台鏡像
```bash
./build-multiplatform.sh build-multi
```

#### 發布到Docker Hub
```bash
./build-multiplatform.sh push-multi
```

## 📚 詳細命令說明

### 構建命令

#### `build-local`
構建適用於當前平台的Docker鏡像。

```bash
./build-multiplatform.sh build-local
```

**特點：**
- 最快的構建方式
- 只支援當前平台
- 自動載入到本地Docker
- 適合日常開發

**輸出：**
- 鏡像標籤：`perchance-api:latest`

---

#### `build-multi`
構建支援多平台的Docker鏡像（AMD64 + ARM64）。

```bash
./build-multiplatform.sh build-multi
```

**特點：**
- 支援跨平台部署
- 儲存在buildx快取中
- 不會載入到本地Docker
- 適合推送到registry

**輸出：**
- 多平台manifest
- 支援AMD64和ARM64

**注意：** 此命令構建的鏡像無法直接在本地運行，需要先推送到registry或使用 `build-multi-load`。

---

#### `build-multi-load`
構建多平台鏡像並同時載入當前平台版本到本地。

```bash
./build-multiplatform.sh build-multi-load
```

**特點：**
- 最佳的開發體驗
- 既有多平台支援又能本地使用
- 自動檢測當前平台

**輸出：**
- 多平台版本：`perchance-api:multi`
- 本地版本：`perchance-api:latest`

**適用場景：**
- 開發階段需要本地測試
- 同時需要多平台支援
- 準備推送前的驗證

---

#### `build-amd64`
只構建AMD64（x86_64）平台鏡像。

```bash
./build-multiplatform.sh build-amd64
```

**特點：**
- 針對Intel/AMD處理器
- 可載入到本地Docker
- 適合x86伺服器部署

**輸出：**
- 鏡像標籤：`perchance-api:amd64`

---

#### `build-arm64`
只構建ARM64（AArch64）平台鏡像。

```bash
./build-multiplatform.sh build-arm64
```

**特點：**
- 針對ARM處理器
- 可載入到本地Docker
- 適合Apple Silicon和ARM伺服器

**輸出：**
- 鏡像標籤：`perchance-api:arm64`

### 推送命令

#### `push-multi`
構建並推送多平台鏡像到Docker Hub。

```bash
./build-multiplatform.sh push-multi
```

**流程：**
1. 提示輸入Docker Hub用戶名（如未預設）
2. 檢查前置需求
3. 設置buildx構建器
4. 構建多平台鏡像
5. 推送到Docker Hub

**前置需求：**
```bash
docker login
```

---

#### `push-existing`
推送已構建的本地鏡像到Docker Hub。

```bash
./build-multiplatform.sh push-existing
```

**適用場景：**
- 已有本地鏡像需要分享
- 測試通過的鏡像需要發布
- 快速推送單平台版本

**注意：** 只能推送 `perchance-api:latest` 標籤的鏡像。

### 管理命令

#### `setup-builder`
手動設置Docker buildx構建器。

```bash
./build-multiplatform.sh setup-builder
```

**功能：**
- 創建名為 `perchance-builder` 的構建器
- 啟用多平台支援
- 啟動構建器實例

**使用場景：**
- 構建失敗時重置構建器
- 手動初始化構建環境

---

#### `list-platforms`
列出支援的平台和構建器狀態。

```bash
./build-multiplatform.sh list-platforms
```

**輸出內容：**
- 當前構建器配置
- 支援的平台列表
- 常用平台說明

## 💡 使用範例

### 場景一：開發階段
```bash
# 快速開始開發
./build-multiplatform.sh build-multi-load

# 運行容器測試
docker run -d --name dev-api -p 8888:8888 perchance-api:latest

# 查看日誌
docker logs -f dev-api

# 測試API
curl http://localhost:8888/health
```

### 場景二：準備發布
```bash
# 登入Docker Hub
docker login

# 構建並推送多平台鏡像
./build-multiplatform.sh push-multi
# 輸入您的Docker Hub用戶名: yourusername

# 驗證推送結果
docker buildx imagetools inspect yourusername/perchance-api:latest
```

### 場景三：跨平台測試
```bash
# 構建AMD64版本
./build-multiplatform.sh build-amd64

# 構建ARM64版本
./build-multiplatform.sh build-arm64

# 測試AMD64版本
docker run --platform linux/amd64 -p 8888:8888 perchance-api:amd64

# 測試ARM64版本
docker run --platform linux/arm64 -p 8889:8888 perchance-api:arm64
```

### 場景四：CI/CD整合
```bash
#!/bin/bash
# CI/CD pipeline script

# 設置環境
export DOCKER_USERNAME="your-username"

# 編輯腳本設置用戶名
sed -i 's/REGISTRY_URL=""/REGISTRY_URL="'$DOCKER_USERNAME'\/"/g' build-multiplatform.sh

# 構建並推送
./build-multiplatform.sh push-multi

# 驗證
docker buildx imagetools inspect $DOCKER_USERNAME/perchance-api:latest
```

## 🌍 平台支援

### 支援的平台

| 平台 | 架構 | 適用設備 | 標籤範例 |
|------|------|----------|----------|
| **linux/amd64** | x86_64 | Intel/AMD PC、伺服器 | `perchance-api:amd64` |
| **linux/arm64** | AArch64 | Apple Silicon、ARM伺服器 | `perchance-api:arm64` |
| **linux/arm/v7** | ARMv7 | Raspberry Pi 3/4 | `perchance-api:armv7` |

### 平台檢測
```bash
# 檢查當前系統架構
uname -m

# 檢查Docker伺服器架構
docker version --format '{{.Server.Os}}/{{.Server.Arch}}'

# 列出buildx支援的平台
docker buildx ls
```

### 跨平台運行
```bash
# 強制使用特定平台
docker run --platform linux/amd64 perchance-api:latest
docker run --platform linux/arm64 perchance-api:latest

# 檢查鏡像支援的平台
docker buildx imagetools inspect perchance-api:latest
```

## 🐳 推送到Docker Hub

### 預設配置（推薦）
```bash
# 編輯腳本
nano build-multiplatform.sh

# 找到這行：
REGISTRY_URL=""

# 改為您的用戶名：
REGISTRY_URL="yourusername/"

# 保存後直接推送
./build-multiplatform.sh push-multi
```

### 動態配置
```bash
# 每次輸入用戶名
./build-multiplatform.sh push-multi
# 提示時輸入：yourusername
```

### 環境變數配置
```bash
# 設置環境變數
export DOCKER_USERNAME="yourusername"

# 使用環境變數修改腳本
sed -i "s/REGISTRY_URL=\"\"/REGISTRY_URL=\"$DOCKER_USERNAME\/\"/g" build-multiplatform.sh

# 推送
./build-multiplatform.sh push-multi
```

### 推送完整流程
```bash
# 1. 登入Docker Hub
docker login
# Username: yourusername
# Password: ********

# 2. 推送多平台鏡像
./build-multiplatform.sh push-multi

# 3. 驗證推送結果
# 訪問：https://hub.docker.com/r/yourusername/perchance-api

# 4. 測試拉取
docker pull yourusername/perchance-api:latest
```

## 🚨 故障排除

### 常見錯誤及解決方案

#### 1. buildx不可用
```
ERROR: docker buildx build requires exactly 1 argument
```

**解決方案：**
```bash
# 檢查Docker版本
docker --version

# 升級Docker Desktop或安裝buildx
# macOS: 下載最新Docker Desktop
# Linux: 安裝buildx插件
```

#### 2. 多平台構建失敗
```
ERROR: docker exporter does not currently support exporting manifest lists
```

**解決方案：**
```bash
# 使用替代命令
./build-multiplatform.sh build-multi-load

# 或推送到registry
./build-multiplatform.sh push-multi
```

#### 3. 平台不支援
```
ERROR: failed to solve: python:3.12-slim: no match for platform
```

**解決方案：**
```bash
# 檢查基礎鏡像支援的平台
docker buildx imagetools inspect python:3.12-slim

# 使用支援多平台的基礎鏡像
```

#### 4. 構建器錯誤
```
ERROR: failed to solve: rpc error: code = Unknown
```

**解決方案：**
```bash
# 重置構建器
docker buildx rm perchance-builder
./build-multiplatform.sh setup-builder

# 或重啟Docker服務
```

#### 5. 推送權限錯誤
```
ERROR: denied: access forbidden
```

**解決方案：**
```bash
# 重新登入
docker logout
docker login

# 檢查用戶名拼寫
# 確認倉庫權限
```

### 調試命令

```bash
# 查看詳細構建過程
docker buildx build --progress=plain --platform linux/amd64,linux/arm64 -t test .

# 檢查構建器狀態
docker buildx ls

# 檢查構建快取
docker buildx du

# 清理構建快取
docker buildx prune
```

## 💡 最佳實踐

### 開發階段
1. 使用 `build-multi-load` 獲得最佳開發體驗
2. 定期清理未使用的鏡像：`docker image prune`
3. 使用 `.dockerignore` 優化構建速度

### 測試階段
1. 在不同平台上測試鏡像
2. 驗證健康檢查端點
3. 測試環境變數配置

### 生產部署
1. 使用具體版本標籤而非 `latest`
2. 實施多階段構建優化鏡像大小
3. 設置適當的資源限制

### CI/CD整合
1. 在CI環境中預設 `REGISTRY_URL`
2. 使用GitHub Actions自動化構建
3. 實施自動化測試流程

### 安全考慮
1. 定期更新基礎鏡像
2. 掃描鏡像漏洞
3. 使用私有registry存放敏感鏡像

## 🔗 相關文件

- [`DOCKER_README.md`](./DOCKER_README.md) - 完整Docker部署指南
- [`DOCKERHUB_GUIDE.md`](./DOCKERHUB_GUIDE.md) - Docker Hub推送詳細指南
- [`MULTIPLATFORM_FIX.md`](./MULTIPLATFORM_FIX.md) - 多平台構建錯誤修復
- [`Makefile`](./Makefile) - Make命令快捷方式
- [`docker-compose.yml`](./docker-compose.yml) - Docker Compose配置

## 📞 技術支援

如果您在使用過程中遇到問題：

1. **查看日誌** - 仔細閱讀錯誤信息
2. **檢查前置需求** - 確認Docker和buildx版本
3. **參考故障排除** - 查看本文檔的故障排除部分
4. **重置環境** - 嘗試重新設置構建器
5. **提交Issue** - 在GitHub repository中報告問題

## 📊 性能參考

### 構建時間（參考值）

| 命令 | 本地 | 多平台 | 備註 |
|------|------|--------|------|
| `build-local` | 3-8分鐘 | N/A | 最快 |
| `build-multi` | N/A | 10-20分鐘 | 包含交叉編譯 |
| `build-multi-load` | 8-15分鐘 | 12-25分鐘 | 推薦 |
| `push-multi` | N/A | 15-30分鐘 | 包含上傳時間 |

### 鏡像大小
- 基礎鏡像：~150MB
- 包含依賴：~300-500MB
- 多平台manifest：不增加實際大小

---

*最後更新：2025年6月26日*
*版本：v1.0.0*
