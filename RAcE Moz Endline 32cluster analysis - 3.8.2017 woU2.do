***********************************
* MOZ ENDLINE HH SURVEY ANALYSIS **
* By: Kirsten Zalisk              *
* February 2017                   *
***********************************

clear all

cd "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Mozambique\Final Data\Moz RAcE Data analysis\Combined"

set more off

use "illness_master 3.8.2017.dta", clear
drop if survey == 1

*Create a value label for binary variables that are recoded 0/1
lab define yn 0 "No" 1 "Yes", modify

*replace cluster = numconglomerado if survey == 2
svyset cluster

****************MODULE 1: Sick child information********************************
*Sex, age and 2-week history of illness of selected children
***Child's age
tab p104d
tab p104f
tab p104c

recode p104d 98 2012 = .
recode p104f 98 2013 = .
recode p104c 98 2011 -2 = .

tab p104d, m
tab p104f, m
tab p104c, m

gen child_age = p104d
replace child_age = p104f if child_age ==.
replace child_age = p104c if child_age ==.

recode child_age 0/11 = 1 12/23 = 2 24/35 = 3 36/47=4 48/59 = 5, gen(agecat)
lab var agecat "Child's age by year"
lab def age_cat 1 "0-11 months" 2 "12-23 months" 3 "24-35 months" 4 "36-47 months" 5 "48-59 months"
lab val agecat age_cat
*Age of 64 children missing
tab agecat, m

***Sex by illness, survey
recode p103d 0=2	
recode p103f 0=2
recode p103c 0=2

lab def sex 0 "" 1 "Male" 2 "Female", modify
lab val p103d sex
lab val p103f sex
lab val p103c sex

tab p103d
tab p103f
tab p103c

gen child_sex = p103d
replace child_sex = p103f if child_sex ==.
replace child_sex = p103c if child_sex ==.
lab val child_sex sex
tab child_sex, m
*Sex of 5 children missing

*Tab number of children with each illness by survey
tab d_case 
tab f_case
tab c_case

cd "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Mozambique\Final Data\Moz RAcE Data analysis\Endline32"
save "illness_analysis32", replace

****************MODULE 2: Caregivers' information*******************************

cd "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Mozambique\Final Data\Moz RAcE Data analysis\Combined"
use "caregiver_combined 3.8.2017.dta", clear
drop if survey == 1
svyset cluster
*Calculate total number of cargeivers included in the survey
count 

*Caregivers' age
*Be sure to check for outliers and missing values
tab p203
recode p203 0 98 = .
sum p203
*hist p203 
recode p203 min/24=1 25/34=2 35/44=3 45/67=4,gen(cagecat)
lab var cagecat "Caregiver's age category"
lab define cagecat 1 "15-24" 2 "25-34" 3 "35-44" 4 "45+"
lab values cagecat cagecat
tab cagecat, m
* Missing age for 106 caregivers

*Caregivers' education
tab p204
tab p205
tab p206
gen cgeduccat = 0 if p204 == 0
replace cgeduccat=1 if p205==1 & p206<5
replace cgeduccat = 2 if p205==1 & p206>=5 & p206!=.
replace cgeduccat = 3 if p205==2 | p205==3
lab var cgeduccat "Caregiver's highest level of education"
lab define educ 0 "No school" 1 "Primary < class 5" 2 "Primary >= class 5" 3 "Secondary or higher", modify
lab val cgeduccat educ
lab var cgeduccat "Caregiver's education (categorical)"
tab cgeduccat, m
*Missing education information for 6 caregivers

*Caregivers' marital status (3 categories)
tab p401, m

*Recode marital status to be binary
recode p401 1 2=1 3=0, gen(union)
lab val union yn
lab var union "Cargeiver is married or living with partner"
tab union, m
*Missing relationship status for 5 caregivers

cd "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Mozambique\Final Data\Moz RAcE Data analysis\Endline32"
save "caregiver_analysis32", replace
****************MODULE 5: Health center access**********************************
*caregiver access to nearest facility*
sort survey
tab p501 survey, m
by survey:sum p501
recode p501 95 995 998 = 98
recode p501 min/7=1 8/25=2 26/95=3 98=4,gen(distcat)
lab var distcat "Distance to nearest health center"
lab define distance 1 "<8 km" 2 "8-25 km" 3 "> 25 km" 4 "Don't know", modify
lab values distcat distance
tab distcat survey, m
*svy: tab distcat survey, col ci pear
svy: mean p501 if p501 !=98, over(survey)
svy: regress p501 survey if p501 != 98
*4 responses missing

*caregiver's mode of transport  
tab p502, m
recode p502 2=1 3 4 5=2 6=3 1=.,gen(transport)
lab def trans 1 "Walk" 2 "Motorbike/Bus/Taxi" 3 "Other"
lab val transport trans
tab transport,m
*16 responses missing: 4 missing module, 12 don't go to facility

*caregiver's time to travel to nearest facility*
sum p503
tab p503, m
*hist q503
recode p503 min/29=1 30/59=2 60/119=3 120/179=4 180/460=5 998=6,gen(timecat)
lab var timecat "Time to reach nearest health center"
lab def timecat 1 "<30 minutes" 2 "30-59 minutes" 3 "1 - <2 hours" 4 "2 - <3 hours" 5 "3+ hours" 6 "Don't know", modify
lab val timecat timecat
tab timecat,m
svy: mean p501 if p503 !=998
*16 responses missing: 4 missing module, 12 don't go to facility

****************MODULE 4: Household decision making*****************************

*Caregiver living with partner  
tab p402,m
recode p402 2=0
label var p402 "Living with Partner"
lab val p402 yn
tab p402, m

*Income decision maker (INDICATOR 19, OPTIONAL) 
tab p403
recode p403 6 = 4,gen(dm_income)
lab var dm_income "Who Makes the Decisions About HH Income?"
lab def dm_income 1 "Respondent" 2 "Husband/Partner" 3 "Husband/Partner Jointly" 4 "Other", modify
lab val dm_income dm_income
tab dm_income

recode dm_income 1 2 4=0 3=1, gen(dm_income_joint)
lab var dm_income_joint "Caregiver & partner decide jointly about HH income"
lab val dm_income_joint yn
tab dm_income_joint

*Health care decision maker (INDICATOR 20, OPTIONAL)
tab p404, m
recode p404 6=4, gen(dm_health)
lab var dm_health "Who Makes the Decisions About When to Seek Health Care?"
lab def dm_health 1 "Respondent" 2 "Husband/Partner" 3 "Husband/Partner Jointly" 4 "Other", modify
lab val dm_health dm_health
tab dm_health

recode dm_health 1 2 4=0 3=1, gen(dm_health_joint)
lab var dm_health_joint "Caregiver & partner decide jointly about seeking health care"
lab val dm_health_joint yn
tab dm_health_joint

save "caregiver_analysis32", replace
****************MODULE 6: Caregiver illness knowledge***************************
*Child illness signs 
tab p601

gen p601a = 1 if strpos(p601,"A") 
gen p601b = 1 if strpos(p601,"B") 
gen p601c = 1 if strpos(p601,"C") 
gen p601d = 1 if strpos(p601,"D") 
gen p601e = 1 if strpos(p601,"E") 
gen p601f = 1 if strpos(p601,"F") 
gen p601g = 1 if strpos(p601,"G") 
gen p601h = 1 if strpos(p601,"H") 
gen p601i = 1 if strpos(p601,"I") 
gen p601j = 1 if strpos(p601,"J") 
gen p601k = 1 if strpos(p601,"K") 
gen p601l = 1 if strpos(p601,"L") 
gen p601m = 1 if strpos(p601,"M") 
gen p601n = 1 if strpos(p601,"N") 
gen p601o = 1 if strpos(p601,"O") 
gen p601p = 1 if strpos(p601,"P") 
gen p601q = 1 if strpos(p601,"Q") 
gen p601r = 1 if strpos(p601,"R") 
gen p601s = 1 if strpos(p601,"S")
gen p601t = 1 if strpos(p601,"T") 
gen p601u = 1 if strpos(p601,"U") 
gen p601v = 1 if strpos(p601,"V") 
gen p601z = 1 if strpos(p601,"Z")  

*Create a variable = total number of illness signs caregiver knows
egen tot_p601 = rownonmiss(p601a-p601v)  
replace tot_p601 = . if p601 == "" 
lab var tot_p601 "Total number of illness signs CG knows"
tab tot_p601, m
*9 caregivers missing module

foreach var of varlist p601a-p601z {
  replace `var' = 0 if `var' == . & tot_p601 !=.
 }
   
*Create a variable = caregiver knows 2+ illness signs (INDICATOR 3)
gen cgdsknow2 = tot_p601 >= 2 & tot_p601 !=. 
replace cgdsknow2 = . if tot_p601 == .
lab var cgdsknow2 "Caregiver knows 2+ child illness signs"
lab val cgdsknow2 yn
tab cgdsknow2,m
*9 caregivers missing module

*Create a variable = caregiver knows 3+ illness signs (INDICATOR 3A)
gen cgdsknow3 = tot_p601 >= 3 & tot_p601 !=. 
replace cgdsknow3 = . if tot_p601 == .
lab var cgdsknow3 "Caregiver knows 3+ child illness signs"
lab val cgdsknow3 yn
tab cgdsknow3
*9 caregivers missing module

*Knowledge of malaria (not an indicator)
tab p602, m

*Knowledge of malaria acquisition (INDICATOR 30, OPTIONAL)  
tab p603
gen malaria_get = 0
replace malaria_get = 1 if strpos(p603,"A")
replace malaria_get =. if p603 == "" 
lab var malaria_get "Knowledge of Malaria Acquisition?"
lab val malaria_get yn
tab malaria_get
*9 caregivers missing module

*Knowledge that fever is a malaria symptom
tab p604

gen p604a = 1 if strpos(p604,"A") 
gen p604b = 1 if strpos(p604,"B") 
gen p604c = 1 if strpos(p604,"C") 
gen p604d = 1 if strpos(p604,"D") 
gen p604e = 1 if strpos(p604,"E") 
gen p604f = 1 if strpos(p604,"F") 
gen p604g = 1 if strpos(p604,"G") 
gen p604h = 1 if strpos(p604,"H") 
gen p604x = 1 if strpos(p604,"X") 
gen p604z = 1 if strpos(p604,"Z") 

gen malaria_fev_sign = 0
replace malaria_fev_sign = 1 if strpos(p604,"A")
replace malaria_fev_sign = . if p604 == "" 
lab var malaria_fev_sign "Knowledge that fever is a sign of malaria"
lab val malaria_fev_sign yn
tab malaria_fev_sign 
*9 caregivers missing module + 1 addition missing response

*Knowledge of at least 2 symptoms of malaria (INDICATOR 31, OPTIONAL)
egen tot_p604 = rownonmiss(p604a-p604h)
replace tot_p604 =. if p604 == ""
lab var tot_p604 "Total number of malaria signs CG knows"
gen malaria_signs2 = 0
replace malaria_signs2 = 1 if tot_p604 >=2
replace malaria_signs2 = . if p604 == "" 
lab var malaria_signs2 "Caregiver knows 2+ signs of malaria"
lab val malaria_signs2 yn
tab malaria_signs2
*9 caregivers missing module + 1 addition missing response

***Knowledge of correct treatment for malaria, ACT (INDICATOR 32, OPTIONAL)
gen malaria_rx = 0
replace malaria_rx = 1 if p605 == 1  
replace malaria_rx = . if p605 == . & p602 == . & survey == 2
lab var malaria_rx "Caregiver knows correct malaria treatment"
lab val malaria_rx yn
tab malaria_rx  
*9 caregivers missing module

save "caregiver_analysis32", replace

