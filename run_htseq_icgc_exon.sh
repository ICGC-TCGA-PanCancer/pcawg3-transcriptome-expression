#!/bin/bash

set -e

anno=PATH_TO_ANNOTATION/gencode.v19.annotation.hs37d5_chr.gtf
outdir=OUTDIR
mkdir -p $outdir

mem=40gb

if [ ! -z "$1" ]
then
    file=$1

    filebase=$(basename $file)
    donefile="${outdir}/${filebase%bam}count.done"
    logfile="${outdir}/${filebase%bam}count.log"
    outfile="${outdir}/${filebase%bam}count.txt"

    if [ -f ${file%bam}done -a ! -f $donefile ]
    then
        cd $(pwd); umask 077; samtools view -F 4 $file | htseq-count -m intersection-nonempty --stranded=no --idattr exon_id -r pos - $anno > $outfile && touch $donefile
    fi
else
    for file in $(ls -1 $(pwd)/alignments_ICGC_2015-04-19/*.bam)
    do
        filebase=$(basename $file)
        donefile="${outdir}/${filebase%bam}count.done"
        logfile="${outdir}/${filebase%bam}count.log"
        outfile="${outdir}/${filebase%bam}count.txt"

        if [ -f ${file%bam}done -a ! -f $donefile ]
        then
            echo "umask 077; samtools view -F 4 $file | htseq-count -m intersection-nonempty --stranded=no --idattr exon_id -r pos - $anno > $outfile && touch $donefile" | qsub -l nodes=1:ppn=1,mem=$mem,vmem=$mem,pmem=$mem,walltime=24:00:00 -N icgc_htseq -j oe -o $logfile
        fi
    done
fi
