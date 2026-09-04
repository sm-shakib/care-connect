"""One-off schema patch for the chat feature's `messages` table.

`Base.metadata.create_all()` (run on every app startup, see `app/main.py`)
only creates *missing tables* — it never adds a column to a table that
already exists. Anyone who had the chat tables created before the
reply-to/unsend feature was added needs this run once against their
database; a fresh database gets these columns for free via `create_all`
and doesn't need it. Safe to run more than once (every statement is
idempotent).

Usage: python fix_chat_schema.py
"""
import os

import psycopg2
from dotenv import load_dotenv

load_dotenv()


def fix_chat_schema():
    database_url = os.getenv("DATABASE_URL")
    print(f"Connecting to: {database_url.split('@')[-1]}")  # host only, for safety

    conn = psycopg2.connect(database_url)
    try:
        cur = conn.cursor()

        cur.execute("SELECT to_regclass('public.messages');")
        if not cur.fetchone()[0]:
            print("Table 'messages' does not exist yet — it will be created "
                  "with these columns already included when you next start uvicorn.")
            return

        cur.execute(
            "SELECT column_name FROM information_schema.columns WHERE table_name = 'messages';"
        )
        columns = {row[0] for row in cur.fetchall()}
        print(f"Current columns: {sorted(columns)}")

        if "reply_to_message_id" not in columns:
            print("Adding 'reply_to_message_id'...")
            cur.execute(
                "ALTER TABLE messages ADD COLUMN reply_to_message_id INTEGER "
                "REFERENCES messages(id) ON DELETE SET NULL;"
            )
        else:
            print("'reply_to_message_id' already present, skipping.")

        if "deleted_at" not in columns:
            print("Adding 'deleted_at'...")
            cur.execute("ALTER TABLE messages ADD COLUMN deleted_at TIMESTAMPTZ;")
        else:
            print("'deleted_at' already present, skipping.")

        conn.commit()
        print("Done.")
    finally:
        conn.close()


if __name__ == "__main__":
    fix_chat_schema()
