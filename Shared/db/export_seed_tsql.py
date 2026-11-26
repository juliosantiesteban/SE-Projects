import sqlite3
from pathlib import Path

HERE = Path(__file__).parent
TABLES = ["users", "groups", "group_members", "role_assignments", "teams", "matches"]


def lit(value):
    if value is None:
        return "NULL"
    if isinstance(value, (int, float)):
        return str(value)
    return "N'" + str(value).replace("'", "''") + "'"


conn = sqlite3.connect(HERE / "local.db")
lines = []
for table in TABLES:
    cur = conn.execute(f"SELECT * FROM {table}")
    cols = [d[0] for d in cur.description]
    for row in cur:
        lines.append(
            f"INSERT INTO {table} ({', '.join(cols)}) VALUES ({', '.join(lit(v) for v in row)});"
        )
out = HERE / "azuresql" / "seed.sql"
out.write_text("\n".join(lines) + "\n")
print(f"wrote {len(lines)} statements to {out}")
conn.close()