#!/bin/bash

# curl https://pdal.io/PDAL.pdf -o PDAL-docs.pdf

git clone -n --depth=1 --filter=tree:0 https://github.com/PDAL/PDAL
cd PDAL
git sparse-checkout set --no-cone doc
git checkout
cd ..

git clone -n --depth=1 --filter=tree:0 https://github.com/PDAL/data
cd data
git sparse-checkout set --no-cone workshop
git checkout
cd ..

mkdir -p exercises exercises/info
mkdir -p software software/MacOS software/Windows software/Linux

# Moving docs
mv PDAL/doc/workshop/manipulation exercises
mv exercises/manipulation exercises/analysis
mv PDAL/doc/workshop/generation/meshing PDAL/doc/workshop/generation/rasterize \
 PDAL/doc/workshop/generation/dtm exercises/analysis
mv PDAL/doc/workshop/generation/batch_processing PDAL/doc/workshop/generation/georeferencing \
 PDAL/doc/workshop/generation/python PDAL/doc/workshop/introduction exercises
mv exercises/introduction exercises/translation
mv exercises/translation/metadata.rst exercises/translation/single-point.rst \
 exercises/translation/near.rst exercises/info
# Moving data
mkdir -p exercises/batch_processing/source
mv data/workshop/TM_551_101.laz data/workshop/TM_551_102.laz data/workshop/TM_552_101.laz \
 data/workshop/TM_552_102.laz exercises/batch_processing/source
mv data/workshop/autzen.laz exercises/analysis/clipping
mv data/workshop/casi-2015-04-29-weekly-mosaic.tif exercises/analysis/colorization
mv data/workshop/18TWK820985.laz exercises/analysis/denoising
cp data/workshop/uncompahgre.laz exercises/analysis/density
mv data/workshop/CSite1_orig-utm.laz exercises/analysis/ground
mv data/workshop/uncompahgre.laz data/workshop/uncompahgre.copc.laz exercises/analysis/thinning
mv data/workshop/S1C1_csd_004.csd exercises/georeferencing
mv data/workshop/athletic-fields.laz exercises/python
mv data/workshop/csite-dd.laz data/workshop/interesting.laz exercises/translation
cp data/workshop/interesting.las exercises/translation
mv data/workshop/interesting.las exercises/info

# software download
cd software/Windows
curl https://qgis.org/downloads/QGIS-OSGeo4W-3.32.0-1.msi -o QGIS-OSGeo4W-3.32.0-1.msi 
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe -o Miniconda3-latest-Windows-x86_64.exe
curl https://www.danielgm.net/cc/release/CloudCompare_v2.13.alpha_setup_x64.exe -o CloudCompare_v2.13.alpha_setup_x64.exe
cd ..
cd MacOS
curl https://qgis.org/downloads/macos/qgis-macos-pr.dmg -o qgis-macos-pr.dmg
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -o Miniconda3-latest-MacOSX-x86_64.sh
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o Miniconda3-latest-MacOSX-arm64.sh
curl https://www.danielgm.net/cc/release/CloudCompare-2.13.0-x86_64.dmg -o CloudCompare-2.13.0-x86_64.dmg
curl https://www.danielgm.net/cc/release/CloudCompare-2.13.0-arm64.dmg -o CloudCompare-2.13.0-arm64.dmg
cd ..
cd Linux
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o Miniconda3-latest-Linux-x86_64.sh
cd ../..

chmod -R +w data PDAL exercises software
rm -rf data PDAL

zip_filename="PDAL_Workshop_complete.zip"
zip -r "$zip_filename" exercises software #PDAL-docs.pdf

rm -rf exercises software #PDAL-docs.pdf