****************MODULE 5: Caregiver knowledge & perceptions of iCCM CHWs********
*Caregiver knows there is an CHW in the community (INDICATOR 1)  
tab p504, m
recode p504 8=0,gen(chw_know)
lab var chw_know "Caregiver knows CHW that works in community"
lab val chw_know yn
tab chw_know,m
*4 caregivers missing module

*Caregiver knows where the CHW is located
*(among those who know that there is an CHW in their community)
tab p506, m
recode p506 2=0, gen(chw_loc)
lab var chw_loc "Caregiver knows where CHW is located"
lab val chw_loc yn
tab chw_loc,m

*Caregiver knows 2+ CHW curative services offered (INDICATOR 2)
*(among those who know that there is an CHW in their community)
tab p505
gen p505a = 1 if strpos(p505,"A") 
gen p505b = 1 if strpos(p505,"B") 
gen p505c = 1 if strpos(p505,"C") 
gen p505d = 1 if strpos(p505,"D") 
gen p505e = 1 if strpos(p505,"E") 
gen p505f = 1 if strpos(p505,"F") 
gen p505g = 1 if strpos(p505,"G") 
gen p505h = 1 if strpos(p505,"H") 
gen p505i = 1 if strpos(p505,"I") 
gen p505j = 1 if strpos(p505,"J") 
gen p505k = 1 if strpos(p505,"K") 
gen p505l = 1 if strpos(p505,"L") 
gen p505m = 1 if strpos(p505,"M") 
gen p505n = 1 if strpos(p505,"N") 
gen p505o = 1 if strpos(p505,"O") 
gen p505p = 1 if strpos(p505,"P") 
gen p505q = 1 if strpos(p505,"Q") 
gen p505r = 1 if strpos(p505,"R") 
gen p505s = 1 if strpos(p505,"S")
gen p505t = 1 if strpos(p505,"T") 
gen p505z = 1 if strpos(p505,"Z") 

*Total number of CHW curative services (P505k-P505s) that caregiver knows
*(among those who know that there is an CHW in their community)
egen tot_p505 = rownonmiss(p505k-p505s)
label var tot_p505 "Total number of CHW curative services CG knows"
replace tot_p505 =. if chw_know != 1
gen cgcurknow2 = tot_p505 >= 2 
replace cgcurknow2 =. if chw_know != 1
lab var cgcurknow2 "Caregiver knows 2+ CHW curative services"
lab val cgcurknow2 yn
tab cgcurknow2,m

foreach var of varlist p505a-p505z {
  replace `var' = 0 if `var' == . & tot_p505 !=.
  lab val `var' yn
 }
   
*Did the CHW make a homevisit to your house in the last month? (endline only)
tab p505A
recode p505A 2 8=0, gen(chw_visit)
lab var p505A "CHW made a visit to caregiver's home in last month"
lab val chw_visit yn
tab chw_visit
 
*What did the CHW do during that homevisit? (endline only)
*Question only allowed for one response but should have allowed multiple
tab p505B
lab var p505B "What did CHW do during homevisit?"
lab def visit 1 "Asked about children's vaccinations" 2 "Asked status of HH members' health" ///
              3 "Advised on health behaviors" 4 "Asked/observed behaviors and conditions" ///
		      5 "Asked about/observed diseases"
lab val p505B visit
tab p505B
  
*Look at all CHW perception responses
*(among those who know that there is an CHW in their community)
tab1 p507-p516
lab def agree 0 "Disagree" 1 "Agree",modify
foreach var of varlist p507-p516 {
  recode `var' 2 8=0 
  replace `var' = . if chw_know != 1
  lab val `var' agree
}

*CHW is a trusted provider (Q509 & Q512 must be YES) (INDICATOR 4)
*(among those who know that there is an CHW in their community)
tab p509,m
tab p512,m
gen chwtrusted = 0
replace chwtrusted = 1 if p509 == 1 & p512 == 1
replace chwtrusted =. if p504 != 1
lab var chwtrusted "CHW is a trusted provider"
lab val chwtrusted yn
tab chwtrusted
***8 responses missing

*CHW provides quality services (3+ must be YES: Q510, Q511, Q513, Q514) (INDICATOR 5)
tab p510
tab p511
tab p513
tab p514

egen chwquality = anycount(p510 p511 p513 p514), values(1)
tab chwquality
replace chwquality = 0 if chwquality == 1 | chwquality == 2
replace chwquality = 1 if chwquality == 3 | chwquality == 4
replace chwquality = . if p504 != 1
replace chwquality = . if p510 == . & p511 == . & p513 == 1 & p514 == 1
lab var chwquality "CHW provides quality services"
lab val chwquality yn
tab chwquality

save "caregiver_analysis32", replace

*CHW availability by caregiver (INDICATOR 57)
*First calculate proportion of cases for which the CHW was available, by CG
*Create the numerator looking at Q722, Q823 & Q917 (CHW was available)
gen chwavail = 0
replace chwavail = chwavail + 1 if p722 == 1
replace chwavail = chwavail + 1 if p823 == 1
replace chwavail = chwavail + 1 if p917 == 1
replace chwavail =. if p722 ==. & p823 ==. & p917 ==.
lab var chwavail "Total number of times CG found CHW at first visit for children in survey"
tab chwavail

*Create the denominator looking at Q724, Q823 & Q917 (CHW was visited)
gen chwavaild = 0
replace chwavaild = chwavaild + 1 if p722 !=.
replace chwavaild = chwavaild + 1 if p823 !=.
replace chwavaild = chwavaild + 1 if p917 !=.
replace chwavaild =. if p722 ==. & p823 ==. & p917 ==.
lab var chwavaild "Total number of times CG sought care from CHW for children in survey"
tab chwavaild

*Create the proportion (numerator variable / denominator variable)
gen chwavailp = chwavail/chwavaild
lab var chwavailp "Prop of time CHW was available at first visit"

tab chwavailp
*390 caregivers sought care from a CHW for 584 sick child cases

*Create variable to capture if CHW was ALWAYS available at first visit (INDICATOR 6)
gen chwalwaysavail = 0
replace chwalwaysavail = 1 if chwavailp == 1
replace chwalwaysavail = . if chwavaild == .
lab var chwalwaysavail "CHW was available when caregiver sought care for each case included in survey"
lab val chwalwaysavail yn 

tab chwalwaysavail

*CHW convenient (INDICATOR 7)
tab p507, m
tab p508, m
gen chwconvenient = 0
replace chwconvenient = 1 if p507 == 1 & p508 == 1 
replace chwconvenient = . if p504 != 1
lab var chwconvenient "CHW is a convenient source of care"
lab val chwconvenient yn
tab chwconvenient

save "caregiver_analysis32", replace

*******************MODULE 7: Diarrhea*******************************************
use "illness_analysis32", clear
svyset cluster
numlabel, add force

*continued fluids (same amount or more than usual?) (INDICATOR 28, OPTIONAL) 
tab p701 if d_case == 1, m
gen d_cont_fluids = .
replace d_cont_fluids = 1 if p701 == 3 | p701 == 4
replace d_cont_fluids = 0 if p701 != 3 & p701 != 4 & p701 !=. & d_case == 1
lab var d_cont_fluids "Child with diarrhea was offered same or more fluids"
lab val d_cont_fluids yn
tab d_cont_fluids if d_case == 1, m
*9 responses missing

*continued feeding (same amount or more than usual) (INDICATOR 29, OPTIONAL) //this question isn't in the Mozambique data set  

*reason did not seek care for diarrhea (ENDLINE ONLY) //Respondents only gave one answer for this question
*Only one response collected from each respondent - not how question was designed
tab p707C
replace p707C = "" if p707C == "---"
gen p707Ca = 1 if p707C == "A"
gen p707Cb = 1 if p707C == "B"
gen p707Cc = 1 if p707C == "C"
gen p707Cd = 1 if p707C == "D"
gen p707Ce = 1 if p707C == "E"
gen p707Cf = 1 if p707C == "F"
gen p707Cg = 1 if p707C == "G"
gen p707Cx = 1 if p707C == "X"
gen p707Cz = 1 if p707C == "Z"

