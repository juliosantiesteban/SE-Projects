-- Findings from the risk rules, and the reviews opened to act on them

CREATE TABLE access_findings (
    id            TEXT PRIMARY KEY,
    user_id       TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    finding_type  TEXT NOT NULL
                  CHECK (finding_type IN ('stale_account', 'over_privileged',
                                          'orphaned_guest', 'privileged_no_mfa')),
    risk          TEXT NOT NULL CHECK (risk IN ('high', 'medium', 'low')),
    details       TEXT,
    status        TEXT NOT NULL DEFAULT 'open'
                  CHECK (status IN ('open', 'resolved', 'accepted')),
    detected_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at   TIMESTAMP
);

CREATE TABLE access_reviews (
    id               TEXT PRIMARY KEY,
    finding_id       TEXT REFERENCES access_findings (id) ON DELETE SET NULL,
    subject_user_id  TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    reviewer         TEXT,
    status           TEXT NOT NULL DEFAULT 'open'
                     CHECK (status IN ('open', 'approved', 'revoked')),
    opened_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    decided_at       TIMESTAMP,
    decision_note    TEXT
);

CREATE INDEX idx_findings_user ON access_findings (user_id);
CREATE INDEX idx_findings_status_risk ON access_findings (status, risk);
CREATE INDEX idx_reviews_subject ON access_reviews (subject_user_id);