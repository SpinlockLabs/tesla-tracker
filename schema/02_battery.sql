CREATE OR REPLACE VIEW battery AS
 SELECT telemetry."time",
    telemetry.vehicle,
    ((telemetry.state -> 'charge_state'::text) ->> 'battery_level'::text)::integer AS battery_level,
    ((telemetry.state -> 'charge_state'::text) ->> 'battery_range'::text)::double precision AS battery_range,
    ((telemetry.state -> 'charge_state'::text) ->> 'est_battery_range'::text)::double precision AS est_battery_range,
    ((telemetry.state -> 'charge_state'::text) ->> 'ideal_battery_range'::text)::double precision AS ideal_battery_range,
    (telemetry.state -> 'charge_state'::text) ->> 'charging_state'::text AS charging_state,
    ((telemetry.state -> 'charge_state'::text) ->> 'time_to_full_charge'::text)::double precision AS hours_until_full,
    ((telemetry.state -> 'charge_state'::text) ->> 'charge_rate'::text)::double precision AS charge_rate,
    ((telemetry.state -> 'charge_state'::text) ->> 'charge_miles_added_ideal'::text)::double precision AS charge_miles_added_ideal,
    ((telemetry.state -> 'charge_state'::text) ->> 'charge_miles_added_rated'::text)::double precision AS charge_miles_added_rated
   FROM telemetry;
