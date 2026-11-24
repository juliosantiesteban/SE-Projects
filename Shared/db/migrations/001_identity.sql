-- Identity data synced from the directory (Entra today, Okta later)

CREATE TABLE users (
    id                   TEXT PRIMARY KEY,
    source               TEXT NOT NULL DEFAULT 'entra',
    external_id          TEXT NOT NULL,
    user_principal_name  TEXT NOT NULL,
    display_name         TEXT,
    user_type            TEXT NOT NULL DEFAULT 'member'
                         CHECK (user_type IN ('member', 'guest')),
    account_enabled      BOOLEAN NOT NULL DEFAULT TRUE,
    mfa_registered       BOOLEAN,
    last_sign_in_at      TIMESTAMP,
    created_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    synced_at            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (source, external_id)
);

CREATE TABLE groups (
    id            TEXT PRIMARY KEY,
    source        TEXT NOT NULL DEFAULT 'entra',
    external_id   TEXT NOT NULL,
    display_name  TEXT NOT NULL,
    description   TEXT,
    synced_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (source, external_id)
);

CREATE TABLE group_members (
    group_id  TEXT NOT NULL REFERENCES groups (id) ON DELETE CASCADE,
    user_id   TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    PRIMARY KEY (group_id, user_id)
);

CREATE TABLE role_assignments (
    id             TEXT PRIMARY KEY,
    user_id        TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    role_name      TEXT NOT NULL,
    is_privileged  BOOLEAN NOT NULL DEFAULT FALSE,
    scope          TEXT NOT NULL DEFAULT '/',
    assigned_at    TIMESTAMP,
    UNIQUE (user_id, role_name, scope)
);

CREATE INDEX idx_users_last_sign_in ON users (last_sign_in_at);
CREATE INDEX idx_role_assignments_user ON role_assignments (user_id);