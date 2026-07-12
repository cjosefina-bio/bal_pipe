# ------------------------------------------------- #
# BAL de novo genome assembly pipeline              #    
# Main Snakefile                                    #
# ------------------------------------------------- #

configfile: "config/config.yaml"

SAMPLES = list(config["samples"].keys())


rule all:
    input:
        ["results/01_quality_control/multiqc/multiqc_report.html",
        "results/02_preprocessing/multiqc/multiqc_report.html"
        ]
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
        + expand(
            config["09_genomic_visualization"]["circos"]["output_dir"]
            + "/{sample}/circos.png",
            sample=SAMPLES
        )

include: "rules/01_quality_control.smk"
include: "rules/02_preprocessing.smk"
include: "rules/04_assembly.smk"
include: "rules/03_taxonomic_classification.smk"
include: "rules/05_assembly_quality.smk"
include: "rules/06_annotation.smk"
include: "rules/07_assembly_summary.smk"
include: "rules/08_annotation_summary.smk"
include: "rules/09_genomic_visualization.smk"

#DAG generation

DAG_DIR = config["00_workflow_dag"]["dag_dir"]
DAG_LOG_DIR = config["00_workflow_dag"]["log_dir"]


onsuccess:
    shell(
        f"scripts/generate_dag.sh {DAG_DIR} {DAG_LOG_DIR}"
    )