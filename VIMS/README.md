VIMS calibration with [ISIS 3](https://isis.astrogeology.usgs.gov)
================================

Get VIMS data
-------------
- Search the PDS location on OPUS, for example the image id: [`1743896394_1`](https://tools.pds-rings.seti.org/opus#/primaryfilespec=1743896394&view=detail&detail=S_CUBE_CO_VIMS_1743896394_IR)

```bash
curl -s 'http://tools.pds-rings.seti.org/opus/api/data.json?channel=IR&primaryfilespec=1743896394&cols=ringobsid,planet,target,phase1,time1,primaryfilespec' |  sed -e 's/"/\n/g' | grep '.QUB' | tr '[:upper:]' '[:lower:]' | sed -e 's/t/T/g' -e 's/daTa/data/g'
```

![Image from OPUS](https://pds-rings.seti.org/holdings/previews/COVIMS_0xxx/COVIMS_0058/data/2013095T224243_2013096T133534/v1743896394_1_med.png)

- Download the file from the PDS

```bash
wget https://pds-imaging.jpl.nasa.gov/data/cassini/cassini_orbiter/covims_0058/data/2013095T224243_2013096T133534/v1743896394_1.qub
```


Calibration with ISIS
----------------------
- Data ingestion for ISIS:
```bash
vims2isis from=v1743896394_1.qub ir=v1743896394_1_ir.cub vis=v1743896394_1_vis.cub
```

- Init Kernels from the web:
```bash
spiceinit web=yes from=v1743896394_1_ir.cub
spiceinit web=yes from=v1743896394_1_vis.cub
```

- Radiometric calibration
```bash
vimscal from=v1743896394_1_ir.cub to=C1743896394_1_ir.cub units=IOF
vimscal from=v1743896394_1_vis.cub to=C1743896394_1_vis.cub units=IOF
```

- Extract camera/body informations (as `.csv` file) on the central pixel
```bash
campt from=C1743896394_1_ir.cub to=K1743896394_1_ir.csv format=flat
```

- Create the geocube:
```bash
phocube from=C1743896394_1_ir.cub+1 to=N1743896394_1_ir phase=true  emission=true  incidence=true  latitude=true  longitude=true pixelresolution=true
```
_(Note: The `+1` sign represents the first image slice)_

Complete calibration pipeline script
-------------------------------------
The whole calibration can be run by:
```bash
sh ${ISISROOT}/../scripts/isis-sh/VIMS/vims.sh 1743896394
```

Sources:
--------
- [PDS](https://pds-imaging.jpl.nasa.gov/data/cassini/cassini_orbiter/)
- [OPUS](http://tools.pds-rings.seti.org/opus)
- [ISIS tutorials](https://isis.astrogeology.usgs.gov/fixit/projects/isis/wiki/Working_with_Cassini_VIMS)
