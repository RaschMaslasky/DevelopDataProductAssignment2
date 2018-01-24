library(shiny)
library(leaflet)
library(dplyr)
library(sqldf)
library(plotly)
library(reshape)
library(rsconnect)

# create lookups
df <- read.csv(file = "./data/df.csv", header=T, sep=',', quote = '"', fileEncoding = "UTF-8")
crime.type              <- levels(df$Crime.type) 
month                   <- levels(df$Month)

# Define UI for application
shinyUI(fluidPage(
        
  # Application title
  # titlePanel("world is yours"),
  h4("London's Crime Monitoring"),
  h5("mirzarashid abbasov | developing data products course | coursera | 24.JAN.2018"),
  # Sidebar layout rendering 
  sidebarLayout(
    sidebarPanel(
        h4("Search parameters:"),
        selectInput("month", label="Period", choices = month, selected = 1),
        selectInput("crime.type", "Crime type", choices = crime.type, selected = 1),
        checkboxInput("cluster", "Cluster option"),
        checkboxInput("legend", "Popup option"),
        br(),
        h4("Forecast parameters:"),
        sliderInput("p", label = "Autoregressive,(p)", min = 0 , max = 5, value=1, step = 1),
        sliderInput("d", label = "Differencing, (d)", min = 0 , max = 5, value=0, step = 1),
        sliderInput("q", label = "Moving average, (q)", min = 0 , max = 5, value=0, step = 1),
        br(),br(),br(),br(),br(),br(),br()
    ),
        
    # Main panel rendering
    mainPanel(
        leafletOutput("mymap"),
        plotlyOutput("myplot")
        # plotlyOutput("myplot", width = "99%", height = 200)
    )
  ),
  br(),
  h4("Introduction"),
  h5("The following content represents London's crime statistics"),
  br(),
  h4("Synopsis"),
  h5("The goal of the project is:"),
  h5("1. create a Shiny application and deploy it on Rstudio's servers"),
  h5("2. prepare a reproducible pitch presentation about application via Slidify or Rstudio Presenter"),
  br(),
  h5("Mirzarashid Abbasov, almaty, 2018")
  
))
