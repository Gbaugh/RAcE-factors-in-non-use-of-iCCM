*************************************
* MALAWI ENDLINE HH SURVEY ANALYSIS *
* By: Kirsten Zalisk                *
* October 2016                      *
*************************************
*log using "background.smcl", replace

cd "C:\Users\26167\Documents\WHO RAcE\Malawi\Endline Survey\Survey Data\Sick Child\Race Childillness Data"
set more off

use "cg_combined_hh_roster_FINALFEB2.dta", clear

*Create a value label for binary variables that are recoded 0/1
lab define yn 0 "No" 1 "Yes"

*Define survey parameters that account for the cluster variable
svyset hhclust

****************MODULE 1: Sick child information********************************
*Sex, age and 2-week history of illness of selected children
***In a different do file

*Create binary variable = child has illness from line number variable
recode q7child 1 2 3 4=1 0=0, gen(d_case)
recode q8child 1 2 3 4=1 0=0, gen(f_case)
recode q9child 1 2 3 4=1 0=0, gen(fb_case)

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


****************MODULE 2: Caregivers' information*******************************
*Calculate total number of cargeivers (records) included in each survey
sort survey
by survey: count 

*Caregivers' age
*Be sure to check for outliers and missing values
sort survey
by survey:sum q202
*hist q202 if survey == 1
*hist q202 if survey == 2
recode q202 min/24=1 25/34=2 35/44=3 45/max=4,gen(cagecat)
lab var cagecat "Caregiver's age category"
lab define cagecat 1 "15-24" 2 "25-34" 3 "35-44" 4 "45+"
lab values cagecat cagecat
tab cagecat survey, col
svy: mean q202, over(survey)

*Caregivers' education
*Only one response in Higher so recoding into different categories
tab q203 survey
tab q204 survey
tab q205 survey
gen cgeduccat = 0 if q203 == 2
replace cgeduccat = 1 if q204 == 1 & q205 < 5
replace cgeduccat = 2 if q204 == 1 & q205 >= 5 & q205 !=.
replace cgeduccat = 3 if q204 == 2 | q204 == 3
lab var cgeduccat "Caregiver's highest level of education"
lab define educ 0 "No school" 1 "Primary < class 5" 2 "Primary >= class 5" 3 "Secondary or higher"
lab val cgeduccat educ
lab var cgeduccat "Caregiver's education (categorical)"

*Caregivers' marital status (3 categories)
tab q401 survey

*Recode marital status to be binary
recode q401 1 2 = 1 3 = 0, gen(union)
lab val union yn
lab var union "Cargeiver is married or living with partner"
tab union survey, col 

****************MODULE 5: Health center access**********************************
*caregiver access to nearest facility*
by survey:sum q501
*hist q501
recode q501 min/4=1 5/9=2 10/14=3 15/19=4 20/50=5 98=.,gen(distcat)
lab var distcat "Distance to nearest health center"
lab define distance 1 "<5 km" 2 "5-9 km" 3 "10-14 km" 4 "15-19 km" 5 "20+ km", modify
lab values distcat distance
tab distcat survey
svy: mean q501 if q501 !=98, over(survey)
svy: regress q501 survey

*caregiver's mode of transport
tab q502 survey
recode q502 2=1 3 4 5=2 6=3 1=.,gen(transport)
lab def trans 1 "Walk" 2 "Motorbike/Bus/Taxi" 3 "Other"
lab val transport trans
tab transport survey, col

*caregiver's time to travel to nearest facility*
by survey: sum q503
*hist q503
recode q503 min/29=1 30/59=2 60/119=3 120/179=4 180/400=5 998=.,gen(timecat)
lab var timecat "Time to reach nearest health center"
lab def timecat 1 "<30 minutes" 2 "30-59 minutes" 3 "1 - <2 hours" 4 "2 - <3 hours" 5 "3+ hours", modify
lab val timecat timecat
tab timecat survey, col

svy: mean q503 if q503 <998, over(survey)

****************MODULE 4: Household decision making*****************************
*Caregiver living with partner
tab q402 survey 
recode q402 2=0
lab values q402 yn
tab q402 survey, col 

*Income decision maker (INDICATOR 19, OPTIONAL)
tab q403 survey
recode q403 6 = 4,gen(dm_income)
lab var dm_income "Household income decision maker"
tab dm_income survey, col

recode dm_income 1 2 4=0 3=1, gen(dm_income_joint)
lab var dm_income_joint "Caregiver makes HH income decisions jointly with partner"
lab val dm_income_joint yn
tab dm_income_joint survey, col

*Health care decision maker (INDICATOR 20, OPTIONAL)
tab q404 survey, col 
*recoded other to be missing because of the small #s in both surveys
*really need at least 5 obs in all cells to run a chi2 test
recode q404 4 6 = ., gen(dm_health)
lab var dm_health "Hsehold health care decision maker"
tab dm_health survey, col

recode dm_health 1 2 4=0 3=1, gen(dm_health_joint)
lab var dm_health_joint "Caregiver makes healthcare decisions jointly with partner"
lab val dm_health_joint yn
tab dm_health_joint survey, col

*log close

