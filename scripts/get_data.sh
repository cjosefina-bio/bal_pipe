#!/usr/bin/env bash

set -euo pipefail

# -----------------------------------------------------------
# Download the public Illumina paired-end datasets
# used to reproduce the bal_pipe validation example.
# Source: European Nucleotide Archive (ENA)
#
# Usage:
#   chmod +x get_data.sh
#   ./get_data.sh
# -----------------------------------------------------------

# Determine the project root from the script location.
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="${PROJECT_DIR}/data/original"

mkdir -p "${DATA_DIR}"

download_sample() {

    local sample="$1"
    local accession="$2"
    local url_r1="$3"
    local url_r2="$4"

    local sample_dir="${DATA_DIR}/${sample}"

    mkdir -p "${sample_dir}"

    echo "--------------------------------------------------"
    echo "Sample: ${sample}"
    echo "Run accession: ${accession}"
    echo "Output directory: ${sample_dir}"
    echo "--------------------------------------------------"

    wget \
        --continue \
        --show-progress \
        --directory-prefix="${sample_dir}" \
        "${url_r1}"

    wget \
        --continue \
        --show-progress \
        --directory-prefix="${sample_dir}" \
        "${url_r2}"

    echo "✓ ${sample} downloaded successfully."
    echo
}

# --------------------------------------------------
# Public test datasets
# --------------------------------------------------

# Lactobacillus delbrueckii subsp. delbrueckii DSM 20074
# BioProject: PRJNA222257
download_sample \
    "LD_01" \
    "SRR1151241" \
    "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR115/001/SRR1151241/SRR1151241_1.fastq.gz" \
    "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR115/001/SRR1151241/SRR1151241_2.fastq.gz"

# Lacticaseibacillus rhamnosus
# BioProject: PRJNA885481
download_sample \
    "LR_02" \
    "SRR21818859" \
    "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR218/059/SRR21818859/SRR21818859_1.fastq.gz" \
    "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR218/059/SRR21818859/SRR21818859_2.fastq.gz"

# Lactobacillus acidophilus
# BioProject: PRJNA336518
download_sample \
    "LA_03" \
    "SRR4041254" \
    "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR404/004/SRR4041254/SRR4041254_1.fastq.gz" \
    "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR404/004/SRR4041254/SRR4041254_2.fastq.gz"

# Lactobacillus helveticus
# BioProject: PRJNA336518
download_sample \
    "LH_04" \
    "SRR4450492" \
    "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR445/002/SRR4450492/SRR4450492_1.fastq.gz" \
    "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR445/002/SRR4450492/SRR4450492_2.fastq.gz"

# Levilactobacillus brevis
# BioProject: PRJNA336518
download_sample \
    "LB_05" \
    "SRR35706911" \
    "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR357/011/SRR35706911/SRR35706911_1.fastq.gz" \
    "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR357/011/SRR35706911/SRR35706911_2.fastq.gz"

echo "------------------------------------------------------"
echo "All public test datasets were downloaded successfully."
echo "Files are available in:"
echo "  ${DATA_DIR}"
echo "------------------------------------------------------"