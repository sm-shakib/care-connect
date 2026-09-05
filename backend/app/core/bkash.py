import httpx
import json
from app.core.config import settings

class BkashClient:
    def __init__(self):
        self.base_url = settings.BKASH_BASE_URL
        self.app_key = settings.BKASH_APP_KEY
        self.app_secret = settings.BKASH_APP_SECRET
        self.username = settings.BKASH_USERNAME
        self.password = settings.BKASH_PASSWORD
        self.headers = {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "username": self.username,
            "password": self.password,
        }

    async def get_token(self):
        url = f"{self.base_url}/tokenized/checkout/token/grant"
        payload = {
            "app_key": self.app_key,
            "app_secret": self.app_secret
        }
        async with httpx.AsyncClient() as client:
            response = await client.post(url, json=payload, headers=self.headers)
            data = response.json()
            if "id_token" in data:
                return data["id_token"]
            raise Exception(f"bKash Token Grant Failed: {data}")

    async def create_payment(self, amount, invoice_number, callback_url):
        token = await self.get_token()
        url = f"{self.base_url}/tokenized/checkout/create"
        
        headers = self.headers.copy()
        headers["Authorization"] = token
        headers["X-APP-Key"] = self.app_key

        payload = {
            "mode": "0011",
            "payerReference": "CareConnect",
            "callbackURL": callback_url,
            "amount": str(amount),
            "currency": "BDT",
            "intent": "sale",
            "merchantInvoiceNumber": invoice_number
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(url, json=payload, headers=headers)
            data = response.json()
            if "bkashURL" in data:
                return data
            raise Exception(f"bKash Payment Creation Failed: {data}")

    async def execute_payment(self, payment_id):
        token = await self.get_token()
        url = f"{self.base_url}/tokenized/checkout/execute"
        
        headers = self.headers.copy()
        headers["Authorization"] = token
        headers["X-APP-Key"] = self.app_key

        payload = {
            "paymentID": payment_id
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(url, json=payload, headers=headers)
            return response.json()

bkash_client = BkashClient()
