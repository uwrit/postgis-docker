# postgis-docker
**postgis-docker** is a Flask REST API for PostGIS TIGER/Line geocoder using Docker containers. This repo:

1) Incorporates steps described in https://experimentalcraft.wordpress.com/2017/11/01/how-to-make-a-postgis-tiger-geocoder-in-less-than-5-days/ for setting up a PostGIS database with TIGER Geocoder, but does so in a pre-configured Docker container for simple setup.
2) Sets up a simple Python Flask REST API in a second Docker container as a wrapper for the database, binding to port 5000.

## Overview
Setting up PostGIS and loading [US Census TIGER spatial files](https://www.census.gov/programs-surveys/geography.html) can be a pain, with differing setup configurations for Windows and Unix systems, and the awkward necessity of executing SQL statements in PostGRES which output shell scripts, which in turn must be executed and are somewhat error prone.

**postgis-docker** simplifies the process. **These steps assume you already have Docker installed on your computer.**


Simply clone the repo:
```bash
$ git clone git@github.com:uwrit/postgis-docker.git
```

Create and configure a `.env` file in the root directory for environment variables:
```bash
$ cd postgis-docker
$ touch .env
```

The file should look like this:
```bash
POSTGRES_DB=geocoder      # Whatever database name you'd like.
POSTGRES_USER=<usr>       # Your username .
POSTGRES_PASSWORD=<pwd>   # Your password.
GEOCODER_STATES=WA,OR,CA  # Comma-delimited state abbrevations.
                          # postgis-docker will load state TIGER files for each state specified here.
                          # Note: Setting this to "*" (without quotes) will load data for all US states.
GEOCODER_YEAR=2017        # The specific year to download TIGER files for.
                          # (The Census bureau publishes updated files each year)
```

Then just:
```bash
$ docker-compose up
```

The build process will install PostGRES and PostGIS using the PostGRES base Docker image. The logic for dynamically loading and configuring the TIGER files is in [load_data.sh](./src/db/load_data.sh), which is a script adapted from the PostGIS default scripts TIGER setup scripts, but made reusable and dynamic.


