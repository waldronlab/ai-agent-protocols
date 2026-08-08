---
name: quality-control-16s
description: Quality control pipeline for 16S rRNA amplicon sequencing data
version: 1.0.0
authors:
  - name: Levi Waldron
    orcid: 0000-0003-2725-0694
date: 2026-08-08
status: stable
license: CC-BY-4.0

protocol_doi: ~
repository_doi: 10.5281/zenodo.XXXXXXX
publication_doi: ~

citations:
  - "10.1038/nmeth.3869"

protocols_used:
  - name: taxonomic-classification
    repository: waldronlab/ai-agent-protocols
    version: "1.0.0"

key_packages:
  - curatedMetagenomicData
  - mia

category: metagenomics
tags: [16s, quality-control, amplicon]
---

# Quality Control for 16S rRNA Amplicon Sequencing

This protocol describes a standard quality control pipeline for 16S data using Bioconductor packages.

## Materials

- `curatedMetagenomicData`
- `mia`

## Steps

### Step 1: Load data
Load the 16S sequencing data into a TreeSummarizedExperiment object.

### Step 2: Quality Filtering
Filter out samples with low read counts or poor quality scores.

## References

- Pasolli E et al. 2017, Nature Methods — doi:10.1038/nmeth.3869
