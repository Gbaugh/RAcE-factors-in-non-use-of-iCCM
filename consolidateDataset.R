#
#
#
# dat is the full consolidated dataset of all sites
# site$dat is the sit dataset to be read and restructured to the dat format
# shortdat is the simplified dataset with limited variables
#
# dat <- read.dta13("RAcE Malawi 60 Cluster Analysis - overall indicators.dta", nonint.factors = TRUE, generate.factors=T)
# malawidat <- read.dta13("RAcE Malawi 60 Cluster Analysis - overall indicators.dta", nonint.factors = TRUE, generate.factors=T)
# abiadat <- read.dta13("NIE ABIA cg_combined_hh_roster_overall_final.dta", nonint.factors = TRUE, generate.factors=T)
# nigerst <- read.dta13("Niger State Overall Illness Analysis Final.dta", nonint.factors = TRUE, generate.factors=T)
# drcdat <- read.dta13("DRC HH Analysis-Overall Variables.dta", nonint.factors = TRUE, generate.factors=T)
#
#  colnames(testDataset1)[colnames(drcdat)=="chw_quality"] <- "chwquality"
#  colnames(testDataset1)[colnames(drcdat)=="chw_trusted"] <- "chwtrusted"
#  colnames(testDataset1)[colnames(drcdat)=="chw_conv"] <- "chwconvenient"
#  colnames(drcdat)[colnames(drcdat)=="cg_educat"] <- "cgeduccat"
#  colnames(drcdat)[colnames(drcdat)=="d_soughtcare"] <- "d_nocare"
#  colnames(drcdat)[colnames(drcdat)=="f_soughtcare"] <- "f_nocare"
#  colnames(drcdat)[colnames(drcdat)=="fb_soughtcare"] <- "fb_nocare"
#  colnames(drcdat)[colnames(drcdat)=="d_chwnocare"] <- "d_nocarechw"
#  colnames(drcdat)[colnames(drcdat)=="f_chwnocare"] <- "f_nocarechw"
#  colnames(drcdat)[colnames(drcdat)=="fb_chwnocare"] <- "fb_nocarechw"
#  colnames(drcdat)[colnames(drcdat)=="cgknow2"] <- "cgdsknow2"
#  colnames(drcdat)[colnames(drcdat)=="mal_fever"] <- "malaria_fev_sign"
#   drcdat <- within(drcdat, levels(d_nocare)[levels(d_nocare)=="0. No"] <- "No")
#   drcdat <- within(drcdat, levels(fb_nocare)[levels(fb_nocare)=="0. No"] <- "No")
#   drcdat <- within(drcdat, levels(chwtrusted)[levels(chwtrusted)=="0. No"] <- "No")
#   drcdat <- within(drcdat, levels(chwquality)[levels(chwquality)=="0. No"] <- "No")
#   drcdat <- within(drcdat, levels(chwconvenient)[levels(chwconvenient)=="0. No"] <- "No")
#   drcdat <- within(drcdat, levels(cgdsknow2)[levels(cgdsknow2)=="0. No"] <- "No")
#   drcdat <- within(drcdat, levels(d_nocarechw)[levels(d_nocarechw)=="0. No"] <- "No")
#   drcdat <- within(drcdat, levels(f_nocarechw)[levels(f_nocarechw)=="0. No"] <- "No")
#   drcdat <- within(drcdat, levels(fb_nocarechw)[levels(fb_nocarechw)=="0. No"] <- "No")
#   drcdat <- within(drcdat, levels(d_nocare)[levels(d_nocare)=="1. Yes"] <- "Yes")
#   drcdat <- within(drcdat, levels(fb_nocare)[levels(fb_nocare)=="1. Yes"] <- "Yes")
#   drcdat <- within(drcdat, levels(chwtrusted)[levels(chwtrusted)=="1. Yes"] <- "Yes")
#   drcdat <- within(drcdat, levels(chwquality)[levels(chwquality)=="1. Yes"] <- "Yes")
#   drcdat <- within(drcdat, levels(chwconvenient)[levels(chwconvenient)=="1. Yes"] <- "Yes")
#   drcdat <- within(drcdat, levels(cgdsknow2)[levels(cgdsknow2)=="1. Yes"] <- "Yes")
#   drcdat <- within(drcdat, levels(d_nocarechw)[levels(d_nocarechw)=="1. Yes"] <- "Yes")
#   drcdat <- within(drcdat, levels(f_nocarechw)[levels(f_nocarechw)=="1. Yes"] <- "Yes")
#   drcdat <- within(drcdat, levels(fb_nocarechw)[levels(fb_nocarechw)=="1. Yes"] <- "Yes")
#  "q501", "NA"
#  "q503", "NA"
#  testDataset1 <- subset(drcdat, select = c("hhinty", "hhnumber", "hhclust", q202", "cg_educat", "q401", "q403", "dm_health", "d_soughtcare", "f_soughtcare", "fb_soughtcare", "d_chwnocare", "f_chwnocare", "fb_chwnocare", "chwtrusted", "chwquality", "chwconvenient", "cgdsknow2", "malaria_fev_sign"))
#  ##  testDataset1$site <- "drc"
##  testDataset1$q501 <- NA
##  testDataset1$q503 <- NA

# 
#
# 
#
# nigerdat <- read.dta13("Niger_illness_analysis.dta", nonint.factors = TRUE, generate.factors=T)
# 
#  "q501", "NA" (distcat)
#  "q503", "NA" (distcat)
#  "q202", "NA" (cagecat)
#   
# 
#
# 
#
# mozambiquedat <- read.dta13("Mozambique illness_analysis32 - 3.8.2017 woU2.dta", nonint.factors = TRUE, generate.factors=T)
# 
#
##  
##  testDataset1 <- subset(dat, select = c("hhinty", "hhnumber", "hhclust", "q501", "q503", "q202", "cgeduccat", "q401", "q403", "dm_health", "d_nocare", "f_nocare", "fb_nocare", "d_nocarechw", "f_nocarechw", "fb_nocarechw", "chwtrusted", "chwquality", "chwconvenient", "cgdsknow2", "malaria_fev_sign"))
##  testDataset1$site <- "abia"
##  testDataset1$q501 <- as.numeric(testDataset1$q501)
##  testDataset1$q503 <- as.numeric(testDataset1$q503)
#   testDataset1 <- testDataset1[c("hhinty", "hhnumber", "site", "hhclust", "q501", "q503", "q202", "cgeduccat", "q401", "q403", "dm_health", "d_nocare", "f_nocare", "fb_nocare", "d_nocarechw", "f_nocarechw", "fb_nocarechw", "chwtrusted", "chwquality", "chwconvenient", "cgdsknow2", "malaria_fev_sign")]
##  
# 
#
#  names(dat) == names(testDataset1)
#
#  dat <- rbind(dat, testDataset1)
#
#
#
#
#
#
#
#
#

