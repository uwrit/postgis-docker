TMPDIR="/gisdata/temp/"
UNZIPTOOL=unzip
WGETTOOL="/usr/bin/wget"
export PGBIN=/usr/lib/postgresql/10/bin
export PGPORT=5432
export PGHOST=localhost
export PGUSER=postgres
export PGPASSWORD=yourpasswordhere
export PGDATABASE=geocoder
PSQL=${PGBIN}/psql
SHP2PGSQL=shp2pgsql
cd /gisdata

cd /gisdata
wget https://www2.census.gov/geo/tiger/TIGER2017/PLACE/tl_2017_53_place.zip --mirror --reject=html
cd /gisdata/www2.census.gov/geo/tiger/TIGER2017/PLACE
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_2017_53*_place.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_place(CONSTRAINT pk_WA_place PRIMARY KEY (plcidfp) ) INHERITS(tiger.place);" 
${SHP2PGSQL} -D -c -s 4269 -g the_geom   -W "latin1" tl_2017_53_place.dbf tiger_staging.wa_place | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WA_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('WA_place'), lower('WA_place')); ALTER TABLE tiger_data.WA_place ADD CONSTRAINT uidx_WA_place_gid UNIQUE (gid);"
${PSQL} -c "CREATE INDEX idx_WA_place_soundex_name ON tiger_data.WA_place USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX tiger_data_WA_place_the_geom_gist ON tiger_data.WA_place USING gist(the_geom);"
${PSQL} -c "ALTER TABLE tiger_data.WA_place ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
cd /gisdata
wget https://www2.census.gov/geo/tiger/TIGER2017/COUSUB/tl_2017_53_cousub.zip --mirror --reject=html
cd /gisdata/www2.census.gov/geo/tiger/TIGER2017/COUSUB
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_2017_53*_cousub.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_cousub(CONSTRAINT pk_WA_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_WA_cousub_gid UNIQUE (gid)) INHERITS(tiger.cousub);" 
${SHP2PGSQL} -D -c -s 4269 -g the_geom   -W "latin1" tl_2017_53_cousub.dbf tiger_staging.wa_cousub | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WA_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('WA_cousub'), lower('WA_cousub')); ALTER TABLE tiger_data.WA_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
${PSQL} -c "CREATE INDEX tiger_data_WA_cousub_the_geom_gist ON tiger_data.WA_cousub USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_cousub_countyfp ON tiger_data.WA_cousub USING btree(countyfp);"
cd /gisdata
wget https://www2.census.gov/geo/tiger/TIGER2017/TRACT/tl_2017_53_tract.zip --mirror --reject=html
cd /gisdata/www2.census.gov/geo/tiger/TIGER2017/TRACT
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_2017_53*_tract.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_tract(CONSTRAINT pk_WA_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
${SHP2PGSQL} -D -c -s 4269 -g the_geom   -W "latin1" tl_2017_53_tract.dbf tiger_staging.wa_tract | ${PSQL}
${PSQL} -c "ALTER TABLE tiger_staging.WA_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('WA_tract'), lower('WA_tract')); "
	${PSQL} -c "CREATE INDEX tiger_data_WA_tract_the_geom_gist ON tiger_data.WA_tract USING gist(the_geom);"
	${PSQL} -c "VACUUM ANALYZE tiger_data.WA_tract;"
	${PSQL} -c "ALTER TABLE tiger_data.WA_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
cd /gisdata
wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53001_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53003_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53005_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53007_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53009_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53011_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53013_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53015_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53017_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53019_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53021_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53023_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53025_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53027_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53029_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53031_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53033_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53035_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53037_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53039_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53041_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53043_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53045_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53047_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53049_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53051_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53053_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53055_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53057_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53059_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53061_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53063_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53065_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53067_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53069_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53071_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53073_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53075_faces.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_53077_faces.zip 
cd /gisdata/www2.census.gov/geo/tiger/TIGER2017/FACES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_53*_faces*.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_faces(CONSTRAINT pk_WA_faces PRIMARY KEY (gid)) INHERITS(tiger.faces);" 
for z in *faces*.dbf; do
${SHP2PGSQL} -D   -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WA_faces | ${PSQL}
${PSQL} -c "SELECT loader_load_staged_data(lower('WA_faces'), lower('WA_faces'));"
done

${PSQL} -c "CREATE INDEX tiger_data_WA_faces_the_geom_gist ON tiger_data.WA_faces USING gist(the_geom);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WA_faces_tfid ON tiger_data.WA_faces USING btree (tfid);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WA_faces_countyfp ON tiger_data.WA_faces USING btree (countyfp);"
	${PSQL} -c "ALTER TABLE tiger_data.WA_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
	${PSQL} -c "vacuum analyze tiger_data.WA_faces;"
cd /gisdata
wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53001_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53003_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53005_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53007_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53009_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53011_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53013_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53015_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53017_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53019_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53021_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53023_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53025_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53027_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53029_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53031_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53033_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53035_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53037_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53039_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53041_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53043_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53045_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53047_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53049_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53051_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53053_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53055_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53057_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53059_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53061_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53063_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53065_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53067_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53069_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53071_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53073_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53075_featnames.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_53077_featnames.zip 
cd /gisdata/www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_53*_featnames*.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_featnames(CONSTRAINT pk_WA_featnames PRIMARY KEY (gid)) INHERITS(tiger.featnames);ALTER TABLE tiger_data.WA_featnames ALTER COLUMN statefp SET DEFAULT '53';" 
for z in *featnames*.dbf; do
${SHP2PGSQL} -D   -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WA_featnames | ${PSQL}
${PSQL} -c "SELECT loader_load_staged_data(lower('WA_featnames'), lower('WA_featnames'));"
done

${PSQL} -c "CREATE INDEX idx_tiger_data_WA_featnames_snd_name ON tiger_data.WA_featnames USING btree (soundex(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_featnames_lname ON tiger_data.WA_featnames USING btree (lower(name));"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_featnames_tlid_statefp ON tiger_data.WA_featnames USING btree (tlid,statefp);"
${PSQL} -c "ALTER TABLE tiger_data.WA_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
${PSQL} -c "vacuum analyze tiger_data.WA_featnames;"
cd /gisdata
wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53001_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53003_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53005_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53007_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53009_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53011_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53013_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53015_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53017_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53019_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53021_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53023_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53025_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53027_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53029_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53031_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53033_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53035_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53037_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53039_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53041_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53043_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53045_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53047_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53049_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53051_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53053_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53055_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53057_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53059_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53061_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53063_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53065_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53067_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53069_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53071_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53073_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53075_edges.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_53077_edges.zip 
cd /gisdata/www2.census.gov/geo/tiger/TIGER2017/EDGES/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_53*_edges*.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_edges(CONSTRAINT pk_WA_edges PRIMARY KEY (gid)) INHERITS(tiger.edges);"
for z in *edges*.dbf; do
${SHP2PGSQL} -D   -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WA_edges | ${PSQL}
${PSQL} -c "SELECT loader_load_staged_data(lower('WA_edges'), lower('WA_edges'));"
done

${PSQL} -c "ALTER TABLE tiger_data.WA_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_edges_tlid ON tiger_data.WA_edges USING btree (tlid);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_edgestfidr ON tiger_data.WA_edges USING btree (tfidr);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_edges_tfidl ON tiger_data.WA_edges USING btree (tfidl);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_edges_countyfp ON tiger_data.WA_edges USING btree (countyfp);"
${PSQL} -c "CREATE INDEX tiger_data_WA_edges_the_geom_gist ON tiger_data.WA_edges USING gist(the_geom);"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_edges_zipl ON tiger_data.WA_edges USING btree (zipl);"
${PSQL} -c "CREATE TABLE tiger_data.WA_zip_state_loc(CONSTRAINT pk_WA_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(tiger.zip_state_loc);"
${PSQL} -c "INSERT INTO tiger_data.WA_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'WA', '53', p.name FROM tiger_data.WA_edges AS e INNER JOIN tiger_data.WA_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.WA_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_zip_state_loc_place ON tiger_data.WA_zip_state_loc USING btree(soundex(place));"
${PSQL} -c "ALTER TABLE tiger_data.WA_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
${PSQL} -c "vacuum analyze tiger_data.WA_edges;"
${PSQL} -c "vacuum analyze tiger_data.WA_zip_state_loc;"
${PSQL} -c "CREATE TABLE tiger_data.WA_zip_lookup_base(CONSTRAINT pk_WA_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(tiger.zip_lookup_base);"
${PSQL} -c "INSERT INTO tiger_data.WA_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'WA', c.name,p.name,'53'  FROM tiger_data.WA_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '53') INNER JOIN tiger_data.WA_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.WA_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
${PSQL} -c "ALTER TABLE tiger_data.WA_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
${PSQL} -c "CREATE INDEX idx_tiger_data_WA_zip_lookup_base_citysnd ON tiger_data.WA_zip_lookup_base USING btree(soundex(city));"
cd /gisdata
wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53001_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53003_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53005_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53007_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53009_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53011_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53013_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53015_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53017_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53019_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53021_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53023_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53025_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53027_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53029_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53031_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53033_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53035_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53037_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53039_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53041_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53043_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53045_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53047_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53049_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53051_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53053_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53055_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53057_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53059_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53061_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53063_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53065_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53067_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53069_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53071_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53073_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53075_addr.zip 
 wget --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_53077_addr.zip 
cd /gisdata/www2.census.gov/geo/tiger/TIGER2017/ADDR/
rm -f ${TMPDIR}/*.*
${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
${PSQL} -c "CREATE SCHEMA tiger_staging;"
for z in tl_*_53*_addr*.zip ; do $UNZIPTOOL -o -d $TMPDIR $z; done
cd $TMPDIR;

${PSQL} -c "CREATE TABLE tiger_data.WA_addr(CONSTRAINT pk_WA_addr PRIMARY KEY (gid)) INHERITS(tiger.addr);ALTER TABLE tiger_data.WA_addr ALTER COLUMN statefp SET DEFAULT '53';" 
for z in *addr*.dbf; do
${SHP2PGSQL} -D   -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.WA_addr | ${PSQL}
${PSQL} -c "SELECT loader_load_staged_data(lower('WA_addr'), lower('WA_addr'));"
done

${PSQL} -c "ALTER TABLE tiger_data.WA_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WA_addr_least_address ON tiger_data.WA_addr USING btree (least_hn(fromhn,tohn) );"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WA_addr_tlid_statefp ON tiger_data.WA_addr USING btree (tlid, statefp);"
	${PSQL} -c "CREATE INDEX idx_tiger_data_WA_addr_zip ON tiger_data.WA_addr USING btree (zip);"
	${PSQL} -c "CREATE TABLE tiger_data.WA_zip_state(CONSTRAINT pk_WA_zip_state PRIMARY KEY(zip,stusps)) INHERITS(tiger.zip_state); "
	${PSQL} -c "INSERT INTO tiger_data.WA_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'WA', '53' FROM tiger_data.WA_addr WHERE zip is not null;"
	${PSQL} -c "ALTER TABLE tiger_data.WA_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '53');"
	${PSQL} -c "vacuum analyze tiger_data.WA_addr;"