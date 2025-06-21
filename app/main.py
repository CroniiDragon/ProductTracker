from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import invoice_routes

app = FastAPI(title="SmartBillAI Backend")

# CORS pentru Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(invoice_routes.router)
