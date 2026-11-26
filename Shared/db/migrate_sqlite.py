import sqlite3
from pathlib import Path

HERE = Path(__file__).parent
DB = HERE / "local.db"
MIGRATIONS = sorted((HERE / "migrations").glob("*.sql"))


def main():
    conn = sqlite3.connect(DB)
    conn.execute("PRAGMA foreign_keys=ON")
    conn.execute(
        "CREATE TABLE IF NOT EXISTS schema_migrations ("
        "filename TEXT PRIMARY KEY, "
        "applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)"
    )
    done = {row[0] for row in conn.execute("SELECT filename FROM schema_migrations")}
    for f in MIGRATIONS:
        if f.name in done:
            print(f"skip   {f.name}")
            continue
        conn.executescript(f.read_text())
        conn.execute("INSERT INTO schema_migrations (filename) VALUES (?)", (f.name,))
        conn.commit()
        print(f"apply  {f.name}")
    conn.close()


if __name__ == "__main__":
    main()