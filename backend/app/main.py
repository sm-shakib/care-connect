from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.db.session import engine, Base
from app.models.user import User
from app.models.elder import Elder
from app.models.caregiver import Caregiver, CaregiverDocument
from app.models.family import Family
from app.models.binding import FamilyElderLink
from app.models.notification import Notification
from app.models.medicine import Medicine
from app.models.booking import Booking
from app.api import elder, auth, caregiver, family, utils, admin, binding, notification, medicine, booking

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Care Connect API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, tags=["Authentication"])
app.include_router(elder.router, tags=["Elderly"])
app.include_router(caregiver.router, tags=["Caregiver"])
app.include_router(family.router, tags=["Family"])
app.include_router(admin.router)
app.include_router(binding.router)
app.include_router(notification.router)
app.include_router(medicine.router)
app.include_router(booking.router, prefix="/bookings", tags=["Bookings"])
app.include_router(utils.router, tags=["Utilities"])

@app.get("/")
def read_root():
    return {"message": "Care Connect Backend with DB is running!"}