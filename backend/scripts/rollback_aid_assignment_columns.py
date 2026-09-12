"""Reverses `scripts/add_aid_assignment_columns.py`.

Drops `assigned_caregiver_id` and `booking_id` from `aid_requests`, and
`is_fund_covered` from `bookings` — returning the schema to what it was
before caregiver allocation was added to the aid request flow.

DESTRUCTIVE. Dropping a column deletes what was in it: which caregiver
each aid request was allocated to, and which bookings the central fund was
paying for. There is no undo, so this asks before touching anything unless
you pass `--yes`.

Two things it deliberately does *not* undo, because neither is reversible
from the schema alone:

- Bookings created by an allocation are left in place. Once
  `is_fund_covered` is gone they are indistinguishable from bookings an
  elder made directly, which means they read as the elder owing the fee.
  Cancel any that shouldn't stand before running this.
- Money already disbursed stays disbursed. The `fund_summary` snapshots
  are history, not state, and rewriting them would falsify the ledger.

What it *does* handle is status: any request sitting in
`awaiting_caregiver` is put back to `pending` first, because that status
only exists in the new code and the old code would render it as an
unrecognised state forever.

Usage (from `backend/`, with the same environment/`.env` the API uses):
    python scripts/rollback_aid_assignment_columns.py [--yes]

Safe to run more than once — every column is dropped only if present.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import inspect, text

from app.db.session import engine

_DROP_COLUMNS = {
    "aid_requests": ["assigned_caregiver_id", "booking_id"],
    "bookings": ["is_fund_covered"],
}


def _confirm(inspector) -> bool:
    """Show what will be lost, then ask. `--yes` skips the prompt."""
    if "--yes" in sys.argv:
        return True

    print("About to DROP these columns — the data in them is lost:")
    for table, columns in _DROP_COLUMNS.items():
        if table not in inspector.get_table_names():
            continue
        existing = {col["name"] for col in inspector.get_columns(table)}
        for name in columns:
            if name in existing:
                print(f"  - {table}.{name}")

    if not sys.stdin.isatty():
        print("\nNot an interactive terminal; re-run with --yes to confirm.")
        return False

    return input("\nType 'rollback' to continue: ").strip() == "rollback"


def main() -> None:
    inspector = inspect(engine)
    tables = set(inspector.get_table_names())

    if not _confirm(inspector):
        print("Aborted — nothing was changed.")
        return

    with engine.begin() as connection:
        # Status first: once the columns are gone there is no way to tell
        # which requests were mid-allocation.
        if "aid_requests" in tables:
            result = connection.execute(
                text(
                    "UPDATE aid_requests SET status = 'pending' "
                    "WHERE status = 'awaiting_caregiver'"
                )
            )
            print(f"{result.rowcount} request(s) returned to 'pending'.")

        for table, columns in _DROP_COLUMNS.items():
            if table not in tables:
                print(f"No '{table}' table — nothing to drop.")
                continue

            existing = {col["name"] for col in inspector.get_columns(table)}
            for name in columns:
                if name not in existing:
                    print(f"  {table}.{name} already absent — skipping.")
                    continue
                connection.execute(text(f"ALTER TABLE {table} DROP COLUMN {name}"))
                print(f"  {table}.{name} dropped.")

    print("Done.")


if __name__ == "__main__":
    main()
