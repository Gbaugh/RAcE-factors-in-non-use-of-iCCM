*******************************************
** Niger State (MC) RAcE Survey Analysis **
**Variable Creation and Analysis do File **
**     Allison Schmale April 12, 2017    **
*******************************************

cd "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Nigeria - MC\Allison's analysis 4.17.2017"
set more off

use "Niger State_complete_BL_EL.dta", clear

*Create a value label for binary variables that are recoded 0/1
lab define yn 0 "No" 1 "Yes"

*Define survey parameters that account for the cluster variable
svyset hhclust

****************MODULE 1: Sick child information********************************
*Sex, age and 2-week history of illness of selected children
***In a different do file

*Create binary variable = child has illness from line number variable
recode q7child 1 2 3 4 5 6 7 8 9 = 1 0=0, gen(d_case)
recode q8child 1 2 3 4 5 6 7 8 18 = 1 0=0, gen(f_case)
recode q9child 1 2 3 4 5 6 7 8 12 = 1 0=0, gen(fb_case)

tab d_case survey,m
tab f_case survey,m
tab fb_case survey,m

*Total number of children
***In a different do file

*Total number of children included in survey
gen tot_children = 0
replace tot_children = 1 if q109ch >= 1 & q109ch !=.
replace tot_children = tot_children + 1 if q110ch >= 1 & q110ch !=. & q110ch != q109ch
replace tot_children = tot_children + 1 if q111ch >= 1 & q111ch !=. & q111ch != q110ch & q111ch != q109ch
tab tot_children survey

preserve
collapse (sum) tot_children, by(survey)
tab tot_children survey
restore

***********************MODULE 2: Caregiver's Informaiton************************

*Caregiver's age, in categories
*recode q202 min/24=1 25/34=2 35/44=3 45/max=4, gen(cagecat)
recode q202 min/24=1 25/34=2 35/44=3 45/95=4, gen(cagecat)
lab var cagecat "Caregiver's age category"
lab define cagecat 1 "15-24" 2 "25-34" 3 "35-44" 4 "45+"
lab val cagecat cagecat
tab cagecat, m
*Analysis
svy: tab cagecat survey, col ci pear obs
svy: mean q202 if q202 <99, over(survey)


*Caregiver's education, in categories
tab q203 survey
tab q204 survey
tab q205 survey
gen cgeduccat = 0 if q203 == 2 | q203==9 | q204 == 9
replace cgeduccat = 1 if q204 == 1 
replace cgeduccat = 2 if q204 == 2 | q204 == 3
lab var cgeduccat "Caregiver's highest level of education"
lab define cgeduccat 0 "No school" 1 "Primary " 2 "Secondary or higher"
lab val cgeduccat cgeduccat
lab var cgeduccat "Caregiver's education"
tab cgeduccat, m
*Analysis 
svy: tab cgeduccat survey, col ci pear obs

*Marital Status, in categories
gen maritalstat = .
replace maritalstat = 1 if q401==1|q401==2
replace maritalstat = 2 if q401==3
lab var maritalstat "Caregiver's maritalstatus"
lab def maritalstat 1 "married/living with partner as married" 2 "not in union"
lab val maritalstat maritalstat
tab maritalstat, m
*Analysis 
svy: tab maritalstat survey, col ci pear obs

*Partner living with caregiver, among those in a union
tab q402, m
gen cg_livepart = .
replace cg_livepart = 0 if q402 == 2
replace cg_livepart = 1 if q402 == 1
replace cg_livepart = 9 if q402 == 9
lab var cg_livepart "Caregiver lives with partner"
lab def cg_livepart 1 "lives with husband/partner" 0 "does not live with husband/partner" 9 "missing"
lab val cg_livepart cg_livepart
tab cg_livepart, m
*Analysis
svy: tab cg_livepart survey, col ci pear obs

****************MODULE 5: Health center access**********************************

*Distance to nearest facility
tab q501, m
recode q501 min/4 = 1 5/9 = 2 10/14 = 3 15/29 = 4 30/45 = 5 98 = 6 99 = ., gen(discat)
lab var discat "Distance to nearest facility"
lab def discat 1 "<5 km" 2 "5-9 km" 3 "10-14 km" 4 "15-29 km" 5 "30+ km" 6 "don't know" 
lab val discat discat
tab discat, m
*Analysis
svy: tab discat survey, col ci pear obs
*KMZ: added the mean to the table template
svy: mean q501 if q501 <95, over(survey)

*Mode of transport to health facility of those that go to the health facility
tab q502, m
recode q502 2 = 1 3 = 2 4 5 6 = 3 9 = . 1 = ., gen(transport)
lab var transport "Mode of transport to health facility"
lab def transport 1 "Walk" 2 "Motorbike" 3 "Other"
lab val transport transport
tab transport, m
*Analysis
svy: tab transport survey, col ci pear obs

*Time to nearest facility 
tab q503, m
recode q503 min/30 = 1 30/59 = 2 60/119 = 3 120/240 = 4 999 = ., gen (timecat)
lab var timecat "Time to nearest facility"
lab def timecat 1 "<30 min" 2 "30-59 min" 3 "1-<2 hours" 4 "2 hours or more" 
lab val timecat timecat
tab timecat, m
*Analysis 
svy: tab timecat survey, col ci pear obs
*Mean
svy: mean q503 if  q503 < 95, over(survey)

*Time to nearest facility - among those who walk
tab q503, m
recode q503 min/30 = 1 30/59 = 2 60/119 = 3 120/240 = 4 999 = ., gen (timewalk)
replace timewalk =. if q502 != 2
lab var timewalk "Time to nearest facility among those who walk"
lab val timewalk timecat
tab timewalk survey, m
*Analysis 
svy: tab timewalk survey, col ci pear obs
*Mean
svy: mean q503 if q502 == 2 & timewalk != ., over(survey)

****************MODULE 4: Household decision making*****************************

*Income decision maker (INDICATOR 19, OPTIONAL)
tab q403, m
recode q403 6 = 4 9 = ., gen(dm_income)
lab var dm_income "Income decision making at household"
lab def dm_income 1 "Caregiver alone" 2 "Caregiver's husband/partner" 3 "Caregiver and partner jointly" 4 "Other"
lab val dm_income dm_income
tab dm_income, m
*Analysis
svy: tab dm_income survey, col ci pear obs

*Joint income decision making 
recode q403 1 2 4 6 = 0 3 = 1 9 = ., gen(dm_income_joint)
lab var dm_income_joint "Caregiver makes HH income decisions with partner"
lab val dm_income_joint yn
tab dm_income_joint, m
*Analysis
svy: tab dm_income_joint survey, col ci pear obs

*Health care decision maker (INDICATOR 20, OPTIONAL)
tab q404, m
recode q404 6 = 4, gen(dm_health)
lab var dm_health "Health care decision making at household"
lab val dm_health dm_income
tab dm_health, m
*Analysis
svy: tab dm_health survey, col ci pear obs

*Joint healthcare decision making 
recode q404 1 2 4 6 = 0 3 = 1, gen(dm_health_joint)
lab var dm_health_joint "Caregiver makes HH healthcare decisions with partner"
lab val dm_health_joint yn
tab dm_health_joint, m
*Analysis
svy: tab dm_health_joint survey, col ci pear obs

****************MODULE 6: Caregiver illness knowledge***************************

*Child illness signs
tab1 q601*

*Child under 2 months old
tab q601a, m
gen Q601a = 0
replace Q601a = 1 if q601a == "A"
lab var Q601a "Child under 2 months old"
lab val Q601a yn
tab Q601a, m
*analysis
svy: tab Q601a survey, col ci pear obs
*Fever
tab q601b, m
gen Q601b = 0 
replace Q601b = 1 if q601b == "B" & survey == 2
lab var Q601b "Fever"
lab val Q601b yn
tab Q601b, m
*analysis
svy: tab Q601b survey, col ci pear obs
*High Fever
tab q601c, m
tab q601b, m
gen Q601c = 0 
replace Q601c = 1 if (q601b == "B" & survey == 1)
replace Q601c = 1 if (q601c == "C" & survey == 2)
lab var Q601c "High fever"
lab val Q601c yn
tab Q601c, m
*analysis
svy: tab Q601c survey, col ci pear obs
*Fever for 7 days or more
tab q601d, m
tab q601c, m
gen Q601d = 0
replace Q601d = 1 if (q601c == "C" & survey == 1)
replace Q601d = 1 if (q601d == "D" & survey == 2)
lab var Q601d "Fever for 7 days or more"
lab val Q601d yn
tab Q601d, m
*analysis
svy: tab Q601d survey, col ci pear obs
*Diarrhea
tab q601e, m
gen Q601e = 0 
replace Q601e = 1 if q601e == "E" & survey == 2
lab var Q601e "Diarrhea"
lab val Q601e yn
tab Q601e, m
*analysis
svy: tab Q601e survey, col ci pear obs
*Diarrhea w/ blood in stool
tab q601f survey, m
tab q601d survey, m
gen Q601f = 0
replace Q601f = 1 if (q601d == "D" & survey == 1)
replace Q601f = 1 if (q601f == "F" & survey == 2)
lab var Q601f "Diarrhea w/ blood in stool"
lab val Q601f yn
tab Q601f, m
*analysis
svy: tab Q601f survey, col ci pear obs
*Diarrhea with dehydration
tab q601g survey, m
tab q601e survey, m
gen Q601g = 0
replace Q601g = 1 if (q601e == "E" & survey == 1)
replace Q601g = 1 if (q601g == "G" & survey == 2)
lab var Q601g "Diarrhea w/ dehydration"
lab val Q601g yn
tab Q601g, m
*analysis
svy: tab Q601g survey, col ci pear obs
*Diarrhea for 14+ days
tab q601h survey, m
tab q601f survey, m
gen Q601h = 0
replace Q601h = 1 if (q601f == "F" & survey == 1)
replace Q601h = 1 if (q601h == "H" & survey == 2)
lab var Q601h "Diarrhea for 14+ days"
lab val Q601h yn
tab Q601h, m
*analysis
svy: tab Q601h survey, col ci pear obs
*Fast or difficult breathing
tab q601i survey, m
tab q601g survey, m
gen Q601i = 0
replace Q601i = 1 if (q601g == "G" & survey == 1)
replace Q601i = 1 if (q601i == "I" & survey == 2)
lab var Q601i "Fast or difficult breathing"
lab val Q601i yn
tab Q601i, m
*analysis
svy: tab Q601i survey, col ci pear obs
*Chest in-drawing
tab q601j survey, m
tab q601g survey, m
gen Q601j = 0
replace Q601j = 1 if (q601g == "G" & survey == 1)
replace Q601j = 1 if (q601j == "J" & survey == 2)
lab var Q601j "Chest in-drawing"
lab val Q601j yn
tab Q601j, m
*analysis
svy: tab Q601j survey, col ci pear obs
*Cough
tab q601k survey, m
gen Q601k = 0 
replace Q601k = 1 if q601k == "K" & survey == 2
lab var Q601k "Cough"
lab val Q601k yn
tab Q601k, m
*analysis
svy: tab Q601k survey, col ci pear obs
*Cough for 21 days or more
tab q601l survey, m
tab q601h survey, m
gen Q601l = 0
replace Q601l = 1 if (q601h == "H" & survey == 1)
replace Q601l = 1 if (q601l == "L" & survey == 2)
lab var Q601l "Cough for 21 days or more"
lab val Q601l yn
tab Q601l, m
*analysis
svy: tab Q601l survey, col ci pear obs
*Refusal to breastfeed
tab q601m survey, m
tab q601i survey, m
gen Q601m = 0
replace Q601m = 1 if (q601i == "I" & survey == 1)
replace Q601m = 1 if (q601m == "M" & survey == 2)
lab var Q601m "Refusal to breastfeed"
lab val Q601m yn
tab Q601m, m
*analysis
svy: tab Q601m survey, col ci pear obs
*Not able to drink or feed
tab q601n survey, m
tab q601j survey, m
gen Q601n = 0
replace Q601n = 1 if (q601j == "J" & survey == 1)
replace Q601n = 1 if (q601n == "N" & survey == 2)
lab var Q601n "Not able to drink or feed"
lab val Q601n yn
tab Q601n, m
*analysis
svy: tab Q601n survey, col ci pear obs
*Vomiting everything
tab q601o survey, m
tab q601k survey, m
gen Q601o = 0
replace Q601o = 1 if (q601k == "K" & survey == 1)
replace Q601o = 1 if (q601o == "O" & survey == 2)
lab var Q601o "Vomiting everything"
lab val Q601o yn
tab Q601o, m
*analysis
svy: tab Q601o survey, col ci pear obs
*Yellow/red MUAC or swelling of both feet
tab q601p survey, m
tab q601l survey, m
gen Q601p = 0
replace Q601p = 1 if (q601l == "L" & survey == 1)
replace Q601p = 1 if (q601p == "P" & survey == 2)
lab var Q601p "Yellow/red MUAC or swelling of both feet"
lab val Q601p yn
tab Q601p, m
*analysis
svy: tab Q601p survey, col ci pear obs
*Convulsions
tab q601q survey, m
tab q601m survey, m
gen Q601q = 0
replace Q601q = 1 if (q601m == "M" & survey == 1)
replace Q601q = 1 if (q601q == "Q" & survey == 2)
lab var Q601q "Convulsions"
lab val Q601q yn
tab Q601q, m
*analysis
svy: tab Q601q survey, col ci pear obs
*Loss of consciousness
tab q601r survey, m
tab q601n survey, m
gen Q601r = 0
replace Q601r = 1 if (q601n == "N" & survey == 1)
replace Q601r = 1 if (q601r == "R" & survey == 2)
lab var Q601r "Loss of consciousness"
lab val Q601r yn
tab Q601r, m
*analysis
svy: tab Q601r survey, col ci pear obs
*Lethargic/tired/slow to respond/doesn't want to play
tab q601s survey, m
tab q601o survey, m
gen Q601s = 0
replace Q601s = 1 if (q601o == "O" & survey == 1)
replace Q601s = 1 if (q601s == "S" & survey == 2)
lab var Q601s "Lethargic/tired/slow response/won't play"
lab val Q601s yn
tab Q601s, m
*analysis
svy: tab Q601s survey, col ci pear obs
*Stiff neck
tab q601t survey, m
tab q601p survey, m
gen Q601t = 0
replace Q601t = 1 if (q601p == "P" & survey == 1)
replace Q601t = 1 if (q601t == "T" & survey == 2)
lab var Q601t "Lethargic/tired/slow response/won't play"
lab val Q601t yn
tab Q601t, m
*analysis
svy: tab Q601t survey, col ci pear obs
*Don't know
tab q601z survey, m
gen Q601z = 0
replace Q601z = 1 if (q601z == "Z" & survey == 1)
replace Q601z = 1 if (q601z == "Z" & survey == 2)
lab var Q601z "Don't know"
lab val Q601z yn
tab Q601z, m
*analysis
svy: tab Q601z survey, col ci pear obs

*Create a variable = total number of illness signs caregiver knows 
egen tot_q601 = anycount(Q601a-Q601t), value (1)
lab var tot_q601 "Total number of illness signs CG knows"
tab tot_q601, m

*CG knows two or more danger signs (INDICATOR 3)
gen cgdsknow2 = 0
replace cgdsknow2 = 1 if tot_q601 >= 2 & tot_q601 != .
lab var cgdsknow2 "Caregiver knows two or more danger signs"
lab val cgdsknow2 yn
tab cgdsknow2, m
*Analysis
svy: tab cgdsknow2 survey, col ci pear obs

*CG knows 3 or more danger signs (INDICATOR 3A)
gen cgdsknow3 = 0
replace cgdsknow3 = 1 if tot_q601 >= 3 & tot_q601 != .
lab var cgdsknow3 "Caregiver knows 3 or more danger signs"
lab val cgdsknow3 yn
tab cgdsknow3, m
*Analysis
svy: tab cgdsknow3 survey, col ci pear obs

*Heard of malaria-recode
tab q602, m
recode q602 8 9 =2 
tab q602, m

*Knows cause of malaria
tab1 q603*
gen malaria_get = .
replace malaria_get = 0 if q602 != .
replace malaria_get = 1 if q603a == "A"
lab var malaria_get "Caregiver knows mosquitos cause malaria"
lab val malaria_get yn
tab malaria_get, m
*Analysis
svy: tab malaria_get survey, col ci pear obs

*Knows fever is a sign of malaria
tab1 q604*
gen malaria_fev_sign = .
replace malaria_fev_sign = 0 if q602 != .
replace malaria_fev_sign = 1 if q604a == "A"
lab var malaria_fev_sign "Caregiver knows fever is a sign of malaria"
lab val malaria_fev_sign yn
tab malaria_fev_sign, m
*Analysis
svy: tab malaria_fev_sign survey, col ci pear obs

*Knows treatment for malaria
tab q605, m
gen malaria_rx = .
replace malaria_rx = 0 if q602 != .
replace malaria_rx = 1 if q605 == 1
lab var malaria_rx "Knows ACT is treatment for malaria"
lab val malaria_rx yn
tab malaria_rx, m
*Analysis
svy: tab malaria_rx survey, col ci pear obs

*Knows of diarrhea
tab q606, m
recode q606 8 9 = 2 
tab q606, m

*Knows treatment for diarrhea
tab1 q607*
gen diarrhea_rx = .
replace diarrhea_rx = 0 if q606 != .
replace diarrhea_rx = 1 if q607b == "B"
lab var diarrhea_rx "Knows ORS and Zn are treatment for diarrhea"
lab val diarrhea_rx yn
tab diarrhea_rx, m
*Analysis
svy: tab diarrhea_rx survey, col ci pear obs


****************MODULE 5: Caregiver knowledge & perceptions of iCCM CHWs********

*Knows CORP works in community (INDICATOR 1)
tab q504, m
recode q504 8 9 = 2, gen(chw_know)
replace chw_know = 0 if q504 != .
replace chw_know = 1 if q504 == 1
lab var chw_know "CG knows a CORP works in the community"
lab val chw_know yn
tab chw_know, m
*Analysis
svy: tab chw_know survey, col ci pear obs

*Knows location of CORP 
tab q506, m
recode q506 8 9 = 0, gen (chw_loc)
replace chw_loc = 0 if q506 == 0
replace chw_loc = 1 if q506 == 1 
lab var chw_loc "CHW knows location of CORP"
lab val chw_loc yn
tab chw_loc, m
*Analysis
svy: tab chw_loc survey, col ci pear obs

