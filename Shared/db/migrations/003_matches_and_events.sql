-- Minimal soccer core (extended on Day 37) and a generic event log

CREATE TABLE teams (
    id       TEXT PRIMARY KEY,
    name     TEXT NOT NULL UNIQUE,
    country  TEXT
);

CREATE TABLE matches (
    id             TEXT PRIMARY KEY,
    home_team_id   TEXT NOT NULL REFERENCES teams (id),
    away_team_id   TEXT NOT NULL REFERENCES teams (id),
    kickoff_at     TIMESTAMP NOT NULL,
    status         TEXT NOT NULL DEFAULT 'scheduled'
                   CHECK (status IN ('scheduled', 'live', 'finished')),
    home_score     INTEGER,
    away_score     INTEGER,
    CHECK (home_team_id <> away_team_id)
);

CREATE TABLE events (
    id           TEXT PRIMARY KEY,
    source       TEXT NOT NULL,
    event_type   TEXT NOT NULL,
    entity_type  TEXT,
    entity_id    TEXT,
    payload      TEXT,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_matches_kickoff ON matches (kickoff_at);
CREATE INDEX idx_events_entity ON events (entity_type, entity_id);
CREATE INDEX idx_events_created ON events (created_at);