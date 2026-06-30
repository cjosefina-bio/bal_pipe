#!/usr/bin/env python3

import argparse
from pathlib import Path
import pandas as pd


def main():

    parser = argparse.ArgumentParser(
        description="Generate a summary table from QUAST reports."
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

        quast = pd.read_csv(
            report_file,
            sep="\t",
            header=None,
            names=["metric", "value"]
        )

        metrics = dict(zip(quast["metric"], quast["value"]))

        rows.append({
            "sample": sample,
            "contigs": metrics.get("# contigs"),
            "largest_contig": metrics.get("Largest contig"),
            "total_length": metrics.get("Total length"),
            "gc_percent": metrics.get("GC (%)"),
            "n50": metrics.get("N50"),
            "n90": metrics.get("N90"),
            "aun": metrics.get("auN"),
            "l50": metrics.get("L50"),
            "l90": metrics.get("L90"),
            "n_per_100kbp": metrics.get("N's per 100 kbp"),
        })

    summary = pd.DataFrame(rows)

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)

    summary.to_csv(output, sep="\t", index=False)


if __name__ == "__main__":
    main()