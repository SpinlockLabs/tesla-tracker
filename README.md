# Tesla Tracker

Track your Tesla, smartly!

## Setup

### Requirements

- [PostgreSQL](https://www.postgresql.org/download/) (v9.8+)
- [Dart](https://www.dartlang.org/tools/sdk#install) (v2.0.0+)

### Configuration

Create a configuration file at `config.json` using the example `config.example.json`:

```json
{
  "db.name": "tesla",
  "db.host": "127.0.0.1",
  "db.port": 5432,
  "db.username": "tesla",
  "db.password": "tesla",
  "http.port": 8090,
  "http.token": "MySecretToken",
  "tesla.email": "me@example.com",
  "tesla.password": "I<3Elon"
}
```

### Running

Run the following command to start tracking your vehicles into PostgreSQL:

```bash
$ dart bin/track.dart config.json
New controller available at http://127.0.0.1:8090/control/534732737344344?token=MySecretToken
```

### Controlling

Once at the controller, you can start, stop, sleep, and wake the tracker.

- Start: Begin tracking the vehicle's telemetry every 30 seconds.
- Stop: Stop tracking the vehicle's telemetry.
- Sleep: Pause tracking of the vehicle's telemetry for 1 hour to allow for vehicle sleep.
- Wake: Wake up the vehicle from sleep and start tracking.
