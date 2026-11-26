import random
import sqlite3
from datetime import datetime, timedelta
from pathlib import Path

DB = Path(__file__).parent / "local.db"
random.seed(42)
now = datetime.now()


def ts(days_ago):
    return (now - timedelta(days=days_ago)).strftime("%Y-%m-%d %H:%M:%S")


STALE = {2, 9, 14, 21, 26, 30, 38, 44, 47, 50}   # no sign-in for 100-400 days
NEVER = {5, 18, 33}                               # never signed in
DISABLED = {13, 27, 41}
NO_MFA = {3, 7}
PRIVILEGED = {
    1: "Global Administrator",
    3: "Global Administrator",
    7: "Privileged Role Administrator",
    9: "User Administrator",
    12: "User Administrator",
}
READERS = {15, 16, 17}

conn = sqlite3.connect(DB)
conn.execute("PRAGMA foreign_keys=ON")

users = []
for n in range(1, 51):
    if n in NEVER:
        last = None
    elif n in STALE:
        last = ts(random.randint(100, 400))
    else:
        last = ts(random.randint(0, 60))
    if n in NO_MFA:
        mfa = 0
    elif n in PRIVILEGED:
        mfa = 1
    else:
        mfa = int(random.random() < 0.85)
    users.append((
        f"user-{n:03d}", "entra", f"ext-{n:03d}",
        f"user{n:03d}@contoso-demo.example", f"Demo User {n:03d}",
        "guest" if n % 10 == 0 else "member",
        0 if n in DISABLED else 1, mfa, last,
    ))
conn.executemany(
    "INSERT OR IGNORE INTO users (id, source, external_id, user_principal_name, "
    "display_name, user_type, account_enabled, mfa_registered, last_sign_in_at) "
    "VALUES (?,?,?,?,?,?,?,?,?)",
    users,
)

group_names = [
    "IT Admins", "Finance", "HR", "Engineering", "Sales",
    "Support", "Contractors", "Executives", "Security Team", "All Staff",
]
groups = [(f"grp-{i:02d}", "entra", f"ext-grp-{i:02d}", name)
          for i, name in enumerate(group_names, start=1)]
conn.executemany(
    "INSERT OR IGNORE INTO groups (id, source, external_id, display_name) VALUES (?,?,?,?)",
    groups,
)

members = set()
for n in range(1, 51):
    uid = f"user-{n:03d}"
    members.add(("grp-10", uid))                       # everyone is in All Staff
    for g in random.sample(range(2, 10), random.randint(1, 2)):
        members.add((f"grp-{g:02d}", uid))
    if n in PRIVILEGED:
        members.add(("grp-01", uid))                   # admins are in IT Admins
conn.executemany("INSERT OR IGNORE INTO group_members (group_id, user_id) VALUES (?,?)",
                 sorted(members))

roles = []
for k, (n, role) in enumerate(sorted(PRIVILEGED.items()), start=1):
    roles.append((f"role-{k:03d}", f"user-{n:03d}", role, 1))
for k, n in enumerate(sorted(READERS), start=len(PRIVILEGED) + 1):
    roles.append((f"role-{k:03d}", f"user-{n:03d}", "Reports Reader", 0))
conn.executemany(
    "INSERT OR IGNORE INTO role_assignments (id, user_id, role_name, is_privileged) VALUES (?,?,?,?)",
    roles,
)

teams = [("team-1", "Rovers FC", "USA"), ("team-2", "Atlas United", "MEX"),
         ("team-3", "Harbor City", "ENG"), ("team-4", "Sol de Cali", "COL"),
         ("team-5", "Nordic Stars", "SWE"), ("team-6", "Porto Azul", "POR")]
conn.executemany("INSERT OR IGNORE INTO teams (id, name, country) VALUES (?,?,?)", teams)

matches = [
    ("m-1", "team-1", "team-2", ts(30), "finished", 2, 1),
    ("m-2", "team-3", "team-4", ts(23), "finished", 0, 0),
    ("m-3", "team-5", "team-6", ts(16), "finished", 1, 3),
    ("m-4", "team-2", "team-3", ts(9), "finished", 4, 2),
    ("m-5", "team-4", "team-1", ts(-7), "scheduled", None, None),
]
conn.executemany(
    "INSERT OR IGNORE INTO matches (id, home_team_id, away_team_id, kickoff_at, "
    "status, home_score, away_score) VALUES (?,?,?,?,?,?,?)",
    matches,
)

conn.commit()
for table in ("users", "groups", "group_members", "role_assignments", "teams", "matches"):
    print(table, conn.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0])
conn.close()