"""One-off migration: adds the columns `Notification` (see
`app/models/notification.py`) needs for SOS alerts — `elder_id`,
`elder_name`, `latitude`, `longitude` — to an existing `notifications`
table.

This project has no Alembic; `Base.metadata.create_all()` (run on every
backend startup) only creates *missing tables*, it never alters an
existing one, so any environment that already had a `notifications` table
before this change needs this script run against it once.

Usage (from `backend/`, with the same environment/`.env` the API uses):
    python scripts/add_sos_notification_columns.py

Safe to run more than once — every column is added only if it doesn't
already exist.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import inspect, text

from app.db.session import engine

_NEW_COLUMNS = {
    "elder_id": "INTEGER REFERENCES elders(id)",
    "elder_name": "VARCHAR",
    "latitude": "VARCHAR",
    "longitude": "VARCHAR",
}


def main() -> None:
    inspector = inspect(engine)
    if "notifications" not in inspector.get_table_names():
        print("No 'notifications' table yet — nothing to migrate; "
              "create_all() will create it with the new columns already.")
        return

    existing = {col["name"] for col in inspector.get_columns("notifications")}
    to_add = {name: ddl for name, ddl in _NEW_COLUMNS.items() if name not in existing}

    if not to_add:
        print("Nothing to do — 'notifications' already has every SOS column.")
        return

    with engine.begin() as conn:
        for name, ddl in to_add.items():
            print(f"Adding notifications.{name} ...")
            conn.execute(text(f"ALTER TABLE notifications ADD COLUMN {name} {ddl}"))

    print(f"Done — added: {', '.join(to_add)}")


if __name__ == "__main__":
    main()
