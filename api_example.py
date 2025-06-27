#!/usr/bin/env python3
"""
Web API使用範例
演示如何使用/api/txttoimage端點生成圖片
"""

import asyncio
import aiohttp
import base64
import json
from PIL import Image
import io


async def test_api():
    """測試Web API"""
    # API端點
    url = "http://localhost:8888/api/txttoimage"
    
    # 請求參數
    request_data = {
        "prompt": "A beautiful sunset over mountains",
        "negative_prompt": "blurry, low quality",
        "seed": -1,
        "shape": "landscape",
        "guidance_scale": 8.0
    }
    
    print(f"發送請求到: {url}")
    print(f"請求參數: {json.dumps(request_data, indent=2, ensure_ascii=False)}")
    
    async with aiohttp.ClientSession() as session:
        try:
            async with session.post(url, json=request_data) as response:
                if response.status == 200:
                    result = await response.json()
                    
                    print(f"\n✅ 成功生成圖片!")
                    print(f"圖片ID: {result['image_id']}")
                    print(f"圖片類型: {result['image_type']}")
                    print(f"尺寸: {result['width']}x{result['height']}")
                    print(f"種子: {result['seed']}")
                    print(f"可能NSFW: {result['maybe_nsfw']}")
                    
                    # 解碼Base64並顯示圖片
                    image_data = base64.b64decode(result['image_base64'])
                    image = Image.open(io.BytesIO(image_data))
                    
                    # 保存圖片
                    filename = f"generated_{result['image_id']}.{result['image_type']}"
                    image.save(filename)
                    print(f"圖片已保存為: {filename}")
                    
                    # 顯示圖片（如果支援的話）
                    try:
                        image.show()
                        print("圖片已在預設圖片檢視器中開啟")
                    except Exception:
                        print("無法開啟圖片檢視器")
                        
                else:
                    error_text = await response.text()
                    print(f"❌ 請求失敗 (HTTP {response.status}): {error_text}")
                    
        except aiohttp.ClientConnectorError:
            print("❌ 無法連接到API服務器。請確保Web API服務正在運行（port 8888）")
        except Exception as e:
            print(f"❌ 發生錯誤: {e}")


async def test_health():
    """測試健康檢查端點"""
    url = "http://localhost:8888/health"
    
    async with aiohttp.ClientSession() as session:
        try:
            async with session.get(url) as response:
                if response.status == 200:
                    result = await response.json()
                    print(f"🟢 API服務狀態: {result}")
                else:
                    print(f"❌ 健康檢查失敗 (HTTP {response.status})")
        except Exception as e:
            print(f"❌ 健康檢查錯誤: {e}")


async def main():
    """主函式"""
    print("=== Perchance Web API 測試 ===\n")
    
    # 先測試健康檢查
    print("1. 測試健康檢查...")
    await test_health()
    
    print("\n2. 測試圖片生成...")
    await test_api()


if __name__ == "__main__":
    asyncio.run(main())
