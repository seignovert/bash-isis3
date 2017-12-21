[ISIS 3](https://isis.astrogeology.usgs.gov) installation
===========================================================

Init folders:
```bash
# Create ISIS folder
mkdir -p /opt/ISIS
mkdir -p /opt/ISIS/isis
mkdir -p /opt/ISIS/data

# PDS data folder
mkdir -p /opt/ISIS/data/pds
mkdir -p /opt/ISIS/data/pds/VIMS
mkdir -p /opt/ISIS/data/pds/VIMS/QUB
mkdir -p /opt/ISIS/data/pds/VIMS/CUB
mkdir -p /opt/ISIS/data/pds/ISS
mkdir -p /opt/ISIS/data/pds/ISS/IMG
mkdir -p /opt/ISIS/data/pds/ISS/CAL

# Add scripts folder
mkdir -p /opt/ISIS/scripts
```

Install sources for  [macosX](https://isis.astrogeology.usgs.gov/documents/InstallGuide/index.html):
```bash
# Rsync ISIS sources
rsync -azv --delete --partial isisdist.astrogeology.usgs.gov::x86-64_darwin_OSX/isis/ /opt/ISIS/isis/
```

Install sources for  [Ubuntu](https://isis.astrogeology.usgs.gov/documents/InstallGuide/index.html):
```bash
# Rsync ISIS sources
rsync -azv --delete --partial isisdist.astrogeology.usgs.gov::x86-64_linux_UBUNTU/isis/ /opt/ISIS/isis/
```
> __Note for Ubuntu 16.04 LTS:__ the `ICU` lib is only availably in version `55` and not `52`. To solve the issue you need to add `deb http://security.ubuntu.com/ubuntu trusty-security main` into your `sources.list` (`Parameters > Sources > Add`). Then `sudo apt-get update; sudo apt-get install libicu52`.

Rsync ISIS data:
```bash
rsync -azv --delete --partial --exclude='dems' isisdist.astrogeology.usgs.gov::isis3data/data/base /opt/ISIS/data/
rsync -azv --delete --partial --exclude='kernels' isisdist.astrogeology.usgs.gov::isis3data/data/voyager1 /opt/ISIS/data/
rsync -azv --delete --partial --exclude='kernels' isisdist.astrogeology.usgs.gov::isis3data/data/voyager2 /opt/ISIS/data/
rsync -azv --delete --partial --exclude='kernels' isisdist.astrogeology.usgs.gov::isis3data/data/newhorizons /opt/ISIS/data/
rsync -azv --delete --partial --exclude='kernels' isisdist.astrogeology.usgs.gov::isis3data/data/cassini /opt/ISIS/data/
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
