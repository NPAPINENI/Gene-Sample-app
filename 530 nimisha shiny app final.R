if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install(c("data.table","TCGAbiolinks","shiny","SummarizedExperiment","ggplot2","DT", "dplyr"), force = TRUE, update = TRUE, ask = FALSE)
install.packages("shinyWidgets")
library(shinyWidgets)

library(shiny)
library(tidyverse)
library(httr)
library(data.table)
library(ggplot2)

# Read in data from URLs
url1 <- "https://tcga-xena-hub.s3.us-east-1.amazonaws.com/download/TCGA.BRCA.sampleMap%2FHiSeqV2.gz"
url2 <- "https://tcga-xena-hub.s3.us-east-1.amazonaws.com/download/probeMap%2Fhugo_gencode_good_hg19_V24lift37_probemap"

data1 <- fread(url1)
data2 <- fread(url2)

# Create a list of variable names
variables <- colnames(data1)

samples <- data1[[1]]  # Assuming the samples are in the first column of data1
genes <- data2[[1]]    # Assuming the genes are in the first column of data2

# Check if there are mutual elements
mutual_elements <- intersect(samples, genes)
data1_mutual <- data1[samples %in% mutual_elements, ]
data2_mutual <- data2[genes %in% mutual_elements, ]

# Merge the data frames on their common elements
combined_data <- merge(data2_mutual, data1_mutual, by.y = names(data1_mutual)[1], by.x = names(data2_mutual)[1],all=TRUE)

# Print the combined data frame
combined_data


# Define UI for the application



# Load necessary libraries
library(shiny)
library(data.table)

# Read in data from URLs
url1 <- "https://tcga-xena-hub.s3.us-east-1.amazonaws.com/download/TCGA.BRCA.sampleMap%2FHiSeqV2.gz"
url2 <- "https://tcga-xena-hub.s3.us-east-1.amazonaws.com/download/probeMap%2Fhugo_gencode_good_hg19_V24lift37_probemap"

data1 <- fread(url1)
data2 <- fread(url2)

# Get the samples and genes
samples <- data1[[1]]  # Assuming the samples are in the first column of data1
genes <- data2[[1]]    # Assuming the genes are in the first column of data2

# Find the mutual elements
mutual_elements <- intersect(samples, genes)

# Subset the data frames to keep only mutual element rows
data1_mutual <- data1[samples %in% mutual_elements, ]
data2_mutual <- data2[genes %in% mutual_elements, ]

# Merge the data frames on their common elements
combined_data <- merge(data1_mutual, data2_mutual, by.x = names(data1_mutual)[1], by.y = names(data2_mutual)[1], all = TRUE)

# Define UI for the application
library(shiny)
library(ggplot2)

ui <- fluidPage(
  titlePanel("Gene and sample Information"),
  sidebarLayout(
    sidebarPanel(
      pickerInput("selected_gene", "Select a gene:", choices = combined_data$gene, options = list(`style` = "btn-info", `icon` = "search")),
      pickerInput("selected_transcript", "Select a sample:", choices = names(data1)[-1], options = list(`style` = "btn-info", `icon` = "search"))
    ),
    mainPanel(
      tableOutput("displayData"),
      plotOutput("histogramPlot")
    )
  )
)


# Define server logic
server <- function(input, output) {
  output$displayData <- renderTable({
    selected_gene_data <- combined_data[combined_data$gene == input$selected_gene, ]
    selected_transcript_count <- as.numeric(selected_gene_data[[input$selected_transcript]])
    extracted_data <- data.frame(gene_name = input$selected_gene,
                                 sample_name = input$selected_transcript,
                                 gene_expression_counts = selected_transcript_count,
                                 chrom_number = selected_gene_data$chrom, # Adjust the column name if necessary
                                 block_counts = selected_gene_data$blockCount) # Adjust the column name if necessary
    extracted_data
  })
  
  output$histogramPlot <- renderPlot({
    # Get the selected gene data
    selected_gene_data <- combined_data[combined_data$gene == input$selected_gene, ]
    
    # Melt the data into a long format
    long_data <- melt(selected_gene_data[, -c(1, 5, 6), with = FALSE], id.vars = NULL, variable.name = "transcript", value.name = "counts")
    
    # Remove rows with NA/NaN values in the 'counts' column
    long_data <- long_data[!is.na(long_data$counts), ]
    
    # Sort the transcript values
    sorted_transcripts <- sort(unique(long_data$transcript))
    selected_transcript_index <- match(input$selected_transcript, sorted_transcripts)
    
    # Get the 10 transcripts closest to the selected transcript
    start_index <- max(1, selected_transcript_index - 5)
    end_index <- min(length(sorted_transcripts), selected_transcript_index + 5)
    selected_range <- sorted_transcripts[start_index:end_index]
    
    # Filter the data to include only the selected transcripts
    filtered_data <- long_data[long_data$transcript %in% selected_range, ]
    
 
    # Create the histogram plot
    ggplot(filtered_data, aes(x = transcript, y = counts, fill = (transcript == input$selected_transcript))) +
      geom_bar(stat = "identity", position = "dodge") +
      labs(title = "Histogram of sample Counts",
           x = "samples",
           y = "Counts",
           fill = "Selected sample") +
      theme_minimal()
  })
}

# Run the application
shinyApp(ui = ui, server = server)
