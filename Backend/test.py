import requests

url = "http://localhost:8000/api/analyze"
file_path = r"D:\Projects\Hackathon\SmartBillAI\image\img_2.png"

with open(file_path, "rb") as f:
    files = {"file": ("img_2.png", f, "image/png")}
    response = requests.post(url, files=files)

print(response.status_code)
print(response)
