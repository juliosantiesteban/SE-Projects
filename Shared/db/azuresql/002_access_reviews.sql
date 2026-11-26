CREATE TABLE access_findings (
    id            NVARCHAR(64)  NOT NULL PRIMARY KEY,
    user_id       NVARCHAR(64)  NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    finding_type  NVARCHAR(32)  NOT NULL
                  CHECK (finding_type IN ('stale_account', 'over_privileged',
                                          'orphaned_guest', 'privileged_no_mfa')),
    risk          NVARCHAR(8)   NOT NULL CHECK (risk IN ('high', 'medium', 'low')),
    details       NVARCHAR(MAX) NULL,
    status        NVARCHAR(16)  NOT NULL DEFAULT 'open'
                  CHECK (status IN ('open', 'resolved', 'accepted')),
    detected_at   DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    resolved_at   DATETIME2     NULL
);

CREATE TABLE access_reviews (
    id               NVARCHAR(64)  NOT NULL PRIMARY KEY,
    finding_id       NVARCHAR(64)  NULL REFERENCES access_findings (id),
    subject_user_id  NVARCHAR(64)  NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    reviewer         NVARCHAR(320) NULL,
    status           NVARCHAR(16)  NOT NULL DEFAULT 'open'
                     CHECK (status IN ('open', 'approved', 'revoked')),
    opened_at        DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    decided_at       DATETIME2     NULL,
    decision_note    NVARCHAR(MAX) NULL
);

CREATE INDEX idx_findings_user ON access_findings (user_id);
CREATE INDEX idx_findings_status_risk ON access_findings (status, risk);
CREATE INDEX idx_reviews_subject ON access_reviews (subject_user_id);