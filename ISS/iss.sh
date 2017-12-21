#!/bin/bash
# ISIS3 calibration pipeline

if [ "$#" -eq 0 ]; then
  echo "USAGE: $0 imageID [campt] [nav] [cal] [clean] [opus]"
  exit 1
else
  imgID=$(echo $1 | sed -e 's/N//g' -e 's/W//g' -e 's/_1//g' -e 's/_2//g')
fi

# Check output folder
IMG="${ISIS3DATA}/pds/ISS/IMG"
CAL="${ISIS3DATA}/pds/ISS/CAL"
if [ -z $ISIS3DATA ]; then
  echo "WARNING: \$ISIS3DATA undefined - The file will be save into your current directory: $(pwd)"
  IMG=$(pwd)"/IMG" ; mkdir -p $IMG
  CAL=$(pwd)"/CAL" ; mkdir -p $CAL
fi

function pds {
	# Get PDS location form OPUS API
	echo "> Search image location on the PDS with OPUS"
	pds=$(curl -s \
			"https://tools.pds-rings.seti.org/opus/api/data.json?primaryfilespec=${imgID}&cols=ringobsid,planet,target,phase1,time1,primaryfilespec" \
			|  sed -e 's/"/\n/g' \
			| grep '.IMG' \
			|  sed -e 's/COISS/coiss/g' \
			| tail -1 \
		)
		if [ -z $pds ]; then
	    echo "ERROR: imageID $1 not found in OPUS"; exit 1
	  else
	    lbl=$(echo $pds | sed -e 's/.IMG/.LBL/')
	    imgID=$(echo $pds | sed -e 's/\//\n/g' | tail -1 | sed -e 's/.IMG//')
	  fi

	  # Downlaod RAW file from the PDS
	  echo ">> Download from the PDS: $pds"
	  wget -P ${IMG} https://pds-imaging.jpl.nasa.gov/data/cassini/cassini_orbiter/$pds
	  wget -P ${IMG} https://pds-imaging.jpl.nasa.gov/data/cassini/cassini_orbiter/$lbl

	  # Check download
	  if [ ! -f ${IMG}/${imgID}.IMG ]; then
	    echo 'ERROR: IMG Download failed' ; exit 1
	  elif [ ! -f ${IMG}/${imgID}.LBL ]; then
	    echo 'ERROR: LBL Download failed' ; exit 1
	  fi
}

function init {
	# Init ISIS data calibration
	if [ ! -f ${CAL}/${imgID}.cub ]; then
	  echo "> Convert ISS to ISIS format"
	  ciss2isis from=${IMG}/${imgID}.LBL to=${CAL}/${imgID}.cub
	  echo "> Init spice"
	  spiceinit web=yes from=${CAL}/${imgID}.cub
	fi
}

function campt {
	# Spice kernels informations
	if [ ! -f ${CAL}/${imgID}.csv ]; then
	  echo "> Spice kernels information"
	  campt from=${CAL}/${imgID}.cub to=${CAL}/${imgID}.csv format=flat
	fi
}

function nav {
	# Image navigation
	if [ ! -f ${CAL}/${imgID}_nav.cub ]; then
		echo "> Image navigation"
		phocube from=${CAL}/${imgID}.cub to=${CAL}/${imgID}_nav.cub phase=true emission=true incidence=true latitude=true longitude=true pixelresolution=true
	fi
}

function cal {
	# ISIS radiometric calibration
	if [ ! -f ${CAL}/${imgID}_cal.cub ]; then
		echo "> ISIS radiometric calibration"
		cisscal from=${CAL}/${imgID}.cub to=${CAL}/${imgID}_cal.cub
	fi
}
function clean {
	# Remove random pixel noise
	if [ ! -f ${CAL}/${imgID}_stdz.cub ]; then
		echo "> Remove random pixel noise"
		noisefilter from=${CAL}/${imgID}_cal.cub to=${CAL}/${imgID}_stdz.cub toldef=stddev tolmin=2.5 tolmax=2.5 replace=null samples=5 lines=5
	fi

	# Fill-in NULL pixels
	if [ ! -f ${CAL}/${imgID}_fill.cub ]; then
		echo "> Fill-in NULL pixels"
		lowpass from=${CAL}/${imgID}_stdz.cub to=${CAL}/${imgID}_fill.cub samples=3 lines=3 filter=outside null=yes hrs=no his=no lrs=no replacement=center
	fi

	# Remove frame-edge noise
	if [ ! -f ${CAL}/${imgID}_trim.cub ]; then
		echo "> Remove frame-edge noise"
		trim from=${CAL}/${imgID}_fill.cub to=${CAL}/${imgID}_trim.cub top=2 bottom=2 left=2 right=2
	fi
}
function opus {
	# Radiometric calibration from OPUS
	if [ ! -f ${CAL}/${imgID}_CALIB.IMG ]; then
		echo "> Download calibration image from OPUS"
		opus=$(curl -s \
			"https://tools.pds-rings.seti.org/opus/api/data.json?primaryfilespec=${imgID}&cols=ringobsid,planet,target,phase1,time1,primaryfilespec" \
			|  sed -e 's/"/\n/g' \
			| grep '.IMG' \
			|  sed -e 's/.IMG/_CALIB.IMG/g' \
			| tail -1 \
			)
		wget -P ${CAL} https://pds-rings.seti.org/holdings/calibrated/COISS_2xxx/$opus
	fi
}

# Main
if [ ! -f ${IMG}/?${imgID}_?.IMG ]; then
	pds
else
	imgID=$(ls ${IMG}/?${imgID}_?.IMG | sed -e 's/\//\n/g' | tail -1 | sed -e 's/.IMG//')
fi

init
for arg in $(echo "$@" | tr '[:upper:]' '[:lower:]')
do
	case $arg in
		'campt' ) campt ;;
		'nav'   ) nav ;;
	  'cal'   ) cal ;;
	  'clean' ) cal ; clean ;;
	  'opus'  ) opus ;;
	esac
done
