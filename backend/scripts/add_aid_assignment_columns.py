"""One-off migration: adds the columns the caregiver-allocation half of
the aid request flow needs — `assigned_caregiver_id` and `booking_id` on
`aid_requests` (see `app/models/fund.py`), and `is_fund_covered` on
`bookings` (see `app/models/booking.py`).

This project has no Alembic; `Base.metadata.create_all()` (run on every
backend startup) only creates *missing tables*, it never alters an
existing one, so any environment that already had these tables before
this change needs this script run against it once.

Usage (from `backend/`, with the same environment/`.env` the API uses):
    python scripts/add_aid_assignment_columns.py

Safe to run more than once — every column is added only if it doesn't
already exist.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import inspect, text

from app.db.session import engine

_NEW_COLUMNS = {
    "aid_requests": {
        "assigned_caregiver_id": "INTEGER REFERENCES caregivers(id)",
        "booking_id": "INTEGER REFERENCES bookings(id)",
    },
    "bookings": {
        # NOT NULL with a default so existing rows read as "elder pays",
        # which is what every booking made before this change was.
        "is_fund_covered": "BOOLEAN NOT NULL DEFAULT FALSE",
    },
}


def main() -> None:
    inspector = inspect(engine)
    tables = set(inspector.get_table_names())

    with engine.begin() as connection:
        for table, columns in _NEW_COLUMNS.items():
            if table not in tables:
                print(f"No '{table}' table yet — create_all() will build it with these columns.")
                continue

            existing = {col["name"] for col in inspector.get_columns(table)}
            for name, definition in columns.items():
                if name in existing:
                    print(f"  {table}.{name} already present — skipping.")
                    continue
                connection.execute(text(f"ALTER TABLE {table} ADD COLUMN {name} {definition}"))
                print(f"  {table}.{name} added.")

    print("Done.")


if __name__ == "__main__":
    main()
