---
name: taxonomic-classification
description: Assign taxonomy to 16S amplicon sequences
version: 1.0.0
authors:
  - name: Levi Waldron
date: 2026-08-08
status: stable

protocols_used: []
key_packages:
  - dada2

category: metagenomics
tags: [16s, taxonomy, dada2]
---

# Taxonomic Classification of 16S Sequences

This protocol uses DADA2 to assign taxonomy to processed 16S sequences.

## Materials

- `dada2`
- Reference database (e.g., Silva)

## Steps

### Step 1: Assign Taxonomy
Run `assignTaxonomy` on the sequence table using the reference database.

## References
- None
