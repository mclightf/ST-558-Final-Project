# ST 558 Final Project
# Michael Lightfoot
# 08/01/22
# Exploring Video Games Sales Data set

#Install packages
library(shiny)
library(tidyverse)
library(caret)

#Reading in Data and perform some Data Pre-processing
data <- read_csv("../vgsales.csv")
data <- na.omit(data)
data <- filter(data, Year != "N/A")
data$Year <- as.numeric(data$Year)

#Select predictor variables and filter out categorical levels with <100 observations
model_data <- data %>%
  select(Platform, Year, Genre, Publisher, Global_Sales) %>%
  group_by(Publisher) %>%
  filter(n()>=100) %>%
  ungroup() %>% 
  group_by(Platform) %>%
  filter(n()>=100) %>%
  ungroup()

shinyServer(function(input, output, session) {
  
  ###Data Exploration Page
  #Record Changed Inputs for plot
  get_data <- reactive({
    if (input$eda_color == "Genre"){
      if ("All" %in% input$eda_genre) {
        new_data <- model_data
      } else if (length(input$eda_genre) != 0){
        new_data <- model_data %>% filter(Genre == input$eda_genre)
      } else {
        stop('Select at least one Genre Checkbox Please!')
      }
    } else if (input$eda_color == "Platform"){
      if ("All" %in% input$eda_platform) {
        new_data <- model_data
      } else if (length(input$eda_platform) != 0){
        new_data <- model_data %>% filter(Platform == input$eda_platform)
      } else {
        stop('Select at least one Platform Checkbox Please!')
      }
    }

  })
  
  #Make plot
  output$eda_plot <- renderPlot({
    #Get possibly filtered data
    new_data <- get_data()
    
    #Make plot based on plot selections and color selections
    if (input$eda_plot == "Bar") {
      if (input$eda_color == "Genre") {
        g <- ggplot(new_data, aes(x = Publisher, fill = Genre)) + 
          geom_bar() +
          theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
          labs(title = "Count of Observations by Publisher", y = "Count") 
      } else if (input$eda_color == "Platform") {
        g <- ggplot(new_data, aes(x = Publisher, fill = Platform)) + 
          geom_bar() +
          theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
          labs(title = "Count of Observations by Publisher", y = "Count") +
          guides(fill=guide_legend(nrow = 10))
      }
    } else if (input$eda_plot == "Line") {
      if (input$eda_color == "Genre") {
        g <- ggplot(new_data, aes(x = Year,y = Global_Sales, color = Genre)) + 
          geom_line(stat = "summary", fun = "mean") +
          labs(title = "Average Global Sales per Year", x ="Global Sales (in millions)", y = "Count") 
      } else if (input$eda_color == "Platform") {
        g <- ggplot(new_data, aes(x = Year,y = Global_Sales, color = Platform)) + 
          geom_line(stat = "summary", fun = "mean") +
          labs(title = "Average Global Sales per Year", x ="Global Sales (in millions)", y = "Count") 
      }
    } else if (input$eda_plot == "Histogram") {
      if (input$eda_color == "Genre") {
        g <- ggplot(new_data, aes(x = Year, fill = Genre)) +
          geom_histogram(alpha = 0.5, aes(y = ..density..), binwidth = 2) + 
          geom_density(alpha = 0.5, position = "stack") + 
          labs(title = "Distribution of Observations by Year", y = "Density")
      } else if (input$eda_color == "Platform") {
        g <- ggplot(new_data, aes(x = Year, fill = Platform)) +
          geom_histogram(alpha = 0.5, aes(y = ..density..), binwidth = 2) + 
          geom_density(alpha = 0.5, position = "stack") + 
          labs(title = "Distribution of Observations by Year", y = "Density")
      }
    }
    return(g)
  })
  
  #Make numerical summaries
  output$eda_table <- renderDataTable({
    #Get possibly filtered data
    new_data <- get_data()
    
    #Change based on grouping variable
    if (input$eda_var == "Year") {
      table <- new_data %>%
        group_by(Year)
    } else if (input$eda_var == "Platform") {
      table <- new_data %>%
        group_by(Platform)
    } else if (input$eda_var == "Genre") {
      table <- new_data %>%
        group_by(Genre)
    } else if (input$eda_var == "Publisher") {
      table <- new_data %>%
        group_by(Publisher)
    } 
    #Get summary statistics
    table <- table %>%
      dplyr::summarize(Count = n(), 
                       Sum = sum(Global_Sales), 
                       Average = mean(Global_Sales), 
                       StdDev = sd(Global_Sales))
    #Round Average and StdDev
    table$Average <- round(table$Average, 2)
    table$StdDev <- round(table$StdDev, 2)
    #Drop statistics based on checkbox input
    if ("All" %in% input$eda_sum) {
      return(table)
    } else {
      if (!("Count" %in% input$eda_sum)){
          table <- table %>% 
          select(-Count)
      } 
      if (!("Sum" %in% input$eda_sum)) {
        table <- table %>% 
        select(-Sum)
      }
      if (!("Average" %in% input$eda_sum)) {
        table <- table %>% 
        select(-Average)
      } 
      if (!("Standard Deviation" %in% input$eda_sum)) {
      table <- table %>% 
        select(-StdDev)
      }
    }
    return(table)
  })
  ###Modeling Page
  #Splitting
  observeEvent(input$model_run, {
    
    #Set Progress Message
    withProgress(message = 'Modeling Data', value = 0, {
    
    #Get Train/Test Split
    split <- input$model_prop/100
    
    #Potentially subset model data set based on desired variables
    modeling_data <- model_data
    if ("All" %in% input$model_var) {
      modeling_data <- modeling_data
    } else if (!("Platform" %in% input$model_var)) {
      modeling_data <- model_data %>% select(-Platform)
    } else if (!("Year" %in% input$model_var)) {
      modeling_data <- model_data %>% select(-Year)
    } else if (!("Genre" %in% input$model_var)) {
      modeling_data <- model_data %>% select(-Genre)
    } else if (!("Publisher" %in% input$model_var)) {
      modeling_data <- model_data %>% select(-Publisher)
    } else if (!input$model_var){
      stop('Select at least one Predictive Variable Please!')
    }
    #Perform Train/Test split
    train <- sample(1:nrow(modeling_data), size = nrow(modeling_data)*0.8)
    test <- setdiff(1:nrow(modeling_data),train)
    train_data <- modeling_data[train,]
    test_data  <- modeling_data[test,]
    
    #Since data was subset already, we can just use Global_Sales ~ . for all models
    #Set train control
    train_control <- trainControl(method = "repeatedcv", number=5, repeats=3)
    
    #Increment progress
    incProgress(1/4, detail = "Performing General Linear Model")
    
    #General linear model
    glm_fit <- train(Global_Sales ~ ., 
                 data = train_data,
                 method = "glm", 
                 preProcess = c("center", "scale"),
                 trControl = train_control)
    #Make Predictions and find RMSE for both train and test data
    glm_test_pred <- predict(glm_fit, newdata = dplyr::select(test_data, -Global_Sales))
    glm_test_rmse <- sqrt(mean((glm_test_pred-test_data$Global_Sales)^2))
    glm_train_pred <- predict(glm_fit, newdata = dplyr::select(train_data, -Global_Sales))
    glm_train_rmse <- sqrt(mean((glm_train_pred-train_data$Global_Sales)^2))
    
    #Increment progress
    incProgress(1/4, detail = "Performing Regression Tree Model")
    
    #Regression tree model with tunegrid
    rpart_fit <- train(Global_Sales ~ ., 
                     data = train_data,
                     method = "rpart", 
                     preProcess = c("center", "scale"),
                     trControl = train_control,
                     tuneGrid = expand.grid(cp=c(0:100)/1000))
    #Make Predictions and find RMSE on training and testing data
    rpart_test_pred <- predict(rpart_fit, newdata = dplyr::select(test_data, -Global_Sales))
    rpart_test_rmse <- sqrt(mean((rpart_test_pred-test_data$Global_Sales)^2))
    rpart_test_pred <- predict(rpart_fit, newdata = dplyr::select(test_data, -Global_Sales))
    rpart_test_rmse <- sqrt(mean((rpart_test_pred-test_data$Global_Sales)^2))
    
    #Increment progress
    incProgress(1/4, detail = "Performing Random Forest Model")
    
    #Random forest model with different trControl and tunegrid
    #No repeats for efficiency
    train_control <- trainControl(method = "repeatedcv", number=5, repeats=1)
    rf_fit <- train(Global_Sales ~ ., 
                       data = train_data,
                       method = "rf", 
                       preProcess = c("center", "scale"),
                       trControl = train_control,
                       tuneGrid = expand.grid(mtry=c(1:15)))
    #Make Predictions and find RMSE
    rf_test_pred <- predict(rf_fit, newdata = dplyr::select(test_data, -Global_Sales))
    rf_test_rmse <- sqrt(mean((rf_test_pred-test_data$Global_Sales)^2))
    
    #Increment progress
    incProgress(1/4, detail = "Creating Outputs")
    
    #Create output Data Frame
    output$model_test_rmse <- renderTable({
      #Create Data Frame of results
      rmse_test <- c(glm_test_rmse,rpart_test_rmse, rf_testrmse)
      return(rmse_df)
    })
    
    #Create VarImpPlots
    })
  })

  #Predictions
  
  ###Data Page
  data_page <- reactive({
    #Perform reactive filtering here, starting from raw data
    if ('All' %in% input$data_col){
      data <- data
    } 
  })
  
  #Output data table
  output$data_page_table <- renderDataTable({
    data_page_df <- data_page()
    return(data_page_df)
  })
  #Save data table
  observeEvent(input$data_save, {
    data_page_df <- data_page()
    write.csv(data_page_df,"../new_vgsales.csv")
  })
})

