library(shiny)
library(DT)
library(dplyr)
library(ggplot2)
library(GGally)

# INCREASE DEFAULT FILE SIZE
options(shiny.maxRequestSize=30*1024^2) 



server <- function(input, output, session){
  myData <- reactive({
    # inFile <- input$file1
    # if (is.null(inFile)) return(NULL)
    # data <- read.csv(inFile$datapath, header = TRUE)
    data <- read.table(file = "https://raw.githubusercontent.com/kentranz/codeSamp/main/Data_v1.1.csv"
                         , header = TRUE, sep = ",", quote = "'", dec = ".", fill = TRUE)
  })
  
  
  
  
  # output$contents <- DT::renderDataTable({
  #   DT::datatable(myData())       
  # })
  
  
  ##############################################
  # DISTRIBUTION SUMMARY
  ##############################################
  
  output$summary <- renderPrint({
    
    df <- myData() %>% select(input$variable)
    summary(df)
  })
  
  output$select <- renderUI({
    df <- myData() %>% select(-c(subject_id, hadm_id, icustay_id, age, ethnicity, thirty_day_mort))
    selectInput("variable", "Choose a variable to explore its association with 30-day ICU mortality:", names(df))
    
    
  })
  
  ##############################################
  # BUG TEST
  ##############################################
  
  # output$logicTest <- renderPrint({
  # #   df <- myData()
  # #   
  # #    df %>% select(input$variable, thirty_day_mort) %>% 
  # #      group_by_at(c(1,2)) %>%
  # #      summarize(n = n()) %>% 
  # #      ungroup() %>% 
  # #      as.data.frame()
  # #   
  # #   
  # 
  #   df <- myData() %>% select(thirty_day_mort, input$variable)
  #   model <- glm(thirty_day_mort ~ ., data = df, family = binomial())
  #   
  #   oddRatios <- cbind(round(exp(coef(model)), 2)
  #                      , round(exp(confint(model)), 2)
  #                      , round(summary(model)$coeff[,4], 2)
  #   ) %>%
  #     as.data.frame() %>%
  #     tibble::rownames_to_column()
  #   
  #   oddRatios <- oddRatios[-1,]
  #   colnames(oddRatios)[1:5] <- c('term', 'estimate', 'conf.low', 'conf.high', 'p')
  #   print(summary(model))
  #   print(oddRatios)
  # 
  # })
  
  
  ##############################################
  # DYNAMIC HISTOGRAMS
  ##############################################
  
  output$plot <- renderPlot({
    df <- myData() %>% 
      mutate(xVar = input$variable) 
    
    xVar <- df %>% select(input$variable) %>% pull()
    if (is.factor(xVar) == F)
    {
      ggplot(df, aes_string(x = input$variable)) + 
        geom_histogram(aes(fill = as.factor(thirty_day_mort)), binwidth = 1, position = 'stack') +
        #theme_bw() +
        guides(fill = guide_legend(title = '30-day Mortality')) +
        scale_fill_manual(values = c('#00BFC4', '#F8766D'), labels = c('N', 'Y')) +
        theme(text=element_text(size=14))
    }

    else if(is.factor(xVar) == T)
    {
      
      plotDF <- df %>% select(input$variable, thirty_day_mort) %>% 
        group_by_at(c(1,2)) %>%
        summarize(n = n()) %>% 
        ungroup() %>% 
        as.data.frame()
      
      

      ggplot(plotDF, aes_string(x = names(plotDF)[1] )) +
        geom_bar(aes(y = n, fill = as.factor(thirty_day_mort))
          , stat = 'identity') +
        guides(fill = guide_legend(title = '30-day Mortality')) +
        scale_fill_manual(values = c('#00BFC4', '#F8766D'), labels = c('N', 'Y')) +
        theme(text=element_text(size=14)) +
        labs(y = 'count')
        #theme(axis.title.y = element_text(angle = 0))
      
      
      # ggplot(df, aes_string(x = input$variable)) + 
      #   geom_histogram( stat = 'count', position = 'stack') +
      #   theme(text=element_text(size=14))
    }
    
  }, height = 'auto', width = 'auto'
  )
  
  
  ##############################################
  # Fit Logistic Regression
  ##############################################
  
  output$LRfit <- renderPrint({
    df <- myData() %>% 
      select(thirty_day_mort, input$variable) 
    # xVar <- df %>% select(input$variables) %>% pull()
    model <- glm(thirty_day_mort ~ ., data = df, family = binomial())
    
    summary(model)
  })
  
  
  ##############################################
  # PLOT OR
  ##############################################
  output$LRplot <- renderPlot({
    
    df <- myData() %>% 
      select(thirty_day_mort, input$variable) 
    
    model <- glm(thirty_day_mort ~ ., data = df, family = binomial())

    oddRatios <- cbind(round(exp(coef(model)), 2)
                       , round(exp(confint(model)), 2)
                       , round(summary(model)$coeff[,4], 2)
                       ) %>%
      as.data.frame() %>%
      tibble::rownames_to_column()
    
    oddRatios <- oddRatios[-1,]
    colnames(oddRatios)[1:5] <- c('term', 'estimate', 'conf.low', 'conf.high', 'p')
    
    ggcoef(
      oddRatios
      , aes(x = estimate, y = term)
      , exponentiate = T
      , exclude_intercept = T
      , sort = 'none'
      , size = 4) +
      theme_classic() +
      theme(axis.text = element_text(size = 14)
            , axis.title.x = element_text(size = 14)
      ) +
      xlab('Odd Ratios [95% CI] with Outcome of 30-day ICU Mortality') +
      ylab('')	

  })
  
}