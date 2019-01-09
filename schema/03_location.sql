CREATE OR REPLACE VIEW location AS
 SELECT telemetry."time",
    telemetry.vehicle,
    (telemetry.state -> 'drive_state'::text) ->> 'shift_state'::text AS shift_state,
    ((telemetry.state -> 'drive_state'::text) ->> 'heading'::text)::double precision AS heading,
    ((telemetry.state -> 'drive_state'::text) ->> 'latitude'::text)::double precision AS latitude,
    ((telemetry.state -> 'drive_state'::text) ->> 'longitude'::text)::double precision AS longitude
   FROM telemetry;
