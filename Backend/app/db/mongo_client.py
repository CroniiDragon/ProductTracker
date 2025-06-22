import os
from pymongo import MongoClient

MONGO_URI = os.getenv("MONGO_KEY")
client = MongoClient(MONGO_URI)

db = client["ProductDb"]  # Numele bazei de date
invoices_collection = db["product"]  # Numele colecției