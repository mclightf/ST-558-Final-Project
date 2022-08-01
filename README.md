# ST-558-Final-Project

This is a repository for an app that explores a data set about video game sales, which can be found [here](https://www.kaggle.com/datasets/gregorut/videogamesales).

The app has four pages:

- **About** - This page is an explanation of the data and this app (*You are here!*)
- **Data Exploration** - Here there is some exploratory data analysis to allow the user to find patterns in the data.
- **Modeling** - This page has the fitting of three supervised learning models. You will be able to learn about the different models used, observe their performance, and test some predictions yourself!
- **Data** - Here you can look through the data set yourself, subset the data however you would like, and save the resulting file as a .csv!

The packages needed to run the app are as follows:

- `tidyverse`, which notably includes `ggplot2`, `dplyr`, `tidyr`, and `readr`, along with some others. 
- `caret`
- `shiny`

The code to install those packages can be found below. 

``` r
install.packages(c("tidyverse", "caret", "shiny"))
```

To run this app using the `runGitHub()` function from `shiny`, use the following code.

``` r
shiny::runGitHub()
```
