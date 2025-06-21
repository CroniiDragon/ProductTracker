from datetime import datetime
import os
import json
import re
from mistralai import Mistral
from app.config import MISTRAL_API_KEY
from app.services.transform_parsed_json import transform_all_saved_invoices


model = "pixtral-12b-2409"
client = Mistral(api_key=MISTRAL_API_KEY)

def send_image_to_mistral(base64_image: str):
    messages = [
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": (
                        "Please extract the invoice data (company, client, date, products) "
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

    # Extrage JSON-ul din blocul ```json ... ```
    match = re.search(r"```json\s*(\{.*?\})\s*```", result_text, re.DOTALL)
    if not match:
        raise ValueError("JSON block not found in the response.")

    json_text = match.group(1)

    try:
        parsed_json = json.loads(json_text)
    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid JSON format inside code block: {e}")

    # Creează folderul dacă nu există
    os.makedirs("saved_invoices", exist_ok=True)

    # Creează numele fișierului cu data și ora
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"saved_invoices/invoice_{timestamp}.json"

    # Salvează JSON-ul curat (fără raw_text)
    with open(filename, "w", encoding="utf-8") as f:
        json.dump(parsed_json, f, indent=4, ensure_ascii=False)

    return parsed_json

