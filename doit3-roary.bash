#! /bin/bash

. $(dirname ${BASH_SOURCE[0]})/doit-preamble.bash

if [ -z "${ENABLE_ROARY}" ] ; then
    echo 1>&2 '# Skipping.'
    exit
fi

# ------------------------------------------------------------------------

rm -rf ${ROARY}
mkdir -p ${ROARY}

# ------------------------------------------------------------------------
# Run Roary
# ------------------------------------------------------------------------

echo 1>&2 '# Run Roary'
roary -e -mafft -p ${THREADS} -f ${ROARY}/ -r ${INPUTS}/*.gff ${ROARY_ARGS}

# ------------------------------------------------------------------------
# Run FastTreeMP
# ------------------------------------------------------------------------

echo 1>&2 '# Run FastTreeMP'
export OMP_NUM_THREADS=${THREADS}
FastTreeMP -nt -gtr ${ROARY}/*/core_gene_alignment.aln > ${ROARY}/tree.phy

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 '# Done.'

