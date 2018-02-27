

ORparams <- function(dataSrc, xVar) {
  
  #n00 <- nrow(filter(dataSrc,  dataSrc$xVar== "No" & dataSrc$f_nocare == "No" | dataSrc$xVar== "No" & dataSrc$d_nocare== "No" | dataSrc$xVar== "No" & dataSrc$fb_nocare== "No"))
  #n01 <- nrow(filter(dataSrc,  dataSrc$xVar== "No" & dataSrc$f_nocare == "Yes" | dataSrc$xVar== "No" & dataSrc$d_nocare== "Yes" | dataSrc$xVar== "No" & dataSrc$fb_nocare== "Yes"))
  #n10 <- nrow(filter(dataSrc,  dataSrc$xVar== "Yes" & dataSrc$f_nocare == "No" | dataSrc$xVar== "Yes" & dataSrc$d_nocare== "No" | dataSrc$xVar== "Yes" & dataSrc$fb_nocare== "No"))
  #n11 <- nrow(filter(dataSrc,  dataSrc$xVar== "Yes" & dataSrc$f_nocare == "Yes" | dataSrc$xVar== "Yes" & dataSrc$d_nocare== "Yes" | dataSrc$xVar== "Yes" & dataSrc$fb_nocare== "Yes"))
  
  n00 <- nrow(filter(dataSrc,  xVar== "No" & f_nocare == "No" | xVar== "No" & d_nocare== "No" | xVar== "No" & fb_nocare== "No"))
  n01 <- nrow(filter(dataSrc,  xVar== "No" & f_nocare == "Yes" | xVar== "No" & d_nocare== "Yes" | xVar== "No" & fb_nocare== "Yes"))
  n10 <- nrow(filter(dataSrc,  xVar== "Yes" & f_nocare == "No" | xVar== "Yes" & d_nocare== "No" | xVar== "Yes" & fb_nocare== "No"))
  n11 <- nrow(filter(dataSrc,  xVar== "Yes" & f_nocare == "Yes" | xVar== "Yes" & d_nocare== "Yes" | xVar== "Yes" & fb_nocare== "Yes"))
  
  ## oddsratioWald(n00, n01, n10, n11)
  c(n00, n01, n10, n11)
  x <- oddsratioWald(n00, n01, n10, n11)
  
  #df <- rbind.data.frame(df,x)
  plotOddsRatio(df)
}




oddsratioWald <- function(n00, n01, n10, n11, alpha = 0.05){
  #
  #  Compute the odds ratio between two binary variables, x and y,
  #  as defined by the four numbers nij:
  #
  #    n00 = number of cases where x = 0 and y = 0
  #    n01 = number of cases where x = 0 and y = 1
  #    n10 = number of cases where x = 1 and y = 0
  #    n11 = number of cases where x = 1 and y = 1
  #
  OR <- (n00 * n11)/(n01 * n10)
  #
  #  Compute the Wald confidence intervals:
  #
  siglog <- sqrt((1/n00) + (1/n01) + (1/n10) + (1/n11))
  zalph <- qnorm(1 - alpha/2)
  logOR <- log(OR)
  loglo <- logOR - zalph * siglog
  loghi <- logOR + zalph * siglog
  #
  ORlo <- exp(loglo)
  ORhi <- exp(loghi)
  #
  oframe <- data.frame(LowerCI = ORlo, OR = OR, UpperCI = ORhi, alpha = alpha)
  oframe
  
  
}


plotOddsRatio <- function(df){
  ggplot(df, aes(x = df$boxOdds, y= "Odds", xmin= 0, xmax= 2)) + 
    geom_point(size = 3.5, color = "orange", shape=19) + 
    ggtitle("Odds Ratio") + geom_vline(aes(xintercept = 1), size = .25, linetype = "dashed") + 
    theme(panel.grid.minor = element_blank()) + 
    geom_errorbarh(aes(xmax = df$boxCIHigh, xmin = df$boxCILow), size = .5, height = .2, color = "gray50") + 
    ylab("Factor") + 
    xlab("Odds ratio") + 
    theme_bw()
  
  
}
