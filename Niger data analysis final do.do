*************************************
* NIGER ENDLINE HH SURVEY ANALYSIS **
* By: Kirsten Zalisk                *
* February 2016                     *
*************************************

clear all
set more off

cd "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Niger\Combined"


******************************
***** CAREGIVER ANALYSIS *****
******************************
use caregiver_combined, clear
lab def yn 0 "No" 1 "Yes"
lab def yndk 0 "No" 1 "Yes" 8 "Don't know"
lab def yndk2 0 "No" 1 "Yes" 98 "Don't know"

*Drop 3 caregivers from the analysis because their sick child is being dropped from 
*the analysis (incompleted module) and they only had one sick child in the survey
***cluster/HH #: 24/17, 5/20, 5/23, 15/7
drop if codevil == 24 & nummen == 17 & survey == 2
drop if codevil == 5 & nummen == 20 & survey == 2
drop if codevil == 5 & nummen == 23 & survey == 2
drop if codevil == 15 & nummen == 7 & survey == 2

*Calculate total number of cargeivers (records) included in each survey
sort survey
by survey: count 
*BL: 512, EL: 489

*Caregivers' age
*Be sure to check for outliers and missing values
tab q202, m
*10 missing

by survey:sum q202
***KZ: Age only available for endline
*hist q202 if survey == 1
*hist q202 if survey == 2
recode q202 min/24=1 25/34=2 35/44=3 45/90=4,gen(cagecat)
lab var cagecat "Caregiver's age category"
lab define cagecat 1 "15-24" 2 "25-34" 3 "35-44" 4 "45+"
lab values cagecat cagecat
tab cagecat survey, m

*Caregivers' education
tab q203 survey, m
recode q203 2=0
lab val q203 yn
tab q203 survey

tab q204 survey
tab q205 survey

gen cgeduccat = 0 if q203 == 0
replace cgeduccat = 1 if q204 == 1 
replace cgeduccat = 2 if q204 == 2 | q204 == 3
replace cgeduccat = 3 if q204 == 6 | q204 == 7
lab var cgeduccat "Caregiver's highest level of education"
lab define educ 0 "No school" 1 "Primary" 2 "Secondary or higher" 3 "Koronic/Alphbetisation", modify
lab val cgeduccat educ
lab var cgeduccat "Caregiver's education (categorical)"
tab cgeduccat survey, m
tab cgeduccat survey, col

*Recode marital status to be binary
tab q401 survey, m
replace q401 = 3 if q401 ==. & q402 !=.
recode q401 1 2=1 3=0, gen(union)
lab val union yn
lab var union "Cargeiver is married or living with partner"
tab union survey

save caregiver_analysis, replace
****************MODULE 5: Health center access**********************************
*caregiver access to nearest facility*
tab q501 survey, m
by survey:sum q501
recode q501 min/4.9=1 5/9=2 10/19=3 20/60=4,gen(distcat)
lab var distcat "Distance to nearest health center"
lab define distance 1 "<5 km" 2 "5-9 km" 3 "10-19 km" 4 "20 or more km", modify
lab values distcat distance
tab distcat survey, m

*caregiver's mode of transport  
tab q502 survey, m
recode q502 2=1 3 4 5=2 6 7=3 1=.,gen(transport)
lab def trans 1 "Walk" 2 "Motorbike/Bus/Taxi" 3 "Other", modify
lab val transport trans
tab transport survey, col

*caregiver's time to travel to nearest facility*
tab q503 survey, m
replace q503 = 360 if q503 == 3600
*hist q503
by survey: sum q503 if q503 != 998
recode q503 min/29=1 30/59=2 60/119=3 120/179=4 180/900=5 998 =.,gen(timecat)
lab var timecat "Time to reach nearest health center"
lab def timecat 1 "<30 minutes" 2 "30-59 minutes" 3 "1 - <2 hours" 4 "2 - <3 hours" 5 "3+ hours", modify
lab val timecat timecat
tab timecat survey, col

*caregiver's time to travel to nearest facility, among those who walk*
by survey: sum q503 if q503 != 998 & q502 == 2
recode q503 min/29=1 30/59=2 60/119=3 120/179=4 180/900=5 998 =.,gen(walkcat)
replace walkcat = . if q502 != 2
lab var walkcat "Time to reach nearest health center by foot"
lab val walkcat timecat
tab walkcat survey, col

****************MODULE 4: Household decision making*****************************

*Caregiver living with partner  
tab q404 survey,m 
recode q404 2=0
lab val q404 yn
tab q404 survey, col

*Women's emplyment within last 12 months

*Besides HH work, any work in past week
tab q410 survey
recode q410 2=0
lab val q410 yn

*Any other job in past week
*-Missing from endline survey
tab q411 survey
*recode q411 2=0
lab val q411 yn

*No work in past week, but were you absent from a job for some reason
*-Missing from endline survey
tab q412 survey
*recode q412 2=0
lab val q412 yn

*Not work in past week, but worked in past 12 months
*-Missing from endline survey
tab q413 survey
*recode q413 2=0
lab val q413 yn

*Form of payment for work
*-In endline survey but not sure who the question was asked of; #s do not align with q410
tab q417 survey
lab def pay 1 "Cash only" 2 "Cash and kind" 3 "In kind only" 4 "Not paid", modify
lab val q417 pay

*Who decides how caregiver's earnings are spent
*-In endline survey but not sure who the question was asked of; #s do not align with q410/q417
tab q420 survey
lab def dm 1 "Respondent" 2 "Husband/Partner" 3 "Husband/Partner Jointly" 4 "Other", modify
lab val q420 dm

*Who decides how caregiver's partner's earnings are spent
*-In endline survey but not sure who the question was asked of; #s do not align with q409
tab q422 survey
lab val q422 dm

*Household purchases decision maker (INDICATOR 19, OPTIONAL) 
*-In endline survey but not sure who the question was asked of; #s do not align with q401 == 1 or 2
tab q424 survey, col
recode q424 6 96=4,gen(dm_income)
replace dm_income =. if union != 1
lab var dm_income "Decision-maker for major household purchases"
lab val dm_income dm
tab dm_income survey, col

recode dm_income 1 2 4=0 3=1, gen(dm_income_joint)
lab var dm_income_joint "Caregiver & partner decide jointly about major HH purchases"
lab val dm_income_joint yn
tab dm_income_joint survey, col

*Health care decision maker (INDICATOR 20, OPTIONAL)
*-In endline survey but not sure who the question was asked of; #s do not align with q401 == 1 or 2
***ONLY HAVE RESPONSES FOR 72 CAREGIVERS AT ENDLINE...not reliable***
tab q423 survey, m
recode q423 96=4, gen(dm_health)
replace dm_health =. if union != 1
lab var dm_health "Decision-maker for woman to seek healthcare"
lab val dm_health dm
tab dm_health survey, col

recode dm_health 1 2 4=0 3=1, gen(dm_health_joint)
lab var dm_health_joint "Caregiver & partner decide jointly if woman seeks health care"
lab val dm_health_joint yn
tab dm_health_joint survey, col

save "caregiver_analysis", replace
****************MODULE 6: Caregiver illness knowledge***************************
*Child illness signs 
tab1 q601A-q601X

foreach x of varlist q601A-q601Z q601X {
  replace `x' = 0 if `x' ==. & q601 != ""
}

replace q601A = . if q601A !=. & q601 == ""

*Create a variable = total number of illness signs caregiver knows
egen tot_q601 = anycount(q601A-q601S), values(1)  
replace tot_q601 = . if mod6 != 1
lab var tot_q601 "Total number of illness signs CG knows"

*Create a variable = caregiver knows 2+ illness signs (INDICATOR 3)
gen cgdsknow2 = tot_q601 >= 2 & tot_q601 !=. 
replace cgdsknow2 = . if mod6 != 1
lab var cgdsknow2 "Caregiver knows 2+ child illness signs"
lab val cgdsknow2 yn
tab cgdsknow2 survey, col 

*Create a variable = caregiver knows 3+ illness signs (INDICATOR 3A)
gen cgdsknow3 = tot_q601 >= 3 & tot_q601 !=. 
replace cgdsknow3 = . if mod6 != 1
lab var cgdsknow3 "Caregiver knows 3+ child illness signs"
lab val cgdsknow3 yn
tab cgdsknow3 survey, col 

*Knowledge of malaria (not an indicator)
tab q602 survey, m
recode q602 98=8 2=0
replace q602 = 1 if q602 == . & q603 != "" & survey == 1
lab val q602 yndk

*Knowledge of malaria acquisition (INDICATOR 30, OPTIONAL)  
by survey: tab1 q603*
foreach x of varlist q603A-q603Z {
  replace `x' = 0 if `x' ==. & q602 == 1
}
gen malaria_get = .
replace malaria_get = 0 if mod6 == 1
replace malaria_get = 1 if q603A == 1
lab var malaria_get "Knowledge of Malaria Acquisition?"
lab val malaria_get yn
tab malaria_get survey, col

*Knowledge that fever is a malaria symptom
by survey: tab1 q604*
foreach x of varlist q604A-q604Z {
  replace `x' = 0 if `x' ==. & q602 == 1
}
gen malaria_fev_sign = .
replace malaria_fev_sign = 0 if mod6 == 1
replace malaria_fev_sign = 1 if q604A == 1
lab var malaria_fev_sign "Knowledge that fever is a sign of malaria"
lab val malaria_fev_sign yn
tab malaria_fev_sign survey, col

*Knowledge of at least 2 symptoms of malaria (INDICATOR 31, OPTIONAL)
egen tot_q604 = anycount(q604A-q604I), values(1)
lab var tot_q604 "Total number of malaria signs CG knows"
tab tot_q604
gen malaria_signs2 = .
replace malaria_signs2 = 0 if mod6 == 1
replace malaria_signs2 = 1 if tot_q604 >=2
lab var malaria_signs2 "Caregiver knows 2+ signs of malaria"
lab val malaria_signs2 yn
tab malaria_signs2 survey, col

***Knowledge of correct treatment for malaria, ACT (INDICATOR 32, OPTIONAL)
gen malaria_rx = .
replace malaria_rx = 0 if mod6 == 1
replace malaria_rx = 1 if strpos(q605,"1")
lab var malaria_rx "Caregiver knows correct malaria treatment"
lab val malaria_rx yn
tab malaria_rx survey, col 

save "caregiver_analysis", replace

****************MODULE 5: Caregiver knowledge & perceptions of iCCM CHWs********
*Caregiver knows there is an CHW in the community (INDICATOR 1)  
tab q504 survey, m
lab val q504 yndk
recode q504 8=0,gen(chw_know)
*Recoded No's to Yes's for 3 caregivers who answered the subsequent CHW questions
replace chw_know = 1 if q507 !=. & survey == 1
lab var chw_know "Caregiver knows CHW that works in community"
lab val chw_know yn
tab chw_know survey, col

*Caregiver knows where the CHW is located....NOT IN NIGER QUESTIONNAIRE

*Caregiver knows 2+ CHW curative services offered (INDICATOR 2)
*(among those who know that there is an CHW in their community)
foreach x of varlist q505A-q505Z {
  replace `x' = 0 if `x' ==. & chw_know == 1
  replace `x' =. if `x' !=. & chw_know != 1
}

*Total number of CHW curative services (q505k-q505s) that caregiver knows
egen tot_q505 = anycount(q505K-q505S), values(1)
label var tot_q505 "Total number of CHW curative services CG knows"
replace tot_q505 =. if chw_know != 1
tab tot_q505 survey
gen cgcurknow2 = tot_q505 >= 2 & tot_q505 !=.
replace cgcurknow2 =. if chw_know != 1
lab var cgcurknow2 "Caregiver knows 2+ CHW curative services"
lab val cgcurknow2 yn
tab cgcurknow2 survey, col

*Look at all CHW perception responses
by survey: tab1 q507-q516
foreach var of varlist q508-q516 {
  recode `var' 2 8 98=0
  lab val `var' yn
}

*CHW is a trusted provider (Q509 & Q512 must be YES) (INDICATOR 4)
tab q509 survey
tab q512 survey
gen chwtrusted = 0
replace chwtrusted = 1 if q509 == 1 & q512 == 1
replace chwtrusted =. if chw_know != 1
lab var chwtrusted "CHW is a trusted provider"
lab val chwtrusted yn
tab chwtrusted survey, col

*CHW provides quality services (3+ must be YES: Q510, Q511, Q513, Q514) (INDICATOR 5)
tab q510 survey
tab q511 survey
tab q513 survey
tab q514 survey 

egen chwquality = anycount(q510 q511 q513 q514), values(1)
replace chwquality = 0 if chwquality == 1 | chwquality == 2
replace chwquality = 1 if chwquality == 3 | chwquality == 4
replace chwquality = . if chw_know != 1
lab var chwquality "CHW provides quality services"
lab val chwquality yn
tab chwquality survey, col

save "caregiver_analysis", replace

*CHW availability by caregiver (INDICATOR 57)
***Only available for endline because caregiver #s in baseline data are not clean

*First calculate proportion of cases for which the CHW was available, by CG
*Create the numerator looking at Q724, Q822 & Q919 & careseeking from CHW (CHW was available)
gen chwavail = 0
replace chwavail = chwavail + 1 if q724 == 1 & q706H == 1
replace chwavail = chwavail + 1 if q822 == 1 & q806H == 1
replace chwavail = chwavail + 1 if q919 == 1 & q906H == 1
replace chwavail =. if q706H != 1 & q806H != 1 & q906H != 1
lab var chwavail "Total number of times CG found CHW at first visit for children in survey"
tab chwavail survey

*Create the denominator looking at careseeking from CHW (CHW was visited)
gen chwavaild = 0
replace chwavaild = chwavaild + 1 if q706H == 1
replace chwavaild = chwavaild + 1 if q806H == 1
replace chwavaild = chwavaild + 1 if q906H == 1
replace chwavaild =. if q706H != 1 & q806H != 1 & q906H != 1
lab var chwavaild "Total number of times CG sought care from CHW for children in survey"
tab chwavaild survey

*Create the proportion (numerator variable / denominator variable)
gen chwavailp = chwavail/chwavaild
lab var chwavailp "Prop of time CHW was available at first visit"
tab chwavailp survey

*Create variable to capture if CHW was ALWAYS available at first visit (INDICATOR 6)
gen chwalwaysavail = 0
replace chwalwaysavail = 1 if chwavailp == 1
replace chwalwaysavail = . if chwavaild == .
lab var chwalwaysavail "CHW was available when caregiver sought care for each case included in survey"
lab val chwalwaysavail yn 
tab chwalwaysavail survey

*CHW convenient (INDICATOR 7)
tab q507 survey, m
recode q507  2 8=0
tab q508 survey, m
gen chwconvenient = 0
replace chwconvenient = 1 if q507 == 1 & q508 == 1 
replace chwconvenient = . if chw_know != 1
lab var chwconvenient "CHW is a convenient source of care"
lab val chwconvenient yn
tab chwconvenient survey, col

save "caregiver_analysis", replace


*****************************
*****SICK CHILD ANALYSIS*****
*****************************
use illness_combined, clear
numlabel, add
lab def yn 0 "No" 1 "Yes"
lab def yndk 0 "No" 1 "Yes" 8 "Don't know"
lab def yndk2 0 "No" 1 "Yes" 98 "Don't know"

*Remove records for modules that were not completed
***Fast breathing - listed that the CG sought care but no fields completed after careseeking field ===>Drop 15 cases
tab q903 survey if fb_case == 1,m
list survey q9* if fb_case == 1 & q903 == .
*2 missing cases but other responses filled in so will keep
replace q910 = "" if q910 == " "
replace q912 = "" if q912 == " "
replace q922 = "" if q922 == " "
egen fb_count = rownonmiss( q909 q910 q911 q912 q913 q914 q915 q916 q917 q918 q919 q920 q921 q922 q923 q924), strok
tab fb_count if q903 == 1
list q9* if fb_count == 0 & q903 == 1
list survey codevil nummen mod7 mod8 mod9 if fb_count == 0 & q903 == 1
***Need to drop 4 CGs from CG analysis because they only had a sick child with cough/fb and those records were dropped.
***cluster/HH #: 24/17, 5/20, 5/23, 15/7
drop if fb_count == 0 & q903 == 1 & survey == 2

***Fever - listed that the CG sought care but no fields completed after careseeking field ===>Drop 1 cases
*Don't need to drop CG record - has multiple illness modules
tab q803 survey if f_case == 1,m
list survey q8* if f_case == 1 & q803 == .
list survey codevil nummen mod7 mod8 mod9 if q803 == . & f_case == 1
*3 missing cases all other responses missing (except 1 record had cont feeding/fluids info) ==> Drop 3 cases
*Don't need to drop CG records - have multiple illness modules
drop if f_case == 1 & q803 ==. & survey == 1

