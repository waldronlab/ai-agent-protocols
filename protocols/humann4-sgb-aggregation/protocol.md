---
name: humann4-sgb-aggregation
description: Aggregate and subsample isolate genomes and MAGs for MetaPhlAn 4.2 SGBs.
version: 1.0.0
authors:
  - name: Levi Waldron
    orcid: 0000-0003-2725-0694
reviews:
  - name: Curtis Huttenhower
    date: 2026-08-18
    protocol_version: 1.0.0
    status: approved
  - name: Eric Franzosa
    date: 2026-08-18
    protocol_version: 1.0.0
    status: approved
date: 2026-08-08
status: draft
license: CC-BY-4.0
type: atomic

protocol_doi: ~
repository_doi: ~
publication_doi: ~

citation: "10.1016/j.cell.2019.01.001"

upstream_repositories:
  - "https://github.com/biobakery/metaphlan"
  - "https://github.com/biobakery/panphlan"
  - "https://github.com/biobakery/biobakery-nextflow"

database_urls:
  - "http://cmprod1.cibio.unitn.it/databases/MetaPhlAn/"
  - "http://cmprod1.cibio.unitn.it/databases/PanPhlAn/"

protocols_used: []
key_packages: []
category: metagenomics
tags: [humann, chocophlan, database, sgb, metaphlan]
---

# HUMAnN 4 SGB Aggregation

This protocol details the retrieval and aggregation of Species-level Genome Bins (SGBs) for compatibility with MetaPhlAn 4.2.

## Materials

- **Software & Repositories:**
  - `Mash` ([marbl/Mash](https://github.com/marbl/Mash)) — Fast genome distance estimation and min-hashing.
  - `metaphlan` ([biobakery/metaphlan](https://github.com/biobakery/metaphlan)) — Species-level genome bin (SGB) taxonomy and marker definitions.
  - `panphlan` ([biobakery/panphlan](https://github.com/biobakery/panphlan)) — Reference implementation for Mash-distance subsampling logic.
- **Databases & Reference Data:**
  - MetaPhlAn 4.2 SGB Genome Catalog ([Segata Lab Database Server](http://cmprod1.cibio.unitn.it/databases/MetaPhlAn/)) — Reference isolate genomes and MAGs.

## Steps

### Step 1: Retrieve SGB Genomes

Download all representative isolate genomes and Metagenome-Assembled Genomes (MAGs) corresponding to the MetaPhlAn 4.2 SGB definitions. Ensure all FASTA files are quality filtered (e.g. using CheckM).

### Step 2: Subsample Overrepresented SGBs

For SGBs containing more than 100 member genomes, subsample the set down to a maximum of 100 representative genomes. 
This is done to limit the computational scale of subsequent clustering steps.
Use `Mash` to sketch and calculate pairwise distances between all genomes in the SGB.
Select a representative subset that maximizes the Mash distances to preserve the maximum genomic diversity within the SGB.

## Notes

- **Computational Context:** This is the first step in the HUMAnN 4 database generation pipeline. End-to-end execution across tens of thousands of SGBs is typically executed in parallel on high-performance computing (HPC) clusters.
- SGBs with fewer than 100 members do not require subsampling.

## History & Reviews
<!-- Newest versions at the top -->

### Version 1.0.0 (2026-08-08)

#### Changes
- Initial protocol creation.

#### Reviews

**Review by Curtis Huttenhower**
- **Date:** 2026-08-18
- **Status:** `approved`
- **Notes:** Reviewed briefly. It seemed correct but light on detail.

**Review by Eric Franzosa**
- **Date:** 2026-08-18
- **Status:** `approved`
- **Notes:** Reviewed briefly. It seemed correct but light on detail.
