# Gene and Sample Information App

This repository contains a Shiny app that allows users to explore gene and sample information from TCGA and Xena data. The app allows users to select a gene and a sample, and displays a table with relevant information. Additionally, the app generates a histogram of sample counts for the selected gene.

## Dependencies

To run this app, you will need the following R packages:

- shiny
- shinyWidgets
- tidyverse
- httr
- data.table
- ggplot2

You can install these packages using the following commands:

```R
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install(c("data.table","TCGAbiolinks","shiny","SummarizedExperiment","ggplot2","DT", "dplyr"), force = TRUE, update = TRUE, ask = FALSE)
install.packages("shinyWidgets")
```

## How to run the app

To run the app, open the `app.R` file in RStudio and click on the "Run App" button, or run the following command in the R console:

```R
shiny::runApp()
```

This will launch the Shiny app in your default web browser.

## App Interface

The app interface is divided into two sections: a sidebar panel and a main panel.

The sidebar panel allows you to select a gene and a sample using dropdown menus. The main panel displays a table with the gene name, sample name, gene expression counts, chromosome number, and block counts. Below the table, a histogram of sample counts for the selected gene is displayed.

## Data Sources

The app uses two data sources from TCGA and Xena:

1. TCGA.BRCA.sampleMap%2FHiSeqV2.gz: https://tcga-xena-hub.s3.us-east-1.amazonaws.com/download/TCGA.BRCA.sampleMap%2FHiSeqV2.gz
2. hugo_gencode_good_hg19_V24lift37_probemap: https://tcga-xena-hub.s3.us-east-1.amazonaws.com/download/probeMap%2Fhugo_gencode_good_hg19_V24lift37_probemap

These data sources are read into the app using the `fread` function from the `data.table` package. The data is then combined and filtered to keep only the mutual elements between the two datasets.

## acknolwedgement
This app is based on data from the following sources:
TCGA and XENA data bases


## Contributors
This app is developed by Nimisha