replace q814 = "" if q814 == " "
replace q825 = "" if q825 == " "
egen f_count = rownonmiss(q809 q810 q811 q812 q813 q814 q815 q816 q817 q818 q819 q820 q821 q822 q823 q824 q825 q826 q827), strok
tab f_count if q803 == 1
list q8* if f_count == 2 & q803 == 1
list q8* if f_count == 4 & q803 == 1
list survey codevil nummen mod7 mod8 mod9 if f_count == 2 & q803 == 1
***Do not need to drop any CGs from CG analysis ==> Drop 1 case
drop if f_count == 2 & q803 == 1 & survey == 1

***Diarrhea - 
tab q703 survey if d_case == 1,m
list survey q7* if d_case == 1 & q703 == .
*10 cases but other responses filled in, so will keep
egen d_count = rownonmiss(q710 q711 q715 q716 q720 q724 q725 q726 q727 q728 q729), strok
tab d_count if d_case == 1
***Records seem to be okay.

*Calculate total number of sick child cases included in each survey
sort survey
by survey: count 
*BL: 996, EL: 889

tab d_case survey
*BL:339, EL: 292
tab f_case survey
*BL:345, EL:305
tab fb_case survey
*BL:312, EL:292

*continued fluids (same amount or more than usual?) (INDICATOR 28, OPTIONAL) 
tab q701 survey if d_case == 1,m
recode q701 1 2 5 98 =0 3 4=1, gen(d_cont_fluids)
lab var d_cont_fluids "Child with diarrhea was offered same or more fluids"
lab val d_cont_fluids yn
tab d_cont_fluids survey, col

*continued feeding (same amount or more than usual) (INDICATOR 29, OPTIONAL)  
tab q702 survey if d_case == 1,m
recode q702 1 2 5 6 8 =0 3 4=1, gen(d_cont_feed)
lab var d_cont_feed "Child with diarrhea was offered same or more to eat"
lab val d_cont_feed yn
tab d_cont_feed survey, col

*sought care for diarrhea
tab q703 survey if d_case == 1, m
recode q703 2=0
*-Missing 10 responses, but all sought care  at baseline
replace q703 = 1 if q706 != "" & q703 != 1 & survey == 1 & d_case == 1
*-2 caregivers missing care-seeking response but didn't list any care-seeking location 
replace q703 = 0 if q703 ==. & q706 == "" & q711 != . & survey == 1 & d_case == 1
replace q703 = 0 if q703 ==. & q706 =="" & survey == 1 & d_case == 1
lab val q703 yn
tab q703 survey

*reason did not seek care for diarrhea (ENDLINE ONLY) 
tab q708c survey
replace q708c = "" if q708c == " "
gen q708ca = 1 if strpos(q708c, "A")
gen q708cb = 1 if strpos(q708c, "B")
gen q708cc = 1 if strpos(q708c, "C")
gen q708cd = 1 if strpos(q708c, "D")
gen q708ce = 1 if strpos(q708c, "E")
gen q708cf = 1 if strpos(q708c, "F")
gen q708cg = 1 if strpos(q708c, "G")
gen q708cx = 1 if strpos(q708c, "X")
gen q708cz = 1 if strpos(q708c, "Z")

foreach var of varlist q708ca-q708cz {
  replace `var' = 0 if `var' == . & q708c != ""
}

*where care was sought
tab q706 survey if d_case == 1, m
replace q706 = "" if q706 == " "

foreach x of varlist q706A-q706X {
  replace `x' = 0 if `x' ==. & q703 == 1
}

egen d_provtot = anycount(q706A-q706X), values(1)
replace d_provtot =. if d_case != 1
lab var d_provtot "Total number of providers where sought care"
tab d_provtot survey, col 

*sought advice or treatment from an appropriate provider (INDICATOR 8A)
egen d_apptot = anycount(q706A-q706H), values(1)
replace d_apptot =. if d_case != 1
lab var d_apptot "Total number of appropriate providers where sought care"
recode d_apptot 1 2 = 1, gen(d_app_prov)

replace d_app_prov =. if d_case != 1
lab var d_app_prov "Sought care from 1+ appropriate provider"
lab val d_app_prov yn 
tab d_app_prov survey, col

*decided to seek care jointly
****93 responses missing at BL; 44 responses missing at EL
tab q704 survey if d_case == 1, m
recode q704 2=0
*-2 records name a person decided to seek care with but q704 missing, changed q704 to be YES
replace q704 = 1 if q704 ==. & q705 !=.
lab val q704 yn
tab q704 survey, col

*decided with whom?
****93 responses missing at BL; 44 responses missing at EL
tab q705 survey if d_case == 1, m
lab def joint 1 "Partner" 2 "Head of Household" 3 "Mother-in-Law" 96 "Other"
lab val q705 joint
tab q705 survey, col

*diarrhea sought treatment from an appropriate provider jointly with a partner (INDICATOR 21A, OPTIONAL) 
*- Missing 6 BL and 6EL responses for CGs who indicated that they sought care jointly
*- Missing 88BL and 33EL responses for CGs who did not answer q704
gen d_app_joint =.
recode q401 3=0 1 2=1, gen(union)
lab val union yn
replace d_app_joint = 0 if union == 1 & d_case == 1 
replace d_app_joint = 1 if d_app_prov == 1 & q705==1 & union == 1 & d_case == 1
replace d_app_joint =. if q703 == 1 & q705 ==. 
replace d_app_joint = 0 if q703 == 0 & q705 !=.
lab var d_app_joint "Decided to seek care from appropriate provider jointly with partner"
lab val d_app_joint yn
tab d_app_joint survey, col

*diarrhea sought treatment jointly with a partner 
*- Missing 6 BL and 7 EL responses for CGs who indicated that they sought care jointly
gen d_joint =.
replace d_joint = 0 if union == 1 & d_case == 1 
replace d_joint = 1 if q705==1 & union == 1 & d_case == 1
replace d_joint =. if q703 == 1 & q705 ==. 
replace d_joint = 0 if q703 == 0 & q705 !=.
lab var d_joint "Decided to seek care jointly with partner"
lab val d_joint yn
tab d_joint survey, col

*Organize care-seeking responses by categories in the report template
gen d_cs_public = 1 if q706A == 1 | q706B == 1 | q706C == 1 | q706D == 1 | q706F == 1
gen d_cs_private = 1 if q706G == 1
gen d_cs_chw = 1 if q706H == 1
gen d_cs_store = 1 if q706J == 1 | q706K == 1 
gen d_cs_trad = 1 if q706I == 1
gen d_cs_other = 1 if q706L == 1 | q706X == 1
gen d_cs_asc = 1 if q706E == 1 

foreach var of varlist d_cs_* {
  replace `var' = 0 if `var' == . & d_provtot > 0 & d_provtot != . & d_case == 1
 }

*did not seek care
tab q703 survey 
gen d_nocare = .
replace d_nocare = 0 if q703 == 1 & d_case == 1
replace d_nocare = 1 if q703 == 0 & d_case == 1
lab var d_nocare "Did not seek care for child with diarrhea"
lab val d_nocare yn
tab d_nocare survey, col

*did not seek care from a CHW
gen d_nocarechw = .
replace d_nocarechw = 0 if d_case == 1 & q703 == 1
replace d_nocarechw = 1 if q706H != 1 & q703 == 1 & d_case == 1
lab var d_nocarechw "Sought care for diarrhea - but not from CHW"
lab val d_nocarechw yn
tab d_nocarechw survey, col

*visited an CHW  
gen d_chw = 1 if q706H == 1 
replace d_chw = 0 if d_chw ==. & d_case == 1 
lab var d_chw "Sought care from CHW for diarrhea"
lab val d_chw yn
tab d_chw survey, col 

*where sought care first
*-National hospital
gen d_firstcare = 11 if q708 == "A" | (q708 == "11" & q706A == 1) | (q706A == 1 & d_provtot == 1)
*-Regional hospital
replace d_firstcare = 12 if q708 == "B" | (q708 == "12" & q706B == 1 )| (q706B == 1 & d_provtot == 1)
*-District hospital
replace d_firstcare = 13 if q708 == "C" | (q708 == "13" & q706C == 1 ) | (q706C == 1 & d_provtot == 1)
*-CSI (health facility)
replace d_firstcare = 14 if q708 == "D" | (q708 == "14" & q706D == 1 ) | (q706D == 1 & d_provtot == 1)
*-Case de Sante
replace d_firstcare = 15 if q708 == "E" | (q708 == "16" & q706E == 1 ) | (q706E == 1 & d_provtot == 1)
*-Mobile clinic
replace d_firstcare = 16 if q708 == "F" | (q708 == "17" & q706F == 1 ) | (q706F == 1 & d_provtot == 1)
*-Private clinic
replace d_firstcare = 17 if q708 == "G" | (q708 == "18" & q706G == 1 ) | (q706G == 1 & d_provtot == 1)
*-RCom (CHW)
replace d_firstcare = 18 if q708 == "H" | (q708 == "15" & q706H == 1 ) | (q706H == 1 & d_provtot == 1)
*-Traditional healer
replace d_firstcare = 21 if q708 == "I" | (q708 == "21" & q706I == 1 ) | (q706I == 1 & d_provtot == 1)
*-Shop
replace d_firstcare = 22 if q708 == "J" | (q708 == "22" & q706J == 1 ) | (q706J == 1 & d_provtot == 1)
*-Pharmacy
replace d_firstcare = 23 if q708 == "K" | (q708 == "23" & q706K == 1 ) | (q706K == 1 & d_provtot == 1)
*-Friend/relative
replace d_firstcare = 26 if q708 == "L" | (q708 == "26" & q706L == 1 ) | (q706L == 1 & d_provtot == 1)
*-Other
replace d_firstcare = 98 if q708 == "X" | (q708 == "98" & q706X == 1 ) | (q706X == 1 & d_provtot == 1)

*Organize care-seeking responses by categories in the report template
egen d_fcs_public = anymatch(d_firstcare), values(11,12,13,14,16)
replace d_fcs_public =. if q703 != 1
gen d_fcs_private = 1 if d_firstcare == 17
gen d_fcs_chw = 1 if d_firstcare == 18
gen d_fcs_store = 1 if d_firstcare == 22 | d_firstcare == 23 
gen d_fcs_trad = 1 if d_firstcare == 21
gen d_fcs_other = 1 if d_firstcare == 26 | d_firstcare == 98
gen d_fcs_asc = 1 if d_firstcare == 15 

foreach x of varlist d_fcs_private-d_fcs_asc {
  replace `x' = 0 if `x' ==. & d_provtot > 0 & d_provtot != . & d_case == 1
}

*visited an CHW as first (*or only*) source of care (INDICATOR 9A)
gen d_chwfirst = .
replace d_chwfirst = 0 if d_case == 1
replace d_chwfirst = 1 if d_firstcare == 18
lab var d_chwfirst "Sought care from CHW first"
lab val d_chwfirst yn
tab d_chwfirst survey, col

*visited an CHW as first (*or only*) source of care - among those who sought any care
gen d_chwfirst_anycare = .
replace d_chwfirst_anycare = 0 if q703 == 1  
replace d_chwfirst_anycare = 1 if d_firstcare == 18
lab var d_chwfirst_anycare "Sought care from CHW first, among those who sought any care"
lab val d_chwfirst_anycare yn
tab d_chwfirst_anycare survey, col

*visited an asc as first (*or only*) source of care (INDICATOR 9A)
gen d_ascfirst = .
replace d_ascfirst = 0 if d_case == 1
replace d_ascfirst = 1 if d_firstcare == 15
lab var d_ascfirst "Sought care from asc first"
lab val d_ascfirst yn
tab d_ascfirst survey, col

*visited an asc as first (*or only*) source of care - among those who sought any care
gen d_ascfirst_anycare = .
replace d_ascfirst_anycare = 0 if q703 == 1  
replace d_ascfirst_anycare = 1 if d_firstcare == 15
lab var d_ascfirst_anycare "Sought care from asc first, among those who sought any care"
lab val d_ascfirst_anycare yn
tab d_ascfirst_anycare survey, col

*reason(s) did not go to CHW for care (ENDLINE ONLY)

tab q708b
replace q708b = "" if q708b == " "
*Recode this other response to prefer to go to another provider (E)
gen q708ba = 1 if q708b == "A"
gen q708bb = 1 if q708b == "B"
gen q708bc = 1 if q708b == "C"
gen q708bd = 1 if q708b == "D"
gen q708be = 1 if q708b == "E"
gen q708bf = 1 if q708b == "F"
gen q708bx = 1 if q708b == "X"
gen q708bz = 1 if q708b == "Z"
*There are responses for 3 caregivers who stated that they sought care from a CHW
*If sought care from a CHW, recode responses q708b to be missing
foreach var of varlist q708ba-q708bz {
  replace `var' = 0 if `var' == . & q708b != "" 
  replace `var' =. if q706H == 1 & `var' !=.
}

***treated with ORS (INDICATOR 26, OPTIONAL)
*A (ORS packet) was included at BL only, B (ORS liquid) was included in both, C (HMFL) was incluyded in EL only
*-One missing response for q709a, but have a response for q709b
tab q709a survey
recode q709a 98=8
lab val q709a yndk
tab q709b survey
recode q709b 2=0 98=8
lab val q709b yndk
tab q709c survey
recode q709c 2=0 
lab val q709c yndk

gen d_ors =.
replace d_ors = 0 if d_case == 1 
replace d_ors = 1 if q709a == 1 | q709b == 1 
*There are 7 records in which CG stated didn't give ORS, but indicate place where they obtained ORS
*Change NO ORS response to YES
replace d_ors = 1 if d_ors == 0 & q711 != .
lab var d_ors "Took ORS for diarrhea"
lab val d_ors yn
tab d_ors survey, col

*where did caregiver get ORS?
tab q711 survey if d_ors == 1,m


*Organize locations of treatment by categories in the report template
egen d_ors_public = anymatch(q711), values(11,12,13,14,16)
replace d_ors_public =. if d_ors != 1
gen d_ors_private = 1 if q711 == 17
gen d_ors_chw = 1 if q711 == 18
gen d_ors_store = 1 if q711 == 22 | q711 == 23 
gen d_ors_trad = 1 if q711 == 21
gen d_ors_other = 1 if q711 == 26 | q711 == 98
gen d_ors_asc = 1 if q711 == 15

foreach x of varlist d_ors_private-d_ors_asc {
  replace `x' = 0 if `x' == . & d_ors == 1
}

*got ORS from CHW
gen d_orschw =.
replace d_orschw = 0 if d_case == 1
replace d_orschw = 1 if d_ors == 1 & q711 == 18
replace d_orschw = . if d_ors == 1 & q711 == .
lab var d_orschw "Got ORS from an CHW"
lab val d_orschw yn
tab d_orschw survey, col

*got ORS from CHW, among those who sought care from a CHW
gen d_orschw2 =.
replace d_orschw2 = 0 if d_chw == 1
replace d_orschw2 = 1 if d_ors == 1 & q711 == 18 & d_chw == 1
lab var d_orschw2 "Got ORS from an CHW, among those who sought care from a CHW"
lab val d_orschw2 yn
tab d_orschw2 survey, col

*got ORS from asc
gen d_orsasc =.
replace d_orsasc = 0 if d_case == 1
replace d_orsasc = 1 if d_ors == 1 & q711 == 15
replace d_orsasc = . if d_ors == 1 & q711 == .
lab var d_orsasc "Got ORS from an asc"
lab val d_orsasc yn
tab d_orsasc survey, col

*got ORS from asc, among those who sought care from asc
gen d_orsasc2 =.
replace d_orsasc2 = 0 if d_cs_asc == 1
replace d_orsasc2 = 1 if d_orsasc == 1 & d_cs_asc == 1
replace d_orsasc2 = . if d_ors == 1 & q711 == .
lab var d_orsasc2 "Got ORS from an asc"
lab val d_orsasc2 yn
tab d_orsasc2 survey, col

*got ORS from provider other than asc and CHW
gen d_orsoth =.
replace d_orsoth = 0 if d_case == 1
replace d_orsoth = 1 if d_ors == 1 & (q711 != 18 & q711 != 15)
replace d_orsoth = . if d_ors == 1 & q711 == .
lab var d_orsoth "Got ORS from provider other than ASC and CHW"
lab val d_orsoth yn
tab d_orsoth survey, col

*if from CHW, did child take ORS in presence of CHW? (INDICATOR 15A)
*-Missing 3 responses in which CG got ORS from CHW
*-Includes 2 responses in which CG did not get ORS from CHW
tab q713 survey
recode q713 2=0
lab val q713 yn  
tab q713 survey, col

