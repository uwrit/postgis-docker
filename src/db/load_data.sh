GISDATA="/gisdata"
TMPDIR="${GISDATA}/temp/"
UNZIPTOOL=unzip
YEAR=$GEOCODER_YEAR
BASEPATH="www2.census.gov/geo/tiger/TIGER${YEAR}"
BASEURL="https://${BASEPATH}"

export PGPASSWORD=$POSTGRES_PASSWORD
PSQL="psql -U $POSTGRES_USER -d $POSTGRES_DB"
SHP2PGSQL=shp2pgsql
mkdir -p ${TMPDIR}

get_fips_from_abbr () {
    local abbr=$1
    local fips=0
    case $abbr in
        "AL")  fips=01;; "AK")  fips=02;; "AS")  fips=60;; "AZ")  fips=04;; "AR")  fips=05;;
        "CA")  fips=06;; "CO")  fips=08;; "CT")  fips=09;; "DE")  fips=10;; "DC")  fips=11;;
        "FL")  fips=12;; "FM")  fips=64;; "GA")  fips=13;; "GU")  fips=66;; "HI")  fips=15;;
        "ID")  fips=16;; "IL")  fips=17;; "IN")  fips=18;; "IA")  fips=19;; "KS")  fips=20;;
        "KY")  fips=21;; "LA")  fips=22;; "ME")  fips=23;; "MH")  fips=68;; "MD")  fips=24;;
        "MA")  fips=25;; "MI")  fips=26;; "MN")  fips=27;; "MS")  fips=28;; "MO")  fips=29;;
        "MT")  fips=30;; "NE")  fips=31;; "NV")  fips=32;; "NH")  fips=33;; "NJ")  fips=34;;
        "NM")  fips=35;; "NY")  fips=36;; "NC")  fips=37;; "ND")  fips=38;; "MP")  fips=69;;
        "OH")  fips=39;; "OK")  fips=40;; "OR")  fips=41;; "PW")  fips=70;; "PA")  fips=42;;
        "PR")  fips=72;; "RI")  fips=44;; "SC")  fips=45;; "SD")  fips=46;; "TN")  fips=47;;
        "TX")  fips=48;; "UM")  fips=74;; "UT")  fips=49;; "VT")  fips=50;; "VA")  fips=51;;
        "VI")  fips=78;; "WA")  fips=53;; "WV")  fips=54;; "WI")  fips=55;; "WY")  fips=56;;
    esac
    echo $fips
}

get_fips_files () {
    local url=$1
    local fips=$2
    local files=($(wget --no-verbose -O - $url \
        | perl -nle 'print if m{(?=\"tl)(.*?)(?<=>)}g' \
        | perl -nle 'print m{(?=\"tl)(.*?)(?<=>)}g' \
        | sed -e 's/[\">]//g'))
    local matched=($(echo "${files[*]}" | tr ' ' '\n' | grep "tl_${YEAR}_${fips}"))
    echo "${matched[*]}"
}

create_extensions () {
    ${PSQL} -c "CREATE EXTENSION IF NOT EXISTS postgis;"
    ${PSQL} -c "CREATE EXTENSION IF NOT EXISTS postgis_topology;"
    ${PSQL} -c "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;"
    ${PSQL} -c "CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;"
    ${PSQL} -c "CREATE EXTENSION IF NOT EXISTS address_standardizer;"
}

create_indicies () {
    ${PSQL} -c "SELECT install_missing_indexes();"
    ${PSQL} -c "vacuum (analyze, verbose) tiger.addr;"
    ${PSQL} -c "vacuum (analyze, verbose) tiger.edges;"
    ${PSQL} -c "vacuum (analyze, verbose) tiger.faces;"
    ${PSQL} -c "vacuum (analyze, verbose) tiger.featnames;"
    ${PSQL} -c "vacuum (analyze, verbose) tiger.place;"
    ${PSQL} -c "vacuum (analyze, verbose) tiger.cousub;"
    ${PSQL} -c "vacuum (analyze, verbose) tiger.county;"
    ${PSQL} -c "vacuum (analyze, verbose) tiger.state;"
    ${PSQL} -c "vacuum (analyze, verbose) tiger.zip_lookup_base;"
    ${PSQL} -c "vacuum (analyze, verbose) tiger.zip_state;"
    ${PSQL} -c "vacuum (analyze, verbose) tiger.zip_state_loc;"
}

