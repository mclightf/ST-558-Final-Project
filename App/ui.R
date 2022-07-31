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

#Create UI
shinyUI(
  #Create tabs via nav bar
  navbarPage("Video Games!",
             tabPanel("About",
                      includeMarkdown("../about.md")
                      ),
             tabPanel("Data Exploration",
                      sidebarLayout(
                        sidebarPanel(
                          selectInput("plottype", "Plot Type:", 
                                      selected = "Bar", choices = c("Bar", "Line", "Histogram")),
                          br(),
                          selectizeInput("var", "Genre to Filter By:", 
                                         selected = "All", choices = c("All", levels(as.factor(data$Genre)))
                          
                          ),
                          br(),
                          checkboxGroupInput("num", "Numerical Summaries to Include:",
                                        choices = c("Count","Sum", "Average", "Standard Deviation"))
                        ),
                        
                        
                        
                        #Show outputs
                        mainPanel(
                          plotOutput("sleepPlot"),
                          textOutput("info"),
                          tableOutput("table")
                        )
                      )
                      ),
             tabPanel("Modeling",
                      
                      ),
             tabPanel("Data"
                      
                      ),
             #Make nav bar page fluid
             fluid = TRUE
             )
)