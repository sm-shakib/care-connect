from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.db.session import engine, Base
from app.models.user import User
from app.models.elder import Elder
from app.models.caregiver import Caregiver, CaregiverDocument
from app.models.family import Family
from app.api import elder, auth, caregiver, family, utils, admin

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
app.include_router(utils.router, tags=["Utilities"])
app.include_router(admin.router)

@app.get("/")
def read_root():
    return {"message": "Care Connect Backend with DB is running!"}
