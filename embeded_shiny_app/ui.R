shinyUI(fluidPage(
       sliderInput("dur","Duration",1,20,1),
       plotOutput("Plot")
     ))