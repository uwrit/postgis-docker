PWD=$PWD
GISDATA="$PWD/gisdata"

get_fips_from_abbr () {
    local abbr=$1
    local fips=0
    case $abbr in
        "AL")  fips=01;;
        "AK")  fips=02;;
        "AS")  fips=60;;
        "AZ")  fips=04;;
        "AR")  fips=05;;
        "CA")  fips=06;;
        "CO")  fips=08;;
        "CT")  fips=09;;
        "DE")  fips=10;;
        "DC")  fips=11;;
        "FL")  fips=12;;
        "FM")  fips=64;;
        "GA")  fips=13;;
        "GU")  fips=66;;
        "HI")  fips=15;;
        "ID")  fips=16;;
        "IL")  fips=17;;
        "IN")  fips=18;;
        "IA")  fips=19;;
        "KS")  fips=20;;
        "KY")  fips=21;;
        "LA")  fips=22;;
        "ME")  fips=23;;
        "MH")  fips=68;;
        "MD")  fips=24;;
        "MA")  fips=25;;
        "MI")  fips=26;;
        "MN")  fips=27;;
        "MS")  fips=28;;
        "MO")  fips=29;;
        "MT")  fips=30;;
        "NE")  fips=31;;
        "NV")  fips=32;;
        "NH")  fips=33;;
        "NJ")  fips=34;;
        "NM")  fips=35;;
        "NY")  fips=36;;
        "NC")  fips=37;;
        "ND")  fips=38;;
        "MP")  fips=69;;
        "OH")  fips=39;;
        "OK")  fips=40;;
        "OR")  fips=41;;
        "PW")  fips=70;;
        "PA")  fips=42;;
        "PR")  fips=72;;
        "RI")  fips=44;;
        "SC")  fips=45;;
        "SD")  fips=46;;
        "TN")  fips=47;;
        "TX")  fips=48;;
        "UM")  fips=74;;
        "UT")  fips=49;;
        "VT")  fips=50;;
        "VA")  fips=51;;
        "VI")  fips=78;;
        "WA")  fips=53;;
        "WV")  fips=54;;
        "WI")  fips=55;;
        "WY")  fips=56;;
    esac
    echo $fips
}

get_fips_files () {
    local url=$1
    local fips=$2
    local files=($(wget -O - $url \
        | perl -nle 'print if m{(?=\"tl)(.*?)(?<=>)}g' \
        | perl -nle 'print m{(?=\"tl)(.*?)(?<=>)}g' \
        | sed -e 's/[\">]//g'))
    local matched=($(echo "${files[*]}" | tr ' ' '\n' | grep "tl_2017_$fips"))
    echo "${matched[*]}"
}

ABBR='WA'
FIPS=$(get_fips_from_abbr $ABBR)
cd $GISDATA
faces=($(get_fips_files "https://www2.census.gov/geo/tiger/TIGER2017/FACES" $FIPS))

for i in "${faces[@]}"
do
	wget --mirror "https://www2.census.gov/geo/tiger/TIGER2017/FACES/$i"
done

cd $GISDATA/www2.census.gov/geo/tiger/TIGER2017/FACES/