CREATE TABLE users (
    id                   NVARCHAR(64)  NOT NULL PRIMARY KEY,
    source               NVARCHAR(32)  NOT NULL DEFAULT 'entra',
    external_id          NVARCHAR(128) NOT NULL,
    user_principal_name  NVARCHAR(320) NOT NULL,
    display_name         NVARCHAR(256) NULL,
    user_type            NVARCHAR(16)  NOT NULL DEFAULT 'member'
                         CHECK (user_type IN ('member', 'guest')),
    account_enabled      BIT           NOT NULL DEFAULT 1,
    mfa_registered       BIT           NULL,
    last_sign_in_at      DATETIME2     NULL,
    created_at           DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    synced_at            DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT uq_users_source_external UNIQUE (source, external_id)
);

CREATE TABLE groups (
    id            NVARCHAR(64)  NOT NULL PRIMARY KEY,
    source        NVARCHAR(32)  NOT NULL DEFAULT 'entra',
    external_id   NVARCHAR(128) NOT NULL,
    display_name  NVARCHAR(256) NOT NULL,
    description   NVARCHAR(MAX) NULL,
    synced_at     DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT uq_groups_source_external UNIQUE (source, external_id)
);

CREATE TABLE group_members (
    group_id  NVARCHAR(64) NOT NULL REFERENCES groups (id) ON DELETE CASCADE,
    user_id   NVARCHAR(64) NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    PRIMARY KEY (group_id, user_id)
);

CREATE TABLE role_assignments (
    id             NVARCHAR(64)  NOT NULL PRIMARY KEY,
    user_id        NVARCHAR(64)  NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    role_name      NVARCHAR(128) NOT NULL,
    is_privileged  BIT           NOT NULL DEFAULT 0,
    scope          NVARCHAR(256) NOT NULL DEFAULT '/',
    assigned_at    DATETIME2     NULL,
    CONSTRAINT uq_role_assignment UNIQUE (user_id, role_name, scope)
);

CREATE INDEX idx_users_last_sign_in ON users (last_sign_in_at);
CREATE INDEX idx_role_assignments_user ON role_assignments (user_id);