gen d_ors_chwp = .
replace d_ors_chwp = 0 if d_orschw == 1
replace d_ors_chwp = 1 if d_orschw == 1 & q713 == 1
replace d_ors_chwp =. if d_orschw == 1 & q713 ==.
lab var d_ors_chwp "Did child take ORS in presence of CHW?"
lab val d_ors_chwp yn
*2 missing responses
tab d_ors_chwp survey

*if from CHW, did caregiver get counseled on how to give ORS at home? (INDICATOR 16A)
*-Missing 3 responses in which CG got ORS from CHW
*-Includes 2 responses in which CG did not get ORS from CHW
tab q714 survey
recode q714 2=0
lab val q714 yn
tab q714 survey, col

gen d_ors_chwc =.
replace d_ors_chwc = 0 if d_orschw == 1
replace d_ors_chwc = 1 if d_orschw == 1 & q714 == 1
replace d_ors_chwc =. if d_orschw == 1 & q714 ==.
lab var d_ors_chwc "Did caregiver get counseled on how to give ORS at home?"
lab val d_ors_chwc yn
*2 missing responses
tab d_ors_chwc survey, col

*took Homemade fluid (ENDLINE ONLY)
gen d_hmfl =.
replace d_hmfl = 0 if d_case == 1 & survey == 2
replace d_hmfl = 1 if q709c == 1 & survey == 2
lab var d_hmfl "Did child take homemade fluid?"
lab val d_hmfl yn
tab d_hmfl survey, col

*took Zinc (INDICATOR 27, OPTIONAL)
tab q715 survey
recode q715 2=0 98=8
lab val q715 yndk
recode q715 2 8=0, gen(d_zinc)
lab val d_zinc yn
lab var d_zinc "Did child take Zinc?"
*-Missing 2 responses for Zinc, but no location and zinc flag == 0, so setting missing to NO
replace d_zinc = 0 if d_zinc ==. & d_case == 1
*-One response with location given but zinc = NO, changing zinc to YES
replace d_zinc = 1 if d_zinc == 0 & q716 !=.
tab d_zinc survey, col

*where did caregiver get zinc?
tab q716 survey

*Organize locations of treatment by categories in the report template
egen d_zinc_public = anymatch(q716), values(11,12,13,14,16)
replace d_zinc_public =. if d_zinc != 1
gen d_zinc_private = 1 if q716 == 17
gen d_zinc_chw = 1 if q716 == 18
gen d_zinc_store = 1 if q716 == 22 | q716 == 23 
gen d_zinc_trad = 1 if q716 == 21
gen d_zinc_other = 1 if q716 == 26 | q716 == 98
gen d_zinc_asc = 1 if q716 == 15

foreach x of varlist d_zinc_private-d_zinc_asc {
  replace `x' = 0 if `x' == . & d_zinc == 1
}

*got zinc from CHW
gen d_zincchw =.
replace d_zincchw = 0 if d_case == 1
replace d_zincchw = 1 if d_zinc == 1 & q716 == 18
lab var d_zincchw "Got zinc from an CHW"
lab val d_zincchw yn
tab d_zincchw survey, col

*got zinc from CHW, among those who sought care from a CHW
gen d_zincchw2 =.
replace d_zincchw2 = 0 if d_chw == 1
replace d_zincchw2 = 1 if d_zinc == 1 & q716 == 18 & d_chw == 1
lab var d_zincchw2 "Got zinc from an CHW, among those who sought care from a CHW"
lab val d_zincchw2 yn
tab d_zincchw2 survey, col

*got zinc from asc
gen d_zincasc =.
replace d_zincasc = 0 if d_case == 1
replace d_zincasc = 1 if d_zinc == 1 & q716 == 15
lab var d_zincasc "Got zinc from an asc"
lab val d_zincasc yn
tab d_zincasc survey, col

*got zinc from provider other than CHW and ASC
gen d_zincoth =.
replace d_zincoth = 0 if d_case == 1
replace d_zincoth = 1 if d_zinc == 1 & (q716 != 18 & q716 != 15)
lab var d_zincoth "Got zinc from provider other than CHW and ASC"
lab val d_zincoth yn
tab d_zincoth survey, col

*got zinc from asc, among those who sought care from a asc
gen d_zincasc2 =.
replace d_zincasc2 = 0 if d_cs_asc == 1
replace d_zincasc2 = 1 if d_zinc == 1 & q716 == 15 & d_cs_asc == 1
lab var d_zincasc2 "Got zinc from an asc, among those who sought care from a asc"
lab val d_zincasc2 yn
tab d_zincasc2 survey, col

*if from CHW, did child take zinc in presence of CHW? (INDICATOR 15B)
*-Missing 3 responses in which CG got ORS from CHW
*-Includes 2 responses in which CG did not get ORS from CHW
tab q718 survey
recode q718 2=0
lab val q718 yn  
tab q718 survey, col

gen d_zinc_chwp = .
replace d_zinc_chwp = 0 if d_zincchw == 1
replace d_zinc_chwp = 1 if d_zincchw == 1 & q718 == 1
replace d_zinc_chwp =. if d_zincchw == 1 & q718 ==.
lab var d_zinc_chwp "Did child take zinc in presence of CHW?"
lab val d_zinc_chwp yn
*2 missing responses
tab d_zinc_chwp survey

*if from CHW, did caregiver get counseled on how to give zinc at home? (INDICATOR 16B)
*-Missing 3 responses in which CG got ORS from CHW
*-Includes 2 responses in which CG did not get ORS from CHW
tab q719 survey
recode q719 2=0
lab val q719 yn  
tab q719 survey, col

gen d_zinc_chwc = .
replace d_zinc_chwc = 0 if d_zincchw == 1
replace d_zinc_chwc = 1 if d_zincchw == 1 & q719 == 1
replace d_zinc_chwc =. if d_zincchw == 1 & q719 ==.
lab var d_zinc_chwc "Did caregiver get counseled on how to give zinc at home?"
lab val d_zinc_chwc yn
*2 missing responses
tab d_zinc_chwc survey

*treated with ORS AND Zinc (INDICATOR 13A)
gen d_orszinc = .
replace d_orszinc = 0 if d_case == 1
replace d_orszinc = 1 if d_ors==1 & d_zinc==1
lab var d_orszinc "Took both ORS and zinc for diarrhea"
lab val d_orszinc yn
tab d_orszinc survey, col

*treated with ORS AND Zinc by CHW (INDICATOR 14A)
gen d_orszincchw =.
replace d_orszincchw = 0 if d_case == 1
replace d_orszincchw = 1 if d_orszinc == 1 & d_orschw == 1 & d_zincchw == 1
replace d_orszincchw = . if d_ors == 1 & q711 == . 
lab var d_orszincchw "Treated with both ORS and zinc for diarrhea by CHW"
lab val d_orszincchw yn
tab d_orszincchw survey, col

*treated with ORS AND Zinc by CHW, among those who sought care from a CHW
gen d_orszincchw2 = .
replace d_orszincchw2 = 0 if d_chw == 1
replace d_orszincchw2 = 1 if d_orszincchw == 1 & d_chw == 1
lab var d_orszincchw2 "Got ORS & zinc from CHW, among those who sought care from a CHW"
lab val d_orszincchw2 yn
tab d_orszincchw2 survey, col

*treated with ORS AND Zinc by asc (INDICATOR 14A)
gen d_orszincasc =.
replace d_orszincasc = 0 if d_case == 1
replace d_orszincasc = 1 if d_orszinc == 1 & d_orsasc == 1 & d_zincasc == 1 
replace d_orszincasc = . if d_ors == 1 & q711 == . 
lab var d_orszincasc "Treated with both ORS and zinc for diarrhea by asc"
lab val d_orszincasc yn
tab d_orszincasc survey, col

*treated with ORS AND Zinc by asc, among those who sought care from a asc
gen d_orszincasc2 = .
replace d_orszincasc2 = 0 if d_cs_asc == 1
replace d_orszincasc2 = 1 if d_orszincasc == 1 & d_cs_asc == 1
lab var d_orszincasc2 "Got ORS & zinc from asc, among those who sought care from a asc"
lab val d_orszincasc2 yn
tab d_orszincasc2 survey, col

*treated with ORS AND Zinc by asc (INDICATOR 14A)
gen d_orszincoth =.
replace d_orszincoth = 0 if d_case == 1
replace d_orszincoth = 1 if d_orszinc == 1 & d_orsoth == 1 & d_zincoth == 1 
replace d_orszincoth = . if d_ors == 1 & q711 == . 
lab var d_orszincoth "Treated with both ORS and zinc for diarrhea by provider other than ASC and CHW"
lab val d_orszincoth yn
tab d_orszincoth survey, col

*Sought care from provider other than RCom or ASC
gen d_careoth = 0 if d_case == 1
replace d_careoth = 1 if d_provtot == 1 & d_chw != 1 & d_cs_asc != 1
replace d_careoth = 1 if d_provtot == 2 & (d_chw != 1 | d_cs_asc != 1)
replace d_careoth = 1 if d_provtot == 3
tab d_careoth survey

*treated with ORS AND Zinc by provider other than RCom or ASC(INDICATOR 14A)
gen d_orszincoth2 =.
replace d_orszincoth2 = 0 if d_careoth == 1 
replace d_orszincoth2 = 1 if d_orszinc == 1 & d_orsoth == 1 & d_zincoth == 1 & d_careoth == 1
replace d_orszincoth2 = . if d_ors == 1 & q711 == . 
lab var d_orszincoth2 "Treated with both ORS and zinc by provider other than ASC and CHW"
lab val d_orszincoth2 yn
tab d_orszincoth2 survey, col

*treated with ORS by provider other than RCom or ASC(INDICATOR 14A)
gen d_orsoth2 =.
replace d_orsoth2 = 0 if d_careoth == 1 
replace d_orsoth2 = 1 if d_orsoth == 1 & d_careoth == 1
replace d_orsoth2 = . if d_ors == 1 & q711 == . 
lab var d_orsoth2 "Treated with ORS by provider other than ASC and CHW"
lab val d_orsoth2 yn
tab d_orsoth2 survey, col

*treated with ORS AND Zinc by provider other than RCom or ASC(INDICATOR 14A)
gen d_zincoth2 =.
replace d_zincoth2 = 0 if d_careoth == 1 
replace d_zincoth2 = 1 if d_zincoth == 1 & d_careoth == 1
replace d_zincoth2 = . if d_zinc == 1 & q716 == . 
lab var d_zincoth2 "Treated with zinc by provider other than ASC and CHW"
lab val d_zincoth2 yn
tab d_zincoth2 survey, col

*took both ORS AND Zinc in presence of CHW (INDICATOR 15C)
gen d_bothfirstdose =.
replace d_bothfirstdose = 0 if d_orszincchw == 1 
replace d_bothfirstdose = 1 if d_ors_chwp == 1 & d_zinc_chwp == 1
replace d_bothfirstdose =. if d_ors_chwp ==. | d_zinc_chwp ==.
lab var d_bothfirstdose "Took first dose of both ORS and zinc in presense of CHW"
lab val d_bothfirstdose yn
tab d_bothfirstdose survey, col

*was counseled on admin of both ORS AND Zinc by CHW (INDICATOR 16C)
gen d_bothcounsel =.
replace d_bothcounsel = 0 if d_orszincchw == 1
replace d_bothcounsel = 1 if d_ors_chwc == 1 & d_zinc_chwc == 1
replace d_bothfirstdose =. if d_ors_chwc ==. | d_zinc_chwc ==.
lab var d_bothcounsel "Was counseled on admin of both ORS and zinc by CHW"
lab val d_bothcounsel yn
tab d_bothcounsel survey, col

*if CHW visited, was available at first visit
*-Missing 15 responses
tab q724 survey  
recode q724 2=0 
lab val	q724 yn
recode q724 8=0, gen(d_chwavail)
replace d_chwavail = . if d_chw != 1
lab var d_chwavail "Was CHW available at first visit?"
lab val d_chwavail yn
tab d_chwavail survey

*if CHW visited, did CHW refer the child to a health center?
*CGs who indicated that they did not seek care at a CHW said that they were referred by a CHW
tab q725 survey
recode q725 2=0 
lab val q725 yndk
recode q725 8=0, gen(d_chwrefer)
replace d_chwrefer =. if d_chw != 1
lab var d_chwrefer "CHW refered child to health center?"
lab val d_chwrefer yn
tab d_chwrefer survey

*completed CHW referral (INDICATOR 17A) 
tab q726 survey
recode q726 2=0
lab val q726 yn
clonevar d_referadhere = q726
replace d_referadhere =. if d_chwrefer ==.
lab var d_referadhere "Completed CHW referral?"
lab val d_referadhere yn
tab d_referadhere survey

*reason did not comply with CHW referral
tab q727 survey
replace q727 = "" if q727 == " " | q727 == "."
gen q727a = 1 if strpos(q727,"A") & d_referadhere == 0
gen q727b = 1 if strpos(q727,"B") & d_referadhere == 0
gen q727c = 1 if strpos(q727,"C") & d_referadhere == 0 
gen q727d = 1 if strpos(q727,"D") & d_referadhere == 0 
gen q727e = 1 if strpos(q727,"E") & d_referadhere == 0
gen q727f = 1 if strpos(q727,"F") & d_referadhere == 0 
gen q727g = 1 if strpos(q727,"G") & d_referadhere == 0 
gen q727h = 1 if strpos(q727,"H") & d_referadhere == 0 
gen q727x = 1 if strpos(q727,"X") & d_referadhere == 0 
gen q727z = 1 if strpos(q727,"Z") & d_referadhere == 0

foreach var of varlist q727a-q727z {
  replace `var' = 0 if `var' ==. & d_referadhere == 0
}

***CHW follow-up (INDICATOR 18A)
tab q728 survey
recode q728 2=0
lab val q728 yn
recode q728 8=0, gen(d_chw_fu)
replace d_chw_fu = . if d_chw != 1
lab var d_chw_fu "CHW followed up sick child"
lab val d_chw_fu yn
tab d_chw_fu survey, col

***when was CHW follow-up
*-Missing from baseline survey
tab q729 survey
recode q729 7 8=., gen(d_when_fu)
replace d_when_fu =. if d_chw_fu != 1
tab d_when_fu survey, col

*sick child given anything else?
tab q721 survey
replace q721 = "" if q721 == " "

foreach var of varlist q721A-q721X {
  replace `var' = 0 if `var' ==. & d_case == 1
}

egen d_othermed = rownonmiss(q721A-q721X)
replace d_othermed = . if d_case != 1
lab var d_othermed "Total number of other meds child given for diarrhea"
*tab d_othermed survey, col 


save "illness_analysis", replace 

*********************MODULE 8: Fever *******************************************

*continued fluids (same amount or more than usual?) (INDICATOR 28, OPTIONAL) 
*-Missing 2 responses at baseline
tab q801 survey if f_case == 1,m
recode q801 1 2 5 8 =0 3 4=1, gen(f_cont_fluids)
lab var f_cont_fluids "Child with fever was offered same or more fluids"
lab val f_cont_fluids yn
tab f_cont_fluids survey, col

*continued feeding (same amount or more than usual) (INDICATOR 29, OPTIONAL)
*-Missing 2 responses at baseline
tab q802 survey if f_case == 1,m
recode q802 1 2 5 6 8 =0 3 4=1, gen(f_cont_feed)
lab var f_cont_feed "Child with fever was offered same or more to eat"
lab val f_cont_feed yn
tab f_cont_feed survey, col

*sought any advice or treatment for fever
tab q803 survey if f_case == 1, m
recode q803 2=0 
lab val q803 yn
*-One response indicates did not seek care but location and medicine listed so changing to YES
replace q803 = 1 if q803 == 0 & q806 !="" & q806 != " "

*
*reason did not seek care for fever (ENDLINE ONLY)
***Not sure where responses 1 2 3 come from
***More responses that people who did not seek care - doesn't make sense
tab q828
replace q828 = "" if q828 == " " | q828 == "."
rename q828Bxx q828B
drop q828b
gen q828a = 1 if strpos(q828,"A") 
gen q828b = 1 if strpos(q828,"B") 
gen q828c = 1 if strpos(q828,"C") 
gen q828d = 1 if strpos(q828,"D") 
gen q828e = 1 if strpos(q828,"E") 
gen q828f = 1 if strpos(q828,"F") 
gen q828g = 1 if strpos(q828,"G")
gen q828x = 1 if strpos(q828,"X") 
gen q828z = 1 if strpos(q828,"Z")

