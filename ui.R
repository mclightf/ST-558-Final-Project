# ST 558 Final Project
# Michael Lightfoot
# 08/01/22
# Exploring Video Games Sales Data set

#Install packages
library(shiny)
library(dplyr)
library(ggplot2)
library(readr)
library(mathjaxr)
library(caret)
library(DT)

#Reading in Data and Data Pre-processing
data <- read_csv("vgsales.csv")
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

#Create UI
shinyUI(
  #Create tabs via nav bar
  navbarPage("Video Games!",
             tabPanel("About",
                      includeMarkdown("about.md")
                      ),
             tabPanel("Data Exploration",
                      sidebarLayout(
                        sidebarPanel(
                          selectInput("eda_plot", "Plot Type:", 
                                      selected = "Bar", choices = c("Bar", "Line", "Histogram")),
                          br(),
                          selectInput("eda_color", "Variable to Color and Filter Data:", 
                                      selected = "Genre", choices = c("Genre", "Platform")),
                          br(),
                          conditionalPanel(condition = "input.eda_color == 'Genre'",
                            checkboxGroupInput("eda_genre", "Genre to Filter By:", 
                                               selected = "All", 
                                               choices = c("All", levels(as.factor(model_data$Genre)))
                                               
                            )
                          ),
                          br(),
                          conditionalPanel(condition = "input.eda_color == 'Platform'",
                            checkboxGroupInput("eda_platform", "Platform to Filter By:", 
                                                selected = "All", 
                                                choices = c("All", levels(as.factor(model_data$Platform)))
                                                               
                            )
                          ),
                          br(),
                          selectInput("eda_var", "Grouping Variable for Numerical Summaries:",
                                      selected = "Year", choices = c("Year", "Platform", "Genre", "Publisher")),
                          br(),
                          checkboxGroupInput("eda_sum", "Numerical Summaries to Include:",
                                        selected = "All", choices = c("All","Count","Sum", "Average", "Standard Deviation"))
                        ),
                        #Show outputs
                        mainPanel(
                          plotOutput("eda_plot"),
                          #textOutput("info"),
                          dataTableOutput("eda_table")
                        )
                      )
                      ),
             tabPanel("Modeling",
                      tabsetPanel( type = "tabs",
                                   tabPanel("Modeling Info",
                                            h1("Modeling"),
                                            br(),
                                            "This page allows you to customize three different supervised learning methods. Here is a brief description of each.",
                                            br(),
                                            br(),
                                            strong("General Linear Model"),
                                            br(),
                                            br(),
                                            "A general linear regression model buils on the idea of a traditional multiple linear regression model of numerical predictors, but also allows for categorical predictors. This is especially useful in our case, considering a majority of our predictive variables are categorical! Some pros of this model are that it is generally fast, easy to interpet in most cases, and can be customized with interaction or higher order terms. Some cons of this model is that it makes some assumptions about the data, such as constant variance and normal distribution of errors.",
                                            br(),
                                            br(),
                                            #Add Math Jax capabilities
                                            withMathJax(),
                                            helpText('For some background, the basic linear regression model is as follows: $$Y_{i} = \\beta_{0} + \\beta_{1}x_{i} + E_{i},$$ where \\(\\beta_{0}\\) is the y-intercept, \\(x_{i}\\) is the value of the predictive variable for the \\(i^{th}\\) observation, \\(\\beta_{1}\\) is the slope, and \\(E_{i}\\) is the error. Ideally, the goal is to minimize the sum of squared residuals, i.e. minimize $$min_{\\beta_0,\\beta_1} \\sum_{i=1}^n (E_i)^2$$'
                                            ),
                                            br(),
                                            br(),
                                            strong("Regression Tree"),
                                            br(),
                                            br(),
                                            "A regression tree model is a non-linear method. The idea behind tree-based models is to break up the predictor space into different regions, and then to have a different prediction for each region. In the case of a regression tree, the prediction for a specific region is usually the mean of the observations from the training set in that region. Some pros of this method are that they are simple to understand and they naturally have built-in variable selection. Some cons of this method are that regression trees generally have high variance, meaning small changes in the data can drastically change the tree, and also the trees can be prone to overfitting and usually require pruning (a process that removes some nodes to prevent overfitting).",
                                            br(),
                                            br(),
                                            helpText('For a given leaf node \\(l\\), our prediction \\(\\hat{y}\\) is given by $$ \\hat{y} = \\frac{1}{n} \\sum_{i=1}^n y_i, $$ i.e. the sample mean of the dependent variable within that node.'),
                                            br(),
                                            br(),
                                            strong("Random Forest"),
                                            br(),
                                            br(),
                                            "A random forest model for regression builds on the idea of a regression tree, but incorporates bagging and random subsetting of the predictors. Bagging is the idea of creating many data sets of equivalent size to the training set with 2/3 of the same data with the rest being repetitive data, and then running an individual regression tree on that model. Then, for a regression model, the results are averaged across all trees. Random forest models specifically also take a random subset of the predictors in each individual tree. This generally aids prediction as it makes the individual tree predictions less correlated with each other. The pros of this method is that it usually performs better in prediction than a simple regression tree or bagging model, but on the other hand you do lose some interpretability and it takes much longer.",
                                            br(),
                                            br(),
                                            helpText('Predictions for a test observation \\(x\\) can be found by averaging our predictions from the \\(N\\) individual regression trees \\(y_{b}(x)\\): $$ \\hat{y} = \\frac{1}{N} \\sum_{b=1}^N y_{b}(x) $$'),
                                            br(),
                                            br(),
                                            "In the model fitting tab, you will be able to customize the train/test split and choose which of the predictive variables, if not all, you would like to use in your models! Then you will be able to run the models. Since we are likely using categorical predictors with many levels, and thus have very many dummy variables, we have chosen not to use the `summary()` function for the `glm` model, as its output is very large. Instead, we include variable importance plots for all models as well was a thorough table of fit statistics. Each model utilizes 5-fold cross validation during training."
                                            ),
                                   tabPanel("Model Fitting",
                                            sidebarLayout(
                                              sidebarPanel(
                                                #Choose proportion of train/test
                                                sliderInput("model_prop", "Percentage used for Traning",
                                                            min = 0, max = 100,
                                                            value = 80, step = 1),
                                                #Choose variables included
                                                checkboxGroupInput("model_var", "Variables to include:",
                                                                   selected = "All",
                                                                   choices = c("All", names(model_data %>% select(-Global_Sales)))),
                                                #Press button to run
                                                actionButton("model_run", "Run Models!")
                                              ),
                                              mainPanel(
                                                tableOutput("model_test_rmse"),
                                                plotOutput("var_imp_glm"),
                                                plotOutput("var_imp_rpart"),
                                                plotOutput("var_imp_rf")
                                              )
                                            )
                                            ),
                                   tabPanel("Prediction",
                                            sidebarLayout(
                                              sidebarPanel(
                                                #Select Values for predictors
                                                #Conditionally based on which are selected in the Model tab
                                                #If platform was used
                                                conditionalPanel(condition = "input.model_var.includes('Platform')",
                                                                 selectizeInput("model_platform", "Platform:",
                                                                                choices = levels(as.factor(model_data$Platform))),
                                                ),
                                                #If year was used
                                                conditionalPanel(condition = "input.model_var.includes('Year')",
                                                                 sliderInput("model_year", "Year:",
                                                                             min = min(data$Year), max = max(model_data$Year), 
                                                                             value = max(model_data$Year), step = 1, sep = "")
                                                ),
                                                #If genre was used
                                                conditionalPanel(condition = "input.model_var.includes('Genre')",
                                                                 selectizeInput("model_genre", "Genre:",
                                                                                choices = levels(as.factor(model_data$Genre)))
                                                ),
                                                #If publisher was used
                                                conditionalPanel(condition = "input.model_var.includes('Publisher')",
                                                                 selectizeInput("model_publish", "Publisher:",
                                                                                choices = levels(as.factor(model_data$Publisher)))
                                                ),
                                                #If all were used (all above panels together)
                                                conditionalPanel(condition = "input.model_var == 'All'",
                                                  selectizeInput("model_platform", "Platform:",
                                                                 choices = levels(as.factor(model_data$Platform))),
                                                  br(),
                                                  sliderInput("model_year", "Year:",
                                                              min = min(model_data$Year), max = max(model_data$Year), 
                                                              value = max(model_data$Year), step = 1, sep = ""),
                                                  br(),
                                                  selectizeInput("model_genre", "Genre:",
                                                                 choices = levels(as.factor(model_data$Genre))),
                                                  br(),
                                                  selectizeInput("model_publish", "Publisher:",
                                                                 choices = levels(as.factor(model_data$Publisher)))
                                                ),
                                                
                                                #Press button to predict
                                                actionButton("model_predict", "Get Predictions!")
                                              ),
                                              mainPanel(
                                                #Output predictions (perhaps plot)
                                                tableOutput("model_prediction")
                                              )
                                            )
                                   )
                      )
                      ),
             tabPanel("Data",
                      sidebarLayout(
                        sidebarPanel(
                          #Subset Columns
                          checkboxGroupInput("data_col", "Columns to include:", selected = "All",
                                             choices = c("All", names(data))),
                          br(),
                          #Subset Rows
                          sliderInput("data_num", "Number of Rows to Randomly Sample:",
                                      min = 1, max = nrow(data), 
                                      value = nrow(data), step = 1),
                          br(),
                          #Save file
                          actionButton("data_save", "Save Data as csv!")
                        ),
                        mainPanel(
                          #Output Data Table
                          dataTableOutput("data_page_table")
                        )
                      )
                      ),
             #Make nav bar page fluid
             fluid = TRUE
             )
)
