# bal_pipe

Automated, reproducible, modular and scalable workflow for **de novo bacterial genome assembly, annotation and genomic characterization of lactic acid bacteria (BAL)** from Illumina paired-end sequencing data.

Master's Thesis — Universidad Internacional de Valencia (VIU).

**bal_pipe** is a Snakemake-based workflow designed as a proof of concept to automate the complete analysis of bacterial sequencing data, from raw sequencing reads to genome annotation and genomic visualization. 

The pipeline was developed with a modular architecture to facilitate reproducibility, scalability and ease of maintenance.

The workflow follows reproducible and FAIR-oriented practices by:

- Using a fully modular Snakemake workflow.
- Managing software dependencies through isolated Conda environments.
- Integrating Docker containers for tools with limited platform compatibility.
- Centralizing all pipeline parameters in `config/config.yaml`.
- Supporting execution of the complete workflow or individual modules.
- Producing standardized summary tables and graphical outputs for downstream analysis.


---

# Project information

This project was developed as part of the Master's Thesis entitled:

**"Development of an automated and reproducible bioinformatics pipeline for genomic analysis of lactic acid bacteria."**

**Author:** Josefina María Cordoba

**Master's Degree in Bioinformatics**

**Institution:** Universidad Internacional de Valencia (VIU)

**Academic year:** 2025–2026

**Location:** Tucumán, Argentina

**Supervisor:** Pablo Marín García


---

# Project initialization

Before running the workflow, initialize the project structure by executing:

```bash
./init.sh
```

This script reads the directory structure defined in `config/config.yaml` and automatically creates the required project directories.

---

# Repository structure

```text
bal_pipe/
├── config/                 # Pipeline configuration files
├── data/                   # Input sequencing data
│   ├── raw/
│   └── original/
├── databases/              # External databases
├── envs/                   # Conda environments
├── logs/                   # Execution logs
├── resources/              # Additional resources
├── results/                # Analysis results
├── rules/                  # Snakemake workflow modules
├── scripts/                # Auxiliary scripts
├── visual/                 # Workflow DAGs and graphical outputs
├── init.sh                 # Project initialization
├── Snakefile               # Main workflow
├── environment.yml         # Base Conda environment
└── README.md
```

---

# Requirements

The pipeline requires:

- Linux or macOS
- Conda (Miniconda or Mambaforge)
- Docker
- Snakemake (≥7)

Create the main environment:

```bash
conda env create -f environment.yml
conda activate bal_pipe
```

The remaining software dependencies are automatically managed through Conda environments or Docker containers during workflow execution.

---

# Input files

The workflow is designed for **Illumina paired-end sequencing data**.

Input samples are defined manually in the main configuration file:

```text
config/config.yaml
```

Each sample must be listed under the `samples` section, specifying the paths to the forward (`r1`) and reverse (`r2`) FASTQ files.

Example:

```yaml
samples:
  SAMPLE_01:
    r1: "data/raw/SAMPLE_01_R1.fastq.gz"
    r2: "data/raw/SAMPLE_01_R2.fastq.gz"

  SAMPLE_02:
    r1: "data/raw/SAMPLE_02_R1.fastq.gz"
    r2: "data/raw/SAMPLE_02_R2.fastq.gz"
```

The corresponding raw sequencing files must be placed in:

```text
data/raw/
```

The sample identifiers defined in `config/config.yaml` are used throughout the workflow to generate sample-specific outputs and establish dependencies between analysis modules.

Before running the pipeline, users should update the `samples` section according to their own dataset and ensure that the specified FASTQ files are available in `data/raw/`.

---

# Configuration

Pipeline parameters are centralized in:

```text
config/config.yaml
```

This file contains:

- Project information
- Sample definitions
- Computational resources
- Output directories
- Software parameters
- Database locations
- Docker images
- Module-specific settings

Most workflow behaviour can be customized by editing this configuration file.

---

# Running the pipeline

Run the complete workflow using:

```bash
snakemake --use-conda --conda-frontend conda --cores 8
```

To inspect the execution plan without running any job:

```bash
snakemake --dry-run --use-conda
```

The workflow DAG and execution logs are generated automatically in the `visual/` and `logs/` directories after successful execution.

---

# Pipeline overview

The workflow consists of the following modules:

| Module | Description |
|----------|-------------|
| **01_quality_control** | Quality assessment of raw sequencing reads using FastQC and MultiQC. |
| **02_preprocessing** | Adapter removal and quality filtering using fastp. |
| **03_taxonomic_classification** | Taxonomic classification of sequencing reads using Kraken2. |
| **04_assembly** | *De novo* genome assembly using SPAdes. |
| **05_assembly_quality** | Assembly quality assessment using QUAST. |
| **06_annotation** | Structural and functional genome annotation using Prokka. |
| **07_assembly_summary** | Automatic consolidation of QUAST statistics into summary tables. |
| **08_annotation_summary** | Automatic consolidation of Prokka annotation statistics. |
| **09_genomic_visualization** | Circular genome visualization using Circos. |

---

# Outputs

Pipeline outputs are automatically organized within the `results/` directory, while workflow documentation files are generated in the `visual/` and `logs/` directories.

## Intermediate outputs

The workflow generates the following intermediate results during the analysis:

- FastQC reports
- MultiQC reports
- Quality-filtered FASTQ files
- Kraken2 taxonomic classification reports
- Genome assemblies
- QUAST assembly quality reports
- Prokka genome annotation files


## Final outputs

The final products generated by **bal_pipe** include:

- Assembly summary table (`quast_summary.tsv`)
- Annotation summary table (`prokka_summary.tsv`)
- Circos genome visualizations

These outputs provide an integrated overview of assembly quality, genome annotation statistics, and graphical genome representation, facilitating downstream analysis and comparison between samples.

## Workflow documentation

In addition to the analysis outputs, the pipeline automatically generates:

- Workflow DAGs
- Rule graphs
- Execution logs

These files document the workflow structure and execution, supporting reproducibility and technical auditing.

---

# Reproducibility

The pipeline was designed to maximize reproducibility and portability across different computational environments.

Reproducibility is ensured through:

- Snakemake workflow management.
- Explicit rule dependencies based on input/output relationships.
- Modular workflow architecture.
- Independent Conda environments for each analysis module.
- Docker containers for software requiring platform-specific compatibility.
- Centralized configuration in `config/config.yaml`.
- Explicit sample definition in `config/samples.tsv`.
- Automated project initialization with `init.sh`.
- Automatic generation of workflow DAGs.
- Automatic logging of pipeline execution.

## Demonstration dataset

To facilitate reproducibility and allow users to evaluate the workflow, **bal_pipe** provides the script:

```bash
scripts/get_data.sh
```

This script downloads the demonstration dataset directly from the European Nucleotide Archive (ENA) and stores the FASTQ files in `data/original/` using the orginal filenames. It is intended exclusively for reproducing the example analysis provided with the repository. 

For analyses of new datasets, users should replace the demonstration FASTQ files with their own sequencing data and update the `samples` section in `config/config.yaml` accordingly.

---

# Software integrated

The current version of **bal_pipe** integrates:

- FastQC
- MultiQC
- fastp
- Kraken2
- SPAdes
- QUAST
- Prokka
- Circos

Thanks to its modular architecture, additional tools and analysis modules can be incorporated with minimal modifications to the workflow.

---

# Citation

If you use **bal_pipe** in your research, please cite the corresponding Master's Thesis together with the software tools integrated into the workflow.