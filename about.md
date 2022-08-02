# Video Game Sales

This app's purpose is to allow the user to explore a data set regarding video game sales. 

#### Source

This data set comes from kaggle, and can be found [here](https://www.kaggle.com/datasets/gregorut/videogamesales). It contains data regarding video games with sales greater than 100,000 copies. The different variables are as follows:

- `Rank` - Ranking of overall sales 
- `Name` - The game's name
- `Platform` - Platform of the games release (i.e. PC,PS4, etc.)
- `Year` - Year of the game's release
- `Genre` - Genre of the game
- `Publisher` - Publisher of the game
- `NA_Sales` - Sales in North America (in millions)
- `EU_Sales` - Sales in Europe (in millions)
- `JP_Sales` - Sales in Japan (in millions)
- `Other_Sales` - Sales in the rest of the world (in millions)
- `Global_Sales` - Total worldwide sales.

We will use `Global_Sales` as the response variable in our analysis. Since many of these variables are clearly either non-predictive or related, we will only use the following variables in our analysis: `Platform`, `Year`, `Genre`, and `Publisher`, along with our response variables. We also perform some data pre-processing to remove categorical levels in `Platform` and `Publisher` with fewer than 100 occurrences to help our algorithms with centering and scaling the data appropriately, with the added benefit of de-cluttering some of the UI options a bit. You can still look through the raw data set on the **Data** tab!


#### This App

This app has four pages:

- **About** - This page is an explanation of the data and this app (*You are here!*)
- **Data Exploration** - Here there is some exploratory data analysis to allow the user to find patterns in the data.
- **Modeling** - This page has the fitting of three supervised learning models. You will be able to learn about the different models used, observe their performance, and test some predictions yourself!
- **Data** - Here you can look through the data set yourself. You can subset the columns however you would like and take a random sample of a desired number of observations! Then, you can save the resulting data set as a .csv!

![Video Game Image](dataset-cover.jpeg)
