##
##
##
## libraries: readstata13"
##
## install.packages("readstata13")
## library(readstata13)
library(RStata)
## initfunction <- function() {
## 
##   }
## 
## 
## 
##  Malawi Endline into testDataset1
##  dat <- read.dta13("RAcE Malawi 60 Cluster Analysis - overall indicators.dta", nonint.factors = TRUE, generate.factors=T)
##  testDataset1 <- subset(dat, select = c("hhnumber", "hhclust", "q501", "q503", "q202", "cgeduccat", "q401", "q403", "dm_health", "d_nocare", "f_nocare", "fb_nocare", "d_nocarechw", "f_nocarechw", "fb_nocarechw", "chwtrusted", "chwquality", "chwconvenient", "cgdsknow2", "malaria_fev_sign"))
##  testDataset1 <- testDataset1[c("hhnumber", "survey", "site", "hhclust", "q501", "q503", "q202", "cgeduccat", "q401", "q403", "dm_health", "d_nocare", "f_nocare", "fb_nocare", "d_nocarechw", "f_nocarechw", "fb_nocarechw", "chwtrusted", "chwquality", "chwconvenient", "cgdsknow2", "malaria_fev_sign")]
##  testDataset1$survey <- "endline"
##  testDataset1$site <- "malawi"
##  testDataset1$q501 <- as.numeric(testDataset1$q501)
##  testDataset1$q503 <- as.numeric(testDataset1$q503)
##
##  Malawi Baseline into testDataset2
## dat <- read.dta13("baseline RAcE Malawi dataset post DO file_Final.dta", nonint.factors = TRUE, generate.factors=T)
## testDataset2 <- subset(dat, select = c("hhnumber", "hhclust", "q501", "q503", "q202", "cgeduccat", "q401", "q403", "dm_health", "d_nocare", "f_nocare", "fb_nocare", "d_nocarechw", "f_nocarechw", "fb_nocarechw", "chwtrusted", "chwquality", "chwconvenient", "cgdsknow2", "malaria_fev_sign"))
##  testDataset2$survey <- "baseline"
##  testDataset2$site <- "malawi"
## testDataset2 <- testDataset2[c("hhnumber", "survey", "site", "hhclust", "q501", "q503", "q202", "cgeduccat", "q401", "q403", "dm_health", "d_nocare", "f_nocare", "fb_nocare", "d_nocarechw", "f_nocarechw", "fb_nocarechw", "chwtrusted", "chwquality", "chwconvenient", "cgdsknow2", "malaria_fev_sign")]
##  testDataset2$q501 <- as.numeric(testDataset2$q501)
##  testDataset2$q503 <- as.numeric(testDataset2$q503)
##  
##  
##  
##
##
##
##
##  boxplot(q501 ~ f_nocare, data = testDataset1, col = "lightgray")
##
##
##
##
##
##
##
##

