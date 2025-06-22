from fastapi import APIRouter, UploadFile, File, HTTPException, Query
from fastapi.responses import JSONResponse
from typing import List, Optional
from datetime import datetime, timedelta
import json
import os
from bson import ObjectId
from app.services.image_encoder import encode_image
from app.services.mistral_client import send_image_to_mistral
from app.db.mongo_client import invoices_collection
from app.models.invoice_model import Product, Invoice

router = APIRouter(prefix="/api", tags=["Invoice"])


def serialize_objectid(obj):
    """Convertește ObjectId la string pentru JSON serialization"""
    if isinstance(obj, list):
        return [serialize_objectid(item) for item in obj]
    elif isinstance(obj, dict):
        return {key: serialize_objectid(value) for key, value in obj.items()}
    elif isinstance(obj, ObjectId):
        return str(obj)
    return obj


@router.post("/analyze")
async def analyze_invoice(file: UploadFile = File(...)):
    """Analizează o factură și extrage produsele"""
    try:
        # Salvează fișierul temporar
        temp_dir = "temp_uploads"
        os.makedirs(temp_dir, exist_ok=True)

        image_path = os.path.join(temp_dir, f"temp_{file.filename}")
        with open(image_path, "wb") as f:
            f.write(await file.read())

        # Procesează imaginea
        base64_image = encode_image(image_path)
        result = send_image_to_mistral(base64_image)

        # Șterge fișierul temporar
        if os.path.exists(image_path):
            os.remove(image_path)

        # Transformă rezultatul pentru a include date de expirare estimate
        if "invoice" in result and isinstance(result["invoice"], list):
            products_with_expiry = []
            for product_data in result["invoice"]:
                # Estimează data de expirare bazată pe tipul produsului
                expiry_date = estimate_expiry_date(product_data.get("Product", ""))

                enhanced_product = {
                    "id": str(ObjectId()),
                    "name": product_data.get("Product", ""),
                    "quantity": product_data.get("Stock", "1"),
                    "expiryDate": expiry_date.isoformat(),
                    "daysLeft": (expiry_date - datetime.now()).days,
                    "category": categorize_product(product_data.get("Product", "")),
                    "addedDate": datetime.now().isoformat()
                }
                products_with_expiry.append(enhanced_product)

            result["products"] = products_with_expiry

        return JSONResponse(content=serialize_objectid(result))

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Eroare la procesarea facturii: {str(e)}")


@router.get("/products")
async def get_all_products(
        filter_type: Optional[str] = Query(None,
                                           description="Filtrează produsele: 'expired', 'expiring_soon', 'fresh'"),
        limit: Optional[int] = Query(100, description="Numărul maxim de produse de returnat")
):
    """Obține toate produsele cu opțiuni de filtrare"""
    try:
        # Obține toate documentele din MongoDB
        cursor = invoices_collection.find().limit(limit)
        all_products = []

        for doc in cursor:
            if "invoice" in doc and isinstance(doc["invoice"], list):
                for product_data in doc["invoice"]:
                    # Calculează data de expirare pentru produsele vechi
                    expiry_date = estimate_expiry_date(product_data.get("Product", ""))
                    days_left = (expiry_date - datetime.now()).days

                    product = {
                        "id": str(doc.get("_id", ObjectId())),
                        "name": product_data.get("Product", ""),
                        "quantity": product_data.get("Stock", "1"),
                        "expiryDate": expiry_date.isoformat(),
                        "daysLeft": days_left,
                        "category": categorize_product(product_data.get("Product", "")),
                        "addedDate": doc.get("addedDate", datetime.now().isoformat())
                    }

                    # Aplică filtrul dacă este specificat
                    if filter_type:
                        if filter_type == "expired" and days_left > 0:
                            continue
                        elif filter_type == "expiring_soon" and (days_left <= 0 or days_left > 7):
                            continue
                        elif filter_type == "fresh" and days_left <= 7:
                            continue

                    all_products.append(product)

        return JSONResponse(content={
            "products": all_products,
            "total": len(all_products)
        })

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Eroare la obținerea produselor: {str(e)}")


