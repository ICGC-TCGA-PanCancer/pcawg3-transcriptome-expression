#!/bin/bash

set -e

dexseq_count=PATH_TO/dexseq_count.py
anno=PATH_TO_ANNOTATION/gencode.v19.annotation.hs37d5_chr.dexseq.gff
meta=METADATA
aligndir=ALIGNMENT_DIR
outdir=OUTDIR
mkdir -p $outdir

mem=25gb


if [ ! -z "$1" ]
then
    file=$1

    paired=$(samtools view -H $file | grep PG | python is_paired.py)
    filebase=$(basename $file)

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

    if [ -f ${file%bam}done ]
    then
        ### per read group
        for lib in $(samtools view -H $file | grep -e "^@RG" | cut -f 2 | cut -f 2- -d ":")
        do
            donefile="${outdir}/${filebase%bam}${lib}.count.done"
            logfile="${outdir}/${filebase%bam}${lib}.count.log"
            outfile="${outdir}/${filebase%bam}${lib}.count.txt"
            if [ ! -f $donefile ]
            then
                cd $(pwd); samtools view -F 4 -r $lib $file | python $dexseq_count -s $strand -f sam -r pos -p $paired $anno - $outfile > $logfile 2>&1 && touch $donefile 
            fi
        done
    fi
else
    for file in $(ls -1 ${aligndir}/*.bam)
    do
        paired=$(samtools view -H $file | grep PG | python is_paired.py)
        filebase=$(basename $file)

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

        if [ -f ${file%bam}done ]
        then
            ### per read group
            for lib in $(samtools view -H $file | grep -e "^@RG" | cut -f 2 | cut -f 2- -d ":")
            do
                donefile="${outdir}/${filebase%bam}${lib}.count.done"
                logfile="${outdir}/${filebase%bam}${lib}.count.log"
                outfile="${outdir}/${filebase%bam}${lib}.count.txt"

                if [ ! -f $donefile ]
                then
                    echo "samtools view -F 4 -r $lib $file | python $dexseq_count -s $strand -f sam -r pos -p $paired $anno - $outfile && touch $donefile" | qsub -l nodes=1:ppn=1,mem=$mem,vmem=$mem,pmem=$mem,walltime=24:00:00 -N icgc_dexseq -j oe -o $logfile
                fi
            done
        fi
    done
fi
