---
name: "independent-filtering-variance"
description: "Filter high-throughput features by overall variance prior to multiple testing adjustment to increase detection power."
version: "1.0.0"
authors:
  - name: "Waldron Lab"
date: "2026-08-28"
status: "draft"
type: "atomic"
license: "CC-BY-4.0"
publication_doi: "10.1073/pnas.0914005107"
citation: "10.1073/pnas.0914005107"
protocols_used: []
key_packages:
    - "genefilter"
    - "limma"
    - "ALL (Acute Lymphoblastic Leukemia)"
category: "Statistical Analysis"
tags:
    - "filtering"
    - "variance"
    - "multiple testing"
    - "microarray"
---

# Independent Filtering by Overall Variance
Independent filtering is a two-stage statistical approach for high-dimensional data (e.g., microarray or RNA-seq gene expression). In Stage 1, uninformative variables are filtered out using overall variance across all samples (ignoring class labels). In Stage 2, differential expression testing and FDR adjustments are applied only to the retained variables.

## Materials
_ **Software & Repositories**
  - [`genefilter`] ([Bioconductor](https://bioconductor.org/packages/genefilter)) - Methods for filtering genes from high-throughput experiments.
  - [`limma`] ([Bioconductor](https://bioconductor.org/packages/limma)) - Linear models for microarray and RNA-seq data.
- **Databases & Reference Data**
  - [`ALL`] ([Bioconductor](https://bioconductor.org/packages/ALL)) - Acute Lymphoblastic Leukemia dataset.

## Steps

### Step 1: Calculate Overall Feature Variance
Compute the sample variance across all arrays for each feature, ignoring sample class labels.

```r
library(genefilter)
library(ALL)
data(ALL)
```

# Compute overall variance for each feature across all samples
```r
feature_vars <- apply(exprs(ALL), 1, var)
```
### Step 2: Apply Variance Cutoff
Filter out lower 50% of features (theta = 0.5).

```r
cutoff <- quantile(feature_vars, 0.5)
selected_features <- feature_vars > cutoff
filtered_ALL <- ALL[selected_features, ]
```

### Step 3: Stage 2 Hypothesis Testing
Perform gene-by-gene differential expression analysis on the retained subset, followed by standard multiple testing adjustment (e.g., Benjamini-Hochberg FDR).

```r
library(limma)
design <- model.matrix(~ ALL$BT)
fit <- lmFit(filtered_ALL, design)
fit <- eBayes(fit)
results <- topTable(fit, adjust.method="BH", number=Inf)
```
## Notes

- The filtering statistic must be independent of the biological group labels and the differential-expression test statistic. Do not calculate variance separately by group or use outcome information when selecting features.
- Apply appropriate quality control and normalization before calculating feature variance. Variance filtering does not replace those steps.
- The 50% cutoff is an example choice. Adjust the cutoff based on the dataset and report the selected threshold and number of retained features.
- The example uses the `ALL` dataset and `limma`; adapt the design formula and contrasts to the experimental study.
- Benjamini-Hochberg adjustment is applied only to the retained features, so the filtering rule and retained feature count should be documented for reproducibility.
