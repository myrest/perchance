import asyncio
import base64
import io
from typing import Literal, Optional
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import uvicorn
import perchance


class ImageRequest(BaseModel):
    """圖片生成請求參數"""
    prompt: str = Field(..., description="圖片描述")
    negative_prompt: Optional[str] = Field(None, description="不希望在圖片中看到的內容")
    seed: int = Field(-1, description="生成種子")
    shape: Literal['portrait', 'square', 'landscape'] = Field('square', description="圖片形狀")
    guidance_scale: float = Field(7.0, description="提示詞準確度，範圍 1-30")


class ImageResponseData(BaseModel):
    """圖片回應資料"""
    image_base64: str = Field(..., description="Base64編碼的圖片資料")
    image_type: str = Field(..., description="圖片類型")
    image_id: str = Field(..., description="圖片ID")
    seed: int = Field(..., description="使用的種子")
    prompt: str = Field(..., description="使用的提示詞")
    width: int = Field(..., description="圖片寬度")
    height: int = Field(..., description="圖片高度")
    guidance_scale: float = Field(..., description="指導比例")
    negative_prompt: Optional[str] = Field(None, description="負面提示詞")
    maybe_nsfw: bool = Field(..., description="可能包含成人內容")


app = FastAPI(
    title="Perchance圖片生成API",
    description="使用Perchance AI生成圖片的Web API",
    version="1.0.0"
)

# 添加CORS支援
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 在生產環境中應該限制特定域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 全域圖片生成器實例
generator = None


@app.on_event("startup")
async def startup_event():
    """應用程式啟動時初始化圖片生成器"""
    global generator
    generator = perchance.ImageGenerator()


@app.get("/")
async def root():
    """根路徑"""
    return {"message": "Perchance圖片生成API服務運行中"}


@app.post("/api/txttoimage", response_model=ImageResponseData)
async def text_to_image(request: ImageRequest):
    """
    文字轉圖片API端點
    
    接受文字提示詞並生成對應的圖片，回傳Base64編碼的圖片資料
    """
    try:
        if generator is None:
            raise HTTPException(status_code=500, detail="圖片生成器未初始化")
        
        print(f"🎨 開始生成圖片: {request.prompt}")
        
        # 使用ImageGenerator生成圖片
        async with await generator.image(
            prompt=request.prompt,
            negative_prompt=request.negative_prompt,
            seed=request.seed,
            shape=request.shape,
            guidance_scale=request.guidance_scale
        ) as result:
            print(f"✅ 圖片生成完成，ID: {result.image_id}")
            
            # 下載圖片資料
            image_data = await result.download()
            
            # 轉換為Base64
            image_data.seek(0)
            image_bytes = image_data.read()
            image_base64 = base64.b64encode(image_bytes).decode('utf-8')
            
            print(f"📦 圖片已轉換為Base64，大小: {len(image_base64)} 字元")
            
            # 組建回應資料
            response_data = ImageResponseData(
                image_base64=image_base64,
                image_type=result.file_ext,
                image_id=result.image_id,
                seed=result.seed,
                prompt=result.prompt,
                width=result.width,
                height=result.height,
                guidance_scale=result.guidance_scale,
                negative_prompt=result.negative_prompt,
                maybe_nsfw=result.maybe_nsfw
            )
            
            return response_data
            
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ 圖片生成失敗: {str(e)}")
        raise HTTPException(status_code=500, detail=f"圖片生成失敗: {str(e)}")


@app.get("/health")
async def health_check():
    """健康檢查端點"""
    return {"status": "healthy", "generator_ready": generator is not None}


def main():
    """啟動Web API服務"""
    uvicorn.run(
        "web_api:app",
        host="0.0.0.0",
        port=8888,
        reload=True,
        log_level="info"
    )


if __name__ == "__main__":
    main()
