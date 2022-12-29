#! /bin/bash

. $(dirname ${BASH_SOURCE[0]})/doit-preamble.bash

if [ -z "${ENABLE_PANAROO}" ] ; then
    echo 1>&2 '# Skipping.'
    exit
fi

# ------------------------------------------------------------------------

rm -rf ${PANAROO}
mkdir -p ${PANAROO}

# ------------------------------------------------------------------------
# Run Panaroo
# ------------------------------------------------------------------------

echo 1>&2 '# Run Panaroo'

panaroo -i ${INPUTS}/*.gff \
	-o ${PANAROO} \
	--threads ${THREADS} \
	${PANAROO_ARGS}


# ------------------------------------------------------------------------
# Run FastTreeMP
# ------------------------------------------------------------------------

if [ -e ${PANAROO}/core_gene_alignment_filtered.aln ] ; then

    echo 1>&2 '# Run FastTreeMP'
    export OMP_NUM_THREADS=${THREADS}
    FastTreeMP -nt -gtr ${PANAROO}/core_gene_alignment_filtered.aln > ${PANAROO}/tree.phy

fi


# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 '# Done.'