foreach var of varlist p707Ca-p707Cz {
  replace `var' = 0 if `var' == . & p707C != "---" & p707C != ""
  lab val `var' yn
}

*decided to seek care jointly
tab p702 if d_case == 1, m
tab p703 if d_case == 1, m

*where care was sought
tab p705

*total number of providers visited
gen p705a = 1 if strpos(p705,"A") 
gen p705b = 1 if strpos(p705,"B") 
gen p705c = 1 if strpos(p705,"C") 
gen p705d = 1 if strpos(p705,"D") 
gen p705e = 1 if strpos(p705,"E") 
gen p705f = 1 if strpos(p705,"F") 
gen p705g = 1 if strpos(p705,"G") 
gen p705h = 1 if strpos(p705,"H") 
gen p705i = 1 if strpos(p705,"I") 
gen p705x = 1 if strpos(p705,"X") 

egen d_provtot = rownonmiss(p705a-p705x)
replace d_provtot = . if d_case != 1
lab var d_provtot "Total number of providers where sought care"
tab d_provtot if d_case == 1, m

*sought advice or treatment from an appropriate provider (INDICATOR 8A)
egen d_apptot = rownonmiss(p705a-p705d)
replace d_apptot = . if d_case != 1
lab var d_apptot "Total number of appropriate providers where sought care"
recode d_apptot 1 2 = 1, gen(d_app_prov)
lab var d_app_prov "Sought care from 1+ appropriate provider"
lab val d_app_prov yn 
tab d_app_prov

foreach var of varlist p705a-p705x {
  replace `var' = 0 if `var' == . & d_provtot > 0 & d_provtot != .
  lab val `var' yn 
}

*Organize care-seeking responses by categories in the report template
gen d_cs_public = 1 if p705a == 1 | p705b == 1
gen d_cs_private = 1 if p705c == 1
gen d_cs_chw = 1 if p705d == 1
gen d_cs_store = 1 if p705f == 1 | p705g == 1 | p705i ==  1
gen d_cs_trad = 1 if p705e == 1
gen d_cs_other = 1 if p705h == 1 | p705x == 1

foreach var of varlist d_cs_* {
  replace `var' = 0 if `var' == . & d_provtot > 0 & d_provtot != .
  lab val `var' yn
}

*did not seek care
tab p702
gen d_nocare = .
replace d_nocare = 0 if p702 == 1 & d_case == 1
replace d_nocare = 1 if p702 == 0 & d_case == 1
lab var d_nocare "Did not seek care for child with diarrhea"
lab val d_nocare yn
tab d_nocare

*did not seek care from a CHW
gen d_nocarechw = .
replace d_nocarechw = 0 if d_case == 1 & p702 == 1
replace d_nocarechw = 1 if p705d != 1 & p702 == 1 & d_case == 1
lab var d_nocarechw "Sought care for diarrhea - but not from CHW"
lab val d_nocarechw yn
tab d_nocarechw

*diarrhea decided to seek carefrom an appropriate provider jointly with a partner (INDICATOR 21A, OPTIONAL) 
gen d_app_joint =.
recode p401 3=0 1 2=1, gen(union)
lab val union yn
replace d_app_joint = 1 if d_app_prov == 1 & strpos(p704,"A") & survey == 2 & union == 1
replace d_app_joint = 0 if d_app_joint == . & d_case == 1 & union == 1
lab var d_app_joint "Decided to seek care from appropriate provider jointly with partner"
lab val d_app_joint yn
tab d_app_joint survey, col

*diarrhea decided to seek care jointly with a partner (INDICATOR 21A, OPTIONAL) 
gen d_joint =.
replace d_joint = 1 if strpos(p704,"A") & survey == 2 & union == 1
replace d_joint = 0 if d_joint == . & d_case == 1 & union == 1
lab var d_joint "Decided to seek care jointly with partner"
lab val d_joint yn
tab d_joint survey, col

*visited an CHW  
gen d_chw = 1 if strpos(p705, "D") 
replace d_chw = 0 if d_chw ==. & d_case == 1 
lab var d_chw "Sought care from CHW for diarrhea"
lab val d_chw yn
tab d_chw

*where sought care first
gen d_firstcare = 1 if p707 == "A" | p707 == "B"
replace d_firstcare = 2 if p707 == "C"
replace d_firstcare = 3 if p707 == "D"
replace d_firstcare = 4 if p707 == "F" | p707 == "G" | p707 == "I"
replace d_firstcare = 5 if p707 == "E"
replace d_firstcare = 6 if p707 == "H" | p707 == "X"

replace d_firstcare = 1 if (p705a == 1 | p705b == 1) & d_provtot == 1
replace d_firstcare = 2 if (p705c == 1) & d_provtot == 1
replace d_firstcare = 3 if (p705d == 1) & d_provtot == 1
replace d_firstcare = 4 if (p705f == 1 | p705g == 1 | p705i == 1) & d_provtot == 1
replace d_firstcare = 5 if (p705e == 1) & d_provtot == 1
replace d_firstcare = 6 if (p705h == 1 | p705x == 1) & d_provtot == 1

*visited an CHW as first (*or only*) source of care (INDICATOR 9A)
gen d_chwfirst = .
replace d_chwfirst = 1 if p707 == "D"
replace d_chwfirst = 1 if (strpos(p705, "D") & d_provtot == 1) 
replace d_chwfirst = 0 if d_case == 1 & d_chwfirst ==.
lab var d_chwfirst "Sought care from CHW first"
lab val d_chwfirst yn
tab d_chwfirst 

*visited an CHW as first (*or only*) source of care
gen d_chwfirst_anycare = .
replace d_chwfirst_anycare = 0 if p702 == 1 & d_case == 1 
replace d_chwfirst_anycare = 1 if p707 == "D"
replace d_chwfirst_anycare = 1 if (strpos(p705, "D") & d_provtot == 1) | (p705_d == 1 & d_provtot == 1)
lab var d_chwfirst_anycare "Sought care from CHW first, among those who sought any care"
lab val d_chwfirst_anycare yn
tab d_chwfirst_anycare survey, col

*reason(s) did not go to CHW f*reason(s) did not go to CHW for care (ENDLINE ONLY)
*Only one response collected from each respondent - not how question was designed
tab p707B
replace p707B = "" if p707B == "---"
*Create a new category G for no APE in community/don't know APE
replace p707B = "G" if p707B == "X" & p707B_outros == "não conhece o APE"
replace p707B = "G" if p707B == "X" & p707B_outros == "Não conhecemos APEs da comunidade"
replace p707B = "G" if p707B == "X" & p707B_outros == "NAo tem APE neste  comunidade"
replace p707B = "G" if p707B == "X" & strpos(p707B_outros, "O APE transferiu nos para US")
replace p707B = "G" if p707B == "X" & p707B_outros == "Nao conhece casa do APe"

gen p707Ba = 1 if p707B == "A"
gen p707Bb = 1 if p707B == "B"
gen p707Bc = 1 if p707B == "C"
gen p707Bd = 1 if p707B == "D"
gen p707Be = 1 if p707B == "E"
gen p707Bf = 1 if p707B == "F"
gen p707Bg = 1 if p707B == "G"
gen p707Bx = 1 if p707B == "X"
gen p707Bz = 1 if p707B == "Z"

foreach var of varlist p707Ba-p707Bz {
  replace `var' = 0 if `var' == . & p707B != "---" & p707B != ""
  lab val `var' yn
}

***treated with ORS (INDICATOR 26, OPTIONAL)
gen d_ors = 1 if p708A == "1" | p708B == "1" 
replace d_ors = 0 if d_case == 1 & d_ors != 1
lab var d_ors "Took ORS for diarrhea"
lab val d_ors yn
tab d_ors 

*where did caregiver get ORS?
tab p710 

*Organize locations of treatment by categories in the report template
gen d_ors_public = 1 if p710 == 11 | p710 == 12
gen d_ors_private = 1 if p710 == 14
gen d_ors_chw = 1 if p710 == 15
gen d_ors_store = 1 if p710 == 22 | p710 == 23 | p710 == 27
gen d_ors_trad = 1 if p710 == 21
gen d_ors_other = 1 if p710 == 26 | p710 == 31

foreach var of varlist d_ors_* {
  replace `var' = 0 if `var' == . & (p709 == 1 | p708A == "1" | p708B == "1")
  lab val `var' yn
}

*got ORS from CHW
recode p710 11 12 14 21 23 26 31 = 0 15 = 1, gen(d_orschw)
replace d_orschw = 0 if d_orschw == . & d_case == 1
lab var d_orschw "Got ORS from an CHW"
lab val d_orschw yn
tab d_orschw 

*if from CHW, did child take ORS in presence of CHW? (INDICATOR 15A)
tab p712
clonevar d_ors_chwp = p712
lab var d_ors_chwp "Did child take ORS in presence of CHW?"
lab val d_ors_chwp yn
tab d_ors_chwp

*if from CHW, did caregiver get counseled on how to give ORS at home? (INDICATOR 16A)
tab p713
clonevar d_ors_chwc = p713
lab var d_ors_chwc "Did caregiver get counseled on how to give ORS at home?"
lab val d_ors_chwc yn
tab d_ors_chwc  

*took Homemade fluid 
tab p708C
gen d_hmfl = 1 if p708C == "1"
replace d_hmfl = 0 if d_case == 1 & d_hmfl != 1
lab var d_hmfl "Did child take homemade fluid?"
lab val d_hmfl yn
tab d_hmfl 

*took Zinc (INDICATOR 27, OPTIONAL)
tab p714
recode p714 (8 2 =0), gen(d_zinc)
lab val d_zinc yn
lab var d_zinc "Did child take Zinc?"
tab d_zinc 

*where did caregiver get zinc?
tab p715 

*Organize locations of treatment by categories in the report template
gen d_zinc_public = 1 if p715 == 11 | p715 == 12
gen d_zinc_private = 1 if p715 == 14
gen d_zinc_chw = 1 if p715 == 15
gen d_zinc_store = 1 if p715 == 22 | p715 == 23 | p715 == 27
gen d_zinc_trad = 1 if p715 == 21
gen d_zinc_other = 1 if p715 == 26 | p715 == 31

foreach var of varlist d_zinc_* {
  replace `var' = 0 if `var' == . & p714 == 1
  lab val `var' yn
}

*got zinc from CHW
recode p715 11 12 23 26 = 0 15 = 1, gen(d_zincchw)
replace d_zincchw = 0 if d_zincchw == . & d_case == 1 & d_zinc !=.
lab var d_zincchw "Got Zinc from CHW?"
lab val d_zincchw yn
tab d_zincchw

*if from CHW, did child take zinc in presence of CHW? (INDICATOR 15B)
tab p717
recode p717 2=0
lab val p717 yn
clonevar d_zinc_chwp = p717
lab var d_zinc_chwp "Did child take zinc in presence of CHW?"
tab d_zinc_chwp

*if from CHW, did caregiver get counseled on how to give zinc at home? (INDICATOR 16B)
tab p718
recode p718 8=0, gen(d_zinc_chwc)
lab val d_zinc_chwc yn
tab d_zinc_chwc 

*treated with ORS AND Zinc (INDICATOR 13A)
gen d_orszinc = .
replace d_orszinc = 0 if d_case == 1
replace d_orszinc = 1 if d_ors==1 & d_zinc==1
replace d_orszinc = . if d_case == 1 & d_zinc ==.
lab var d_orszinc "Took both ORS and zinc for diarrhea"
lab val d_orszinc yn
tab d_orszinc 

*treated with ORS AND Zinc by CHW (INDICATOR 14A)
gen d_orszincchw = 0
replace d_orszincchw = 1 if d_orszinc == 1 & p710 == 15 & p715 == 15 
replace d_orszincchw = . if d_case != 1
replace d_orszincchw = . if d_zinc == . & d_case == 1
lab var d_orszincchw "Treated with both ORS and zinc for diarrhea by CHW"
lab val d_orszincchw yn
tab d_orszincchw 

*took both ORS AND Zinc in presence of CHW (INDICATOR 15C)
gen d_bothfirstdose =.
replace d_bothfirstdose = 1 if p712 == 1 & p717 == 1
replace d_bothfirstdose = 0 if p710 == 15 & p715 == 15 & d_bothfirstdose ==.
lab var d_bothfirstdose "Took first dose of both ORS and zinc in presense of CHW"
lab val d_bothfirstdose yn
tab d_bothfirstdose 

*was counseled on admin of both ORS AND Zinc by CHW (INDICATOR 16C)
gen d_bothcounsel =.
replace d_bothcounsel = 1 if p713 == 1 & p718 == 1
replace d_bothcounsel = 0 if p710 == 15 & p715 == 15 & d_bothcounsel ==.
lab var d_bothcounsel "Was counseled on admin of both ORS and zinc by CHW"
lab val d_bothcounsel yn
tab d_bothcounsel 

*if CHW visited, was available at first visit
tab p722   
recode p722 2=0
lab val p722 yn
clonevar d_chwavail = p722
lab var d_chwavail "Was CHW available at first visit?"
lab val d_chwavail yn
tab d_chwavail

*if CHW visited, did CHW refer the child to a health center?
tab p723  
recode p723 2=0 
lab val p723 yn
clonevar d_chwrefer = p723
lab var d_chwrefer "Did CHW refer child to a health center?"
lab val d_chwrefer yn
tab d_chwrefer

*completed CHW referral (INDICATOR 17A) 
tab p724 
recode p724 2=0 
lab val p724 yn
clonevar d_referadhere = p724
lab var d_referadhere "Did you go to the health unit?"
lab val d_referadhere yn

*reason did not comply with CHW referral
tab p725 survey
gen p725a = 1 if strpos(p725,"A") 
gen p725b = 1 if strpos(p725,"B") 
gen p725c = 1 if strpos(p725,"C") 
gen p725d = 1 if strpos(p725,"D") 
gen p725e = 1 if strpos(p725,"E") 
gen p725f = 1 if strpos(p725,"F") 
gen p725g = 1 if strpos(p725,"G") 
gen p725h = 1 if strpos(p725,"H") 
gen p725i = 1 if strpos(p725,"I") 
gen p725x = 1 if strpos(p725,"X") 

foreach var of varlist p725a-p725x {
  replace `var' = 0 if `var' ==. & d_referadhere == 0
  lab val `var' yn
}

***CHW follow-up (INDICATOR 18A)
tab p726
lab var p726 "CHW Followed Up?"
lab def followup 1 "Yes at child's home" 2 "Yes at APE's place" 3 "No"
lab val p726 followup
tab p726

recode p726 2 3=0, gen(d_chw_fu)
lab var d_chw_fu "CHW followed up sick child"
lab val d_chw_fu yn
tab d_chw_fu

*when was CHW follow-up
tab p727

clonevar d_when_fu = p727
replace d_when_fu = . if p726 == 2
lab var d_when_fu "When did CHW followed up sick child"
tab d_when_fu 

***CHW follow-up (INDICATOR 18A)
recode p726 1 3=0 2=1, gen(d_chw_fu2)
lab var d_chw_fu2 "Caregiver visited CHW for follow-up"
lab val d_chw_fu2 yn

*when was CHW follow-up
gen d_when_fu2 = .
replace d_when_fu2 = p727
replace d_when_fu2 = . if p726 == 1
lab var d_chw_fu2 "When did caregiver visit CHW for follow-up"
tab d_when_fu2 survey, col

*sick child given anything else?
***Endline
gen p720a = 1 if strpos(p720,"A") 
gen p720b = 1 if strpos(p720,"B") 
gen p720c = 1 if strpos(p720,"C") 
gen p720d = 1 if strpos(p720,"D") 
gen p720e = 1 if strpos(p720,"E") 
gen p720f = 1 if strpos(p720,"F") 
gen p720g = 1 if strpos(p720,"G") 
gen p720h = 1 if strpos(p720,"H") 
gen p720i = 1 if strpos(p720,"I") 
gen p720x = 1 if strpos(p720,"X") 

egen d_othermed = rownonmiss(p720a-p720x)
replace d_othermed = . if d_case != 1
lab var d_othermed "Total number of other meds child given for diarrhea"
tab d_othermed  

foreach var of varlist p720a-p720x {
  replace `var' = 0 if `var' ==. & d_othermed > 0 & d_case == 1
  lab val `var' yn
}

save "illness_analysis32", replace 

*********************MODULE 8: Fever *******************************************

*sought any advice or treatment for fever
tab p804 if f_case == 1, m

*reason did not seek care for fever (ENDLINE ONLY)
tab p829
*Recode the other responses to existing responses
replace p829 = "G" if p829 == "X" & p829_outros == "comprei o comprimido para malária na comunidade"
replace p829 = "F" if p829 == "X" & p829_outros == "Falta de dinheiro"
replace p829 = "C" if p829 == "X" & p829_outros == "A idade já nao permite andar muito"
*See how many reasons were given since multiple responses were allowed
gen p829a = 1 if strpos(p829,"A") 
gen p829b = 1 if strpos(p829,"B") 
gen p829c = 1 if strpos(p829,"C") 
gen p829d = 1 if strpos(p829,"D") 
gen p829e = 1 if strpos(p829,"E") 
gen p829f = 1 if strpos(p829,"F") 
gen p829g = 1 if strpos(p829,"G")
gen p829x = 1 if strpos(p829,"X") 
gen p829z = 1 if strpos(p829,"Z")

egen tot_p829 = rownonmiss(p829a-p829z)
replace tot_p829 = . if f_case != 1 
replace tot_p829 = . if survey == 1 
lab var tot_p829 "Number of reasons caregiver did not seek care"
tab tot_p829

foreach var of varlist p829a-p829z {
  replace `var' = 0 if `var' ==. & tot_p829 > 0 & tot_p829 != . & f_case == 1
  lab val `var' yn
  }

*decided to seek care jointly
tab p805

*where care was sought
tab p807 

*total number of providers visited 
gen p807a = 1 if strpos(p807,"A") 
gen p807b = 1 if strpos(p807,"B") 
gen p807c = 1 if strpos(p807,"C") 
gen p807d = 1 if strpos(p807,"D") 
gen p807e = 1 if strpos(p807,"E") 
gen p807f = 1 if strpos(p807,"F") 
gen p807g = 1 if strpos(p807,"G") 
gen p807h = 1 if strpos(p807,"H") 
gen p807i = 1 if strpos(p807,"I") 
gen p807x = 1 if strpos(p807,"X") 

egen f_provtot = rownonmiss(p807a-p807x)
replace f_provtot = . if f_case != 1
replace f_provtot = . if p807 == "---"
lab var f_provtot "Total number of providers where sought care"
tab f_provtot 

*sought advice or treatment from an appropriate provider (INDICATOR 8B)
egen f_apptot = rownonmiss(p807a-p807d)
replace f_apptot = . if f_case != 1
replace f_apptot = . if p807 == "---"
lab var f_apptot "Total number of appropriate providers where sought care"
recode f_apptot 1 2 = 1, gen(f_app_prov)
replace f_app_prov = 0 if f_app_prov ==. & f_case == 1
lab var f_app_prov "Sought care from 1+ appropriate provider"
lab val f_app_prov yn 
tab f_app_prov 

foreach var of varlist p807a-p807x {
  replace `var' = 0 if `var' ==. & f_provtot > 0 & f_provtot != . & f_case == 1
  lab val `var' yn
  }

gen f_cs_public = 1 if p807a == 1 | p807b == 1
gen f_cs_private = 1 if p807c == 1
gen f_cs_chw = 1 if p807d == 1
gen f_cs_store = 1 if p807f == 1 | p807g == 1 | p807i ==  1
gen f_cs_trad = 1 if p807e == 1
gen f_cs_other = 1 if p807h == 1 | p807x == 1

foreach var of varlist f_cs_* {
  replace `var' = 0 if `var' == . & f_provtot > 0 & f_provtot != .
  lab val `var' yn
  }

*did not seek care
tab p804
gen f_nocare = .
replace f_nocare = 0 if p804 == 1 & f_case == 1
replace f_nocare = 1 if p804 == 0 & f_case == 1
lab var f_nocare "Did not seek care for child with fever"
lab val f_nocare yn
tab f_nocare 

*did not seek care from a CHW
gen f_nocarechw = .
replace f_nocarechw = 0 if f_case == 1 & p804 == 1
replace f_nocarechw = 1 if p807d != 1 & p804 == 1 & f_case == 1
lab var f_nocarechw "Sought care for fever - but not from CHW"
lab val f_nocarechw yn
tab f_nocarechw 

*fever sought treatment from an appropriate provider jointly with a partner (INDICATOR 21B, OPTIONAL)
***endline only
gen f_app_joint =.
replace f_app_joint = 1 if f_app_prov == 1 & strpos(p806,"A") & p804 == 1 & union == 1 
replace f_app_joint = 0 if f_app_joint ==. & f_case == 1 & union == 1
lab var f_app_joint "Decided to seek care from appropriate provider jointly with partner"
lab val f_app_joint yn
tab f_app_joint

*fever sought treatment jointly with a partner (INDICATOR 21B, OPTIONAL)
***endline only
gen f_joint =.
replace f_joint = 1 if strpos(p806,"A") & p804 == 1 & union == 1 
replace f_joint = 0 if f_joint ==. & f_case == 1 & union == 1
lab var f_joint "Decided to seek care from jointly with partner"
lab val f_joint yn
tab f_joint

*where sought care first
gen f_firstcare = 1 if p809 == "A" | p809 == "B"
replace f_firstcare = 2 if p809 == "C"
replace f_firstcare = 3 if p809 == "D"
replace f_firstcare = 4 if p809 == "F" | p809 == "G" | p809 == "I"
replace f_firstcare = 5 if p809 == "E"
replace f_firstcare = 6 if p809 == "H" | p809 == "X"

replace f_firstcare = 1 if (p807a == 1 | p807b == 1) & f_provtot == 1
replace f_firstcare = 2 if (p807c == 1) & f_provtot == 1
replace f_firstcare = 3 if (p807d == 1) & f_provtot == 1
replace f_firstcare = 4 if (p807f == 1 | p807g == 1 | p807i == 1) & f_provtot == 1
replace f_firstcare = 5 if (p807e == 1) & f_provtot == 1
replace f_firstcare = 6 if (p807h == 1 | p807x == 1) & f_provtot == 1

*visited a CHW
tab p807d 
gen f_chw = 1 if p807d == 1
replace f_chw = 0 if f_chw ==. & f_case !=. 
lab var f_chw "Sought care from CHW for fever"
lab val f_chw yn
tab f_chw 

*visited an CHW as first (*or only*) source of care (INDICATOR 9B)
gen f_chwfirst = .
replace f_chwfirst = 1 if p809 == "D"
replace f_chwfirst = 1 if p807d == 1 & f_provtot == 1
replace f_chwfirst = 0 if f_case !=. & f_chwfirst ==.
lab var f_chwfirst "Sought care from CHW first"
lab val f_chwfirst yn
tab f_chwfirst 

*visited an CHW as first (*or only*) source of care
gen f_chwfirst_anycare = .
replace f_chwfirst_anycare = 0 if p804 == 1
replace f_chwfirst_anycare = 1 if p809 == "D"
replace f_chwfirst_anycare = 1 if p807d == 1 & f_provtot == 1
lab var f_chwfirst_anycare "Sought care from CHW first, among those who sought any care"
lab val f_chwfirst_anycare yn
tab f_chwfirst_anycare survey, col

*reason(s) did not go to CHW for care (ENDLINE ONLY)
replace p809B ="G" if p809B == "X" & p809B_outros == "Nao existe APE nesta comunidade"
replace p809B ="G" if p809B == "X" & p809B_outros == "Nao conhece o APE"
replace p809B ="G" if p809B == "X" & p809B_outros == "Nao existe APE Nesta comunidade"
replace p809B ="G" if p809B == "X" & p809B_outros == "NAo existe APE nesta comunidade"

gen p809Ba = 1 if strpos(p809B,"A") 
gen p809Bb = 1 if strpos(p809B,"B") 
gen p809Bc = 1 if strpos(p809B,"C") 
gen p809Bd = 1 if strpos(p809B,"D") 
gen p809Be = 1 if strpos(p809B,"E") 
gen p809Bf = 1 if strpos(p809B,"F") 
gen p809Bg = 1 if strpos(p809B,"G")
gen p809Bx = 1 if strpos(p809B,"X") 
gen p809Bz = 1 if strpos(p809B,"Z")

tab1 p809Ba-p809Bz
egen tot_p809b = rownonmiss(p809Ba-p809Bz)
replace tot_p809b = . if f_case != 1
replace tot_p809b = . if p807d == 1
lab var tot_p809b "Total number of reasons CG did not seek care from CHW"
tab tot_p809b 

foreach var of varlist p809Ba-p809Bz {
  replace `var' = 0 if `var' ==. & tot_p809b > 0 & tot_p809b != .
  lab val `var' yn
}

*had blood taken (INDICATOR 10) 
tab p810
lab var p810 "Had Blood Taken"
recode p810 8 .=0, gen(f_bloodtaken)
replace f_bloodtaken = . if f_case != 1
lab var f_bloodtaken "Child had blood taken"
lab val f_bloodtaken yn
tab f_bloodtaken 

*had blood taken from CHW
gen f_bloodtakenchw = .
replace f_bloodtakenchw = 0 if p807d == 1
replace f_bloodtakenchw = 1 if p811_a == 1 | strpos(p811, "A")
lab var f_bloodtakenchw "Child had blood taken by a CHW"
lab val f_bloodtakenchw yn
tab f_bloodtakenchw

*caregiver received results of blood test (INDICATOR 11) 
tab p812
recode p812 8=0,gen(f_gotresult)
lab val f_gotresult yn
lab var f_gotresult "Caregiver received results of blood test"
tab f_gotresult 

*caregiver received results of blood test from CHW
gen f_gotresultchw = .
replace f_gotresultchw = 0 if f_bloodtakenchw == 1
replace f_gotresultchw = 1 if f_bloodtakenchw == 1 & p812 == 1
lab var f_gotresultchw "Caregiver received results of blood test performed by CHW"
lab val f_gotresultchw yn
tab f_gotresultchw

*blood test results  
tab p813  
recode p813 8=., gen(f_result)
lab var f_result "Blood test result"
lab def result 0 "Negative" 1 "Positive"
lab val f_result result
tab f_result
**2 results missing

*blood test results from CHW
gen f_resultchw = .
replace f_resultchw = 0 if f_gotresultchw == 1
replace f_resultchw = 1 if f_gotresultchw == 1 & f_result == 1
lab var f_resultchw "Result of blood test performed by CHW"
lab val f_resultchw yn
tab f_resultchw

* who performed the blood test? 
***Endline
tab p811
gen p811a = 1 if strpos(p811,"A") 
gen p811b = 1 if strpos(p811,"B") 
gen p811c = 1 if strpos(p811,"C") 
gen p811d = 1 if strpos(p811,"D") 
gen p811e = 1 if strpos(p811,"E") 
gen p811x = 1 if strpos(p811,"X") 
gen p811z = 1 if strpos(p811,"Z")

foreach var of varlist p811a-p811x {
  replace `var' = 0 if `var' == . & p810 == 1
  lab val `var' yn
  }

* took medication
gen p815a = 1 if strpos(p815,"A") 
gen p815b = 1 if strpos(p815,"B") 
gen p815c = 1 if strpos(p815,"C") 
gen p815d = 1 if strpos(p815,"D") 
gen p815e = 1 if strpos(p815,"E") 
gen p815f = 1 if strpos(p815,"F") 
gen p815g = 1 if strpos(p815,"G") 
gen p815h = 1 if strpos(p815,"H") 
gen p815x = 1 if strpos(p815,"X") 
gen p815z = 1 if strpos(p815,"Z")

foreach var of varlist p815a-p815z {
  replace `var' = 0 if `var' == . & p814 == 1
  lab val `var' yn
}

***took any antimalarial (INDICATOR 22, OPTIONAL)
gen f_antim = 1 if p815a == 1 | p815b == 1 | p815c == 1 | p815d == 1
replace f_antim = 0 if f_antim ==. & f_case == 1
lab var f_antim "Took antimalarial for fever"
lab val f_antim yn
tab f_antim 

*tool any antimalarial after positive blood test
gen f_antimc = 1 if (p815a == 1 | p815b == 1 | p815c == 1 | p815d == 1) & f_result == 1
replace f_antimc = 0 if f_antimc ==. & f_result == 1
lab var f_antimc "Took antimalarial for fever, among those with a positive blood test"
lab val f_antimc yn
tab f_antimc 

*took ACT
gen f_act = 1 if p815a == 1
replace f_act = 0 if f_act ==. & f_case == 1
lab var f_act "Took ACT for fever, among all fever cases"
lab val f_act yn
tab f_act 

*Where got ACT
*Organize locations of treatment by categories in the report template
gen f_act_public = 1 if p817 == 11 | p817 == 12
gen f_act_private = 1 if p817 == 14
gen f_act_chw = 1 if p817 == 15
gen f_act_store = 1 if p817 == 22 | p817 == 23 | p817 == 27
gen f_act_trad = 1 if p817 == 21
gen f_act_other = 1 if p817 == 26 | p817 == 31

foreach var of varlist f_act_public-f_act_other {
  replace `var' = 0 if `var' == . & p815a == 1
  lab val `var' yn
  }

*took ACT among any antimalarial (INDICATOR 23, OPTIONAL)
gen f_act_am = . 
replace f_act_am = 1 if f_act == 1
replace f_act_am = 0 if f_antim == 1 & f_act_am ==.
lab var f_act_am "Took ACT, among those who took any antimalarial"
lab val f_act_am yn
tab f_act_am 

**took ACT within 24 hours (same or next day)
gen f_act24 = 1 if f_act == 1 & p818 < 2
replace f_act24 = 0 if f_act24 ==. & f_case == 1
lab var f_act24 "Took ACT same or next day, among all cases of fever"
lab val f_act24 yn
tab f_act24 

**took ACT after positive blood test
gen f_actc = 0 if f_result == 1
replace f_actc = 1 if f_act == 1 & f_result == 1
lab var f_actc "Took ACT, among those with a positive blood test"
lab val f_actc yn
tab f_actc 

***appropriate fever treatment - confirmed malaria within 24 hours (INDICATOR 13C)  
***took ACT within 24 hours after positive blood test
gen f_actc24 = .
replace f_actc24 = 0 if f_result == 1 
replace f_actc24 = 1 if p815a == 1 & p818 < 2 & p813 == 1
lab var f_actc24 "Took ACT same or next day, among those with a positive blood test"
lab val f_actc24 yn
tab f_actc24  

*where did caregiver get ACT?
tab p817 

*ACT from CHW
gen f_actchw = .
replace f_actchw = 0 if f_case == 1 & p104f >= 6
replace f_actchw = 1 if p815a == 1 & p817 == 15 & p104f >= 6
lab var f_actchw "ACT treatment by an CHW, among all fever cases"
lab val f_actchw yn
tab f_actchw  

*fever treatment from CHW - confirmed among all fever cases
gen f_actcchw = .
replace f_actcchw = 0 if f_result == 1 & p104f >= 6
replace f_actcchw = 1 if p815a == 1 & p817 == 15 & p813 == 1 & p104f >= 6
lab var f_actcchw "ACT treatment by an CHW, among those with a positive blood test"
lab val f_actcchw yn
tab f_actcchw  

*fever treatment from CHW - confirmed among those managed by CHW
gen f_actcchw2 = .
replace f_actcchw2 = 0 if f_result == 1 & f_chw == 1 & p104f >= 6
replace f_actcchw2 = 1 if f_actc == 1 & p817 == 15 & p104f >= 6
lab var f_actcchw2 "ACT treatment by an CHW, among those with a positive blood test performed by CHW"
lab val f_actcchw2 yn
tab f_actcchw2  

*fever treatment - confirmed, among those with positive result
*now the same as f_actc
gen f_actc2 = .
replace f_actc2 = 0 if f_result == 1
replace f_actc2 = 1 if f_actc == 1
lab var f_actc2 "ACT treatment, among those with positive blood test result"
lab val f_actc2 yn
tab f_actc2  

*appropriate fever treatment from CHW - confirmed within 24 hours (INDICATOR 14C)
***took ACT from CHW within 24 hours after positive blood test
gen f_actc24chw = .
replace f_actc24chw = 0 if f_result == 1 & p104f >= 6
replace f_actc24chw = 1 if f_actc == 1 & p818 < 2 & p817 == 15 & p104f >= 6
lab var f_actc24chw "ACT treatment the same or next day by an CHW, among those with a positive blood test"
lab val f_actc24chw yn
tab f_actc24chw  

*treatment with antibiotic
gen f_antibiotic = 1 if p815e == 1 | p815f == 1
replace f_antibiotic = 0 if f_antibiotic ==. & f_case == 1
lab var f_antibiotic "Took antibiotic for fever"
lab val f_antibiotic yn
tab f_antibiotic 

*treatment with antibiotic if blood test negative
gen f_ab_neg = 1 if (p815e == 1 | p815f == 1) & f_result == 0
replace f_ab_neg = 0 if f_ab_neg ==. & f_case == 1 & f_result == 0
lab var f_ab_neg "Took antibiotic for fever - blood test negative"
lab val f_ab_neg yn
tab f_ab_neg 

*treatment with antibiotic by CHW
gen f_abchw = 1 if (p815e == 1 | p815f == 1) & p817 == 15
replace f_abchw = 0 if f_abchw ==. & f_case == 1
lab var f_abchw "Took antibiotic for fever"
lab val f_abchw yn
tab f_abchw 

*if from CHW, did child take ACT in presence of CHW? (INDICATOR 15B)  
tab p820
clonevar f_act_chwp = p820
lab var f_act_chwp "Did child take ACT in presence of CHW?"
lab val f_act_chwp yn
tab f_act_chwp

*if from CHW, did caregiver get counseled on how to give ACT at home? (INDICATOR 16B)
tab p821 
clonevar f_act_chwc = p821
lab var f_act_chwc "Was CG counseled on how to give ACT at home?"
lab val f_act_chwc yn
tab f_act_chwc 
***1 response missing

*if CHW visited, was available at first visit
tab p823 
clonevar f_chwavail = p823
lab var f_chwavail "Was CHW Available the first time you went?"
lab val f_chwavail yn
tab f_chwavail

*if CHW visited, did CHW refer the child to a health center?
tab p824 
recode p824 8=0, gen(f_chwrefer)
lab val f_chwrefer yn
label var f_chwrefer "Did CHW refer child to a health center?" 
tab f_chwrefer

***completed referral by CHW (INDICATOR 17B)
tab p825 
recode p825 8=0, gen(f_referadhere)
label var f_referadhere "Did you complete the referral by CHW?" 
lab val f_referadhere yn
tab f_referadhere

***reason did not comply with CHW referral  
tab p826
gen p826a = 1 if strpos(p826,"A")
gen p826b = 1 if strpos(p826,"B")
gen p826c = 1 if strpos(p826,"C") 
gen p826d = 1 if strpos(p826,"D")
gen p826e = 1 if strpos(p826,"E")
gen p826f = 1 if strpos(p826,"F")
gen p826g = 1 if strpos(p826,"G") 
gen p826h = 1 if strpos(p826,"H") 
gen p826i = 1 if strpos(p826,"I") 
gen p826x = 1 if strpos(p826,"X") 

foreach var of varlist p826a-p826x {
  replace `var' = 0 if `var' == . & f_referadhere == 0
  lab val `var' yn
  }

***CHW follow-up (INDICATOR 18B)
tab p827
recode p827 2 3=0, gen(f_chw_fu)
label var f_chw_fu "CHW followed up sick child" 
lab val f_chw_fu yn
tab f_chw_fu

***when was CHW follow-up
tab p828
clonevar f_when_fu = p828
replace f_when_fu = . if p827 == 2
label var f_when_fu "When did CHW followed up sick child" 
tab f_when_fu 

***CHW follow-up (INDICATOR 18B)
tab p827 survey
recode p827 1 3=0 2=1, gen(f_chw_fu2)
*replace f_chw_fu2 = 0 if f_chw_fu2 == 1 & p828 > 3
label var f_chw_fu2 "Caregiver visted CHW for follow-up" 
lab val f_chw_fu2 yn

***when was CHW follow-up
tab p828 survey
recode p828 8 =.
tab p828 survey, col

gen f_when_fu2 = .
replace f_when_fu2 = p828
replace f_when_fu2 = . if p827 == 1
label var f_when_fu2 "When did caregiver visted CHW for follow-up" 
tab f_when_fu2 survey, col

save "illness_analysis32", replace 
***********************MODULE 9: Fast Breathing*********************************

*sought any advice or treatment
tab p901

****reason did no seek care for cough/fast breathing (ENDLINE ONLY)
tab p923
gen p923a = 1 if strpos(p923,"A") 
gen p923b = 1 if strpos(p923,"B") 
gen p923c = 1 if strpos(p923,"C") 
gen p923d = 1 if strpos(p923,"D") 
gen p923e = 1 if strpos(p923,"E") 
gen p923f = 1 if strpos(p923,"F") 
gen p923g = 1 if strpos(p923,"G") 
gen p923x = 1 if strpos(p923,"X") 
gen p923z = 1 if strpos(p923,"Z") 
*See how many reasons were given since multiple responses were allowed
egen tot_p923 = rownonmiss(p923a-p923x)
replace tot_p923 =. if p901 == 1
replace tot_p923 =. if survey == 1
replace tot_p923 =. if c_case != 1
lab var tot_p923 "Number of reasons caregiver did not seek care"
tab tot_p923

foreach var of varlist p923a-p923z {
  replace `var' = 0 if `var' == . & tot_p923 > 0 & tot_p923 != .
  lab val `var' yn
  }

*decided to seek care jointly
tab p902 

*where care was sought
tab p904

gen p904a = 1 if strpos(p904,"A") 
gen p904b = 1 if strpos(p904,"B") 
gen p904c = 1 if strpos(p904,"C") 
gen p904d = 1 if strpos(p904,"D") 
gen p904e = 1 if strpos(p904,"E") 
gen p904f = 1 if strpos(p904,"F") 
gen p904g = 1 if strpos(p904,"G") 
gen p904h = 1 if strpos(p904,"H") 
gen p904i = 1 if strpos(p904,"I") 
gen p904x = 1 if strpos(p904,"X") 

*total number of providers visited 
egen fb_provtot = rownonmiss(p904a-p904x)
replace fb_provtot = . if c_case != 1
lab var fb_provtot "Total number of providers where care was sought"
tab fb_provtot 

*sought advice or treatment from an appropriate provider (INDICATOR 8C)
egen fb_apptot = rownonmiss(p904a-p904d)
replace fb_apptot = . if c_case != 1
lab var fb_apptot "Total number of appropriate providers where care was sought"
recode fb_apptot 1 2 = 1, gen(fb_app_prov)
lab var fb_app_prov "Sought care from 1+ appropriate provider"
lab val fb_app_prov yn 
tab fb_app_prov 

foreach var of varlist p904a-p904x {
  replace `var' = 0 if `var' ==. & p901 == 1 & c_case == 1
  lab val `var' yn
  }

gen fb_cs_public = 1 if p904a == 1 | p904b == 1
gen fb_cs_private = 1 if p904c == 1
gen fb_cs_chw = 1 if p904d == 1
gen fb_cs_store = 1 if p904f == 1 | p904g == 1 | p904i ==  1
gen fb_cs_trad = 1 if p904e == 1
gen fb_cs_other = 1 if p904h == 1 | p904x == 1

foreach var of varlist fb_cs_* {
  replace `var' = 0 if `var' == . & fb_provtot > 0 & fb_provtot != .
  lab val `var' yn
  }

*fast breathing sought treatment from an appropriate provider jointly with a partner (INDICATOR 21C, OPTIONAL) 
gen fb_app_joint =.
replace fb_app_joint = 1 if fb_app_prov == 1 & ((strpos(p903, "A") & survey == 2) | (p903_a == 1 & survey == 1)) & union == 1 & c_case == 1
replace fb_app_joint = 0 if fb_app_joint ==. & c_case == 1 & union == 1
lab var fb_app_joint "Decided to seek care from appropriate provider jointly with partner"
lab val fb_app_joint yn
tab fb_app_joint

*fast breathing sought treatment jointly with a partner (INDICATOR 21C, OPTIONAL) 
gen fb_joint =.
replace fb_joint = 1 if ((strpos(p903, "A") & survey == 2) | (p903_a == 1 & survey == 1)) & union == 1 & c_case == 1
replace fb_joint = 0 if fb_joint ==. & c_case == 1 & union == 1
lab var fb_joint "Decided to seek care jointly with partner"
lab val fb_joint yn
tab fb_joint

*did not seek care
tab p901
gen fb_nocare = .
replace fb_nocare = 0 if p901 == 1 & c_case == 1
replace fb_nocare = 1 if p901 == 0 & c_case == 1
lab var fb_nocare "Did not seek care for child with fast breathing"
lab val fb_nocare yn
tab fb_nocare 

*did not seek care from a CHW
gen fb_nocarechw = .
replace fb_nocarechw = 0 if c_case == 1 & p901 == 1
replace fb_nocarechw = 1 if p904d != 1 & p901 == 1 & c_case == 1
lab var fb_nocarechw "Sought care for fast breathing - but not from CHW"
lab val fb_nocarechw yn
tab fb_nocarechw 

*where sought care first
gen fb_firstcare = 1 if p906 == "A" | p906 == "B"
replace fb_firstcare = 2 if p906 == "C"
replace fb_firstcare = 3 if p906 == "D"
replace fb_firstcare = 4 if p906 == "F" | p906 == "G" | p906 == "I"
replace fb_firstcare = 5 if p906 == "E"
replace fb_firstcare = 6 if p906 == "H" | p906 == "X"

replace fb_firstcare = 1 if (p904a == 1 | p904b == 1) & fb_provtot == 1
replace fb_firstcare = 2 if (p904c == 1) & fb_provtot == 1
replace fb_firstcare = 3 if (p904d == 1) & fb_provtot == 1
replace fb_firstcare = 4 if (p904f == 1 | p904g == 1 | p904i == 1) & fb_provtot == 1
replace fb_firstcare = 5 if (p904e == 1) & fb_provtot == 1
replace fb_firstcare = 6 if (p904h == 1 | p904x == 1) & fb_provtot == 1

*visited an CHW
tab p904d 
gen fb_chw = 1 if p904d == 1
replace fb_chw = 0 if fb_chw ==. & c_case == 1
lab var fb_chw "Sought care from CHW for cough/fast breathing"
lab val fb_chw yn
tab fb_chw 

*visited an CHW as first (*or only*) source of care (INDICATOR 9C)
gen fb_chwfirst = .
replace fb_chwfirst = 1 if p906 == "D"
replace fb_chwfirst = 1 if p904d == 1 & fb_provtot == 1
replace fb_chwfirst = 0 if c_case ==1 & fb_chwfirst ==.
lab var fb_chwfirst "Sought care from CHW first"
lab val fb_chwfirst yn
tab fb_chwfirst 

*visited an CHW as first (*or only*) source of care (INDICATOR 9C)
gen fb_chwfirst_anycare = .
replace fb_chwfirst_anycare = 0 if p901 == 1
replace fb_chwfirst_anycare = 1 if p906 == "D"
replace fb_chwfirst_anycare = 1 if p904d == 1 & fb_provtot == 1
lab var fb_chwfirst_anycare "Sought care from CHW first"
lab val fb_chwfirst_anycare yn
tab fb_chwfirst_anycare survey, col

****reason(s) did not go to CHW for care (ENDLINE ONLY)
*Only gave one answer
tab p906B
replace p906B = "" if p906B == "---"
replace p906B = "E" if p906B == "X" & p906B_outros == "os curandeiros é quem Sabe tratar essas doenças"
replace p906B = "G" if p906B == "X" & p906B_outros == "NAo existe APE nesta comunidade"
replace p906B = "G" if p906B == "X" & p906B_outros == "NAo tem APE  formado neste comunidade"
replace p906B = "G" if p906B == "X" & p906B_outros == "nao conhecia o APE"
replace p906B = "G" if p906B == "X" & p906B_outros == "nao tinha conhecimento do APE nessa comunidade"
replace p906B = "G" if p906B == "X" & p906B_outros == "O APE passou transferência"
replace p906B = "G" if p906B == "X" & p906B_outros == "NAo tem APE nesta comunidade"
replace p906B = "G" if p906B == "X" & p906B_outros == "Nao conhece o APE"
gen p906Ba = 1 if p906B == "A"
gen p906Bb = 1 if p906B == "B"
gen p906Bc = 1 if p906B == "C"
gen p906Bd = 1 if p906B == "D"
gen p906Be = 1 if p906B == "E"
gen p906Bf = 1 if p906B == "F"
gen p906Bg = 1 if p906B == "G"
gen p906Bx = 1 if p906B == "X"
gen p906Bz = 1 if p906B == "Z"

foreach var of varlist p906Ba-p906Bz {
  replace `var' = 0 if `var' == . & p906B != "---" & p906B != ""
  lab val `var' yn
}

*assessed for fast breathing (INDICATOR 12) 
tab p907 
recode p907 2 8 .=0, gen(fb_assessed)
replace fb_assessed =. if c_case != 1
lab var fb_assessed "Assesed for fast breathing?"
lab val fb_assessed yn
tab fb_assessed 
*1 response missing

*assessed for fast breathing by a CHW
gen fb_assessedchw = .
replace fb_assessedchw = 0 if p904d == 1
replace fb_assessedchw = 1 if p907 == 1 & (p908_a == 1 | strpos(p908, "A"))
lab var fb_assessedchw "Assessed for fast breathing by CHW"
lab val fb_assessedchw yn
tab fb_assessedchw

* where was the assessment done?  //Not in the Mozambique Survey 

* who performed the assessment?
***Endline
gen p908a = 1 if strpos(p908,"A") 
gen p908b = 1 if strpos(p908,"B") 
gen p908c = 1 if strpos(p908,"C") 
gen p908d = 1 if strpos(p908,"D") 
gen p908e = 1 if strpos(p908,"E") 
gen p908f = 1 if strpos(p908,"F") 
gen p908x = 1 if strpos(p908,"X") 
gen p908z = 1 if strpos(p908,"Z") 

foreach var of varlist p908a-p908z {
  replace `var' = 0 if `var' == . & p907 == 1
  lab val `var' yn
  }

* received any treatment (INDICATOR 24, OPTIONAL)
***Endline
gen p910a = 1 if strpos(p910,"A") 
gen p910b = 1 if strpos(p910,"B") 
gen p910c = 1 if strpos(p910,"C") 
gen p910d = 1 if strpos(p910,"D") 
gen p910e = 1 if strpos(p910,"E") 
gen p910f = 1 if strpos(p910,"F")
gen p910g = 1 if strpos(p910,"G") 
gen p910h = 1 if strpos(p910,"H") 
gen p910x = 1 if strpos(p910,"X") 
gen p910z = 1 if strpos(p910,"Z") 

egen fb_rxany = rownonmiss(p910a-p910h)
replace fb_rxany = 1 if fb_rxany > 0 & fb_rxany !=.
replace fb_rxany = . if c_case != 1
lab var fb_rxany "Took any medication for fast breathing"
lab val fb_rxany yn
tab fb_rxany

foreach var of varlist p910a-p910z {
  replace `var' = 0 if `var' == . & p909 == 1
  lab val `var' yn
}

* treated with first line antibiotics (INDICATOR 13D)  
gen fb_flab = 1 if p910e == 1
replace fb_flab = 0 if fb_flab ==. & c_case == 1
replace fb_flab =. if c_case != 1
lab var fb_flab "Took first line antibiotic for fast breathing"
lab val fb_flab yn
tab fb_flab 

*where did caregiver get firstline antibiotic?  
tab p912 

*Organize locations of treatment by categories in the report template
gen fb_flab_public = 1 if p912 == 11 | p912 == 12
gen fb_flab_private = 1 if p912 == 14
gen fb_flab_chw = 1 if p912 == 15
gen fb_flab_store = 1 if p912 == 22 | p912 == 23 | p912 == 27
gen fb_flab_trad = 1 if p912 == 21
gen fb_flab_other = 1 if p912 == 26 | p912 == 31

foreach var of varlist fb_flab_* {
  replace `var' = 0 if `var' == . & p910e == 1
  lab val `var' yn
  }

* treated by CHW with first line antibiotics (INDICATOR 14D) 
gen fb_flabchw = 0 if c_case == 1
replace fb_flabchw = 1 if p910e == 1 & p912 == 15 
replace fb_flabchw =. if c_case != 1
lab var fb_flabchw "Got first line antibiotic for fast breathing from CHW"
lab val fb_flabchw yn
tab fb_flabchw 

* treated with any antibiotic
gen fb_abany =.
replace fb_abany = 0 if c_case == 1
replace fb_abany = 1 if p910e == 1 | p910f == 1
lab var fb_abany "Took antibiotic for fast breathing"
lab val fb_abany yn
tab fb_ab 

* treated with any antibiotic among children who received any med (INDICATOR 25, OPTIONAL)
gen fb_ab =.
replace fb_ab = 0 if fb_rxany == 1
replace fb_ab = 1 if p910e == 1 | p910f == 1
lab var fb_ab "Took antibiotic for fast breathing among children who received any med"
lab val fb_ab yn
tab fb_ab 

*if from CHW, did child take antibiotic in presence of CHW? (INDICATOR 15C)  
tab p914 
clonevar fb_flab_chwp = p914
lab var fb_flab_chwp "Child took antibiotic in presence of CHW?"
lab val fb_flab_chwp yn
tab fb_flab_chwp

*if from CHW, did caregiver get counseled on how to give antibiotic at home? (INDICATOR 16C)
tab p915 
clonevar fb_flab_chwc = p915 
lab var fb_flab_chwc "Caregiver was counseled on how to give antibiotics at home?"
lab val fb_flab_chwc yn
tab fb_flab_chwc 

*if CHW visited, was available at first visit
tab p917 
clonevar fb_chwavail = p917 
lab var fb_chwavail "CHW was available at first visit?"
lab val fb_chwavail yn
tab fb_chwavail

*if CHW visited, did CHW refer the child to a health center?
tab p918 
recode p918 2 8=0, gen(fb_chwrefer)
lab var fb_chwrefer "CHW refered child to health center?"
lab val fb_chwrefer yn
tab fb_chwrefer

***completed CHW referral (INDICATOR 17C)
tab p919
recode p919 2=0, gen(fb_referadhere) 
lab var fb_referadhere "Completed CHW referral?"
lab val fb_referadhere yn
tab fb_referadhere

***reason did not comply with CHW referral
tab p920

gen p920a = 1 if strpos(p920,"A")
gen p920b = 1 if strpos(p920,"B")
gen p920c = 1 if strpos(p920,"C")
gen p920d = 1 if strpos(p920,"D")
gen p920e = 1 if strpos(p920,"E")
gen p920f = 1 if strpos(p920,"F")
gen p920g = 1 if strpos(p920,"G")
gen p920h = 1 if strpos(p920,"H")
gen p920i = 1 if strpos(p920,"I")
gen p920x = 1 if strpos(p920,"X")

foreach var of varlist p920a-p920x {
  replace `var' = 0 if `var' == . & fb_referadhere == 0
  lab val `var' yn
}

***CHW follow-up (INDICATOR 18C)
tab p921
recode p921 2 3=0, gen(fb_chw_fu)
lab var fb_chw_fu "CHW followed up sick child"
lab val fb_chw_fu yn
tab fb_chw_fu 

***when was CHW follow-up
tab p922
clonevar fb_when_fu = p922
replace fb_when_fu = . if p921 == 2
lab var fb_when_fu "When did CHW followed up sick child"
tab fb_when_fu 

***CHW follow-up (INDICATOR 18C)
tab p921 survey
recode p921 1 3=0 2=1, gen(fb_chw_fu2)
*replace fb_chw_fu2 = 0 if fb_chw_fu2 == 1 & p922 > 3
lab var fb_chw_fu2 "Caregiver visit CHW for follow-up"
lab val fb_chw_fu2 yn
tab fb_chw_fu2

***when was CHW follow-up
gen fb_when_fu2 = .
replace fb_when_fu2 = p922
replace fb_when_fu2 = . if p921 == 1
lab var fb_when_fu2 "When did caregiver visit CHW for follow-up"
tab fb_when_fu2

save "illness_analysis32.dta", replace

********************************************************************************
********************************************************************************
*Key endline indicators, disaggregated by sex
********DIARRHEA
*Sought any care
svyset clust
svy: tab p702 p103d

*Sought care from an appropriate provider
svy: tab d_app_prov p103d

*Sought care from a CHW
svy: tab d_chw p103d

*CHW was first source of care
svy: tab d_chwfirst p103d

*Same or more to drink
svy: tab d_cont_fluids p103d

*Took ORS
svy: tab d_ors p103d

*Took zinc
svy: tab d_zinc p103d

*Took homemade fluid
svy: tab d_hmfl p103d

*Took ORS and zinc
svy: tab d_orszinc p103d

********FEVER
*Sought any care
svy: tab p804 p103f

*Sought care from an appropriate provider
svy: tab f_app_prov p103f

*Sought care from a CHW
svy: tab f_chw p103f

*CHW was first source of care
svy: tab f_chwfirst p103f

*Had blood drawn
svy: tab f_bloodtaken p103f

*Got test results
svy: tab f_gotresult p103f

*Test results positive
svy: tab p813 p103f

*Any antimalarial
svy: tab f_antim p103f

*ACT
svy: tab f_act p103f

*ACT within 24 hours
svy: tab f_act24 p103f

*Any antimalarial after positive blood test
*Can't use col because 100%
*svy: tab f_antimc p103f
svy: tab f_antimc p103f if survey == 2

*ACT after positive blood test
svy: tab f_actc p103f

*ACT within 24 hours after positive blood test
svy: tab f_actc24 p103f

*******FAST BREATHING
*Sought any care
svy: tab p901 p103c

*Sought care from an appropriate provider
svy: tab fb_app_prov p103c

*Sought care from a CHW
svy: tab fb_chw p103c

*CHW was first source of care
svy: tab fb_chwfirst p103c

*Had breathing assessed
svy: tab fb_assessed p103c

*Took any antibiotic
svy: tab fb_abany p103c

*Took firstline antibiotic
svy: tab fb_flab p103c

save "illness_analysis32", replace

********************************************************************************
********************************************************************************
*Key indicators, across all three illnesses

*care-seeking from an appropriate provider, all 3 illnesses
gen all_app_prov = 0
replace all_app_prov = 1 if (d_case == 1 & d_app_prov == 1) | (f_case == 1 & f_app_prov == 1) | (c_case == 1 & fb_app_prov == 1)

*CHW first source of care, all 3 illnesses
gen all_chwfirst = 0
replace all_chwfirst = 1 if (d_case == 1 & d_chwfirst == 1) | (f_case == 1 & f_chwfirst == 1) | (c_case == 1 & fb_chwfirst == 1)

*Correct treatment, all 3 illnesses
gen all_correct_rx = 0 if (d_case == 1 & d_zinc !=.) | (f_case == 1 & f_result == 1 ) | c_case == 1
replace all_correct_rx = 1 if (d_case == 1 & d_orszinc == 1) | (f_case == 1 & f_actc24 == 1) | (c_case == 1 & fb_flab == 1)

*Correct treatment from a CHW, all 3 illnesses
gen all_correct_rxchw = 0 if (d_case == 1 & d_zinc !=.) | (f_case == 1 & f_result == 1 & p104f >= 6) | c_case == 1
replace all_correct_rxchw = 1 if (d_case == 1 & d_orszincchw == 1) | (f_case == 1 & f_actc24chw == 1) | (c_case == 1 & fb_flabchw == 1)

*Received 1st dose treatment in front of CHW, all 3 illnesses
gen all_firstdose = .
replace all_firstdose = 0 if (p710==15 & p715==15 & d_case == 1) | (p817==15 & f_case == 1) | (p912==15 & c_case == 1)
replace all_firstdose = 1 if (d_case == 1 & p710==15 & p712 == 1 & p715==15 & p717==1) | (f_case == 1 & p817==15 & p820 == 1) | (c_case == 1 & p912 ==15 & p914 == 1)

*Received counseling on treatment administration from CHW, all 3 illnesses
gen all_counsel = .
replace all_counsel = 0 if (p710==15 & p715==15 & d_case == 1 ) | (p817==15 & f_case == 1) | (p912==15 & c_case == 1)
replace all_counsel = 1 if (d_case == 1 & p710==15 & p713 == 1 & p715==15 & p718==1) | (f_case == 1 & p817==15 & p821 == 1) | (c_case == 1 & p912 ==15 & p915 == 1)
replace all_counsel = . if p821 ==. & p817 == 15 & all_counsel !=.

*Adhered to referral advice from CHW, all 3 illnesses
gen all_referadhere = .
replace all_referadhere = 0 if (p724 !=. & d_case == 1 ) | (p825 !=. & f_case == 1) | (p919 !=. & c_case == 1)
replace all_referadhere = 1 if (d_case == 1 & p724==1) | (f_case == 1 & p825 == 1) | (c_case == 1 & p919 == 1)

*Received a follow-up visit from a CHW, all 3 illnesses
gen all_followup = .
replace all_followup = 0 if ((d_chw == 1) & d_case == 1 ) | (f_chw & f_case == 1) | (fb_chw == 1 & c_case == 1)
replace all_followup = 1 if (d_case == 1 & d_chw == 1 & d_chw_fu == 1) | (f_case == 1 & f_chw == 1 & f_chw_fu == 1) | (c_case == 1 & fb_chw == 1 & fb_chw_fu == 1)
replace all_followup = . if (p827 ==. & f_case == 1) | (p921 ==. & c_case == 1) | (p726 ==. & d_case == 1)

*decided to seek care from an appropriate provider jointly, all 3 illnesses
gen all_app_joint = .
replace all_app_joint = 0 if survey == 2 
replace all_app_joint = 1 if (d_case == 1 & d_app_joint == 1) | (f_case == 1 & f_app_joint == 1) | (c_case == 1 & fb_app_joint == 1)
replace all_app_joint = . if union != 1

*decided to seek care jointly, all 3 illnesses
gen all_joint = .
replace all_joint = 0 if survey == 2 
replace all_joint = 1 if (d_case == 1 & d_joint == 1) | (f_case == 1 & f_joint == 1) | (c_case == 1 & fb_joint == 1)
replace all_joint = . if union != 1

*did not seek care, all 3 illnesses
gen all_nocare = 0
replace all_nocare = 1 if (p702 != 1 & d_case == 1) | (p804 != 1 & f_case == 1) | (p901 != 1 & c_case == 1)

*sought care but not from a CHW, all 3 illnesses
gen all_nocarechw = .
replace all_nocarechw = 0 if (p702 == 1 & d_case == 1) | (p804 == 1 & f_case == 1) | (p901 == 1 & c_case == 1)
replace all_nocarechw = 1 if (p702 == 1 & p705d != 1 & d_case == 1) | (p804 == 1 & p807d != 1 & f_case == 1) | (p901 == 1 & p904d != 1 & c_case == 1)

*where sought care first, all 3 illnesses
gen all_firstcare = .
replace all_firstcare = d_firstcare if d_case == 1
replace all_firstcare = f_firstcare if f_case == 1
replace all_firstcare = fb_firstcare if c_case == 1

*sources of care, all 3 illnesses
gen all_cs_public = .
replace all_cs_public = 0 if p702 == 1 | p804 == 1 | p901 == 1
replace all_cs_public = 1 if d_cs_public == 1 | f_cs_public == 1 | fb_cs_public == 1

gen all_cs_private = .
replace all_cs_private = 0 if p702 == 1 | p804 == 1 | p901 == 1
replace all_cs_private = 1 if d_cs_private == 1 | f_cs_private == 1 | fb_cs_private == 1

gen all_cs_chw = .
replace all_cs_chw = 0 if p702 == 1 | p804 == 1 | p901 == 1
replace all_cs_chw = 1 if d_cs_chw == 1 | f_cs_chw == 1 | fb_cs_chw == 1

gen all_cs_store = .
replace all_cs_store = 0 if p702 == 1 | p804 == 1 | p901 == 1
replace all_cs_store = 1 if d_cs_store == 1 | f_cs_store == 1 | fb_cs_store == 1

gen all_cs_trad = .
replace all_cs_trad = 0 if p702 == 1 | p804 == 1 | p901 == 1
replace all_cs_trad = 1 if d_cs_trad == 1 | f_cs_trad == 1 | fb_cs_trad == 1

gen all_cs_other = .
replace all_cs_other = 0 if p702 == 1 | p804 == 1 | p901 == 1
replace all_cs_other = 1 if d_cs_other == 1 | f_cs_other == 1 | fb_cs_other == 1

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


*reasons for not seeking care, endline only
gen all_nocare_a = .
replace all_nocare_a = 1 if p707Ca == 1 | p829a == 1 | p923a == 1
replace all_nocare_a = 0 if all_nocare_a == . & survey == 2 & ( p702 == 0 | p804 == 0 | p901 == 0)

gen all_nocare_b = .
replace all_nocare_b = 1 if p707Cb == 1 | p829b == 1 | p923b == 1
replace all_nocare_b = 0 if all_nocare_b == . & survey == 2 & ( p702 == 0 | p804 == 0 | p901 == 0)

gen all_nocare_c = .
replace all_nocare_c = 1 if p707Cc == 1 | p829c == 1 | p923c == 1
replace all_nocare_c = 0 if all_nocare_c == . & survey == 2 & ( p702 == 0 | p804 == 0 | p901 == 0)

gen all_nocare_d = .
replace all_nocare_d = 1 if p707Cd == 1 | p829d == 1 | p923d == 1
replace all_nocare_d = 0 if all_nocare_d == . & survey == 2 & ( p702 == 0 | p804 == 0 | p901 == 0)

gen all_nocare_e = .
replace all_nocare_e = 1 if p707Ce == 1 | p829e == 1 | p923e == 1
replace all_nocare_e = 0 if all_nocare_e == . & survey == 2 & ( p702 == 0 | p804 == 0 | p901 == 0)

gen all_nocare_f = .
replace all_nocare_f = 1 if p707Cf == 1 | p829f == 1 | p923f == 1
replace all_nocare_f = 0 if all_nocare_f == . & survey == 2 & ( p702 == 0 | p804 == 0 | p901 == 0)

gen all_nocare_g = .
replace all_nocare_g = 1 if p707Cg == 1 | p829g == 1 | p923g == 1
replace all_nocare_g = 0 if all_nocare_g == . & survey == 2 & ( p702 == 0 | p804 == 0 | p901 == 0)

gen all_nocare_x = .
replace all_nocare_x = 1 if p707Cx == 1 | p829x == 1 | p923x == 1
replace all_nocare_x = 0 if all_nocare_x == . & survey == 2 & ( p702 == 0 | p804 == 0 | p901 == 0)

gen all_nocare_z = .
replace all_nocare_z = 1 if p707Cz == 1 | p829z == 1 | p923z == 1
replace all_nocare_z = 0 if all_nocare_z == . & survey == 2 & ( p702 == 0 | p804 == 0 | p901 == 0)

*reasons for not seeking care from a CHW among those who sought care, endline only
gen all_nocarechw_a = .
replace all_nocarechw_a = 0 if survey == 2 & ((p702 == 1 & d_chw == 0) | (p804 == 1 & f_chw == 0) | (p901 == 1 & fb_chw == 0))
replace all_nocarechw_a = 1 if p707Ba == 1 | p809Ba == 1 | p906Ba == 1

gen all_nocarechw_b = .
replace all_nocarechw_b = 1 if p707Bb == 1 | p809Bb == 1 | p906Bb == 1
replace all_nocarechw_b = 0 if all_nocarechw_b == . & survey == 2 & ((p702 == 1 & d_chw == 0) | (p804 == 1 & f_chw == 0) | (p901 == 1 & fb_chw == 0))

gen all_nocarechw_c = .
replace all_nocarechw_c = 1 if p707Bc == 1 | p809Bc == 1 | p906Bc == 1
replace all_nocarechw_c = 0 if all_nocarechw_c == . & survey == 2 & ((p702 == 1 & d_chw == 0) | (p804 == 1 & f_chw == 0) | (p901 == 1 & fb_chw == 0))

gen all_nocarechw_d = .
replace all_nocarechw_d = 1 if p707Bd == 1 | p809Bd == 1 | p906Bd == 1
replace all_nocarechw_d = 0 if all_nocarechw_d == . & survey == 2 & ((p702 == 1 & d_chw == 0) | (p804 == 1 & f_chw == 0) | (p901 == 1 & fb_chw == 0))

gen all_nocarechw_e = .
replace all_nocarechw_e = 1 if p707Be == 1 | p809Be == 1 | p906Be == 1
replace all_nocarechw_e = 0 if all_nocarechw_e == . & survey == 2 & ((p702 == 1 & d_chw == 0) | (p804 == 1 & f_chw == 0) | (p901 == 1 & fb_chw == 0))

gen all_nocarechw_f = .
replace all_nocarechw_f = 1 if p707Bf == 1 | p809Bf == 1 | p906Bf == 1
replace all_nocarechw_f = 0 if all_nocarechw_f == . & survey == 2 & ((p702 == 1 & d_chw == 0) | (p804 == 1 & f_chw == 0) | (p901 == 1 & fb_chw == 0))

gen all_nocarechw_g = .
replace all_nocarechw_g = 1 if p707Bg == 1 | p809Bg == 1 | p906Bg == 1
replace all_nocarechw_g = 0 if all_nocarechw_g == . & survey == 2 & ((p702 == 1 & d_chw == 0) | (p804 == 1 & f_chw == 0) | (p901 == 1 & fb_chw == 0))

gen all_nocarechw_x = .
replace all_nocarechw_x = 1 if p707Bx == 1 | p809Bx == 1 | p906Bx == 1
replace all_nocarechw_x = 0 if all_nocarechw_x == . & survey == 2 & ((p702 == 1 & d_chw == 0) | (p804 == 1 & f_chw == 0) | (p901 == 1 & fb_chw == 0))

gen all_nocarechw_z = .
replace all_nocarechw_z = 1 if p707Bz == 1 | p809Bz == 1 | p906Bz == 1
replace all_nocarechw_z = 0 if all_nocarechw_z == . & survey == 2 & ((p702 == 1 & d_chw == 0) | (p804 == 1 & f_chw == 0) | (p901 == 1 & fb_chw == 0))

*reasons for not complying with CHW referral
gen all_noadhere_a = .
replace all_noadhere_a = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_a = 1 if p725a == 1 | p826a == 1 | p920a == 1

gen all_noadhere_b = .
replace all_noadhere_b = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_b = 1 if p725b == 1 | p826b == 1 | p920b == 1

gen all_noadhere_c = .
replace all_noadhere_c = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_c = 1 if p725c == 1 | p826c == 1 | p920c == 1

gen all_noadhere_d = .
replace all_noadhere_d = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_d = 1 if p725d == 1 | p826d == 1 | p920d == 1

gen all_noadhere_e = .
replace all_noadhere_e = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_e = 1 if p725e == 1 | p826e == 1 | p920e == 1

gen all_noadhere_f = .
replace all_noadhere_f = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_f = 1 if p725f == 1 | p826f == 1 | p920f == 1

gen all_noadhere_g = .
replace all_noadhere_g = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_g = 1 if p725g == 1 | p826g == 1 | p920g == 1

gen all_noadhere_h = .
replace all_noadhere_h = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_h = 1 if p725h == 1 | p826h == 1 | p920h == 1

gen all_noadhere_i = .
replace all_noadhere_i = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_i = 1 if p725i == 1 | p826i == 1 | p920i == 1

gen all_noadhere_x = .
replace all_noadhere_x = 0 if d_referadhere == 0 | f_referadhere == 0 | fb_referadhere == 0
replace all_noadhere_x = 1 if p725x == 1 | p826x == 1 | p920x == 1

*When was CHW follow-up?
gen all_when_fu = .
replace all_when_fu = p727 if p726 == 1 
replace all_when_fu = p828 if p827 == 1
replace all_when_fu = p922 if p921 == 1

*CHW first source of care, all 3 illnesses
gen all_chwfirst_anycare =.
replace all_chwfirst_anycare = 0 if p702 == 1 | p804 == 1 | p901 == 1
replace all_chwfirst_anycare = 1 if (d_case == 1 & d_chwfirst_anycare == 1) | (f_case == 1 & f_chwfirst_anycare == 1) | (c_case == 1 & fb_chwfirst_anycare == 1)

foreach x of varlist all* {
  tab `x' 
}

