# postgis-docker
**postgis-docker** is a Flask REST API for PostGIS TIGER/Line geocoder using Docker containers. This repo:

1) Incorporates steps described in https://experimentalcraft.wordpress.com/2017/11/01/how-to-make-a-postgis-tiger-geocoder-in-less-than-5-days/ for setting up a PostGIS database with TIGER Geocoder, but does so in a pre-configured Docker container for simple setup.
2) Sets up a simple Python Flask REST API in a second Docker container as a wrapper for the database, binding to port 50000.

## Installation
Setting up PostGIS and loading [US Census TIGER spatial files](https://www.census.gov/programs-surveys/geography.html) can be a pain, with differing setup configurations for Windows and Unix systems, and the awkward necessity of executing SQL statements in PostGRES which output (somewhat error-prone) shell scripts, which in turn must be executed in a very specific order.

**postgis-docker** simplifies the process.
> **These steps assume you already have Docker installed on your computer.** If you don't have Docker installed, install [Docker Desktop](https://docs.docker.com/docker-for-windows/install/) if you're on Windows, `brew cask install docker` if on a Mac, or `apt-get`/`yum` if Linux (the setup varies a bit by Linux distro, so search for instructions appropriate for you).


1) **clone the repo:**
```bash
$ git clone git@github.com:uwrit/postgis-docker.git
```

2) **Create and configure a `.env` file in the root directory for environment variables:**
```bash
$ cd postgis-docker
$ touch .env
```

Edit the file to look like this (set the actual values to your needs):
```bash
POSTGRES_DB=geocoder      # Whatever database name you'd like.
POSTGRES_USER=<usr>       # Database username.
POSTGRES_PASSWORD=<pwd>   # Database password.
GEOCODER_STATES=WA,OR,CA  # Comma-delimited state abbrevations.
                          # postgis-docker will load state TIGER files for each state specified here.
                          # Note: Setting this to "*" (without quotes) will load data for all US states.
GEOCODER_YEAR=2022       # The specific year to download TIGER files for.
                          # (The Census bureau publishes updated files each year)
```

NOTE - 2/15/2024 -  Currently postgis only supports ingesting TIGER files from the year 2022 back. SHP2PGSQL currently cannot consume 2023 format TIGER files.


3) **Create Docker Overlay Network that is attachable**

```
$ docker network create --driver overlay --attachable uw_postgis_net
```

4) **Finally:**
```bash
$ docker-compose up
```

And that's it! Note that that TIGER file-load process may take a while, depending on the US states you configure. The logic for dynamically loading and configuring the TIGER files is in [load_data.sh](./src/db/load_data.sh), which is a script adapted from the PostGIS default TIGER setup scripts, but made reusable and dynamic. Doing all states the download and initialization of the container took 10 hours in a recent implementation (you can use docker logs follow to tail the log in real time and track progress).

After setup is complete, test it out!
```bash
$ # 1410 NE Campus Parkway, Seattle, WA 98195 (the University of Washington)
$ curl http://localhost:50000/latlong?q=1410+NE+Campus+Parkway%2c+Seattle%2c+WA+98195
{
  "building": 1410,
  "city": "Seattle",
  "lat": 47.6563,
  "long": -122.31314,
  "state": "WA",
  "street": "Campus",
  "streetType": "Pkwy",
  "zip": "98195"
}
```

The PostGIS and API containers can be taken down anytime with:
```bash
$ docker-compose down
```