egen tot_q828 = rownonmiss(q828A-q828Z)
replace tot_q828 = . if f_case != 1 
replace tot_q828 = . if survey == 1 
lab var tot_q828 "Number of reasons caregiver did not seek care"
tab tot_q828

foreach var of varlist q828A-q828Z {
  replace `var' = 0 if `var' ==. & tot_q828 > 0 & tot_q828 != . & f_case == 1
}

*decided to seek care jointly
recode q805 9=.
tab q805 survey, m
*/

*where care was sought
tab q806 survey if f_case == 1,m
replace q806 = "" if q806 == " "
*-3 responses missing but careseeking = YES and location of medicine given as 16 
replace q806 = "15" if q806 =="" & q816 ==15
replace q806E = 1 if q806 =="15" & q816 ==15
*-1 response missing but careseeking = YES and location is also missing but listed medicine
replace q803 = 0 if q806 =="" & q803 == 1 & q816 ==.

egen f_provtot = anycount(q806A-q806X), values(1)
replace f_provtot = . if f_case != 1
lab var f_provtot "Total number of providers where sought care"
tab f_provtot survey, col

foreach var of varlist q806A-q806X {
  replace `var' = 0 if `var' ==. & f_provtot > 0 & f_provtot != . & f_case == 1
}

*sought advice or treatment from an appropriate provider (INDICATOR 8B)
egen f_apptot = anycount(q806A-q806H), values(1)
replace f_apptot = . if f_case != 1
lab var f_apptot "Total number of appropriate providers where sought care"
tab f_apptot survey

recode f_apptot 1 2 3 = 1, gen(f_app_prov)
replace f_app_prov = 0 if f_app_prov ==. & f_case == 1
lab var f_app_prov "Sought care from 1+ appropriate provider"
lab val f_app_prov yn 
tab f_app_prov survey, col

*Organize care-seeking responses by categories in the report template
gen f_cs_public = 1 if q806A == 1 | q806B == 1 | q806C == 1 | q806D == 1 | q806F == 1
gen f_cs_private = 1 if q806G == 1
gen f_cs_chw = 1 if q806H == 1
gen f_cs_store = 1 if q806J == 1 | q806K == 1 
gen f_cs_trad = 1 if q806I == 1
gen f_cs_other = 1 if q806L == 1 | q806X == 1
gen f_cs_asc = 1 if q806E == 1

foreach var of varlist f_cs_* {
  replace `var' = 0 if `var' == . & f_provtot > 0 & f_provtot != . & f_case == 1
 }

*did not seek care
tab q803
gen f_nocare = .
replace f_nocare = 0 if q803 == 1 & f_case == 1
replace f_nocare = 1 if q803 == 0 & f_case == 1
lab var f_nocare "Did not seek care for child with fever"
lab val f_nocare yn
tab f_nocare survey, col

*did not seek care from a CHW
gen f_nocarechw = .
replace f_nocarechw = 0 if f_case == 1 & q803 == 1
replace f_nocarechw = 1 if q806H != 1 & q803 == 1 & f_case == 1
lab var f_nocarechw "Sought care for fever - but not from CHW"
lab val f_nocarechw yn
tab f_nocarechw survey, col

*decided to seek care jointly
****81 responses missing at BL; 35 responses missing at EL
tab q804 survey if f_case == 1, m
recode q804 2=0
*-12 records name a person decided to seek care with but q704 missing, changed q704 to be YES
replace q804 = 1 if q804 ==. & q805 !=.
lab val q804 yn
tab q804 survey, col

*decided with whom?
****81 responses missing at BL; 35 responses missing at EL
*- 2 records indicated decided to seek care jointly but no person listed
tab q805 survey if f_case == 1, m
lab val q805 joint
tab q805 survey, col

*fever decided to seek care from an appropriate provider jointly with a partner (INDICATOR 21B, OPTIONAL)
*- 2 records indicated decided to seek care jointly but no person listed
gen f_app_joint =.
replace f_app_joint = 0 if f_case == 1 & union == 1 
replace f_app_joint = 1 if f_app_prov == 1 & q805==1 & union == 1 & f_case == 1
replace f_app_joint =. if q803 == 1 & q805 ==. 
replace f_app_joint = 0 if q803 == 0 & q805 !=.
lab var f_app_joint "Decided to seek care from appropriate provider jointly with partner"
lab val f_app_joint yn
tab f_app_joint survey

*fever decided to seek care jointly with a partner (INDICATOR 21A, OPTIONAL) 
*- 2 records indicated decided to seek care jointly but no person listed
gen f_joint =.
replace f_joint = 0 if union == 1 & f_case == 1 
replace f_joint = 1 if q805==1 & union == 1 & f_case == 1
replace f_joint =. if q803 == 1 & q805 ==. 
replace f_joint = 0 if q803 == 0 & q805 !=.
lab var f_joint "Decided to seek care jointly with partner"
lab val f_joint yn
tab f_joint survey, col

*visited an CHW  
gen f_chw = 1 if q806H == 1 
replace f_chw = 0 if f_chw ==. & f_case == 1 
lab var f_chw "Sought care from CHW for fever"
lab val f_chw yn
tab f_chw survey, col 

*where sought care first
gen f_firstcare = 11 if q808 == "A" | (q808 == "11" & q806A == 1) | (q806A == 1 & f_provtot == 1)
replace f_firstcare = 12 if q808 == "B" | (q808 == "12" & q806B == 1 )| (q806B == 1 & f_provtot == 1)
replace f_firstcare = 13 if q808 == "C" | (q808 == "13" & q806C == 1 ) | (q806C == 1 & f_provtot == 1)
replace f_firstcare = 14 if q808 == "D" | (q808 == "14" & q806D == 1 ) | (q806D == 1 & f_provtot == 1)
replace f_firstcare = 15 if q808 == "E" | (q808 == "16" & q806E == 1 ) | (q806E == 1 & f_provtot == 1)
replace f_firstcare = 16 if q808 == "F" | (q808 == "17" & q806F == 1 ) | (q806F == 1 & f_provtot == 1)
replace f_firstcare = 17 if q808 == "G" | (q808 == "18" & q806G == 1 ) | (q806G == 1 & f_provtot == 1)
replace f_firstcare = 18 if q808 == "H" | (q808 == "15" & q806H == 1 ) | (q806H == 1 & f_provtot == 1)
replace f_firstcare = 21 if q808 == "I" | (q808 == "21" & q806I == 1 ) | (q806I == 1 & f_provtot == 1)
replace f_firstcare = 22 if q808 == "J" | (q808 == "22" & q806J == 1 ) | (q806J == 1 & f_provtot == 1)
replace f_firstcare = 23 if q808 == "K" | (q808 == "23" & q806K == 1 ) | (q806K == 1 & f_provtot == 1)
replace f_firstcare = 26 if q808 == "L" | (q808 == "26" & q806L == 1 ) | (q806L == 1 & f_provtot == 1)
replace f_firstcare = 98 if q808 == "X" | (q808 == "98" & q806X == 1 ) | (q806X == 1 & f_provtot == 1)

*Organize care-seeking responses by categories in the report template
egen f_fcs_public = anymatch(f_firstcare), values(11,12,13,14,16)
replace f_fcs_public =. if q803 != 1
gen f_fcs_private = 1 if f_firstcare == 17
gen f_fcs_chw = 1 if f_firstcare == 18
gen f_fcs_store = 1 if f_firstcare == 22 | f_firstcare == 23 
gen f_fcs_trad = 1 if f_firstcare == 21
gen f_fcs_other = 1 if f_firstcare == 26 | f_firstcare == 98
gen f_fcs_asc = 1 if f_firstcare == 15

foreach x of varlist f_fcs_private-f_fcs_asc {
  replace `x' = 0 if `x' ==. & f_provtot > 0 & f_provtot != . & f_case == 1
}

*visited an CHW as first (*or only*) source of care (INDICATOR 9A)
gen f_chwfirst = .
replace f_chwfirst = 0 if f_case == 1
replace f_chwfirst = 1 if f_firstcare == 18
lab var f_chwfirst "Sought care from CHW first"
lab val f_chwfirst yn
tab f_chwfirst survey, col

*visited an CHW as first (*or only*) source of care - among those who sought any care
gen f_chwfirst_anycare = .
replace f_chwfirst_anycare = 0 if q803 == 1  
replace f_chwfirst_anycare = 1 if f_firstcare == 18
lab var f_chwfirst_anycare "Sought care from CHW first, among those who sought any care"
lab val f_chwfirst_anycare yn
tab f_chwfirst_anycare survey, col

*visited an asc as first (*or only*) source of care (INDICATOR 9A)
gen f_ascfirst = .
replace f_ascfirst = 0 if f_case == 1
replace f_ascfirst = 1 if f_firstcare == 15
lab var f_ascfirst "Sought care from asc first"
lab val f_ascfirst yn
tab f_ascfirst survey, col

*visited an asc as first (*or only*) source of care - among those who sought any care
gen f_ascfirst_anycare = .
replace f_ascfirst_anycare = 0 if q803 == 1  
replace f_ascfirst_anycare = 1 if f_firstcare == 15
lab var f_ascfirst_anycare "Sought care from asc first, among those who sought any care"
lab val f_ascfirst_anycare yn
tab f_ascfirst_anycare survey, col


*reason(s) did not go to CHW for care (ENDLINE ONLY)
***26 did not seek care but only 7 CGs gave reasons -- does not make sense
tab q808b_A

*had blood taken (INDICATOR 10) 
tab q809 survey
recode q809 2=0 98=8
lab var q809 "Had Blood Taken"
recode q809 8=0 if q803 ==1, gen(f_bloodtaken)
replace f_bloodtaken = . if f_case != 1
replace f_bloodtaken = 0 if f_case == 1 & f_bloodtaken ==.
*-2 records missing responses to 809, set to NO
replace f_bloodtaken = 0 if f_bloodtaken ==. & q803 == 1
lab var f_bloodtaken "Child had blood taken"
lab val f_bloodtaken yn
tab f_bloodtaken survey, col

* who performed the blood test - only 1 response for each
replace q810 = "1" if q810 == "A"
replace q810 = "2" if q810 == "2" | q810 == "B"
replace q810 = "3" if q810 == "3" | q810 == "C"
replace q810 = "4" if q810 == "4" | q810 == "D"
replace q810 = "8" if q810 == "96" | q810 == "X"
replace q810 = "9" if q810 == "98" | q810 == "Z"
replace q810 = "" if q810 == " "
destring q810, replace
*-One record where indicated a who, but bloodtaken = NO, so changed who to be missing
replace q810 = . if q810 == 9 & q809 == 0

lab def who 1 "CHW" 2 "Medical Assistant" 3 "Nurse" 4 "Doctor" 8 "Other" 9 "Don't know", modify
lab val q810 who
tab q810 survey

*had blood taken from CHW
gen f_bloodtakenchw = .
replace f_bloodtakenchw = 0 if f_chw == 1
replace f_bloodtakenchw = 1 if q810 == 1 & f_chw == 1
lab var f_bloodtakenchw "Child had blood taken by a CHW"
lab val f_bloodtakenchw yn
tab f_bloodtakenchw survey

*had blood taken from provider other CHW
gen f_bloodtakenoth = .
replace f_bloodtakenoth = 0 if (f_provtot == 1 & f_chw != 1) | (f_provtot >=2 & f_provtot !=.)
replace f_bloodtakenoth = 1 if ((f_provtot == 1 & f_chw != 1) | (f_provtot >=2 & f_provtot !=.)) & q810 > 1 & q810 < 9
lab var f_bloodtakenoth "Child had blood taken by provider other than CHW"
lab val f_bloodtakenoth yn
tab f_bloodtakenoth survey

*caregiver received results of blood test (INDICATOR 11) 
tab q811 survey
recode q811 2=0 98=8
*-1 response missing but had blood taken and knew result, so changing got result to YES
replace q811 = 1 if f_bloodtaken == 1 & q811 ==. & q812 ==1
*-1 result missing but stated got result, so changing go result to NO
replace q811 = 0 if q811 == 1 & q812 ==.
lab val q811 yndk
recode q811 8=0 if f_bloodtaken == 1,gen(f_gotresult)
lab val f_gotresult yn
lab var f_gotresult "Caregiver received results of blood test"
tab f_gotresult survey, col
	
*caregiver received results of blood test from CHW
gen f_gotresultchw = .
replace f_gotresultchw = 0 if f_bloodtakenchw == 1
replace f_gotresultchw = 1 if f_bloodtakenchw == 1 & f_gotresult == 1
lab var f_gotresultchw "Caregiver received results of blood test performed by CHW"
lab val f_gotresultchw yn
tab f_gotresultchw survey

*caregiver received results of blood test done by provider other than CHW 
gen f_gotresultoth = .
replace f_gotresultoth = 0 if f_bloodtakenoth == 1
replace f_gotresultoth = 1 if f_gotresult == 1 & f_bloodtakenoth == 1
lab var f_gotresultoth "Caregiver recieved results from provider other than CHW"
lab val f_gotresultoth yn
tab f_gotresultoth survey

*blood test results  
tab q812 survey, col 
recode q812 2=0 98=8
lab val q812 yndk
recode q812 8=0, gen(f_result)
lab var f_result "Blood test result"
lab def result 0 "Negative" 1 "Positive"
lab val f_result result
tab f_result survey

*blood test results from CHW
gen f_resultchw = .
replace f_resultchw = 0 if f_gotresultchw == 1
replace f_resultchw = 1 if f_gotresultchw == 1 & f_result == 1
lab var f_resultchw "Result of blood test performed by CHW"
lab val f_resultchw yn
tab f_resultchw survey

*Cases managed by provider other than CHW: Blood test was positive
gen f_resultoth = .
replace f_resultoth = 0 if f_gotresultoth == 1
replace f_resultoth = 1 if f_result == 1 & f_gotresultoth == 1
lab var f_resultoth "Received positive blood test result from provider other than CHW"
lab val f_resultoth yn
tab f_resultoth survey

***took any medicine
tab q813 survey
recode q813 2=0
lab val q813 yn
*-2 records q813= NO but medicine listed in q814, so changed q813 to YES
replace q813 = 1 if q813==. & q814 !="" & q803 == 1
tab q813 survey

tab q814

foreach var of varlist q814A-q814Z {
  replace `var' = 0 if `var' == . & q814 !=""
}

***took any antimalarial (INDICATOR 22, OPTIONAL)
gen f_antim = 1 if q814A == 1 | q814B == 1 | q814C == 1 | q814D == 1
replace f_antim = 0 if f_antim ==. & f_case == 1
lab var f_antim "Took antimalarial for fever"
lab val f_antim yn
tab f_antim survey, col

*tool any antimalarial after positive blood test, among all fever cases
gen f_antimc = 1 if f_result == 1 & (q814A == 1 | q814B == 1 | q814C == 1 | q814D == 1)
replace f_antimc = 0 if f_antimc ==. & f_result == 1
lab var f_antimc "Took antimalarial for fever after positive blood test, all fever cases"
lab val f_antimc yn
tab f_antimc survey, col

*tool any antimalarial after positive blood test, among confirmed malaria cases
gen f_antimc2 = 1 if f_result == 1 & (q814A == 1 | q814B == 1 | q814C == 1 | q814D == 1)
replace f_antimc2 = 0 if f_antimc2 ==. & f_result == 1
lab var f_antimc2 "Took antimalarial for fever after positive blood test, confirmed malaria"
lab val f_antimc2 yn
tab f_antimc2 survey, col

*took AL Coartem (ACT)
gen f_act = .
replace f_act = 0 if f_case == 1
replace f_act = 1 if (q814A == 1 | q814B == 1) & q803 == 1 & f_case == 1
lab var f_act "Took ACT for fever"
lab val f_act yn
tab f_act survey, col

*took ACT among any antimalarial (INDICATOR 23, OPTIONAL)
gen f_act_am = . 
replace f_act_am = 1 if f_act == 1
replace f_act_am = 0 if f_antim == 1 & f_act_am ==.
lab var f_act_am "Took ACT among any antimalarial"
lab val f_act_am yn
tab f_act_am survey, col

**took ACT within 24 hours (same or next day)
gen f_act24 = .
replace f_act24 = 0 if f_case == 1 
replace f_act24 = 1 if f_act == 1 & q817 < 2
lab var f_act24 "Took ACT within 24 hours of start of fever"
lab val f_act24 yn
tab f_act24 survey, col

**took ACT after positive blood test
gen f_actc = 0 if f_result == 1
replace f_actc = 1 if f_act == 1 & f_result == 1
lab var f_actc "Took ACT after malaria confirmed by blood test"
lab val f_actc yn
tab f_actc survey, col