@router.post("/products")
async def save_product(product: dict):
    """Salvează un produs nou"""
    try:
        # Adaugă date suplimentare
        product["id"] = str(ObjectId())
        product["addedDate"] = datetime.now().isoformat()

        # Salvează în MongoDB
        result = invoices_collection.insert_one({
            "invoice": [product],
            "type": "manual_entry",
            "createdAt": datetime.now().isoformat()
        })

        product["_id"] = str(result.inserted_id)

        return JSONResponse(content=serialize_objectid(product))

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Eroare la salvarea produsului: {str(e)}")


@router.delete("/products/{product_id}")
async def delete_product(product_id: str):
    """Șterge un produs"""
    try:
        if not ObjectId.is_valid(product_id):
            raise HTTPException(status_code=400, detail="ID produs invalid")

        result = invoices_collection.delete_one({"_id": ObjectId(product_id)})

        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Produsul nu a fost găsit")

        return JSONResponse(content={"message": "Produs șters cu succes"})

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Eroare la ștergerea produsului: {str(e)}")


@router.get("/products/stats")
async def get_products_stats():
    """Obține statistici despre produse"""
    try:
        cursor = invoices_collection.find()
        total = 0
        expired = 0
        expiring_soon = 0

        for doc in cursor:
            if "invoice" in doc and isinstance(doc["invoice"], list):
                for product_data in doc["invoice"]:
                    total += 1
                    expiry_date = estimate_expiry_date(product_data.get("Product", ""))
                    days_left = (expiry_date - datetime.now()).days

                    if days_left <= 0:
                        expired += 1
                    elif days_left <= 7:
                        expiring_soon += 1

        return JSONResponse(content={
            "total": total,
            "expired": expired,
            "expiring_soon": expiring_soon,
            "fresh": total - expired - expiring_soon
        })

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Eroare la obținerea statisticilor: {str(e)}")


def estimate_expiry_date(product_name: str) -> datetime:
    """Estimează data de expirare bazată pe numele produsului"""
    product_name = product_name.lower()

    # Categorii și durata lor de viață estimată
    if any(word in product_name for word in ['lapte', 'iaurt', 'milk', 'yogurt']):
        return datetime.now() + timedelta(days=7)
    elif any(word in product_name for word in ['paine', 'bread', 'franzela']):
        return datetime.now() + timedelta(days=3)
    elif any(word in product_name for word in ['carne', 'meat', 'porc', 'vita', 'pui']):
        return datetime.now() + timedelta(days=5)
    elif any(word in product_name for word in ['branза', 'cheese', 'telemea']):
        return datetime.now() + timedelta(days=14)
    elif any(word in product_name for word in ['cafea', 'coffee', 'cafe']):
        return datetime.now() + timedelta(days=365)  # Cafea se păstrează mult
    elif any(word in product_name for word in ['conserva', 'conserve', 'canned']):
        return datetime.now() + timedelta(days=730)  # 2 ani
    else:
        return datetime.now() + timedelta(days=30)  # Default: 30 zile


def categorize_product(product_name: str) -> str:
    """Categorizează produsul bazat pe nume"""
    product_name = product_name.lower()

    if any(word in product_name for word in ['lapte', 'iaurt', 'branza', 'cheese', 'milk']):
        return 'Lactate'
    elif any(word in product_name for word in ['paine', 'bread', 'franzela']):
        return 'Panificație'
    elif any(word in product_name for word in ['carne', 'meat', 'porc', 'vita', 'pui']):
        return 'Carne'
    elif any(word in product_name for word in ['cafea', 'coffee', 'cafe']):
        return 'Băuturi'
    elif any(word in product_name for word in ['sapun', 'soap', 'detergent']):
        return 'Igienă'
    elif any(word in product_name for word in ['baterie', 'battery']):
        return 'Electronice'
    else:
        return 'Altele'