library(shiny)
library(mrgsolve)

code <- '$PARAM CL=1,V=4\n$CMT CENT\n$PKMODEL ncmt=1'
mod <- mcode("embed", code) %>% update(delta=0.1,end=72)

shiny::shinyServer(function(input, output) {
       output$Plot <- renderPlot({
         mod %>% 
           ev(amt=100,rate=100/input$dur,ii=24,addl=100) %>% 
           mrgsim %>% plot
     })
})