***appropriate fever treatment - confirmed malaria within 24 hours (INDICATOR 13C)  
gen f_actc24 = .
replace f_actc24 = 0 if f_result == 1  
replace f_actc24 = 1 if f_actc == 1 & q817 < 2  
lab var f_actc24 "Appropriate, timely confirmed malaria treatment"
lab val f_actc24 yn
tab f_actc24 survey, col 

*where did caregiver get ACT?
tab q816 survey, col

*Where got ACT
*Organize locations of treatment by categories in the report template
egen f_act_public = anymatch(q816), values(11,12,13,14,16)
replace f_act_public =. if f_act != 1
gen f_act_private = 1 if q816 == 17
gen f_act_chw = 1 if q816 == 18
gen f_act_store = 1 if q816 == 22 | q816 == 23 
gen f_act_trad = 1 if q816 == 21
gen f_act_other = 1 if q816 == 26 | q816 == 98
gen f_act_asc = 1 if q816 == 15

foreach x of varlist f_act_private-f_act_asc {
  replace `x' = 0 if `x' == . & f_act == 1
  replace `x' = . if `x' != . & f_act == 0
}

*ACT from CHW - all fever cases
gen f_actchw = .
replace f_actchw = 0 if f_case == 1 
replace f_actchw = 1 if f_act == 1 & q816 == 18
replace f_actchw = . if q816 == . & f_act == 1
lab var f_actchw "ACT treatment by an CHW, all fever cases"
lab val f_actchw yn
tab f_actchw survey, col 

*ACT from ASC - all fever cases
gen f_actasc = .
replace f_actasc = 0 if f_case ==1 
replace f_actasc = 1 if f_act == 1 & q816 == 15
replace f_actasc = . if q816 == . & f_act == 1
lab var f_actasc "ACT treatment by provider ascer than CHW, all fever cases"
lab val f_actasc yn
tab f_actasc survey, col 

*ACT from provider other than ASC or CHW - all fever cases
gen f_actoth = .
replace f_actoth = 0 if f_case ==1 
replace f_actoth = 1 if f_act == 1 & (q816 != 15 & q816 != 18)
replace f_actoth = . if q816 == . & f_act == 1
lab var f_actoth "ACT treatment by provider other than CHW and ASC, all fever cases"
lab val f_actoth yn
tab f_actoth survey, col 

**ACT from CHW within 24 hours (same or next day)
gen f_act24chw = .
replace f_act24chw = 0 if f_case == 1 
replace f_act24chw = 1 if f_act == 1 & q817 < 2 & q816 == 18
replace f_act24chw = . if q816 == . & f_act == 1
lab var f_act24chw "ACT treatment by CHW within 24 hours of start of fever"
lab val f_act24chw yn
tab f_act24chw survey, col

**ACT from ASC within 24 hours (same or next day)
gen f_act24asc = .
replace f_act24asc = 0 if f_case == 1 
replace f_act24asc = 1 if f_act == 1 & q817 < 2 & q816 == 15
replace f_act24asc = . if q816 == . & f_act == 1
lab var f_act24asc "ACT treatment by asc within 24 hours of start of fever"
lab val f_act24asc yn
tab f_act24asc survey, col

**ACT from provider other than ASC and CHW within 24 hours (same or next day)
gen f_act24oth = .
replace f_act24oth = 0 if f_case == 1 
replace f_act24oth = 1 if f_act == 1 & q817 < 2 & (q816 != 18 & q816 != 15)
replace f_act24oth = . if q816 == . & f_act == 1
lab var f_act24oth "ACT treatment by provider other than CHW and ASC within 24 hours of start of fever"
lab val f_act24oth yn
tab f_act24oth survey, col

*ACT from CHW - confirmed among all fever cases
gen f_actcchw = .
replace f_actcchw = 0 if f_result == 1
replace f_actcchw = 1 if f_actc == 1 & q816 == 18
lab var f_actcchw "ACT treatment by an CHW, malaria confirmed by blood test"
lab val f_actcchw yn
tab f_actcchw survey, col 

*ACT from ASC  - confirmed among all fever cases
gen f_actcasc = .
replace f_actcasc = 0 if f_result == 1
replace f_actcasc = 1 if f_actc == 1 & q816 == 15
lab var f_actcasc "ACT treatment by ASC, malaria confirmed by blood test"
lab val f_actcasc yn
tab f_actcasc survey, col 


*ACT from provider other than CHW and ASC  - confirmed among all fever cases
gen f_actcoth = .
replace f_actcoth = 0 if f_result == 1
replace f_actcoth = 1 if f_actc == 1 & (q816 != 18 & q816 != 15)
lab var f_actcoth "ACT treatment by provider other than CHW and ASC, malaria confirmed by blood test"
lab val f_actcoth yn
tab f_actcoth survey, col 

*appropriate fever treatment from CHW - confirmed within 24 hours (INDICATOR 14C)
gen f_actc24chw = .
replace f_actc24chw = 0 if f_result == 1 
replace f_actc24chw = 1 if f_actc24 == 1 & q816 == 18
lab var f_actc24chw "ACT treatment by an CHW - confirmed malaria within 2 days"
lab val f_actc24chw yn
tab f_actc24chw survey, col 

*appropriate fever treatment from ASC - confirmed within 24 hours (INDICATOR 14C)
gen f_actc24asc = .
replace f_actc24asc = 0 if f_result == 1 
replace f_actc24asc = 1 if f_actc24 == 1 & q816 == 15
lab var f_actc24asc "ACT treatment ASC - confirmed malaria within 2 days"
lab val f_actc24asc yn
tab f_actc24asc survey, col 

*appropriate fever treatment from provider other than CHW and ASC - confirmed within 24 hours (INDICATOR 14C)
gen f_actc24oth = .
replace f_actc24oth = 0 if f_result == 1 
replace f_actc24oth = 1 if f_actc24 == 1 & (q816 != 15 & q816 != 18)
lab var f_actc24oth "ACT treatment by provider other than CHW and ASC - confirmed malaria within 2 days"
lab val f_actc24oth yn
tab f_actc24oth survey, col 

*fever treatment - ACT if care was sought from CHW
gen f_actchw_2 = .
replace f_actchw_2 = 0 if f_chw == 1
replace f_actchw_2 = 1 if f_actchw == 1 & f_chw == 1
lab var f_actchw_2 "ACT treatment, among fever cases if care was sought from CHW"
lab val f_actchw_2 yn
tab f_actchw_2 survey

*fever treatment from CHW within 24 hours among those managed by CHW 
gen f_act24chw2 = .
replace f_act24chw2 = 0 if f_chw == 1 
replace f_act24chw2 = 1 if f_act24chw == 1 & f_chw == 1
lab var f_act24chw2 "ACT treatment by an CHW within 24 hours, cases managed by CHW"
lab val f_act24chw2 yn
tab f_act24chw2 survey

*fever treatment from CHW - confirmed among those managed by CHW among those with positive result
gen f_actcchw2 = .
replace f_actcchw2 = 0 if f_resultchw == 1
replace f_actcchw2 = 1 if f_actcchw == 1 & f_resultchw == 1
lab var f_actcchw2 "ACT treatment by an CHW - positive blood test, cases managed by CHW"
lab val f_actcchw2 yn
tab f_actcchw2 survey

***ACT treatment with 24 hours from CHW - positive blood test, among those who sought care from a CHW
gen f_actc24chw2 = .
replace f_actc24chw2 = 0 if f_chw == 1 & f_resultchw == 1
replace f_actc24chw2 = 1 if f_actc24chw == 1 & f_chw == 1
lab var f_actc24chw2 "ACT treatment within 24 hours by a CHW - blood test+, among those who sought care from a CHW"
lab val f_actc24chw2 yn
tab f_actc24chw2 survey, col

***ACT treatment from asc - among those who sought care from a asc
gen f_actasc2 = .
replace f_actasc2 = 0 if f_cs_asc == 1 
replace f_actasc2 = 1 if f_actasc == 1 & f_cs_asc == 1
lab var f_actasc2 "ACT treatment by a asc - among those who sought care from a asc"
lab val f_actasc2 yn
tab f_actasc2 survey, col

***ACT treatment with 24 hours from asc - among those who sought care from a asc
gen f_act24asc2 = .
replace f_act24asc2 = 0 if f_cs_asc == 1 
replace f_act24asc2 = 1 if f_act24asc == 1 & f_cs_asc == 1
lab var f_act24asc2 "ACT treatment within 24 hours by a asc - among those who sought care from a asc"
lab val f_act24asc2 yn
tab f_act24asc2 survey, col

*ACT from ASC  - confirmed among all fever cases
gen f_actcasc2 = .
replace f_actcasc2 = 0 if f_result == 1 & f_cs_asc == 1
replace f_actcasc2 = 1 if f_actcasc == 1 & f_cs_asc == 1
lab var f_actcasc2 "ACT treatment by ASC, malaria confirmed by blood test"
lab val f_actcasc2 yn
tab f_actcasc2 survey, col 

**ACT treatment with 24 hours from asc - positive blood test, among those who sought care from a asc
gen f_actc24asc2 = .
replace f_actc24asc2 = 0 if f_cs_asc == 1 & f_result == 1
replace f_actc24asc2 = 1 if f_actc24asc == 1 & f_cs_asc == 1
lab var f_actc24asc2 "ACT treatment within 24 hours by a asc - blood test+, among those who sought care from a asc"
lab val f_actc24asc2 yn
tab f_actc24asc2 survey, col

*Sought care from provider other than RCom and ASC
gen f_careoth = 0 if f_case == 1
replace f_careoth = 1 if f_provtot == 1 & f_chw != 1 & f_cs_asc != 1
replace f_careoth = 1 if f_provtot == 2 & (f_chw != 1 | f_cs_asc != 1)
replace f_careoth = 1 if f_provtot == 3
tab f_careoth survey

*ACT from provider other than ASC or CHW - sought care from other providers
gen f_actoth2 = .
replace f_actoth2 = 0 if f_careoth == 1  
replace f_actoth2 = 1 if f_actoth == 1 & f_careoth == 1
replace f_actoth2 = . if q816 == . & f_act == 1
lab var f_actoth2 "ACT treatment by provider other than CHW and ASC, sought care from other providers"
lab val f_actoth2 yn
tab f_actoth2 survey, col 

*ACT from provider other than ASC or CHW within 24 hours - sought care from other providers
gen f_act24oth2 = .
replace f_act24oth2 = 0 if f_careoth == 1  
replace f_act24oth2 = 1 if f_act24oth == 1 & f_careoth == 1
replace f_act24oth2 = . if q816 == . & f_act == 1
lab var f_act24oth2 "ACT treatment by provider other than CHW and ASC, sought care from other providers"
lab val f_act24oth2 yn
tab f_act24oth2 survey, col 

*ACT from provider other than CHW and ASC  - confirmed among all fever cases
gen f_actcoth2 = .
replace f_actcoth2 = 0 if f_resultoth == 1 & f_careoth == 1
replace f_actcoth2 = 1 if f_careoth == 1 & f_actcoth == 1 & f_careoth == 1
lab var f_actcoth2 "ACT treatment by provider other than CHW and ASC, malaria confirmed by blood test"
lab val f_actcoth2 yn
tab f_actcoth2 survey, col 

*appropriate fever treatment from provider other than CHW and ASC - confirmed within 24 hours (INDICATOR 14C)
gen f_actc24oth2 = .
replace f_actc24oth2 = 0 if f_resultoth == 1 & f_careoth == 1
replace f_actc24oth2 = 1 if f_resultoth == 1 & f_careoth == 1 & f_actc24oth == 1 
lab var f_actc24oth2 "ACT treatment by provider other than CHW and ASC - confirmed malaria within 2 days"
lab val f_actc24oth2 yn
tab f_actc24oth2 survey, col 

*Cases managed by provider other than CORP: Blood test was positive
gen f_actc_resultoth = .
replace f_actc_resultoth = 0 if f_resultoth == 1
replace f_actc_resultoth = 1 if f_resultoth == 1 & f_actc == 1 & f_actchw != 1 & f_actasc != 1
lab var f_actc_resultoth "Received positive blood test result from provider other than CHW"
lab val f_actc_resultoth yn
tab f_actc_resultoth survey

*fever treatment - confirmed, among those with positive result
gen f_actc2 = .
replace f_actc2 = 0 if f_result == 1
replace f_actc2 = 1 if f_actc == 1 & f_result == 1
lab var f_actc2 "ACT treatment, among those with positive blood test result"
lab val f_actc2 yn
tab f_actc2 survey

*received ACT without blood test
gen f_actnotest =.
replace f_actnotest = 0 if f_bloodtaken == 0
replace f_actnotest = 1 if f_act == 1 & f_bloodtaken == 0
lab var f_actnotest "Given ACT but not givern blood test"
lab val f_actnotest yn
tab f_actnotest survey, col

*received ACT but had negative blood test result
gen f_actneg = .
replace f_actneg = 0 if f_result == 0
replace f_actneg = 1 if f_act == 1 & f_result == 0
lab var f_actneg "Given ACT but blood test result was negative"
lab val f_actneg yn
tab f_actneg survey, col

*no treatment with ACT if blood test negative
gen f_noactnoc = 0 if f_result == 0 
replace f_noactnoc = 1 if f_act != 1 & f_result == 0 
lab var f_noactnoc "No ACT given, among those with negative blood test result"
lab val f_noactnoc yn
tab f_noactnoc survey, col

*no treatment with ACT if blood test positive
gen f_noactc = 0 if f_result == 1 
replace f_noactc = 1 if f_act != 1 & f_result == 1 
lab var f_noactc "No ACT given, among those with positive blood test result"
lab val f_noactc yn
tab f_noactc survey, col

*if from CHW, did child take ACT in presence of CHW? (INDICATOR 15B)  
tab q819 survey
recode q819 2=0
lab val q819 yndk
recode q819 8=0, gen(f_act_chwp)
replace f_act_chwp = . if f_actchw != 1 | (f_act_chwp ==. & f_actchw == 1)
lab var f_act_chwp "Child took ACT in presence of CHW?"
lab val f_act_chwp yn
tab f_act_chwp survey

*if from CHW, did caregiver get counseled on how to give ACT at home? (INDICATOR 16B)
tab q820 survey
recode q820 2=0 
lab val q820 yn
clonevar f_act_chwc = q820
replace f_act_chwc = . if f_actchw != 1 | (f_act_chwc ==. & f_actchw == 1)
lab var f_act_chwc "Was CG counseled on how to give ACT at home?"
lab val f_act_chwc yn
tab f_act_chwc survey

*if CHW visited, was available at first visit
*-Missing responses for 8 children
tab q822 survey
recode q822 2=0  
lab val q822 yndk
recode q822 8=0, gen(f_chwavail)
replace f_chwavail =. if f_chw != 1
lab var f_chwavail "CHW was available at first visit?"
lab val f_chwavail yn
tab f_chwavail survey

*if CHW visited, did CHW refer the child to a health center?
*-Missing responses for 8 children
tab q823 survey
recode q823 2=0 
lab val q823 yndk
recode q823 8=0, gen(f_chwrefer)
replace f_chwrefer =. if f_chw != 1
lab var f_chwrefer "CHW refered child to health center?"
lab val f_chwrefer yn
tab f_chwrefer survey

***completed CHW referral (INDICATOR 17C)
tab q824 survey
recode q824 2=0
lab val q824 yn
clonevar f_referadhere = q824
replace f_referadhere = . if f_chwrefer != 1
lab var f_referadhere "Completed CHW referral?"
lab val f_referadhere yn
tab f_referadhere survey

***reason did not comply with CHW referral  
*Note: Only one response allowed at baseline but multiple allowed at endline
tab q825 if f_referadhere == 0
replace q825 = "" if q825 == " " | q825 == "."
gen q825a = 1 if strpos(q825,"A") & f_referadhere == 0
gen q825b = 1 if strpos(q825,"B") & f_referadhere == 0
gen q825c = 1 if strpos(q825,"C") & f_referadhere == 0
gen q825d = 1 if strpos(q825,"D") & f_referadhere == 0
gen q825e = 1 if strpos(q825,"E") & f_referadhere == 0
gen q825f = 1 if strpos(q825,"F") & f_referadhere == 0
gen q825g = 1 if strpos(q825,"G") & f_referadhere == 0
gen q825h = 1 if strpos(q825,"H") & f_referadhere == 0
gen q825x = 1 if strpos(q825,"X") & f_referadhere == 0
gen q825z = 1 if strpos(q825,"Z") & f_referadhere == 0

foreach var of varlist q825a-q825z {
  replace `var' = 0 if `var' == . & f_referadhere == 0
}

