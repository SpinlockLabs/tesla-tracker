CREATE TABLE IF NOT EXISTS telemetry (
    "time" TIMESTAMP WITH TIME ZONE NOT NULL,
    vehicle BIGINT NOT NULL,
    state JSON NOT NULL,
    CONSTRAINT pkeys PRIMARY KEY ("time", vehicle)
);
