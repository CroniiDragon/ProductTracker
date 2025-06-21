from fastapi import APIRouter, UploadFile, File
from app.services.image_encoder import encode_image
from app.services.mistral_client import send_image_to_mistral

router = APIRouter(prefix="/api", tags=["Invoice"])

@router.post("/analyze")
async def analyze_invoice(file: UploadFile = File(...)):
    image_path = f"temp_{file.filename}"
    with open(image_path, "wb") as f:
        f.write(await file.read())

    base64_image = encode_image(image_path)
    result = send_image_to_mistral(base64_image)

    return {"result": result}
