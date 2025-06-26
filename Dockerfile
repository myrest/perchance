# 使用官方Python 3.12基礎鏡像（支援多平台）
FROM --platform=$BUILDPLATFORM python:3.12-slim

# 設置工作目錄
WORKDIR /app

# 設置環境變數
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# 安裝系統依賴（Playwright需要）
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 複製requirements文件
COPY requirements.txt .

# 安裝Python依賴
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# 安裝Playwright瀏覽器
RUN playwright install --with-deps chromium

# 複製專案文件
COPY . .

# 確保start_api.py有執行權限
RUN chmod +x start_api.py

# 暴露端口
EXPOSE 8888

# 健康檢查
HEALTHCHECK --interval=30s --timeout=30s --start-period=40s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8888/health')" || exit 1

# 啟動命令
CMD ["python", "start_api.py"]
