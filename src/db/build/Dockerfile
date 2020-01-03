# Postgis
FROM mdillon/postgis

ARG db
ARG user
ARG pw
ARG states

# Configure utils
RUN apt-get update \
    && apt-get install -y wget unzip \
    && rm -rf /var/lib/apt/lists/*

# Make data dir
RUN mkdir -p /gisdata \
    && chmod 777 -R /gisdata

# Copy nation an state scripts
COPY ./load_nation.sh ./load_state.sh /docker-entrypoint-initdb.d/

# Overwrite the default /postgis.sh file
COPY ./postgis.sh /docker-entrypoint-initdb.d/

# Set env variables
ENV POSTGRES_DB=${db}
ENV POSTGRES_USER=${user}
ENV POSTGRES_PASSWORD=${pw}
ENV GEOCODER_STATES=${states}