***CHW follow-up (INDICATOR 18B)
*Missing responses for 12 CGs
tab q826 survey
recode q826 2=0
lab val q826 yn
clonevar f_chw_fu = q826
replace f_chw_fu = . if f_chw != 1
lab var f_chw_fu "CHW followed up sick child"
lab val f_chw_fu yn
tab f_chw_fu survey, col

***when was CHW follow-up
tab q827 survey
recode q827 8=., gen(f_when_fu)
replace f_when_fu =. if f_chw_fu != 1
tab f_when_fu survey, col


save "illness_analysis", replace 
***********************MODULE 9: Fast Breathing*********************************

*continued fluids (same amount or more than usual?) (INDICATOR 28, OPTIONAL) 
tab q901 survey if fb_case == 1,m
recode q901 1 2 5 8 =0 3 4=1, gen(fb_cont_fluids)
lab var fb_cont_fluids "Child with cough & fast breathing was offered same or more fluids"
lab val fb_cont_fluids yn
tab fb_cont_fluids survey, col

*continued feeding (same amount or more than usual) (INDICATOR 29, OPTIONAL)  
tab q902 survey if fb_case == 1,m
recode q902 1 2 5 6 8 =0 3 4=1, gen(fb_cont_feed)
lab var fb_cont_feed "Child with cough & fast breathing was offered same or more to eat"
lab val fb_cont_feed yn
tab fb_cont_feed survey, col

*sought any advice or treatment
tab q903 survey
recode q903 2=0

lab val q903 yn

****reason did no seek care for cough/fast breathing (ENDLINE ONLY)
*57 CGs responded that they didn't seek care but there are reasons for not seeking care for 121 caregivers
tab q924a
replace q924a = "" if q924a == " "
gen q924aa = 1 if q924a == "A"
gen q924ab = 1 if q924a == "B" 
gen q924ac = 1 if q924a == "C" 
gen q924ad = 1 if q924a == "D" 
gen q924ae = 1 if q924a == "E" 
gen q924af = 1 if q924a == "F" 
gen q924ag = 1 if q924a == "G" 
gen q924ax = 1 if q924a == "X" 
gen q924az = 1 if q924a == "Z" 
replace q924ax = 1 if q924a == "X Z"

foreach var of varlist q924aa-q924az {
  replace `var' = 0 if `var' == . & q924a !=""
}

*where care was sought
tab q906 survey if fb_case == 1,m
replace q906 = "" if q906 == " "
*-1 record that has q903=YES, but no locations listed. Change q903=YES to NO
replace q903 = 0 if q903 == 1 & q906 == ""
*-4 records that list a careseeking location but indicate did not seek care, so changing seek care to YES
replace q903 = 1 if q903 == 0 & q906 != ""
*-2 records that list a careseeking location but missing response to q903, so changing seek care to YES
replace q903 = 1 if q903 ==. & q906 != ""

tab q903 survey
tab q906 survey

*total number of providers visited 
egen fb_provtot = anycount(q906A-q906X), values(1)
replace fb_provtot = . if fb_case != 1
lab var fb_provtot "Total number of providers where sought care"
tab fb_provtot survey, col

foreach var of varlist q906A-q906X {
  replace `var' = 0 if `var' ==. & fb_provtot > 0 & fb_provtot != . & fb_case == 1
}

egen fb_apptot = anycount(q906A-q906H), values(1)
replace fb_apptot = . if fb_case != 1
lab var fb_apptot "Total number of appropriate providers where sought care"
tab fb_apptot survey

recode fb_apptot 1 2 3 = 1, gen(fb_app_prov)
replace fb_app_prov = 0 if fb_app_prov ==. & fb_case == 1
lab var fb_app_prov "Sought care from 1+ appropriate provider"
lab val fb_app_prov yn 
tab fb_app_prov survey, col

*Organize care-seeking responses by categories in the report template
gen fb_cs_public = 1 if q906A == 1 | q906B == 1 | q906C == 1 | q906D == 1 | q906F == 1
gen fb_cs_private = 1 if q906G == 1
gen fb_cs_chw = 1 if q906H == 1
gen fb_cs_store = 1 if q906J == 1 | q906K == 1 
gen fb_cs_trad = 1 if q906I == 1
gen fb_cs_other = 1 if q906L == 1 | q906X == 1
gen fb_cs_asc = 1 if q906E == 1 

foreach var of varlist fb_cs_* {
  replace `var' = 0 if `var' == . & fb_provtot > 0 & fb_provtot != . & fb_case == 1
 }

*decided to seek care jointly
****79 responses missing at BL; 55 responses missing at EL
tab q904 survey if fb_case == 1, m
recode q904 2=0
lab val q904 yn
*- 5 records indicated did not indicate sought care jointly but person listed, so changing q904 to YES
replace q904 = 1 if q905 != . & q904 != 1
*- 1 record indicated decided to seek care jointly but no person listed, so changing q904 to NO
replace q904 = 0 if q905 == . & q904 == 1
tab q904 survey, col

*decided with whom?
****79 responses missing at BL; 55 responses missing at EL
tab q905 survey if fb_case == 1, m
lab val q905 joint
tab q905 survey, col

*cough with fast breathing decided to seek treatment from an appropriate provider jointly with a partner (INDICATOR 21B, OPTIONAL)
gen fb_app_joint =.
replace fb_app_joint = 0 if fb_case == 1 & union == 1 
replace fb_app_joint = 1 if fb_app_prov == 1 & q905==1 & union == 1 & fb_case == 1
replace fb_app_joint =. if q903 == 1 & q905 ==. 
replace fb_app_joint = 0 if q903 == 0 & q905 !=.
lab var fb_app_joint "Sought care from appropriate provider jointly with partner"
lab val fb_app_joint yn
tab fb_app_joint survey

*cough with fast breathing decided to seek care jointly with a partner 
gen fb_joint =.
replace fb_joint = 0 if union == 1 & fb_case == 1 
replace fb_joint = 1 if q905==1 & union == 1 & fb_case == 1
replace fb_joint =. if q903 == 1 & q905 ==. 
replace fb_joint = 0 if q903 == 0 & q905 !=.
lab var fb_joint "Decided to seek care jointly with partner"
lab val fb_joint yn
tab fb_joint survey, col

*did not seek care
tab q903 survey
gen fb_nocare = .
replace fb_nocare = 0 if q903 == 1 & fb_case == 1
replace fb_nocare = 1 if q903 == 0 & fb_case == 1
lab var fb_nocare "Did not seek care for child with cough with fast breathing"
lab val fb_nocare yn
tab fb_nocare survey, col

*did not seek care from a CHW
gen fb_nocarechw = .
replace fb_nocarechw = 0 if fb_case == 1 & q903 == 1
replace fb_nocarechw = 1 if q906H != 1 & q903 == 1 & fb_case == 1
lab var fb_nocarechw "Sought care for cough with fast breathing - but not from CHW"
lab val fb_nocarechw yn
tab fb_nocarechw survey, col

*visited an CHW  
gen fb_chw = 1 if q906H == 1 
replace fb_chw = 0 if fb_chw ==. & fb_case == 1 
lab var fb_chw "Sought care from CHW for fever"
lab val fb_chw yn
tab fb_chw survey, col 

*where sought care first
gen fb_firstcare = 11 if q908 == "A" | (q908 == "11" & q906A == 1) | (q906A == 1 & fb_provtot == 1)
replace fb_firstcare = 12 if q908 == "B" | (q908 == "12" & q906B == 1 )| (q906B == 1 & fb_provtot == 1)
replace fb_firstcare = 13 if q908 == "C" | (q908 == "13" & q906C == 1 ) | (q906C == 1 & fb_provtot == 1)
replace fb_firstcare = 14 if q908 == "D" | (q908 == "14" & q906D == 1 ) | (q906D == 1 & fb_provtot == 1)
replace fb_firstcare = 15 if q908 == "E" | (q908 == "16" & q906E == 1 ) | (q906E == 1 & fb_provtot == 1)
replace fb_firstcare = 16 if q908 == "F" | (q908 == "17" & q906F == 1 ) | (q906F == 1 & fb_provtot == 1)
replace fb_firstcare = 17 if q908 == "G" | (q908 == "18" & q906G == 1 ) | (q906G == 1 & fb_provtot == 1)
replace fb_firstcare = 18 if q908 == "H" | (q908 == "15" & q906H == 1 ) | (q906H == 1 & fb_provtot == 1)
replace fb_firstcare = 21 if q908 == "I" | (q908 == "21" & q906I == 1 ) | (q906I == 1 & fb_provtot == 1)
replace fb_firstcare = 22 if q908 == "J" | (q908 == "22" & q906J == 1 ) | (q906J == 1 & fb_provtot == 1)
replace fb_firstcare = 23 if q908 == "K" | (q908 == "23" & q906K == 1 ) | (q906K == 1 & fb_provtot == 1)
replace fb_firstcare = 26 if q908 == "L" | (q908 == "26" & q906L == 1 ) | (q906L == 1 & fb_provtot == 1)
replace fb_firstcare = 98 if q908 == "X" | (q908 == "98" & q906X == 1 ) | (q906X == 1 & fb_provtot == 1)

*Organize care-seeking responses by categories in the report template
egen fb_fcs_public = anymatch(fb_firstcare), values(11,12,13,14,16)
replace fb_fcs_public =. if q903 != 1
gen fb_fcs_private = 1 if fb_firstcare == 17
gen fb_fcs_chw = 1 if fb_firstcare == 18
gen fb_fcs_store = 1 if fb_firstcare == 22 | fb_firstcare == 23 
gen fb_fcs_trad = 1 if fb_firstcare == 21
gen fb_fcs_other = 1 if fb_firstcare == 26 | fb_firstcare == 98
gen fb_fcs_asc = 1 if fb_firstcare == 15

foreach x of varlist fb_fcs_private-fb_fcs_asc {
  replace `x' = 0 if `x' ==. & fb_provtot > 0 & fb_provtot != . & fb_case == 1
}

*visited an CHW as first (*or only*) source of care (INDICATOR 9A)
gen fb_chwfirst = .
replace fb_chwfirst = 0 if fb_case == 1
replace fb_chwfirst = 1 if fb_firstcare == 18
lab var fb_chwfirst "Sought care from CHW first"
lab val fb_chwfirst yn
tab fb_chwfirst survey, col

*visited an CHW as first (*or only*) source of care - among those who sought any care
gen fb_chwfirst_anycare = .
replace fb_chwfirst_anycare = 0 if q903 == 1  
replace fb_chwfirst_anycare = 1 if fb_firstcare == 18
lab var fb_chwfirst_anycare "Sought care from CHW first, among those who sought any care"
lab val fb_chwfirst_anycare yn
tab fb_chwfirst_anycare survey, col

*visited an asc as first (*or only*) source of care (INDICATOR 9A)
gen fb_ascfirst = .
replace fb_ascfirst = 0 if fb_case == 1
replace fb_ascfirst = 1 if fb_firstcare == 15
lab var fb_ascfirst "Sought care from asc first"
lab val fb_ascfirst yn
tab fb_ascfirst survey, col

*visited an asc as first (*or only*) source of care - among those who sought any care
gen fb_ascfirst_anycare = .
replace fb_ascfirst_anycare = 0 if q903 == 1  
replace fb_ascfirst_anycare = 1 if fb_firstcare == 15
lab var fb_ascfirst_anycare "Sought care from asc first, among those who sought any care"
lab val fb_ascfirst_anycare yn
tab fb_ascfirst_anycare survey, col

****reason(s) did not go to CHW for care (ENDLINE ONLY)
*Only gave one answer
tab q908b
replace q908b = "" if q908b == " "
gen q908ba = 1 if q908b == "A"
gen q908bb = 1 if q908b == "B"
gen q908bc = 1 if q908b == "C"
gen q908bd = 1 if q908b == "D"
gen q908be = 1 if q908b == "E"
gen q908bf = 1 if q908b == "F"
gen q908bg = 1 if q908b == "G"
gen q908bx = 1 if q908b == "X"
gen q908bz = 1 if q908b == "Z"

foreach var of varlist q908ba-q908bz {
  replace `var' = 0 if `var' == . & q908b != ""
  lab val `var' yn
  }

*assessed for fast breathing (INDICATOR 12) 
tab q909 survey
recode q909 98=8 2=0
lab val q909 yndk
recode q909 8=0, gen(fb_assessed)
replace fb_assessed = 0 if fb_assessed == . & fb_case == 1
replace fb_assessed =. if fb_case != 1
lab var fb_assessed "Assesed for fast breathing?"
lab val fb_assessed yn
tab fb_assessed survey, col

* where was the assessment done?  //Not in the Niger Survey 

* who performed the assessment?
tab q910 survey

replace q910 = "1" if q910 == "A" | strpos(q910, "A")
replace q910 = "2" if q910 == "2" | q910 == "B" | strpos(q910, "B")
replace q910 = "3" if q910 == "3" | q910 == "C" | strpos(q910, "C")
replace q910 = "4" if q910 == "4" | q910 == "D" | strpos(q910, "D")
replace q910 = "8" if q910 == "96" | q910 == "X" | strpos(q910, "X")
replace q910 = "9" if q910 == "98" | q910 == "Z" | strpos(q910, "Z")
replace q910 = "" if q910 == " "
destring q910, replace
lab val q910 who
tab q910 survey

*assessed for fast breathing by a CHW
gen fb_assessedchw = .
replace fb_assessedchw = 0 if fb_chw == 1
replace fb_assessedchw = 1 if fb_chw == 1 & q910 == 1
lab var fb_assessedchw "Assessed for fast breathing by CHW"
lab val fb_assessedchw yn
tab fb_assessedchw survey

*Child assessed for fast breathing by provider other than CHW, among those who sought care from other providers
gen fb_assessedoth = .
replace fb_assessedoth = 0 if (fb_provtot == 1 & fb_chw != 1) | (fb_provtot !=. & fb_provtot >= 2 )
replace fb_assessedoth = 1 if ((fb_provtot == 1 & fb_chw != 1) | (fb_provtot !=. & fb_provtot >= 2 )) & q910>1 & q910<9
replace fb_assessedoth = . if fb_assessed == 1 & q910 ==.
lab var fb_assessedoth "Child assessed for fast breathing by provider other than CHW"
lab val fb_assessedoth yn
tab fb_assessedoth survey, m

* received any treatment (INDICATOR 24, OPTIONAL)
tab q911 survey
recode q911 2=0 98=8
label val q911 yndk
*-5 records with q911 missing or no but q912 filled in, so changed q911 to YES
replace q911 = 1 if q911 != 1 & q912 !=""  
*-1 record missing location (q912) but q911 == YES

egen fb_rxany = anycount(q912A-q912J), values(1)
replace fb_rxany = 1 if fb_rxany > 0 & fb_rxany !=.
replace fb_rxany = . if fb_case != 1
lab var fb_rxany "Took any medication for fast breathing"
lab val fb_rxany yn
tab fb_rxany survey
*Many people didn't know what the child took for fast breathing so can't verify it was a medicine

* treated with first line antibiotics (INDICATOR 13D)  
gen fb_flab = 0 if fb_case == 1
replace fb_flab = 1 if q912E == 1 | q912F == 1 | q912G == 1
lab var fb_flab "Took first line antibiotic for fast breathing"
lab val fb_flab yn
tab fb_flab survey, col

* treated by CHW with first line antibiotics (INDICATOR 14D) 
gen fb_flabchw = 0 if fb_case == 1
replace fb_flabchw = 1 if fb_flab == 1 & q914 == 18 
replace fb_flabchw = . if fb_flab == 1 & q914 == .
lab var fb_flabchw "Got first line antibiotic for fast breathing from CHW"
lab val fb_flabchw yn
tab fb_flabchw survey, col

* treated with first line antibiotics by a CHW, among those who sought care from a CHW
gen fb_flabchw2 = .
replace fb_flabchw2 = 0 if fb_chw == 1
replace fb_flabchw2 = 1 if fb_flabchw == 1 & fb_chw == 1
lab var fb_flabchw2 "Got 1st line antibiotic from CHW, among those who sought care from CHW"
lab val fb_flabchw2 yn
tab fb_flabchw2 survey, col

* treated by asc with first line antibiotics (INDICATOR 14D) 
gen fb_flabasc = 0 if fb_case == 1
replace fb_flabasc = 1 if fb_flab == 1 & q914 == 15 
lab var fb_flabasc "Got first line antibiotic for fast breathing from ASC"
replace fb_flabasc = . if fb_flab == 1 & q914 == .
lab val fb_flabasc yn
tab fb_flabasc survey, col

* treated with first line antibiotics by a asc, among those who sought care from a asc
gen fb_flabasc2 = .
replace fb_flabasc2 = 0 if fb_cs_asc == 1
replace fb_flabasc2 = 1 if fb_flabasc == 1 & fb_cs_asc == 1
lab var fb_flabasc2 "Got 1st line antibiotic from asc, among those who sought care from asc"
lab val fb_flabasc2 yn
tab fb_flabasc2 survey, col

* treated with first line antibiotics by provider other than ASC and CHW (INDICATOR 14D) 
gen fb_flaboth = 0 if fb_case == 1
replace fb_flaboth = 1 if fb_flab == 1 & (q914 != 15 & q914 != 18)
replace fb_flaboth = . if fb_flab == 1 & q914 == .
lab var fb_flaboth "Got first line antibiotic for fast breathing from provider other than ASC and CHW"
lab val fb_flaboth yn
tab fb_flaboth survey, col

*Sought care from provider other than RCom and ASC
gen fb_careoth = 0 if fb_case == 1
replace fb_careoth = 1 if fb_provtot == 1 & fb_chw != 1 & fb_cs_asc != 1
replace fb_careoth = 1 if fb_provtot == 2 & (fb_chw != 1 | fb_cs_asc != 1)
replace fb_careoth = 1 if fb_provtot == 3
tab fb_careoth survey

* treated with first line antibiotics by provider other than ASC and CHW (INDICATOR 14D) 
gen fb_flaboth2 = 0 if fb_careoth == 1
replace fb_flaboth2 = 1 if fb_flaboth == 1 & fb_careoth == 1
replace fb_flaboth2 = . if fb_flab == 1 & q914 == .
lab var fb_flaboth2 "Got first line antibiotic for fast breathing from provider other than ASC and CHW"
lab val fb_flaboth2 yn
tab fb_flaboth2 survey, col

* treated with any antibiotic
gen fb_abany =.
replace fb_abany = 0 if fb_case == 1
replace fb_abany = 1 if q912E == 1 | q912F == 1 | q912G == 1 | q912H == 1
lab var fb_abany "Took antibiotic for fast breathing"
lab val fb_abany yn
tab fb_ab survey, col

* treated with any antibiotic among children who received any med (INDICATOR 25, OPTIONAL)
gen fb_ab =.
replace fb_ab = 0 if fb_rxany == 1
replace fb_ab = 1 if fb_abany == 1 & fb_rxany == 1
lab var fb_ab "Took antibiotic for fast breathing among children who received any med"
lab val fb_ab yn
tab fb_ab survey, col

*where did caregiver get antibiotic?  
tab q912 survey
foreach var of varlist q912A-q912Z {
  replace `var' = 0 if `var' == . & q912 !=""
}

