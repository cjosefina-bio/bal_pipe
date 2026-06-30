# ------------------------------------------------- #
# BAL de novo genome assembly pipeline              #    
# Main Snakefile                                    #
# ------------------------------------------------- #

configfile: "config/config.yaml"

SAMPLES = list(config["samples"].keys())


rule all:
    input:
        ["results/01_quality_control/multiqc/multiqc_report.html"]
        + expand(
            "results/03_taxonomic_classification/kraken2/{sample}/{sample}.kraken2.report",
            sample=SAMPLES
        )
        + expand(
            "results/06_annotation/prokka/{sample}/{sample}.gff",
            sample=SAMPLES
        )
        + [
            "results/07_assembly_summary/quast_summary.tsv",
            "results/08_annotation_summary/prokka_summary.tsv"
        ]

include: "rules/01_quality_control.smk"
include: "rules/02_preprocessing.smk"
include: "rules/04_assembly.smk"
include: "rules/03_taxonomic_classification.smk"
include: "rules/05_assembly_quality.smk"
include: "rules/06_annotation.smk"
include: "rules/07_assembly_summary.smk"
include: "rules/08_annotation_summary.smk"