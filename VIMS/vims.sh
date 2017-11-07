#!/bin/bash
# ISIS3 calibration pipeline

if [ -z $1 ]; then
  echo "USAGE: $0 imageID"
  exit 1
else
  imgID=$(echo $1 | sed -e 's/v//g' -e 's/_1//g')
fi

# Check output folder
if [ -z $ISIS3DATA ]; then
  echo "WARNING: \$ISIS3DATA undefined - The file will be save into your current directory: $(pwd)"
  QUB=$(pwd)"/QUB"
  CUB=$(pwd)"/CUB"
else
  QUB="${ISIS3DATA}/pds/VIMS/QUB"
  CUB="${ISIS3DATA}/pds/VIMS/CUB"
fi
mkdir -p $QUB
mkdir -p $CUB

if [ ! -f ${QUB}/v${imgID}_1.qub ]; then
  # Get PDS location form OPUS API
  echo "> Search image location on the PDS with OPUS"
  pds=$(curl -s \
    "http://tools.pds-rings.seti.org/opus/api/data.json?channel=IR&primaryfilespec=${imgID}&cols=ringobsid,planet,target,phase1,time1,primaryfilespec" \
    |  sed -e 's/"/\n/g' \
    | grep '.QUB' \
    | tr '[:upper:]' '[:lower:]' \
    | sed -e 's/t/T/g' -e 's/daTa/data/g' \
  )
  if [ -z $pds ]; then
    echo "ERROR: imageID $1 not found in OPUS"
    exit 1
  fi

  # Downlaod RAW file from the PDS
  echo ">> Download from the PDS: $pds"
  wget --quiet -P ${QUB} https://pds-imaging.jpl.nasa.gov/data/cassini/cassini_orbiter/$pds

  # Check download
  if [ ! -f ${QUB}/v${imgID}_1.qub ]; then
    echo 'ERROR: Download failed'
    exit 1
  fi
fi

# Init ISIS data calibration
if [ ! -f ${QUB}/v${imgID}_ir.cub ]; then
  echo "> Convert VIMS to ISIS format"
  vims2isis from=${QUB}/v${imgID}_1.qub ir=${QUB}/v${imgID}_ir.cub vis=${QUB}/v${imgID}_vis.cub
  echo "> Init spice"
  spiceinit web=yes from=${QUB}/v${imgID}_ir.cub
fi

# Radiometric calibration
if [ ! -f ${CUB}/C${imgID}_ir.cub ]; then
  echo "> Radiometric calibration"
  vimscal from=${QUB}/v${imgID}_ir.cub to=${CUB}/C${imgID}_ir.cub
fi

# Spice kernels informations
if [ ! -f ${CUB}/N${imgID}_ir.csv ]; then
  echo "> Spice kernels information"
  campt from=${CUB}/C${imgID}_ir.cub to=${CUB}/N${imgID}_ir.csv format=flat
fi

# Image navigation
if [ ! -f ${CUB}/N${imgID}_ir.cub ]; then
  echo "> Image navigation"
  phocube from=${CUB}/C${imgID}_ir.cub+1 to=${CUB}/N${imgID}_ir.cub phase=true emission=true incidence=true latitude=true longitude=true pixelresolution=true
fi