*log using "caregiver_results", replace
****************MODULE 6: Caregiver illness knowledge***************************
*Child illness signs (Q601a-Q601p, Q601z = don't know)
by survey: tab1 q601*

*Create a variable = total number of illness signs caregiver knows
egen tot_q601 = rownonmiss(q601a-q601p), strok
lab var tot_q601 "Total number of illness signs CG knows"

encode q601a, gen(q601_a)
encode q601b, gen(q601_b)
encode q601c, gen(q601_c)
encode q601d, gen(q601_d)
encode q601e, gen(q601_e)
encode q601f, gen(q601_f)
encode q601g, gen(q601_g)
encode q601h, gen(q601_h)
encode q601i, gen(q601_i)
encode q601j, gen(q601_j)
encode q601k, gen(q601_k)
encode q601l, gen(q601_l)
encode q601m, gen(q601_m)
encode q601n, gen(q601_n)
encode q601o, gen(q601_o)
encode q601p, gen(q601_p)
encode q601z, gen(q601_z)

foreach x of varlist q601_* {
  replace `x' = 0 if `x' == .
  lab val `x' yn
  }

*Create a variable = caregiver knows 2+ illness signs (INDICATOR 3)
gen cgdsknow2 = tot_q601 >= 2 & tot_q601 !=. 
lab var cgdsknow2 "Caregiver knows 2+ child illness signs"
lab val cgdsknow2 yn
tab cgdsknow2 survey, col 

*Create a variable = caregiver knows 3+ illness signs (INDICATOR 3A)
gen cgdsknow3 = tot_q601 >= 3 & tot_q601 !=. 
lab var cgdsknow3 "Caregiver knows 3+ child illness signs"
lab val cgdsknow3 yn
tab cgdsknow3 survey, col 

*Knowledge of malaria (not an indicator)
tab q602 survey

*Knowledge of malaria aquisition (INDICATOR 30, OPTIONAL)
by survey: tab1 q603*
gen malaria_get = .
replace malaria_get = 0 if q602 !=.
replace malaria_get = 1 if q603a == "A"
lab var malaria_get "Caregiver knows how malaria is acquired"
lab val malaria_get yn
tab malaria_get survey, col

*Knowledge that fever is a malaria symptom
by survey: tab1 q604*
gen malaria_fev_sign = .
replace malaria_fev_sign = 0 if q602 !=.
replace malaria_fev_sign = 1 if q604a == "A"
lab var malaria_fev_sign "Caregiver knows that fever is a sign of malaria"
lab val malaria_fev_sign yn
tab malaria_fev_sign survey, col

*Knowledge of at least 2 symptoms of malaria (INDICATOR 31, OPTIONAL)
egen tot_q604 = rownonmiss(q604a-q604i), strok
lab var tot_q604 "Total number of malaria signs CG knows"
gen malaria_signs2 = .
replace malaria_signs2 = 0 if q602 !=.
replace malaria_signs2 = 1 if tot_q604 >=2
lab var malaria_signs2 "Caregiver knows 2+ signs of malaria"
lab val malaria_signs2 yn
tab malaria_signs2 survey, col

*q605 was coded differently for the endline & baseline surveys in Malawi
*numerical at baseline, but a string at endline
***recode q605string from the endline survey
tab q605
tab q605string

gen q605a = 1 if strpos(q605string,"A") 
gen q605b = 1 if strpos(q605string,"B") 
gen q605c = 1 if strpos(q605string,"C") 
gen q605d = 1 if strpos(q605string,"D")
gen q605e = 1 if strpos(q605string,"E")
gen q605x = 1 if strpos(q605string,"X")
gen q605z = 1 if strpos(q605string,"Z")

***Knowledge of correct treatment for malaria, ACT (INDICATOR 32, OPTIONAL)
gen malaria_rx = .
replace malaria_rx = 0 if q602 !=.
replace malaria_rx = 1 if q605 == 1 | q605a == 1
lab var malaria_rx "Caregiver knows correct malaria treatment"
lab val malaria_rx yn
tab malaria_rx survey, col


****************MODULE 5: Caregiver knowledge & perceptions of iCCM CHWs********
*Caregiver knows there is an CHW in the community (INDICATOR 1)
tab q504 survey
recode q504 (2 8 = 0),gen(chw_know)
lab var chw_know "Caregiver knows CHW works in community"
lab values chw_know yn
tab chw_know survey, col

*Caregiver knows 2+ CHW curative services offered (INDICATOR 2)
*(among those who know that there is an CHW in their community)
by survey: tab1 q505*

encode q505a, gen(q505_a)
encode q505b, gen(q505_b)
encode q505c, gen(q505_c)
encode q505d, gen(q505_d)
encode q505e, gen(q505_e)
encode q505f, gen(q505_f)
encode q505g, gen(q505_g)
encode q505h, gen(q505_h)
encode q505i, gen(q505_i)
encode q505j, gen(q505_j)
encode q505k, gen(q505_k)
encode q505l, gen(q505_l)
encode q505m, gen(q505_m)
encode q505n, gen(q505_n)
encode q505o, gen(q505_o)
encode q505p, gen(q505_p)
encode q505q, gen(q505_q)
encode q505z, gen(q505_z)

foreach x of varlist q505_* {
  replace `x' = 0 if `x' == . & chw_know == 1
  lab val `x' yn
  }
  
*Total number of CHW curative services (Q505h-Q505p) that caregiver knows
egen tot_q505 = rownonmiss(q505h-q505p), strok
*replace tot_q505 =. if q504 != 1
label var tot_q505 "Total number of CHW curative services CG knows"
replace tot_q505 =. if q504 != 1
gen cgcurknow2 = tot_q505 >= 2 
replace cgcurknow2 =. if q504 != 1
lab var cgcurknow2 "Caregiver knows 2+ CHW curative services"
lab val cgcurknow2 yn
tab cgcurknow2 survey, col

*Caregiver knows CHW location
*(among those who know that there is an CHW in their community)
tab q506 survey
recode q506 8=0, gen(chw_loc)
tab chw_loc survey, col

*Look at all CHW perception responses
tab1 q508-q516

*CHW is a trusted provider (Q509 & Q512 must be YES) (INDICATOR 4)
tab q509 survey
tab q512 survey
gen chwtrusted = 0
replace chwtrusted = 1 if q509 == 1 & q512 == 1
replace chwtrusted =. if q504 != 1
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
replace chwquality = . if q504 != 1
lab var chwquality "CHW provides quality services"
lab val chwquality yn
tab chwquality survey, col

*CHW availability by caregiver (INDICATOR 57)
*(This one is a little tricky....)
*Want to see if the CHW was available at first visit for all cases the CG sought 
*care for included in the survey

*First calculate proportion of cases for which the CHW was available, by CG
*Create the numerator looking at Q724, Q822 & Q919 (CHW was available)
gen chwavail = 0
replace chwavail = chwavail + 1 if q724 == 1
replace chwavail = chwavail + 1 if q822 == 1
replace chwavail = chwavail + 1 if q919 == 1
replace chwavail =. if q724 ==. & q822 ==. & q919 ==.
lab var chwavail "Total number of times CG found CHW at first visit for children in survey"

*Create the denominator looking at Q724, Q822 & Q919 (CHW was visited)
gen chwavaild = 0
replace chwavaild = chwavaild + 1 if q724 !=.
replace chwavaild = chwavaild + 1 if q822 !=.
replace chwavaild = chwavaild + 1 if q919 !=.
replace chwavaild =. if q724 ==. & q822 ==. & q919 ==.
lab var chwavaild "Total number of times CG sought care from CHW for children in survey"

*Create the proportion (numerator variable / denominator variable)
gen chwavailp = chwavail/chwavaild
lab var chwavailp "Prop of time CHW was available at first visit"

*Create variable to capture if CHW was ALWAYS available at first visit (INDICATOR 6)
gen chwalwaysavail = 0
replace chwalwaysavail = 1 if chwavailp == 1
replace chwalwaysavail = . if chwavaild == .
lab var chwalwaysavail "CHW was available when caregiver sought care for each case included in survey"
lab val chwalwaysavail yn

tab chwalwaysavail survey, col 

*CHW convenient (INDICATOR 7)
tab q507 survey
tab q508 survey
gen chwconvenient = 0
replace chwconvenient = 1 if q507 == 1 & q508 == 1 
*replace chwconvenient = . if q504 != 1
lab var chwconvenient "CHW is a convenient source of care"
lab val chwconvenient yn
tab chwconvenient survey, col

*log close

*log using "diarrhea_results", replace
*******************MODULE 7: Diarrhea*******************************************
*Age of children with diarrhea (not really needed)
recode d_age min/11=1 12/23=2 24/35=3 36/47=4 48/60=5 98/99=.,gen (d_agecat)
lab val d_agecat agecat 
lab var d_agecat "Age category of children with diarrhea included in survey"
tab d_agecat survey, col

*continued fluids (same amount or more than usual?) (INDICATOR 28, OPTIONAL)
tab q701 survey
gen d_cont_fluids = .
replace d_cont_fluids = 1 if q701 == 3 | q701 == 4
replace d_cont_fluids = 0 if d_case == 1 & q701 !=. & d_cont_fluids == .
lab var d_cont_fluids "Child with diarrhea was offered same or more fluids"
lab val d_cont_fluids yn
tab d_cont_fluids survey, col

*continued feeding (same amount or more than usual) (INDICATOR 29, OPTIONAL)
tab q702 survey
gen d_cont_feed = .
replace d_cont_feed = 1 if q702 == 3 | q702 == 4
replace d_cont_feed = 0 if d_case == 1 & q702 !=. & d_cont_feed == .
lab var d_cont_feed "Child with diarrhea was offered same or more to eat"
lab val d_cont_feed yn
tab d_cont_feed survey, col
tab d_cont_feed survey, col

*sought any advice or treatment
tab q703 survey
recode q703 2 = 0
lab val q703 yn
tab q703 survey, col

*did not seek care
tab q703
gen d_nocare = .
replace d_nocare = 0 if q703 == 1 & d_case == 1
replace d_nocare = 1 if q703 == 0 & d_case == 1
lab var d_nocare "Did not seek care for child with diarrhea"
lab val d_nocare yn
tab d_nocare survey, col

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

*decided to seek care jointly
tab q704 survey, col

*where care was sought
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
encode q706x, gen(q706_x)

foreach x of varlist q706_* {
  replace `x' = 0 if `x' == . & d_case == 1 & q703 == 1
  lab val `x' yn
}

*total number of providers visited 
egen d_provtot = rownonmiss(q706a-q706x),strok
replace d_provtot = . if d_case != 1
lab var d_provtot "Total number of providers where sought care"
tab d_provtot survey, col

*sought advice or treatment from an appropriate provider (INDICATOR 8A)
egen d_apptot = rownonmiss(q706a-q706g),strok
replace d_apptot = . if d_case != 1
lab var d_apptot "Total number of appropriate providers where sought care"
recode d_apptot 1 2 3 = 1, gen(d_app_prov)
lab var d_app_prov "Sought care from 1+ appropriate provider"
lab val d_app_prov yn 
tab d_app_prov survey, col

*careseeking locations
gen d_cs_public = 1 if q706_a == 1 | q706_b == 1 | q706_c == 1 | q706_e == 1
gen d_cs_private = 1 if q706_f == 1 | q706_g == 1 
gen d_cs_chw = 1 if q706_d == 1
gen d_cs_store = 1 if q706_h == 1 | q706_j == 1 | q706_l == 1
gen d_cs_trad = 1 if q706_i == 1
gen d_cs_other = 1 if q706_k == 1 | q706_x == 1

foreach x of varlist d_cs_* {
  replace `x' = 0 if d_case == 1 & q703 == 1 & `x' ==.
  lab val `x' yn
}

***diarrhoea sought treatment from an appropriate provider jointly with a partner (INDICATOR 21A, OPTIONAL)
gen d_app_joint =.
replace d_app_joint = 1 if d_app_prov == 1 & q705a == "A" & union == 1 & q703 == 1
replace d_app_joint = 0 if d_app_joint ==. & d_case == 1 & union == 1
lab var d_app_joint "Decided to seek care from appropriate provider jointly with partner"
lab val d_app_joint yn
tab d_app_joint survey, col

***diarrhoea sought treatment from an appropriate provider jointly with a partner (INDICATOR 21A, OPTIONAL)
gen d_joint =.
replace d_joint = 1 if q705a == "A" & union == 1 & q703 == 1
replace d_joint = 0 if d_joint ==. & d_case == 1 & union == 1
lab var d_joint "Decided to seek care jointly with partner"
lab val d_joint yn
tab d_joint survey, col

*visited an CHW
tab q706d survey
tab q708 survey
gen d_chw = 1 if q706d == "D"
replace d_chw = 0 if d_chw ==. & d_case == 1
lab var d_chw "Sought care from CHW for diarrhea"
lab val d_chw yn
tab d_chw survey, col 

*did not seek care from a CHW
gen d_nocarechw = .
replace d_nocarechw = 0 if d_case == 1 & q703 == 1
replace d_nocarechw = 1 if q706d != "D" & q703 == 1 & d_case == 1
lab var d_nocarechw "Sought care for diarrhea - but not from CHW"
lab val d_nocarechw yn
tab d_nocarechw survey, col

*visited an CHW as first (*or only*) source of care (INDICATOR 9A)
gen d_chwfirst = .
replace d_chwfirst = 1 if q708 == "D"
replace d_chwfirst = 1 if q706d == "D" & d_provtot == 1
replace d_chwfirst = 0 if d_case == 1 & d_chwfirst ==.
lab var d_chwfirst "Sought care from CHW first"
lab val d_chwfirst yn
tab d_chwfirst survey, col
svy: tab d_chwfirst survey, col ci pear

*visited an CHW as first (*or only*) source of care
gen d_chwfirst_anycare = .
replace d_chwfirst_anycare = 0 if d_case == 1 & q703 == 1
replace d_chwfirst_anycare = 1 if q708 == "D"
replace d_chwfirst_anycare = 1 if q706d == "D" & d_provtot == 1
lab var d_chwfirst_anycare "Sought care from CHW first among those who sought any care"
lab val d_chwfirst_anycare yn
tab d_chwfirst_anycare survey, col

*first source of care locations
gen d_fcs_public = 1 if q708 == "A" | q708 == "B" | q708 == "C" | q708 == "E"
gen d_fcs_private = 1 if q708 == "F" | q708 == "G" 
gen d_fcs_chw = 1 if q708 == "D"
gen d_fcs_store = 1 if q708 == "H" | q708 == "J" | q708 == "L"
gen d_fcs_trad = 1 if q708 == "I"
gen d_fcs_other = 1 if q708 == "K" | q708 == "X"

replace d_fcs_public = 1 if (q706_a == 1 | q706_b == 1 | q706_c == 1 | q706_e == 1) & d_provtot == 1
replace d_fcs_private = 1 if (q706_f == 1 | q706_g == 1) & d_provtot == 1
replace d_fcs_chw = 1 if q706_d == 1 & d_provtot == 1
replace d_fcs_store = 1 if (q706_h == 1 | q706_j == 1 | q706_l == 1) & d_provtot == 1
replace d_fcs_trad = 1 if q706_i == 1 & d_provtot == 1
replace d_fcs_other = 1 if (q706_k == 1 | q706_x == 1) & d_provtot == 1

foreach x of varlist d_fcs_* {
  replace `x' = 0 if d_case == 1 & q703 == 1 & `x' ==.
  lab val `x' yn
}

****reason(s) did not go to CHW for care (ENDLINE ONLY)
tab1 q708ba-q708bz
egen tot_q708b = rownonmiss(q708ba-q708bx),strok
replace tot_q708b = . if survey == 1
replace tot_q708b = . if q703 != 1
replace tot_q708b = . if q706d == "D"
lab var tot_q708b "Total number of reasons CG did not seek care by CHW"
tab tot_q708b

encode q708ba, gen(q708b_a)
encode q708bb, gen(q708b_b)
encode q708bc, gen(q708b_c)
encode q708bd, gen(q708b_d)
encode q708be, gen(q708b_e)
encode q708bf, gen(q708b_f)
encode q708bx, gen(q708b_x)
encode q708bz, gen(q708b_z)

foreach x of varlist q708b_* {
  replace `x' = 0 if `x' == . & d_case == 1 & survey == 2 & q703 == 1 & q706d != "D"
  lab val `x' yn
}


***treated with ORS (INDICATOR 26, OPTIONAL)
***Malawi only had one ORS field but other countries have more than 1 (709a & b) - must add
tab q709 survey
gen d_ors = 1 if q709 == 1
replace d_ors = 0 if q709 == 2 | q709 == 8
lab var d_ors "Took ORS for diarrhea"
lab val d_ors yn
tab d_ors survey, col

*where did caregiver get ORS?
tab q711 survey, col

gen d_ors_public = 1 if q711 == 11 | q711 == 12 | q711 == 13 | q711 == 15
gen d_ors_private = 1 if q711 == 21 | q711 == 22 
gen d_ors_chw = 1 if q711 == 14
gen d_ors_store = 1 if q711 == 23 | q711 == 32 | q711 == 34
gen d_ors_trad = 1 if q711 == 31
gen d_ors_other = 1 if q711 == 33 | q711 == 41

foreach x of varlist d_ors_* {
  replace `x' = 0 if d_case == 1 & d_ors == 1 & `x' ==.
  lab val `x' yn
}

*got ORS from CHW
recode q711 11 12 13 21 22 32 33 34 41 = 0 14 = 1, gen(d_orschw)
replace d_orschw = 0 if d_orschw ==. & d_case == 1
replace d_orschw = . if d_case ==.
lab var d_orschw "Got ORS from an CHW"
lab val d_orschw yn
tab d_orschw survey, col

*if from CHW, did child take ORS in presence of CHW? (INDICATOR 15A)
tab q713 survey
recode q713 2=0, gen(d_ors_chwp)
lab val d_ors_chwp yn
tab d_ors_chwp survey, col

*if from CHW, did caregiver get counseled on how to give ORS at home? (INDICATOR 16A)
tab q714 survey
recode q714 2=0, gen(d_ors_chwc)
lab val d_ors_chwc yn
tab d_ors_chwc survey, col 

*Not in Malawi dataset
*took Homemade fluid
*gen d_hmfl = 1 if q709c == 1
*replace d_hmfl = 0 if q709c == 2 | q709c == 8
*replace d_hmfl = . if d_case !=.
*lab var d_hmfl "Took homemade fluid for diarrhea"
*lab val d_hmfl yn
*tab d_hmfl survey, col

*took Zinc (INDICATOR 27, OPTIONAL)
recode q715 (2 8 = 0), gen(d_zinc)
lab val d_zinc yn
replace d_zinc = . if d_case != 1
tab d_zinc survey, col

*where did caregiver get zinc?
tab q716 survey, col

gen d_zinc_public = 1 if q716 == 11 | q716 == 12 | q716 == 13 | q716 == 15
gen d_zinc_private = 1 if q716 == 21 | q716 == 22 
gen d_zinc_chw = 1 if q716 == 14
gen d_zinc_store = 1 if q716 == 23 | q716 == 32 | q716 == 34
gen d_zinc_trad = 1 if q716 == 31
gen d_zinc_other = 1 if q716 == 33 | q716 == 41

foreach x of varlist d_zinc_* {
  replace `x' = 0 if d_case == 1 & d_zinc == 1 & `x' ==.
  lab val `x' yn
}

*got zinc from CHW
recode q716 11 12 13 21 22 32 33 34 41 = 0 14 = 1, gen(d_zincchw)
replace d_zincchw = 0 if d_zincchw ==. & d_case == 1
lab val d_zincchw yn
replace d_zincchw = . if d_case != 1
tab d_zincchw survey, col

*if from CHW, did child take zinc in presence of CHW? (INDICATOR 15B)
tab q718 survey, col
recode q718 2=0, gen(d_zinc_chwp)
lab val d_zinc_chwp yn
tab d_zinc_chwp survey, col 

*if from CHW, did caregiver get counseled on how to give zinc at home? (INDICATOR 16B)
* ONLY 2 NO's in endline survey; 0 in baseline.
tab q719 survey, col
recode q719 2=0, gen(d_zinc_chwc)
lab val d_zinc_chwc yn
tab d_zinc_chwc survey, col

*treated with ORS AND Zinc (INDICATOR 13A)
gen d_orszinc = .
replace d_orszinc = 0 if d_case == 1
replace d_orszinc = 1 if d_ors==1 & d_zinc==1
lab var d_orszinc "Took both ORS and zinc for diarrhea"
lab val d_orszinc yn
tab d_orszinc survey, col

*treated with ORS AND Zinc by CHW (INDICATOR 14A)
gen d_orszincchw = 0
replace d_orszincchw = 1 if d_orszinc == 1 & q711 == 14 & q716 == 14 
replace d_orszincchw =. if d_case != 1
lab var d_orszincchw "Took both ORS and zinc for diarrhea"
lab val d_orszincchw yn
tab d_orszincchw survey, col

*treated with ORS AND Zinc by CHW among those who sought care from a CHW
gen d_orszincchw2 = 0
replace d_orszincchw2 = 1 if d_orszinc == 1 & q711 == 14 & q716 == 14 
replace d_orszincchw2 =. if d_chw != 1
lab var d_orszincchw2 "Got both ORS and zinc for diarrhea from CHW among those who sought care from a CHW"
lab val d_orszincchw2 yn
tab d_orszincchw2 survey, col

*took both ORS AND Zinc in presence of CHW (INDICATOR 15C)
gen d_bothfirstdose =.
replace d_bothfirstdose = 1 if q713 == 1 & q718 == 1
replace d_bothfirstdose = 0 if q711 == 14 & q716 == 14 & d_bothfirstdose ==.
lab var d_bothfirstdose "Took first dose of both ORS and zinc in presense of CHW"
lab val d_bothfirstdose yn
tab d_bothfirstdose survey, col

*was counseled on admin of both ORS AND Zinc by CHW (INDICATOR 16C)
gen d_bothcounsel =.
replace d_bothcounsel = 1 if q714 == 1 & q719 == 1
replace d_bothcounsel = 0 if q711 == 14 & q716 == 14 & d_bothcounsel ==.
lab var d_bothcounsel "Was counseled on admin of both ORS and zinc by CHW"
lab val d_bothcounsel yn
tab d_bothcounsel survey, col

*if CHW visited, was available at first visit
tab q724 survey
recode q724 2=0, gen(d_chwavail)
lab val d_chwavail yn
tab d_chwavail survey, col
***one response missing

*if CHW visited, did CHW refer the child to a health center?
tab q725 survey
recode q725 2=0, gen(d_chwrefer)
lab val d_chwrefer yn
tab d_chwrefer survey, col
***one response missing

****completed CHW referral (INDICATOR 17A)
tab q726 survey
recode q726 2=0, gen(d_referadhere)
lab val d_referadhere yn
tab d_referadhere survey, col 

***reason did not comply with CHW referral
by survey: tab1 q727*

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

***CHW follow-up (INDICATOR 18A)
tab q728
recode q728 2=0, gen(d_chw_fu)
lab val d_chw_fu yn
tab d_chw_fu survey, col

***when was CHW follow-up
tab q729 survey, col

*did the child take anything else for diarrhea?
tab q720 

tab1 q721*

encode q721a, gen(q721_a)
encode q721b, gen(q721_b)
encode q721c, gen(q721_c)
encode q721d, gen(q721_d)
encode q721e, gen(q721_e)
encode q721f, gen(q721_f)
encode q721g, gen(q721_g)
encode q721h, gen(q721_h)
encode q721i, gen(q721_i)
encode q721x, gen(q721_x)

foreach x of varlist q721_* {
  replace `x' = 0 if `x' == . & q720 == 1
  lab val `x' yn
  }

*log close

*log using "fever_results", replace
*********************MODULE 8: Fever *******************************************
*Age of children with fever (not really needed)
recode f_age min/23=1 24/60=2 98/99=.,gen(f_agecat)

*sought any advice or treatment for fever
tab q803 survey
recode q803 2 = 0
lab val q803 yn
tab q803 survey, col 

*did not seek care
tab q803
gen f_nocare = .
replace f_nocare = 0 if q803 == 1 & f_case == 1
replace f_nocare = 1 if q803 == 0 & f_case == 1
lab var f_nocare "Did not seek care for child with fever"
lab val f_nocare yn
tab f_nocare survey, col

*reason did not seek care for fever (ENDLINE ONLY)
tab1 q828*
*See how many reasons were given since multiple responses were allowed
egen tot_q828 = rownonmiss(q828a-q828x),strok
replace tot_q828 = . if q803 != 0
replace tot_q828 = . if survey == 1
lab var tot_q828 "Number of reasons caregiver did not seek care"
tab tot_q828

encode q828a, gen(q828_a)
encode q828b, gen(q828_b)
encode q828c, gen(q828_c)
encode q828d, gen(q828_d)
encode q828e, gen(q828_e)
encode q828f, gen(q828_f)
encode q828g, gen(q828_g)
encode q828x, gen(q828_x)
encode q828z, gen(q828_z)

foreach x of varlist q828_* {
  replace `x' = 0 if `x' == . & f_case == 1 & survey == 2 & q803 == 0
  lab val `x' yn
}

*decided to seek care jointly
tab q804 survey, col

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
encode q806x, gen(q806_x)

foreach x of varlist q806_* {
  replace `x' = 0 if `x' == . & f_case == 1 & q803 == 1
  lab val `x' yn
}

*total number of providers visited 
egen f_provtot = rownonmiss(q806a-q806x),strok
replace f_provtot = . if f_case != 1
lab var f_provtot "Total number of providers where sought care"
tab f_provtot survey, col

*sought advice or treatment from an appropriate provider (INDICATOR 8B)
egen f_apptot = rownonmiss(q806a-q806g),strok
replace f_apptot = . if f_case != 1
lab var f_apptot "Total number of appropriate providers where sought care"
recode f_apptot 1 2 3 = 1, gen(f_app_prov)
lab var f_app_prov "Sought care from 1+ appropriate provider"
lab val f_app_prov yn 
tab f_app_prov survey, col

***fever decided to seek care from an appropriate provider jointly with a partner (INDICATOR 21B, OPTIONAL)
gen f_app_joint =.
replace f_app_joint = 1 if f_app_prov == 1 & q805a == "A" & union == 1 & f_case == 1
replace f_app_joint = 0 if f_app_joint ==. & f_case == 1 & union == 1
lab var f_app_joint "Decided to seek care from appropriate provider jointly with partner"
lab val f_app_joint yn
tab f_app_joint survey, col

***fever decided to seek care jointly with a partner (INDICATOR 21B, OPTIONAL)
gen f_joint =.
replace f_joint = 1 if q805a == "A" & union == 1 & f_case == 1
replace f_joint = 0 if f_joint ==. & f_case == 1 & union == 1
lab var f_joint "Decided to seek care from appropriate provider jointly with partner"
lab val f_joint yn
tab f_joint survey, col

*careseeking locations
gen f_cs_public = 1 if q806_a == 1 | q806_b == 1 | q806_c == 1 | q806_e == 1
gen f_cs_private = 1 if q806_f == 1 | q806_g == 1 
gen f_cs_chw = 1 if q806_d == 1
gen f_cs_store = 1 if q806_h == 1 | q806_j == 1 | q806_l == 1
gen f_cs_trad = 1 if q806_i == 1
gen f_cs_other = 1 if q806_k == 1 | q806_x == 1

foreach x of varlist f_cs_* {
  replace `x' = 0 if f_case == 1 & q803 == 1 & `x' ==.
  lab val `x' yn
}

*visited a CHW
tab q806d survey
tab q808 survey
gen f_chw = 1 if q806d == "D"
replace f_chw = 0 if f_chw ==. & f_case == 1 
lab var f_chw "Sought care from CHW for fever"
lab val f_chw yn
tab f_chw survey, col

*did not seek care from a CHW
gen f_nocarechw = .
replace f_nocarechw = 0 if f_case == 1 & q803 == 1
replace f_nocarechw = 1 if q806d != "D" & q803 == 1 & f_case == 1
lab var f_nocarechw "Sought care for fever - but not from CHW"
lab val f_nocarechw yn
tab f_nocarechw survey, col

*visited an CHW as first (*or only*) source of care (INDICATOR 9B)
gen f_chwfirst = .
replace f_chwfirst = 1 if q808 == "D"
replace f_chwfirst = 1 if q806d == "D" & f_provtot == 1
replace f_chwfirst = 0 if f_case == 1 & f_chwfirst ==.
lab var f_chwfirst "Sought care from CHW first"
lab val f_chwfirst yn
tab f_chwfirst survey, col

*visited an CHW as first (*or only*) source of care
gen f_chwfirst_anycare = .
replace f_chwfirst_anycare = 0 if f_case == 1 & q803 == 1
replace f_chwfirst_anycare = 1 if q808 == "D"
replace f_chwfirst_anycare = 1 if q806d == "D" & f_provtot == 1
lab var f_chwfirst_anycare "Sought care from CHW first among those who sought any care"
lab val f_chwfirst_anycare yn
tab f_chwfirst_anycare survey, col

*first source of care locations
gen f_fcs_public = 1 if q808 == "A" | q808 == "B" | q808 == "C" | q808 == "E"
gen f_fcs_private = 1 if q808 == "F" | q808 == "G" 
gen f_fcs_chw = 1 if q808 == "D"
gen f_fcs_store = 1 if q808 == "H" | q808 == "J" | q808 == "L"
gen f_fcs_trad = 1 if q808 == "I"
gen f_fcs_other = 1 if q808 == "K" | q808 == "X"

replace f_fcs_public = 1 if (q806_a == 1 | q806_b == 1 | q806_c == 1 | q806_e == 1) & f_provtot == 1
replace f_fcs_private = 1 if (q806_f == 1 | q806_g == 1) & f_provtot == 1
replace f_fcs_chw = 1 if q806_d == 1 & f_provtot == 1
replace f_fcs_store = 1 if (q806_h == 1 | q806_j == 1 | q806_l == 1) & f_provtot == 1
replace f_fcs_trad = 1 if q806_i == 1 & f_provtot == 1
replace f_fcs_other = 1 if (q806_k == 1 | q806_x == 1) & f_provtot == 1

foreach x of varlist f_fcs_* {
  replace `x' = 0 if f_case == 1 & q803 == 1 & `x' ==.
  lab val `x' yn
}
	
****reason(s) did not go to CHW for care (ENDLINE ONLY)
tab1 q808ba-q808bz
egen tot_q808b = rownonmiss(q808ba-q808bx),strok
replace tot_q808b = . if survey == 1
replace tot_q808b = . if f_case != 1
replace tot_q808b = . if q806d == "D"
lab var tot_q808b "Total number of reasons CG did not seek care from CHW"
tab tot_q808b

encode q808ba, gen(q808b_a)
encode q808bb, gen(q808b_b)
encode q808bc, gen(q808b_c)
encode q808bd, gen(q808b_d)
encode q808be, gen(q808b_e)
encode q808bf, gen(q808b_f)
encode q808bx, gen(q808b_x)
encode q808bz, gen(q808b_z)

foreach x of varlist q808b_* {
  replace `x' = 0 if `x' == . & f_case == 1 & survey == 2 & q803 == 1 & q806d != "D"
  lab val `x' yn
}

*had blood taken (INDICATOR 10)
tab q809 survey
recode q809 2=0, gen(f_bloodtaken)
replace f_bloodtaken = 0 if f_bloodtaken ==. & f_case == 1
lab var f_bloodtaken "Child had blood taken"
lab val f_bloodtaken yn
tab f_bloodtaken survey, col 

***Questions 809a and 810 are coded differently in BL & EL surveys
egen mrdtwheretot = rownonmiss(q809aa-q809az),strok
lab var mrdtwheretot "Total number of locations where mRDT was done"
tab mrdtwheretot survey
list q809aa-q809az q823 if mrdtwheretot == 2

egen mrdtwhotot = rownonmiss(q810a-q810z),strok
lab var mrdtwhotot "Total number of providers who performed mRDT"
tab mrdtwhotot survey
list q810a-q810z q823 if mrdtwhotot == 2 | mrdtwhotot == 3

* where was the blood test done?
***Endline (multiple responses allowed)
tab1 q809aa-q809az if survey == 2

***Baseline (only one response allowed)
tab q809a if survey == 1

gen q809a_a = 1 if q809a == 1 | q809aa == "A"
gen q809a_b = 1 if q809a == 2 | q809ab == "B"
gen q809a_c = 1 if q809a == 3 | q809ac == "C"
gen q809a_d = 1 if q809a == 4 | q809ad == "D"
gen q809a_x = 1 if q809ax == "X"

foreach x of varlist q809a_* {
  replace `x' = 0 if `x' ==. & q809 == 1
  lab val `x' yn
}

* who performed the blood test?
***Endline (multiple responses allowed)
tab1 q810a-q810z if survey == 2

***Baseline (only one response allowed)
tab q810 if survey == 1

gen q810_a = 1 if q810 == 1 | q810a == "A"
gen q810_b = 1 if q810 == 2 | q810b == "B"
gen q810_c = 1 if q810 == 3 | q810c == "C"
gen q810_d = 1 if q810 == 4 | q810d == "D"
gen q810_e = 1 if q810 == 5 | q810e == "E"
gen q810_x = 1 if q810 == 6 | q810x == "X"
gen q810_z = 1 if q810 == 8 | q810z == "Z"

foreach x of varlist q810_* {
  replace `x' = 0 if `x' ==. & q809 == 1
  lab val `x' yn
}


*caregiver received results of blood test (INDICATOR 11)
tab q811 survey
recode q811 2 8 = 0, gen(f_gotresult)
lab val f_gotresult yn
lab var f_gotresult "Caregiver received results of blood test"
tab f_gotresult survey, col

*blood test results
tab q812 survey
recode q812 2=0, gen(f_result)
lab def result 0 "Negative" 1 "Positive"
lab val f_result result
tab f_result survey, col 

*had blood taken by CHW at a village clinic (INDICATOR 10)
gen f_bloodtakenchw =.
replace f_bloodtakenchw = 0 if f_chw == 1
replace f_bloodtakenchw = 1 if f_chw == 1 & (q809a_a == 1 & q810_a == 1) & survey == 2
lab var f_bloodtakenchw "Child had blood taken by CHW at village clinic"
lab val f_bloodtakenchw yn
tab f_bloodtakenchw survey, col 

*had blood taken by a CHW (may or may not have been at a village clinic)
gen f_bloodtakenchw2 =.
replace f_bloodtakenchw2 = 0 if f_chw == 1
replace f_bloodtakenchw2 = 1 if f_chw == 1 & q810_a == 1
lab var f_bloodtakenchw2 "Child had blood taken by CHW"
lab val f_bloodtakenchw2 yn
tab f_bloodtakenchw2 survey, col 

*caregiver received results of blood test done by CHW at village clinic (INDICATOR 11)
gen f_gotresultchw =.
replace f_gotresultchw = 0 if f_bloodtakenchw == 1
replace f_gotresultchw = 1 if f_gotresult == 1 & f_chw == 1 & (q809a_a == 1 & q810_a == 1)
replace f_gotresultchw = . if survey == 1
lab val f_gotresultchw yn
lab var f_gotresultchw "Caregiver received results of blood test done at village clinic by CHW"
tab f_gotresultchw survey, col

*caregiver received results of blood test done by CHW (may or may not have been at a village clinic)
gen f_gotresultchw2 =.
replace f_gotresultchw2 = 0 if f_bloodtakenchw2 == 1
replace f_gotresultchw2 = 1 if f_gotresult == 1 & f_chw == 1 & q810_a == 1
lab val f_gotresultchw2 yn
lab var f_gotresultchw2 "Caregiver received results of blood test done by CHW"
tab f_gotresultchw2 survey, col

*blood test results from blood test done by CHW at village clinic
gen f_resultchw =.
replace f_resultchw = 0 if f_gotresultchw == 1
replace f_resultchw = 1 if f_result == 1 & f_chw == 1 & q809a_a == 1 & q810_a == 1
replace f_resultchw = . if survey == 1
lab var f_resultchw "Result of test done by CHW at village clinic"
lab val f_resultchw result
tab f_resultchw survey, col 

*blood test results from blood test done by CHW (may or may not have been at a village clinic)
gen f_resultchw2 =.
replace f_resultchw2 = 0 if f_gotresultchw2 == 1
replace f_resultchw2 = 1 if f_result == 1 & f_chw == 1 & q810_a == 1
lab var f_resultchw2 "Result of test done by CHW"
lab val f_resultchw2 result
tab f_resultchw2 survey, col 

***took any antimalarial for fever, among all fever cases (INDICATOR 22, OPTIONAL)
by survey: tab1 q814*

encode(q814a), gen(q814_a)
encode(q814b), gen(q814_b)
encode(q814c), gen(q814_c)
encode(q814d), gen(q814_d)
encode(q814e), gen(q814_e)
encode(q814f), gen(q814_f)
encode(q814g), gen(q814_g)
encode(q814h), gen(q814_h)
encode(q814x), gen(q814_x)
encode(q814z), gen(q814_z)

foreach x of varlist q814_* {
  replace `x' = 0 if `x' ==. & q813 == 1
  lab val `x' yn
}

gen f_antim = 0 if f_case == 1 & f_age >= 5
replace f_antim = 1 if (q814a == "A" | q814b == "B" | q814c == "C") & f_age >= 5
lab var f_antim "Took antimalarial for fever, among all fever cases"
lab val f_antim yn
tab f_antim survey, col

*took antimalarial, among cases with positive blood test
gen f_antimc = 0 if f_result == 1 & f_age >= 5
replace f_antimc = 1 if (q814a == "A" | q814b == "B" | q814c == "C") & q812 == 1 & f_age >= 5
lab var f_antimc "Took antimalarial for fever, among those with positive blood test"
lab val f_antimc yn
tab f_antimc survey, col

*took ACT (includes cases in which blood taken but results not given or not positive)
gen f_act = 0 if f_case == 1 & f_age >= 5
replace f_act = 1 if q814a == "A" & f_age >= 5
lab var f_act "Took ACT for fever, among all fever cases"
lab val f_act yn
tab f_act survey, col

*did not take ACT
gen f_noact =.
replace f_noact = 0 if f_case == 1 & f_age >= 5
replace f_noact = 1 if f_act == 0 & f_age >= 5
lab var f_noact "Did not take ACT for fever, among all fever cases"
lab val f_noact yn
tab f_noact survey, col

*took ACT - confirmed malaria, positive blood test
gen f_actc = 0 if f_result == 1 & f_age >= 5
replace f_actc = 1 if f_act == 1 & f_result == 1 & f_age >= 5
lab var f_actc "Took ACT for fever, among those with a positive blood test"
lab val f_actc yn
tab f_actc survey, col

*took ACT - presumptive treatment, no blood test
gen f_actp = 0 if f_bloodtaken == 0 & f_age >= 5
replace f_actp = 1 if f_act == 1 & f_bloodtaken == 0 & f_age >= 5
lab var f_actp "Took ACT for fever, among those who did not get a blood test"
lab val f_actp yn
tab f_actp survey, col

*took ACT - presumptive + confirmed treatment 
gen f_acto = f_actc & f_age >= 5
replace f_acto = f_actp if f_act == 1 & f_bloodtaken == 0 & f_case == 1 & f_age >= 5
lab var f_acto "Took ACT for fever, confirmed + presumptive treatment"
lab val f_acto yn
tab f_acto survey, col

*took ACT, but negative blood test
gen f_actneg =.
replace f_actneg = 0 if f_result == 0 & f_age >= 5
replace f_actneg = 1 if f_result == 0 & f_act == 1 & f_age >= 5
lab var f_actneg "Took ACT for fever, among those with a negative blood test"
lab val f_actneg yn
tab f_actneg survey, col

*No ACT - but confirmed malaria, positive blood test
gen f_noactc =.
replace f_noactc = 0 if f_result == 1 & f_age >= 5
replace f_noactc = 1 if f_result == 1 & f_act != 1 & f_age >= 5
lab var f_noactc "No ACT, among those with a positive blood test"
lab val f_noactc yn
tab f_noactc survey, col

*No ACT, negative blood test
gen f_noactnoc =.
replace f_noactnoc = 0 if f_result == 0 & f_age >= 5
replace f_noactnoc = 1 if f_result == 0 & f_act != 1 & f_age >= 5
lab var f_noactnoc "No ACT, among those with a negative blood test"
lab val f_noactnoc yn
tab f_noactnoc survey, col

*No ACT, no blood test
gen f_noactnotest=.
replace f_noactnotest = 0 if f_bloodtaken == 0 & f_age >= 5 & f_nocare == 0
replace f_noactnotest = 1 if f_bloodtaken == 0 & f_act != 1 & f_age >= 5 & f_nocare == 0
lab var f_noactnotest "No ACT, among those who sought care and did not get a blood test"
lab val f_noactnotest yn
tab f_noactnotest survey, col

*ACT, no blood test
gen f_actnotest=.
replace f_actnotest = 0 if f_bloodtaken == 0 & f_age >= 5 & f_nocare == 0
replace f_actnotest = 1 if f_bloodtaken == 0 & f_act == 1 & f_age >= 5 & f_nocare == 0
lab var f_actnotest "ACT, among those who sought care and did not get a blood test"
lab val f_actnotest yn
tab f_actnotest survey, col

*took ACT among any antimalarial (INDICATOR 23, OPTIONAL)
gen f_act_am = .
replace f_act_am = 0 if f_antim == 1 & f_act_am ==. & f_age >= 5
replace f_act_am = 1 if f_act == 1 & f_age >= 5
lab var f_act_am "Took ACT for fever, among those who took any antimalarial"
lab val f_act_am yn
tab f_act_am survey, col

*took ACT among any antimalarial - positive blood test
gen f_act_amc = .
replace f_act_amc = 0 if f_antimc == 1 & f_age >= 5
replace f_act_amc = 1 if f_actc == 1 & f_antimc == 1 & f_age >= 5
lab var f_act_amc "Took ACT, among those with a positive blood test who took any antimalarial"
lab val f_act_amc yn
tab f_act_amc survey, col

*took ACT within 24 hours (same or next day) 
gen f_act24 = 0 if f_case == 1 & f_age >= 5
replace f_act24 = 1 if f_act == 1 & q817 < 2 & f_age >= 5
lab var f_act24 "Took ACT same or next day, among all fever cases"
lab val f_act24 yn
tab f_act24 survey, col

*took ACT within 24 hours (same or next day), presumptive treatment
gen f_act24p = .
replace f_act24p = 0 if f_bloodtaken == 0 & f_age >= 5
replace f_act24p = 1 if f_actp == 1 & q817 < 2 & f_bloodtaken == 0 & f_age >= 5
lab var f_act24p "Took ACT same or next day, among those who did not get a blood test"
lab val f_act24p yn
tab f_act24p survey, col

*took ACT within 24 hours (same or next day), confirmed malaria - positive blood test
gen f_act24c = .
replace f_act24c = 0 if f_result == 1 & f_age >= 5
replace f_act24c = 1 if f_actc == 1 & q817 < 2  & f_result == 1 & f_age >= 5
lab var f_act24c "Took ACT same or next day, among those with a positive blood test"
lab val f_act24c yn
tab f_act24c survey, col

*took ACT within 24 hours (same or next day), confirmed + presumptive treatment
gen f_act24o = f_act24c if f_age >= 5
replace f_act24o = f_act24p if f_bloodtaken == 0 & f_case == 1 & f_age >= 5
lab var f_act24o "Took ACT same or next day, presumptive + confirmed treatment"
lab val f_act24o yn
tab f_act24o survey, col

*took ACT within 24 hours, but negative blood test
gen f_act24neg =.
replace f_act24neg = 0 if f_result == 0 & f_age >= 5
replace f_act24neg = 1 if f_result == 0 & f_act == 1 & q817 < 2 & f_age >= 5
lab var f_act24neg "Took ACT same or next day, among those with a negative blood test"
lab val f_act24neg yn
tab f_act24neg survey, col

*where did caregiver get ACT?
tab q816 survey, col

gen f_act_public = 1 if q816 == 11 | q816 == 12 | q816 == 13 | q816 == 15
gen f_act_private = 1 if q816 == 21 | q816 == 22 
gen f_act_chw = 1 if q816 == 14
gen f_act_store = 1 if q816 == 23 | q816 == 32 | q816 == 34
gen f_act_trad = 1 if q816 == 31
gen f_act_other = 1 if q816 == 33 | q816 == 41

foreach x of varlist f_act_* {
  replace `x' = 0 if f_case == 1 & f_act == 1 & `x' ==.
  lab val `x' yn
}

***ACT treatment from CHW 
gen f_actchw = .
replace f_actchw = 0 if f_case == 1 & f_age >= 5
replace f_actchw = 1 if f_act == 1 & q816 == 14 & f_age >= 5
lab var f_actchw "ACT treatment by a CHW, among all fever cases"
lab val f_actchw yn
tab f_actchw survey, col

gen f_actchw2 = .
replace f_actchw2 = 0 if f_chw == 1 & f_age >= 5
replace f_actchw2 = 1 if f_act == 1 & q816 == 14 & f_chw == 1 & f_age >= 5
lab var f_actchw2 "ACT treatment by a CHW, among those who sought care from a CHW"
lab val f_actchw2 yn
tab f_actchw2 survey, col

***ACT treatment from CHW - positive blood test
gen f_actcchw = .
replace f_actcchw = 0 if f_result == 1 & f_age >= 5
replace f_actcchw = 1 if f_actchw == 1 & f_resultchw == 1 & f_age >= 5
lab var f_actcchw "ACT treatment by a CHW, among all cases with a positive blood test"
lab val f_actcchw yn
tab f_actcchw survey, col

***ACT treatment from CHW among those who had a positive blood test done at a village clinic by a CHW
gen f_actcchw2 = . 
replace f_actcchw2 = 0 if f_resultchw == 1 & f_age >= 5
replace f_actcchw2 = 1 if f_actchw == 1 & f_resultchw == 1 & f_age >= 5
lab var f_actcchw2 "ACT treatment by a CHW, among those with positive blood test by CHW at village clinic"
lab val f_actcchw2 yn
tab f_actcchw2 survey, col

***ACT treatment from CHW among those who had a positive blood test done by a CHW
gen f_actcchw3 = .
replace f_actcchw3 = 0 if f_resultchw2 == 1 & f_age >= 5
replace f_actcchw3 = 1 if f_actchw == 1 & f_resultchw2 == 1 & f_age >= 5
lab var f_actcchw3 "ACT treatment by CHW, among those with positive blood test by CHW"
lab val f_actcchw3 yn
tab f_actcchw3 survey, col

***ACT treatment from CHW - no blood test, presumptive treatment
gen f_actpchw = 0 if f_bloodtaken == 0 & f_age >= 5
replace f_actpchw = f_actp if q816 == 14 & f_age >= 5
replace f_actpchw = . if f_bloodtaken == 1
lab var f_actpchw "ACT treatment by CHW, among all cases with no blood test"
lab val f_actpchw yn
tab f_actpchw survey, col

gen f_actpchw2 = 0 if f_chw == 1 & f_bloodtakenchw == 0 & f_age >= 5
*replace f_actpchw2 = f_actp if q816 == 14 & f_chw == 1 & f_bloodtakenchw == 0
replace f_actpchw2 = 1 if q816 == 14 & f_chw == 1 & f_bloodtakenchw == 0 & f_age >= 5
lab var f_actpchw2 "ACT treatment by CHW, among those who sought care from CHW and did not have a blood test"
lab val f_actpchw2 yn
tab f_actpchw2 survey, col

*took ACT, but negative blood test
gen f_actnegchw =.
replace f_actnegchw = 0 if f_resultchw == 0 & f_chw == 1 & f_age >= 5
replace f_actnegchw = 1 if f_resultchw == 0 & f_actchw == 1 & f_chw == 1 & f_age >= 5
lab var f_actnegchw "ACT treatment by CHW, among those with negative blood test by CHW"
lab val f_actnegchw yn
tab f_actnegchw survey, col

*No ACT - but confirmed malaria, positive blood test by CHW
gen f_noactcchw =.
replace f_noactcchw = 0 if f_chw == 1 & f_resultchw == 1 & f_age >= 5
replace f_noactcchw = 1 if f_resultchw == 1 & f_actchw != 1 & f_chw == 1 & f_age >= 5
lab var f_noactcchw "No ACT from CHW, among those with a positive blood test by a CHW at village clinic"
lab val f_noactcchw yn
tab f_noactcchw survey, col

*No ACT, negative blood test by CHW
gen f_noactnocchw =.
replace f_noactnocchw = 0 if f_resultchw == 0 & f_chw == 1 & f_age >= 5
replace f_noactnocchw = 1 if f_resultchw == 0 & f_actchw != 1 & f_chw == 1 & f_age >= 5
lab var f_noactnocchw "No ACT from CHW, among those with a negative blood test by a CHW at village clinic"
lab val f_noactnocchw yn
tab f_noactnocchw survey, col

*No ACT, no blood test by CHW
gen f_noactnotestchw =.
replace f_noactnotestchw = 0 if f_bloodtakenchw == 0 & f_chw == 1 & f_age >= 5 & f_nocare == 0
replace f_noactnotestchw = 1 if f_bloodtakenchw == 0 & f_chw == 1 & f_actchw != 1 & f_age >= 5 & f_nocare == 0
lab var f_noactnotestchw "No ACT from CHW, among those who did not get a blood test from CHW"
lab val f_noactnotestchw yn
tab f_noactnotestchw survey, col

*ACT, no blood test by CHW
gen f_actnotestchw =.
replace f_actnotestchw = 0 if f_bloodtakenchw == 0 & f_chw == 1 & f_age >= 5 & f_nocare == 0
replace f_actnotestchw = 1 if f_bloodtakenchw == 0 & f_chw == 1 & f_actchw == 1 & f_age >= 5 & f_nocare == 0
lab var f_actnotestchw "ACT from CHW, among those who did not get a blood test from CHW"
lab val f_actnotestchw yn
tab f_actnotestchw survey, col


***ACT treatment from CHW - confirmed  malaria + presumptive treatment
gen f_actochw = f_actcchw if f_age >= 5
replace f_actochw = f_actpchw if q816 == 14 & f_bloodtakenchw == 0 & f_age >= 5
replace f_actochw = 0 if f_actochw ==. & f_case == 1 & f_age >= 5
lab var f_actochw "ACT treatment by a CHW, presumptive + confirmed"
lab val f_actochw yn
tab f_actochw survey, col

***ACT within 24 hours from CHW 
gen f_act24chw = .
replace f_act24chw = 0 if f_case == 1 & f_age >= 5
replace f_act24chw = 1 if f_act == 1 & q816 == 14 & q817 < 2 & f_age >= 5
lab var f_act24chw "ACT treatment same or next day by a CHW, among all fever cases"
lab val f_act24chw yn
tab f_act24chw survey, col

gen f_act24chw2 = .
replace f_act24chw2 = 0 if f_chw == 1 & f_age >= 5
replace f_act24chw2 = 1 if f_act == 1 & q816 == 14 & q817 < 2 & f_chw == 1 & f_age >= 5
lab var f_act24chw2 "ACT treatment same or next day by a CHW, among those who sought care from a CHW"
lab val f_act24chw2 yn
tab f_act24chw2 survey, col

***ACT within 24 hours (same or next day), presumptive treatment by CHW
*gen f_act24pchw = 0 if f_chw == 1
gen f_act24pchw = 0 if f_bloodtaken == 0 & f_age >= 5
replace f_act24pchw = f_act24p if q816 == 14 & f_age >= 5
replace f_act24pchw = . if f_bloodtaken == 1
lab var f_act24pchw "ACT treatment same or next day by CHW, among all cases without a blood test"
lab val f_act24pchw yn
tab f_act24pchw survey, col

gen f_act24pchw2 = 0 if f_chw == 1 & f_age >= 5
replace f_act24pchw2 = f_act24p if q816 == 14 & f_age >= 5
replace f_act24pchw2 = . if f_bloodtaken == 1 
lab var f_act24pchw2 "ACT treatment same or next day by CHW, among cases without a blood test in which care was sought from CHW"
lab val f_act24pchw2 yn
tab f_act24pchw2 survey, col

***ACT within 24 hours (same or next day), confirmed malaria treatment by CHW
gen f_act24cchw = 0 if f_result == 1 & f_age >= 5
replace f_act24cchw = f_actcchw if q817 < 2 & f_age >= 5
lab var f_act24cchw "ACT treatment same or next day by CHW, among all cases with a positive blood test"
lab val f_act24cchw yn
tab f_act24cchw survey, col

***ACT within 24 hours (sam or next day), presumptive + confirmed treatment by CHW
gen f_act24ochw = f_act24cchw & f_age >= 5
replace f_act24ochw = f_act24pchw if f_case == 1 & f_act24ochw == . & f_age >= 5
tab f_act24ochw survey, col
lab var f_act24ochw "CT treatment same or next day by CHW, presumptive + confirmed"
lab val f_act24ochw yn
tab f_act24ochw survey, col

***ACT treatment with 24 hours from CHW - among those who sought care from a CHW and had positive blood test
gen f_act24cchw2 = .
replace f_act24cchw2 = 0 if f_chw == 1 & f_resultchw == 1 & f_age >= 5
replace f_act24cchw2 = 1 if f_act24cchw == 1 & f_chw == 1 & f_resultchw == 1 & survey == 2 & f_age >= 5
lab var f_act24cchw2 "ACT treatment same or next day by a CHW, among those who sought care from a CHW and had a positive blood test"
lab val f_act24cchw2 yn
tab f_act24cchw2 survey, col

***appropriate, timely fever treatment - ACT within 24 hours, confirmed malaria + presumptive HSA treatment at baseline (INDICATOR 13B)
gen f_act_app =.
replace f_act_app = f_act24c if f_age >= 5
replace f_act_app = f_act24pchw2 if f_act24pchw2 !=. & survey == 1 
lab var f_act_app "Appropriate and timely ACT treatment according to national policy"
lab val f_act_app yn
tab f_act_app survey, col

***appropriate, timely fever treatment by a CHW - ACT within 24 hours, presumptive at baseline, conformed at endline
gen f_act_appchw =.
replace f_act_appchw = f_act24cchw if survey == 2
replace f_act_appchw = f_act24pchw if survey == 1
replace f_act_appchw = . if f_act_app == .
replace f_act_appchw = 0 if f_act24c !=. & survey == 1
lab var f_act_appchw "Appropriate and timely ACT treatment by CHW according to national policy"
lab val f_act_appchw yn
tab f_act_appchw survey, col

gen f_act_appchw2 =.
replace f_act_appchw2 = f_act24cchw if survey == 2
replace f_act_appchw2 = f_act24pchw if survey == 1
replace f_act_appchw2 =. if f_chw != 1
lab var f_act_appchw2 "Appropriate and timely ACT treatment by CHW according to national policy, among those who sought care from HSA"
lab val f_act_appchw2 yn
tab f_act_appchw2 survey, col

*if from CHW, did child take ACT in presence of CHW? (INDICATOR 15B)
tab q819 survey
recode q819 2=0, gen(f_act_chwp)
lab val f_act_chwp yn
tab f_act_chwp survey, col

*if from CHW, did caregiver get counseled on how to give ACT at home? (INDICATOR 16B)
tab q820 survey
recode q820 2=0, gen(f_act_chwc)
lab val f_act_chwc yn
tab f_act_chwc survey, col

*if CHW visited, was available at first visit
tab q822 survey, col
recode q822 2=0, gen(f_chwavail)
lab val f_chwavail yn
tab f_chwavail survey, col 

*if CHW visited, did CHW refer the child to a health center?
tab q823 survey
recode q823 2=0, gen(f_chwrefer)
lab val f_chwrefer yn
tab f_chwrefer survey, col 

***completed referral by CHW (INDICATOR 17B)
tab q824 survey
recode q824 2=0, gen(f_referadhere)
lab val f_referadhere yn
tab f_referadhere survey, col

***reason did not comply with CHW referral
by survey: tab1 q825*

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
  replace `x' = 0 if `x' == . & q824 == 2
  lab val `x' yn
}

***CHW follow-up (INDICATOR 18B)
tab q826 survey
recode q826 2 8 =0, gen(f_chw_fu)
lab val f_chw_fu yn
tab f_chw_fu survey, col 

***when was CHW follow-up
tab q827 survey, col

*log close

*log using "fast_breathing_results", replace
***********************MODULE 9: Fast Breathing*********************************
*Age of children with fast breathing (not really needed)
recode fb_age min/23=1 24/60=2 98/99=.,gen (fb_agecat)

*sought any advice or treatment
tab q903 survey
recode q903 2 = 0
lab val q903 yn
tab q903 survey, col 

*did not seek care
tab q903
gen fb_nocare = .
replace fb_nocare = 0 if q903 == 1 & fb_case == 1
replace fb_nocare = 1 if q903 == 0 & fb_case == 1
lab var fb_nocare "Did not seek care for child with fast breathing"
lab val fb_nocare yn
tab fb_nocare survey, col

****reason did no seek care for cough/fast breathing (ENDLINE ONLY)
tab1 q925*
*See how many reasons were given since multiple responses were allowed
egen tot_q925 = rownonmiss(q925a-q925x),strok
replace tot_q925 = . if q903 != 0
replace tot_q925 = . if survey == 1
lab var tot_q925 "Number of reasons caregiver did not seek care"
tab tot_q925

encode q925a, gen(q925_a)
encode q925b, gen(q925_b)
encode q925c, gen(q925_c)
encode q925d, gen(q925_d)
encode q925e, gen(q925_e)
encode q925f, gen(q925_f)
encode q925g, gen(q925_g)
encode q925x, gen(q925_x)
encode q925z, gen(q925_z)

foreach x of varlist q925_* {
  replace `x' = 0 if `x' == . & fb_case == 1 & survey == 2 & q903 == 0
  lab val `x' yn
}

*decided to seek care jointly
tab q904 survey, col

*where care was sought
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
encode q906x, gen(q906_x)

foreach x of varlist q906_* {
  replace `x' = 0 if `x' == . & fb_case == 1 & q903 == 1
  lab val `x' yn
}

*total number of providers visited 
egen fb_provtot = rownonmiss(q906a-q906x),strok
replace fb_provtot = . if fb_case != 1
lab var fb_provtot "Total number of providers where sought care"
tab fb_provtot survey, col

*sought advice or treatment from an appropriate provider (INDICATOR 8C)
egen fb_apptot = rownonmiss(q906a-q906g),strok
replace fb_apptot = . if fb_case != 1
lab var fb_apptot "Total number of appropriate providers where sought care"
recode fb_apptot 1 2 3 = 1, gen(fb_app_prov)
lab var fb_app_prov "Sought care from 1+ appropriate provider"
lab val fb_app_prov yn 
tab fb_app_prov survey, col

***fever decided to seek care from an appropriate provider jointly with a partner (INDICATOR 21C, OPTIONAL)
gen fb_app_joint =.
replace fb_app_joint = 1 if fb_app_prov == 1 & q905a == "A" & union == 1 & fb_case == 1 & q903 == 1
replace fb_app_joint = 0 if fb_app_joint ==. & fb_case == 1 & union == 1
lab var fb_app_joint "Decided to seek care from appropriate provider jointly with partner"
lab val fb_app_joint yn
tab fb_app_joint survey, col

***fever decided to seek care from an appropriate provider jointly with a partner (INDICATOR 21C, OPTIONAL)
gen fb_joint =.
replace fb_joint = 1 if q905a == "A" & union == 1 & fb_case == 1 & q903 == 1
replace fb_joint = 0 if fb_joint ==. & fb_case == 1 & union == 1
lab var fb_joint "Decided to seek care jointly with partner"
lab val fb_joint yn
tab fb_joint survey, col

*careseeking locations
gen fb_cs_public = 1 if q906_a == 1 | q906_b == 1 | q906_c == 1 | q906_e == 1
gen fb_cs_private = 1 if q906_f == 1 | q906_g == 1 
gen fb_cs_chw = 1 if q906_d == 1
gen fb_cs_store = 1 if q906_h == 1 | q906_j == 1 | q906_l == 1
gen fb_cs_trad = 1 if q906_i == 1
gen fb_cs_other = 1 if q906_k == 1 | q906_x == 1

foreach x of varlist fb_cs_* {
  replace `x' = 0 if fb_case == 1 & q903 == 1 & `x' ==.
  lab val `x' yn
}

*visited an CHW
tab q906d survey, col
tab q908 survey, col
gen fb_chw = 1 if q906d == "D"
replace fb_chw = 0 if fb_chw ==. & fb_case == 1
lab var fb_chw "Sought care from CHW for cough/fast breathing"
lab val fb_chw yn
tab fb_chw survey, col

*did not seek care from a CHW
gen fb_nocarechw = .
replace fb_nocarechw = 0 if fb_case == 1 & q903 == 1
replace fb_nocarechw = 1 if q906d != "D" & q903 == 1 & fb_case == 1
lab var fb_nocarechw "Sought care for fast breathing - but not from CHW"
lab val fb_nocarechw yn
tab fb_nocarechw survey, col

*visited an CHW as first (*or only*) source of care (INDICATOR 9C)
gen fb_chwfirst = .
replace fb_chwfirst = 1 if q908 == "D"
replace fb_chwfirst = 1 if q906d == "D" & fb_provtot == 1
replace fb_chwfirst = 0 if fb_case == 1 & fb_chwfirst ==.
lab var fb_chwfirst "Sought care from CHW first"
lab val fb_chwfirst yn
tab fb_chwfirst survey, col

*visited an CHW as first (*or only*) source of care 
gen fb_chwfirst_anycare = .
replace fb_chwfirst_anycare = 0 if fb_case == 1 & q903 == 1
replace fb_chwfirst_anycare = 1 if q908 == "D"
replace fb_chwfirst_anycare = 1 if q906d == "D" & fb_provtot == 1
lab var fb_chwfirst_anycare "Sought care from CHW first among those who sought any care"
lab val fb_chwfirst_anycare yn
tab fb_chwfirst_anycare survey, col

*first source of care locations
gen fb_fcs_public = 1 if q908 == "A" | q908 == "B" | q908 == "C" | q908 == "E"
gen fb_fcs_private = 1 if q908 == "F" | q908 == "G" 
gen fb_fcs_chw = 1 if q908 == "D"
gen fb_fcs_store = 1 if q908 == "H" | q908 == "J" | q908 == "L"
gen fb_fcs_trad = 1 if q908 == "I"
gen fb_fcs_other = 1 if q908 == "K" | q908 == "X"

replace fb_fcs_public = 1 if (q906_a == 1 | q906_b == 1 | q906_c == 1 | q906_e == 1) & fb_provtot == 1
replace fb_fcs_private = 1 if (q906_f == 1 | q906_g == 1) & fb_provtot == 1
replace fb_fcs_chw = 1 if q906_d == 1 & fb_provtot == 1
replace fb_fcs_store = 1 if (q906_h == 1 | q906_j == 1 | q906_l == 1) & fb_provtot == 1
replace fb_fcs_trad = 1 if q906_i == 1 & fb_provtot == 1
replace fb_fcs_other = 1 if (q906_k == 1 | q906_x == 1) & fb_provtot == 1

foreach x of varlist fb_fcs_* {
  replace `x' = 0 if fb_case == 1 & q903 == 1 & `x' ==.
  lab val `x' yn
}

****reason(s) did not go to CHW for care (ENDLINE ONLY)
tab1 q908ba-q908bz
egen tot_q908b = rownonmiss(q908ba-q908bx),strok
replace tot_q908b = . if survey == 1
replace tot_q908b = . if q903 != 1
replace tot_q908b = . if q906d == "D"
lab var tot_q908b "Total number of reasons CG did not go to an CHW"
lab val tot_q908b yn
tab tot_q908b

encode q908ba, gen(q908b_a)
encode q908bb, gen(q908b_b)
encode q908bc, gen(q908b_c)
encode q908bd, gen(q908b_d)
encode q908be, gen(q908b_e)
encode q908bf, gen(q908b_f)
encode q908bx, gen(q908b_x)
encode q908bz, gen(q908b_z)

foreach x of varlist q908b_* {
  replace `x' = 0 if `x' == . & fb_case == 1 & survey == 2 & q903 == 1 & q906d != "D"
  lab val `x' yn
}

*assessed for fast breathing (INDICATOR 12)
tab q909 survey
recode q909 2 8 =0, gen(fb_assessed)
replace fb_assessed = 0 if fb_assessed ==. & fb_case == 1
lab var fb_assessed "Child assessed for fast breathing"
lab val fb_assessed yn
tab fb_assessed survey, col

* where was the assessment done?
by survey: tab1 q909aa-q909az

encode q909aa, gen(q909a_a)
encode q909ab, gen(q909a_b)
encode q909ac, gen(q909a_c)
encode q909ad, gen(q909a_d)

foreach x of varlist q909a_* {
  replace `x' = 0 if `x' ==. & q909 == 1
  lab val `x' yn
}

* who performed the assessment?
by survey: tab1 q910a-q910z 

encode q910a, gen(q910_a)
encode q910b, gen(q910_b)
encode q910c, gen(q910_c)
encode q910d, gen(q910_d)
encode q910e, gen(q910_e)
encode q910x, gen(q910_x)
encode q910z, gen(q910_z)

foreach x of varlist q910_* {
  replace `x' = 0 if `x' ==. & q909 == 1
  lab val `x' yn
}

*assessed for fast breathing during CHW visit (INDICATOR 12)
gen fb_assessedchw =.
replace fb_assessedchw = 0 if fb_chw == 1
replace fb_assessedchw = 1 if fb_assessed == 1 & q910_a == 1 & q909a_a == 1 & fb_chw == 1
lab var fb_assessedchw "Child assessed for fast breathing by CHW at a village clinic"
lab val fb_assessedchw yn
tab fb_assessedchw survey, col

gen fb_assessedchw2 =.
replace fb_assessedchw2 = 0 if fb_chw == 1
replace fb_assessedchw2 = 1 if fb_assessed == 1 & q910_a == 1 & fb_chw == 1
lab var fb_assessedchw2 "Child assessed for fast breathing by CHW"
lab val fb_assessedchw2 yn
tab fb_assessedchw2 survey, col

* received any treatment (INDICATOR 24, OPTIONAL)
by survey: tab1 q912*

encode q912a, gen(q912_a)
encode q912b, gen(q912_b)
encode q912c, gen(q912_c)
encode q912d, gen(q912_d)
encode q912e, gen(q912_e)
encode q912f, gen(q912_f)
encode q912g, gen(q912_g)
encode q912h, gen(q912_h)
encode q912x, gen(q912_x)
encode q912z, gen(q912_z)

foreach x of varlist q912_* {
  replace `x' = 0 if `x' ==. & q911 == 1
  lab val `x' yn
} 

egen fb_rxany = rownonmiss(q912a-q912h), strok
replace fb_rxany = 1 if fb_rxany > 0 & fb_rxany !=.
replace fb_rxany = . if fb_case != 1
lab var fb_rxany "Took any medication for fast breathing"
lab val fb_rxany yn
tab fb_rxany survey, col 

*treated with any antibiotic
gen fb_abany = .
replace fb_abany = 0 if fb_case == 1
replace fb_abany = 1 if q912d == "D" | q912e == "E" | q912f == "F"
lab val fb_abany yn
lab var fb_abany "Took any antibiotic for fast breathing"
tab fb_abany survey, col

* treated with first line antibiotics (INDICATOR 13D)
gen fb_flab = 1 if q912f == "F"
replace fb_flab = 0 if fb_flab ==. & fb_case == 1
replace fb_flab =. if fb_case != 1
lab var fb_flab "Took first line antibiotic for fast breathing"
lab val fb_flab yn
tab fb_flab survey, col

* treated with first line antibiotics by a CHW (INDICATOR 14D)
gen fb_flabchw = 0 if fb_case == 1
replace fb_flabchw = 1 if q912f == "F" & q914 == 14
replace fb_flabchw =. if fb_case != 1
lab var fb_flabchw "Got first line antibiotic for fast breathing from CHW"
lab val fb_flabchw yn
tab fb_flabchw survey, col

* treated with first line antibiotics by a CHW, among those who sought care from a CHW
gen fb_flabchw2 = .
replace fb_flabchw2 = 0 if fb_chw == 1
replace fb_flabchw2 = 1 if fb_flabchw == 1
lab var fb_flabchw2 "Got 1st line antibiotic from CHW, among those who sought care from CHW"
lab val fb_flabchw2 yn
tab fb_flabchw2 survey, col

* treated with any antibiotic among children who received any med (INDICATOR 25, OPTIONAL)
gen fb_ab =.
replace fb_ab = 0 if fb_rxany == 1
replace fb_ab = 1 if q912d == "D" | q912e == "E" | q912f == "F"
lab var fb_ab "Took antibiotic for fast breathing if received any med"
lab val fb_ab yn
tab fb_ab survey, col

*treated with firstline antibiotic by CHW with respiratory rate assessed
gen fb_flabchw_rr = 0 if fb_assessedchw == 0 & fb_flabchw == 1
replace fb_flabchw_rr = 1 if fb_assessedchw == 1 & fb_flabchw == 1

*treated with firstline antibiotic by CHW without respiratory rate assessed


*where did caregiver get the firstline antibiotic?
tab q914 survey, col

gen fb_flab_public = 1 if (q914 == 11 | q914 == 12 | q914 == 13 | q914 == 15) & fb_flab == 1
gen fb_flab_private = 1 if (q914 == 21 | q914 == 22) & fb_flab == 1
gen fb_flab_chw = 1 if q914 == 14 & fb_flab == 1
gen fb_flab_store = 1 if (q914 == 23 | q914 == 32 | q914 == 34) & fb_flab == 1
gen fb_flab_trad = 1 if q914 == 31 & fb_flab == 1
gen fb_flab_other = 1 if (q914 == 33 | q914 == 41) & fb_flab == 1

foreach x of varlist fb_flab_* {
  replace `x' = 0 if fb_case == 1 & fb_flab == 1 & `x' ==. & q914 !=.
  lab val `x' yn
}

*if from CHW, did child take antibiotic in presence of CHW? (INDICATOR 15C)
tab q916 survey
recode q916 2=0, gen(fb_flab_chwp)
***4 records that indicated firstline AB first dose was given in front of CHW, but not given firstline AB
replace fb_flab_chwp =. if q912f != "F"
lab val fb_flab_chwp yn
tab fb_flab_chwp survey, col 

*if from CHW, did caregiver get counseled on how to give antibiotic at home? (INDICATOR 16C)
tab q917 survey
recode q917 2=0, gen(fb_flab_chwc)
***4 records that indicated firstline AB first dose was given in front of CHW, but not given firstline AB
replace fb_flab_chwc =. if q912f != "F"
lab val fb_flab_chwc yn
tab fb_flab_chwc survey, col

*if CHW visited, was available at first visit
tab q919 survey
recode q919 2=0, gen(fb_chwavail)
lab val fb_chwavail yn
tab fb_chwavail survey, col

*if CHW visited, did CHW refer the child to a health center?
tab q920 survey
recode q920 2=0, gen(fb_chwrefer)
lab val fb_chwrefer yn
tab fb_chwrefer survey, col 

***completed CHW referral (INDICATOR 17C)
tab q921 survey
recode q921 2=0, gen(fb_referadhere)
lab val fb_referadhere yn
tab fb_referadhere survey, col

***reason did not comply with CHW referral
by survey: tab1 q922*

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

***CHW follow-up (INDICATOR 18C)
tab q923 survey
recode q923 2 8=0, gen(fb_chw_fu)
lab val fb_chw_fu yn
tab fb_chw_fu survey, col

***when was CHW follow-up
tab q924 survey, col

*log close

*log using "endline_sex_results", replace

********************************************************************************
********************************************************************************
*Key endline indicators, disaggregated by sex
********DIARRHEA
*Sought any care
svyset hhclust
svy: tab q703 d_sex if survey == 2, col

*Sought care from an appropriate provider
svy: tab d_app_prov d_sex if survey == 2, col

*Sought care from a CHW
svy: tab d_chw d_sex if survey == 2, col

*CHW was first source of care
svy: tab d_chwfirst d_sex if survey == 2, col

*Same or more to drink
svy: tab d_cont_fluids d_sex if survey == 2, col

*Took ORS
svy: tab d_ors d_sex if survey == 2, col

*Took zinc
svy: tab d_zinc d_sex if survey == 2, col

*Took homemade fluid
***NOT in Malawi survey

*Took ORS and zinc
svy: tab d_orszinc d_sex if survey == 2, col

********FEVER
*Sought any care
svy: tab q803 f_sex if survey == 2, col

*Sought care from an appropriate provider
svy: tab f_app_prov f_sex if survey == 2, col

*Sought care from a CHW
svy: tab f_chw f_sex if survey == 2, col

*CHW was first source of care
svy: tab f_chwfirst f_sex if survey == 2, col

*Had blood drawn
svy: tab f_bloodtaken f_sex if survey == 2, col

*Got test results
svy: tab f_gotresult f_sex if survey == 2, col

*Test results positive
svy: tab f_result f_sex if survey == 2, col

*Any antimalarial
svy: tab f_antim f_sex if survey == 2, col

*Any antimalarial - confirmed malaria
svy: tab f_antimc f_sex if survey == 2, col

*ACT
svy: tab f_act f_sex if survey == 2, col

*ACT - confirmed malaria
svy: tab f_actc f_sex if survey == 2, col

*ACT within 24 hours
svy: tab f_act24 f_sex if survey == 2, col

*ACT within 24 hours - confirmed malaria
svy: tab f_act24c f_sex if survey == 2, col

*******FAST BREATHING
*Sought any care
svy: tab q903 fb_sex if survey == 2, col

*Sought care from an appropriate provider
svy: tab fb_app_prov fb_sex if survey == 2, col

*Sought care from a CHW
svy: tab fb_chw fb_sex if survey == 2, col

*CHW was first source of care
svy: tab fb_chwfirst fb_sex if survey == 2, col

*Had breathing assessed
svy: tab fb_assessed fb_sex if survey == 2, col

*Took any antibiotic
svy: tab fb_abany fb_sex if survey == 2, col

*Took firstline antibiotic
svy: tab fb_flab fb_sex if survey == 2, col

save "cg_combined_hh_roster_FINAL60FEB9 post.dta", replace

*log close

*log using "endline_overall_results", replace

********************************************************************************
********************************************************************************
*Overall indicators across all three illnesses
*First create a variable in the final analysis file to indicate that will be used to indicate the illness
*Used the variable "set" and created three separate files
*SET: 1 = diarrhea, 2 = fever, and 3 = fast breathing.
use "cg_combined_hh_roster_FINAL60FEB9 post.dta", clear
gen set = 1
save "cg_combined_hh_roster_FINAL60FEB9 post1.dta", replace
replace set = 2
save "cg_combined_hh_roster_FINAL60FEB9 post2.dta", replace
replace set = 3
save "cg_combined_hh_roster_FINAL60FEB9 post3.dta", replace

*In the diarrhea file, drop any caregiver records without a child who had diarrhea
use "cg_combined_hh_roster_FINAL60FEB9 post1.dta", clear
tab d_case
drop if d_case != 1
save "cg_combined_hh_roster_FINAL60FEB9 post1.dta", replace

*In the fever file, drop any caregiver records without a child who had fever
use "cg_combined_hh_roster_FINAL60FEB9 post2.dta", clear
tab f_case
drop if f_case != 1
save "cg_combined_hh_roster_FINAL60FEB9 post2.dta", replace

*In the fast breathing file, drop any caregiver records without a child who had fast breathing
use "cg_combined_hh_roster_FINAL60FEB9 post3.dta", clear
tab fb_case
drop if fb_case != 1
save "cg_combined_hh_roster_FINAL60FEB9 post3.dta", replace

*Append the three illness files together & save the resulting file
use "cg_combined_hh_roster_FINAL60FEB9 post1.dta", clear
append using "cg_combined_hh_roster_FINAL60FEB9 post2.dta", nolabel
append using "cg_combined_hh_roster_FINAL60FEB9 post3.dta", nolabel
save "cg_combined_hh_roster_FINAL60FEB9 post all.dta", replace

***Calculate each of the key indicators across all three illnesses
*care-seeking from an appropriate provider, all 3 illnesses
gen all_app_prov = 0
replace all_app_prov = 1 if (set == 1 & d_app_prov == 1) | (set == 2 & f_app_prov == 1) | (set == 3 & fb_app_prov == 1)

*CHW first source of care, all 3 illnesses
gen all_chwfirst = 0
replace all_chwfirst = 1 if (set == 1 & d_chwfirst == 1) | (set == 2 & f_chwfirst == 1) | (set == 3 & fb_chwfirst == 1)

*Correct treatment, all 3 illnesses - presumptive fever treatment from HSAs at baseline
***This includes confirmed cases of malaria within 24 hours and presumptive treatment by CHWs at BL
gen all_correct_rx = 0 if set == 1 | (set == 2 & f_act_app !=.) | set == 3 
replace all_correct_rx = 1 if (set == 1 & d_orszinc == 1) | (set == 2 & f_act_app == 1) | (set == 3 & fb_flab == 1)

*Correct treatment from a CHW, all 3 illnesses
***This includes confirmed cases of malaria within 24 hours, does not include presumptive treatment by CHWs at BL
gen all_correct_rxchw = 0 if set == 1 | (set == 2 & f_act_appchw !=.) | set == 3
replace all_correct_rxchw = 1 if (set == 1 & d_orszincchw == 1) | (set == 2 & f_act_appchw == 1) | (set == 3 & fb_flabchw == 1)

*Received 1st dose treatment in front of CHW, all 3 illnesses
gen all_firstdose = .
replace all_firstdose = 0 if (q711==14 & q716==14 & set == 1 ) | (q816==14 & set == 2) | (q914==14 & set == 3 & fb_flabchw == 1)
replace all_firstdose = 1 if (set == 1 & q711==14 & d_ors_chwp==1 & q716==14 & d_zinc_chwp==1) | (set == 2 & q816==14 & f_act_chwp==1) | (set == 3 & q914 ==14 & fb_flab_chwp==1)

*Received counseling on treatment administration from CHW, all 3 illnesses
gen all_counsel = .
replace all_counsel = 0 if (q711==14 & q716==14 & set == 1 ) | (q816==14 & set == 2) | (q914==14 & set == 3 & fb_flabchw == 1)
replace all_counsel = 1 if (set == 1 & q711==14 & d_ors_chwc==1 & q716==14 & d_zinc_chwc==1) | (set == 2 & q816==14 & f_act_chwc==1) | (set == 3 & q914 ==14 & fb_flab_chwc==1)

*Adhered to referral advice from CHW, all 3 illnesses
gen all_referadhere = .
replace all_referadhere = 0 if (d_chwrefer == 1 & set == 1 ) | (f_chwrefer == 1 & set == 2) | (fb_chwrefer == 1 & set == 3)
replace all_referadhere = 1 if (set == 1 & d_referadhere==1) | (set == 2 & f_referadhere== 1) | (set == 3 & fb_referadhere== 1)

*Received a follow-up visit from a CHW, all 3 illnesses
gen all_followup = .
replace all_followup = 0 if (d_chw_fu !=. & set == 1 ) | (f_chw_fu !=. & set == 2) | (fb_chw_fu !=. & set == 3)
replace all_followup = 1 if (set == 1 & d_chw == 1 & d_chw_fu == 1) | (set == 2 & f_chw == 1 & f_chw_fu == 1) | (set == 3 & fb_chw == 1 & fb_chw_fu == 1)

*decided to seek care from an appropriate provider jointly with partner, all 3 illnesses
gen all_app_joint = .
replace all_app_joint = 0 if union == 1
replace all_app_joint = 1 if (set == 1 & d_app_joint == 1) | (set == 2 & f_app_joint == 1) | (set == 3 & fb_app_joint == 1)

*decided to seek care jointly with partner, all 3 illnesses
gen all_joint = .
replace all_joint = 0 if union == 1
replace all_joint = 1 if (set == 1 & d_joint == 1) | (set == 2 & f_joint == 1) | (set == 3 & fb_joint == 1)

*did not seek care, all 3 illnesses
gen all_nocare = 0
replace all_nocare = 1 if (set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1)

*sought care but not from a CHW, all 3 illnesses
gen all_nocarechw = .
replace all_nocarechw = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_nocarechw = 1 if (set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1)

*where sought care first, all 3 illnesses
gen all_fcs_public = .
replace all_fcs_public = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_public = 1 if (set == 1 & d_fcs_public == 1) | (set == 2 & f_fcs_public == 1) | (set == 3 & fb_fcs_public == 1)

gen all_fcs_private = .
replace all_fcs_private = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_private = 1 if (set == 1 & d_fcs_private == 1) | (set == 2 & f_fcs_private == 1) | (set == 3 & fb_fcs_private == 1)

gen all_fcs_chw = .
replace all_fcs_chw = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_chw = 1 if (set == 1 & d_fcs_chw == 1) | (set == 2 & f_fcs_chw == 1) | (set == 3 & fb_fcs_chw == 1)

gen all_fcs_store = .
replace all_fcs_store = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_store = 1 if (set == 1 & d_fcs_store == 1) | (set == 2 & f_fcs_store == 1) | (set == 3 & fb_fcs_store == 1)

gen all_fcs_trad = .
replace all_fcs_trad = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_trad = 1 if (set == 1 & d_fcs_trad == 1) | (set == 2 & f_fcs_trad == 1) | (set == 3 & fb_fcs_trad == 1)

gen all_fcs_other = .
replace all_fcs_other = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_other = 1 if (set == 1 & d_fcs_other == 1) | (set == 2 & f_fcs_other == 1) | (set == 3 & fb_fcs_other == 1)

*sources of care, all 3 illnesses
gen all_cs_public = .
replace all_cs_public = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_public = 1 if (set == 1 & d_cs_public == 1) | (set == 2 & f_cs_public == 1) | (set == 3 & fb_cs_public == 1)

gen all_cs_private = .
replace all_cs_private = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_private = 1 if (set == 1 & d_cs_private == 1) | (set == 2 & f_cs_private == 1) | (set == 3 & fb_cs_private == 1)

gen all_cs_chw = .
replace all_cs_chw = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_chw = 1 if (set == 1 & d_cs_chw == 1) | (set == 2 & f_cs_chw == 1) | (set == 3 & fb_cs_chw == 1)

gen all_cs_store = .
replace all_cs_store = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_store = 1 if (set == 1 & d_cs_store == 1) | (set == 2 & f_cs_store == 1) | (set == 3 & fb_cs_store == 1)

gen all_cs_trad = .
replace all_cs_trad = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_trad = 1 if (set == 1 & d_cs_trad == 1) | (set == 2 & f_cs_trad == 1) | (set == 3 & fb_cs_trad == 1)

gen all_cs_other = .
replace all_cs_other = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_other = 1 if (set == 1 & d_cs_other == 1) | (set == 2 & f_cs_other == 1) | (set == 3 & fb_cs_other == 1)

*source of treatment, all 3 illnesses
gen all_rx_public = .
replace all_rx_public = 0 if (set == 1 & (d_ors == 1 | d_zinc ==1)) | (set == 2 & f_act == 1) | (set == 3 & fb_flab == 1)
replace all_rx_public = 1 if (set == 1 & (d_ors_public == 1 | d_zinc_public == 1)) | (set == 2 & f_act_public == 1) | (set == 3 & fb_flab_public == 1)

gen all_rx_private = .
replace all_rx_private = 0 if (set == 1 & (d_ors == 1 | d_zinc ==1)) | (set == 2 & f_act == 1) | (set == 3 & fb_flab == 1)
replace all_rx_private = 1 if (set == 1 & (d_ors_private == 1 | d_zinc_private == 1)) | (set == 2 & f_act_private == 1) | (set == 3 & fb_flab_private == 1)

gen all_rx_chw = .
replace all_rx_chw = 0 if (set == 1 & (d_ors == 1 | d_zinc ==1)) | (set == 2 & f_act == 1) | (set == 3 & fb_flab == 1)
replace all_rx_chw = 1 if (set == 1 & (d_ors_chw == 1 | d_zinc_chw == 1)) | (set == 2 & f_act_chw == 1) | (set == 3 & fb_flab_chw == 1)

gen all_rx_store = .
replace all_rx_store = 0 if (set == 1 & (d_ors == 1 | d_zinc ==1)) | (set == 2 & f_act == 1) | (set == 3 & fb_flab == 1)
replace all_rx_store = 1 if (set == 1 & (d_ors_store == 1 | d_zinc_store == 1)) | (set == 2 & f_act_store == 1) | (set == 3 & fb_flab_store == 1)

gen all_rx_trad = .
replace all_rx_trad = 0 if (set == 1 & (d_ors == 1 | d_zinc ==1)) | (set == 2 & f_act == 1) | (set == 3 & fb_flab == 1)
replace all_rx_trad = 1 if (set == 1 & (d_ors_trad == 1 | d_zinc_trad == 1)) | (set == 2 & f_act_trad == 1) | (set == 3 & fb_flab_trad == 1)

gen all_rx_other = .
replace all_rx_other = 0 if (set == 1 & (d_ors == 1 | d_zinc ==1)) | (set == 2 & f_act == 1) | (set == 3 & fb_flab == 1)
replace all_rx_other = 1 if (set == 1 & (d_ors_other == 1 | d_zinc_other == 1)) | (set == 2 & f_act_other == 1) | (set == 3 & fb_flab_other == 1)

*reasons for not complying with CHW referral
gen all_noadhere_a = .
replace all_noadhere_a = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_a = 1 if (set == 1 & q727_a == 1) | (set == 2 & q825_a == 1) | (set == 3 & q922_a == 1)

gen all_noadhere_b = .
replace all_noadhere_b = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_b = 1 if (set == 1 & q727_b == 1) | (set == 2 & q825_b == 1) | (set == 3 & q922_b == 1)

gen all_noadhere_c = .
replace all_noadhere_c = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_c = 1 if (set == 1 & q727_c == 1) | (set == 2 & q825_c == 1) | (set == 3 & q922_c == 1)

gen all_noadhere_d = .
replace all_noadhere_d = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_d = 1 if (set == 1 & q727_d == 1) | (set == 2 & q825_d == 1) | (set == 3 & q922_d == 1)

gen all_noadhere_e = .
replace all_noadhere_e = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_e = 1 if (set == 1 & q727_e == 1) | (set == 2 & q825_e == 1) | (set == 3 & q922_e == 1)

gen all_noadhere_f = .
replace all_noadhere_f = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_f = 1 if (set == 1 & q727_f == 1) | (set == 2 & q825_f == 1) | (set == 3 & q922_f == 1)

gen all_noadhere_g = .
replace all_noadhere_g = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_g = 1 if (set == 1 & q727_g == 1) | (set == 2 & q825_g == 1) | (set == 3 & q922_g == 1)

gen all_noadhere_h = .
replace all_noadhere_h = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_h = 1 if (set == 1 & q727_h == 1) | (set == 2 & q825_h == 1) | (set == 3 & q922_h == 1)

gen all_noadhere_x = .
replace all_noadhere_x = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_x = 1 if (set == 1 & q727_x == 1) | (set == 2 & q825_x == 1) | (set == 3 & q922_x == 1)

gen all_noadhere_z = .
replace all_noadhere_z = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_z = 1 if (set == 1 & q727_z == 1) | (set == 2 & q825_z == 1) | (set == 3 & q922_z == 1)

*When was CHW follow-up?
gen all_when_fu = .
replace all_when_fu = q729 if q728 == 1 & set == 1
replace all_when_fu = q827 if q826 == 1 & set == 2
replace all_when_fu = q924 if q923 == 1 & set == 3

*reasons for not seeking care, endline only
gen all_nocare_a = .
replace all_nocare_a = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_a = 1 if (set == 1 & q708c_a == 1) | (set == 2 & q828_a == 1) | (set == 3 & q925_a == 1)

gen all_nocare_b = .
replace all_nocare_b = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_b = 1 if (set == 1 & q708c_b == 1) | (set == 2 & q828_b == 1) | (set == 3 & q925_b == 1)

gen all_nocare_c = .
replace all_nocare_c = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_c = 1 if (set == 1 & q708c_c == 1) | (set == 2 & q828_c == 1) | (set == 3 & q925_c == 1)

gen all_nocare_d = .
replace all_nocare_d = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_d = 1 if (set == 1 & q708c_d == 1) | (set == 2 & q828_d == 1) | (set == 3 & q925_d == 1)

gen all_nocare_e = .
replace all_nocare_e = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_e = 1 if (set == 1 & q708c_e == 1) | (set == 2 & q828_e == 1) | (set == 3 & q925_e == 1)

gen all_nocare_f = .
replace all_nocare_f = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_f = 1 if (set == 1 & q708c_f == 1) | (set == 2 & q828_f == 1) | (set == 3 & q925_f == 1)

gen all_nocare_g = .
replace all_nocare_g = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_g = 1 if (set == 1 & q708c_g == 1) | (set == 2 & q828_g == 1) | (set == 3 & q925_g == 1)

gen all_nocare_x = .
replace all_nocare_x = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_x = 1 if (set == 1 & q708c_x == 1) | (set == 2 & q828_x == 1) | (set == 3 & q925_x == 1)

gen all_nocare_z = .
replace all_nocare_z = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_z = 1 if (set == 1 & q708c_z == 1) | (set == 2 & q828_z == 1) | (set == 3 & q925_z == 1)

*reasons for not seeking care from a CHW among those who sought care, endline only
gen all_nocarechw_a = .
replace all_nocarechw_a = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
replace all_nocarechw_a = 1 if (set == 1 & q708b_a == 1) | (set == 2 & q808b_a == 1) | (set == 3 & q908b_a == 1)

gen all_nocarechw_b = .
replace all_nocarechw_b = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
replace all_nocarechw_b = 1 if (set == 1 & q708b_b == 1) | (set == 2 & q808b_b == 1) | (set == 3 & q908b_b == 1)

gen all_nocarechw_c = .
replace all_nocarechw_c = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
replace all_nocarechw_c = 1 if (set == 1 & q708b_c == 1) | (set == 2 & q808b_c == 1) | (set == 3 & q908b_c == 1)

gen all_nocarechw_d = .
replace all_nocarechw_d = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
replace all_nocarechw_d = 1 if (set == 1 & q708b_d == 1) | (set == 2 & q808b_d == 1) | (set == 3 & q908b_d == 1)

gen all_nocarechw_e = .
replace all_nocarechw_e = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
replace all_nocarechw_e = 1 if (set == 1 & q708b_e == 1) | (set == 2 & q808b_e == 1) | (set == 3 & q908b_e == 1)

gen all_nocarechw_f = .
replace all_nocarechw_f = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
replace all_nocarechw_f = 1 if (set == 1 & q708b_f == 1) | (set == 2 & q808b_f == 1) | (set == 3 & q908b_f == 1)

*gen all_nocarechw_g = .
*replace all_nocarechw_g = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
*replace all_nocarechw_g = 1 if (set == 1 & q708b_g == 1) | (set == 2 & q808b_g == 1) | (set == 3 & q908b_g == 1)

gen all_nocarechw_x = .
replace all_nocarechw_x = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
replace all_nocarechw_x = 1 if (set == 1 & q708b_x == 1) | (set == 2 & q808b_x == 1) | (set == 3 & q908b_x == 1)

gen all_nocarechw_z = .
replace all_nocarechw_z = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
replace all_nocarechw_z = 1 if (set == 1 & q708b_z == 1) | (set == 2 & q808b_z == 1) | (set == 3 & q908b_z == 1)

*Correct treatment, all 3 illnesses - positive blood test only
***This includes confirmed cases of malaria within 24 hours only
gen all_correct_rxc = 0
replace all_correct_rxc = 1 if (set == 1 & d_orszinc == 1) | (set == 2 & f_act24c == 1) | (set == 3 & fb_flab == 1)

*Correct treatment from a CHW, all 3 illnesses
***This includes confirmed cases of malaria within 24 hours only
gen all_correct_rxchwc = 0
replace all_correct_rxchwc = 1 if (set == 1 & d_orszincchw == 1) | (set == 2 & f_act_appchw == 1) | (set == 3 & fb_flabchw == 1)

*CHW first source of care among those who sought any care, all 3 illnesses
gen all_chwfirst_anycare = .
replace all_chwfirst_anycare = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_chwfirst_anycare = 1 if (set == 1 & d_chwfirst_anycare == 1) | (set == 2 & f_chwfirst_anycare == 1) | (set == 3 & fb_chwfirst_anycare == 1)

*Correct treatment from a CHW, all 3 illnesses
***This includes presumptive tx at BL and confirmed tx at endline
gen all_correct_rxchw2 = .
replace all_correct_rxchw2 = 0 if (set == 1 & d_chw == 1) | (set == 2 & f_act_appchw2 !=. ) | (set == 3 & fb_chw == 1)
replace all_correct_rxchw2 = 1 if (set == 1 & d_orszincchw2 == 1) | (set == 2 & f_act_appchw2 == 1) | (set == 3 & fb_flabchw2 == 1)

*Referral advice from CHW, all 3 illnesses
gen all_chwrefer = .
replace all_chwrefer = 0 if (d_chwrefer !=. & set == 1 ) | (f_chwrefer !=. & set == 2) | (fb_chwrefer !=. & set == 3)
replace all_chwrefer = 1 if (set == 1 & d_chwrefer==1) | (set == 2 & f_chwrefer== 1) | (set == 3 & fb_chwrefer== 1)

foreach x of varlist all* {
  tab `x' survey, col
}

save "cg_combined_hh_roster_FINAL60FEB9 post all2", replace

*log close
