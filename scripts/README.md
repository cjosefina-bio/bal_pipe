# scripts

## Description

This directory contains the auxiliary scripts used by **bal_pipe** to support workflow execution, result summarization, visualization, and project documentation.

## Contents

`generate_dag.sh`:  Automatically generates the workflow DAG, rule graph, and execution logs after successful pipeline execution. |
`get_data.sh`: Downloads the demonstration dataset from the European Nucleotide Archive (ENA). |
`prepare_circos.py`: Generates the input files required for Circos genome visualization. |
`prokka_summary.py`: Consolidates Prokka annotation statistics into a single summary table. |
`quast_summary.py`: Consolidates QUAST assembly statistics into a single summary table. |

## Notes

These scripts are executed automatically by the workflow and generally do not require user modification.