*Where got firstline antibiotics
*Organize locations of treatment by categories in the report template
egen fb_flab_public = anymatch(q914), values(11,12,13,14,16)
replace fb_flab_public =. if fb_flab != 1
gen fb_flab_private = 1 if q914 == 17 & fb_flab == 1
gen fb_flab_chw = 1 if q914 == 18 & fb_flab == 1
gen fb_flab_store = 1 if (q914 == 22 | q914 == 23) & fb_flab == 1 
gen fb_flab_trad = 1 if q914 == 21 & fb_flab == 1
gen fb_flab_other = 1 if (q914 == 26 | q914 == 98) & fb_flab == 1
gen fb_flab_asc = 1 if q914 == 15 & fb_flab == 1

foreach x of varlist fb_flab_private-fb_flab_asc {
  replace `x' = 0 if `x' == . & fb_flab == 1
}


*if from CHW, did child take antibiotic in presence of CHW? (INDICATOR 15C)  
*1 response missing
tab q916 survey
recode q916 2=0 98=8
lab val q916 yndk
recode q916 8=0, gen(fb_flab_chwp)
replace fb_flab_chwp = . if fb_flabchw != 1 | (fb_flabchw == 1 & fb_flab_chwp ==.)
lab var fb_flab_chwp "Child took antibiotic in presence of CHW?"
lab val fb_flab_chwp yn
tab fb_flab_chwp survey

*if from CHW, did caregiver get counseled on how to give antibiotic at home? (INDICATOR 16C)
tab q917 survey
recode q917 2=0 98=8
lab val q917 yndk
recode q917 8=0, gen(fb_flab_chwc)
replace fb_flab_chwc = . if fb_flabchw != 1 | (fb_flabchw == 1 & fb_flab_chwp ==.)
lab var fb_flab_chwc "Caregiver was counseled on how to give antibiotics at home?"
lab val fb_flab_chwc yn
tab fb_flab_chwc survey

*if CHW visited, was available at first visit
****Missing a lot of responses
tab q919 survey
recode q919 2=0  
lab val q919 yndk
recode q919 8=0, gen(fb_chwavail)
replace fb_chwavail =. if fb_chw != 1
lab var fb_chwavail "CHW was available at first visit?"
lab val fb_chwavail yn
tab fb_chwavail survey

*if CHW visited, did CHW refer the child to a health center?
tab q920 survey
recode q920 2=0 
lab val q920 yndk
recode q920 8=0, gen(fb_chwrefer)
replace fb_chwrefer =. if fb_chw != 1
lab var fb_chwrefer "CHW refered child to health center?"
lab val fb_chwrefer yn
tab fb_chwrefer survey

***completed CHW referral (INDICATOR 17C)
tab q921 survey
recode q921 2=0
lab val q921 yn
clonevar fb_referadhere = q921
lab var fb_referadhere "Completed CHW referral?"
lab val fb_referadhere yn
tab fb_referadhere survey

***reason did not comply with CHW referral
tab q922 
tab q922 if fb_referadhere == 0
replace q922 = "" if q922 == " " | q922 == "."
gen q922a = 1 if strpos(q922,"A") & fb_referadhere == 0
gen q922b = 1 if strpos(q922,"B") & fb_referadhere == 0
gen q922c = 1 if strpos(q922,"C") & fb_referadhere == 0
gen q922d = 1 if strpos(q922,"D") & fb_referadhere == 0
gen q922e = 1 if strpos(q922,"E") & fb_referadhere == 0
gen q922f = 1 if strpos(q922,"F") & fb_referadhere == 0
gen q922g = 1 if strpos(q922,"G") & fb_referadhere == 0
gen q922h = 1 if strpos(q922,"H") & fb_referadhere == 0
gen q922x = 1 if strpos(q922,"X") & fb_referadhere == 0
gen q922z = 1 if strpos(q922,"Z") & fb_referadhere == 0

foreach var of varlist q922a-q922z {
  replace `var' = 0 if `var' == . & fb_referadhere == 0
}


***CHW follow-up (INDICATOR 18C)
tab q923 survey
recode q923 2=0
lab val q923 yn
clonevar fb_chw_fu = q923
replace fb_chw_fu = . if fb_chw != 1
lab var fb_chw_fu "CHW followed up sick child"
lab val fb_chw_fu yn
tab fb_chw_fu survey, col

***when was CHW follow-up
tab q924 survey
recode q924 7=8
tab q924 survey, col
recode q924 7 8=., gen(fb_when_fu)
replace fb_when_fu =. if fb_chw_fu != 1
tab fb_when_fu survey, col

save "illness_analysis.dta", replace

********************************************************************************
********************************************************************************
*Key indicators, across all three illnesses

*care-seeking from an appropriate provider, all 3 illnesses
gen all_app_prov = 0
replace all_app_prov = 1 if (d_case == 1 & d_app_prov == 1) | (f_case == 1 & f_app_prov == 1) | (fb_case == 1 & fb_app_prov == 1)

*CHW first source of care, all 3 illnesses
gen all_chwfirst = 0
replace all_chwfirst = 1 if (d_case == 1 & d_chwfirst == 1) | (f_case == 1 & f_chwfirst == 1) | (fb_case == 1 & fb_chwfirst == 1)

*Correct treatment, all 3 illnesses
gen all_correct_rx = 0 if d_case == 1 | (f_case == 1 & f_result == 1) | fb_case == 1
replace all_correct_rx = 1 if (d_case == 1 & d_orszinc == 1) | (f_case == 1 & f_actc24 == 1) | (fb_case == 1 & fb_flab == 1)

*Correct treatment from a CHW, all 3 illnesses
gen all_correct_rxchw = 0 if d_orszincchw !=. | f_actc24chw !=. | fb_flabchw !=.
replace all_correct_rxchw = 1 if (d_case == 1 & d_orszincchw == 1) | (f_case == 1 & f_actc24chw == 1) | (fb_case == 1 & fb_flabchw == 1)

*Received 1st dose treatment in front of CHW, all 3 illnesses (diarrhea includes cases in which child got both ORS and zinc)
gen all_firstdose = .
replace all_firstdose = 0 if (d_bothfirstdose !=. & d_case == 1 ) | (f_act_chwp !=. & f_case == 1) | (fb_flab_chwp !=. & fb_case == 1)
replace all_firstdose = 1 if (d_case == 1 & d_bothfirstdose == 1) | (f_case == 1 & f_act_chwp == 1) | (fb_case == 1 & fb_flab_chwp ==1)

*Received counseling on treatment administration from CHW, all 3 illnesses
gen all_counsel = .
replace all_counsel = 0 if (d_bothcounsel !=. & d_case == 1 ) | (f_act_chwc !=. & f_case == 1) | (fb_flab_chwc !=. & fb_case == 1)
replace all_counsel = 1 if (d_case == 1 & d_bothcounsel == 1) | (f_case == 1 & f_act_chwc == 1) | (fb_case == 1 & fb_flab_chwc ==1)

*Referred by CHW, all 3 illnesses
gen all_chwrefer = .
replace all_chwrefer = 0 if (d_chwrefer!=. & d_case == 1 ) | (f_chwrefer !=. & f_case == 1) | (fb_chwrefer !=. & fb_case == 1)
replace all_chwrefer = 1 if (d_case == 1 & d_chwrefer == 1) | (f_case == 1 & f_chwrefer == 1) | (fb_case ==1 & fb_chwrefer == 1)

*Adhered to referral advice from CHW, all 3 illnesses
gen all_referadhere = .
replace all_referadhere = 0 if (d_referadhere!=. & d_case == 1 ) | (f_referadhere !=. & f_case == 1) | (fb_referadhere !=. & fb_case == 1)
replace all_referadhere = 1 if (d_case == 1 & d_referadhere == 1) | (f_case == 1 & f_referadhere == 1) | (fb_case ==1 & fb_referadhere == 1)

*Received a follow-up visit from a CHW, all 3 illnesses
gen all_followup = .
replace all_followup = 0 if (d_chw_fu != . & d_case == 1 ) | (f_chw_fu !=. & f_case == 1) | (fb_chw_fu !=. & fb_case == 1)
replace all_followup = 1 if (d_case == 1 & d_chw_fu == 1) | (f_case == 1 & f_chw_fu == 1) | (fb_case == 1 & fb_chw_fu == 1)

*decided to seek care jointly from an appropriate provider, all 3 illnesses
gen all_app_joint = .
replace all_app_joint = 0 if (d_case == 1 & d_app_joint !=.) | (f_case == 1 & f_app_joint !=.) | (fb_case == 1 & fb_app_joint !=.)
replace all_app_joint = 1 if (d_case == 1 & d_app_joint == 1) | (f_case == 1 & f_app_joint == 1) | (fb_case == 1 & fb_app_joint == 1)

*decided to seek care jointly, all 3 illnesses
gen all_joint = .
replace all_joint = 0 if (d_case == 1 & d_joint !=.) | (f_case == 1 & f_joint !=.) | (fb_case == 1 & fb_joint !=.) 
replace all_joint = 1 if (d_case == 1 & d_joint == 1) | (f_case == 1 & f_joint == 1) | (fb_case == 1 & fb_joint == 1)

*did not seek care, all 3 illnesses
gen all_nocare = 0
replace all_nocare = 1 if (d_nocare == 1 & d_case == 1) | (f_nocare == 1 & f_case == 1) | (fb_nocare == 1 & fb_case == 1)

*sought care but not from a CHW, all 3 illnesses
gen all_nocarechw = .
replace all_nocarechw = 0 if (d_nocarechw !=. & d_case == 1) | (f_nocarechw !=. & f_case == 1) | (fb_nocarechw !=. & fb_case == 1)
replace all_nocarechw = 1 if (d_nocarechw == 1 & d_case == 1) | (f_nocarechw == 1 & f_case == 1) | (fb_nocarechw == 1 & fb_case == 1)

*where sought care first, all 3 illnesses
gen all_firstcare = .
replace all_firstcare = d_firstcare if d_case == 1
replace all_firstcare = f_firstcare if f_case == 1
replace all_firstcare = fb_firstcare if fb_case == 1

*sources of care, all 3 illnesses
gen all_cs_public = .
replace all_cs_public = 0 if q703 == 1 | q803 == 1 | q903 == 1
replace all_cs_public = 1 if d_cs_public == 1 | f_cs_public == 1 | fb_cs_public == 1

gen all_cs_private = .
replace all_cs_private = 0 if q703 == 1 | q803 == 1 | q903 == 1
replace all_cs_private = 1 if d_cs_private == 1 | f_cs_private == 1 | fb_cs_private == 1

gen all_cs_chw = .
replace all_cs_chw = 0 if q703 == 1 | q803 == 1 | q903 == 1
replace all_cs_chw = 1 if d_cs_chw == 1 | f_cs_chw == 1 | fb_cs_chw == 1

gen all_cs_store = .
replace all_cs_store = 0 if q703 == 1 | q803 == 1 | q903 == 1
replace all_cs_store = 1 if d_cs_store == 1 | f_cs_store == 1 | fb_cs_store == 1

gen all_cs_trad = .
replace all_cs_trad = 0 if q703 == 1 | q803 == 1 | q903 == 1
replace all_cs_trad = 1 if d_cs_trad == 1 | f_cs_trad == 1 | fb_cs_trad == 1

gen all_cs_other = .
replace all_cs_other = 0 if q703 == 1 | q803 == 1 | q903 == 1
replace all_cs_other = 1 if d_cs_other == 1 | f_cs_other == 1 | fb_cs_other == 1

gen all_cs_asc = .
replace all_cs_asc = 0 if q703 == 1 | q803 == 1 | q903 == 1
replace all_cs_asc = 1 if d_cs_asc == 1 | f_cs_asc == 1 | fb_cs_asc == 1

*first source of care, all 3 illnesses
gen all_fcs_public = .
replace all_fcs_public = 0 if q703 == 1 | q803 == 1 | q903 == 1
replace all_fcs_public = 1 if d_fcs_public == 1 | f_fcs_public == 1 | fb_fcs_public == 1

gen all_fcs_private = .
replace all_fcs_private = 0 if q703 == 1 | q803 == 1 | q903 == 1
replace all_fcs_private = 1 if d_fcs_private == 1 | f_fcs_private == 1 | fb_fcs_private == 1

gen all_fcs_chw = .
replace all_fcs_chw = 0 if q703 == 1 | q803 == 1 | q903 == 1
replace all_fcs_chw = 1 if d_fcs_chw == 1 | f_fcs_chw == 1 | fb_fcs_chw == 1

gen all_fcs_store = .
replace all_fcs_store = 0 if q703 == 1 | q803 == 1 | q903 == 1
replace all_fcs_store = 1 if d_fcs_store == 1 | f_fcs_store == 1 | fb_fcs_store == 1

gen all_fcs_trad = .
replace all_fcs_trad = 0 if q703 == 1 | q803 == 1 | q903 == 1
replace all_fcs_trad = 1 if d_fcs_trad == 1 | f_fcs_trad == 1 | fb_fcs_trad == 1

gen all_fcs_other = .
replace all_fcs_other = 0 if q703 == 1 | q803 == 1 | q903 == 1
replace all_fcs_other = 1 if d_fcs_other == 1 | f_fcs_other == 1 | fb_fcs_other == 1

gen all_fcs_asc = .
replace all_fcs_asc = 0 if q703 == 1 | q803 == 1 | q903 == 1
replace all_fcs_asc = 1 if d_fcs_asc == 1 | f_fcs_asc == 1 | fb_fcs_asc == 1

*source of treatment, all 3 illnesses
gen all_rx_public = .
replace all_rx_public = 0 if d_ors == 1 | d_zinc == 1 | f_act == 1 | fb_flab == 1
replace all_rx_public = 1 if d_ors_public == 1 | d_zinc_public == 1 | f_act_public == 1 | fb_flab_public == 1

gen all_rx_private = .
replace all_rx_private = 0 if d_ors == 1 | d_zinc == 1 | f_act == 1 | fb_flab == 1
replace all_rx_private = 1 if d_ors_private == 1 | d_zinc_private == 1 | f_act_private == 1 | fb_flab_private == 1

gen all_rx_chw = .
replace all_rx_chw = 0 if d_ors == 1 | d_zinc == 1 | f_act == 1 | fb_flab == 1
replace all_rx_chw = 1 if d_ors_chw == 1 | d_zinc_chw == 1 | f_act_chw == 1 | fb_flab_chw == 1

