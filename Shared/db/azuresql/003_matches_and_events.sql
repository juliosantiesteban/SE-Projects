CREATE TABLE teams (
    id       NVARCHAR(64)  NOT NULL PRIMARY KEY,
    name     NVARCHAR(256) NOT NULL UNIQUE,
    country  NVARCHAR(64)  NULL
);

CREATE TABLE matches (
    id             NVARCHAR(64) NOT NULL PRIMARY KEY,
    home_team_id   NVARCHAR(64) NOT NULL REFERENCES teams (id),
    away_team_id   NVARCHAR(64) NOT NULL REFERENCES teams (id),
    kickoff_at     DATETIME2    NOT NULL,
    status         NVARCHAR(16) NOT NULL DEFAULT 'scheduled'
                   CHECK (status IN ('scheduled', 'live', 'finished')),
    home_score     INT          NULL,
    away_score     INT          NULL,
    CHECK (home_team_id <> away_team_id)
);

CREATE TABLE events (
    id           NVARCHAR(64)  NOT NULL PRIMARY KEY,
    source       NVARCHAR(64)  NOT NULL,
    event_type   NVARCHAR(64)  NOT NULL,
    entity_type  NVARCHAR(64)  NULL,
    entity_id    NVARCHAR(64)  NULL,
    payload      NVARCHAR(MAX) NULL,
    created_at   DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE INDEX idx_matches_kickoff ON matches (kickoff_at);
CREATE INDEX idx_events_entity ON events (entity_type, entity_id);
CREATE INDEX idx_events_created ON events (created_at);