ISS calibration with [ISIS 3](https://isis.astrogeology.usgs.gov)
================================

Get ISS data
-------------
- Search the PDS location on OPUS, for example the image id: [`N1551888681_1`](https://tools.pds-rings.seti.org/opus#/primaryfilespec=N1551888681_1&view=detail&detail=S_IMG_CO_ISS_1551888681_N)

```bash
curl -s 'http://tools.pds-rings.seti.org/opus/api/data.json?primaryfilespec=1551888681&cols=ringobsid,planet,target,phase1,time1,primaryfilespec' |  sed -e 's/"/\n/g' | grep '.IMG' |  sed -e 's/COISS/coiss/g' | tail -1
```

![Image from OPUS](https://pds-rings.seti.org/holdings/previews/COISS_2xxx/COISS_2030/data/1551868920_1552128641/N1551888681_1_med.jpg)

- Download the file from the PDS

```bash
wget https://pds-imaging.jpl.nasa.gov/data/cassini/cassini_orbiter/coiss_2030/data/1551868920_1552128641/N1551888681_1.IMG
wget https://pds-imaging.jpl.nasa.gov/data/cassini/cassini_orbiter/coiss_2030/data/1551868920_1552128641/N1551888681_1.LBL
```


Calibration with ISIS
----------------------
- Data ingestion for ISIS:
```bash
ciss2isis from=N1551888681_1.LBL to=N1551888681_1.cub
```

- Init spice
```bash
spiceinit web=yes from=N1551888681_1.cub
```

- Spice kernels information
```bash
campt from=N1551888681_1.cub to=N1551888681_1.csv format=flat
```

> - [Optional 1] Radiometric calibration
```bash
  cisscal from=N1551888681_1.cub to=N1551888681_1_cal.cub
```

> - [Optional 2] Image navigation
```bash
phocube from=N1551888681_1.cub to=N1551888681_1_nav.cub phase=true  emission=true incidence=true latitude=true longitude=true pixelresolution=true
```

> - [Optional 3] Remove random pixel noise
```bash
noisefilter from=N1551888681_1_cal.cub to=N1551888681_1_stdz.cub  toldef=stddev tolmin=2.5 tolmax=2.5 replace=null samples=5 lines=5
```

> - [Optional 3] Fill-in NULL pixels
```bash
lowpass from=N1551888681_1_stdz.cub to=N1551888681_1_fill.cub samples=3 lines=3 filter=outside null=yes hrs=no his=no lrs=no replacement=center
```

> - [Optional 3] Remove frame-edge noise
```bash
trim from=N1551888681_1_fill.cub to=N1551888681_1_trim.cub top=2 bottom=2 left=2 right=2
```

_Note - 2017/11/28: [ISIS3 `cisscal`](https://isis.astrogeology.usgs.gov/Application/presentation/Tabbed/cisscal/cisscal.html) is based from the version 3.6 IDL CISSCAL application developed by the Cassini Imaging Central Laboratory for Operations (CICLPOS). The most recent version currently available is the [3.8](https://pds-imaging.jpl.nasa.gov/documentation/iss_data_user_guide_160929.pdf). Therefore, it is highly recommended to use directly the [calibrated images from OPUS](https://pds-rings.seti.org/cassini/iss/calibration.html), since there are directly available:_
```
wget https://pds-rings.seti.org/holdings/calibrated/COISS_2xxx/COISS_2030/data/1551868920_1552128641/N1551888681_1_CALIB.IMG
```

Complete calibration pipeline script
-------------------------------------
- Download the image, the kernel infos and the OPUS calibrated image:
```bash
sh ISS/iss.sh N1551888681_1
```

- The whole calibration can be run by:
```bash
sh ISS/iss.sh N1551888681_1 isis_cal nav noise
```

Sources:
--------
- [PDS](https://pds-imaging.jpl.nasa.gov/data/cassini/cassini_orbiter/)
- [OPUS](http://tools.pds-rings.seti.org/opus)
- [ISIS tutorials](https://isis.astrogeology.usgs.gov/fixit/projects/isis/wiki/Working_with_Cassini_ISS_Data)
