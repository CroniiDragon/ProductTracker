# main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.invoice_routes import router as enhanced_router
import uvicorn
import os

app = FastAPI(
    title="SmartBillAI Backend", 
    description="Backend pentru aplicația Monitor Produse - detectarea automată a produselor din facturi",
    version="1.0.0"
)

# CORS pentru Flutter - configurare mai detaliată
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # În producție, specifică domeniile exacte
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# Include rutele pentru facturi
app.include_router(enhanced_router)

@app.get("/")
async def root():
    return {
        "message": "SmartBillAI Backend", 
        "version": "1.0.0",
        "status": "running"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy", "message": "Backend is running properly"}

if __name__ == "__main__":
    # Pentru dezvoltare locală
    uvicorn.run(
        "main:app", 
        host="0.0.0.0", 
        port=8000, 
        reload=True,
        log_level="info"
    )