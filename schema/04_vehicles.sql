CREATE OR REPLACE VIEW vehicles AS
 SELECT a.vehicle,
    a.state ->> 'vin'::text AS vin,
    a.state ->> 'display_name'::text AS display_name,
    a.state
   FROM telemetry a
     JOIN ( SELECT telemetry.vehicle,
            max(telemetry."time") AS latest_time
           FROM telemetry
          GROUP BY telemetry.vehicle) b ON a."time" = b.latest_time;
