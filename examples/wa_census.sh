TMPDIR="/gisdata/temp/"
UNZIPTOOL=unzip
WGETTOOL="/usr/bin/wget"
export PGBIN=/usr/lib/postgresql/11/bin
export PGPORT=5432
export PGHOST=localhost
export PGUSER=postgres
export PGPASSWORD=yourpasswordhere
export PGDATABASE=geocoder
PSQL=${PGBIN}/psql
SHP2PGSQL=shp2pgsql
cd /gisdata

cd /gisdata
wget https://www2.census.gov/geo/tiger/TIGER2019/TRACT/tl_2019_53_tract.zip --mirror --reject=html
cd /gisdata/www2.census.gov/geo/tiger/TIGER2019/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_2019_53*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_tract(CONSTRAINT pk_WA_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); "
${SHP2PGSQL} -D -c -s 4269 -g the_geom   -W "latin1" tl_2019_53_tract.dbf tiger_staging.wa_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WA_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('WA_tract'), lower('WA_tract')); "
${PSQL} -c "CREATE INDEX tiger_data_WA_tract_the_geom_gist ON tiger_data.WA_tract USING gist(the_geom);"
${PSQL} -c "VACUUM ANALYZE tiger_data.WA_tract;"
${PSQL} -c "ALTER TABLE tiger_data.WA_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"

cd /gisdata
wget https://www2.census.gov/geo/tiger/TIGER2019/TABBLOCK/tl_2019_53_tabblock10.zip --mirror --reject=html
cd /gisdata/www2.census.gov/geo/tiger/TIGER2019/TABBLOCK
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_2019_53*_tabblock10.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;
${PSQL} -c "CREATE TABLE tiger_data.WA_tabblock(CONSTRAINT pk_WA_tabblock PRIMARY KEY (tabblock_id)) INHERITS(tiger.tabblock);"
${SHP2PGSQL} -D -c -s 4269 -g the_geom   -W "latin1" tl_2019_53_tabblock10.dbf tiger_staging.wa_tabblock10 | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WA_tabblock10 RENAME geoid10 TO tabblock_id;  SELECT loader_load_staged_data(lower('WA_tabblock10'), lower('WA_tabblock')); "
${PSQL} -c "ALTER TABLE tiger_data.WA_tabblock ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
${PSQL} -c "CREATE INDEX tiger_data_WA_tabblock_the_geom_gist ON tiger_data.WA_tabblock USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.WA_tabblock;"

cd /gisdata
wget https://www2.census.gov/geo/tiger/TIGER2019/BG/tl_2019_53_bg.zip --mirror --reject=html
cd /gisdata/www2.census.gov/geo/tiger/TIGER2019/BG
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_2019_53*_bg.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_bg(CONSTRAINT pk_WA_bg PRIMARY KEY (bg_id)) INHERITS(tiger.bg);"
${SHP2PGSQL} -D -c -s 4269 -g the_geom   -W "latin1" tl_2019_53_bg.dbf tiger_staging.wa_bg | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WA_bg RENAME geoid TO bg_id;  SELECT loader_load_staged_data(lower('WA_bg'), lower('WA_bg')); "
${PSQL} -c "ALTER TABLE tiger_data.WA_bg ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
${PSQL} -c "CREATE INDEX tiger_data_WA_bg_the_geom_gist ON tiger_data.WA_bg USING gist(the_geom);"
${PSQL} -c "vacuum analyze tiger_data.WA_bg;