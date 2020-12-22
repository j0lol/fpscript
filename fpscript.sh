#!/bin/bash

echo "This script will make a directory 'fpscript' at the current location and will download windows release, build the linux launcher, replace the config and pack it all into a release."
echo "This script builds 'Flashpoint Infinity'"
echo "Please make sure this script is up to date, it's repository can be found at https://github.com/j0lol/fpscript"
echo "READ THE SCRIPT before you continue. Only run scripts you trust, read through this script and make sure you understand what it does before continuing."
echo 
echo "Please make sure you have the correct dependancies before building."
echo "At the moment, these appear to be:"
echo "git (and other essential build tools), npm, 7z, php, wine (32 bit)"
echo
read -n 1 -srp "Press any key to continue..."
# Make our working directory

mkdir fpscript
cd fpscript
# escape directory for spaces
workingdir="${PWD:-$(pwd)}"

# Get latest links from separate script
wget https://raw.githubusercontent.com/j0lol/fpscript/main/links.sh
. ./links.sh
rm links.sh

# Part 1: Get Flashpoint.exe
mkdir win-dl
cd win-dl

wget "$FPDOWNLOAD"
7z x Flashpoint*.exe # Extract self-extracting archive
for x in Flashpoint*; do case "$x" in *.exe) :;; *) dir="$x"; esac; done
mv "$dir"/* ./
rm -r "$dir"
rm -rf Launcher # Remove windows build to be replaced w linux build
mkdir Launcher

cd "$workingdir"

# Part 2: Build Flashpoint Launcher

git clone --branch develop --recurse-submodules https://github.com/FlashpointProject/launcher.git launcher
cd launcher

npm install # Get deps
npm run build # Build
npm run pack # Pack for release

cd dist/linux-unpacked
mv * "$workingdir"/win-dl/Launcher/ # Copy into our flashpoint infinity folder

cd "$workingdir"

# Part 3: Overwrite files w patches/config changes
cd win-dl
wget "https://github.com/j0lol/fpscript/blob/main/conf.zip?raw=true" -O conf.zip
unzip conf.zip
rm conf.zip

# Part 4: Cleanup
cd "$workingdir"
rm -rf launcher
mv win-dl/* ./
rm -r win-dl
rm *.lnk
echo "Run Launcher/flashpoint-launcher to run Flashpoint. PHP and Wine is needed to run games." > linux-howtorun.txt

echo "Build finished! Hopefully it works :)"
