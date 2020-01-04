# Postgis
FROM mdillon/postgis

# Configure utils
RUN apt-get update \
    && apt-get install -y wget unzip \
    && rm -rf /var/lib/apt/lists/*

# Make data dir
RUN mkdir -p /gisdata \
    && chmod 777 -R /gisdata

# Copy nation an state scripts
COPY ./load_data.sh /docker-entrypoint-initdb.d/

# Overwrite the default /postgis.sh file
COPY ./postgis.sh /docker-entrypoint-initdb.d/