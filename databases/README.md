# databases

## Description

This directory contains the external databases required by **bal_pipe**.

## Contents

- `kraken2/` – Kraken2 **Standard-8** database used for taxonomic classification.

## Notes

The location of each database is specified in `config/config.yaml`.

The demonstration workflow uses the **Kraken2 Standard-8** database. Users may replace it with an alternative Kraken2 database by updating the corresponding path in the configuration file.

If the database is not available locally, it can be downloaded automatically by the workflow before taxonomic classification.