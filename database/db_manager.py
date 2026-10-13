import os
import sqlite3
from contextlib import contextmanager

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "sports_club.db")
SCHEMA_PATH = os.path.join(BASE_DIR, "schema.sql")
SEED_PATH = os.path.join(BASE_DIR, "seed_data.sql")


def get_connection(db_path=None):
    """Establishes and returns a connection to the SQLite database."""
    target_path = db_path or DB_PATH
    conn = sqlite3.connect(target_path)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON;")
    return conn


@contextmanager
def get_db(db_path=None):
    """Context manager for safe database transactions with auto-commit/rollback."""
    conn = get_connection(db_path)
    try:
        yield conn
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise e
    finally:
        conn.close()


def init_database(db_path=None, seed=True):
    """Initializes the database schema and seeds sample data."""
    target_path = db_path or DB_PATH
    # If starting fresh, remove existing if needed or run DDL
    with get_connection(target_path) as conn:
        with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
            schema_sql = f.read()
        conn.executescript(schema_sql)

        if seed:
            # Check if members table has data already
            cur = conn.cursor()
            cur.execute("SELECT COUNT(*) FROM members;")
            count = cur.fetchone()[0]
            if count == 0:
                with open(SEED_PATH, "r", encoding="utf-8") as f:
                    seed_sql = f.read()
                conn.executescript(seed_sql)
        conn.commit()
    print(f"Database successfully initialized at: {target_path}")


def query_db(query, args=(), one=False, db_path=None):
    """Helper to query database and return dictionary rows."""
    conn = get_connection(db_path)
    try:
        cur = conn.cursor()
        cur.execute(query, args)
        rows = cur.fetchall()
        result = [dict(row) for row in rows]
        return (result[0] if result else None) if one else result
    finally:
        conn.close()


def execute_db(query, args=(), db_path=None):
    """Helper to execute an INSERT, UPDATE, or DELETE and return lastrowid / rowcount."""
    with get_db(db_path) as conn:
        cur = conn.cursor()
        cur.execute(query, args)
        return {
            "lastrowid": cur.lastrowid,
            "rowcount": cur.rowcount
        }


if __name__ == "__main__":
    init_database(seed=True)
