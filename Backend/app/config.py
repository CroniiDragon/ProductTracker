from dotenv import load_dotenv
import os

load_dotenv()
MISTRAL_API_KEY = os.getenv("MISTRAL_API_KEY")
CHATGPT_API_KEY = os.getenv("CHATGPT_API_KEY")
