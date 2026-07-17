# data

## Description

This directory stores the sequencing data used as input for the workflow.

## Contents

- `raw/` – Illumina paired-end sequencing reads used as input by the pipeline.
- `original/` – Original sequencing files downloaded from the European Nucleotide Archive (ENA) for the demonstration dataset.

## Notes

The workflow expects the input FASTQ files to be located in `data/raw/` and referenced in `config/config.yaml`. The `original/` directory is provided for reproducibility purposes and preserves the unmodified demonstration dataset downloaded from ENA.