*treated with ORS AND Zinc by CHW, among those who sought care from a CHW
gen d_orszincchw2 = .
replace d_orszincchw2 = 0 if d_chw == 1 & d_zinc !=.
replace d_orszincchw2 = 1 if d_orszincchw == 1 & d_chw == 1
lab var d_orszincchw2 "Got ORS & zinc from CHW, among those who sought care from a CHW"
lab val d_orszincchw2 yn
tab d_orszincchw2 survey, col

***ACT treatment with 24 hours from CHW - positive blood test, among those who sought care from a CHW
gen f_act24cchw2 = .
replace f_act24cchw2 = 0 if  f_chw == 1 & f_result == 1 & p104f >= 6
replace f_act24cchw2 = 1 if f_actc24chw == 1 & f_chw == 1 & p104f >= 6
lab var f_act24cchw2 "ACT treatment within 24 hours by a CHW - blood test+, among those who sought care from a CHW"
lab val f_act24cchw2 yn
tab f_act24cchw2 survey, col

* treated with first line antibiotics by a CHW, among those who sought care from a CHW
gen fb_flabchw2 = .
replace fb_flabchw2 = 0 if fb_chw == 1
replace fb_flabchw2 = 1 if fb_flabchw == 1 & fb_chw == 1
lab var fb_flabchw2 "Got 1st line antibiotic from CHW, among those who sought care from CHW"
lab val fb_flabchw2 yn
tab fb_flabchw2 survey, col