*CORP Activities
*community mobilization
tab q505a, m
gen q505_a = .
replace q505_a = 0 if chw_know == 1
replace q505_a = 1 if q505a == "A"
lab var q505_a "community mobilization"
lab val q505_a yn
tab q505_a, m
*analysis
svy: tab q505_a survey, col ci pear obs
*distribution of LLINs
tab q505b, m
gen q505_b = .
replace q505_b = 0 if chw_know == 1
replace q505_b = 1 if q505b == "B"
lab var q505_b "distribution of LLINs"
lab val q505_b yn
tab q505_b, m
*analysis
svy: tab q505_b survey, col ci pear obs
*organize health campaigns
tab q505c, m
gen q505_c = .
replace q505_c = 0 if chw_know == 1
replace q505_c = 1 if q505c == "C"
lab var q505_c "org health campaigns"
lab val q505_c yn
tab q505_c, m
*analysis
svy: tab q505_c survey, col ci pear obs
*dissemination of health messages
tab q505d, m
gen q505_d = .
replace q505_d = 0 if chw_know == 1
replace q505_d = 1 if q505d == "D"
lab var q505_d "disseminate health messages"
lab val q505_d yn
tab q505_d, m
*analysis
svy: tab q505_d survey, col ci pear obs
*help hang nets in households
tab q505e, m
gen q505_e = .
replace q505_e = 0 if chw_know == 1
replace q505_e = 1 if q505e == "E"
lab var q505_e "hang nets in HHs"
lab val q505_e yn
tab q505_e, m
*analysis
svy: tab q505_e survey, col ci pear obs
*provide health information in households
tab q505f, m
gen q505_f = .
replace q505_f = 0 if chw_know == 1
replace q505_f = 1 if q505f == "F"
lab var q505_f "provide health info to HHs"
lab val q505_f yn
tab q505_f, m
*analysis
svy: tab q505_f survey, col ci pear obs
*provide health information at community events
tab q505g, m
gen q505_g = .
replace q505_g = 0 if chw_know == 1
replace q505_g = 1 if q505g == "G"
lab var q505_g "provide health info at comm events"
lab val q505_g yn
tab q505_g, m
*analysis
svy: tab q505_g survey, col ci pear obs
*provide water treatment tablets
tab q505h, m
gen q505_h = .
replace q505_h = 0 if chw_know == 1
replace q505_h = 1 if q505h == "H"
lab var q505_h "provide water tx tablets"
lab val q505_h yn
tab q505_h, m
*analysis
svy: tab q505_h survey, col ci pear obs
*collect information on health
tab q505i, m
gen q505_i = .
replace q505_i = 0 if chw_know == 1
replace q505_i = 1 if q505i == "I"
lab var q505_i "collect information on health"
lab val q505_i yn
tab q505_i, m
*analysis
svy: tab q505_i survey, col ci pear obs
*other preventative activity
tab q505j, m
gen q505_j = .
replace q505_j = 0 if chw_know == 1
replace q505_j = 1 if q505j == "J"
lab var q505_j "other preventative activity"
lab val q505_j yn
tab q505_j, m
*analysis
svy: tab q505_j survey, col ci pear obs
*refer to health facility
tab q505k, m
gen q505_k = .
replace q505_k = 0 if chw_know == 1
replace q505_k = 1 if q505k == "K"
lab var q505_k "refer to health facility"
lab val q505_k yn
tab q505_k, m
*analysis
svy: tab q505_k survey, col ci pear obs
*test for malaria
tab q505l, m
gen q505_l = .
replace q505_l = 0 if chw_know == 1
replace q505_l = 1 if q505l == "L"
lab var q505_l "test for malaria"
lab val q505_l yn
tab q505_l, m
*analysis
svy: tab q505_l survey, col ci pear obs
*assess for suspected pneumonia
tab q505m, m
gen q505_m = .
replace q505_m = 0 if chw_know == 1
replace q505_m = 1 if q505m == "M"
lab var q505_m "assess for suspected pneumonia"
lab val q505_m yn
tab q505_m, m
*analysis
svy: tab q505_m survey, col ci pear obs
*provide treatment for malaria
tab q505n, m
gen q505_n = .
replace q505_n = 0 if chw_know == 1
replace q505_n = 1 if q505n == "N"
lab var q505_n "provide treatment for malaria"
lab val q505_n yn
tab q505_n, m
*analysis
svy: tab q505_n survey, col ci pear obs
*provide treatment for pneumonia
tab q505o, m
gen q505_o = .
replace q505_o = 0 if chw_know == 1
replace q505_o = 1 if q505o == "O"
lab var q505_o "provide treatment for pneumonia"
lab val q505_o yn
tab q505_o, m
*analysis-removed 'col' b/c single row table
svy: tab q505_o survey, ci pear obs
*provide ORS for diarrhea
tab q505p, m
gen q505_p = .
replace q505_p = 0 if chw_know == 1
replace q505_p = 1 if q505p == "P"
lab var q505_p "provide ORS for diarrhea"
lab val q505_p yn
tab q505_p, m
*analysis
svy: tab q505_p survey, col ci pear obs
*provide zinc for diarrhea
tab q505q, m
gen q505_q = .
replace q505_q = 0 if chw_know == 1
replace q505_q = 1 if q505q == "Q"
lab var q505_q "provide zinc for diarrhea"
lab val q505_q yn
tab q505_q, m
*analysis-removed 'col' b/c single row table
svy: tab q505_q survey, ci pear obs
*assess for malnutrition
tab q505r, m
gen q505_r = .
replace q505_r = 0 if chw_know == 1
replace q505_r = 1 if q505r == "R"
lab var q505_r "assess for malnutrition"
lab val q505_r yn
tab q505_r, m
*analysis
svy: tab q505_r survey, col ci pear obs
*follow up sick children at home
tab q505s, m
gen q505_s = .
replace q505_s = 0 if chw_know == 1
replace q505_s = 1 if q505s == "S"
lab var q505_s "f/u sick children at home"
lab val q505_s yn
tab q505_s, m
*analysis
svy: tab q505_s survey, col ci pear obs
*other curative services
tab q505t, m
gen q505_t = .
replace q505_t = 0 if chw_know == 1
replace q505_t = 1 if q505t == "T"
lab var q505_t "other curative services"
lab val q505_t yn
tab q505_t, m
*analysis-removed 'col' b/c single row table
svy: tab q505_t survey, ci pear obs
*don't know
tab q505z, m
gen q505_z = .
replace q505_z = 0 if chw_know == 1
replace q505_z = 1 if q505z == "Z"
lab var q505_z "don't know"
lab val q505_z yn
tab q505_z, m
*analysis
svy: tab q505_z survey, col ci pear obs

