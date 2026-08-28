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
  - "limma"
  - "Biobase"
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
- **Software & Repositories**
  - [`Biobase`](https://bioconductor.org/packages/Biobase) - Infrastructure for Bioconductor expression data objects.
  - [`limma`] ([Bioconductor](https://bioconductor.org/packages/limma)) - Linear models for microarray and RNA-seq data.
- **Databases & Reference Data**
  - [`ALL`] ([Bioconductor](https://bioconductor.org/packages/ALL)) - Acute Lymphoblastic Leukemia dataset.

## Steps

### Step 1: Calculate Overall Feature Variance
Compute the sample variance across all arrays for each feature, ignoring sample class labels.
```r
library(ALL)
data(ALL)
```
Compute overall variance using base R:
```r
feature_vars <- apply(Biobase::exprs(ALL), 1, var)
```
### Step 2: Apply Variance Cutoff
Filter out lower 50% of features (theta = 0.5).
```r
cutoff <- quantile(feature_vars, 0.5)
selected_features <- feature_vars > cutoff
filtered_ALL <- ALL[selected_features, ]
```
### Step 3: Stage 2 Hypothesis Testing
Perform gene-by-gene differential expression analysis on the retained subset.
```r
library(limma)

bt_subtype <- Biobase::pData(filtered_ALL)$BT
group <- factor(
  ifelse(grepl("^B", bt_subtype), "B",
       ifelse(grepl("^T", bt_subtype), "T", NA_character_)),
  levels = c("B", "T")
)
stopifnot(!anyNA(group), nlevels(group) == 2)
design <- model.matrix(~ group)

fit <- lmFit(filtered_ALL, design)
fit <- eBayes(fit)

group_coefficient <- grep("^group", colnames(design), value = TRUE)[1]
results <- topTable(fit, coef = group_coefficient, adjust.method = "BH", number = Inf)
```

## Notes

- The filtering statistic must be independent of the biological group labels and the differential-expression test statistic. Do not calculate variance separately by group or use outcome information when selecting features.
- Apply appropriate quality control and normalization before calculating feature variance. Variance filtering does not replace those steps.
- The 50% cutoff is an example choice. Adjust the cutoff based on the dataset and report the selected threshold and number of retained features.
- The example uses the `ALL` dataset and `limma`; the `BT` subtypes are collapsed into broad B-cell and T-cell lineages. Adapt the design formula and contrasts to the experimental study. Specifically, the `BT` prefix mapping (`B*` to B-cell and `T*` to T-cell) is specific to the `ALL` dataset. For another dataset, replace it with the appropriate grouping variable and verify that the resulting levels represent the intended comparison.
- The first factor level (`B`) is the reference group. Set the factor levels explicitly when the biological reference matters.
- Benjamini-Hochberg adjustment is applied only to the retained features, so the filtering rule and retained feature count should be documented for reproducibility.
