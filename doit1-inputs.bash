#! /bin/bash

. $(dirname ${BASH_SOURCE[0]})/doit-preamble.bash

# ------------------------------------------------------------------------

rm -rf ${INPUTS}
mkdir -p ${INPUTS}

# ------------------------------------------------------------------------
# Collect qualifying genomes
# ------------------------------------------------------------------------

echo 1>&2 '# Collect qualifying genomes'

if [ -e "${GENOMES}/metadata.tsv" ] ; then
    : nop
elif [ -e "${GENOMES}/data/metadata.tsv" ] ; then
    GENOMES="${GENOMES}/data"
else
    echo 1>&2 "Cannot find metadata.tsv in ${GENOMES}"
    exit 1
fi

cat ${GENOMES}/metadata.tsv | (
    while IFS=$'\t' read NAME ACCESSION SOURCE ORGANISM STRAIN LEVEL DATE \
	     SEQS BASES MEDIAN MEAN N50 L50 MIN MAX \
	     BUSCO_DB BUSCO_C BUSCO_S BUSCO_D BUSCO_F BUSCO_M BUSCO_N
    do
	if [ "${NAME}" = "Name" ] ; then
	    continue
	fi

	if [ "${INPUTS_CLUSTER}" ] ; then
	    if ( grep "\<${INPUTS_CLUSTER}\>" ${GENOMES}/clusters.txt \
		     | grep -qs "\<${NAME}\>" )
	    then
		: nop
	    else
		echo 1>&2 "## skipping $NAME (INPUTS_CLUSTER=${INPUTS_CLUSTER})"
		continue
	    fi
	fi
		
	if [ "${INPUTS_REMOVE_REDUNDENT}" ] ; then
	    case "$NAME" in
		*~)
		    echo 1>&2 "## skipping $NAME (redundent)"
		    continue
	    esac
	fi

	if [ "${INPUTS_BUSCO_DB}" ] ; then
	    if [ "${INPUTS_BUSCO_DB}" != "${BUSCO_DB}" ] ; then
		echo 1>&2 "## skipping $NAME (BUSCO_DB=${BUSCO_DB})"
		continue
	    fi
	fi
	if [ "${INPUTS_BUSCO_C}" ] ; then
	    BUSCO_C="$(echo "${BUSCO_C}" | sed -e 's/%$//')"
	    if perl -e "exit !(${INPUTS_BUSCO_C} <= ${BUSCO_C})" ; then
		: ok
	    else
		echo 1>&2 "## skipping $NAME (BUSCO_C=${BUSCO_C}%)"
		continue
	    fi
	fi
	if [ "${INPUTS_BUSCO_D}" ] ; then
	    BUSCO_D="$(echo "${BUSCO_D}" | sed -e 's/%$//')"
	    if perl -e "exit !(${INPUTS_BUSCO_C} >= ${BUSCO_D})" ; then
		: ok
	    else
		echo 1>&2 "## skipping $NAME (BUSCO_D=${BUSCO_D}%)"
		continue
	    fi
	fi

	echo 1>&2 "## $NAME ($ACCESSION)"
	for EXT in fna faa gff ; do
	    cp --archive ${GENOMES}/genomes/${NAME}.${EXT} ${INPUTS}
	done
    done
)
    



# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 '# Done.'

