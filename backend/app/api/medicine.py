from datetime import date
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.elder import Elder
from app.models.medicine import Medicine
from app.models.user import User
from app.schemas.medicine import (
    MedicineCreate,
    MedicineOut,
    MedicineTakeRequest,
    MedicineUpdate,
)
from app.api.deps import get_current_user

router = APIRouter(prefix="/medicines", tags=["Medicines"])


def _get_own_elder(db: Session, current_user: User) -> Elder:
    if current_user.role != "elder":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only elders can manage their own medicines",
        )
    elder = db.query(Elder).filter(Elder.user_id == current_user.id).first()
    if not elder:
        raise HTTPException(status_code=404, detail="Elder profile not found")
    return elder


def _get_own_medicine(db: Session, elder: Elder, medicine_id: int) -> Medicine:
    medicine = db.query(Medicine).filter(
        Medicine.id == medicine_id, Medicine.elder_id == elder.id
    ).first()
    if not medicine:
        raise HTTPException(status_code=404, detail="Medicine not found")
    return medicine


@router.get("/me", response_model=List[MedicineOut])
def get_my_medicines(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    elder = _get_own_elder(db, current_user)
    # Medicines whose schedule has already ended are excluded so they drop
    # off the dashboard and medicine list automatically.
    return (
        db.query(Medicine)
        .filter(Medicine.elder_id == elder.id, Medicine.end_date >= date.today())
        .order_by(Medicine.start_date.desc())
        .all()
    )


@router.post("/", response_model=MedicineOut)
def create_medicine(
    payload: MedicineCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    elder = _get_own_elder(db, current_user)
    medicine = Medicine(elder_id=elder.id, **payload.model_dump())
    db.add(medicine)
    db.commit()
    db.refresh(medicine)
    return medicine


@router.put("/{medicine_id}", response_model=MedicineOut)
def update_medicine(
    medicine_id: int,
    payload: MedicineUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    elder = _get_own_elder(db, current_user)
    medicine = _get_own_medicine(db, elder, medicine_id)

    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(medicine, field, value)

    # Drop any taken-today markers for times that no longer exist on the
    # (possibly just-changed) schedule, so they don't linger for the rest
    # of the day.
    medicine.taken_dose_times_raw = [
        time for time in medicine.taken_dose_times_raw
        if time in medicine.schedule_times
    ]

    db.commit()
    db.refresh(medicine)
    return medicine


@router.delete("/{medicine_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_medicine(
    medicine_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    elder = _get_own_elder(db, current_user)
    medicine = _get_own_medicine(db, elder, medicine_id)
    db.delete(medicine)
    db.commit()


@router.patch("/{medicine_id}/take", response_model=MedicineOut)
def mark_medicine_taken(
    medicine_id: int,
    payload: MedicineTakeRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    elder = _get_own_elder(db, current_user)
    medicine = _get_own_medicine(db, elder, medicine_id)

    if payload.time not in medicine.schedule_times:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Not a scheduled time for this medicine",
        )

    today = date.today()
    if medicine.taken_on_date != today:
        medicine.taken_dose_times_raw = []
        medicine.taken_on_date = today

    if payload.time not in medicine.taken_dose_times_raw:
        medicine.taken_dose_times_raw = [*medicine.taken_dose_times_raw, payload.time]

    db.commit()
    db.refresh(medicine)
    return medicine
