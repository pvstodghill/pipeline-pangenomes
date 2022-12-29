#! /bin/bash

. $(dirname ${BASH_SOURCE[0]})/doit-preamble.bash

if [ -z "${ENABLE_PYP}" ] ; then
    echo 1>&2 '# Skipping.'
    exit
fi

# ------------------------------------------------------------------------

rm -rf ${PYP}
mkdir -p ${PYP}

# ------------------------------------------------------------------------
# Setting up .pep directories
# ------------------------------------------------------------------------

echo 1>&2 '# Setting up .pep directories'

mkdir -p ${PYP}/core-genomes/pep

(
    shopt -s nullglob    
    for f in ${INPUTS}/*.faa ; do
	name=$(basename $f .faa)
	cp $f ${PYP}/core-genomes/pep/${name}.pep.fa
    done
)

sed -E -i -e 's/^>gnl\|[a-zA-Z0-9]+\|/>/' ${PYP}/core-genomes/pep/*.pep.fa

if [ "$PROP_PEP_FA_DIR" ] ; then
    mkdir -p ${PYP}/prop-genomes/pep
    cp ${PROP_PEP_FA_DIR}/*.pep.fa ${PYP}/prop-genomes/pep/
    sed -E -i -e 's/^>gnl\|[a-zA-Z0-9]+\|/>/' ${PYP}/prop-genomes/pep/*.pep.fa
fi


# ------------------------------------------------------------------------
# Creating core genome list
# ------------------------------------------------------------------------

echo 1>&2 '# Creating core genome list'

for f in ${PYP}/core-genomes/pep/*.pep.fa ; do
    name=$(basename $f .pep.fa)
    echo $name >> ${PYP}/core-genomes.txt
done


# ------------------------------------------------------------------------
# Running BuildGroups.py
# ------------------------------------------------------------------------

echo 1>&2 '# Running BuildGroups.py'

ARGS=
if [ "$PYP_BUILDGROUPS_THRESHOLD" ] ; then
    ARGS+=" --threshold $PYP_BUILDGROUPS_THRESHOLD"
fi

BuildGroups.py --use_MP --clean --verbose  --cpus ${THREADS} \
	       ${ARGS} \
	       ${PYP}/core-genomes ${PYP}/core-genomes.txt ${PYP}/db

# ------------------------------------------------------------------------
# Running PropagateGroups.py
# ------------------------------------------------------------------------

if [ "$PROP_PEP_FA_DIR" ] ; then
    echo 1>&2 '# Running PropagateGroups.py'

    for f in ${PYP}/prop-genomes/pep/*.pep.fa ; do
	name=$(basename $f .pep.fa)
	echo $name >> ${PYP}/prop-genomes.txt
    done

    PropagateGroups.py ${PYP}/prop-genomes ${PYP}/prop-genomes.txt ${PYP}/db
else
    echo 1>&2 '# [not] Running PropagateGroups.py'
    touch ${PYP}/db/prop_strainlist.txt ${PYP}/db/prop_homolog.faa
fi

# ------------------------------------------------------------------------
# Running IdentifyOrthologs.py
# ------------------------------------------------------------------------

echo 1>&2 '# Running IdentifyOrthologs.py'

for THRESHOLD in ${PYP_ORTHO_THRESHOLDS} ; do
    echo 1>&2 "## --threshold ${THRESHOLD}"
    rm -f ${PYP}/db/all_groups.hmm.ssi
    # This is an ugly hack. See https://github.com/ryanmelnyk/PyParanoid/issues/11.
    case X${THRESHOLD}X in
	X1X|X1.0X|X1.00X|X1.000X)
	    THRESHOLD_ARG=
	    ;;
	X*X)
	    THRESHOLD_ARG="--threshold ${THRESHOLD}"
	    ;;
	*)
	    echo 1>&2 "Cannot happen."
	    exit 1
    esac
    IdentifyOrthologs.py --use_MP --cpus ${THREADS} \
			 ${THRESHOLD_ARG}  \
			 ${PYP}/db ${PYP}/orthos_${THRESHOLD}

    echo '## orthologs:' $(cat ${PYP}/orthos_${THRESHOLD}/orthos.txt | wc -l)

done

# ------------------------------------------------------------------------
# Making trees
echo 1>&2 '# Making trees'

if [ -z "$PYP_TREE_THRESHOLDS" ] ; then
    PYP_TREE_THRESHOLDS="$PYP_ORTHO_THRESHOLDS"
fi

for THRESHOLD in ${PYP_TREE_THRESHOLDS} ; do

    echo 1>&2 '## Threshold = '${THRESHOLD}

    PHYLO=${TREES}/${THRESHOLD}
    mkdir -p ${PYP}/tree_${THRESHOLD}

    # ------------------------------------------------------------------------

    echo 1>&2 '## Making local copy of master alignment'
    if [ ! -s ${PYP}/orthos_${THRESHOLD}/orthos.txt ] ; then
	echo 1>&2 "# Empty master alignment! Skipping..."
	continue
    fi

    cp ${PYP}/orthos_${THRESHOLD}/master_alignment.faa ${PYP}/tree_${THRESHOLD}

    # ------------------------------------------------------------------------

    if [ "$USE_GBLOCKS" = "yes" ] ; then
	
	echo 1>&2 '## Running GBlocks'
	set +e
	Gblocks ${PYP}/tree_${THRESHOLD}/master_alignment.faa -t=p # -t=p == protein
	set -e

	# Gblocks returns non-0 status? This is a hack
	if [ ! -s ${PYP}/tree_${THRESHOLD}/master_alignment.faa-gb ] ; then
	    echo 1>&2 '## Gblocks failed!'
	    continue
	fi

	TRIMMED=${PYP}/tree_${THRESHOLD}/master_alignment.faa-gb

    else

	echo 1>&2 '## Running ClipKIT'
	clipkit ${PYP}/tree_${THRESHOLD}/master_alignment.faa
	TRIMMED=${PYP}/tree_${THRESHOLD}/master_alignment.faa.clipkit

    fi

    # ------------------------------------------------------------------------

    echo 1>&2 '## Running FastTree'

    (
	export OMP_NUM_THREADS=${THREADS}
	FastTreeMP < ${TRIMMED} > ${PYP}/tree_${THRESHOLD}/tree.phy

    )

    # ------------------------------------------------------------------------

done

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 '# Done.'