gen all_rx_store = .
replace all_rx_store = 0 if d_ors == 1 | d_zinc == 1 | f_act == 1 | fb_flab == 1
replace all_rx_store = 1 if d_ors_store == 1 | d_zinc_store == 1 | f_act_store == 1 | fb_flab_store == 1

gen all_rx_trad = .
replace all_rx_trad = 0 if d_ors == 1 | d_zinc == 1 | f_act == 1 | fb_flab == 1
replace all_rx_trad = 1 if d_ors_trad == 1 | d_zinc_trad == 1 | f_act_trad == 1 | fb_flab_trad == 1

gen all_rx_other = .
replace all_rx_other = 0 if d_ors == 1 | d_zinc == 1 | f_act == 1 | fb_flab == 1
replace all_rx_other = 1 if d_ors_other == 1 | d_zinc_other == 1 | f_act_other == 1 | fb_flab_other == 1

gen all_rx_asc = .
replace all_rx_asc = 0 if d_ors == 1 | d_zinc == 1 | f_act == 1 | fb_flab == 1
replace all_rx_asc = 1 if d_ors_asc == 1 | d_zinc_asc == 1 | f_act_asc == 1 | fb_flab_asc == 1

*reasons for not seeking care, endline only
gen all_nocare_a = .
replace all_nocare_a = 1 if q708ca == 1 | q828a == 1 | q924aa == 1
replace all_nocare_a = 0 if all_nocare_a == . & survey == 2 & ( q703 == 0 | q803 == 0 | q903 == 0)

gen all_nocare_b = .
replace all_nocare_b = 1 if q708cb == 1 | q828b == 1 | q924ab == 1
replace all_nocare_b = 0 if all_nocare_b == . & survey == 2 & ( q703 == 0 | q803 == 0 | q903 == 0)

gen all_nocare_c = .
replace all_nocare_c = 1 if q708cc == 1 | q828c == 1 | q924ac == 1
replace all_nocare_c = 0 if all_nocare_c == . & survey == 2 & ( q703 == 0 | q803 == 0 | q903 == 0)

gen all_nocare_d = .
replace all_nocare_d = 1 if q708cd == 1 | q828d == 1 | q924ad == 1
replace all_nocare_d = 0 if all_nocare_d == . & survey == 2 & ( q703 == 0 | q803 == 0 | q903 == 0)

gen all_nocare_e = .
replace all_nocare_e = 1 if q708ce == 1 | q828e == 1 | q924ae == 1
replace all_nocare_e = 0 if all_nocare_e == . & survey == 2 & ( q703 == 0 | q803 == 0 | q903 == 0)

gen all_nocare_f = .
replace all_nocare_f = 1 if q708cf == 1 | q828f == 1 | q924af == 1
replace all_nocare_f = 0 if all_nocare_f == . & survey == 2 & ( q703 == 0 | q803 == 0 | q903 == 0)

gen all_nocare_g = .
replace all_nocare_g = 1 if q708cg == 1 | q828g == 1 | q924ag == 1
replace all_nocare_g = 0 if all_nocare_g == . & survey == 2 & ( q703 == 0 | q803 == 0 | q903 == 0)

gen all_nocare_x = .
replace all_nocare_x = 1 if q708cx == 1 | q828x == 1 | q924ax == 1
replace all_nocare_x = 0 if all_nocare_x == . & survey == 2 & ( q703 == 0 | q803 == 0 | q903 == 0)

gen all_nocare_z = .
replace all_nocare_z = 1 if q708cz == 1 | q828z == 1 | q924az == 1
replace all_nocare_z = 0 if all_nocare_z == . & survey == 2 & ( q703 == 0 | q803 == 0 | q903 == 0)

*reasons for not seeking care from a CHW among those who sought care, endline only
gen all_nocarechw_a = .
replace all_nocarechw_a = 0 if survey == 2 & (d_nocarechw == 1 & f_nocarechw == 1 & fb_nocarechw == 1)
replace all_nocarechw_a = 1 if q708ba == 1 | q808bA == 1 | q908ba == 1

gen all_nocarechw_b = .
replace all_nocarechw_b = 1 if q708bb == 1 | q808bB == 1 | q908bb == 1
replace all_nocarechw_b = 0 if all_nocarechw_b == . & survey == 2 & (d_nocarechw == 1 & f_nocarechw == 1 & fb_nocarechw == 1)

gen all_nocarechw_c = .
replace all_nocarechw_c = 1 if q708bc == 1 | q808bC == 1 | q908bc == 1
replace all_nocarechw_c = 0 if all_nocarechw_c == . & survey == 2 & (d_nocarechw == 1 & f_nocarechw == 1 & fb_nocarechw == 1)

gen all_nocarechw_d = .
replace all_nocarechw_d = 1 if q708bd == 1 | q808bD == 1 | q908bd == 1
replace all_nocarechw_d = 0 if all_nocarechw_d == . & survey == 2 & (d_nocarechw == 1 & f_nocarechw == 1 & fb_nocarechw == 1)

gen all_nocarechw_e = .
replace all_nocarechw_e = 1 if q708be == 1 | q808bE == 1 | q908be == 1
replace all_nocarechw_e = 0 if all_nocarechw_e == . & survey == 2 & (d_nocarechw == 1 & f_nocarechw == 1 & fb_nocarechw == 1)

gen all_nocarechw_f = .
replace all_nocarechw_f = 1 if q708bf == 1 | q808bF == 1 | q908bf == 1
replace all_nocarechw_f = 0 if all_nocarechw_f == . & survey == 2 & (d_nocarechw == 1 & f_nocarechw == 1 & fb_nocarechw == 1)

gen all_nocarechw_x = .
replace all_nocarechw_x = 1 if q708bx == 1 | q808bX == 1 | q908bx == 1
replace all_nocarechw_x = 0 if all_nocarechw_x == . & survey == 2 & (d_nocarechw == 1 & f_nocarechw == 1 & fb_nocarechw == 1)

gen all_nocarechw_z = .
replace all_nocarechw_z = 1 if q708bz == 1 | q808bZ == 1 | q908bz == 1
replace all_nocarechw_z = 0 if all_nocarechw_z == . & survey == 2 & (d_nocarechw == 1 & f_nocarechw == 1 & fb_nocarechw == 1)

*reasons for not complying with CHW referral
gen all_noadhere_a = .
replace all_noadhere_a = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_a = 1 if q727a == 1 | q825a == 1 | q922a == 1

gen all_noadhere_b = .
replace all_noadhere_b = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_b = 1 if q727b == 1 | q825b == 1 | q922b == 1

gen all_noadhere_c = .
replace all_noadhere_c = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_c = 1 if q727c == 1 | q825c == 1 | q922c == 1

gen all_noadhere_d = .
replace all_noadhere_d = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_d = 1 if q727d == 1 | q825d == 1 | q922d == 1

gen all_noadhere_e = .
replace all_noadhere_e = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_e = 1 if q727e == 1 | q825e == 1 | q922e == 1

gen all_noadhere_f = .
replace all_noadhere_f = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_f = 1 if q727f == 1 | q825f == 1 | q922f == 1

gen all_noadhere_g = .
replace all_noadhere_g = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_g = 1 if q727g == 1 | q825g == 1 | q922g == 1

gen all_noadhere_h = .
replace all_noadhere_h = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_h = 1 if q727h == 1 | q825h == 1 | q922h == 1

gen all_noadhere_x = .
replace all_noadhere_x = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_x = 1 if q727x == 1 | q825x == 1 | q922x == 1

gen all_noadhere_z = .
replace all_noadhere_z = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_z = 1 if q727z == 1 | q825z == 1 | q922z == 1

*When was CHW follow-up?, all three illnesses
gen all_when_fu = .
replace all_when_fu = d_when_fu if d_case == 1
replace all_when_fu = f_when_fu if f_case == 1
replace all_when_fu = fb_when_fu if fb_case == 1

*CHW first source of care, all 3 illnesses
gen all_chwfirst_anycare =.
replace all_chwfirst_anycare = 0 if q703 == 1 | q803 == 1 | q903 == 1
replace all_chwfirst_anycare = 1 if (d_case == 1 & d_chwfirst_anycare == 1) | (f_case == 1 & f_chwfirst_anycare == 1) | (fb_case == 1 & fb_chwfirst_anycare == 1)

*Continued fluids, all 3 illnesses
gen all_cont_fluids = 0
replace all_cont_fluids = 1 if (d_case == 1 & d_cont_fluids == 1) | (f_case == 1 & f_cont_fluids == 1) | (fb_case == 1 & fb_cont_fluids == 1)
replace all_cont_fluids =. if (d_case == 1 & d_cont_fluids == .) | (f_case == 1 & f_cont_fluids == .) | (fb_case == 1 & fb_cont_fluids == .)

*Continued feeding, all 3 illnesses
gen all_cont_feed = 0
replace all_cont_feed = 1 if (d_case == 1 & d_cont_feed == 1) | (f_case == 1 & f_cont_feed == 1) | (fb_case ==1 & fb_cont_feed == 1)
replace all_cont_feed =. if (d_case == 1 & d_cont_feed == .) | (f_case == 1 & f_cont_feed == .) | (fb_case == 1 & fb_cont_feed == .)

foreach x of varlist all* {
  tab `x' survey, col
}

* appropriate treatment, all 3 illnesses, among those who sought care from a CHW
gen all_correct_rxchw2 = .
replace all_correct_rxchw2 = 0 if (d_case == 1 & d_chw == 1) | (f_case == 1 & f_actc24chw2 !=.) | (fb_case == 1 & fb_chw == 1)
replace all_correct_rxchw2 = 1 if (d_case == 1 & d_orszincchw2 ==1) | (f_case == 1 & f_actc24chw2 ==1) | (fb_case == 1 & fb_flabchw2 ==1)

* appropriate treatment, all 3 illnesses, among those who sought care from a asc
gen all_correct_rxasc2 = .
replace all_correct_rxasc2 = 0 if (d_case == 1 & d_cs_asc == 1) | (f_case == 1 & f_actc24asc2 !=.) | (fb_case == 1 & fb_cs_asc == 1)
replace all_correct_rxasc2 = 1 if (d_case == 1 & d_orszincasc2 ==1) | (f_case == 1 & f_actc24asc2 ==1) | (fb_case == 1 & fb_flabasc2 ==1)

*Correct treatment from ASC, all 3 illnesses
gen all_correct_rxasc = 0 if d_orszincasc !=. | f_actc24asc !=. | fb_flabasc !=.
replace all_correct_rxasc = 1 if (d_case == 1 & d_orszincasc == 1) | (f_case == 1 & f_actc24asc == 1) | (fb_case == 1 & fb_flabasc == 1)

*Correct treatment from a provder other than CHW, all 3 illnesses
gen all_correct_rxoth = 0 if d_orszincoth !=. | f_actc24oth !=. | fb_flaboth !=.
replace all_correct_rxoth = 1 if (d_case == 1 & d_orszincoth == 1) | (f_case == 1 & f_actc24oth == 1) | (fb_case == 1 & fb_flaboth == 1)

* appropriate treatment from other provider, all 3 illnesses, among those who sought care from provider other than RCom or ASC
gen all_correct_rxoth2 = .
replace all_correct_rxoth2 = 0 if (d_case == 1 & d_orszincoth2 !=.) | (f_case == 1 & f_actc24oth2 !=.) | (fb_case == 1 & fb_flaboth2 !=.)
replace all_correct_rxoth2 = 1 if (d_case == 1 & d_orszincoth2 ==1) | (f_case == 1 & f_actc24oth2 ==1) | (fb_case == 1 & fb_flaboth2 ==1)


*asc first source of care, all 3 illnesses
gen all_ascfirst = 0
replace all_ascfirst = 1 if (d_case == 1 & d_ascfirst == 1) | (f_case == 1 & f_ascfirst == 1) | (fb_case == 1 & fb_ascfirst == 1)

*asc first source of care, all 3 illnesses
gen all_ascfirst_anycare =.
replace all_ascfirst_anycare = 0 if q703 == 1 | q803 == 1 | q903 == 1
replace all_ascfirst_anycare = 1 if (d_case == 1 & d_ascfirst_anycare == 1) | (f_case == 1 & f_ascfirst_anycare == 1) | (fb_case == 1 & fb_ascfirst_anycare == 1)

save "illness_analysis", replace



********************************************************************************
********************************************************************************

*Key endline indicators, disaggregated by sex
********DIARRHEA
*Sought any care
tab q703 q103 if survey == 2, col

*Sought care from an appropriate provider
tab d_app_prov q103 if survey == 2, col

*Sought care from a CHW
tab d_chw q103 if survey == 2, col

*CHW was first source of care
tab d_chwfirst q103 if survey == 2, col

*Same or more to drink
tab d_cont_fluids q103 if survey == 2, col

*Took ORS
tab d_ors q103 if survey == 2, col

*Took zinc
tab d_zinc q103 if survey == 2, col

*Took homemade fluid
tab d_hmfl q103 if survey == 2, col

*Took ORS and zinc
tab d_orszinc q103 if survey == 2, col

********FEVER
*Sought any care
tab q803 q103 if survey == 2, col

*Sought care from an appropriate provider
tab f_app_prov q103 if survey == 2, col

*Sought care from a CHW
tab f_chw q103 if survey == 2, col

*CHW was first source of care
tab f_chwfirst q103 if survey == 2, col

*Had blood drawn
tab f_bloodtaken q103 if survey == 2, col

*Got test results
tab f_gotresult q103 if survey == 2, col

*Test results positive
tab f_result q103 if survey == 2, col

*Any antimalarial, among all fever cases
tab f_antim q103 if survey == 2, col

*ACT, among all fever cases
tab f_act q103 if survey == 2, col

*ACT within 24 hours, among all fever cases
tab f_act24 q103 if survey == 2, col

*Any antimalarial, among confirmed malaria cases
tab f_antimc q103 if survey == 2, col

*ACT, among confirmed malaria cases
tab f_actc q103 if survey == 2, col

*ACT within 24 hours, among confirmed malaria cases
tab f_actc24 q103 if survey == 2, col

*******FAST BREATHING
*Sought any care
tab q903 q103 if survey == 2, col

*Sought care from an appropriate provider
tab fb_app_prov q103 if survey == 2, col

*Sought care from a CHW
tab fb_chw q103 if survey == 2, col

*CHW was first source of care
tab fb_chwfirst q103 if survey == 2, col

*Had breathing assessed
tab fb_assessed q103 if survey == 2, col

*Took any antibiotic
tab fb_abany q103 if survey == 2, col

*Took firstline antibiotic
tab fb_flab q103 if survey == 2, col

gen child_sex = 1 if q103 == 1 | q103 == 1 | q103 == 1
replace child_sex = 2 if q103 == 2 | q103 == 2 | q103 == 2
lab val child_sex sex

save "illness_analysis", replace


*Age of sick children included in survey
tab q104 survey, m
*-Missing 68 values at BL, 1 at EL

recode q104 0/11 = 1 12/23 = 2 24/35 = 3 36/47=4 48/59 = 5, gen(agecat)
lab var agecat "Child's age by year"
lab def age_cat 1 "0-11 months" 2 "12-23 months" 3 "24-35 months" 4 "36-47 months" 5 "48-59 months"
lab val agecat age_cat
tab agecat survey

*Sex of sick children included in survey
tab q103 survey, m

*Two week history of illness among sick children included in survey
foreach x of varlist q105 q106 q107 q108 {
  recode `x' 2=0
  lab val `x' yn
}

replace q108 = 0 if q108 ==. & q107 == 0

gen no_illness = q105 + q106 + q108
tab no_illness
*13 cases were listed as having no illness: 1 at BL, 12 at EL

by survey: sum no_illness

save "illness_analysis", replace

sort survey codevil nummen child_number
collapse (firstnm) q103 q104 q105 q106 q107 q108, by (survey codevil nummen child_number)

tab q103 survey, m

recode q104 0/11 = 1 12/23 = 2 24/35 = 3 36/47=4 48/59 = 5, gen(agecat)
lab var agecat "Child's age by year"
lab def age_cat 1 "0-11 months" 2 "12-23 months" 3 "24-35 months" 4 "36-47 months" 5 "48-59 months", modify
lab val agecat age_cat
tab agecat survey

tab q105 survey, m
tab q106 survey, m
tab q108 survey, m

save "child_chars", replace


*************************************************************
/* All indicators were calculated using the following code:
svyset cluster

svy: tab `x' survey, col ci pear obs
or
svy: prop `x', over(survey)
svy: tab survey `x', col pear
*/
*************************************************************
