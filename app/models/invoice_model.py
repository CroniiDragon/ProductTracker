from pydantic import BaseModel
from typing import List

class Product(BaseModel):
    code: str
    name: str
    quantity: float
    category: str

class Invoice(BaseModel):
    products: List[Product]
    total: float
    tva: float
    date: str
    merchant: str
