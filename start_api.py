#!/usr/bin/env python3
"""
啟動Perchance Web API服務
"""

import os
import sys

# 確保可以導入perchance模組
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

if __name__ == "__main__":
    from web_api import main
    print("🚀 啟動Perchance圖片生成Web API服務...")
    print("📡 服務將在 http://localhost:8888 上運行")
    print("📋 API文檔: http://localhost:8888/docs")
    print("🔗 端點: POST /api/txttoimage")
    print("💡 按 Ctrl+C 停止服務\n")
    
    main()
