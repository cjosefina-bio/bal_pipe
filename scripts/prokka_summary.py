#!/usr/bin/env python3

import argparse
from pathlib import Path
import pandas as pd


def main():

    parser = argparse.ArgumentParser(
        description="Generate a summary table from Prokka TSV files."
    )

    parser.add_argument(
        "-i", "--input",
        required=True,
        help="TXT file with columns: sample and report"
    )

    parser.add_argument(
        "-o", "--output",
        required=True,
        help="Output summary TSV file"
    )

    args = parser.parse_args()

    reports = pd.read_csv(args.input, sep="\t")

    if not {"sample", "report"}.issubset(reports.columns):
        raise ValueError(
            "Input file must contain the columns: sample and report"
        )

    rows = []

    for _, row in reports.iterrows():

        sample = row["sample"]
        report_file = row["report"]

        prokka = pd.read_csv(report_file, sep="\t")

        feature_counts = prokka["ftype"].value_counts().to_dict()

        hypothetical_proteins = (
            prokka["product"]
            .fillna("")
            .str.lower()
            .eq("hypothetical protein")
            .sum()
        )

        rows.append({
            "sample": sample,
            "total_features": len(prokka),
            "cds": feature_counts.get("CDS", 0),
            "trna": feature_counts.get("tRNA", 0),
            "rrna": feature_counts.get("rRNA", 0),
            "tmrna": feature_counts.get("tmRNA", 0),
            "hypothetical_proteins": hypothetical_proteins,
        })

    summary = pd.DataFrame(rows)

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)

    summary.to_csv(output, sep="\t", index=False)


if __name__ == "__main__":
    main()