*Caregiver knows role of CORP (id's two curative services) (INDICATOR 2)
egen tot_q505 = anycount(q505_k-q505_s), value(1)
replace tot_q505 = . if chw_know != 1
lab var tot_q505 "total number of curative services CG knows"
gen cgcurknow2 = .
replace cgcurknow2 = 0 if chw_know == 1
replace cgcurknow2 = 1 if tot_q505 >= 2 & tot_q505 != .
lab var cgcurknow2 "CG knows role of CORP"
lab val cgcurknow2 yn
tab cgcurknow2, m
*Analysis 
svy: tab cgcurknow2 survey, col ci pear obs

*CHW's CORP perception responses
tab q508, m
tab q509, m
tab q510, m
tab q511, m
tab q512, m
tab q513, m
tab q514, m
tab q515, m
tab q516, m

*recode missing (9) to don't know (8)
recode q511 9=8

*CHW is a trusted provider (Q509 & Q512 must be yes) (INDICATOR 4)
tab q509, m
tab q512, m
gen chwtrusted = .
replace chwtrusted = 0 if chw_know == 1
replace chwtrusted = 1 if q509 == 1 & q512 == 1
lab var chwtrusted "CHW is a trusted provider"
lab val chwtrusted yn
tab chwtrusted, m
*Analysis
svy: tab chwtrusted survey, col ci pear obs

*CHW provides quality services (3+ must be yes: q510 q511 q513 q514) (INDICATOR 5)
tab q510, m
tab q511, m
tab q513, m
tab q514, m

egen chwquality = anycount (q510 q511 q513 q514), values(1)
replace chwquality = 0 if chwquality == 1 | chwquality == 2
replace chwquality = 1 if chwquality == 3 | chwquality == 4
replace chwquality = . if chw_know != 1
lab var chwquality "CHW provides quality services"
lab val chwquality yn
tab chwquality survey, m
*Analysis
svy: tab chwquality survey, col ci pear obs
 
*CHW availability by caregiver (INDICATOR 57)
*If CHW was avaiable at first visit for all cases the CG sought

*Numerator: q724, q822, q919
gen chwavail = 0 
replace chwavail = chwavail + 1 if q724 == 1
replace chwavail = chwavail + 1 if q822 == 1
replace chwavail = chwavail + 1 if q919 == 1
replace chwavail = . if q724 == . & q822 == . & q919 == .
lab var chwavail "Total number of time CG found CHW at first vist for children in survey"

*Denominator: looking at q724, q822, & q919 (CHW was visted)
gen chwavaild = 0
replace chwavaild = chwavaild + 1 if q724 !=.
replace chwavaild = chwavaild + 1 if q822 !=.
replace chwavaild = chwavaild + 1 if q919 !=.
replace chwavaild = . if q724 == . & q822 == . & q919 == .
lab var chwavaild "Total number of time CG sought care from CHW for children in survey"

*Create proportion  (numerator variable/denominator variable)
gen chwavailp = chwavail/chwavaild
lab var chwavailp "proportion of time CHW was available at first visit"
tab chwavailp survey, m

*Create variable to capture if CHW was always available at first visit (INDICATOR 6)
gen chwalwaysavail = 0 
replace chwalwaysavail = 1 if chwavailp == 1
replace chwalwaysavail = . if chwavaild == .
lab var chwalwaysavail "CHW was available when caregiver sought care for each case include in survey"
lab val chwalwaysavail yn
tab chwalwaysavail survey, m
*Analysis 
svy: tab chwalwaysavail survey, col ci pear obs

*CHW convenient (INDICATOR 7)-Only q508 available
tab q508, m
gen chwconvenient = .
replace chwconvenient = 0 if q504 == 1
replace chwconvenient = 1 if q508 == 1
lab var chwconvenient "CHW is a convenient source of care"
lab val chwconvenient yn
tab chwconvenient survey, m
*Analysis
svy: tab chwconvenient survey, col ci pear obs


*******************MODULE 7: Diarrhea*******************************************
*recoding of d_cases that have the whole module missing
tab q703, m
recode q703 9=.
recode q703 2 = 0
recode d_case 1=. if q703==.

***Diarrhea Management Table, endline by sex
*CHW sought any advice or treatment
tab q703 survey, m
*Analysis by EL and sex
svy: tab q703 d_sex if survey==2, col ci pear obs

*Sought treatment from appropriate provider
tab1 q706*
gen d_app_prov = .
replace d_app_prov = 0 if d_case == 1
replace d_app_prov = 1 if (q706a == "A" | q706b == "B" | q706c == "C" | q706d == "D" | q706e == "E" | q706g == "G" | q706j == "J" | q706k == "K")
lab var d_app_prov "Caregiver sought treatment from appropriate provider"
lab val d_app_prov yn
tab d_app_prov survey, m
*Analysis by EL and sex
svy: tab d_app_prov d_sex if survey == 2, col ci pear obs

egen d_apptot = rownonmiss(q706a-q706e q706g q706j q706k),strok
replace d_apptot = . if d_case != 1
lab var d_apptot "Total number of appropriate providers where sought care"

*Sought treatement from a CHW
tab q706g, m
gen d_chw = .
replace d_chw = 0 if d_case == 1
replace d_chw = 1 if q706g == "G"
lab var d_chw "Caregiver sought treatment from CHW"
lab val d_chw yn
tab d_chw survey, m
*Analysis by EL and sex
svy: tab d_chw d_sex if survey == 2, col ci pear obs

*Sought treatment from CHW (CORP) as first choice (INDICATOR 9A)
egen d_provtot = rownonmiss(q706a-q706x),strok
replace d_provtot = . if d_case != 1
lab var d_provtot "Total number of providers where sought care"
tab d_provtot survey, col

tab q708, m
tab q706g, m
gen d_chwfirst = .
replace d_chwfirst = 0 if d_case == 1
replace d_chwfirst = 1 if q708 == "G" 
replace d_chwfirst = 1 if q706g == "G" & d_provtot == 1
lab var d_chwfirst "Sought treatment from CHW as first choice"
lab val d_chwfirst yn
tab d_chwfirst survey, m
*Analysis by EL and sex
svy: tab d_chwfirst d_sex if survey == 2, col ci pear obs

*Given the same or more than usual to drink
tab q701, m
gen d_cont_fluids = .
replace d_cont_fluids = 0 if d_case == 1
replace d_cont_fluids = 1 if q701 == 3 | q701 == 4
lab var d_cont_fluids "Given the same or more than usual to drink"
lab val d_cont_fluids yn
tab d_cont_fluids survey, m
*Analysis by EL and sex 
svy: tab d_cont_fluids d_sex if survey == 2, col ci pear obs

*Given the same or more than usual to eat
tab q702, m
gen d_cont_feed = .
replace d_cont_feed = 0 if d_case == 1
replace d_cont_feed = 1 if q702 == 3 | q702 == 4
lab var d_cont_feed "Given the same or more than usual to eat"
lab val d_cont_feed yn
tab d_cont_feed survey, m
*Analysis by EL and sex
svy: tab d_cont_fluids d_sex if survey == 2, col ci pear obs

*Given ORS as treatment for diarrhea
tab q709a, m
gen d_ors = .
replace d_ors = 0 if d_case == 1
replace d_ors = 1 if q709a == 1
lab var d_ors "Given ORS as treatment for diarrhea"
lab val d_ors yn
tab d_ors survey, m
*Analysis by EL and sex
svy: tab d_ors d_sex if survey == 2, col ci pear obs

*Given home-made fluid as treatment for diarrhea
tab q709c, m
gen d_hmfl = .
replace d_hmfl = 0 if d_case == 1
replace d_hmfl = 1 if q709c == 1
lab var d_hmfl "Given home-made fluid as treatment for diarrhea"
lab val d_hmfl yn
tab d_hmfl survey, m
*Analysis by EL and sex
svy: tab d_hmfl d_sex if survey == 2, col ci pear obs

*Given zinc as treatment for diarrhea
tab q715, m
gen d_zinc = .
replace d_zinc = 0 if d_case == 1
replace d_zinc = 1 if q715 == 1
lab var d_zinc "Given zinc as treatment for diarrhea"
lab val d_zinc yn
tab d_zinc survey, m
*Analysis by EL and sex
svy: tab d_zinc d_sex if survey == 2, col ci pear obs

*Given zinc and ORS for treatment for diarrhea
gen d_orszinc = .
replace d_orszinc = 0 if d_case == 1
replace d_orszinc = 1 if d_ors == 1 & d_zinc == 1
lab var d_orszinc "Given ORS and zinc as treatment for diarrhea"
lab val d_orszinc yn
tab d_orszinc survey, m
*Analysis by EL and sex
svy: tab d_orszinc d_sex if survey == 2, col ci pear obs

***Seeking care jointly table
*Decided to seek care jointly with partner
tab1 q705*
gen d_joint = .
replace d_joint = 0 if d_case == 1 & maritalstat == 1
replace d_joint = 1 if q705a == "A" & maritalstat == 1
lab var d_joint "Decided to seek care jointly with partner"
lab val d_joint yn
tab d_joint survey, m
*Analysis
svy: tab d_joint survey, col ci pear obs

***Continued fluids and feeding table
*continued fluids
tab d_cont_fluids, m
svy: tab d_cont_fluids survey, col ci pear obs

*continued feeding
tab d_cont_feed, m
svy: tab d_cont_feed survey, col ci pear obs

***Table: Appropriate care seeking 
*Caregiver sought care from appropriate provider
tab d_app_prov, m
svy: tab d_app_prov survey, col ci pear obs

*Caregiver sought care from CHW
tab d_chw, m
svy: tab d_chw survey, col ci pear obs

*Caregiver sought care but not from a CHW
gen d_nocarechw = .
replace d_nocarechw = 0 if d_case == 1 & q703 == 1
replace d_nocarechw = 1 if q706g != "G" & q703 == 1 & d_case == 1
lab var d_nocarechw "Sought care for Diarrhea, but not from CHW"
lab val d_nocarechw yn
tab d_nocarechw, m
*Analysis
svy: tab d_nocarechw survey, col ci pear obs

*Caregiver sought care from CHW as first source of care
tab d_chwfirst, m
svy: tab d_chwfirst survey, col ci pear obs

*Caregiver sought care from CHW as first source of care among any of those who sought care
*total number of providers visited 
*where care was sought
sort survey
by survey: tab1 q706*

encode q706a, gen(q706_a)
encode q706b, gen(q706_b)
encode q706c, gen(q706_c)
encode q706d, gen(q706_d)
encode q706e, gen(q706_e)
encode q706f, gen(q706_f)
encode q706g, gen(q706_g)
encode q706h, gen(q706_h)
encode q706i, gen(q706_i)
encode q706j, gen(q706_j)
encode q706k, gen(q706_k)
encode q706l, gen(q706_l)
encode q706m, gen(q706_m)
encode q706x, gen(q706_x)

foreach x of varlist q706_* {
  replace `x' = 0 if `x' == . & d_case == 1 & q703 == 1
  lab val `x' yn
}


tab q708, m
tab q706g, m
tab d_provtot, m
gen d_chwfirst_anycare = .
replace d_chwfirst_anycare = 0 if d_case == 1 & q703 == 1
replace d_chwfirst_anycare = 1 if q708 == "G"
replace d_chwfirst_anycare = 1 if q706g == "G" & d_provtot == 1
lab var d_chwfirst_anycare "Caregiver sought care first from CHW as first source among any who sought care"
lab val d_chwfirst_anycare yn
tab d_chwfirst_anycare survey, m
*Analysis 
svy: tab d_chwfirst_anycare survey, col ci pear obs

***Table for CS sources
*hospital
tab q706_a, m
gen d_cs_hosp = . 
replace d_cs_hosp = 0 if d_case == 1 & q703 == 1
replace d_cs_hosp = 1 if q706_a == 1
lab var d_cs_hosp "hospital"
lab val d_cs_hosp yn
tab d_cs_hosp survey, m
*analysis
svy: tab d_cs_hosp survey, col ci pear obs
*health center
tab q706_b, m
gen d_cs_hcent = . 
replace d_cs_hcent = 0 if d_case == 1 & q703 == 1
replace d_cs_hcent = 1 if q706_b == 1
lab var d_cs_hcent "heath center"
lab val d_cs_hcent yn
tab d_cs_hcent survey, m
*analysis
svy: tab d_cs_hcent survey, col ci pear obs
*health post 
tab q706_c, m
gen d_cs_hpost = . 
replace d_cs_hpost = 0 if d_case == 1 & q703 == 1
replace d_cs_hpost = 1 if q706_c == 1
lab var d_cs_hpost "heath post"
lab val d_cs_hpost yn
tab d_cs_hpost survey, m
*analysis
svy: tab d_cs_hpost survey, col ci pear obs
*NGO center
tab q706_d, m
gen d_cs_ngo = . 
replace d_cs_ngo = 0 if d_case == 1 & q703 == 1
replace d_cs_ngo = 1 if q706_d == 1
lab var d_cs_ngo "NGO center"
lab val d_cs_ngo yn
tab d_cs_ngo survey, m
*analysis-removed 'col' because single row ouput
svy: tab d_cs_ngo survey, ci pear obs
*Clinic
tab q706_e, m
gen d_cs_clin = . 
replace d_cs_clin = 0 if d_case == 1 & q703 == 1
replace d_cs_clin = 1 if q706_e == 1
lab var d_cs_clin "Clinic"
lab val d_cs_clin yn
tab d_cs_clin survey, m
*analysis
svy: tab d_cs_clin survey, col ci pear obs
*Role Model Caregivers
tab q706_f, m
gen d_cs_rmod = . 
replace d_cs_rmod = 0 if d_case == 1 & q703 == 1
replace d_cs_rmod = 1 if q706_f == 1
lab var d_cs_rmod "Role model caregiver"
lab val d_cs_rmod yn
tab d_cs_rmod survey, m
*analysis
svy: tab d_cs_rmod survey, col ci pear obs
*CHW
tab q706_g, m
gen d_cs_chw = . 
replace d_cs_chw = 0 if d_case == 1 & q703 == 1
replace d_cs_chw = 1 if q706_g == 1
lab var d_cs_chw "CHW"
lab val d_cs_chw yn
tab d_cs_chw survey, m
*analysis
svy: tab d_cs_chw survey, col ci pear obs
*Community directed distributor
tab q706_h, m
gen d_cs_cdd = . 
replace d_cs_cdd = 0 if d_case == 1 & q703 == 1
replace d_cs_cdd = 1 if q706_h == 1
lab var d_cs_cdd "CDD"
lab val d_cs_cdd yn
tab d_cs_cdd survey, m
*analysis-removed 'col' b/c single row
svy: tab d_cs_cdd survey, ci pear obs
*Traditional practitioner
tab q706_i, m
gen d_cs_trad = . 
replace d_cs_trad = 0 if d_case == 1 & q703 == 1
replace d_cs_trad = 1 if q706_i == 1
lab var d_cs_trad "traditional practicioner"
lab val d_cs_trad yn
tab d_cs_trad survey, m
*analysis
svy: tab d_cs_trad survey, col ci pear obs
*Shop/Patient Medicine Vendor (PPMV)
tab q706_j, m
gen d_cs_ppmv = . 
replace d_cs_ppmv = 0 if d_case == 1 & q703 == 1
replace d_cs_ppmv = 1 if q706_j == 1
lab var d_cs_ppmv "PPMV"
lab val d_cs_ppmv yn
tab d_cs_ppmv survey, m
*analysis
svy: tab d_cs_trad survey, col ci pear obs
*Pharmacy
tab q706_k, m
gen d_cs_phar = . 
replace d_cs_phar = 0 if d_case == 1 & q703 == 1
replace d_cs_phar = 1 if q706_k == 1
lab var d_cs_phar "pharmacy"
lab val d_cs_phar yn
tab d_cs_phar survey, m
*analysis
svy: tab d_cs_phar survey, col ci pear obs
*Friend/Relative
tab q706_l, m
gen d_cs_friend = . 
replace d_cs_friend = 0 if d_case == 1 & q703 == 1
replace d_cs_friend = 1 if q706_l == 1
lab var d_cs_friend "friend/relative"
lab val d_cs_friend yn
tab d_cs_friend survey, m
*analysis
svy: tab d_cs_friend survey, col ci pear obs
*Market
tab q706_m, m
gen d_cs_mark = . 
replace d_cs_mark = 0 if d_case == 1 & q703 == 1
replace d_cs_mark = 1 if q706_m == 1
lab var d_cs_mark "market"
lab val d_cs_mark yn
tab d_cs_mark survey, m
*analysis
svy: tab d_cs_mark survey, col ci pear obs
*Other
tab q706_x, m
gen d_cs_other = . 
replace d_cs_other = 0 if d_case == 1 & q703 == 1
replace d_cs_other = 1 if q706_x == 1
lab var d_cs_other "other"
lab val d_cs_other yn
tab d_cs_other survey, m
*analysis
svy: tab d_cs_other survey, col ci pear obs

*First source of care locations-diarrhea
gen d_fcs_hosp = 1 if q708 == "A"
gen d_fcs_hcent = 1 if q708 == "B" 
gen d_fcs_hpost = 1 if q708 == "C" 
gen d_fcs_ngo = 1 if q708 == "D" 
gen d_fcs_clin = 1 if q708 == "E" 
gen d_fcs_rmod = 1 if q708 == "F"
gen d_fcs_chw = 1 if q708 == "G"
gen d_fcs_cdd = 1 if q708 == "H"
gen d_fcs_trad = 1 if q708 == "I"
gen d_fcs_ppmv = 1 if q708 == "J" 
gen d_fcs_phar = 1 if q708 == "K"
gen d_fcs_friend = 1 if q708 == "L"
gen d_fcs_mark = 1 if q708 == "M"
gen d_fcs_other = 1 if q708 == "X"

replace d_fcs_hosp = 1 if q706_a == 1 & d_provtot == 1
replace d_fcs_hcent = 1 if q706_b == 1 & d_provtot == 1
replace d_fcs_hpost = 1 if q706_c == 1 & d_provtot == 1
replace d_fcs_ngo = 1 if q706_d == 1 & d_provtot == 1
replace d_fcs_clin = 1 if q706_e == 1 & d_provtot == 1
replace d_fcs_rmod = 1 if q706_f == 1 & d_provtot == 1
replace d_fcs_chw = 1 if q706_g == 1 & d_provtot == 1
replace d_fcs_cdd = 1 if q706_h == 1 & d_provtot == 1
replace d_fcs_trad = 1 if q706_i == 1 & d_provtot == 1
replace d_fcs_ppmv = 1 if q706_j == 1 & d_provtot == 1
replace d_fcs_phar = 1 if q706_k == 1 & d_provtot == 1
replace d_fcs_friend = 1 if q706_l == 1 & d_provtot == 1
replace d_fcs_mark = 1 if q706_m == 1 & d_provtot == 1
replace d_fcs_other = 1 if q706_x == 1 & d_provtot == 1

foreach x of varlist d_fcs_* {
  replace `x' = 0 if d_case == 1 & q703 == 1 & `x' ==.
  lab val `x' yn
}

*hospital
tab d_fcs_hosp, m
lab var d_fcs_hosp "hospital"
lab val d_fcs_hosp yn
*analysis
svy: tab d_fcs_hosp survey, col ci pear obs
*health center
tab d_fcs_hcent, m
lab var d_fcs_hcent "health center"
lab val d_fcs_hcent yn
*analysis
svy: tab d_fcs_hcent survey, col ci pear obs
*health post
tab d_fcs_hpost, m
lab var d_fcs_hpost "health post"
lab val d_fcs_hpost yn
*analysis
svy: tab d_fcs_hpost survey, col ci pear obs
*health ngo
tab d_fcs_ngo, m
lab var d_fcs_ngo "NGO center"
lab val d_fcs_ngo yn
*analysis-removed 'col' b/c single row
svy: tab d_fcs_ngo survey, ci pear obs
*Clinic
tab d_fcs_clin, m
lab var d_fcs_clin "clinic"
lab val d_fcs_clin yn
*analysis
svy: tab d_fcs_clin survey, col ci pear obs
*Role model
tab d_fcs_rmod, m
lab var d_fcs_rmod "role model"
lab val d_fcs_rmod yn
*analysis
svy: tab d_fcs_rmod survey, col ci pear obs
*CHW
tab d_fcs_chw, m
lab var d_fcs_chw "chw"
lab val d_fcs_chw yn
*analysis
svy: tab d_fcs_chw survey, col ci pear obs
*Traditional practitioner
tab d_fcs_trad, m
lab var d_fcs_trad "traditional practitioner"
lab val d_fcs_trad yn
*analysis
svy: tab d_fcs_trad survey, col ci pear obs
*PPMV
tab d_fcs_ppmv, m
lab var d_fcs_ppmv "PPMV"
lab val d_fcs_ppmv yn
*analysis
svy: tab d_fcs_ppmv survey, col ci pear obs
*Pharmacy
tab d_fcs_phar, m
lab var d_fcs_phar "pharmacy"
lab val d_fcs_phar yn
*analysis
svy: tab d_fcs_phar survey, col ci pear obs
*Friend
tab d_fcs_friend, m
lab var d_fcs_friend "friend/relative"
lab val d_fcs_friend yn
*analysis
svy: tab d_fcs_friend survey, col ci pear obs
*Market
tab d_fcs_mark, m
lab var d_fcs_mark "market"
lab val d_fcs_mark yn
*analysis
svy: tab d_fcs_mark survey, col ci pear obs
*Other
tab d_fcs_other, m
lab var d_fcs_other "other"
lab val d_fcs_other yn
*analysis
svy: tab d_fcs_other survey, col ci pear obs


***Appropriate Treatment Table
*treated with ORS AND Zinc by CHW (INDICATOR 14A)
tab q711, m
tab q716, m
gen d_orszincchw = .
replace d_orszincchw = 0 if d_case != .
replace d_orszincchw = 1 if d_orszinc == 1 & q711 == 17 & q716 == 17
lab var d_orszincchw "Treated by ORS and Zinc from CHW"
lab val d_orszincchw yn
tab d_orszincchw, m
*Analysis
svy: tab d_orszincchw survey, col ci pear obs

*Treated with ORS and Zinc by provider other than CHW (New WHO Indicator)
gen d_orszincother = .
replace d_orszincother = 0 if d_case == 1
replace d_orszincother = 1 if d_orszinc == 1 & d_orszincchw == 0
lab var d_orszincother "recived ORS and zinc from provider other than CHW"
lab val d_orszincother yn
tab d_orszincother survey, m
*Analysis
svy: tab d_orszincother survey, col ci pear obs

*treated with ORS and Zinc (INDICATOR 13A)
tab d_orszinc, m
*analysis
svy: tab d_orszinc survey, col ci pear obs

*Recieved ORS and Zinc from CHW among those who sought care from CHW
gen d_orszincchw2 = .
replace d_orszincchw2 = 0 if d_chw == 1
replace d_orszincchw2 = 1 if d_orszinc == 1 & q711 == 17 & q716 == 17 & d_chw == 1
lab var d_orszincchw2 "Recieved ORS and Zinc from CHW who sought care from CHW"
lab val d_orszincchw2 yn
tab d_orszincchw2, m
*analysis
svy: tab d_orszincchw2 survey, col ci pear obs

*Recieved ORS and Zinc from provier other than CHW among those who sought care from other providers
gen d_orszincoth2 = .
replace d_orszincoth2 = 0 if (d_provtot >= 2 | (d_provtot == 1 & d_chw != 1)) & d_case == 1
replace d_orszincoth2 = 1 if d_orszincother == 1 & (d_provtot >= 2 | (d_provtot == 1 & d_chw != 1)) & d_case == 1
lab var d_orszincoth2 "Recieved ORS and Zinc from CHW who sought care from CHW"
lab val d_orszincoth2 yn
tab d_orszincoth2, m
*analysis
svy: tab d_orszincoth2 survey, col ci pear obs

*Child given ORS
tab d_ors, m
*analysis
svy: tab d_ors survey, col ci pear obs

*Child given Zinc
tab d_zinc, m
*analysis
svy: tab d_zinc survey, col ci pear obs

*Child given home made fluid
tab d_hmfl, m
*analysis
svy: tab d_hmfl survey, col ci pear obs

*did the child take anything else for diarrhea (among all diarrhea cases)
tab q720 

tab1 q721*

*antibiotic pill/syrup
tab q721a, m
gen q721_a = .
replace q721_a = 0 if d_case == 1
replace q721_a = 1 if q721a == "A"
lab var q721_a "antibiotic pill/syrup"
lab val q721_a yn
*analysis
svy: tab q721_a survey, col ci pear obs
*antimotlity pill/syrup
tab q721b, m
gen q721_b = .
replace q721_b = 0 if d_case == 1
replace q721_b = 1 if q721b == "B"
lab var q721_b "antimotility pill/syrup"
lab val q721_b yn
*analysis
svy: tab q721_b survey, col ci pear obs
*other pill/syrup
tab q721c, m
gen q721_c = .
replace q721_c = 0 if d_case == 1
replace q721_c = 1 if q721c == "C"
lab var q721_c "other pill/syrup"
lab val q721_c yn
*analysis
svy: tab q721_c survey, col ci pear obs
*unknown pill/syrup
tab q721d, m
gen q721_d = .
replace q721_d = 0 if d_case == 1
replace q721_d = 1 if q721d == "D"
lab var q721_d "unknown pill/syrup"
lab val q721_d yn
*analysis
svy: tab q721_d survey, col ci pear obs
*antibiotic injection
tab q721e, m
gen q721_e = .
replace q721_e = 0 if d_case == 1
replace q721_e = 1 if q721e == "E"
lab var q721_e "antibiotic injection"
lab val q721_e yn
*analysis
svy: tab q721_e survey, col ci pear obs
*non-antibiotic injection
tab q721f, m
gen q721_f = .
replace q721_f = 0 if d_case == 1
replace q721_f = 1 if q721f == "F"
lab var q721_f "non-antibiotic injection"
lab val q721_f yn
*analysis-removed 'col' b/c single row
svy: tab q721_f survey, ci pear obs
*unknown injection
tab q721g, m
gen q721_g = .
replace q721_g = 0 if d_case == 1
replace q721_g = 1 if q721g == "G"
lab var q721_g "unknown injection"
lab val q721_g yn
*analysis
svy: tab q721_g survey, col ci pear obs
*intravenous treatment
tab q721h, m
gen q721_h = .
replace q721_h = 0 if d_case == 1
replace q721_h = 1 if q721h == "H"
lab var q721_h "intravenous treatment"
lab val q721_h yn
*analysis
svy: tab q721_h survey, col ci pear obs
*Home remedy/herbal medicine
tab q721i, m
gen q721_i = .
replace q721_i = 0 if d_case == 1
replace q721_i = 1 if q721i == "I"
lab var q721_i "home remedy/herbal medicine"
lab val q721_i yn
*analysis
svy: tab q721_i survey, col ci pear obs
*other
tab q721x, m
gen q721_x = .
replace q721_x = 0 if d_case == 1
replace q721_x = 1 if q721x == "X"
lab var q721_x "other"
lab val q721_x yn
*analysis
svy: tab q721_x survey, col ci pear obs
 
***Source of Treatment Table
*Source of ORS treatment
*7 missing responses
tab q711, m
*Hospital
gen d_ors_hosp = .
replace d_ors_hosp = 0 if d_case == 1 & d_ors == 1
replace d_ors_hosp = 1 if q711 == 11
lab var d_ors_hosp "recieved ORS from hospital"
lab val d_ors_hosp yn
tab d_ors_hosp, m
*analysis
svy: tab d_ors_hosp survey, col ci pear obs
*health center
gen d_ors_hcent = .
replace d_ors_hcent = 0 if d_case == 1 & d_ors == 1
replace d_ors_hcent = 1 if q711 == 12
lab var d_ors_hcent "recieved ORS from health center"
lab val d_ors_hcent yn
tab d_ors_hcent, m
*analysis
svy: tab d_ors_hcent survey, col ci pear obs
*health post
gen d_ors_hpost = .
replace d_ors_hpost = 0 if d_case == 1 & d_ors == 1
replace d_ors_hpost = 1 if q711 == 13
lab var d_ors_hpost "recieved ORS from health post"
lab val d_ors_hpost yn
tab d_ors_hpost, m
*analysis
svy: tab d_ors_hpost survey, col ci pear obs
*NGO Center
gen d_ors_ngo = .
replace d_ors_ngo = 0 if d_case == 1 & d_ors == 1
replace d_ors_ngo = 1 if q711 == 14
lab var d_ors_ngo "recieved ORS from ngo center"
lab val d_ors_ngo yn
tab d_ors_ngo, m
*analysis-removed 'col' b/c single row
svy: tab d_ors_ngo survey, ci pear obs
*Clinic
gen d_ors_clin = .
replace d_ors_clin = 0 if d_case == 1 & d_ors == 1
replace d_ors_clin = 1 if q711 == 15
lab var d_ors_clin "recieved ORS from clinic"
lab val d_ors_clin yn
tab d_ors_clin, m
*analysis
svy: tab d_ors_clin survey, col ci pear obs
*Role Model
gen d_ors_rmod = .
replace d_ors_rmod = 0 if d_case == 1 & d_ors == 1
replace d_ors_rmod = 1 if q711 == 16
lab var d_ors_rmod "recieved ORS from role model"
lab val d_ors_rmod yn
tab d_ors_rmod, m
*analysis-removed 'col' b/c single row
svy: tab d_ors_rmod survey, ci pear obs
*CHW
gen d_ors_chw = .
replace d_ors_chw = 0 if d_case == 1 & d_ors == 1
replace d_ors_chw = 1 if q711 == 17
lab var d_ors_chw "recieved ORS from chw"
lab val d_ors_chw yn
tab d_ors_chw, m
*analysis
svy: tab d_ors_chw survey, col ci pear obs
*Traditional practitioner
gen d_ors_trad = .
replace d_ors_trad = 0 if d_case == 1 & d_ors == 1
replace d_ors_trad = 1 if q711 == 21
lab var d_ors_trad "recieved ORS from traditional healer"
lab val d_ors_trad yn
tab d_ors_trad, m
*analysis-removed 'col' b/c single row
svy: tab d_ors_trad survey, ci pear obs
*PPMV
gen d_ors_ppmv = .
replace d_ors_ppmv = 0 if d_case == 1 & d_ors == 1
replace d_ors_ppmv = 1 if q711 == 22
lab var d_ors_ppmv "recieved ORS from PPMV"
lab val d_ors_ppmv yn
tab d_ors_ppmv, m
*analysis
svy: tab d_ors_ppmv survey, col ci pear obs
*Pharmacy
gen d_ors_phar = .
replace d_ors_phar = 0 if d_case == 1 & d_ors == 1
replace d_ors_phar = 1 if q711 == 23
lab var d_ors_phar "recieved ORS from pharmacy"
lab val d_ors_phar yn
tab d_ors_phar, m
*analysis
svy: tab d_ors_phar survey, col ci pear obs
*Friend/Relative
gen d_ors_friend = .
replace d_ors_friend = 0 if d_case == 1 & d_ors == 1
replace d_ors_friend = 1 if q711 == 26
lab var d_ors_friend "recieved ORS from friend/relative"
lab val d_ors_friend yn
tab d_ors_friend, m
*analysis-removed 'col' because single row output
svy: tab d_ors_friend survey, ci pear obs
*Market
gen d_ors_mark = .
replace d_ors_mark = 0 if d_case == 1 & d_ors == 1
replace d_ors_mark = 1 if q711 == 27
lab var d_ors_mark "recieved ORS from market"
lab val d_ors_mark yn
tab d_ors_mark, m
*analysis
svy: tab d_ors_mark survey, col ci pear obs
*Other
gen d_ors_other = .
replace d_ors_other = 0 if d_case == 1 & d_ors == 1
replace d_ors_other = 1 if q711 ==31
lab var d_ors_other "recieved ORS from other source"
lab val d_ors_other yn
tab d_ors_other, m
*analysis-removed 'col' b/c single row
svy: tab d_ors_other survey, ci pear obs


*Source of zinc treatment
*1 missing response
tab q716, m
*Hospital
gen d_zinc_hosp = .
replace d_zinc_hosp  = 0 if d_case == 1 & d_zinc == 1
replace d_zinc_hosp  = 1 if q716 == 11
lab var d_zinc_hosp  "recieved zinc from hospital"
lab val d_zinc_hosp  yn
tab d_zinc_hosp , m
*analysis
svy: tab d_zinc_hosp  survey, col ci pear obs
*health center
gen d_zinc_hcent = .
replace d_zinc_hcent = 0 if d_case == 1 & d_zinc == 1
replace d_zinc_hcent = 1 if q716 == 12
lab var d_zinc_hcent "recieved zinc from health center"
lab val d_zinc_hcent yn
tab d_zinc_hcent, m
*analysis
svy: tab d_zinc_hcent survey, col ci pear obs
*health post
gen d_zinc_hpost = .
replace d_zinc_hpost = 0 if d_case == 1 & d_zinc == 1
replace d_zinc_hpost = 1 if q716 == 13
lab var d_zinc_hpost "recieved zinc from health post"
lab val d_zinc_hpost yn
tab d_zinc_hpost, m
*analysis
svy: tab d_zinc_hpost survey, col ci pear obs
*NGO Center
gen d_zinc_ngo = .
replace d_zinc_ngo = 0 if d_case == 1 & d_zinc == 1
replace d_zinc_ngo = 1 if q716 == 14
lab var d_zinc_ngo "recieved zinc from NGO center"
lab val d_zinc_ngo yn
tab d_zinc_ngo, m
*analysis-removed 'col' b/c single row
svy: tab d_zinc_ngo survey, ci pear obs
*Clinic
gen d_zinc_clin = .
replace d_zinc_clin = 0 if d_case == 1 & d_zinc == 1
replace d_zinc_clin = 1 if q716 == 15
lab var d_zinc_clin "recieved zinc from clinic"
lab val d_zinc_clin yn
tab d_zinc_clin, m
*analysis
svy: tab d_zinc_clin survey, col ci pear obs
*Role Model
gen d_zinc_rmod = .
replace d_zinc_rmod = 0 if d_case == 1 & d_zinc == 1
replace d_zinc_rmod = 1 if q716 == 16
lab var d_zinc_rmod "recieved zinc from role model"
lab val d_zinc_rmod yn
tab d_zinc_rmod, m
*analysis-removed 'col' b/c single row
svy: tab d_zinc_rmod survey, ci pear obs
*CHW
gen d_zinc_chw = .
replace d_zinc_chw = 0 if d_case == 1 & d_zinc == 1
replace d_zinc_chw = 1 if q716 == 17
lab var d_zinc_chw "recieved zinc from chw"
lab val d_zinc_chw yn
tab d_zinc_chw, m
*analysis
svy: tab d_zinc_chw survey, col ci pear obs
*Traditional practitioner
gen d_zinc_trad = .
replace d_zinc_trad = 0 if d_case == 1 & d_zinc == 1
replace d_zinc_trad = 1 if q716 == 21
lab var d_zinc_trad "recieved zinc from traditional healer"
lab val d_zinc_trad yn
tab d_zinc_trad, m
*analysis-removed 'col' b/c single row
svy: tab d_zinc_trad survey, ci pear obs
*PPMV
gen d_zinc_ppmv = .
replace d_zinc_ppmv = 0 if d_case == 1 & d_zinc == 1
replace d_zinc_ppmv = 1 if q716 == 22
lab var d_zinc_ppmv "recieved zinc from PPMV"
lab val d_zinc_ppmv yn
tab d_zinc_ppmv, m
*analysis
svy: tab d_zinc_ppmv survey, col ci pear obs
*Pharmacy
gen d_zinc_phar = .
replace d_zinc_phar = 0 if d_case == 1 & d_zinc == 1
replace d_zinc_phar = 1 if q716 == 23
lab var d_zinc_phar "recieved zinc from pharmacy"
lab val d_zinc_phar yn
tab d_zinc_phar, m
*analysis
svy: tab d_zinc_phar survey, col ci pear obs
*Friend/Relative
gen d_zinc_friend = .
replace d_zinc_friend = 0 if d_case == 1 & d_zinc == 1
replace d_zinc_friend = 1 if q716 == 26
lab var d_zinc_friend "recieved zinc from friend/relative"
lab val d_zinc_friend yn
tab d_zinc_friend, m
*analysis-removed 'col' because one line
svy: tab d_zinc_friend survey, ci pear obs
*Market
gen d_zinc_mark = .
replace d_zinc_mark  = 0 if d_case == 1 & d_zinc == 1
replace d_zinc_mark  = 1 if q716 == 27
lab var d_zinc_mark  "recieved zinc from market"
lab val d_zinc_mark  yn
tab d_zinc_mark , m
*analysis
svy: tab d_zinc_mark  survey, col ci pear obs
*Other
gen d_zinc_other = .
replace d_zinc_other = 0 if d_case == 1 & d_zinc == 1
replace d_zinc_other = 1 if q716 ==31
lab var d_zinc_other "recieved zinc from other source"
lab val d_zinc_other yn
tab d_zinc_other, m
*analysis-removed 'col' b/c single row
svy: tab d_zinc_other survey, ci pear obs


***Table: Recieved first dose for diarrhea in presence of CHW
*Recieved ORS from CHW
tab q711, m
gen d_orschw = .
replace d_orschw = 0 if d_case == 1
replace d_orschw = 1 if q711 == 17 & d_case == 1
lab var d_orschw "recieved ors from chw"
lab val d_orschw yn
tab d_orschw, m
*analysis
svy: tab d_orschw survey, col ci pear obs

*Recieved ORS from provider other than CHW
gen d_orsoth = .
replace d_orsoth = 0 if d_case == 1
replace d_orsoth = 1 if q711 != 17 & d_ors == 1
lab var d_orsoth "recieved ors from provider other than CHW"
lab val d_orsoth yn
tab d_orsoth, m
*analysis
svy: tab d_orsoth survey, col ci pear obs

*Recieved ORS from CHW among those who sought care from CHW
gen d_orschw2 = .
replace d_orschw2 = 0 if d_chw == 1
replace d_orschw2 = 1 if d_orschw == 1 & d_chw == 1
lab var d_orschw2 "Recieved ORS from CHW who sought care from CHW"
lab val d_orschw2 yn
tab d_orschw2, m
*analysis
svy: tab d_orschw2 survey, col ci pear obs

*Recieved ORS from provier other than CHW among those who sought care from other providers
gen d_orsoth2 = .
replace d_orsoth2 = 0 if (d_provtot >= 2 | (d_provtot == 1 & d_chw != 1)) & d_case == 1 
replace d_orsoth2 = 1 if d_orsoth == 1 & (d_provtot >= 2 | (d_provtot == 1 & d_chw != 1) & d_case == 1)
lab var d_orsoth2 "Recieved ORS from provider other than CHW, among those who sought care from providers other than CHW"
lab val d_orsoth2 yn
tab d_orsoth2, m
*analysis
svy: tab d_orsoth2 survey, col ci pear obs

*Recieved first dose of ORS in presence of CHW (INDICATOR 15A)
tab q713, m
gen d_ors_chwp = .
replace d_ors_chwp = 0 if d_orschw == 1
replace d_ors_chwp = 1 if q713 == 1
lab var d_ors_chwp "received first dose of ORS in front of CHW"
lab val d_ors_chwp yn
tab d_ors_chwp, m
*analysis
svy: tab d_ors_chwp survey, col ci pear obs

*Recieved zinc from CHW
tab q716, m
gen d_zincchw = . 
replace d_zincchw = 0 if d_case == 1 
replace d_zincchw = 1 if q716 == 17 & d_case == 1
lab var d_zincchw "recived zinc from chw"
lab val d_zincchw yn
tab d_zincchw survey, m
*analysis
svy: tab d_zincchw survey, col ci pear obs

*Recieved Zinc from CHW among those who sought care from CHW
gen d_zincchw2 = .
replace d_zincchw2 = 0 if d_chw == 1
replace d_zincchw2 = 1 if d_zincchw == 1 & d_chw == 1
lab var d_zincchw2 "Recieved Zinc from CHW who sought care from CHW"
lab val d_zincchw2 yn
tab d_zincchw2, m
*analysis
svy: tab d_zincchw2 survey, col ci pear obs

*Recieved zinc from provider other than CHW
gen d_zincoth = .
replace d_zincoth = 0 if d_case == 1
replace d_zincoth = 1 if q711 != 17 & d_zinc == 1
lab var d_zincoth "recieved zinc from provider other than CHW"
lab val d_zincoth yn
tab d_zincoth, m
*analysis
svy: tab d_zincoth survey, col ci pear obs

*Recieved zinc from provier other than CHW among those who sought care from other providers
gen d_zincoth2 = .
replace d_zincoth2 = 0 if (d_provtot >= 2 | (d_provtot == 1 & d_chw != 1)) & d_case == 1
replace d_zincoth2 = 1 if d_zincoth == 1 & (d_provtot >= 2 | (d_provtot == 1 & d_chw != 1)) & d_case == 1
lab var d_zincoth2 "Recieved Zinc from provider other than CHW, among those who sought care from providers other than CHW"
lab val d_zincoth2 yn
tab d_zincoth2, m
*analysis
svy: tab d_zincoth2 survey, col ci pear obs

*Recieved first dose of zinc in presence of CHW (INDICATOR 15B)
tab q718, m
gen d_zinc_chwp = .
replace d_zinc_chwp = 0 if d_zincchw == 1 
replace d_zinc_chwp = 1 if q718 == 1
lab var d_zinc_chwp "recived first dose of zinc in front of CHW"
lab val d_zinc_chwp yn
tab d_zinc_chwp survey, m
*analysis
svy: tab d_zinc_chwp survey, col ci pear obs

*Recieved frist dose of zinc and ORS in presence of CHW (INDICATOR 15C)
gen d_bothfirstdose = .
replace d_bothfirstdose = 0 if q711 == 17 & q716 == 17 
replace d_bothfirstdose = 1 if q713 == 1 & q718 == 1 
lab var d_bothfirstdose "recived first dose of zinc and ORS in front of CHW"
lab val d_bothfirstdose yn
tab d_bothfirstdose survey, m
*analysis 
svy: tab d_bothfirstdose survey, col ci pear obs

***Table: Recieved counseling from CWH for diarrhea treatment
*Received counseling for ORS from CHW (INDICATOR 16A)
tab q714, m
gen d_ors_chwc = . 
replace d_ors_chwc = 0 if d_orschw == 1
replace d_ors_chwc = 1 if q714 == 1
lab var d_ors_chwc "Recieved counseling from CHW for ORS"
lab val d_ors_chwc yn
tab d_ors_chwc survey, m
*analysis
svy: tab d_ors_chwc survey, col ci pear obs

*Recieved counseling for zinc from CHW (INDICATOR 16B)
tab q719, m
gen d_zinc_chwc = .
replace d_zinc_chwc = 0 if d_zincchw == 1
replace d_zinc_chwc = 1 if q719 == 1
lab var d_zinc_chwc "Recieved counseling from CHW for zinc"
lab val d_zinc_chwc yn
tab d_zinc_chwc survey, m
*analysis
svy: tab d_zinc_chwc survey, col ci pear obs

*Recieved counseling for ORS and zinc from CHW (INDICATOR 16C)
gen d_bothcounsel = .
replace d_bothcounsel = 0 if q711 == 17 & q716 == 17
replace d_bothcounsel = 1 if q714 == 1 & q719 == 1
lab var d_bothcounsel "Recieved counseling for ORS and zinc from CHW"
lab val d_bothcounsel yn
tab d_bothcounsel survey, m
*analysis
svy: tab d_bothcounsel survey, col ci pear obs

***Table: Referral adherence
*CHW gave caregiver referral
tab q725, m
gen d_chwrefer = .
replace d_chwrefer = 0 if d_chw == 1
replace d_chwrefer = 1 if q725 == 1
lab var d_chwrefer "CHW gave caregiver referral"
lab val d_chwrefer yn
tab d_chwrefer survey, m
*analysis
svy: tab d_chwrefer survey, col ci pear obs

*Caregiver went to referral
tab q726, m
gen d_referadhere = .
replace d_referadhere = 0 if q725 == 1
replace d_referadhere = 1 if q726 == 1
lab var d_referadhere "Caregiver complied with referral"
lab val d_referadhere yn
tab d_referadhere survey, m
*analysis
svy: tab d_referadhere survey, col ci pear obs

*Reasons did not comply with referral
tab1 q727*

encode q727a, gen(q727_a)
encode q727b, gen(q727_b)
encode q727c, gen(q727_c)
encode q727d, gen(q727_d)
encode q727e, gen(q727_e)
encode q727f, gen(q727_f)
encode q727g, gen(q727_g)
encode q727h, gen(q727_h)
encode q727x, gen(q727_x)
encode q727z, gen(q727_z)

foreach x of varlist q727_* {
  replace `x' = 0 if `x' == . & q726 == 2
  lab val `x' yn
}

*too far
tab q727_a, m
lab var q727_a "too far"
lab val q727_a yn
tab q727_a survey, m
*analysis
svy: tab q727_a survey, col ci pear obs
*did not have money
tab q727_b, m
lab var q727_b "did not have money"
lab val q727_b yn
tab q727_b survey, m
*analysis-removed col b/c single row
svy: tab q727_b survey, ci pear obs
*no transport
tab q727_c, m
lab var q727_c "no transport"
lab val q727_c yn
tab q727_c survey, m
*analysis-removed col b/c single row
svy: tab q727_c survey, ci pear obs
*did not think illness serious
tab q727_d, m
lab var q727_d "did not think illness serious"
lab val q727_d yn
tab q727_d survey, m
*analysis 
svy: tab q727_d survey, col ci pear obs
*child improved
tab q727_e, m
lab var q727_e "child improved"
lab val q727_e yn
tab q727_e survey, m
*analysis
svy: tab q727_e survey, col ci pear obs
*no time
tab q727_f, m
lab var q727_f "no time"
lab val q727_f yn
tab q727_f survey, m
*analysis-removed col b/c single row
svy: tab q727_f survey, ci pear obs
*went somewhere else
tab q727_g, m
lab var q727_g "went somewhere else"
lab val q727_g yn
tab q727_g survey, m
*analysis
svy: tab q727_g survey, col ci pear obs
*did not have husband's permission
tab q727_h, m
lab var q727_h "no permission"
lab val q727_h yn
tab q727_h survey, m
*analysis
svy: tab q727_h survey, col ci pear obs
*other
tab q727_x, m
lab var q727_x "other"
lab val q727_x yn
tab q727_x survey, m
*analysis-removed col b/c single row
svy: tab q727_x survey, ci pear obs
*don't know
tab q727_z, m
lab var q727_z "don't know"
lab val q727_z yn
tab q727_z survey, m
*analysis
svy: tab q727_z survey, col ci pear obs

***Table: CHW Follow up
*CHW did follow up 
tab q728, m
gen d_chw_fu = .
replace d_chw_fu = 0 if d_chw == 1
replace d_chw_fu = 1 if q728 == 1
lab var d_chw_fu "CHW did follow up"
lab val d_chw_fu yn
tab d_chw_fu survey, m
*analysis
svy: tab d_chw_fu survey, col ci pear obs

***Table: No Care Seeking Reasons
*CG did not seek care for diarrhea
tab q703, m
tab d_case, m
gen d_nocare = .
replace d_nocare = 0 if q703 == 1 & d_case == 1
replace d_nocare = 1 if q703 == 0 & d_case == 1
lab var d_nocare "CG did not seek care for diarrhea"
lab val d_nocare yn
tab d_nocare survey, m
*analysis 
svy: tab d_nocare survey, col ci pear obs

*CG sought care but not from CHW
tab d_nocarechw survey, m
*analysis
svy: tab d_nocarechw survey, col ci pear obs

*reasons for not going to CHW for diarrhea (endline only)
tab1 q708b*
egen tot_q708b = rownonmiss (q708ba-q708bx), strok
replace tot_q708b = . if survey == 1
replace tot_q708b = . if q703 != 1
replace tot_q708b = . if q706g == "G"
lab var tot_q708b "Total number of reasons CG did not seek care by CHW"
tab tot_q708b, m

encode q708ba, gen(q708b_a)
encode q708bb, gen(q708b_b)
encode q708bc, gen(q708b_c)
encode q708bd, gen(q708b_d)
encode q708be, gen(q708b_e)
encode q708bf, gen(q708b_f)
encode q708bx, gen(q708b_x)
encode q708bz, gen(q708b_z)

foreach x of varlist q708b_* {
  replace `x' = 0 if `x' == . & d_case == 1 & survey == 2 & q703 == 1 & q706g != "G"
  }

*CHW not available
tab q708b_a, m
lab var q708b_a "CHW not available"
lab val q708b_a yn
*anaylsis
svy: tab q708b_a survey, col ci pear obs
*CHW did not have medicines or supplies
tab q708b_b, m
lab var q708b_b "CHW did not have meds/supplies"
lab val q708b_b yn
*anaylsis
svy: tab q708b_b survey, col ci pear obs
*did not trust CHW to provide care
tab q708b_c, m
lab var q708b_c "did not trust CHW"
lab val q708b_c yn
*anaylsis
svy: tab q708b_c survey, col ci pear obs
*thought condition was too serious for CHW to treat
tab q708b_d, m
lab var q708b_d "condition too serious"
lab val q708b_d yn
*anaylsis
svy: tab q708b_d survey, col ci pear obs
*preferred to go to another provider
tab q708b_e, m
lab var q708b_e "preferred other provider"
lab val q708b_e yn
*anaylsis
svy: tab q708b_e survey, col ci pear obs
*CHW too far away
tab q708b_f, m
lab var q708b_f "CHW too far"
lab val q708b_f yn
*anaylsis-removed 'col' b/c single row
svy: tab q708b_f survey, ci pear obs
*other
tab q708b_x, m
lab var q708b_x "other"
lab val q708b_x yn
*anaylsis
svy: tab q708b_x survey, col ci pear obs

*reason did not seek care for diarrhea (ENDLINE ONLY)
tab1 q708c*
*See how many reasons were given since multiple responses were allowed
egen tot_q708c = rownonmiss(q708ca-q708cx),strok
replace tot_q708c = . if q703 != 0
replace tot_q708c = . if survey == 1
lab var tot_q708c "Number of reasons caregiver did not seek care"
tab tot_q708c

encode q708ca, gen(q708c_a)
encode q708cb, gen(q708c_b)
encode q708cc, gen(q708c_c)
encode q708cd, gen(q708c_d)
encode q708ce, gen(q708c_e)
encode q708cf, gen(q708c_f)
encode q708cg, gen(q708c_g)
encode q708cx, gen(q708c_x)
encode q708cz, gen(q708c_z)

foreach x of varlist q708c_* {
  replace `x' = 0 if `x' == . & d_case == 1 & survey == 2 & q703 == 0
  lab val `x' yn
}

*did not think condition serious
tab q708c_a, m
lab var q708c_a "did not think condition serious"
lab val q708c_a yn
*analysis-removed 'col' b/c single row
svy: tab q708c_a survey, ci pear obs
*condition passed
tab q708c_b, m
lab var q708c_b "condition passed"
lab val q708c_b yn
*analysis-removed 'col' b/c single row
svy: tab q708c_b survey, ci pear obs
*place of care was too far
tab q708c_c, m
lab var q708c_c "place of care was too far"
lab val q708c_c yn
*analysis-removed 'col' b/c single row
svy: tab q708c_c survey, ci pear obs
*did not have time
tab q708c_d, m
lab var q708c_d "did not have time"
lab val q708c_d yn
*analysis-no observations, removed 'col'
svy: tab q708c_d survey, ci pear obs
*did not have permission
tab q708c_e, m
lab var q708c_e "did not have permission"
lab val q708c_e yn
*analysis-no observations, removed 'col'
svy: tab q708c_e survey, ci pear obs
*did not have money
tab q708c_f, m
lab var q708c_f "did not have money"
lab val q708c_f yn
*analysis-removed 'col' b/c single row
svy: tab q708c_f survey, ci pear obs
*could treat condition at home
tab q708c_g, m
lab var q708c_g "treat at home"
lab val q708c_g yn
*analysis-removed 'col' b/c single row
svy: tab q708c_g survey, ci pear obs
*other
tab q708c_x, m
lab var q708c_x "treat at home"
lab val q708c_x yn
*analysis-removed 'col' b/c single row
svy: tab q708c_x survey, ci pear obs
*don't know
tab q708c_z, m
lab var q708c_z "don't know"
lab val q708c_z yn
*analysis-removed 'col' b/c single row
svy: tab q708c_z survey, ci pear obs

*Number of children with a health booklet or other document to record immunizations
tab q730, m
gen d_booklet = .
replace d_booklet = 0 if q730 == 3
replace d_booklet = 1 if q730 == 1 
replace d_booklet = 2 if q730 == 2
lab var d_booklet "child has health booklet w/ vaccinations"
lab def booklet 0 "no card" 1 "yes, seen card" 2 "yes, have not seen card"
lab val d_booklet booklet
tab d_booklet survey, m
*analysis
svy: tab d_booklet survey, col ci pear obs

***********************MODULE 8: FEVER******************************************
***Table: Fever Management
*Sought advice for fever
tab q803, m
recode q803 9 = .
recode q803 2 = 0
recode f_case 1=. if q803==.
*analysis
svy: tab q803 f_sex if survey == 2, col ci pear obs

*Total number of providers visited
egen f_provtot = rownonmiss (q806a-q806x), strok
replace f_provtot = . if f_case != 1
lab var f_provtot "Total number of providers where sought care"
tab f_provtot survey, col

*Sought treatment from appropriate provider
egen f_apptot = rownonmiss (q806a-q806c q806e q806g q806j q806k), strok
replace f_apptot = . if f_case != 1
lab var f_apptot "total number of appropriate providers were sought care"
recode f_apptot 2 3 4 = 1, gen (f_app_prov)
lab var f_app_prov "Sought care from 1+ appropriate provider"
lab val f_app_prov yn
tab f_app_prov survey, m
*analysis
svy: tab f_app_prov f_sex if survey == 2, col ci pear obs

*Sought treatment from a CHW
tab q806g, m
gen f_chw = . 
replace f_chw = 0 if f_case == 1
replace f_chw = 1 if q806g == "G"
lab var f_chw "Sought treatment for fever from CHW"
lab val f_chw yn
tab f_chw survey, m
*analysis
svy: tab f_chw f_sex if survey == 2, col ci pear obs

*Sought treatment from a CHW as first choice
tab q808, m
gen f_chwfirst = .
replace f_chwfirst = 0 if f_case == 1
replace f_chwfirst = 1 if q808 == "G" 
replace f_chwfirst = 1 if q806g == "G" & f_provtot == 1
lab var f_chwfirst "Sought treatment from a CHW as first choice"
lab val f_chwfirst yn
tab f_chwfirst survey, m
*analysis
svy: tab f_chwfirst f_sex if survey == 2, col ci pear obs

***Table: Joint Care Seeking
*Sought care jointly for fever
tab q805a, m
gen f_joint = .
replace f_joint = 0 if f_case == 1 & maritalstat == 1
replace f_joint = 1 if q805a == "A" & maritalstat == 1 & q803 == 1
lab var f_joint "Joint care seeking for fever"
lab val f_joint yn
tab f_joint survey, m
*analysis
svy: tab f_joint survey, col ci pear obs

***Table: Care Seeking
*sought care from an appropriate provider
tab f_app_prov survey, m
*analysis
svy: tab f_app_prov survey, col ci pear obs

*Sought care from CHW first
tab f_chwfirst survey, m
*analysis
svy: tab f_chwfirst survey, col ci pear obs

*Sought care from CHW FIRST among those who sought any care
tab q808, m
gen f_chwfirst_anycare = .
replace f_chwfirst_anycare = 0 if f_case == 1 & q803 == 1
replace f_chwfirst_anycare = 1 if q808 == "G"
replace f_chwfirst_anycare = 1 if q806g == "G" & f_provtot == 1
lab var f_chwfirst_anycare "Sought care from CHW first among those who sought any care"
lab val f_chwfirst_anycare yn
tab f_chwfirst_anycare survey, m
*analysis
svy: tab f_chwfirst_anycare survey, col ci pear obs

***Table: Care Seeking Sources
*Where CG sought care
*where care was sought
by survey: tab1 q806*

encode q806a, gen(q806_a)
encode q806b, gen(q806_b)
encode q806c, gen(q806_c)
encode q806d, gen(q806_d)
encode q806e, gen(q806_e)
encode q806f, gen(q806_f)
encode q806g, gen(q806_g)
encode q806h, gen(q806_h)
encode q806i, gen(q806_i)
encode q806j, gen(q806_j)
encode q806k, gen(q806_k)
encode q806l, gen(q806_l)
encode q806m, gen(q806_m)
encode q806x, gen(q806_x)

foreach x of varlist q806_* {
  replace `x' = 0 if `x' == . & f_case == 1 & q803 == 1
  lab val `x' yn
}
*careseeking locations
gen f_cs_hosp = 1 if q806_a == 1 
gen f_cs_hcent = 1 if q806_b == 1 
gen f_cs_hpost = 1 if q806_c == 1
gen f_cs_ngo = 1 if q806_d == 1
gen f_cs_clin = 1 if q806_e == 1
gen f_cs_rmod = 1 if q806_f == 1
gen f_cs_chw = 1 if q806_g == 1
gen f_cs_cdd = 1 if q806_h == 1
gen f_cs_trad = 1 if q806_i == 1
gen f_cs_ppmv = 1 if q806_j == 1
gen f_cs_phar = 1 if q806_k == 1
gen f_cs_friend = 1 if q806_l == 1
gen f_cs_mark = 1 if q806_m == 1
gen f_cs_other = 1 if q806_x == 1

foreach x of varlist f_cs_* {
  replace `x' = 0 if f_case == 1 & q803 == 1 & `x' ==.
  lab val `x' yn
}
*hospital
tab f_cs_hosp, m
lab var f_cs_hosp "hospital"
lab val f_cs_hosp yn
*analysis
svy: tab f_cs_hosp survey, col ci pear obs
*health center
tab f_cs_hcent, m
lab var f_cs_hcent "health center"
lab val f_cs_hcent yn
*analysis
svy: tab f_cs_hcent survey, col ci pear obs
*health post
tab f_cs_hpost, m
lab var f_cs_hpost "health post"
lab val f_cs_hpost yn
*analysis
svy: tab f_cs_hpost survey, col ci pear obs
*health ngo
tab f_cs_ngo, m
lab var f_cs_ngo "NGO center"
lab val f_cs_ngo yn
*analysis
svy: tab f_cs_ngo survey, col ci pear obs
*Clinic
tab f_cs_clin, m
lab var f_cs_clin "clinic"
lab val f_cs_clin yn
*analysis
svy: tab f_cs_clin survey, col ci pear obs
*Role Modle
tab f_cs_rmod, m
lab var f_cs_rmod "role model"
lab val f_cs_rmod yn
*analysis
svy: tab f_cs_rmod survey, col ci pear obs
*CHW
tab f_cs_chw, m
lab var f_cs_chw "chw"
lab val f_cs_chw yn
*analysis
svy: tab f_cs_chw survey, col ci pear obs
*Traditional practitioner
tab f_cs_trad, m
lab var f_cs_trad "traditional practitioner"
lab val f_cs_trad yn
*analysis
svy: tab f_cs_trad survey, col ci pear obs
*PPMV
tab f_cs_ppmv, m
lab var f_cs_ppmv "PPMV"
lab val f_cs_ppmv yn
*analysis
svy: tab f_cs_ppmv survey, col ci pear obs
*Pharmacy
tab f_cs_phar, m
lab var f_cs_phar "pharmacy"
lab val f_cs_phar yn
*analysis
svy: tab f_cs_phar survey, col ci pear obs
*Friend
tab f_cs_friend, m
lab var f_cs_friend "friend/relative"
lab val f_cs_friend yn
*analysis
svy: tab f_cs_friend survey, col ci pear obs
*Market
tab f_cs_mark, m
lab var f_cs_mark "market"
lab val f_cs_mark yn
*analysis
svy: tab f_cs_mark survey, col ci pear obs
*Other
tab f_cs_other, m
lab var f_cs_other "other"
lab val f_cs_other yn
*analysis
svy: tab f_cs_other survey, col ci pear obs

*First source of care locations
gen f_fcs_hosp = 1 if q808 == "A"
gen f_fcs_hcent = 1 if q808 == "B" 
gen f_fcs_hpost = 1 if q808 == "C" 
gen f_fcs_ngo = 1 if q808 == "D" 
gen f_fcs_clin = 1 if q808 == "E" 
gen f_fcs_rmod = 1 if q808 == "F"
gen f_fcs_chw = 1 if q808 == "G"
gen f_fcs_cdd = 1 if q808 == "H"
gen f_fcs_trad = 1 if q808 == "I"
gen f_fcs_ppmv = 1 if q808 == "J" 
gen f_fcs_phar = 1 if q808 == "K"
gen f_fcs_friend = 1 if q808 == "L"
gen f_fcs_mark = 1 if q808 == "M"
gen f_fcs_other = 1 if q808 == "X"

replace f_fcs_hosp = 1 if q806_a == 1 & f_provtot == 1
replace f_fcs_hcent = 1 if q806_b == 1 & f_provtot == 1
replace f_fcs_hpost = 1 if q806_c == 1 & f_provtot == 1
replace f_fcs_ngo = 1 if q806_d == 1 & f_provtot == 1
replace f_fcs_clin = 1 if q806_e == 1 & f_provtot == 1
replace f_fcs_rmod = 1 if q806_f == 1 & f_provtot == 1
replace f_fcs_chw = 1 if q806_g == 1 & f_provtot == 1
replace f_fcs_cdd = 1 if q806_h == 1 & f_provtot == 1
replace f_fcs_trad = 1 if q806_i == 1 & f_provtot == 1
replace f_fcs_ppmv = 1 if q806_j == 1 & f_provtot == 1
replace f_fcs_phar = 1 if q806_k == 1 & f_provtot == 1
replace f_fcs_friend = 1 if q806_l == 1 & f_provtot == 1
replace f_fcs_mark = 1 if q806_m == 1 & f_provtot == 1
replace f_fcs_other = 1 if q806_x == 1 & f_provtot == 1

foreach x of varlist f_fcs_* {
  replace `x' = 0 if f_case == 1 & q803 == 1 & `x' ==.
  lab val `x' yn
}

*hospital
tab f_fcs_hosp, m
lab var f_fcs_hosp "hospital"
lab val f_fcs_hosp yn
*analysis
svy: tab f_fcs_hosp survey, col ci pear obs
*health center
tab f_fcs_hcent, m
lab var f_fcs_hcent "health center"
lab val f_fcs_hcent yn
*analysis
svy: tab f_fcs_hcent survey, col ci pear obs
*health post
tab f_fcs_hpost, m
lab var f_fcs_hpost "health post"
lab val f_fcs_hpost yn
*analysis
svy: tab f_fcs_hpost survey, col ci pear obs
*health ngo
tab f_fcs_ngo, m
lab var f_fcs_ngo "NGO center"
lab val f_fcs_ngo yn
*analysis
svy: tab f_fcs_ngo survey, col ci pear obs
*Clinic
tab f_fcs_clin, m
lab var f_fcs_clin "clinic"
lab val f_fcs_clin yn
*analysis
svy: tab f_fcs_clin survey, col ci pear obs
*Role Model
tab f_fcs_rmod, m
lab var f_fcs_rmod "role model"
lab val f_fcs_rmod yn
*analysis-removed 'col' b/c single row
svy: tab f_fcs_rmod survey, ci pear obs
*CHW
tab f_fcs_chw, m
lab var f_fcs_chw "chw"
lab val f_fcs_chw yn
*analysis
svy: tab f_fcs_chw survey, col ci pear obs
*Traditional practitioner
tab f_fcs_trad, m
lab var f_fcs_trad "traditional practitioner"
lab val f_fcs_trad yn
*analysis
svy: tab f_fcs_trad survey, col ci pear obs
*PPMV
tab f_fcs_ppmv, m
lab var f_fcs_ppmv "PPMV"
lab val f_fcs_ppmv yn
*analysis
svy: tab f_fcs_ppmv survey, col ci pear obs
*Pharmacy
tab f_fcs_phar, m
lab var f_fcs_phar "pharmacy"
lab val f_fcs_phar yn
*analysis
svy: tab f_fcs_phar survey, col ci pear obs
*Friend
tab f_fcs_friend, m
lab var f_fcs_friend "friend/relative"
lab val f_fcs_friend yn
*analysis
svy: tab f_fcs_friend survey, col ci pear obs
*Market
tab f_fcs_mark, m
lab var f_fcs_mark "market"
lab val f_fcs_mark yn
*analysis
svy: tab f_fcs_mark survey, col ci pear obs
*Other
tab f_fcs_other, m
lab var f_fcs_other "other"
lab val f_fcs_other yn
*analysis
svy: tab f_fcs_other survey, col ci pear obs

*Had blood taken from finger or heel
tab q809, m
recode q809 9 = .
gen f_bloodtaken = .
replace f_bloodtaken = 0 if f_case == 1
replace f_bloodtaken = 1 if q809 == 1
lab var f_bloodtaken "Had blood taken from finger or heel"
lab val f_bloodtaken yn
tab f_bloodtaken survey, m
*analysis
svy: tab f_bloodtaken f_case, col ci pear obs
svy: tab f_bloodtaken f_sex if survey == 2, col ci pear obs

*Of those with blood taken, if they got results
tab q811, m
gen f_gotresult = .
replace f_gotresult = 0 if f_bloodtaken == 1
replace f_gotresult = 1 if f_bloodtaken == 1 & q811 == 1
lab var f_gotresult "CG got results if blood taken"
lab val f_gotresult yn
tab f_gotresult survey, m
*analysis 
svy: tab f_gotresult f_sex if survey == 2, col ci pear obs

*Of those with blood test, the test was positive
tab q812, m
recode q812 2 8 = 0
gen f_result = .
replace f_result = 0 if f_gotresult == 1
replace f_result = 1 if q812 == 1 & f_gotresult == 1
lab var f_result "Results of blood test"
lab def results 1 "Positive" 0 "Negative"
lab val f_result results
tab f_result survey, m
*analysis
svy: tab f_result f_sex if survey == 2, col ci pear obs

*Location of assessment
tab1 q809aa-q809az

gen q809a_a = 1 if q809aa=="A"
gen q809a_b = 1 if q809ab=="B"
gen q809a_c = 1 if q809ac=="C"
gen q809a_d = 1 if q809ad=="D"
gen q809a_e = 1 if q809ae=="E"
gen q809a_x = 1 if q809ax=="X"
gen q809a_z = 1 if q809az=="Z"

foreach x of varlist q809a_* {
  replace `x' = 0 if `x' ==. & q809 == 1
  lab val `x' yn
}
*hospital
tab q809a_a, m
lab var q809a_a "blood test taken at hospital"
lab val q809a_a yn
*analysis
svy: tab q809a_a survey, col ci pear obs
*health center
tab q809a_b, m
lab var q809a_b "blood test taken at health center"
lab val q809a_b yn
*analysis
svy: tab q809a_b survey, col ci pear obs
*health post
tab q809a_c, m
lab var q809a_c "blood test taken at health post"
lab val q809a_c yn
*analysis
svy: tab q809a_c survey, col ci pear obs
*Private Clinic
tab q809a_d, m
lab var q809a_d "blood test taken at private clinic"
lab val q809a_d yn
*analysis
svy: tab q809a_d survey, col ci pear obs
*Community
tab q809a_e, m
lab var q809a_e "blood test taken at community"
lab val q809a_e yn
*analysis
svy: tab q809a_e survey, col ci pear obs
*Other
tab q809a_x, m
lab var q809a_x "blood test taken at other location"
lab val q809a_x yn
*analysis
svy: tab q809a_x survey, col ci pear obs
*Don't know
tab q809a_z, m
lab var q809a_z "Don't know location of blood test"
lab val q809a_z yn
*analysis
svy: tab q809a_z survey, col ci pear obs

*Health worker who performed the blood test
tab1 q810a-q810z
gen q810_a = 1 if q810a == "A" | q810 == 1
gen q810_b = 1 if q810b == "B" | q810 == 2
gen q810_c = 1 if q810c == "C" | q810 == 3
gen q810_d = 1 if q810d == "D" | q810 == 4
gen q810_e = 1 if q810e == "E" | q810 == 5
gen q810_x = 1 if q810x == "X" | q810 == 6
gen q810_z = 1 if q810z == "Z" | q810 == 8

foreach x of varlist q810_* {
  replace `x' = 0 if `x' ==. & q809 == 1
  lab val `x' yn
}
*CHW
tab q810_a, m
lab var q810_a "CHW performed blood test"
lab val q810_a yn
*analysis
svy: tab q810_a survey, col ci pear obs
*Medical assistant
tab q810_b, m
lab var q810_b "Medical assistant performed blood test"
lab val q810_b yn
*analysis
svy: tab q810_b survey, col ci pear obs
*clinical officer
tab q810_c, m
lab var q810_c "Clinical officer performed blood test"
lab val q810_c yn
*analysis
svy: tab q810_c survey, col ci pear obs
*Nurse
tab q810_d, m
lab var q810_d "Nurse performed blood test"
lab val q810_d yn
*analysis
svy: tab q810_d survey, col ci pear obs
*Doctor
tab q810_e, m
lab var q810_e "Doctor performed blood test"
lab val q810_e yn
*analysis
svy: tab q810_e survey, col ci pear obs
*Other
tab q810_x, m
lab var q810_x "Other provider performed blood test"
lab val q810_x yn
*analysis-removed 'col' b/c single row
svy: tab q810_x survey, ci pear obs

egen f_bloodtaken_tot = anycount(q810_a-q810_x), values(1)
replace f_bloodtaken_tot = . if f_bloodtaken !=1

***Table: Assessment
*Cases managed by CORP: child had blood taken
tab q810a, m
tab q810, m
gen f_bloodtakenchw = .
replace f_bloodtakenchw = 0 if f_chw == 1
replace f_bloodtakenchw = 1 if (q810a == "A" | q810 == 1) & f_chw == 1
lab var f_bloodtakenchw "Child had blood taken by CHW"
lab val f_bloodtakenchw yn
tab f_bloodtakenchw survey, m
*analysis
svy: tab f_bloodtakenchw survey, col ci pear obs

*Cases managed by provider other than CORP: child had blood taken
gen f_bloodtakenoth = .
replace f_bloodtakenoth = 0 if f_case == 1 & (f_provtot >= 2 |(f_provtot == 1 & f_chw != 1))
replace f_bloodtakenoth = 1 if ((f_bloodtaken_tot == 1 & q810_a != 1) | (f_bloodtaken_tot >= 2)) & (f_provtot >= 2 |(f_provtot == 1 & f_chw != 1)) & f_case == 1
replace f_bloodtakenoth = . if f_bloodtaken_tot == 0
lab var f_bloodtakenoth "Child had blood taken by provider other than CHW"
lab val f_bloodtakenoth yn
tab f_bloodtakenoth survey, m
*analysis
svy: tab f_bloodtakenoth survey, col ci pear obs

*Cases managed by CORP: Caregiver recieved results of blood test
gen f_gotresultchw = .
replace f_gotresultchw = 0 if f_bloodtakenchw == 1
replace f_gotresultchw = 1 if f_gotresult == 1 & f_bloodtakenchw == 1
lab var f_gotresultchw "Caregiver recieved results from CHW"
lab val f_gotresultchw yn
tab f_gotresultchw survey, m
*analysis 
svy: tab f_gotresultchw survey, col ci pear obs

*Cases managed by provider other than CORP: Caregiver recieved results of blood test
gen f_gotresultoth = .
replace f_gotresultoth = 0 if f_bloodtakenoth == 1
replace f_gotresultoth = 1 if f_gotresult == 1 & f_bloodtakenoth == 1
lab var f_gotresultoth "Caregiver recieved results from provider other than CHW"
lab val f_gotresultoth yn
tab f_gotresultoth survey, m
*analysis 
svy: tab f_gotresultoth survey, col ci pear obs

*Cases managed by CORP: Blood test was positive
gen f_resultchw = .
replace f_resultchw = 0 if f_gotresultchw == 1
replace f_resultchw = 1 if f_result == 1 & f_gotresultchw == 1
lab var f_resultchw "Received positive blood test result from CHW"
lab val f_resultchw yn
tab f_resultchw survey, m
*analysis
svy: tab f_resultchw survey, col ci pear obs

*Cases managed by provider other than CORP: Blood test was positive
gen f_resultoth = .
replace f_resultoth = 0 if f_gotresultoth == 1
replace f_resultoth = 1 if f_result == 1 & f_gotresultoth == 1
lab var f_resultoth "Received positive blood test result from provider other than CHW"
lab val f_resultoth yn
tab f_resultoth survey, m
*analysis
svy: tab f_resultoth survey, col ci pear obs

*Any antimalarial taken 
tab q814a, m
tab q814b, m
tab q814c, m
gen f_antim = .
replace f_antim = 0 if f_case == 1
replace f_antim = 1 if q814a == "A" | q814b == "B" | q814c == "C"
lab var f_antim "Any antimalarial taken"
lab val f_antim yn
tab f_antim survey, m
*analysis
svy: tab f_antim f_sex if survey == 2, col ci pear obs

*Given any antimalarial for positive test
gen f_antimc = .
replace f_antimc = 0 if f_result == 1
replace f_antimc = 1 if f_antim == 1 & f_result == 1
lab var f_antimc "Recieve any antimalarial among those with a positive test"
lab val f_antimc yn
tab f_antimc survey, m
*analysis
svy: tab f_antimc f_sex if survey == 2, col ci pear obs

*Took ACT for fever treatment
tab q814a, m
gen f_act = .
replace f_act = 0 if f_case == 1
replace f_act = 1 if q814a == "A"
lab var f_act "Took ACT for Fever Tx"
lab val f_act yn
tab f_act survey, m
*analysis
svy: tab f_act f_sex if survey == 2, col ci pear obs

*Took ACT w/in 24 hours for fever treatment
tab q817, m
gen f_act24 = .
replace f_act24 = 0 if f_case == 1
replace f_act24 = 1 if f_act == 1 & q817 < 2
lab var f_act24 "Took ACT w/in 24 hours"
lab val f_act24 yn
tab f_act24 survey, m
*analysis
svy: tab f_act24 f_sex if survey == 2, col ci pear obs

*ACT given if positive test
tab f_act, m
gen f_actc = .
replace f_actc = 0 if f_result == 1
replace f_actc = 1 if f_act == 1 & f_result == 1
lab var f_actc "Recieved ACT for positive blood test"
lab val f_actc yn
tab f_actc survey, m

*took ACT within 24 hours (same or next day), confirmed malaria - positive blood test, among those w/positive RDT
gen f_act24c = .
replace f_act24c = 0 if f_result == 1
replace f_act24c = 1 if f_actc == 1 & q817 < 2 
lab var f_act24c "Confirmed malaria treatment, same or next day"
lab val f_act24c yn
tab f_act24c survey, col
*analysis
svy: tab f_act24c f_sex if survey == 2, col ci pear obs

*Recieved ACT from CHW 
gen f_actchw = .
replace f_actchw = 0 if f_case == 1
replace f_actchw = 1 if f_act == 1 & q816 == 17 
lab var f_actchw "ACT treatment by a CHW"
lab val f_actchw yn
tab f_actchw survey, col

*Received ACT within 24 hours from CHW 
gen f_act24chw = .
replace f_act24chw = 0 if f_case == 1
replace f_act24chw = 1 if f_act24 == 1 & f_actchw == 1
lab var f_act24chw "Received ACT within 24 hours from CHW"
lab val f_act24chw yn
tab f_act24chw survey, m
*analysis
svy: tab f_actchw survey, ci pear obs

*Received ACT from CHW among those with + blood test
gen f_actcchw = .
replace f_actcchw = 0 if f_result == 1
replace f_actcchw = 1 if f_actchw == 1 & f_resultchw == 1
lab var f_actcchw "Received ACT from CHW after positive result from CHW"
lab val f_actcchw yn
tab f_actcchw survey, m
*analysis
svy: tab f_actcchw survey, ci pear obs

*Received ACT within 24 hours from CHW among those with + blood test
gen f_act24cchw = .
replace f_act24cchw = 0 if f_result == 1
replace f_act24cchw = 1 if f_act24chw == 1 & f_resultchw == 1
lab var f_act24cchw "Received ACT from CHW after positive result from CHW"
lab val f_act24cchw yn
tab f_act24cchw survey, m
*analysis
svy: tab f_actcchw survey, ci pear obs

*Received ACT from CHW among those who sought care from CHW and had +blood test
gen f_actcchw2 = .
replace f_actcchw2 = 0 if f_resultchw == 1
replace f_actcchw2 = 1 if f_actchw == 1 & f_resultchw == 1
lab var f_actcchw2 "Received ACT from CHW after positive result from CHW"
lab val f_actcchw2 yn
tab f_actcchw2 survey, m
*analysis
svy: tab f_actcchw2 survey, ci pear obs

*All Cases: child had blood drawn
tab f_bloodtaken, m
*analysis
svy: tab f_bloodtaken survey, col ci pear obs

*All Cases: Caregiver reiceved results of blood test (INDICATOR 11)
tab f_gotresult, m
*analysis
svy: tab f_gotresult survey, col ci pear obs

*All Cases: Blood test positive for malaria
tab f_result, m
*analysis
svy: tab f_result survey, col ci pear obs

*All Cases: Recieved ACT after positive blood test
*ACT given if positive test
*analysis
svy: tab f_actc survey, col ci pear obs

***Table: Appropriate Treatment
*Received ACT for fever (Appropriate treatment table, all cases indicator 1/4)
tab f_act survey, m
*analysis
svy: tab f_act survey, col ci pear obs

*Received ACT for fever within 24 hours (Appropriate treatment table, all cases indicator 2/4)
tab f_act24 survey, m
*analysis
svy: tab f_act24 survey, col ci pear obs

*Recieved appropriate treatment (Appropriate treatment table, all cases indicator 3/4)
tab f_actc survey, m
*analysis
svy: tab f_actc survey, col ci pear obs

*Recieved appropriate treatment for confirmed malaria w/in 24 hours (Appropriate treatment table, all cases indicator 4/4)
tab q817, m
tab f_act24c survey, m
*analysis
svy: tab f_act24c survey, col ci pear obs

*Received ACT for fever from CHW (Appropriate treatment table, CHW indicator 1/4)
*analysis
svy: tab f_actchw survey, col ci pear obs

**Received ACT for fever within 24 hours from CHW (Appropriate treatment table, CHW indicator 2/4)
*analysis
svy: tab f_act24chw survey, col ci pear obs

*Recieved appropriate treatment from CHW (Appropriate treatment table, CHW indicator 3/4)
*analysis 
svy: tab f_actcchw survey, col ci pear obs

***ACT within 24 hours (same or next day), confirmed malaria treatment by CHW
*analysis-removed 'col' b/c single row
svy: tab f_act24cchw survey, ci pear obs

*Recieved ACT for fever from provider other than CHW (New WHO Indicator, other provider 1/4)
gen f_actother = .
replace f_actother = 0 if f_case == 1
replace f_actother = 1 if f_act == 1 & f_actchw != 1
lab var f_actother "recived ACT for fever from provider other than CHW"
lab val f_actother yn
tab f_actother survey, m
*Analysis
svy: tab f_actother survey, col ci pear obs

*Recieved ACT from provider other than CHW among those who sought care from other providers
gen f_actoth2 = .
replace f_actoth2 = 0 if (f_provtot >= 2 | (f_provtot == 1 & f_chw != 1)) & f_case == 1 
replace f_actoth2 = 1 if f_actother == 1 & (f_provtot >= 2 | (f_provtot == 1 & f_chw != 1) & f_case == 1)
lab var f_actoth2 "Recieved ACT from provider other than CHW, among those who sought care from providers other than CHW"
lab val f_actoth2 yn
tab f_actoth2, m
*analysis
svy: tab f_actoth2 survey, col ci pear obs

*Recived ACT for fever from provider other than CHW within 24hrs (New WHO Indicator, other provider 2/4)
gen f_act24other = .
replace f_act24other = 0 if f_case == 1
replace f_act24other = 1 if f_act == 1 & f_act24chw != 1 & q817 < 2
lab var f_act24other "recived ACT for fever from provider other than CHW w/in 24 hrs"
lab val f_act24other yn
tab f_act24other survey, m
*Analysis
svy: tab f_act24other survey, col ci pear obs

*Recieved ACT from provider other than CHW within 24 hours among those who sought care from other providers
gen f_act24oth2 = .
replace f_act24oth2 = 0 if (f_provtot >= 2 | (f_provtot == 1 & f_chw != 1)) & f_case == 1 
replace f_act24oth2 = 1 if f_act24other == 1 & (f_provtot >= 2 | (f_provtot == 1 & f_chw != 1) & f_case == 1)
lab var f_act24oth2 "Recieved ACT within 24 hours from provider other than CHW, among those who sought care from providers other than CHW"
lab val f_act24oth2 yn
tab f_act24oth2, m
*analysis
svy: tab f_act24oth2 survey, col ci pear obs

gen f_actcother = .
replace f_actcother = 0 if f_result == 1
replace f_actcother = 1 if f_actc == 1 & f_actchw != 1
lab var f_actcother "recieved ACT for confirmed malaria from provider other than CHW"
lab val f_actcother yn
tab f_actcother survey, m
*Analysis-removed 'col' b/c single row
svy: tab f_actcother survey, ci pear obs

*Recieved ACT from provider other than CHW, among those who sought care from other providers & had + blood test
gen f_actcoth2 = .
replace f_actcoth2 = 0 if (f_provtot >= 2 | (f_provtot == 1 & f_chw != 1)) & f_resultoth == 1 
replace f_actcoth2 = 1 if f_actcother == 1 & (f_provtot >= 2 | (f_provtot == 1 & f_chw != 1)) & f_resultoth == 1 
lab var f_actcoth2 "recieved ACT for confirmed malaria from provider other than CHW, + blood test"
lab val f_actcoth2 yn
tab f_actcoth2 survey, m
svy: tab f_actcoth2 survey, ci col pear obs

*Recieved ACT for confirmed malaria from provider other than CHW w/in 24 hrs (New WHO Indicator, other provider 4/4)
gen f_actc24other = .
replace f_actc24other = 0 if f_result == 1
replace f_actc24other = 1 if f_act24c == 1 & f_act24cchw != 1 & q817 < 2
lab var f_actc24other "recieved ACT for confirmed malaria from provider other than CHW w/in 24hrs"
lab val f_actc24other yn
tab f_actc24other survey, m
*analysis-removed 'col' b/c single row
svy: tab f_actc24other survey, ci pear obs

*Recieved ACT from provider other than CHW, among those who sought care from other providers & had + blood test
gen f_actc24oth2 = .
replace f_actc24oth2 = 0 if (f_provtot >= 2 | (f_provtot == 1 & f_chw != 1)) & f_resultoth == 1 
replace f_actc24oth2 = 1 if f_actc24other == 1 & (f_provtot >= 2 | (f_provtot == 1 & f_chw != 1)) & f_resultoth == 1 
lab var f_actc24oth2 "recieved ACT for confirmed malaria from provider other than CHW within 24 hours, + blood test"
lab val f_actc24oth2 yn
tab f_actc24oth2 survey, m
*Analysis-removed 'col' b/c single row
svy: tab f_actc24oth2 survey, ci pear obs

*received ACT from CHW, among those who sought care from a CHW (Appropriate treatment table 2, indicator 1/4)
gen f_actchw2 = .
replace f_actchw2 = 0 if f_chw == 1
replace f_actchw2 = 1 if f_chw == 1 & f_actchw == 1
lab var f_actchw2 "ACT treatment by CHW, among those who sought care from a CHW"
lab val f_actchw2 yn
tab f_actchw2 survey

*received ACT from CHW within 24 hours, among those who sought care from a CHW (Appropriate treatment table 2, indicator 2/4)
gen f_act24chw2 = .
replace f_act24chw2 = 0 if f_chw == 1
replace f_act24chw2 = 1 if f_chw == 1 & f_act24chw == 1
lab var f_act24chw2 "ACT treatment by CHW within 24 hours, among those who sought care from a CHW"
lab val f_act24chw2 yn
tab f_act24chw2 survey

*Recieved appropriate treatment among those who sought care from CHW (Appropriate treatment table 2, indicator 3/4)
tab f_actcchw2 survey, m
*analysis
svy: tab f_actcchw2 survey, col ci pear obs

*ACT treatment with 24 hours from CHW - positive blood test, among those who sought care from a CHW (Appropriate treatment table 2, indicator 4/4)
gen f_act24cchw2 = .
replace f_act24cchw2 = 0 if f_resultchw == 1
replace f_act24cchw2 = 1 if f_act24cchw == 1  & f_resultchw==1
lab var f_act24cchw2 "ACT treatment within 24 hours by a CHW - blood test+, among those who sought care from a CHW"
lab val f_act24cchw2 yn
tab f_act24cchw2 survey, m
*analysis-removed 'col' b/c single row
svy: tab f_act24cchw2 survey, ci pear obs

*Treatment taken for fever
sort survey
by survey: tab1 q814*

gen q814_a = 1 if q814a=="A"
gen q814_b = 1 if q814b=="B"
gen q814_c = 1 if q814c=="C"
gen q814_d = 1 if q814d=="D"
gen q814_e = 1 if q814e=="E"
gen q814_f = 1 if q814f=="F"
gen q814_g = 1 if q814g=="G"
gen q814_x = 1 if q814x=="X"
gen q814_z = 1 if q814z=="Z"


foreach x of varlist q814_* {
  replace `x' = 0 if `x' ==. & q813 == 1
  lab val `x' yn
}

*ACT
tab q814_a, m
lab var q814_a "ACT"
lab val q814_a yn
*analysis
svy: tab q814_a survey, col ci pear obs
*quinine
tab q814_b, m
lab var q814_b "Quinine"
lab val q814_b yn
*analysis
svy: tab q814_b survey, col ci pear obs
*sp/fansidar
tab q814_c, m
lab var q814_c "SP/Fansidar"
lab val q814_c yn
*analysis
svy: tab q814_c survey, col ci pear obs
*antibiotic pill or syrup
tab q814_d, m
lab var q814_d "Antibiotic pill/syrup"
lab val q814_d yn
*analysis
svy: tab q814_d survey, col ci pear obs
*antibiotic injection
tab q814_e, m
lab var q814_e "Antibiotic injection"
lab val q814_e yn
*analysis
svy: tab q814_e survey, col ci pear obs
*Aspirin
tab q814_f, m
lab var q814_f "Aspirin"
lab val q814_f yn
*analysis
svy: tab q814_f survey, col ci pear obs
*Paracetamol
tab q814_g, m
lab var q814_g "Paracetamol"
lab val q814_g yn
*analysis
svy: tab q814_g survey, col ci pear obs
*Other
tab q814_x, m
lab var q814_x "Other"
lab val q814_x yn
*analysis
svy: tab q814_x survey, col ci pear obs

***Table: Source of treatment
*Source of ACT
tab q816 survey, col

gen f_act_hosp = 1 if q816 == 11 
gen f_act_hcent = 1 if q816 == 12
gen f_act_hpost = 1 if q816 == 13
gen f_act_ngo = 1 if q816 == 14
gen f_act_clin = 1 if q816 == 15
gen f_act_rmod = 1 if q816 == 16
gen f_act_chw = 1 if q816 == 17
gen f_act_trad = 1 if q816 == 21 
gen f_act_ppmv = 1 if q816 == 22
gen f_act_phar = 1 if q816 == 23 
gen f_act_friend = 1 if q816 == 26
gen f_act_mark = 1 if q816 == 27
gen f_act_other = 1 if q816 == 31 

foreach x of varlist f_act_* {
  replace `x' = 0 if f_case == 1 & f_act == 1 & `x' ==.
  lab val `x' yn
}

*hospital
tab f_act_hosp, m
lab var f_act_hosp "Source of ACT: Hospital"
lab val f_act_hosp yn
*analysis
svy: tab f_act_hosp survey, col ci pear obs
*health center
tab f_act_hcent, m
lab var f_act_hcent "Source of ACT: Health center"
lab val f_act_hcent yn
*analysis
svy: tab f_act_hcent survey, col ci pear obs
*health post
tab f_act_hpost, m
lab var f_act_hpost "Source of ACT: Health post"
lab val f_act_hpost yn
*analysis
svy: tab f_act_hpost survey, col ci pear obs
*NGO
tab f_act_ngo, m
lab var f_act_ngo "Source of ACT: NGO"
lab val f_act_ngo yn
*analysis-removed 'col' b/c single row
svy: tab f_act_ngo survey, ci pear obs
*clinic
tab f_act_clin, m
lab var f_act_clin "Source of ACT: Clinic"
lab val f_act_clin yn
*analysis
svy: tab f_act_clin survey, col ci pear obs
*role model
tab f_act_rmod, m
lab var f_act_rmod "Source of ACT: Role Model"
lab val f_act_rmod yn
*analysis-removed 'col' b/c single row
svy: tab f_act_rmod survey, ci pear obs
*chw
tab f_act_chw, m
lab var f_act_chw "Source of ACT: CHW"
lab val f_act_chw yn
*analysis
svy: tab f_act_chw survey, col ci pear obs
*Traditional practitioner
tab f_act_trad, m
lab var f_act_trad "Source of ACT: Traditional Practitioner"
lab val f_act_trad yn
*analysis-removed 'col' b/c single row
svy: tab f_act_trad survey, ci pear obs
*PPMV
tab f_act_ppmv, m
lab var f_act_ppmv "Source of ACT: PPMV"
lab val f_act_ppmv yn
*analysis
svy: tab f_act_ppmv survey, col ci pear obs
*Pharmacy
tab f_act_phar, m
lab var f_act_phar "Source of ACT: Pharmacy"
lab val f_act_phar yn
*analysis
svy: tab f_act_phar survey, col ci pear obs
*Friend/relative
tab f_act_friend, m
lab var f_act_friend "Source of ACT: Friend/Relative"
lab val f_act_friend yn
*analysis-removed 'col' b/c single row
svy: tab f_act_friend survey, ci pear obs
*Market
tab f_act_mark, m
lab var f_act_mark "Source of ACT: Market"
lab val f_act_mark yn
*analysis-remove 'col' b/c single row
svy: tab f_act_mark survey, ci pear obs
*Other
tab f_act_other, m
lab var f_act_other "Source of ACT: Other"
lab val f_act_other yn
*analysis-remove 'col' b/c single row
svy: tab f_act_other survey, ci pear obs

***Table: CORP first dose
*Recieved ACT from CHW
tab f_actchw survey, col
*analysis
svy: tab f_actchw survey, col ci pear obs

*Recieved first dose of ACT in front of CHW (INDICATOR 15A)
*one missing, recoded to 0
tab q819, m
gen f_act_chwp = .
replace f_act_chwp = 0 if f_actchw == 1
replace f_act_chwp = 1 if q819 == 1
lab var f_act_chwp "Recieved first dose of ACT in front of CHW"
lab val f_act_chwp yn
tab f_act_chwp survey, m
*analysis
svy: tab f_act_chwp survey, col ci pear obs

***Table: Recieved counseling for treatment from CHW
*Recived counseling for ACT from CHW--1 missing, coded as 0 (INDICATOR 16)
tab q820, m
gen f_act_chwc = .
replace f_act_chwc = 0 if f_actchw == 1
replace f_act_chwc = 1 if q820 == 1
lab var f_act_chwc "Recieved counseling for ACT from CHW"
lab val f_act_chwc yn
tab f_act_chwc survey, m
*analysis
svy: tab f_act_chwc survey, col ci pear obs

***Table: Referral Adherence
*Recieved referral from CHW
tab q823, m
gen f_chwrefer = .
replace f_chwrefer = 0 if f_chw == 1
replace f_chwrefer = 1 if q823 == 1
lab var f_chwrefer "Recieved referral from CHW"
lab val f_chwrefer yn
tab f_chwrefer survey, m
*analysis
svy: tab f_chwrefer survey, col ci pear obs

*Adhered to referral from CHW
gen f_referadhere = .
replace f_referadhere = 0 if q823 == 1
replace f_referadhere = 1 if q824 == 1 
lab var f_referadhere "Adhered to referral from CHW"
lab val f_referadhere yn
tab f_referadhere survey, m
*analysis
svy: tab f_referadhere survey, col ci pear obs

*Reasons did not comply with referral
tab1 q825*

encode q825a, gen(q825_a)
encode q825b, gen(q825_b)
encode q825c, gen(q825_c)
encode q825d, gen(q825_d)
encode q825e, gen(q825_e)
encode q825f, gen(q825_f)
encode q825g, gen(q825_g)
encode q825h, gen(q825_h)
encode q825x, gen(q825_x)
encode q825z, gen(q825_z)

foreach x of varlist q825_* {
  replace `x' = 0 if `x' == . & (q824 == 2|q824 == 9)
  lab val `x' yn
}

*too far
tab q825_a, m
lab var q825_a "too far"
lab val q825_a yn
tab q825_a survey, m
*analysis
svy: tab q825_a survey, col ci pear obs
*did not have money
tab q825_b, m
lab var q825_b "did not have money"
lab val q825_b yn
tab q825_b survey, m
*analysis-removed col b/c single row
svy: tab q825_b survey, ci pear obs
*no transport
tab q825_c, m
lab var q825_c "no transport"
lab val q825_c yn
tab q825_c survey, m
*analysis-removed col b/c single row
svy: tab q825_c survey, ci pear obs
*did not think illness serious
tab q825_d, m
lab var q825_d "did not think illness serious"
lab val q825_d yn
tab q825_d survey, m
*analysis-removed col b/c single row
svy: tab q825_d survey, ci pear obs
*child improved
tab q825_e, m
lab var q825_e "child improved"
lab val q825_e yn
tab q825_e survey, m
*analysis
svy: tab q825_e survey, col ci pear obs
*no time
tab q825_f, m
lab var q825_f "no time"
lab val q825_f yn
tab q825_f survey, m
*analysis-removed col b/c single row
svy: tab q825_f survey, ci pear obs
*went somewhere else
tab q825_g, m
lab var q825_g "went somewhere else"
lab val q825_g yn
tab q825_g survey, m
*analysis
svy: tab q825_g survey, col ci pear obs
*did not have husband's permission
tab q825_h, m
lab var q825_h "no permission"
lab val q825_h yn
tab q825_h survey, m
*analysis-removed 'col' b/c single row
svy: tab q825_h survey, ci pear obs
*other
tab q825_x, m
lab var q825_x "other"
lab val q825_x yn
tab q825_x survey, m
*analysis-removed col b/c single row
svy: tab q825_x survey, ci pear obs
*don't know
tab q825_z, m
lab var q825_z "don't know"
lab val q825_z yn
tab q825_z survey, m
*analysis
svy: tab q825_z survey, col ci pear obs

***Table: CHW Follow up
*CHW did follow up 
tab q826, m
gen f_chw_fu = .
replace f_chw_fu = 0 if f_chw == 1
replace f_chw_fu = 1 if q826 == 1
lab var f_chw_fu "CHW did follow up"
lab val f_chw_fu yn
tab f_chw_fu survey, m
*analysis
svy: tab f_chw_fu survey, col ci pear obs

***Table: No Care Seeking Reasons
*CG did not seek care for fever
tab q803, m
tab f_case, m
gen f_nocare = .
replace f_nocare = 0 if q803 == 1 & f_case == 1
replace f_nocare = 1 if q803 == 0 & f_case == 1
lab var f_nocare "CG did not seek care for fever"
lab val f_nocare yn
tab f_nocare survey, m
*analysis 
svy: tab f_nocare survey, col ci pear obs

*CG sought care but not from CHW
tab q806g, m
gen f_nocarechw = .
replace f_nocarechw = 0 if q803 == 1 & f_case == 1
replace f_nocarechw = 1 if q806g != "G" & q803 == 1 & f_case == 1
lab var f_nocarechw "CG sought care but not from CHW"
lab val f_nocarechw yn
tab f_nocarechw survey, m
*analysis
svy: tab f_nocarechw survey, col ci pear obs

*reasons for not going to CHW for fever (endline only)
tab1 q808b*
egen tot_q808b = rownonmiss (q808ba-q808bx), strok
replace tot_q808b = . if survey == 1
replace tot_q808b = . if q803 != 1
replace tot_q808b = . if q806g == "G"
lab var tot_q808b "Total number of reasons CG did not seek care by CHW"
tab tot_q808b, m

encode q808ba, gen(q808b_a)
encode q808bb, gen(q808b_b)
encode q808bc, gen(q808b_c)
encode q808bd, gen(q808b_d)
encode q808be, gen(q808b_e)
encode q808bf, gen(q808b_f)
encode q808bx, gen(q808b_x)
encode q808bz, gen(q808b_z)

foreach x of varlist q808b_* {
  replace `x' = 0 if `x' == . & f_case == 1 & survey == 2 & q803 == 1 & q806g != "G"
  }

*CHW not available
tab q808b_a, m
lab var q808b_a "CHW not available"
lab val q808b_a yn
*anaylsis
svy: tab q808b_a survey, col ci pear obs
*CHW did not have medicines or supplies
tab q808b_b, m
lab var q808b_b "CHW did not have meds/supplies"
lab val q808b_b yn
*anaylsis
svy: tab q808b_b survey, col ci pear obs
*did not trust CHW to provide care
tab q808b_c, m
lab var q808b_c "did not trust CHW"
lab val q808b_c yn
*anaylsis
svy: tab q808b_c survey, col ci pear obs
*thought condition was too serious for CHW to treat
tab q808b_d, m
lab var q808b_d "condition too serious"
lab val q808b_d yn
*anaylsis
svy: tab q808b_d survey, col ci pear obs
*preferred to go to another provider
tab q808b_e, m
lab var q808b_e "preferred other provider"
lab val q808b_e yn
*anaylsis
svy: tab q808b_e survey, col ci pear obs
*CHW too far away
tab q808b_f, m
lab var q808b_f "CHW too far"
lab val q808b_f yn
*anaylsis
svy: tab q808b_f survey, col ci pear obs
*other
tab q808b_x, m
lab var q808b_x "CHW too far"
lab val q808b_x yn
*anaylsis
svy: tab q808b_x survey, col ci pear obs

*reason did not seek care for fever (ENDLINE ONLY)
tab1 q827*
*See how many reasons were given since multiple responses were allowed
egen tot_q827 = rownonmiss(q827a-q827x),strok
replace tot_q827 = . if q803 != 0
replace tot_q827 = . if survey == 1
lab var tot_q827 "Number of reasons caregiver did not seek care"
tab tot_q827

encode q827a, gen(q827_a)
encode q827b, gen(q827_b)
encode q827c, gen(q827_c)
encode q827d, gen(q827_d)
encode q827e, gen(q827_e)
encode q827f, gen(q827_f)
encode q827g, gen(q827_g)
encode q827x, gen(q827_x)
encode q827z, gen(q827_z)

foreach x of varlist q827_* {
   replace `x' = 0 if `x' == . & f_case == 1 & survey == 2 & q803 == 0
  lab val `x' yn
}

*did not think condition serious
tab q827_a, m
lab var q827_a "did not think condition serious"
lab val q827_a yn
*analysis
svy: tab q827_a survey, col ci pear obs
*condition passed
tab q827_b, m
lab var q827_b "condition passed"
lab val q827_b yn
*analysis
svy: tab q827_b survey, col ci pear obs
*place of care was too far
tab q827_c, m
lab var q827_c "place of care was too far"
lab val q827_c yn
*analysis-removed 'col' b/c single row
svy: tab q827_c survey, ci pear obs
*did not have time
tab q827_d, m
lab var q827_d "did not have time"
lab val q827_d yn
*analysis-removed 'col' b/c single row
svy: tab q827_d survey, ci pear obs
*did not have permission
tab q827_e, m
lab var q827_e "did not have permission"
lab val q827_e yn
*analysis
svy: tab q827_e survey, col ci pear obs
*did not have money
tab q827_f, m
lab var q827_f "did not have money"
lab val q827_f yn
*analysis-removed 'col' b/c single row
svy: tab q827_f survey, ci pear obs
*could treat condition at home
tab q827_g, m
lab var q827_g "treat at home"
lab val q827_g yn
*analysis
svy: tab q827_g survey, col ci pear obs
*other
tab q827_x, m
lab var q827_x "treat at home"
lab val q827_x yn
*analysis
svy: tab q827_x survey, col ci pear obs
*don't know
tab q827_z, m
lab var q827_z "don't know"
lab val q827_z yn
*analysis-removed 'col' b/c single line
svy: tab q827_z survey, ci pear obs

***Immunization Indicator
tab q828, m
gen f_booklet = .
replace f_booklet = 0 if q828 == 3
replace f_booklet = 1 if q828 == 1 
replace f_booklet = 2 if q828 == 2
replace f_booklet = d_booklet if f_booklet == . & q7child == q8child
lab var f_booklet "child has health booklet w/ vaccinations"
lab val f_booklet booklet
tab f_booklet survey, m
*analysis
svy: tab f_booklet survey, col ci pear obs


***********************MODULE 9: FAST BREATHING*********************************
***Table: FB management by sex
*recoding of fb_cases where whole module is missing information	
recode q903 9=. 
recode fb_case 1=. if q903==.

*soutght any treatment
tab q903, m
recode q903 2 = 0
lab var q903 "Sought treatment for fast breathing"
lab val q903 yn
tab q903 survey, m
*analysis
svy: tab q903 fb_sex if survey == 2, col ci pear obs

*Total number of providers visited
egen fb_provtot = rownonmiss (q906a-q906x), strok
replace fb_provtot = . if fb_case != 1
lab var fb_provtot "Total number of providers where sought care"
tab fb_provtot survey, m

*sought advice from an appropriate provider
egen fb_apptot = rownonmiss (q906a-q906e q906g q906k), strok
replace fb_apptot = . if fb_case != 1
lab var fb_apptot "Total number of appropriate providers where sought care"
recode fb_apptot 1 2 3 4 = 1, gen (fb_app_prov)
lab var fb_app_prov "Sought care from 1+ appropriate providers"
lab val fb_app_prov yn
tab fb_app_prov survey, m
*analysis
svy: tab fb_app_prov fb_sex if survey == 2, col ci pear obs

*Sought care from a CHW
tab q906g, m
gen fb_chw = .
replace fb_chw = 0 if fb_case == 1
replace fb_chw = 1 if q906g == "G"
lab var fb_chw "Caregiver sought care from a CHW"
lab val fb_chw yn
tab fb_chw survey, m
*analysis
svy: tab fb_chw fb_sex if survey == 2, col ci pear obs

*Sought care from a CHW first
tab q908, m
gen fb_chwfirst = .
replace fb_chwfirst = 0 if fb_case == 1
replace fb_chwfirst = 1 if q908 == "G"
replace fb_chwfirst = 1 if q906g == "G" & fb_provtot == 1
lab var fb_chwfirst "Sought care from CHW"
lab val fb_chwfirst yn
tab fb_chwfirst survey, m
*analysis 
svy: tab fb_chwfirst fb_sex if survey == 2, col ci pear obs

*Child was assess for rapid breathing (INDICATOR 12)
tab q909, m
gen fb_assessed = .
replace fb_assessed = 0 if fb_case == 1
replace fb_assessed = 1 if q909 == 1
lab var fb_assessed "Child assessed for rapid breathing"
lab val fb_assessed yn
tab fb_assessed survey, m
*analysis
svy: tab fb_assessed fb_sex if survey == 2, col ci pear obs
 
*Child was given any antibiotic for fast breathing
tab q912d, m
tab q912e, m
gen fb_abany = .
replace fb_abany = 0 if fb_case == 1
replace fb_abany = 1 if q912a == "D" | q912b == "E"
lab var fb_abany "child given any antibiotic for fast breathing"
lab val fb_abany yn
tab fb_abany survey, m
*Analysis
svy: tab fb_abany fb_sex if survey == 2, col ci pear obs

*Child given first line antibiotic for fast breathing (for Nigeria it is Amoxicillin)
tab q912d, m
gen fb_flab = .
replace fb_flab = 0 if fb_case == 1
replace fb_flab = 1 if q912a == "D"
lab var fb_flab "Child given first line antibiotics for fast breathing"
lab val fb_flab yn
tab fb_flab survey, m
*analysis 
svy: tab fb_flab fb_sex if survey == 2, col ci pear obs

***Table: Joint Care Seeking
*Decided to seek care jointly with partner
tab q905a, m
gen fb_joint = .
replace fb_joint = 0 if fb_case == 1 & maritalstat == 1
replace fb_joint = 1 if q905a == "A" & maritalstat == 1
lab var fb_joint "decided to seek care jointly with partner"
lab val fb_joint yn
tab fb_joint survey, m
*analysis
svy: tab fb_joint survey, col ci pear obs

***Table: Care Seeking
*Sought care from an appropriate provider
tab fb_app_prov survey, m
*analysis
svy: tab fb_app_prov survey, col ci pear obs
 
*Sought care from CHW first
tab fb_chwfirst survey, m
*analysis
svy: tab fb_chwfirst survey, col ci pear obs

*Sought care from CHW first among those who sought any care
tab q908, m
gen fb_chwfirst_anycare = .
replace fb_chwfirst_anycare = 0 if fb_case == 1 & q903 == 1
replace fb_chwfirst_anycare = 1 if q908 == "G"
replace fb_chwfirst_anycare = 1 if q906g == "G" & fb_provtot == 1
lab var fb_chwfirst_anycare "Sought care from CHW first among those who sought any care"
lab val fb_chwfirst_anycare yn
tab fb_chwfirst_anycare survey, m
*analysis
svy: tab fb_chwfirst_anycare survey, col ci pear obs

***Table: Care Seeking Sources
*Where CG sought care for fever
by survey: tab1 q906*

encode q906a, gen(q906_a)
encode q906b, gen(q906_b)
encode q906c, gen(q906_c)
encode q906d, gen(q906_d)
encode q906e, gen(q906_e)
encode q906f, gen(q906_f)
encode q906g, gen(q906_g)
encode q906h, gen(q906_h)
encode q906i, gen(q906_i)
encode q906j, gen(q906_j)
encode q906k, gen(q906_k)
encode q906l, gen(q906_l)
encode q906m, gen(q906_m)
encode q906x, gen(q906_x)

foreach x of varlist q906_* {
  replace `x' = 0 if `x' == . & fb_case == 1 & q903 == 1
  lab val `x' yn
}
*careseeking locations
gen fb_cs_hosp = 1 if q906_a == 1 
gen fb_cs_hcent = 1 if q906_b == 1 
gen fb_cs_hpost = 1 if q906_c == 1
gen fb_cs_ngo = 1 if q906_d == 1
gen fb_cs_clin = 1 if q906_e == 1
gen fb_cs_rmod = 1 if q906_f == 1
gen fb_cs_chw = 1 if q906_g == 1
gen fb_cs_cdd = 1 if q906_h == 1
gen fb_cs_trad = 1 if q906_i == 1
gen fb_cs_ppmv = 1 if q906_j == 1
gen fb_cs_phar = 1 if q906_k == 1
gen fb_cs_friend = 1 if q906_l == 1
gen fb_cs_mark = 1 if q906_m == 1
gen fb_cs_other = 1 if q906_x == 1

foreach x of varlist fb_cs_* {
  replace `x' = 0 if fb_case == 1 & q903 == 1 & `x' ==.
  lab val `x' yn
}
*hospital
tab fb_cs_hosp, m
lab var fb_cs_hosp "hospital"
lab val fb_cs_hosp yn
*analysis
svy: tab fb_cs_hosp survey, col ci pear obs
*health center
tab fb_cs_hcent, m
lab var fb_cs_hcent "health center"
lab val fb_cs_hcent yn
*analysis
svy: tab fb_cs_hcent survey, col ci pear obs
*health post
tab fb_cs_hpost, m
lab var fb_cs_hpost "health post"
lab val fb_cs_hpost yn
*analysis
svy: tab fb_cs_hpost survey, col ci pear obs
*health ngo
tab fb_cs_ngo, m
lab var fb_cs_ngo "NGO center"
lab val fb_cs_ngo yn
*analysis-removed 'col' b/c single row
svy: tab fb_cs_ngo survey, ci pear obs
*Clinic
tab fb_cs_clin, m
lab var fb_cs_clin "clinic"
lab val fb_cs_clin yn
*analysis
svy: tab fb_cs_clin survey, col ci pear obs
*CHW
tab fb_cs_chw, m
lab var fb_cs_chw "chw"
lab val fb_cs_chw yn
*analysis
svy: tab fb_cs_chw survey, col ci pear obs
*role model
tab fb_cs_rmod, m
lab var fb_cs_rmod "chw"
lab val fb_cs_rmod yn
*analysis-removed 'col' b/c single row
svy: tab fb_cs_rmod survey, ci pear obs
*Traditional practitioner
tab fb_cs_trad, m
lab var fb_cs_trad "traditional practitioner"
lab val fb_cs_trad yn
*analysis
svy: tab fb_cs_trad survey, col ci pear obs
*PPMV
tab fb_cs_ppmv, m
lab var fb_cs_ppmv "PPMV"
lab val fb_cs_ppmv yn
*analysis
svy: tab fb_cs_ppmv survey, col ci pear obs
*Pharmacy
tab fb_cs_phar, m
lab var fb_cs_phar "pharmacy"
lab val fb_cs_phar yn
*analysis
svy: tab fb_cs_phar survey, col ci pear obs
*Friend
tab fb_cs_friend, m
lab var fb_cs_friend "friend/relative"
lab val fb_cs_friend yn
*analysis
svy: tab fb_cs_friend survey, col ci pear obs
*Market
tab fb_cs_mark, m
lab var fb_cs_mark "market"
lab val fb_cs_mark yn
*analysis-removed 'col' b/c single row
svy: tab fb_cs_mark survey, ci pear obs
*Other
tab fb_cs_other, m
lab var fb_cs_other "other"
lab val fb_cs_other yn
*analysis
svy: tab fb_cs_other survey, col ci pear obs

*First source of care locations
gen fb_fcs_hosp = 1 if q908 == "A"
gen fb_fcs_hcent = 1 if q908 == "B" 
gen fb_fcs_hpost = 1 if q908 == "C" 
gen fb_fcs_ngo = 1 if q908 == "D" 
gen fb_fcs_clin = 1 if q908 == "E" 
gen fb_fcs_rmod = 1 if q908 == "F"
gen fb_fcs_chw = 1 if q908 == "G"
gen fb_fcs_cdd = 1 if q908 == "H"
gen fb_fcs_trad = 1 if q908 == "I"
gen fb_fcs_ppmv = 1 if q908 == "J" 
gen fb_fcs_phar = 1 if q908 == "K"
gen fb_fcs_friend = 1 if q908 == "L"
gen fb_fcs_mark = 1 if q908 == "M"
gen fb_fcs_other = 1 if q908 == "X"

replace fb_fcs_hosp = 1 if q906_a == 1 & fb_provtot == 1
replace fb_fcs_hcent = 1 if q906_b == 1 & fb_provtot == 1
replace fb_fcs_hpost = 1 if q906_c == 1 & fb_provtot == 1
replace fb_fcs_ngo = 1 if q906_d == 1 & fb_provtot == 1
replace fb_fcs_clin = 1 if q906_e == 1 & fb_provtot == 1
replace fb_fcs_rmod = 1 if q906_f == 1 & fb_provtot == 1
replace fb_fcs_chw = 1 if q906_g == 1 & fb_provtot == 1
replace fb_fcs_cdd = 1 if q906_h == 1 & fb_provtot == 1
replace fb_fcs_trad = 1 if q906_i == 1 & fb_provtot == 1
replace fb_fcs_ppmv = 1 if q906_j == 1 & fb_provtot == 1
replace fb_fcs_phar = 1 if q906_k == 1 & fb_provtot == 1
replace fb_fcs_friend = 1 if q906_l == 1 & fb_provtot == 1
replace fb_fcs_mark = 1 if q906_m == 1 & fb_provtot == 1
replace fb_fcs_other = 1 if q906_x == 1 & fb_provtot == 1

foreach x of varlist fb_fcs_* {
  replace `x' = 0 if fb_case == 1 & q903 == 1 & `x' ==.
  lab val `x' yn
}

*hospital
tab fb_fcs_hosp, m
lab var fb_fcs_hosp "hospital"
lab val fb_fcs_hosp yn
*analysis
svy: tab fb_fcs_hosp survey, col ci pear obs
*health center
tab fb_fcs_hcent, m
lab var fb_fcs_hcent "health center"
lab val fb_fcs_hcent yn
*analysis
svy: tab fb_fcs_hcent survey, col ci pear obs
*health post
tab fb_fcs_hpost, m
lab var fb_fcs_hpost "health post"
lab val fb_fcs_hpost yn
*analysis
svy: tab fb_fcs_hpost survey, col ci pear obs
*health ngo
tab fb_fcs_ngo, m
lab var fb_fcs_ngo "NGO center"
lab val fb_fcs_ngo yn
*analysis-removed 'col' b/c single line
svy: tab fb_fcs_ngo survey, ci pear obs
*Clinic
tab fb_fcs_clin, m
lab var fb_fcs_clin "clinic"
lab val fb_fcs_clin yn
*analysis
svy: tab fb_fcs_clin survey, col ci pear obs
*CHW
tab fb_fcs_chw, m
lab var fb_fcs_chw "chw"
lab val fb_fcs_chw yn
*analysis
svy: tab fb_fcs_chw survey, col ci pear obs
*Role Model
tab fb_fcs_rmod, m
lab var fb_fcs_rmod "role model"
lab val fb_fcs_rmod yn
*analysis-removed 'col' b/c single row
svy: tab fb_fcs_rmod survey, ci pear obs
*Traditional practitioner
tab fb_fcs_trad, m
lab var fb_fcs_trad "traditional practitioner"
lab val fb_fcs_trad yn
*analysis
svy: tab fb_fcs_trad survey, col ci pear obs
*PPMV
tab fb_fcs_ppmv, m
lab var fb_fcs_ppmv "PPMV"
lab val fb_fcs_ppmv yn
*analysis
svy: tab fb_fcs_ppmv survey, col ci pear obs
*Pharmacy
tab fb_fcs_phar, m
lab var fb_fcs_phar "pharmacy"
lab val fb_fcs_phar yn
*analysis
svy: tab fb_fcs_phar survey, col ci pear obs
*Friend
tab fb_fcs_friend, m
lab var fb_fcs_friend "friend/relative"
lab val fb_fcs_friend yn
*analysis
svy: tab fb_fcs_friend survey, col ci pear obs
*Market
tab fb_fcs_mark, m
lab var fb_fcs_mark "market"
lab val fb_fcs_mark yn
*analysis-removed 'col' b/c single row
svy: tab fb_fcs_mark survey, ci pear obs
*Other
tab fb_fcs_other, m
lab var fb_fcs_other "other"
lab val fb_fcs_other yn
*analysis
svy: tab fb_fcs_other survey, col ci pear obs


*Location of assessment
tab1 q909aa-q909az

gen q909a_a = 1 if q909aa=="A"
gen q909a_b = 1 if q909ab=="B"
gen q909a_c = 1 if q909ac=="C"
gen q909a_d = 1 if q909ad=="D"
gen q909a_e = 1 if q909ae=="E"
gen q909a_x = 1 if q909ax=="X"
gen q909a_z = 1 if q909az=="Z"

foreach x of varlist q909a_* {
  replace `x' = 0 if `x' ==. & q909 == 1
  lab val `x' yn
}
*hospital
tab q909a_a, m
lab var q909a_a "assessed at hospital"
lab val q909a_a yn
*analysis
svy: tab q909a_a survey, col ci pear obs
*health center
tab q909a_b, m
lab var q909a_b "assessed at health center"
lab val q909a_b yn
*analysis
svy: tab q909a_b survey, col ci pear obs
*health post
tab q909a_c, m
lab var q909a_c "assessed at health post"
lab val q909a_c yn
*analysis
svy: tab q909a_c survey, col ci pear obs
*Private Clinic
tab q909a_d, m
lab var q909a_d "assessed at private clinic"
lab val q909a_d yn
*analysis
svy: tab q909a_d survey, col ci pear obs
*Community
tab q909a_e, m
lab var q909a_e "assessed at community"
lab val q909a_e yn
*analysis
svy: tab q909a_e survey, col ci pear obs
*Other
tab q909a_x, m
lab var q909a_x "assessed at other location"
lab val q909a_x yn
*analysis
svy: tab q909a_x survey, col ci pear obs
*Don't know
tab q909a_z, m
lab var q909a_z "Don't know location of assessment"
lab val q909a_z yn
*analysis
svy: tab q909a_z survey, col ci pear obs

*Who provided assessment
*Health worker who performed the blood test
tab1 q910a-q910z
gen q910_a = 1 if q910a == "A"
gen q910_b = 1 if q910b == "B"
*gen q910_c = 1 if q910c == "C"
*missing q910c from data
gen q910_d = 1 if q910d == "C"
gen q910_e = 1 if q910e == "D"
gen q910_x = 1 if q910x == "E"
gen q910_z = 1 if q910z == "X"

foreach x of varlist q910_* {
  replace `x' = 0 if `x' ==. & q909 == 1
  lab val `x' yn
}
*CHW
tab q910_a, m
lab var q910_a "CHW did assessment"
lab val q910_a yn
*analysis
svy: tab q910_a survey, col ci pear obs
*Medical assistant
tab q910_b, m
lab var q910_b "Medical assistant did assessment"
lab val q910_b yn
*analysis
svy: tab q910_b survey, col ci pear obs
*Clinical officer-missing q910c from data
*Nurse
tab q910_d, m
lab var q910_d "Nurse did assessment"
lab val q910_d yn
*analysis-removed 'col' b/c single row
svy: tab q910_d survey, ci pear obs
*Doctor
tab q910_e, m
lab var q910_e "Doctor did assessment"
lab val q910_e yn
*analysis-removed 'col' b/c single row
svy: tab q910_e survey, ci pear obs
*Other
tab q910_x, m
lab var q910_x "Other provider did assessment"
lab val q910_x yn
*analysis-removed 'col' b/c single row
svy: tab q910_x survey, ci pear obs

egen fb_assessed_tot = anycount(q910_a-q910_x), values(1)
replace fb_assessed_tot = . if fb_assessed == 0 | fb_case !=1
tab fb_assessed_tot survey

***Table: Assessment
*Child assessed for fast breathing by CHW
tab q910a, m
gen fb_assessedchw = .
replace fb_assessedchw = 0 if fb_chw == 1
replace fb_assessedchw = 1 if fb_assessed == 1 & q910a == "A" & fb_chw == 1
lab var fb_assessedchw "Child assessed for fast breathing by CHW"
lab val fb_assessedchw yn
tab fb_assessedchw survey, m
*analysis
svy: tab fb_assessedchw survey, col ci pear obs

*Child assessed for fast breathing by provider other than CHW, among those who sought care from other providers
gen fb_assessedoth = .
replace fb_assessedoth = 0 if (fb_provtot == 1 & fb_chw != 1) | (fb_provtot >= 2 & fb_provtot !=.)
replace fb_assessedoth = 1 if (fb_assessed == 1 & ((fb_assessed_tot == 1 & fb_assessedchw != 1) | fb_assessed_tot == 2)) & ((fb_provtot == 1 & fb_chw != 1) | (fb_provtot >= 2 & fb_provtot !=.))
replace f_bloodtakenoth = . if fb_assessed_tot == 0
lab var fb_assessedoth "Child assessed for fast breathing by provider other than CHW"
lab val fb_assessedoth yn
tab fb_assessedoth survey, m
*analysis
svy: tab fb_assessedoth survey, col ci pear obs

*Child assessed for fast breathing, all cases (INDICATOR 12)
tab fb_assessed survey, m
*analysis
svy: tab fb_assessed survey, col ci pear obs

***Table: Appropriate Treatment
*Recieved appropriate treatment from CHW, among all FB cases
tab q912d, m
tab q914, m
gen fb_flabchw = .
replace fb_flabchw = 0 if fb_case == 1
replace fb_flabchw = 1 if q912a == "D" & q914 == 17
lab var fb_flabchw "recieved treatment from CHW, among all FB cases"
lab val fb_flabchw yn
tab fb_flabchw survey, m
*analysis
svy: tab fb_flabchw survey, col ci pear obs

*Recieved appropriate treatment from provider other than CHW (new WHO Indicator)
gen fb_flabother = .
replace fb_flabother = 0 if fb_case == 1
replace fb_flabother = 1 if fb_flab == 1 & fb_flabchw == 0
lab var fb_flabother "recived first line antibiotics from provider other than CHW for fast breathing"
lab val fb_flabother yn
tab fb_flabother survey, m
*analysis
svy: tab fb_flabother survey, col ci pear obs

*Recieved appropriate treatment from provider other than CHW
gen fb_flaboth2 = .
replace fb_flaboth2 = 0 if (fb_provtot >= 2 | (fb_provtot == 1 & fb_chw != 1)) & fb_case == 1
replace fb_flaboth2 = 1 if fb_flabother == 1 & (fb_provtot >= 2 | (fb_provtot == 1 & fb_chw != 1)) & fb_case == 1
lab var fb_flaboth2 "recived first line antibiotics from provider other than CHW for fast breathing"
lab val fb_flaboth2 yn
tab fb_flaboth2 survey, m
*analysis
svy: tab fb_flabother survey, col ci pear obs

*Recived appropriate treatment for FB, all cases (INDICATOR 13)
tab fb_flab survey, m
*analysis
svy: tab fb_flab survey, col ci pear obs

*Recived appropriate treatment for FB from CHW among those who sought care from CHW
gen fb_flabchw2 = .
replace fb_flabchw2 = 0 if fb_chw == 1 
replace fb_flabchw2 = 1 if fb_flabchw ==1
lab var fb_flabchw2 "Recieved app. tx. from CHW for FB amongh those who sought care from CHW"
lab val fb_flabchw2 yn
tab fb_flabchw2 survey, m
*analysis
svy: tab fb_flabchw2 survey, col ci pear obs

*Treatment taken for cough/fast breathing
sort survey
by survey: tab1 q912*
*Amoxicillin
tab q912a, m
gen q912_d = . 
replace q912_d = 0 if q911 == 1
replace q912_d = 1 if q912a == "D"
lab var q912_d "Amoxicillin"
lab val q912_d yn
tab q912_d survey, m
*analysis
svy: tab q912_d survey, col ci pear obs
*antibiotic injection
tab q912b, m
gen q912_e = . 
replace q912_e = 0 if q911 == 1
replace q912_e = 1 if q912b == "E"
lab var q912_e "Antibiotic injection"
lab val q912_e yn
tab q912_e survey, m
*analysis
svy: tab q912_e survey, col ci pear obs
*Aspirin
tab q912c, m
gen q912_f = . 
replace q912_f = 0 if q911 == 1
replace q912_f = 1 if q912c == "F"
lab var q912_f "Aspirin"
lab val q912_f yn
tab q912_f survey, m
*analysis
svy: tab q912_f survey, col ci pear obs
*Paracetamol
tab q912d, m
gen q912_g = . 
replace q912_g = 0 if q911 == 1
replace q912_g = 1 if q912d == "G"
lab var q912_g "Paracetamol"
lab val q912_g yn
tab q912_g survey, m
*analysis-removed 'col' b/c single row
svy: tab q912_g survey, ci pear obs
*Other 
tab q912e, m
gen q912_x = . 
replace q912_x = 0 if q911 == 1
replace q912_x = 1 if q912e == "X"
lab var q912_x "Other"
lab val q912_x yn
tab q912_x survey, m
*analysis-removed 'col' b/c single row
svy: tab q912_x survey, ci pear obs
*Don't know 
tab q912f, m
gen q912_z = . 
replace q912_z = 0 if q911 == 1
replace q912_z= 1 if q912f == "Z"
lab var q912_z "Don't Know"
lab val q912_z yn
tab q912_z survey, m
*analysis-removed 'col' b/c single row
svy: tab q912_z survey, ci pear obs

***Table: Source of Treatment
*Source of Amoxicillin
tab q914 survey, col

gen fb_flab_hosp = 1 if q914 == 11 
gen fb_flab_hcent = 1 if q914 == 12
gen fb_flab_hpost = 1 if q914 == 13
gen fb_flab_ngo = 1 if q914 == 14
gen fb_flab_clin = 1 if q914 == 15
gen fb_flab_rmod = 1 if q914 == 16
gen fb_flab_chw = 1 if q914 == 17
gen fb_flab_trad = 1 if q914 == 21 
gen fb_flab_ppmv = 1 if q914 == 22
gen fb_flab_phar = 1 if q914 == 23 
gen fb_flab_friend = 1 if q914 == 26
gen fb_flab_mark = 1 if q914 == 27
gen fb_flab_other = 1 if q914 == 31 

foreach x of varlist fb_flab_* {
  replace `x' = 0 if fb_case == 1 & fb_flab == 1 & `x' ==. & q914 !=.
  lab val `x' yn
}

*hospital
tab fb_flab_hosp, m
lab var fb_flab_hosp "Source of Amox: Hospital"
lab val fb_flab_hosp yn
*analysis
svy: tab fb_flab_hosp survey, col ci pear obs
*health center
tab fb_flab_hcent, m
lab var fb_flab_hcent "Source of Amox: Health center"
lab val fb_flab_hcent yn
*analysis
svy: tab fb_flab_hcent survey, col ci pear obs
*health post
tab fb_flab_hpost, m
lab var fb_flab_hpost "Source of Amox: Health post"
lab val fb_flab_hpost yn
*analysis
svy: tab fb_flab_hpost survey, col ci pear obs
*NGO
tab fb_flab_ngo, m
lab var fb_flab_ngo "Source of Amox: NGO"
lab val fb_flab_ngo yn
*analysis-removed 'col' b/c single row
svy: tab fb_flab_ngo survey, ci pear obs
*clinic
tab fb_flab_clin, m
lab var fb_flab_clin "Source of Amox: Clinic"
lab val fb_flab_clin yn
*analysis
svy: tab fb_flab_clin survey, col ci pear obs
*role model
tab fb_flab_rmod, m
lab var fb_flab_rmod "Source of Amox: Role Model"
lab val fb_flab_rmod yn
*analysis-removed 'col' b/c single row
svy: tab fb_flab_rmod survey, ci pear obs
*chw
tab fb_flab_chw, m
lab var fb_flab_chw "Source of Amox: CHW"
lab val fb_flab_chw yn
*analysis
svy: tab fb_flab_chw survey, col ci pear obs
*Traditional practitioner
tab fb_flab_trad, m
lab var fb_flab_trad "Source of Amox: Traditional Practitioner"
lab val fb_flab_trad yn
*analysis-removed 'col' b/c single row
svy: tab fb_flab_trad survey, ci pear obs
*PPMV
tab fb_flab_ppmv, m
lab var fb_flab_ppmv "Source of Amox: PPMV"
lab val fb_flab_ppmv yn
*analysis
svy: tab fb_flab_ppmv survey, col ci pear obs
*Pharmacy
tab fb_flab_phar, m
lab var fb_flab_phar "Source of Amox: Pharmacy"
lab val fb_flab_phar yn
*analysis
svy: tab fb_flab_phar survey, col ci pear obs
*Friend/relative
tab fb_flab_friend, m
lab var fb_flab_friend "Source of Amox: Friend/Relative"
lab val fb_flab_friend yn
*analysis-removed 'col' b/c single row
svy: tab fb_flab_friend survey, ci pear obs
*Market
tab fb_flab_mark, m
lab var fb_flab_mark "Source of Amox: Market"
lab val fb_flab_mark yn
*analysis-remove 'col' b/c single row
svy: tab fb_flab_mark survey, ci pear obs
*Other
tab fb_flab_other, m
lab var fb_flab_other "Source of Amox: Other"
lab val fb_flab_other yn
*analysis
svy: tab fb_flab_other survey, col ci pear obs

***Table: First Dose Recieved in Presence of CHW
*Recieved medicine for fast breathing in presence of CHW if visted a CHW
tab q916, m
gen fb_flab_chwp = . 
replace fb_flab_chwp = 0 if fb_flabchw == 1
replace fb_flab_chwp = 1 if q916 == 1 & fb_flabchw == 1
lab var fb_flab_chwp "Recieved frist dose in presence of CHW"
lab val fb_flab_chwp yn
tab fb_flab_chwp survey, m
*analysis
svy: tab fb_flab_chwp survey, col ci pear obs

***Table: Recieved counseling from CHW
*Recieved counseling from CHW for fast breathing if visited a CHW (INDICATOR 16)
tab q917, m
gen fb_flab_chwc = .
replace fb_flab_chwc = 0 if fb_flabchw == 1
replace fb_flab_chwc = 1 if q917 == 1 & fb_flabchw == 1
lab var fb_flab_chwc "recieved first dose in presence of CHW"
lab val fb_flab_chwc yn
tab fb_flab_chwc survey, m
*analysis 
svy: tab fb_flab_chwc survey, col ci pear obs

***Table: Referral Adherence
*CHW referred client to health facility
tab q920, m
gen fb_chwrefer = .
replace fb_chwrefer = 0 if fb_chw == 1
replace fb_chwrefer = 1 if q920 == 1
lab var fb_chwrefer "CHW gave referral"
lab val fb_chwrefer yn
tab fb_chwrefer survey, m
*analysis
svy: tab fb_chwrefer survey, col ci pear obs

*Caregiver adhered to referral from CHW
tab q921, m
gen fb_referadhere = .
replace fb_referadhere = 0 if fb_chwrefer == 1
replace fb_referadhere = 1 if q921 == 1
lab var fb_referadhere "Caregiver adhered to referral from CHW"
lab val fb_referadhere yn
tab fb_referadhere survey, m
*analysis
svy: tab fb_referadhere survey, col ci pear obs

*Reasons did not comply with referral
tab1 q922*

encode q922a, gen(q922_a)
encode q922b, gen(q922_b)
encode q922c, gen(q922_c)
encode q922d, gen(q922_d)
encode q922e, gen(q922_e)
encode q922f, gen(q922_f)
encode q922g, gen(q922_g)
encode q922h, gen(q922_h)
encode q922x, gen(q922_x)
encode q922z, gen(q922_z)

foreach x of varlist q922_* {
  replace `x' = 0 if `x' == . & q921 == 2
  lab val `x' yn
}

*too far
tab q922_a, m
lab var q922_a "too far"
lab val q922_a yn
tab q922_a survey, m
*analysis
svy: tab q922_a survey, col ci pear obs
*did not have money
tab q922_b, m
lab var q922_b "did not have money"
lab val q922_b yn
tab q922_b survey, m
*analysis-removed col b/c single row
svy: tab q825_b survey, ci pear obs
*no transport
tab q922_c, m
lab var q922_c "no transport"
lab val q922_c yn
tab q922_c survey, m
*analysis-removed col b/c single row
svy: tab q922_c survey, ci pear obs
*did not think illness serious
tab q922_d, m
lab var q922_d "did not think illness serious"
lab val q922_d yn
tab q922_d survey, m
*analysis-removed col b/c single row
svy: tab q922_d survey, col ci pear obs
*child improved
tab q922_e, m
lab var q922_e "child improved"
lab val q922_e yn
tab q922_e survey, m
*analysis
svy: tab q922_e survey, col ci pear obs
*no time
tab q922_f, m
lab var q922_f "no time"
lab val q922_f yn
tab q922_f survey, m
*analysis-removed col b/c single row
svy: tab q922_f survey, ci pear obs
*went somewhere else
tab q922_g, m
lab var q922_g "went somewhere else"
lab val q922_g yn
tab q922_g survey, m
*analysis
svy: tab q922_g survey, col ci pear obs
*did not have husband's permission
tab q922_h, m
lab var q922_h "no permission"
lab val q922_h yn
tab q922_h survey, m
*analysis
svy: tab q922_h survey, col ci pear obs
*other
tab q922_x, m
lab var q922_x "other"
lab val q922_x yn
tab q922_x survey, m
*analysis-removed col b/c single row
svy: tab q922_x survey, ci pear obs
*don't know
tab q922_z, m
lab var q922_z "don't know"
lab val q922_z yn
tab q922_z survey, m
*analysis
svy: tab q922_z survey, col ci pear obs

***Table: CHW Follow up
*CHW did follow up 
tab q923, m
gen fb_chw_fu = .
replace fb_chw_fu = 0 if fb_chw == 1
replace fb_chw_fu = 1 if q923 == 1
lab var fb_chw_fu "CHW did follow up"
lab val fb_chw_fu yn
tab fb_chw_fu survey, m
*analysis
svy: tab fb_chw_fu survey, col ci pear obs

***Table: No Care Seeking Reasons
*CG did not seek care for fever
tab q903, m
tab fb_case, m
gen fb_nocare = .
replace fb_nocare = 0 if q903 == 1 & fb_case == 1
replace fb_nocare = 1 if q903 == 0 & fb_case == 1
lab var fb_nocare "CG did not seek care for fast breathing"
lab val fb_nocare yn
tab fb_nocare survey, m
*analysis 
svy: tab fb_nocare survey, col ci pear obs

*CG sought care but not from CHW
tab q906g, m
gen fb_nocarechw = .
replace fb_nocarechw = 0 if q903 == 1 & fb_case == 1
replace fb_nocarechw = 1 if q906g != "G" & q903 == 1 & fb_case == 1
lab var fb_nocarechw "CG sought care but not from CHW"
lab val fb_nocarechw yn
tab fb_nocarechw survey, m
*analysis
svy: tab fb_nocarechw survey, col ci pear obs

*reasons for not going to CHW for fast breathing (endline only)
tab1 q908b*
egen tot_q908b = rownonmiss (q908ba-q908bx), strok
replace tot_q908b = . if survey == 1
replace tot_q908b = . if q903 != 1
replace tot_q908b = . if q906g == "G"
lab var tot_q908b "Total number of reasons CG did not seek care by CHW"
tab tot_q908b, m

encode q908ba, gen(q908b_a)
encode q908bb, gen(q908b_b)
encode q908bc, gen(q908b_c)
encode q908bd, gen(q908b_d)
encode q908be, gen(q908b_e)
encode q908bf, gen(q908b_f)
encode q908bx, gen(q908b_x)
encode q908bz, gen(q908b_z)

foreach x of varlist q908b_* {
  replace `x' = 0 if `x' == . & fb_case == 1 & survey == 2 & q903 == 1 & q906g != "G"
  }

*CHW not available
tab q908b_a, m
lab var q908b_a "CHW not available"
lab val q908b_a yn
*anaylsis
svy: tab q908b_a survey, col ci pear obs
*CHW did not have medicines or supplies
tab q908b_b, m
lab var q908b_b "CHW did not have meds/supplies"
lab val q908b_b yn
*anaylsis
svy: tab q908b_b survey, col ci pear obs
*did not trust CHW to provide care
tab q908b_c, m
lab var q908b_c "did not trust CHW"
lab val q908b_c yn
*anaylsis
svy: tab q908b_c survey, col ci pear obs
*thought condition was too serious for CHW to treat
tab q908b_d, m
lab var q908b_d "condition too serious"
lab val q908b_d yn
*anaylsis
svy: tab q908b_d survey, col ci pear obs
*preferred to go to another provider
tab q908b_e, m
lab var q908b_e "preferred other provider"
lab val q908b_e yn
*anaylsis
svy: tab q908b_e survey, col ci pear obs
*CHW too far away
tab q908b_f, m
lab var q908b_f "CHW too far"
lab val q908b_f yn
*anaylsis-removed 'col' b/c single row
svy: tab q908b_f survey, ci pear obs
*other
tab q908b_x, m
lab var q908b_x "CHW too far"
lab val q908b_x yn
*anaylsis
svy: tab q908b_x survey, col ci pear obs

*reason did not seek care for fast breathing (ENDLINE ONLY)
tab1 q924*
*See how many reasons were given since multiple responses were allowed
egen tot_q924 = rownonmiss(q924a-q924x),strok
replace tot_q924 = . if q903 != 0
replace tot_q924 = . if survey == 1
lab var tot_q924 "Number of reasons caregiver did not seek care"
tab tot_q924

encode q924a, gen(q924_a)
encode q924b, gen(q924_b)
encode q924c, gen(q924_c)
encode q924d, gen(q924_d)
encode q924e, gen(q924_e)
encode q924f, gen(q924_f)
encode q924g, gen(q924_g)
encode q924x, gen(q924_x)
encode q924z, gen(q924_z)

foreach x of varlist q924_* {
  replace `x' = 0 if `x' == . & fb_case == 1 & survey == 2 & q903 == 0
  lab val `x' yn
}


*did not think condition serious
tab q924_a, m
lab var q924_a "did not think condition serious"
lab val q924_a yn
*analysis
svy: tab q924_a survey, col ci pear obs
*condition passed
tab q924_b, m
lab var q924_b "condition passed"
lab val q924_b yn
*analysis
svy: tab q924_b survey, col ci pear obs
*place of care was too far
tab q924_c, m
lab var q924_c "place of care was too far"
lab val q924_c yn
*analysis
svy: tab q924_c survey, col ci pear obs
*did not have time
tab q924_d, m
lab var q924_d "did not have time"
lab val q924_d yn
*analysis
svy: tab q924_d survey, col ci pear obs
*did not have permission
tab q924_e, m
lab var q924_e "did not have permission"
lab val q924_e yn
*analysis
svy: tab q924_e survey, col ci pear obs
*did not have money
tab q924_f, m
lab var q924_f "did not have money"
lab val q924_f yn
*analysis
svy: tab q924_f survey, col ci pear obs
*could treat condition at home
tab q924_g, m
lab var q924_g "treat at home"
lab val q924_g yn
*analysis
svy: tab q924_g survey, col ci pear obs
*other
tab q924_x, m
lab var q924_x "treat at home"
lab val q924_x yn
*analysis
svy: tab q924_x survey, col ci pear obs
*don't know
tab q924_z, m
lab var q924_z "don't know"
lab val q924_z yn
*analysis
svy: tab q924_z survey, col ci pear obs

***Immunization Indicator
tab q925, m
gen fb_booklet = .
replace fb_booklet = 0 if q925 == 3
replace fb_booklet = 1 if q925 == 1 
replace fb_booklet = 2 if q925 == 2
replace fb_booklet = d_booklet if q7child == q9child & fb_booklet == .
replace fb_booklet = f_booklet if q8child == q9child & fb_booklet == .
lab var fb_booklet "child has health booklet w/ vaccinations"
lab def fb_booklet 0 "no card" 1 "yes, seen card" 2 "yes, have not seen card"
lab val fb_booklet booklet
tab fb_booklet survey, m
*analysis
svy: tab fb_booklet survey, col ci pear obs


save "Niger State_final_BL_EL.dta", replace
