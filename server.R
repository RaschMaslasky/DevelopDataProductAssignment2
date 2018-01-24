library(shiny)
library(leaflet)
library(dplyr)
library(plotly)
library(sqldf)
library(forecast)
library(rsconnect)


df <- read.csv(file = "./data/df.csv", header=TRUE, sep=',', quote = '"', fileEncoding = "UTF-8")
df.origin <- read.csv(file = "./data/origin.csv", header=TRUE, sep=',', quote = '"', fileEncoding = "UTF-8")
df.wn.train <- read.csv(file = "./data/train.csv", header=TRUE, sep=',', quote = '"', fileEncoding = "UTF-8")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
        
        # add filters Month & Crime.type
        dfFiltered <- reactive({
        
                temp <- df %>%
                        filter(
                                Crime.type == input$crime.type,
                                Month == input$month
                        )
                temp <- as.data.frame(temp)
        })
        
        # forecasting model fitting
        FitData <- reactive({
                
                origin <- gsub(" ", ".", input$crime.type, fixed = TRUE)
                origin <- gsub("-", ".", origin, fixed = TRUE)
                
                month <- "Month"
                
                temp <- df.wn.train %>% select(c(month, origin))
                
                temp <- as.data.frame(temp)
                
                fit <- arima(temp[, origin],
                            order=c(input$p, input$d, input$q),
                            list(order=c(1, 0, 1), period=12), method = "CSS")
                
                fore <- predict(fit, n.ahead = 33)

                result <- data.frame(as.Date(temp[, month], format="%Y-%m-%d"),
                                   temp[, origin],
                                   as.integer(fore$pred))

                # colnames(result) <- c("Month", "Origin", "Prediction") 
                
                result <- as.data.frame(result)
        })
        
        output$mymap <- renderLeaflet({

                myMap <- leaflet() %>% addTiles()

                if (input$legend == FALSE)
                {
                        if (input$cluster == FALSE) {myMap <- myMap %>% addMarkers(dfFiltered()$Longitude, dfFiltered()$Latitude)}
                        else {myMap <- myMap %>% addMarkers(dfFiltered()$Longitude, dfFiltered()$Latitude,
                                                            clusterOptions = markerClusterOptions())}
                }
                else
                {
                        if (input$cluster == FALSE) {myMap <- myMap %>% addMarkers(dfFiltered()$Longitude, dfFiltered()$Latitude,
                                                                                   popup = dfFiltered()$Last.outcome.category,
                                                                                   label = dfFiltered()$Crime.ID)}
                        else {myMap <- myMap %>% addMarkers(dfFiltered()$Longitude, dfFiltered()$Latitude,
                                                            popup = dfFiltered()$Last.outcome.category,
                                                            label = dfFiltered()$Crime.ID,
                                                            clusterOptions = markerClusterOptions())}
                }
        })
        
        output$myplot <- renderPlotly({
                
                m <- list(
                        l = 50,
                        r = 50,
                        b = 50,
                        t = 50,
                        pad = 4
                )
                
                # origin <- gsub(" ", ".", input$crime.type, fixed = TRUE)
                # origin <- gsub("-", ".", origin, fixed = TRUE)
                
                p <- plot_ly(data = FitData(), x = ~ FitData()[, 1]) %>%
                        add_lines(y = ~ FitData()[ ,2],
                                  name = "Origin",
                                  type = "scatter",
                                  mode = "lines") %>%
                        add_lines(y = ~ FitData()[ ,3],
                                  name = "Forecast",
                                  type = "scatter",
                                  mode = "lines",
                                  line = list(color = 'rgb(205, 12, 24)', width = 3, dash = 'dot')) %>%
                        layout(title = paste("Forecast for '", input$crime.type , "'"),
                               autosize = T,
                               margin = m,
                               # width = 550, height = 250,
                               yaxis = list(title = "quantity"),
                               xaxis = list(title = "time")
                        )
                p

        })

})
