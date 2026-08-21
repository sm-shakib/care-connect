from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from app.core.config import settings

# Update engine configuration
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,  # Checks connection health before every request
    pool_recycle=300,    # Automatically restarts connections every 5 minutes
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

# Dependency to get DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()