[ISIS 3](https://isis.astrogeology.usgs.gov) installation
===========================================================

On [macosX](https://isis.astrogeology.usgs.gov/documents/InstallGuide/index.html):
```bash
# Create ISIS folder
mkdir -p /opt/ISIS
mkdir -p /opt/ISIS/isis
mkdir -p /opt/ISIS/data

# Rsync ISIS sources
rsync -azv --delete --partial isisdist.astrogeology.usgs.gov::x86-64_darwin_OSX/isis/ /opt/ISIS/isis/

# Rsync ISIS data
rsync -azv --delete --partial --exclude='dems' isisdist.astrogeology.usgs.gov::isis3data/data/base /opt/ISIS/data/
rsync -azv --delete --partial --exclude='kernels' isisdist.astrogeology.usgs.gov::isis3data/data/voyager1 /opt/ISIS/data/
rsync -azv --delete --partial --exclude='kernels' isisdist.astrogeology.usgs.gov::isis3data/data/voyager2 /opt/ISIS/data/
rsync -azv --delete --partial --exclude='kernels' isisdist.astrogeology.usgs.gov::isis3data/data/newhorizons /opt/ISIS/data/
rsync -azv --delete --partial --exclude='kernels' isisdist.astrogeology.usgs.gov::isis3data/data/cassini /opt/ISIS/data/

# PDS data folder
mkdir -p /opt/ISIS/data/pds

# Add scripts folder
mkdir -p /opt/ISIS/script
```

Update `~/.bashrc`, add:
```bash
# ISS variable
ISISROOT=/opt/ISIS/isis
ISIS3DATA=/opt/ISIS/data
export ISISROOT
export ISIS3DATA
PATH="${PATH}:${ISISROOT}/bin"
```
_(Note: exit the current bash session to reload all the parameters)_
