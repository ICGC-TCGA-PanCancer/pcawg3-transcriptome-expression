#!/bin/bash

set -e

anno=PATH_TO_ANNOTATION/rnaseq.gc19_extNc.gtf
dexseq=PATH_TO/dexseq_prepare_annotation.py

python ${dexseq $anno ${anno%gtf}dexseq.gff
cat ${anno%gtf}dexseq.gff | sed -e "s/dexseq_prepare_annotation.py/rnaseq.gc19_extNc.gtf/g" > ${anno%gtf}dexseq.gff.tmp
mv ${anno%gtf}dexseq.gff.tmp ${anno%gtf}dexseq.gff
