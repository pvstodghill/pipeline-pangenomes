# directory into which the results are written.
#DATA=.
#DATA=data # default

# ------------------------------------------------------------------------

GENOMES=FIXME # Points to results of pipeline-genomes

# ------------------------------------------------------------------------

# Criteria for selecting genomes for analysis
INPUTS_REMOVE_REDUNDENT=1
INPUTS_BUSCO_DB=enterobacterales
INPUTS_BUSCO_C=95
INPUTS_BUSCO_D=5

# ------------------------------------------------------------------------

ENABLE_PYP=1 # Run pyparanoid

## "minimum size of groups, defaults to 2 which ignores singletons,
## set to 1 to include singleton"
#PYP_BUILDGROUPS_THRESHOLD=1 # needed for "cloud pangenome"

# These thresholds are "strictly greater than"
PYP_ORTHO_THRESHOLDS=
PYP_ORTHO_THRESHOLDS+=" 0.99" # hard core
#PYP_ORTHO_THRESHOLDS+=" 0.95" # soft core
#PYP_ORTHO_THRESHOLDS+=" 0.15" # shell

# PYP_USE_GBLOCKS=yes # use GBlocks for trimming master alignments
PYP_USE_GBLOCKS=no # use ClipKIT for trimming master alignments

PYP_TREE_THRESHOLDS= # defaults to ${ORTHO_THRESHOLDS}

# ------------------------------------------------------------------------

ENABLE_ROARY=1

ROARY_ARGS=
ROARY_ARGS+=" -cd 99" # hard core
#ROARY_ARGS+=" -cd 95" # soft core

# ------------------------------------------------------------------------

ENABLE_PANAROO=1

PANAROO_ARGS=

#PANAROO_ARGS+=" --clean-mode strict --remove-invalid-genes"

PANAROO_ARGS+=" --clean-mode sensitive" # "Very rare plasmids are
					# difficult to distinguish
					# from contamination. "

#PANAROO_ARGS+=" --merge_paralogs"

PANAROO_ARGS+=" -a core --core_threshold 0.99" # generate a hard core gene alignment
#PANAROO_ARGS+=" -a core --core_threshold 0.95" # generate a soft core gene alignment

# ------------------------------------------------------------------------

# Uncomment to get packages from HOWTO
PACKAGES_FROM=howto

# # Uncomment to use conda
# PACKAGES_FROM=conda
# CONDA_ENV=pipeline-FIXME

#THREADS=$(nproc --all)

# ------------------------------------------------------------------------
