#!/bin/bash

# From https://github.com/wwliao/pangenome-utils/blob/main/preprocess_vcf.sh
# Usage: preprocess_vcf.sh <VCF file> <sample name> <max variant size>

VCF=$1
SAMPLE=$2
REF=$3
CHROMS=$4
MAXSIZE=$5

PREFIX=$(basename $VCF .vcf.gz)

MEM="10G"

bcftools view -a -s ${SAMPLE} -Ou ${VCF} \
    | bcftools norm -f ${REF} -c s -m - -Ou \
    | bcftools view -e 'GT="ref" | GT~"\."' -f 'PASS,.' -Ou \
    | bcftools sort -m ${MEM} -T bcftools-sort.XXXXXX -Ou \
    | bcftools norm -d exact -Oz -o ${PREFIX}.norm.vcf.gz \
    && bcftools index -t ${PREFIX}.norm.vcf.gz \
    && bcftools view -e "STRLEN(REF)>${MAXSIZE} | STRLEN(ALT)>${MAXSIZE}" \
                 -r ${CHROMS} -Oz -o ${PREFIX}.norm.max${MAXSIZE}.gz \
                 ${PREFIX}.norm.vcf.gz \
    && bcftools index -t ${PREFIX}.norm.max${MAXSIZE}.gz \
    && rm ${PREFIX}.norm.vcf.gz*
