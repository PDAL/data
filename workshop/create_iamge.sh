eval "$(conda shell.bash hook)"

export ROOT_DIR="$PWD/PDAL Workshop Materials"
# create root_directory for image
mkdir -p "$ROOT_DIR"

# grab PDAL repo 
git clone -n --depth=1 https://github.com/PDAL/PDAL

# build pdal docs
conda create -n "pdal-docs" python=3.11 --yes --quiet
conda activate pdal-docs
mamba install -c conda-forge graphviz --yes --quiet
pip install -r PDAL/doc/requirements.txt
make -C PDAL/doc doxygen
make -C PDAL/doc html
make -C PDAL/doc latexpdf

# copy workshop docs to image directory
cp -R PDAL/doc/build/html "$ROOT_DIR/docs"
cp PDAL/doc/build/latex/PDAL.pdf "$ROOT_DIR"/docs

# copy needed datasets
git clone --depth=1 https://github.com/PDAL/data
cd data
git lfs install
git lfs pull
cd ..   

mkdir -p "$ROOT_DIR/exercises/batch_processing"
cp PDAL/doc/workshop/generation/batch_processing/batch_srs_gdal.json \
    "$ROOT_DIR/exercises/batch_processing"
    

mkdir -p "$ROOT_DIR/exercises/batch_processing/source"
cp data/workshop/TM_551_101.laz \
    data/workshop/TM_551_102.laz \
    data/workshop/TM_552_101.laz \
    data/workshop/TM_552_102.laz \
    "$ROOT_DIR/exercises/batch_processing/source/"

mkdir -p "$ROOT_DIR/exercises/analysis/clipping"
cp data/workshop/autzen.laz \
    PDAL/doc/workshop/manipulation/clipping/clipping.json \
    "$ROOT_DIR/exercises/analysis/clipping/"


mkdir -p "$ROOT_DIR/exercises/analysis/colorization"
cp data/workshop/casi-2015-04-29-weekly-mosaic.tif \
    PDAL/doc/workshop/manipulation/colorization/colorize.json \
    "$ROOT_DIR/exercises/analysis/colorization/" 

mkdir -p "$ROOT_DIR/exercises/analysis/denoising"
cp PDAL/doc/workshop/manipulation/denoising/denoise.json \
    data/workshop/18TWK820985.laz \
    "$ROOT_DIR/exercises/analysis/denoising/"

mkdir -p "$ROOT_DIR/exercises/analysis/density"
cp data/workshop/uncompahgre.laz "$ROOT_DIR/exercises/analysis/density/"

mkdir -p "$ROOT_DIR/exercises/analysis/dtm"
cp PDAL/doc/workshop/generation/dtm/gdal.json "$ROOT_DIR/exercises/analysis/dtm"
    
mkdir -p "$ROOT_DIR/exercises/analysis/ground"
cp data/workshop/CSite1_orig-utm.laz "$ROOT_DIR/exercises/analysis/ground/"

mkdir -p "$ROOT_DIR/exercises/analysis/rasterize"
cp PDAL/doc/workshop/generation/rasterize/classification.json "$ROOT_DIR/exercises/analysis/rasterize"

mkdir -p "$ROOT_DIR/exercises/analysis/thinning"
cp data/workshop/uncompahgre.laz \
    data/workshop/uncompahgre.copc.laz \
    "$ROOT_DIR/exercises/analysis/thinning/"

mkdir -p "$ROOT_DIR/exercises/georeferencing"
cp data/workshop/S1C1_csd_004.csd "$ROOT_DIR/exercises/georeferencing"

mkdir -p "$ROOT_DIR/exercises/python"
cp PDAL/doc/workshop/generation/python/histogram.json \
    PDAL/doc/workshop/generation/python/histogram.py \
    data/workshop/athletic-fields.laz  \
    "$ROOT_DIR/exercises/python/"

mkdir -p "$ROOT_DIR/exercises/translation"
cp data/workshop/csite-dd.laz \
    data/workshop/interesting.laz \
    PDAL/doc/workshop/introduction/entwine.json \
    "$ROOT_DIR/exercises/translation"

cp data/workshop/interesting.las "$ROOT_DIR/exercises/translation"

mkdir -p "$ROOT_DIR/exercises/info"
cp data/workshop/interesting.las "$ROOT_DIR/exercises/info/"

curl --output-dir "$ROOT_DIR/software/windows" -C - -OL --create-dirs https://download.qgis.org/downloads/QGIS-OSGeo4W-3.32.2-1.msi
curl --output-dir "$ROOT_DIR/software/windows" -C - -OL --create-dirs https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Windows-x86_64.exe
curl --output-dir "$ROOT_DIR/software/windows" -C - -OL --create-dirs https://github.com/jqlang/jq/releases/download/jq-1.7/jq-windows-amd64.exe
curl --output-dir "$ROOT_DIR/software/windows" -C - -OL --create-dirs https://www.danielgm.net/cc/release/CloudCompare_v2.13.beta_setup_x64.exe

# grab macOS Installers
curl --output-dir "$ROOT_DIR/software/macOS" -C - -OL --create-dirs https://download.qgis.org/downloads/macos/qgis-macos-pr.dmg
curl --output-dir "$ROOT_DIR/software/macOS" -C - -OL --create-dirs https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-MacOSX-arm64.sh
curl --output-dir "$ROOT_DIR/software/macOS" -C - -OL --create-dirs https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-MacOSX-x86_64.sh
curl --output-dir "$ROOT_DIR/software/macOS" -C - -OL --create-dirs https://github.com/jqlang/jq/releases/download/jq-1.7/jq-macos-amd64
curl --output-dir "$ROOT_DIR/software/macOS" -C - -OL --create-dirs https://github.com/jqlang/jq/releases/download/jq-1.7/jq-macos-arm64
curl --output-dir "$ROOT_DIR/software/macOS" -C - -OL --create-dirs https://www.danielgm.net/cc/release/CloudCompare-2.13.0-x86_64.dmg
curl --output-dir "$ROOT_DIR/software/macOS" -C - -OL --create-dirs https://www.danielgm.net/cc/release/CloudCompare-2.13.0-arm64.dmg

# mamba env create -f environment-pdal_workshop_image.yml --yes --quiet
conda create -n "pdal-gen-workshop-image" python=3.11 --yes --quiet
conda activate pdal-gen-workshop-image
mamba install -c conda-forge conda-pack awscli --yes --quiet

# grab cool-lidar content
aws s3 sync s3://cool-lidar "$ROOT_DIR/cool-lidar"

# grab conda environments
mkdir -p "$ROOT_DIR/software/conda_environments"

# make docker environment 
# NOTE: need to do this for x86_64
mkdir docker
cd docker
docker image build -t pdal-workshop data/workshop/docker
docker save -o pdal-workshop_docker-arm64.tar.gz pdal-workshop
cd ..
cp "docker/pdal-workshop_docker*.tar.gz" "$ROOT_DIR/software/conda_environments/"


mkdir -p staging/conda_environments
# NOTE: this needs to happen for every platform, not just osx-arm64 
mamba env create --file "$PWD/PDAL/doc/workshop/environment.yml" -p "$PWD/staging/conda_environments" --yes --quiet
conda-pack -p staging/conda_environments -o "$ROOT_DIR/software/conda_environments/pdal-workshop_osx-arm64.tar.gz" -f



