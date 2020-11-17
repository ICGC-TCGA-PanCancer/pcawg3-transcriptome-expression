#!/bin/bash

set -e

dexseq_count=PATH_TO/dexseq_count.py
anno=PATH_TO_ANNOTATION/rnaseq.gc19_extNc.dexseq.gff
meta=METADATA
aligndir=ALIGNMENT_DIR
outdir=OUTDIR
mkdir -p $outdir

mem=30gb


if [ ! -z "$1" ]
then
    file=$1

    filebase=$(basename $file)
    donefile="${outdir}/${filebase%bam}count.done"
    logfile="${outdir}/${filebase%bam}count.log"
    outfile="${outdir}/${filebase%bam}count.txt"

    paired=$(samtools view -H $file | grep PG | python is_paired.py)

    aid=$(echo $filebase | cut -f 1 -d '.')
    stranded=$(grep $aid $meta | cut -f 31)
    if [ "$stranded" == "fr-firststrand" ]
    then
        strand="reverse"
    elif [ "$stranded" == "fr-secondstrand" ]
    then
        strand="yes"
    else
        strand="no"
    fi

    if [ -f ${file%bam}done -a ! -f $donefile ]
    then
        cd $(pwd); samtools view -F 4 $file | python $dexseq_count -s $strand -f sam -r pos -p $paired $anno - $outfile && touch $donefile 
    fi
else
    for file in $(ls -1 ${aligndir}/*.bam)
    do
        filebase=$(basename $file)
        donefile="${outdir}/${filebase%bam}count.done"
        logfile="${outdir}/${filebase%bam}count.log"
        outfile="${outdir}/${filebase%bam}count.txt"

        paired=$(samtools view -H $file | grep PG | python is_paired.py)

        aid=$(echo $filebase | cut -f 1 -d '.')
        stranded=$(grep $aid $meta | cut -f 31)
        if [ "$stranded" == "fr-firststrand" ]
        then
            strand="reverse"
        elif [ "$stranded" == "fr-secondstrand" ]
        then
            strand="yes"
        else
            strand="no"
        fi

        if [ -f ${file%bam}done -a ! -f $donefile ]
        then
            echo "samtools view -F 4 $file | python $dexseq_count -s $strand -f sam -r pos -p $paired $anno - $outfile && touch $donefile" | qsub -l nodes=1:ppn=1,mem=$mem,vmem=$mem,pmem=$mem,walltime=24:00:00 -N icgc_htseq -j oe -o $logfile
        fi
    done
fi
