from datetime import datetime
import os
import json
import re
from mistralai import Mistral
from app.config import MISTRAL_API_KEY
from app.db.mongo_client import invoices_collection
from bson import ObjectId


model = "pixtral-12b-2409"
client = Mistral(api_key=MISTRAL_API_KEY)

def extract_clean_json(raw_text_block):
    # Extrage JSON curat din blocul ```json ... ```
    match = re.search(r"```json\s*(\{.*?\})\s*```", raw_text_block, re.DOTALL)
    if not match:
        raise ValueError("JSON block not found in the response.")
    json_text = match.group(1)
    return json.loads(json_text)


def send_image_to_mistral(base64_image: str):
    messages = [
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": (
                        "Please extract the invoice data (From Product : NameProduct and Stock(Cant.) only) "
                        "and return only the JSON wrapped in ```json ... ```"
                    )
                },
                {
                    "type": "image_url",
                    "image_url": f"data:image/jpeg;base64,{base64_image}"
                }
            ]
        }
    ]

    response = client.chat.complete(model=model, messages=messages)
    result_text = response.choices[0].message.content

    # În rezultat avem JSON cu "raw_text" (string ce conține blocul ```json ... ```)
    # Prima dată îl parsam ca JSON simplu
    try:
        parsed_json = extract_clean_json(result_text)
    except Exception as e:
        raise ValueError(f"Failed to extract JSON: {e}")

    os.makedirs("saved_invoices", exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"saved_invoices/invoice_{timestamp}.json"

    with open(filename, "w", encoding="utf-8") as f:
        json.dump(parsed_json, f, indent=4, ensure_ascii=False)

    def fix_objectid(obj):
        if isinstance(obj, list):
            return [fix_objectid(o) for o in obj]
        if isinstance(obj, dict):
            return {k: fix_objectid(v) for k, v in obj.items()}
        if isinstance(obj, ObjectId):
            return str(obj)
        return obj

    result = invoices_collection.insert_one(parsed_json)
    saved_doc = invoices_collection.find_one({"_id": result.inserted_id})
    clean_doc = fix_objectid(saved_doc)
    return clean_doc