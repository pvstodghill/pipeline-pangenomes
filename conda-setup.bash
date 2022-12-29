#! /bin/bash

set -e

NAME=pipeline-pangenomes

CONDA_PREFIX=$(dirname $(dirname $(type -p conda)))
. "${CONDA_PREFIX}/etc/profile.d/conda.sh"

PACKAGES=
#PACKAGES+=" pip"

# roary
PACKAGES+=" kraken"
PACKAGES+=" r-ggplot2"
PACKAGES+=" roary"

# pyparanoid
PACKAGES+=" pip"

PACKAGES+=" cd-hit" # =4.8.1
PACKAGES+=" clipkit"
PACKAGES+=" diamond" # =2.0.13
PACKAGES+=" fasttree"
#PACKAGES+=" gblocks"
PACKAGES+=" hmmer" # =3.3.2
PACKAGES+=" mcl" # =14-137
PACKAGES+=" muscle=3.8.1551"

# panaroo
PACKAGES+=" panaroo"

if [ "$(type -p mamba)" ] ; then
    _conda="mamba --no-banner"
else
    _conda=conda
fi

function __ {
    echo + "$@"
    eval "$@"
}

if [ "$1" = -f ] ; then
    __ conda env remove -y --name ${NAME}
fi
if [ ! -d ${CONDA_PREFIX}/envs/${NAME} ] ; then
    __ conda create -y --name ${NAME}
fi
__ conda activate ${NAME}

__ $_conda install -y ${PACKAGES}

__ pip install pyparanoid
