


ui<- shinyUI(fluidPage(
  #theme = shinytheme('slate'),
  titlePanel("Exploring a Subset of MIMIC-III Data"),
  
  
  sidebarLayout(
    sidebarPanel(
      # fileInput('file1', 'Choose CSV File',
      #           accept=c('text/csv',
      #                    'text/comma-separated-values,text/plain',
      #                    '.csv')),
      uiOutput('select'),
      
      p(paste0('by: Ken Tran')),
      p(paste0('Supplemental visual to the code sample')),
      h5(paste0('This dashboard:')),
      h5(paste0('1. Summarizes and plots the distribution of the chosen variable, compatible with both categorical or continuous data')),
      h5(paste0('2. Fits a logitical regression model and plots the odd ratio(s) to quantify the association of the chosen variable with 30-day mortality'))
    ),
    
    
    mainPanel(
      #DT::dataTableOutput('contents'),
      
      #####################################
      # PRINT BUGTEST OUTPUT
      #####################################
      #verbatimTextOutput('logicTest'),
      
      #####################################
      # PRINT ERROR MESSAGE
      #####################################
      conditionalPanel(condition = "output.warnstat == 'Error'",
                       verbatimTextOutput("warnmsg")
                       ),
      
      #####################################
      # SUMMARY + HISTOGRAM
      #####################################
      h4(paste0('1. Distribution of the Chosen Variable')),
      
      verbatimTextOutput('summary'),
      
      plotOutput('plot'),
      
      #####################################
      # LR FIT
      #####################################
      
      h4(paste0('2. Univariate Logistic Regression Fit')),
      
      verbatimTextOutput('LRfit'),
      
      plotOutput('LRplot'),
    )
  )
)
)

