library(shiny)
library(ggplot2)
attach(faithful)


shinyServer(
  function(input,output){
    w0 = reactive({as.numeric(input$wait0)})
    l0 = reactive({as.numeric(input$len0m + input$len0s/60)})
    
    fit = reactive({arima(c(waiting, w0()), 
                          order = c(1,0,0), 
                          xreg = c(eruptions, l0())
                          )})
    
    wpred = reactive({predict(fit(), n.ahead = 1, newxreg = l0()
                              )})
    
    conf = reactive({c((100 - input$conf)/200, 1 - (100 - input$conf)/200)})
    
    ci = reactive({c(round(qnorm(conf()[1], wpred()$pred[1], wpred()$se[1])), 
                     round(qnorm(conf()[2], wpred()$pred[1], wpred()$se[1])))})
    
    output$repeatinput = renderText({
      paste('The last eruption occurred', input$wait0, 'minutes after the previous one, and it was', 
            input$len0m, 'minutes and', input$len0s, 'seconds long.')
    })
    
    output$pred = renderText({      
      paste('The next eruption will occur in approximately', round(wpred()$pred[1]), 'minutes, or in the next',
            ci()[1], 'to', ci()[2], 'minutes with', input$conf, '% confidence.')
    }
    )
    
    output$distrib = renderPlot({(ggplot(data.frame(x=c(50, 100)), aes(x)) 
                                 + stat_function(fun=function(x) dnorm(x,wpred()$pred[1],wpred()$se[1]),
                                                 color = '#669900')
                                 + geom_vline(xintercept = wpred()$pred[1], 
                                              colour = '#CCCC00',
                                              alpha = .66, 
                                              size = 1.5)
                                 + geom_vline(xintercept = qnorm(conf()[1], wpred()$pred[1], wpred()$se[1]),
                                              colour = '#CCCC00',
                                              alpha = 1,
                                              linetype = 'dashed')
                                 + geom_vline(xintercept = qnorm(conf()[2], wpred()$pred[1], wpred()$se[1]),
                                              colour = '#CCCC00',
                                              alpha = 1,
                                              linetype = 'dashed')
                                 + geom_text(label = paste('mean = ', round(wpred()$pred[1],2), 'min.'), 
                                             x = wpred()$pred[1]+2, 
                                             y = .03,
                                             hjust = 0,
                                             angle = 90,
                                             colour = '#ACAEAC')
                                 + geom_text(label = paste(conf()[1]*100, 'th percentile = ', round(ci()[1],2), 'min.'), 
                                             x = ci()[1]+2, 
                                             y = .03,
                                             hjust = 0,
                                             angle = 90,
                                             colour = '#ACAEAC')
                                 + geom_text(label = paste(conf()[2]*100, 'th percentile = ', round(ci()[2],2), 'min.'), 
                                             x = ci()[2]+2, 
                                             y = .03,
                                             hjust = 0,
                                             angle = 90,
                                             colour = '#ACAEAC')
                                 + ggtitle('Estimated waiting time density.')
                                 + theme(axis.text.x = element_text(colour="grey20",size=14,hjust=.5,vjust=.5,face="plain"),
                                         axis.text.y = element_blank(),
                                         axis.title.y = element_blank(),
                                         panel.background = element_rect(fill = '#2F332F', colour = '#2F332F'),
                                         panel.grid.minor = element_line(colour = '#595C59'),
                                         panel.grid.major = element_line(colour = '#595C59'))
                                 + xlab('Waiting time (minutes)')
    )
      #curve(dnorm(x, wpred()$pred[1], wpred()$se[1]), 50, 100)
      })
  }
)