load_national_data () {
    cd $GISDATA
    wget ${BASEURL}/STATE/tl_${YEAR}_us_state.zip --mirror --reject=html --no-verbose
    cd ${BASEPATH}/STATE
    rm -f ${TMPDIR}/*.*

    ${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
    ${PSQL} -c "CREATE SCHEMA tiger_staging;"
    $UNZIPTOOL tl_${YEAR}_us_state.zip
    for z in tl_*state.zip ; 
    do 
        $UNZIPTOOL -o -d $TMPDIR $z; 
    done
    cd $TMPDIR;

    ${PSQL} -c "CREATE TABLE tiger_data.state_all(CONSTRAINT pk_state_all PRIMARY KEY (statefp),CONSTRAINT uidx_state_all_stusps  UNIQUE (stusps), CONSTRAINT uidx_state_all_gid UNIQUE (gid) ) INHERITS(tiger.state); "
    ${SHP2PGSQL} -D -c -s 4269 -g the_geom -W "latin1" tl_${YEAR}_us_state.dbf tiger_staging.state | ${PSQL}
    ${PSQL} -c "SELECT loader_load_staged_data(lower('state'), lower('state_all')); "
    ${PSQL} -c "CREATE INDEX tiger_data_state_all_the_geom_gist ON tiger_data.state_all USING gist(the_geom);"
    ${PSQL} -c "VACUUM ANALYZE tiger_data.state_all"
    cd $GISDATA
    wget ${BASEURL}/COUNTY/tl_${YEAR}_us_county.zip --mirror --reject=html --no-verbose
    cd $GISDATA/${BASEPATH}/COUNTY
    rm -f ${TMPDIR}/*.*
    ${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
    ${PSQL} -c "CREATE SCHEMA tiger_staging;"
    for z in tl_*county.zip ; 
    do 
        $UNZIPTOOL -o -d $TMPDIR $z; 
    done
    cd $TMPDIR;

    ${PSQL} -c "CREATE TABLE tiger_data.county_all(CONSTRAINT pk_tiger_data_county_all PRIMARY KEY (cntyidfp),CONSTRAINT uidx_tiger_data_county_all_gid UNIQUE (gid)  ) INHERITS(tiger.county); " 
    ${SHP2PGSQL} -D -c -s 4269 -g the_geom -W "latin1" tl_${YEAR}_us_county.dbf tiger_staging.county | ${PSQL}
    ${PSQL} -c "ALTER TABLE tiger_staging.county RENAME geoid TO cntyidfp;  SELECT loader_load_staged_data(lower('county'), lower('county_all'));"
    ${PSQL} -c "CREATE INDEX tiger_data_county_the_geom_gist ON tiger_data.county_all USING gist(the_geom);"
    ${PSQL} -c "CREATE UNIQUE INDEX uidx_tiger_data_county_all_statefp_countyfp ON tiger_data.county_all USING btree(statefp,countyfp);"
    ${PSQL} -c "CREATE TABLE tiger_data.county_all_lookup ( CONSTRAINT pk_county_all_lookup PRIMARY KEY (st_code, co_code)) INHERITS (tiger.county_lookup);"
    ${PSQL} -c "VACUUM ANALYZE tiger_data.county_all;"
    ${PSQL} -c "INSERT INTO tiger_data.county_all_lookup(st_code, state, co_code, name) SELECT CAST(s.statefp as integer), s.abbrev, CAST(c.countyfp as integer), c.name FROM tiger_data.county_all As c INNER JOIN state_lookup As s ON s.statefp = c.statefp;"
    ${PSQL} -c "VACUUM ANALYZE tiger_data.county_all_lookup;"
}

load_state_data () {
    ABBR=$1
    abbr=$(echo "$ABBR" | perl -ne 'print lc')
    FIPS=$2

    #############
    # Place
    #############                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
    cd $GISDATA                                                                                                                                                                                                                                                                                                                                                                                                                                                       
    wget $BASEURL/PLACE/tl_${YEAR}_${FIPS}_place.zip --mirror --reject=html --no-verbose                                                                                                                                                                                                                                                                                                                                                                    
    cd $GISDATA/$BASEPATH/PLACE                                                                                                                                                                                                                                                                                                                                                                                                                       
    rm -f ${TMPDIR}/*.*                                                                                                                                                                                                                                                                                                                                                                                                                                                         
    ${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"                                                                                                                                                                                                                                                                                                                                                                                                                   
    ${PSQL} -c "CREATE SCHEMA tiger_staging;"                                                                                                                                                                                                                                                                                                                                                                                                                                   
    for z in tl_${YEAR}_${FIPS}*_place.zip ; 
    do 
        $UNZIPTOOL -o -d $TMPDIR $z; 
    done
    cd $TMPDIR;                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    ${PSQL} -c "CREATE TABLE tiger_data.${abbr}_place(CONSTRAINT pk_${abbr}_place PRIMARY KEY (plcidfp) ) INHERITS(tiger.place);"                                                                                                                                                                                                                                                                                                                                               
    ${SHP2PGSQL} -D -c -s 4269 -g the_geom -W "latin1" tl_${YEAR}_${FIPS}_place.dbf tiger_staging.${abbr}_place | ${PSQL}                                                                                                                                                                                                                                                                                                                                                             
    ${PSQL} -c "ALTER TABLE tiger_staging.${abbr}_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('${abbr}_place'), lower('${abbr}_place')); ALTER TABLE tiger_data.${abbr}_place ADD CONSTRAINT uidx_${abbr}_place_gid UNIQUE (gid);"                                                                                                                                                                                                                       
    ${PSQL} -c "CREATE INDEX idx_${abbr}_place_soundex_name ON tiger_data.${abbr}_place USING btree (soundex(name));"                                                                                                                                                                                                                                                                                                                                                           
    ${PSQL} -c "CREATE INDEX tiger_data_${abbr}_place_the_geom_gist ON tiger_data.${abbr}_place USING gist(the_geom);"                                                                                                                                                                                                                                                                                                                                                          
    ${PSQL} -c "ALTER TABLE tiger_data.${abbr}_place ADD CONSTRAINT chk_statefp CHECK (statefp = '${FIPS}');"

    #############
    # Cousub
    #############   
    cd $GISDATA                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
    wget $BASEURL/COUSUB/tl_${YEAR}_${FIPS}_cousub.zip --mirror --reject=html --no-verbose
    cd $GISDATA/$BASEPATH/COUSUB                                                                                                                                                                                                                                                                                                                                                                                                                      
    rm -f ${TMPDIR}/*.*                                                                                                                                                                                                                                                                                                                                                                                                                                                         
    ${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"                                                                                                                                                                                                                                                                                                                                                                                                                   
    ${PSQL} -c "CREATE SCHEMA tiger_staging;"                                                                                                                                                                                                                                                                                                                                                                                                                                   
    for z in tl_${YEAR}_${FIPS}*_cousub.zip ; 
    do 
        $UNZIPTOOL -o -d $TMPDIR $z; 
    done
    cd $TMPDIR;                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    ${PSQL} -c "CREATE TABLE tiger_data.${abbr}_cousub(CONSTRAINT pk_${abbr}_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_${abbr}_cousub_gid UNIQUE (gid)) INHERITS(tiger.cousub);"                                                                                                                                                                                                                                                                                           
    ${SHP2PGSQL} -D -c -s 4269 -g the_geom -W "latin1" tl_${YEAR}_${FIPS}_cousub.dbf tiger_staging.${abbr}_cousub | ${PSQL}                                                                                                                                                                                                                                                                                                                                                           
    ${PSQL} -c "ALTER TABLE tiger_staging.${abbr}_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('${abbr}_cousub'), lower('${abbr}_cousub')); ALTER TABLE tiger_data.${abbr}_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '${FIPS}');"                                                                                                                                                                                                              
    ${PSQL} -c "CREATE INDEX tiger_data_${abbr}_cousub_the_geom_gist ON tiger_data.${abbr}_cousub USING gist(the_geom);"                                                                                                                                                                                                                                                                                                                                                        
    ${PSQL} -c "CREATE INDEX idx_tiger_data_${abbr}_cousub_countyfp ON tiger_data.${abbr}_cousub USING btree(countyfp);"      

    #############
    # Tract
    #############   
    cd $GISDATA                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
    wget $BASEURL/TRACT/tl_${YEAR}_${FIPS}_tract.zip --mirror --reject=html --no-verbose
    cd $GISDATA/$BASEPATH/TRACT                                                                                                                                                                                                                                                                                                                                                                                                                       
    rm -f ${TMPDIR}/*.*                                                                                                                                                                                                                                                                                                                                                                                                                                                         
    ${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"                                                                                                                                                                                                                                                                                                                                                                                                                   
    ${PSQL} -c "CREATE SCHEMA tiger_staging;"                                                                                                                                                                                                                                                                                                                                                                                                                                   
    for z in tl_${YEAR}_${FIPS}*_tract.zip ; 
    do 
        $UNZIPTOOL -o -d $TMPDIR $z; 
    done
    cd $TMPDIR;                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    ${PSQL} -c "CREATE TABLE tiger_data.${abbr}_tract(CONSTRAINT pk_${abbr}_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); "                                                                                                                                                                                                                                                                                                                                             
    ${SHP2PGSQL} -D -c -s 4269 -g the_geom -W "latin1" tl_${YEAR}_${FIPS}_tract.dbf tiger_staging.${abbr}_tract | ${PSQL}                                                                                                                                                                                                                                                                                                                                                             
    ${PSQL} -c "ALTER TABLE tiger_staging.${abbr}_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('${abbr}_tract'), lower('${abbr}_tract')); "                                                                                                                                                                                                                                                                                                            
    ${PSQL} -c "CREATE INDEX tiger_data_${abbr}_tract_the_geom_gist ON tiger_data.${abbr}_tract USING gist(the_geom);"                                                                                                                                                                                                                                                                                                                                                  
    ${PSQL} -c "VACUUM ANALYZE tiger_data.${abbr}_tract;"                                                                                                                                                                                                                                                                                                                                                                                                               
    ${PSQL} -c "ALTER TABLE tiger_data.${abbr}_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '${FIPS}');"   

    #############
    # Faces
    #############                                                                                                                                                                                                                                                                                                                                                           
    cd $GISDATA
    files=($(get_fips_files $BASEURL/FACES $FIPS))

    for i in "${files[@]}"
    do
        wget $BASEURL/FACES/$i --no-verbose --mirror 
    done

    cd $GISDATA/$BASEPATH/FACES/                                                                                                                                                                                                                                                                                                                                                                                                                      
    rm -f ${TMPDIR}/*.*                                                                                                                                                                                                                                                                                                                                                                                                                                                         
    ${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"                                                                                                                                                                                                                                                                                                                                                                                                                   
    ${PSQL} -c "CREATE SCHEMA tiger_staging;"                                                                                                                                                                                                                                                                                                                                                                                                                                   
    for z in tl_${YEAR}_${FIPS}*_faces*.zip ; 
    do 
        $UNZIPTOOL -o -d $TMPDIR $z; 
    done
    cd $TMPDIR;                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    ${PSQL} -c "CREATE TABLE tiger_data.${abbr}_faces(CONSTRAINT pk_${abbr}_faces PRIMARY KEY (gid)) INHERITS(tiger.faces);"                                                                                                                                                                                                                                                                                                                                                    
    for z in *faces*.dbf; do                                                                                                                                                                                                                                                                                                                                                                                                                                                    
        ${SHP2PGSQL} -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.${abbr}_faces | ${PSQL}                                                                                                                                                                                                                                                                                                                                                                               
        ${PSQL} -c "SELECT loader_load_staged_data(lower('${abbr}_faces'), lower('${abbr}_faces'));"                                                                                                                                                                                                                                                                                                                                                                                
    done                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    ${PSQL} -c "CREATE INDEX tiger_data_${abbr}_faces_the_geom_gist ON tiger_data.${abbr}_faces USING gist(the_geom);"                                                                                                                                                                                                                                                                                                                                                          
    ${PSQL} -c "CREATE INDEX idx_tiger_data_${abbr}_faces_tfid ON tiger_data.${abbr}_faces USING btree (tfid);"                                                                                                                                                                                                                                                                                                                                                         
    ${PSQL} -c "CREATE INDEX idx_tiger_data_${abbr}_faces_countyfp ON tiger_data.${abbr}_faces USING btree (countyfp);"                                                                                                                                                                                                                                                                                                                                                 
    ${PSQL} -c "ALTER TABLE tiger_data.${abbr}_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '${FIPS}');"                                                                                                                                                                                                                                                                                                                                                           
    ${PSQL} -c "vacuum analyze tiger_data.${abbr}_faces;"                       

    #############
    # FeatNames
    #############                                                                                                                                                                                                                                                                                                                                                                                           
    cd $GISDATA
    files=($(get_fips_files $BASEURL/FEATNAMES $FIPS))

    for i in "${files[@]}"
    do
        wget $BASEURL/FEATNAMES/$i --no-verbose --mirror 
    done

    cd $GISDATA/$BASEPATH/FEATNAMES/
    rm -f ${TMPDIR}/*.*                                                                                                                                                                                                                                                                                                                                                                                                                                                         
    ${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"                                                                                                                                                                                                                                                                                                                                                                                                                   
    ${PSQL} -c "CREATE SCHEMA tiger_staging;"                                                                                                                                                                                                                                                                                                                                                                                                                                   
    for z in tl_${YEAR}_${FIPS}*_featnames*.zip ; 
    do 
        $UNZIPTOOL -o -d $TMPDIR $z;
    done
    cd $TMPDIR;                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    ${PSQL} -c "CREATE TABLE tiger_data.${abbr}_featnames(CONSTRAINT pk_${abbr}_featnames PRIMARY KEY (gid)) INHERITS(tiger.featnames);ALTER TABLE tiger_data.${abbr}_featnames ALTER COLUMN statefp SET DEFAULT '${FIPS}';"                                                                                                                                                                                                                                                    
    for z in *featnames*.dbf; do                                                                                                                                                                                                                                                                                                                                                                                                                                                
        ${SHP2PGSQL} -D   -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.${abbr}_featnames | ${PSQL}                                                                                                                                                                                                                                                                                                                                                                           
        ${PSQL} -c "SELECT loader_load_staged_data(lower('${abbr}_featnames'), lower('${abbr}_featnames'));"                                                                                                                                                                                                                                                                                                                                                                        
    done                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    ${PSQL} -c "CREATE INDEX idx_tiger_data_${abbr}_featnames_snd_name ON tiger_data.${abbr}_featnames USING btree (soundex(name));"                                                                                                                                                                                                                                                                                                                                            
    ${PSQL} -c "CREATE INDEX idx_tiger_data_${abbr}_featnames_lname ON tiger_data.${abbr}_featnames USING btree (lower(name));"                                                                                                                                                                                                                                                                                                                                                 
    ${PSQL} -c "CREATE INDEX idx_tiger_data_${abbr}_featnames_tlid_statefp ON tiger_data.${abbr}_featnames USING btree (tlid,statefp);"                                                                                                                                                                                                                                                                                                                                         
    ${PSQL} -c "ALTER TABLE tiger_data.${abbr}_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '${FIPS}');"                                                                                                                                                                                                                                                                                                                                                               
    ${PSQL} -c "vacuum analyze tiger_data.${abbr}_featnames;"    

    #############
    # Edges
    #############   
    cd $GISDATA
    files=($(get_fips_files $BASEURL/EDGES $FIPS))

    for i in "${files[@]}"
    do
        wget $BASEURL/EDGES/$i --no-verbose --mirror 
    done

    cd $GISDATA/$BASEPATH/EDGES/
    rm -f ${TMPDIR}/*.*                                                                                                                                                                                                                                                                                                                                                                                                                                                         
    ${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"                                                                                                                                                                                                                                                                                                                                                                                                                   
    ${PSQL} -c "CREATE SCHEMA tiger_staging;"                                                                                                                                                                                                                                                                                                                                                                                                                                   
    for z in tl_${YEAR}_${FIPS}*_edges*.zip ; 
    do 
        $UNZIPTOOL -o -d $TMPDIR $z; 
    done
    cd $TMPDIR;                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    ${PSQL} -c "CREATE TABLE tiger_data.${abbr}_edges(CONSTRAINT pk_${abbr}_edges PRIMARY KEY (gid)) INHERITS(tiger.edges);"                                                                                                                                                                                                                                                                                                                                                    
    for z in *edges*.dbf; 
    do                                                                                                                                                                                                                                                                                                                                                                                                                                                    
        ${SHP2PGSQL} -D   -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.${abbr}_edges | ${PSQL}                                                                                                                                                                                                                                                                                                                                                                               
        ${PSQL} -c "SELECT loader_load_staged_data(lower('${abbr}_edges'), lower('${abbr}_edges'));"                                                                                                                                                                                                                                                                                                                                                                                
    done                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    ${PSQL} -c "ALTER TABLE tiger_data.${abbr}_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '${FIPS}');"                                                                                                                                                                                                                                                                                                                                                                   
    ${PSQL} -c "CREATE INDEX idx_tiger_data_${abbr}_edges_tlid ON tiger_data.${abbr}_edges USING btree (tlid);"                                                                                                                                                                                                                                                                                                                                                                 
    ${PSQL} -c "CREATE INDEX idx_tiger_data_${abbr}_edgestfidr ON tiger_data.${abbr}_edges USING btree (tfidr);"                                                                                                                                                                                                                                                                                                                                                                
    ${PSQL} -c "CREATE INDEX idx_tiger_data_${abbr}_edges_tfidl ON tiger_data.${abbr}_edges USING btree (tfidl);"                                                                                                                                                                                                                                                                                                                                                               
    ${PSQL} -c "CREATE INDEX idx_tiger_data_${abbr}_edges_countyfp ON tiger_data.${abbr}_edges USING btree (countyfp);"                                                                                                                                                                                                                                                                                                                                                         
    ${PSQL} -c "CREATE INDEX tiger_data_${abbr}_edges_the_geom_gist ON tiger_data.${abbr}_edges USING gist(the_geom);"                                                                                                                                                                                                                                                                                                                                                          
    ${PSQL} -c "CREATE INDEX idx_tiger_data_${abbr}_edges_zipl ON tiger_data.${abbr}_edges USING btree (zipl);"                                                                                                                                                                                                                                                                                                                                                                 
    ${PSQL} -c "CREATE TABLE tiger_data.${abbr}_zip_state_loc(CONSTRAINT pk_${abbr}_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(tiger.zip_state_loc);"                                                                                                                                                                                                                                                                                                                
    ${PSQL} -c "INSERT INTO tiger_data.${abbr}_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, '${abbr}', '${FIPS}', p.name FROM tiger_data.${abbr}_edges AS e INNER JOIN tiger_data.${abbr}_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.${abbr}_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"                                                                                      
    ${PSQL} -c "CREATE INDEX idx_tiger_data_${abbr}_zip_state_loc_place ON tiger_data.${abbr}_zip_state_loc USING btree(soundex(place));"                                                                                                                                                                                                                                                                                                                                       
    ${PSQL} -c "ALTER TABLE tiger_data.${abbr}_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '${FIPS}');"                                                                                                                                                                                                                                                                                                                                                           
    ${PSQL} -c "vacuum analyze tiger_data.${abbr}_edges;"                                                                                                                                                                                                                                                                                                                                                                                                                       
    ${PSQL} -c "vacuum analyze tiger_data.${abbr}_zip_state_loc;"                                                                                                                                                                                                                                                                                                                                                                                                               
    ${PSQL} -c "CREATE TABLE tiger_data.${abbr}_zip_lookup_base(CONSTRAINT pk_${abbr}_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(tiger.zip_lookup_base);"                                                                                                                                                                                                                                                                                       
    ${PSQL} -c "INSERT INTO tiger_data.${abbr}_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, '${abbr}', c.name,p.name,'${FIPS}'  FROM tiger_data.${abbr}_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '${FIPS}') INNER JOIN tiger_data.${abbr}_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.${abbr}_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
    ${PSQL} -c "ALTER TABLE tiger_data.${abbr}_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '${FIPS}');"                                                                                                                                                                                                                                                                                                                                                             
    ${PSQL} -c "CREATE INDEX idx_tiger_data_${abbr}_zip_lookup_base_citysnd ON tiger_data.${abbr}_zip_lookup_base USING btree(soundex(city));"  

    #############
    # Addr
    #############   
    cd $GISDATA
    files=($(get_fips_files $BASEURL/ADDR $FIPS))

    for i in "${files[@]}" 
    do 
        wget $BASEURL/ADDR/$i --no-verbose --mirror  
    done

    cd $GISDATA/$BASEPATH/ADDR/
    rm -f ${TMPDIR}/*.*                                                                                                                                                                                                                                                                                                                                                                                                                                                             
    ${PSQL} -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"                                                                                                                                                                                                                                                                                                                                                                                                                       
    ${PSQL} -c "CREATE SCHEMA tiger_staging;"                                                                                                                                                                                                                                                                                                                                                                                                                                       
    for z in tl_${YEAR}_${FIPS}*_addr*.zip ; 
    do 
        $UNZIPTOOL -o -d $TMPDIR $z; 
    done                                                                                                                                                                                                                                                                                                                                                                                                         
    cd $TMPDIR;                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
    ${PSQL} -c "CREATE TABLE tiger_data.${abbr}_addr(CONSTRAINT pk_${abbr}_addr PRIMARY KEY (gid)) INHERITS(tiger.addr);ALTER TABLE tiger_data.${abbr}_addr ALTER COLUMN statefp SET DEFAULT '${FIPS}';"                                                                                                                                                                                                                                                                            
    for z in *addr*.dbf; 
    do                                                                                                                                                                                                                                                                                                                                                                                                                                                         
        ${SHP2PGSQL} -D -s 4269 -g the_geom -W "latin1" $z tiger_staging.${abbr}_addr | ${PSQL}                                                                                                                                                                                                                                                                                                                                                                                    
        ${PSQL} -c "SELECT loader_load_staged_data(lower('${abbr}_addr'), lower('${abbr}_addr'));"                                                                                                                                                                                                                                                                                                                                                                                      
    done                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
    ${PSQL} -c "ALTER TABLE tiger_data.${abbr}_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '${FIPS}');"                                                                                                                                                                                                                                                                                                                                                                        
    ${PSQL} -c "CREATE INDEX idx_tiger_data_${abbr}_addr_least_address ON tiger_data.${abbr}_addr USING btree (least_hn(fromhn,tohn) );"                                                                                                                                                                                                                                                                                                                                    
    ${PSQL} -c "CREATE INDEX idx_tiger_data_${abbr}_addr_tlid_statefp ON tiger_data.${abbr}_addr USING btree (tlid, statefp);"                                                                                                                                                                                                                                                                                                                                              
    ${PSQL} -c "CREATE INDEX idx_tiger_data_${abbr}_addr_zip ON tiger_data.${abbr}_addr USING btree (zip);"                                                                                                                                                                                                                                                                                                                                                                 
    ${PSQL} -c "CREATE TABLE tiger_data.${abbr}_zip_state(CONSTRAINT pk_${abbr}_zip_state PRIMARY KEY(zip,stusps)) INHERITS(tiger.zip_state); "                                                                                                                                                                                                                                                                                                                             
    ${PSQL} -c "INSERT INTO tiger_data.${abbr}_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, '${abbr}', '${FIPS}' FROM tiger_data.${abbr}_addr WHERE zip is not null;"                                                                                                                                                                                                                                                                                                 
    ${PSQL} -c "ALTER TABLE tiger_data.${abbr}_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '${FIPS}');"                                                                                                                                                                                                                                                                                                                                                           
    ${PSQL} -c "vacuum analyze tiger_data.${abbr}_addr;"
}


main () {
    echo '----------------------------------------'
    echo "      Creating Postgis extensions"
    echo '----------------------------------------'

    # Extensions
    create_extensions

    echo '----------------------------------------'
    echo "      Adding US national data"
    echo '----------------------------------------'
    # National data
    load_national_data

    # State data
    if [ "$GEOCODER_STATES" = '*' ]; then
        echo "'*' detected for STATES parameter. Adding data for all US states..."
        GEOCODER_STATES="AL,AK,AZ,AR,CA,CO,CT,DE,FL,GA,HI,ID,IL,IN,IA,KS,KY,LA,ME,MD,MA,MI,MN,MS,MO,MT,NE,NV,NH,NJ,NM,NY,NC,ND,OH,OK,OR,PA,RI,SC,SD,TN,TX,UT,VT,VA,WA,WV,WI,WY"
    fi

    # For each selected state
    IFS=',' read -ra STATES <<< "$GEOCODER_STATES"
    for i in "${STATES[@]}"; 
    do
        ABBR=$i
        FIPS=$(get_fips_from_abbr $ABBR)
        if [ $FIPS -eq 0 ]; then
            echo "Error: '$ABBR' is not a recognized US state abbreviation"
        else
            echo '----------------------------------------'
            echo "      Loading state data for: '$ABBR $FIPS'"
            echo '----------------------------------------'
            load_state_data $ABBR $FIPS
        fi
    done

    # Final indicies
    create_indicies
}

main