* appropriate treatment, all 3 illnesses, among those who sought care from a CHW
gen all_correct_rxchw2 = .
replace all_correct_rxchw2 = 0 if (d_case == 1 & d_chw == 1 & d_zinc !=.) | (f_case == 1 & f_result == 1 & f_chw == 1 & p104f >= 6) | (c_case == 1 & fb_chw == 1)
replace all_correct_rxchw2 = 1 if (d_case == 1 & d_orszincchw2 ==1) | (f_case == 1 & f_act24cchw2 ==1) | (c_case == 1 & fb_flabchw2 ==1)

*Caregiver returned to CHW for follow-up, all 3 illnesses
gen all_followup2 = .
replace all_followup2 = 0 if ((d_chw == 1) & d_case == 1 ) | (f_chw & f_case == 1) | (fb_chw == 1 & c_case == 1)
replace all_followup2 = 1 if (d_case == 1 & d_chw == 1 & d_chw_fu2 == 1) | (f_case == 1 & f_chw == 1 & f_chw_fu2 == 1) | (c_case == 1 & fb_chw == 1 & fb_chw_fu2 == 1)
replace all_followup2 = . if (p827 ==. & f_case == 1) | (p921 ==. & c_case == 1) | (p726 ==. & d_case == 1)

*When did caregiver visit CHW for follow-up?
gen all_when_fu2 = .
replace all_when_fu2 = p727 if p726 == 2 
replace all_when_fu2 = p828 if p827 == 2
replace all_when_fu2 = p922 if p921 == 2

