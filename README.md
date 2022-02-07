## PCAWG 3 - Expression counting

This repository contains the scripts used for generating the RNA-Seq expression counts on the normal and extended annotation files.
Expression counts were generated on gene and exon level for both library-level and merged alignment files. Both HTSeq and DexSeq counts were generated.

### Preparation of annotation files

 - `run_dexseq_annotation.sh` - preparation of annotation file for DexSeq
 - `run_dexseq_extended_annotation.sh` - preparation of extended annotation file for DexSeq

### Counting

Counting was performed for both HTSeq and DexSeq tools on gene and exon level. For normal and extended annotation, we also generated per-library counts.
