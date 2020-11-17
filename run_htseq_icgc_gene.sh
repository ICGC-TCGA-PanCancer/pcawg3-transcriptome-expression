#!/bin/bash

set -e

anno=PATH_TO_ANNOTATION/gencode.v19.annotation.hs37d5_chr.gtf
outdir=OUTDIR
meta=METADATA_FILE 
aligndir=ALIGNMENT_DIR

mkdir -p $outdir

mem=60gb

if [ ! -z "$1" ]
then
    file=$1

    filebase=$(basename $file)
    aid=$(echo $filebase | cut -f 1 -d '.')

    stranded=$(grep $aid $meta | cut -f 31)

    donefile="${outdir}/${filebase%bam}count.done"
    logfile="${outdir}/${filebase%bam}count.log"
    outfile="${outdir}/${filebase%bam}count.txt"

    if [ -f ${file%bam}done -a ! -f $donefile ]
    then
        if [ "$stranded" == "fr-firststrand" ]
        then
            cd $(pwd); umask 077; samtools view -F 4 $file | htseq-count -m intersection-nonempty --stranded=reverse --idattr gene_id -r pos - $anno > $outfile && touch $donefile
        elif [ "$stranded" == "fr-secondstrand" ]
        then
            cd $(pwd); umask 077; samtools view -F 4 $file | htseq-count -m intersection-nonempty --stranded=yes --idattr gene_id -r pos - $anno > $outfile && touch $donefile
        else
            cd $(pwd); umask 077; samtools view -F 4 $file | htseq-count -m intersection-nonempty --stranded=no --idattr gene_id -r pos - $anno > $outfile && touch $donefile
        fi
    fi
else
    for file in $(ls -1 ${aligndir}/*.bam)
    do
        filebase=$(basename $file)
        aid=$(echo $filebase | cut -f 1 -d '.')

        stranded=$(grep $aid $meta | cut -f 31)

        donefile="${outdir}/${filebase%bam}count.done"
        logfile="${outdir}/${filebase%bam}count.log"
        outfile="${outdir}/${filebase%bam}count.txt"

        if [ -f ${file%bam}done -a ! -f $donefile ]
        then
            if [ "$stranded" == "fr-firststrand" ]
            then
                echo "umask 077; samtools view -F 4 $file | htseq-count -m intersection-nonempty --stranded=reverse --idattr gene_id -r pos - $anno > $outfile && touch $donefile" | qsub -l nodes=1:ppn=1,mem=$mem,vmem=$mem,pmem=$mem,walltime=24:00:00 -N icgc_htseq -j oe -o $logfile
            elif [ "$stranded" == "fr-secondstrand" ]
            then
                echo "umask 077; samtools view -F 4 $file | htseq-count -m intersection-nonempty --stranded=yes --idattr gene_id -r pos - $anno > $outfile && touch $donefile" | qsub -l nodes=1:ppn=1,mem=$mem,vmem=$mem,pmem=$mem,walltime=24:00:00 -N icgc_htseq -j oe -o $logfile
            else
                echo "umask 077; samtools view -F 4 $file | htseq-count -m intersection-nonempty --stranded=no --idattr gene_id -r pos - $anno > $outfile && touch $donefile" | qsub -l nodes=1:ppn=1,mem=$mem,vmem=$mem,pmem=$mem,walltime=24:00:00 -N icgc_htseq -j oe -o $logfile
            fi
        fi
    done
fi