save "illness_analysis32", replace


*Determine characteristics of children included in survey
cd "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Mozambique\Final Data\Moz RAcE Data analysis"

***Endline
use "module7_mergeready", clear
gen lineno = lineno_d
save "module7_mergeready2", replace

use "module8_mergeready", clear
gen lineno = lineno_f
save "module8_mergeready2", replace

use "module9_mergeready", clear
gen lineno = lineno_c
save "module9_mergeready2", replace

use "module7_mergeready2", clear
merge 1:1 hhid lineno using "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Mozambique\Final Data\Moz RAcE Data analysis\module8_mergeready2.dta"
drop _merge
merge 1:1 hhid lineno using "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Mozambique\Final Data\Moz RAcE Data analysis\module9_mergeready2.dta"
drop _merge
merge m:1 roster_no using "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Mozambique\Final Data\Moz RAcE Data analysis\Endline\Module 1 Child Group.dta", keepusing(p103- p108)
drop if _merge == 2
drop _merge
drop if survey == 1
save "three_illnesses_32el", replace

replace p104 = "" if p104 == "---"
destring p104, replace
recode p104 2011 2012 2013 98 = .
drop if p104 < 2

svyset numconglomerado
*Age of sick children included in survey
recode p104 2/11 = 1 12/23 = 2 24/35 = 3 36/47=4 48/59 = 5, gen(agecat)
lab var agecat "Child's age by year"
lab def age_cat 1 "0-11 months" 2 "12-23 months" 3 "24-35 months" 4 "36-47 months" 5 "48-59 months"
lab val agecat age_cat
tab agecat survey, m
svy: prop agecat

*Sex of sick children included in survey
tab p103
destring p103, replace
svy: prop p103

*Two-week history of illness of sick children included in survey
replace p106 = "" if p106 == "---"
replace p108 = "" if p108 == "---"
destring p105 p106 p108, replace

recode p105 . 2=0
recode p106 . 2=0
recode p108 . 2=0

*gen no_illness = p105 + p106 + p108
*Ten cases were listed as having no illness, but all were cases of cough with fast breathing.
*replace no_illness = 1 if no_illness == 0
*Total number of sick kids included in survey
count
*Number of selected sick kids with fever
tab p105
*Number of selected sick kids with diarrhea
tab p106
*Number of selected sick kids with cough with fast or difficult breathing
tab p108

svy: prop p105
svy: prop p106
svy: prop p108
svy: mean no_illness

save "three_illnesses_32el", replace
