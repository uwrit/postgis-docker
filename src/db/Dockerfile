# Postgis, now official package
FROM postgis/postgis 

# Configure utils, adding postgis client tools for access to shp2pgsql
RUN apt-get update \
    && apt-get install -y wget unzip postgis \
    && rm -rf /var/lib/apt/lists/*

# Make data dir
RUN mkdir -p /gisdata \
    && chmod 777 -R /gisdata

# Copy nation an state scripts
COPY ./load_data.sh /docker-entrypoint-initdb.d/

# Overwrite the default /postgis.sh file
COPY ./postgis.sh /docker-entrypoint-initdb.d/
