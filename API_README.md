# Perchance Web API

這是一個基於FastAPI的Web服務，提供Perchance AI圖片生成功能。

## 功能特色

- 🎨 文字轉圖片生成
- 🌐 RESTful API介面
- 📝 自動API文檔
- 🔧 支援所有ImageGenerator參數
- 📦 Base64編碼圖片回傳

## 安裝需求

```bash
pip install -r requirements.txt
```

## 啟動服務

### 方法1：使用啟動腳本
```bash
python start_api.py
```

### 方法2：直接啟動
```bash
python web_api.py
```

### 方法3：使用uvicorn
```bash
uvicorn web_api:app --host 0.0.0.0 --port 8888 --reload
```

服務將在 http://localhost:8888 上運行

## API端點

### POST /api/txttoimage

文字轉圖片生成端點

**請求參數：**
```json
{
  "prompt": "A beautiful sunset over mountains",
  "negative_prompt": "blurry, low quality",
  "seed": 42,
  "shape": "landscape",
  "guidance_scale": 8.0
}
```

**參數說明：**
- `prompt` (必需): 圖片描述文字
- `negative_prompt` (選用): 不希望在圖片中看到的內容
- `seed` (選用): 生成種子，預設-1（隨機）
- `shape` (選用): 圖片形狀，可選 'portrait', 'square', 'landscape'，預設'square'
- `guidance_scale` (選用): 提示詞準確度，範圍1-30，預設7.0

**回應格式：**
```json
{
  "image_base64": "base64編碼的圖片資料",
  "image_type": "圖片檔案類型(如png, jpg)",
  "image_id": "圖片唯一ID",
  "seed": "使用的種子值",
  "prompt": "使用的提示詞",
  "width": 圖片寬度,
  "height": 圖片高度,
  "guidance_scale": 指導比例,
  "negative_prompt": "負面提示詞",
  "maybe_nsfw": false
}
```

### GET /health

健康檢查端點

**回應：**
```json
{
  "status": "healthy",
  "generator_ready": true
}
```

### GET /

根路徑，返回服務狀態

### GET /docs

自動生成的API文檔（Swagger UI）

## 使用範例

### Python客戶端範例

```python
import asyncio
import aiohttp
import base64
from PIL import Image
import io

async def generate_image():
    url = "http://localhost:8888/api/txttoimage"
    data = {
        "prompt": "A cat sitting on stairs",
        "shape": "square",
        "guidance_scale": 7.0
    }
    
    async with aiohttp.ClientSession() as session:
        async with session.post(url, json=data) as response:
            if response.status == 200:
                result = await response.json()
                
                # 解碼並顯示圖片
                image_data = base64.b64decode(result['image_base64'])
                image = Image.open(io.BytesIO(image_data))
                image.show()
            else:
                print(f"錯誤: {response.status}")

asyncio.run(generate_image())
```

### cURL範例

```bash
curl -X POST "http://localhost:8888/api/txttoimage" \
     -H "Content-Type: application/json" \
     -d '{
       "prompt": "A beautiful sunset over mountains",
       "shape": "landscape",
       "guidance_scale": 8.0
     }'
```

### JavaScript範例

```javascript
async function generateImage() {
    const response = await fetch('http://localhost:8888/api/txttoimage', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            prompt: "A cat sitting on stairs",
            shape: "square",
            guidance_scale: 7.0
        })
    });
    
    if (response.ok) {
        const result = await response.json();
        console.log('圖片ID:', result.image_id);
        
        // 創建圖片元素
        const img = document.createElement('img');
        img.src = `data:image/${result.image_type};base64,${result.image_base64}`;
        document.body.appendChild(img);
    }
}
```

## 測試

執行測試範例：

```bash
python api_example.py
```

## 注意事項

1. 首次啟動時，系統需要初始化圖片生成器，可能需要一些時間
2. 圖片生成可能需要較長時間，請耐心等待
3. 生成的圖片會以Base64格式回傳，適合直接在網頁中顯示
4. 服務支援CORS，可以從前端直接呼叫
5. 建議在生產環境中使用HTTPS和適當的安全措施
