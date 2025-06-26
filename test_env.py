#!/usr/bin/env python3
"""
測試Web API是否正常工作
"""

import asyncio
import time

async def test_import():
    """測試模組導入"""
    try:
        print("測試導入模組...")
        
        # 測試FastAPI導入
        from fastapi import FastAPI
        print("✅ FastAPI導入成功")
        
        # 測試uvicorn導入
        import uvicorn
        print("✅ Uvicorn導入成功")
        
        # 測試perchance導入
        import perchance
        print("✅ Perchance導入成功")
        
        # 測試web_api導入
        from web_api import app, ImageRequest, ImageResponseData
        print("✅ Web API模組導入成功")
        
        print("\n🎉 所有必要模組都已成功導入！")
        print("\n要啟動API服務，請執行以下命令之一：")
        print("1. python web_api.py")
        print("2. uvicorn web_api:app --host 0.0.0.0 --port 8888 --reload")
        print("3. python start_api.py")
        
        return True
        
    except ImportError as e:
        print(f"❌ 導入錯誤: {e}")
        return False
    except Exception as e:
        print(f"❌ 其他錯誤: {e}")
        return False

if __name__ == "__main__":
    print("=== Perchance Web API 環境測試 ===\n")
    
    success = asyncio.run(test_import())
    
    if success:
        print("\n✅ 環境設置完成，可以啟動API服務了！")
    else:
        print("\n❌ 環境設置有問題，請檢查套件安裝")
