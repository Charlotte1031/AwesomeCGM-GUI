library(shiny)
library(shinyFiles)
library(git2r)  

script_paths <- list(
  Aleppo2017 = c("preprocessor.R"),
  Anderson2016 = c("preprocessor.R"),
  Broll2021 = c("preprocessor.R"),
  Buckingham2007 = c("preprocessor.R", "preprocessor_updated.R"),
  Chase2005 = c("preprocessor.R"),
  Colas2019 = c("preprocessor.R", "preprocessor_updated.R"),
  Dubosson2018 = c("preprocessor.R"),
  Hall2018 = c("preprocessor.R", "preprocessor_updated.R"),
  Lynch2022 = c("preprocessor.R"),
  Marling2020 = c("preprocessor.R"),
  O_Mally2021 = c("preprocessor.R"),
  Shah2019 = c("preprocessor.R"),
  Tamborlane2008 = c("preprocessor.R"),
  Tsalikian2005 = c("preprocessor.R"),
  Wadwa2023 = c("preprocessor.R")
)

# Define UI
ui <- fluidPage(
  titlePanel("Dataset Processor"),
  
  sidebarLayout(
    sidebarPanel(
      # Select the dataset
      selectInput("dataset", "Choose a Study Dataset:", 
                  choices = names(script_paths)),
      
      # Conditional UI for selecting script version (will show up if multiple scripts exist)
      uiOutput("scriptVersionUI"),
      
      # File upload or folder selection
      fileInput("files", "Upload Target Datasource (multiple files allowed):", 
                multiple = TRUE, accept = c(".csv")),
      shinyDirButton("directory", "Select Folder", "Please select a folder"),
      
      # Process button
      actionButton("process", "Process Dataset"),
      
      # Output results
      downloadButton("downloadData", "Download Processed Dataset")
    ),
    
    mainPanel(
      verbatimTextOutput("processStatus")
    )
  )
)
# Define Server logic
server <- function(input, output, session) {
  
  # Dynamically show script version selection if more than one script is available
  output$scriptVersionUI <- renderUI({
    selected_dataset <- input$dataset
    
    # Get available script versions for the selected dataset
    available_scripts <- script_paths[[selected_dataset]]
    
    if (length(available_scripts) > 1) {
      selectInput("scriptVersion", "Choose Processing Script:", choices = available_scripts)
    }
  })
  
  # Process datasets upon button click
  observeEvent(input$process, {
    # File paths from uploaded files or directory
    files <- if (!is.null(input$files)) {
      input$files$datapath
    } else {
      NULL
    }
    
    if (is.null(files)) {
      output$processStatus <- renderText("No files selected.")
      return()
    }
    
    # Get the selected dataset and script
    selected_dataset <- input$dataset
    selected_script <- if (length(script_paths[[selected_dataset]]) > 1) {
      input$scriptVersion  # Use the selected script version if multiple exist
    } else {
      script_paths[[selected_dataset]][1]  # Default to the only script
    }
    
    # Construct GitHub link for the selected script
    script_url <- paste0("https://github.com/IrinaStatsLab/Awesome-CGM/blob/master/R/", 
                         selected_dataset, "/", selected_script)
    
    # Call your R script to process the datasets (simulated here)
    output$processStatus <- renderText({
      paste("Processing using", script_url, "for", selected_dataset, "dataset...")
      
      # Add logic to download and source the selected R script from GitHub here
      
      "Processing complete!"
    })
  })
  
  # Download handler for processed data
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("processed_", input$dataset, ".csv", sep = "")
    },
    content = function(file) {
      # Write processed data to file (replace with actual data processing output)
      write.csv(data.frame(Example = 1:10), file)
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)