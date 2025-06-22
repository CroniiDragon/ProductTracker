import os
import json
import re

def extract_clean_json(raw_text_block):
    match = re.search(r"```json\s*(\{.*?\})\s*```", raw_text_block, re.DOTALL)
    if not match:
        raise ValueError("No valid JSON block found")
    json_text = match.group(1)
    return json.loads(json_text)

def transform_all_saved_invoices():
    folder = os.path.join(os.path.dirname(__file__), "..", "..", "saved_invoices")
    folder = os.path.abspath(folder)

    if not os.path.exists(folder):
        print(f"[INFO] Folderul '{folder}' nu există.")
        return

    for filename in os.listdir(folder):
        if filename.endswith(".json"):
            filepath = os.path.join(folder, filename)

            with open(filepath, "r", encoding="utf-8") as f:
                try:
                    data = json.load(f)
                except json.JSONDecodeError:
                    print(f"[WARN] Skipping invalid JSON file: {filename}")
                    continue

            if "raw_text" in data:
                try:
                    clean_json = extract_clean_json(data["raw_text"])
                except Exception as e:
                    print(f"[ERROR] Error processing {filename}: {e}")
                    continue

                with open(filepath, "w", encoding="utf-8") as f:
                    json.dump(clean_json, f, indent=4, ensure_ascii=False)

                print(f"[OK] Transformed: {filename}")
            else:
                print(f"[SKIP] No raw_text in {filename}")
