# ---------------------------------------------------
# BAL de novo genome assembly pipeline
# Main Snakefile
# ---------------------------------------------------

configfile: "config/config.yaml"

SAMPLES = list(config["samples"].keys())

rule all:
    input:
        expand(
            "results/05_annotation/prokka/{sample}/{sample}.gff",
            sample=SAMPLES
        )

include: "rules/01_quality_control.smk"
include: "rules/02_preprocessing.smk"
include: "rules/03_assembly.smk"
include: "rules/04_assembly_quality.smk"
include: "rules/05_annotation.smk"