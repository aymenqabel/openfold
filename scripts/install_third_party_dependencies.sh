#!/bin/bash

source scripts/vars.sh

# Install Miniconda locally
rm -rf lib/conda
rm -f /tmp/Miniconda3-latest-Linux-x86_64.sh
wget -q -P /tmp \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash /tmp/Miniconda3-latest-Linux-x86_64.sh -b -p lib/conda \
    && rm /tmp/Miniconda3-latest-Linux-x86_64.sh

# Grab conda-only packages
PATH=lib/conda/bin:$PATH
conda update -qy conda \
    && conda create --name $ENV_NAME -y python==3.9.5 \
    && source lib/conda/etc/profile.d/conda.sh \
    && conda activate $ENV_NAME \
    && pip install -r requirements.txt \
    && conda install -qy -c conda-forge \
      openmm=7.5.1 \
      pdbfixer

# Install DeepMind's OpenMM patch
OPENFOLD_DIR=$PWD
pushd lib/conda/envs/$ENV_NAME/lib/python3.9/site-packages/ \
    && patch -p0 < $OPENFOLD_DIR/lib/openmm.patch \
    && popd

# Download folding resources
wget -q -P openfold/resources \
    https://git.scicore.unibas.ch/schwede/openstructure/-/raw/7102c63615b64735c4941278d92b554ec94415f8/modules/mol/alg/src/stereo_chemical_props.txt

# Download pretrained openfold weights
scripts/download_alphafold_params.sh openfold/resources

# Decompress test data
gunzip tests/test_data/sample_feats.pickle.gz