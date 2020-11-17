#!/bin/bash

set -e

anno=PATH_TO_ANNOTATION/gencode.v19.annotation.hs37d5_chr.gtf
dexseq=PATH_TO/dexseq_prepare_annotation.py

python ${dexseq} $anno ${anno%gtf}dexseq.gff
cat ${anno%gtf}dexseq.gff | sed -e "s/dexseq_prepare_annotation.py/gencode.v19.annotation.hs37d5_chr.gtf/g" > ${anno%gtf}dexseq.gff.tmp
mv ${anno%gtf}dexseq.gff.tmp ${anno%gtf}dexseq.gff
