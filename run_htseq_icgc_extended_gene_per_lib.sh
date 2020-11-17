#!/bin/bash

set -e

anno=PATH_TO_ANNOTATION/rnaseq.gc19_extNc.gtf
outdir=OUTDIR
meta=METADATA_FILE 
aligndir=ALIGNMENT_DIR

mkdir -p $outdir
Q="-q batch"

mem=60gb

if [ ! -z "$1" ]
then
    file=$1

    filebase=$(basename $file)
    aid=$(echo $filebase | cut -f 1 -d '.')

    stranded=$(grep $aid $meta | cut -f 31)

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
                if [ "$stranded" == "fr-firststrand" ]
                then
                    cd $(pwd); umask 077; samtools view -F 4 -r $lib $file | htseq-count -m intersection-nonempty --stranded=reverse --idattr gene_id -r pos - $anno > $outfile && touch $donefile
                elif [ "$stranded" == "fr-secondstrand" ]
                then
                    cd $(pwd); umask 077; samtools view -F 4 -r $lib $file | htseq-count -m intersection-nonempty --stranded=yes --idattr gene_id -r pos - $anno > $outfile && touch $donefile
                else
                    cd $(pwd); umask 077; samtools view -F 4 -r $lib $file | htseq-count -m intersection-nonempty --stranded=no --idattr gene_id -r pos - $anno > $outfile && touch $donefile
                fi
            fi
        done
    fi
else
    for file in $(ls -1 ${aligndir}/*.bam)
    do
        filebase=$(basename $file)
        aid=$(echo $filebase | cut -f 1 -d '.')

        stranded=$(grep $aid $meta | cut -f 31)

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
                    if [ "$stranded" == "fr-firststrand" ]
                    then
                        echo "umask 077; samtools view -F 4 -r $lib $file | htseq-count -m intersection-nonempty --stranded=reverse --idattr gene_id -r pos - $anno > $outfile && touch $donefile" | qsub -l nodes=1:ppn=1,mem=$mem,vmem=$mem,pmem=$mem,walltime=24:00:00 -N icgc_htseq -j oe -o $logfile $Q
                    elif [ "$stranded" == "fr-secondstrand" ]
                    then
                        echo "umask 077; samtools view -F 4 -r $lib $file | htseq-count -m intersection-nonempty --stranded=yes --idattr gene_id -r pos - $anno > $outfile && touch $donefile" | qsub -l nodes=1:ppn=1,mem=$mem,vmem=$mem,pmem=$mem,walltime=24:00:00 -N icgc_htseq -j oe -o $logfile $Q
                    else
                        echo "umask 077; samtools view -F 4 -r $lib $file | htseq-count -m intersection-nonempty --stranded=no --idattr gene_id -r pos - $anno > $outfile && touch $donefile" | qsub -l nodes=1:ppn=1,mem=$mem,vmem=$mem,pmem=$mem,walltime=24:00:00 -N icgc_htseq -j oe -o $logfile $Q
                    fi
                fi
            done
        fi
    done
fi
