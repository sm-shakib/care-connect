"""One-off migration: links AidRequest -> Elder and Booking -> AidRequest
for the donation-funded caregiver booking flow (see `app/api/fund.py`,
`app/api/booking.py`, `app/services/fund_service.py`):

  - aid_requests.elder_id   -- which elder the aid is for
  - bookings.aid_request_id -- marks a booking as created from an
                                approved aid request instead of a normal
                                elder/family-initiated booking

This project has no Alembic; `Base.metadata.create_all()` (run on every
backend startup) only creates *missing tables*, it never alters an
existing one, so any environment that already had these tables before
this change needs this script run against it once.

Also backfills `aid_requests.elder_id` for existing rows submitted
directly by an elder (requester_id -> elders.user_id), since that link
is unambiguous. Rows submitted by a family member on an elder's behalf
can't be inferred this way and are left NULL — see the printed count.

Usage (from `backend/`, with the same environment/`.env` the API uses):
    python scripts/add_aid_caregiver_linkage_columns.py

Safe to run more than once — every column is added only if it doesn't
already exist, and the backfill only touches rows still NULL.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import inspect, text

from app.db.session import engine

_NEW_COLUMNS = {
    "aid_requests": {
        "elder_id": "INTEGER REFERENCES elders(id)",
    },
    "bookings": {
        "aid_request_id": "INTEGER REFERENCES aid_requests(id)",
    },
}

_BACKFILL_ELDER_SUBMITTED_SQL = """
    UPDATE aid_requests ar
    SET elder_id = e.id
    FROM elders e
    WHERE e.user_id = ar.requester_id
      AND ar.elder_id IS NULL
"""

_COUNT_STILL_NULL_SQL = "SELECT COUNT(*) FROM aid_requests WHERE elder_id IS NULL"


def main() -> None:
    inspector = inspect(engine)
    existing_tables = set(inspector.get_table_names())

    with engine.begin() as conn:
        for table, columns in _NEW_COLUMNS.items():
            if table not in existing_tables:
                print(f"No '{table}' table yet — nothing to migrate; "
                      f"create_all() will create it with the new columns already.")
                continue

            existing_columns = {col["name"] for col in inspector.get_columns(table)}
            to_add = {name: ddl for name, ddl in columns.items() if name not in existing_columns}

            if not to_add:
                print(f"Nothing to do — '{table}' already has every new column.")
                continue

            for name, ddl in to_add.items():
                print(f"Adding {table}.{name} ...")
                conn.execute(text(f"ALTER TABLE {table} ADD COLUMN {name} {ddl}"))

        if "aid_requests" in existing_tables and "elders" in existing_tables:
            print("Backfilling aid_requests.elder_id for elder-submitted requests ...")
            result = conn.execute(text(_BACKFILL_ELDER_SUBMITTED_SQL))
            print(f"Backfilled {result.rowcount} row(s).")

            still_null = conn.execute(text(_COUNT_STILL_NULL_SQL)).scalar()
            if still_null:
                print(f"{still_null} aid request(s) still have elder_id = NULL "
                      f"(family-submitted, pre-dating this feature) — these can't "
                      f"go through the caregiver-booking flow until set manually.")

    print("Done.")


if __name__ == "__main__":
    main()
