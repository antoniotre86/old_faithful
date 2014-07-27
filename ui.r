library(shiny)




shinyUI(pageWithSidebar(
  headerPanel('The Old Faithful waiting time prediction.'),
  
  sidebarPanel(
    h5('This app predicts the waiting time to the next eruption of the Old Faithful geyser in Yellowstone 
      National Park, Wyoming, USA.'),
    h5('Just insert the data from the last eruption in the boxes below.'),
    p('\n'),
    numericInput('wait0', 'Waiting time to the last eruption (minutes)', value = 0, min = 0, max = 100),
    p(''),
    p('Last eruption length'),
    numericInput('len0m', 'minutes', value = 0, min = 0, max = 10, step = 1),
    numericInput('len0s', 'seconds', value = 0, min = 0, max = 60, step = 1),
    p(''),
    sliderInput('conf', 'Confidence', value = 95, min = 90, max = 99, step = 1)
  ),
  
  mainPanel(
    h5(textOutput('repeatinput')),
    h5(textOutput('pred')), 
    plotOutput('distrib')
    )
)
)