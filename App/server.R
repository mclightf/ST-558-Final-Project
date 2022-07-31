# ST 558 Final Project
# Michael Lightfoot
# 08/01/22
# Exploring Video Games Sales Data set

#Install packages
library(shiny)
library(dplyr)
library(ggplot2)
library(readr)

#Reading in Data and Data Pre-processing
data <- read_csv("../vgsales.csv")
data <- na.omit(data)
data <- filter(data, Year != "N/A")
data$Year <- as.numeric(data$Year)

shinyServer(function(input, output, session) {
  
  #Data Exploration Page
  
  ###Modeling Page
  #Splitting
  #Before splitting, we need to make dummies out of the categorical variables. 
  #Variable Selection
  
  #Model Running
  
  #Predictions
  
  ###Data Page
  
  #Subset Data
  #Save Data
})