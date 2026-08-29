import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

def fix_database():
    database_url = os.getenv("DATABASE_URL")
    print(f"Connecting to: {database_url.split('@')[-1]}") # Print only the host part for safety
    
    try:
        conn = psycopg2.connect(database_url)
        cur = conn.cursor()
        
        # 1. Check if the table exists
        cur.execute("SELECT to_regclass('public.family_elder_links');")
        if not cur.fetchone()[0]:
            print("Table family_elder_links does not exist yet. It will be created when you restart uvicorn.")
            return

        # 2. Check current columns
        cur.execute("SELECT column_name FROM information_schema.columns WHERE table_name = 'family_elder_links';")
        columns = [row[0] for row in cur.fetchall()]
        print(f"Current columns: {columns}")
        
        # 3. Handle the 'relationship' column
        if 'relationship' not in columns:
            if 'family_relationship' in columns:
                print("Renaming 'family_relationship' to 'relationship'...")
                cur.execute("ALTER TABLE family_elder_links RENAME COLUMN family_relationship TO relationship;")
            else:
                print("Adding missing column 'relationship'...")
                cur.execute("ALTER TABLE family_elder_links ADD COLUMN relationship VARCHAR NOT NULL DEFAULT 'Other';")
        else:
            print("Column 'relationship' already exists.")
            
        conn.commit()

        # 4. Handle users table missing created_at
        cur.execute("SELECT column_name FROM information_schema.columns WHERE table_name = 'users';")
        user_columns = [row[0] for row in cur.fetchall()]
        if 'created_at' not in user_columns:
            print("Adding missing column 'created_at' to users table...")
            cur.execute("ALTER TABLE users ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();")
        else:
            print("Column 'created_at' already exists in users table.")

        # 5. Handle bookings table missing total_amount
        cur.execute("SELECT column_name FROM information_schema.columns WHERE table_name = 'bookings';")
        booking_columns = [row[0] for row in cur.fetchall()]
        if 'total_amount' not in booking_columns:
            print("Adding missing column 'total_amount' to bookings table...")
            cur.execute("ALTER TABLE bookings ADD COLUMN total_amount FLOAT DEFAULT 0.0;")
        else:
            print("Column 'total_amount' already exists in bookings table.")

        conn.commit()
        print("Database updated successfully!")
        
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    fix_database()
