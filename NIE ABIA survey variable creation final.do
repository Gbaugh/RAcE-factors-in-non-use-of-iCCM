*******************************************
* SFH BASELINE/ENDLINE HH SURVEY ANALYSIS *
* Variable Creation do file               *
* By: Samantha Herrera                    *
* March 2017                              *
*******************************************

cd "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Nigeria - SFH\Data analysis"
set more off

use "cg_combined_hh_roster_final.dta", clear

*Create a value label for binary variables that are recoded 0/1
lab define yn 0 "No" 1 "Yes"

*Define survey parameters that account for the cluster variable
svyset hhclust

*Dropped two observations - one that had no sick child and one that had no data beyond Mod 1
*1st dropped observation was in survey 2, hhcluster 22 hhnumber 16 (no observations beyond Mod 1)
*2nd dropped observation was in survey 2, hhcluster 1 hhnumber 6 (no sick child)
****************MODULE 1: Sick child information********************************
*Sex, age and 2-week history of illness of selected children
***In a different do file

*Create binary variable = child has illness from line number variable
recode q7child 1 2 3 4 6 =1 0=0, gen(d_case)
recode q8child 1 2 3 4 5 6 =1 0=0, gen(f_case)
recode q9child 1 2 3 4 5 6 =1 0=0, gen(fb_case)

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
g cagecat = .
replace cagecat = 1 if q202>=15 & q202<=24
replace cagecat = 2 if q202>=25 & q202<=34
replace cagecat = 3 if q202>=35 & q202<=44
replace cagecat = 4 if q202>=45 & q202<=98
*imputed missing to category 2 which had the majority
replace cagecat = 2 if q202==99
lab var cagecat "Caregiver's age category"
lab define cagecat 1 "15-24" 2 "25-34" 3 "35-44" 4 "45+"
lab values cagecat cagecat

*Caregivers' education
*Only one response in Higher so recoding into different categories
tab q203 survey
tab q204 survey
tab q205 survey
gen cgeduccat = 0 if q203 == 2| q203==9
replace cgeduccat = 1 if q204 == 1 
replace cgeduccat = 2 if q204 == 2 | q204 == 3
lab var cgeduccat "Caregiver's highest level of education"
lab define cgeduccat 0 "No school" 1 "Primary " 2 "Secondary or higher"
lab val cgeduccat cgeduccat
lab var cgeduccat "Caregiver's education"

*Caregivers' marital status (2 categories)
gen maritalstat = .
replace maritalstat = 1 if q401==1|q401==2
replace maritalstat = 2 if q401==3
lab var maritalstat "Caregiver's maritalstatus"
lab def maritalstat 1 "married/living with partner as married" 2 "not in union"
lab val maritalstat maritalstat

****************MODULE 5: Health center access**********************************
*caregiver access to nearest facility* - need SFH to confirm miles vs km
by survey:sum q501
*hist q501
recode q501 min/3=1 4/9=2 10/19=3 20/50=4 98=5 99=.,gen(distcat)
lab var distcat "Distance to nearest health center"
lab define distance 1 "<5 km" 2 "5-15 km" 3 "16-30 km" 4 "30+ km" 5 "don't know", modify
lab values distcat distance

*caregiver's mode of transport
tab q502 survey
recode q502 2=1 3 4 5=2 6=3 1=.,gen(transport)
lab def trans 1 "Walk" 2 "Motorbike/Bus/Taxi" 3 "Other"
lab val transport trans
lab var transport "mode of transport"

*caregiver's time to travel to nearest facility*
by survey: sum q503
*note, coded missing as don't know
recode q503 min/29=1 30/59=2 60/119=3 120/240=4 998/999=5,gen(timecat)
lab var timecat "Time to reach nearest health center"
lab def timecat 1 "<30 minutes" 2 "30-59 minutes" 3 "1 - <2 hours" 4 "2+ hours" 5 "don't know", modify
lab val timecat timecat

*caregiver's time to travel to nearest facility, among only those who walk*
by survey: sum q503
*note, coded missing as don't know
recode q503 min/29=1 30/59=2 60/119=3 120/240=4 998/999=5,gen(timewalk)
replace timewalk = . if q502 != 2
lab var timewalk "Time to reach nearest health center among those who walk"
lab val timewalk timecat


****************MODULE 4: Household decision making*****************************
*Caregiver living with partner
gen cg_livepart =.
replace cg_livepart = 0 if q402==2
replace cg_livepart = 1 if q402==1
replace cg_livepart = 9 if q402==9
lab var cg_livepart "caregiver lives w/partner"
lab def cg_livepart 0 "no" 1 "yes" 9 "missing"
lab val cg_livepart cg_livepart

*Income decision maker (INDICATOR 19, OPTIONAL)
tab q403 survey
recode q403 6 = 4,gen(dm_income)
lab var dm_income "Household income decision maker"
lab def dm_income 1 "respondent" 2 "husband/partner" 3 "respondent and husband/partner jointly" 4 "other" 9 "missing"
*recoded 2 missing responses as joint decision-making (majority response)
recode dm_income 9=3
lab val dm_income dm_income
tab dm_income survey, col

recode dm_income 1 2 4=0 3=1, gen(dm_income_joint)
lab var dm_income_joint "Caregiver makes HH income decisions jointly with partner"
lab val dm_income_joint yn
*recoded 2 missing responses as no
recode dm_income_joint 9=0
tab dm_income_joint survey, col

*Health care decision maker (INDICATOR 20, OPTIONAL)
tab q404 survey, col 
recode q404 6 = 4, gen(dm_health)
lab var dm_health "Household health care decision maker"
lab def dm_health 1 "respondent" 2 "husband/partner" 3 "respondent and husband/partner jointly" 4 "other" 9 "missing"
*recoded 2 missing responses at joint decision-making (majority response)
recode dm_health 9 = 3
lab val dm_health dm_health
tab dm_health survey, col

recode dm_health 1 2 4=0 3=1, gen(dm_health_joint)
lab var dm_health_joint "Caregiver makes healthcare decisions jointly with partner"
lab val dm_health_joint yn

****************MODULE 6: Caregiver illness knowledge***************************
*Child illness signs (Q601a-Q601p, Q601z = don't know)
by survey: tab1 q601*

*Note - return, need to update coding since it doesn't align across baseline and endline

*child under 2 months 
gen Q601a =0
replace Q601a = 1 if q601a=="A"

*fever
gen Q601b = 0
replace Q601b = 1 if (q601b=="B" & survey==2)

*high fever
gen Q601c = 0
replace Q601c = 1 if (q601b=="B" & survey==1)
replace Q601c = 1 if (q601c=="C" & survey==2)

*Fever for 7 days or more
gen Q601d = 0
replace Q601d = 1 if (q601c=="C" & survey==1)
replace Q601d = 1 if (q601d=="D" & survey==2)

*Diarrhea
gen Q601e = 0
replace Q601e = 1 if (q601e=="E" & survey==2)

*Diarrhea w/blood in stool
gen Q601f = 0
replace Q601f = 1 if (q601d=="D" & survey==1)
replace Q601f = 1 if (q601f=="F" & survey==2)

*Diarrhea with dehydration
gen Q601g = 0
replace Q601g = 1 if (q601e=="E" & survey==1)
replace Q601g = 1 if (q601g=="G" & survey==2)

*Diarrhea for 14+ days
gen Q601h = 0
replace Q601h = 1 if (q601f=="F" & survey==1)
replace Q601h = 1 if (q601h=="H" & survey==2)

*fast or difficult breathing
gen Q601i = 0
replace Q601i = 1 if (q601g=="G" & survey==1)
replace Q601i = 1 if (q601i=="I" & survey==2)

*chest in-drawing
gen Q601j = 0
replace Q601j = 1 if (q601g=="G" & survey==1)
replace Q601j = 1 if (q601j=="J" & survey==2)

*Cough
gen Q601k = 0
replace Q601k = 1 if (q601k=="K" & survey==2)

*Cough for 21+ days
gen Q601l = 0
replace Q601l = 1 if (q601h=="H" & survey==1)
replace Q601l = 1 if (q601l=="L" & survey==2)

*refusal to bf
gen Q601m = 0
replace Q601m = 1 if (q601i=="I" & survey==1)
replace Q601m = 1 if (q601m=="M" & survey==2)

*not able to drink or feed
gen Q601n = 0
replace Q601n = 1 if (q601j=="J" & survey==1)
replace Q601n = 1 if (q601n=="N" & survey==2)

*Vomiting everything
gen Q601o = 0
replace Q601o = 1 if (q601k=="K" & survey==1)
replace Q601o = 1 if (q601o=="O" & survey==2)

*Yellow/red MUAC or swelling of both feet
gen Q601p = 0
replace Q601p = 1 if (q601l=="L" & survey==1)
replace Q601p = 1 if (q601p=="P" & survey==2)

*convulsions
gen Q601q = 0
replace Q601q = 1 if (q601m=="M" & survey==1)
replace Q601q = 1 if (q601q=="Q" & survey==2)

*loss of consciousness
gen Q601r = 0
replace Q601r = 1 if (q601n=="N" & survey==1)
replace Q601r = 1 if (q601r=="R" & survey==2)

*Lethargic/tired/slow to respond/doesn't want to play
gen Q601s = 0
replace Q601s = 1 if (q601o=="O" & survey==1)
replace Q601s = 1 if (q601s=="S" & survey==2)

*Stiff neck
gen Q601t = 0
replace Q601t = 1 if (q601p=="P" & survey==1)
replace Q601t = 1 if (q601t=="T" & survey==2)

*don't know
gen Q601z = 0
replace Q601z = 1 if (q601z=="Z" & survey==1)
replace Q601z = 1 if (q601z=="Z" & survey==2)
 
*Create a variable = total number of illness signs caregiver knows
egen tot_q601 = anycount(Q601a-Q601t), values(1)
lab var tot_q601 "Total number of illness signs CG knows"

/*encode Q601a, gen(q601_a)
encode Q601b, gen(q601_b)
encode Q601c, gen(q601_c)
encode Q601d, gen(q601_d)
encode Q601e, gen(q601_e)
encode Q601f, gen(q601_f)
encode Q601g, gen(q601_g)
encode Q601h, gen(q601_h)
encode Q601i, gen(q601_i)
encode Q601j, gen(q601_j)
encode Q601k, gen(q601_k)
encode Q601l, gen(q601_l)
encode Q601m, gen(q601_m)
encode Q601n, gen(q601_n)
encode Q601o, gen(q601_o)
encode Q601p, gen(q601_p)
encode Q601q, gen(q601_q)
encode Q601r, gen(q601_r)
encode Q601s, gen(q601_s)
encode Q601t, gen(q601_t)
encode Q601z, gen(q601_z)

foreach x of varlist Q601* {
  replace `x' = 0 if `x' == .
  lab val `x' yn
  }
*/
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
*/

*Knowledge of malaria (not an indicator)
*recoded don't know and missing responses as no
recode q602 8 9 =2
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

*Knowledge of at least 2 symptoms of malaria 
egen tot_q604 = rownonmiss(q604a-q604i), strok
lab var tot_q604 "Total number of malaria signs CG knows"
gen malaria_signs2 = .
replace malaria_signs2 = 0 if q602 !=.
replace malaria_signs2 = 1 if tot_q604 >=2
lab var malaria_signs2 "Caregiver knows 2+ signs of malaria"
lab val malaria_signs2 yn
tab malaria_signs2 survey, col

***Knowledge of correct treatment for malaria, ACT 
gen malaria_rx = .
replace malaria_rx = 0 if q602 !=.
replace malaria_rx = 1 if q605 == 1 
lab var malaria_rx "Caregiver knows correct malaria treatment"
lab val malaria_rx yn
tab malaria_rx survey, col

***Knowledge of correct management for diarrhea (ORS + zinc) 
*coded differently in baseline (numeric) and endline (alphabetic - option b is ors and zinc)
gen diarrhea_rx = 0 
replace diarrhea_rx = 1 if (q607==2 & survey==1) | (q607b=="B" & survey==2)
lab var diarrhea_rx "Caregiver knows correct management of diarrhea"
lab val diarrhea_rx yn
tab diarrhea_rx survey, col

****************MODULE 5: Caregiver knowledge & perceptions of iCCM CHWs********
*Caregiver knows there is an CHW in the community (INDICATOR 1)
tab q504 survey
recode q504 (2 8 9 = 0),gen(chw_know)
lab var chw_know "Caregiver knows CHW works in community"
lab values chw_know yn
tab chw_know survey, col

*Caregiver knows 2+ CHW curative services offered (INDICATOR 2)
*(among those who know that there is an CHW in their community)
by survey: tab1 q505*

gen q505_a = 0 if chw_know==1
replace q505_a = 1 if q505a=="A"
lab val q505_a yn

gen q505_b = 0 if chw_know==1
replace q505_b = 1 if q505b=="B"
lab val q505_b yn

gen q505_c = 0 if chw_know==1
replace q505_c = 1 if q505c=="C"
lab val q505_c yn

gen q505_d = 0 if chw_know==1
replace q505_d = 1 if q505d=="D"
lab val q505_d yn

gen q505_e = 0 if chw_know==1
replace q505_e = 1 if q505e=="E"
lab val q505_e yn

gen q505_f = 0 if chw_know==1
replace q505_f = 1 if q505f=="F"
lab val q505_f yn

gen q505_g = 0 if chw_know==1
replace q505_g = 1 if q505g=="G"
lab val q505_g yn

gen q505_h = 0 if chw_know==1
replace q505_h = 1 if q505h=="H"
lab val q505_h yn

gen q505_i = 0 if chw_know==1
replace q505_i = 1 if q505i=="I"
lab val q505_i yn

gen q505_j = 0 if chw_know==1
replace q505_j = 1 if q505j=="J"
lab val q505_j yn

gen q505_k = 0 if chw_know==1
replace q505_k = 1 if q505k=="K"
lab val q505_k yn

gen q505_l = 0 if chw_know==1
replace q505_l = 1 if q505l=="L"
lab val q505_l yn

gen q505_m = 0 if chw_know==1
replace q505_m = 1 if q505m=="M"
lab val q505_m yn

gen q505_n = 0 if chw_know==1
replace q505_n = 1 if q505n=="N"
lab val q505_n yn

gen q505_o = 0 if chw_know==1
replace q505_o = 1 if q505o=="O"
lab val q505_o yn

gen q505_p = 0 if chw_know==1
replace q505_p = 1 if q505p=="P"
lab val q505_p yn

gen q505_q = 0 if chw_know==1
replace q505_q = 1 if q505q=="Q"
lab val q505_q yn

gen q505_r = 0 if chw_know==1
replace q505_r = 1 if q505r=="R"
lab val q505_r yn

gen q505_s = 0 if chw_know==1
replace q505_s = 1 if q505s=="S"
lab val q505_s yn

gen q505_t = 0 if chw_know==1
replace q505_t = 1 if q505t=="T"
lab val q505_t yn

gen q505_z = 0 if chw_know==1
replace q505_z = 1 if q505z=="Z"
lab val q505_z yn

*Total number of CHW curative services (Q505h-Q505p) that caregiver knows (note - excluded 'other' curative)
egen tot_q505 = rownonmiss(q505k-q505s), strok
replace tot_q505 =. if chw_know != 1
label var tot_q505 "Total number of CHW curative services CG knows"
gen cgcurknow2 = tot_q505 >= 2 
replace cgcurknow2 =. if chw_know != 1
lab var cgcurknow2 "Caregiver knows 2+ CHW curative services"
lab val cgcurknow2 yn
tab cgcurknow2 survey, col

*Caregiver knows CHW location
*(among those who know that there is an CHW in their community)
tab q506 survey
recode q506 8 9 =0, gen(chw_loc)
lab var chw_loc "Caregiver knows location of CHW"
tab chw_loc survey, col

*Look at all CHW perception responses
tab1 q508-q516

*recode missing to don't know
recode q508 9=8
recode q509 9=8
recode q510 9=8
recode q511 9=8
recode q512 9=8
recode q513 9=8
recode q514 9=8
recode q515 9=8
recode q516 9=8

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

*CHW availability by caregiver (INDICATOR 57)
*Want to see if the CHW was available at first visit for all cases the CG sought 

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
lab var chwavailp "Proportion of time CHW was available at first visit"

*Create variable to capture if CHW was ALWAYS available at first visit (INDICATOR 6)
gen chwalwaysavail = 0
replace chwalwaysavail = 1 if chwavailp == 1
replace chwalwaysavail = . if chwavaild == .
lab var chwalwaysavail "CHW was available when caregiver sought care for each case included in survey"
lab val chwalwaysavail yn

tab chwalwaysavail survey, col 

*CHW convenient (INDICATOR 7) - Note for SFH, they did not collect q507 (the CHW is nearby), so this is based on q508 only
tab q508 survey
gen chwconvenient = 0
replace chwconvenient = 1 if q508 == 1 
replace chwconvenient = . if q504 != 1
lab var chwconvenient "CHW is a convenient source of care"
lab val chwconvenient yn
tab chwconvenient survey, col

*******************MODULE 7: Diarrhea*******************************************
*Age of children with diarrhea (not really needed)
recode d_age min/11=1 12/23=2 24/35=3 36/47=4 48/60=5 98/99=.,gen (d_agecat)
lab val d_agecat agecat 
lab var d_agecat "Age category of children with diarrhea included in survey"
tab d_agecat survey, col

*recoding of d_cases that have the whole module missing
recode q703 9=2 if (q708cx=="X"|q708cz=="Z")
recode q703 9=.
recode d_case 1=. if q703==.

*continued fluids (same amount or more than usual?) 
tab q701 survey
gen d_cont_fluids = .
replace d_cont_fluids = 1 if q701 == 3 | q701 == 4
replace d_cont_fluids = 0 if d_case == 1 & q701 !=. & d_cont_fluids == .
lab var d_cont_fluids "Child with diarrhea was offered same or more fluids"
lab val d_cont_fluids yn
tab d_cont_fluids survey, col

*continued feeding (same amount or more than usual) 
tab q702 survey
gen d_cont_feed = .
replace d_cont_feed = 1 if q702 == 3 | q702 == 4
replace d_cont_feed = 0 if d_case == 1 & q702 !=. & d_cont_feed == .
lab var d_cont_feed "Child with diarrhea was offered same or more to eat"
lab val d_cont_feed yn
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

*decided to seek care jointly with partner
tab q704 survey, col
gen d_joint = .
replace d_joint = 1 if q705a=="A" & maritalstat==1 & q703==1
replace d_joint = 0 if d_joint==. & d_case==1 & maritalstat==1 
lab var d_joint "cg sought care jointly w/partner (diarrhea cases)"
lab val d_joint yn

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

*careseeking locations
gen d_cs_hosp = 1 if q706_a == 1 
gen d_cs_hcent = 1 if q706_b == 1 
gen d_cs_hpost = 1 if q706_c == 1
gen d_cs_ngo = 1 if q706_d == 1 
gen d_cs_clin = 1 if q706_e == 1 
gen d_cs_chw = 1 if q706_f == 1 
gen d_cs_trad = 1 if q706_g == 1 
gen d_cs_ppmv = 1 if q706_h == 1 
gen d_cs_phar= 1 if q706_i == 1
gen d_cs_friend = 1 if q706_j == 1 
gen d_cs_mark = 1 if q706_k == 1 
gen d_cs_other = 1 if q706_x == 1

foreach x of varlist d_cs_* {
  replace `x' = 0 if d_case == 1 & q703 == 1 & `x' ==.
  lab val `x' yn
}

*sought advice or treatment from an appropriate provider 
gen d_app_prov = 0 if d_case==1
replace d_app_prov = 1 if (q706_a==1 | q706_b==1 | q706_c==1 | q706_d==1 | q706_e==1 | q706_f==1 | q706_h==1 | q706_i==1)
lab var d_app_prov "Sought care from appropriate provider"
lab val d_app_prov yn 
tab d_app_prov survey, col

egen d_apptot = rownonmiss(q706a-q706f q706h q706i),strok
replace d_apptot = . if d_case != 1
lab var d_apptot "Total number of appropriate providers where sought care"

*visited an CHW (CORP - Option 'F' in questionnaire)
tab q706f survey
tab q708 survey
gen d_chw = 1 if q706f == "F"
replace d_chw = 0 if d_chw ==. & d_case == 1
lab var d_chw "Sought care from CHW for diarrhea"
lab val d_chw yn
tab d_chw survey, col 

*did not seek care from a CHW
gen d_nocarechw = .
replace d_nocarechw = 0 if d_case == 1 & q703 == 1
replace d_nocarechw = 1 if q706f != "F" & q703 == 1 & d_case == 1
lab var d_nocarechw "Sought care for diarrhea - but not from CHW"
lab val d_nocarechw yn
tab d_nocarechw survey, col

*visited an CHW as first (*or only*) source of care (INDICATOR 9A)
gen d_chwfirst = .
replace d_chwfirst = 1 if q708 == "F"
replace d_chwfirst = 1 if q706f == "F" & d_provtot == 1
replace d_chwfirst = 0 if d_case == 1 & d_chwfirst ==.
lab var d_chwfirst "Sought care from CHW first"
lab val d_chwfirst yn
tab d_chwfirst survey, col
svy: tab d_chwfirst survey, col ci pear

*visited an CHW as first (*or only*) source of care among those that sought any care
gen d_chwfirst_anycare = .
replace d_chwfirst_anycare = 0 if d_case == 1 & q703 == 1
replace d_chwfirst_anycare = 1 if q708 == "F"
replace d_chwfirst_anycare = 1 if q706f == "F" & d_provtot == 1
lab var d_chwfirst_anycare "Sought care from CHW first among those who sought any care"
lab val d_chwfirst_anycare yn
tab d_chwfirst_anycare survey, col

*first source of care locations
gen d_fcs_hosp = 1 if q708 == "A" 
gen d_fcs_hcent = 1 if q708 == "B" 
gen d_fcs_hpost = 1 if q708 == "C"
gen d_fcs_ngo = 1 if q708 == "D"
gen d_fcs_clin = 1 if q708 == "E"
gen d_fcs_chw = 1 if q708 == "F"
gen d_fcs_trad = 1 if q708 == "G"
gen d_fcs_ppmv = 1 if q708 == "H"
gen d_fcs_phar = 1 if q708 == "I"
gen d_fcs_friend = 1 if q708 == "J" 
gen d_fcs_mark = 1 if q708 == "K"
gen d_fcs_other = 1 if q708 == "X"

replace d_fcs_hosp = 1 if q706_a == 1 & d_provtot == 1
replace d_fcs_hcent = 1 if q706_b == 1 & d_provtot == 1
replace d_fcs_hpost = 1 if q706_c == 1 & d_provtot == 1
replace d_fcs_ngo = 1 if q706_d == 1 & d_provtot == 1
replace d_fcs_clin = 1 if q706_e == 1 & d_provtot == 1
replace d_fcs_chw = 1 if q706_f == 1 & d_provtot == 1
replace d_fcs_trad = 1 if q706_g == 1 & d_provtot == 1
replace d_fcs_ppmv = 1 if q706_h == 1 & d_provtot == 1
replace d_fcs_phar = 1 if q706_i == 1 & d_provtot == 1
replace d_fcs_friend = 1 if q706_j == 1 & d_provtot == 1
replace d_fcs_mark = 1 if q706_k == 1 & d_provtot == 1
replace d_fcs_other = 1 if q706_x == 1 & d_provtot == 1

foreach x of varlist d_fcs_* {
  replace `x' = 0 if d_case == 1 & q703 == 1 & `x' ==.
  lab val `x' yn
}

****reason(s) did not go to CHW for care (ENDLINE ONLY)
tab1 q708ba-q708bz
egen tot_q708b = rownonmiss(q708ba-q708bx),strok
replace tot_q708b = . if survey == 1
replace tot_q708b = . if q703 != 1
replace tot_q708b = . if q706f == "F"
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
  replace `x' = 0 if `x' == . & d_case == 1 & survey == 2 & q703 == 1 & q706f != "F"
  lab val `x' yn
}


***treated with ORS 
***Includes fluid from ORS packet (709a) and pre-packaged ORS liquid (q709b)
tab q709a survey, col
tab q709b survey, col
gen d_ors = 0 if d_case==1
replace d_ors = 1 if q709a == 1 | q709b == 1
lab var d_ors "Took ORS for diarrhea"
lab val d_ors yn
tab d_ors survey, col

*where did caregiver get ORS?
*Note 6 missing responses
tab q711 survey, col

gen d_ors_hosp = 1 if q711 == 11 
gen d_ors_hcent = 1 if q711 == 12 
gen d_ors_hpost = 1 if q711 == 13 
gen d_ors_ngo = 1 if q711 == 14
gen d_ors_clin= 1 if q711 == 15 
gen d_ors_chw = 1 if q711 == 16 
gen d_ors_trad = 1 if q711 == 21 
gen d_ors_ppmv = 1 if q711 == 22 
gen d_ors_phar = 1 if q711 == 23 
gen d_ors_friend = 1 if q711 == 24 
gen d_ors_mark = 1 if q711 == 25
gen d_ors_other = 1 if q711 == 31

foreach x of varlist d_ors_* {
  replace `x' = 0 if d_case == 1 & d_ors == 1 & `x' ==.
  lab val `x' yn
}

*got ORS from CHW
recode q711 11 12 13 14 15 21 22 23 24 25 31 = 0 16 = 1, gen(d_orschw)
replace d_orschw = 0 if d_orschw ==. & d_case == 1
replace d_orschw = . if d_case ==.
lab var d_orschw "Got ORS from an CHW"
lab val d_orschw yn
*recoded 6 missing responses as no
recode d_orschw 99=0
tab d_orschw survey, col

*got ORS from provider other than CHW
gen d_orsoth = 0 if d_case == 1
replace d_orsoth = 1 if d_ors == 1 & d_orschw != 1
lab var d_orsoth "Got ORS from provider other than CHW"
lab val d_orsoth yn
tab d_orsoth survey, col

*if from CHW, did child take ORS in presence of CHW? (INDICATOR 15A)
tab q713 survey
recode q713 2=0, gen(d_ors_chwp)
lab val d_ors_chwp yn
lab var d_ors_chwp "Child took first dose ORS in presence of CHW"
tab d_ors_chwp survey, col

*if from CHW, did caregiver get counseled on how to give ORS at home? (INDICATOR 16A)
tab q714 survey
recode q714 2 9 =0, gen(d_ors_chwc)
lab val d_ors_chwc yn
lab var d_ors_chwc "CG counseled how to give child ORS"
tab d_ors_chwc survey, col 

*took Homemade fluid
gen d_hmfl = 1 if q709c == 1
replace d_hmfl = 0 if q709c == 2 | q709c == 8 | q709c == 9
replace d_hmfl = . if d_case !=1
lab var d_hmfl "Took homemade fluid for diarrhea"
lab val d_hmfl yn
tab d_hmfl survey, col

*took Zinc 
recode q715 (2 8 9 = 0), gen(d_zinc)
lab val d_zinc yn
lab var d_zinc "child given zinc (for diarrhea cases)"
replace d_zinc = . if d_case != 1
tab d_zinc survey, col

*where did caregiver get zinc?
tab q716 survey, col

gen d_zinc_hosp = 1 if q716 == 11
gen d_zinc_hcent = 1 if q716 == 12
gen d_zinc_hpost = 1 if q716 == 13
gen d_zinc_ngo = 1 if q716 == 14
gen d_zinc_clin = 1 if q716 == 15
gen d_zinc_chw = 1 if q716 == 16
gen d_zinc_trad = 1 if q716 == 21
gen d_zinc_ppmv = 1 if q716 == 22
gen d_zinc_phar = 1 if q716 == 23
gen d_zinc_friend = 1 if q716 == 24
gen d_zinc_mark = 1 if q716 == 25
gen d_zinc_other = 1 if q716 == 31

foreach x of varlist d_zinc_* {
  replace `x' = 0 if d_case == 1 & d_zinc == 1 & `x' ==.
  lab val `x' yn
}

*got zinc from CHW
recode q716 11 12 13 14 15 21 22 23 24 25 31 = 0 16 = 1, gen(d_zincchw)
replace d_zincchw = 0 if d_zincchw ==. & d_case == 1
lab val d_zincchw yn
lab var d_zincchw "CG got zinc from CHW"
*recoded 1 missing response to 0
recode d_zincchw 99=0
tab d_zincchw survey, col

*got zinc from provider other than CHW
gen d_zincoth = 0 if d_case == 1
replace d_zincoth = 1 if d_zinc == 1 & d_zincchw != 1
lab var d_zincoth "Got zinc from provider other than CHW"
lab val d_zincoth yn
tab d_zincoth survey, col

*if from CHW, did child take zinc in presence of CHW? (INDICATOR 15B)
tab q718 survey, col
recode q718 2=0, gen(d_zinc_chwp)
lab val d_zinc_chwp yn
lab var d_zinc_chwp "Child took zinc in presence of CHW"
tab d_zinc_chwp survey, col 

*if from CHW, did caregiver get counseled on how to give zinc at home? (INDICATOR 16B)
*0 in baseline
tab q719 survey, col
recode q719 2 9 =0, gen(d_zinc_chwc)
lab val d_zinc_chwc yn
lab var d_zinc_chwc "CG counseled by CHW on how to give zinc at home"
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
replace d_orszincchw = 1 if d_orszinc == 1 & q711 == 16 & q716 == 16
replace d_orszincchw =. if d_case != 1
lab var d_orszincchw "Took both ORS and zinc for diarrhea from CHW"
lab val d_orszincchw yn
tab d_orszincchw survey, col

*treated with ORS AND Zinc by CHW among those who sought care from a CHW
gen d_orszincchw2 = 0
replace d_orszincchw2 = 1 if d_orszinc == 1 & q711 == 16 & q716 == 16 
replace d_orszincchw2 =. if d_chw != 1
lab var d_orszincchw2 "Got both ORS and zinc for diarrhea from CHW among those who sought care from a CHW"
lab val d_orszincchw2 yn
tab d_orszincchw2 survey, col

*treated with ORS by CHW among those who sought care from a CHW
gen d_orschw2 = 0
replace d_orschw2 = 1 if d_orschw == 1 
replace d_orschw2 =. if d_chw != 1
lab var d_orschw2 "Got ORS for diarrhea from CHW among those who sought care from a CHW"
lab val d_orschw2 yn
tab d_orschw2 survey, col

*treated with zinc by CHW among those who sought care from a CHW
gen d_zincchw2 = 0
replace d_zincchw2 = 1 if d_zincchw == 1 
replace d_zincchw2 =. if d_chw != 1
lab var d_zincchw2 "Got zinc for diarrhea from CHW among those who sought care from a CHW"
lab val d_zincchw2 yn
tab d_zincchw2 survey, col

*treated with ORS by provider other than CHW among those who sought care from other providers
gen d_orsoth2 = .
replace d_orsoth2 = 0 if (d_provtot == 1 & d_chw != 1) | (d_provtot >=2 & d_provtot !=.)
replace d_orsoth2 = 1 if d_orsoth == 1 & ((d_provtot == 1 & d_chw != 1) | (d_provtot >=2 & d_provtot !=.)) 
lab var d_orsoth2 "Got ORS from provider other than CHW among those who sought care from other providers"
lab val d_orsoth2 yn
tab d_orsoth2 survey, col

*treated with zinc by provider other than CHW among those who sought care from other providers
gen d_zincoth2 = .
replace d_zincoth2 = 0 if (d_provtot == 1 & d_chw != 1) | (d_provtot >=2 & d_provtot !=.)
replace d_zincoth2 = 1 if d_zincoth == 1 & ((d_provtot == 1 & d_chw != 1) | (d_provtot >=2 & d_provtot !=.)) 
lab var d_zincoth2 "Got zinc from provider other than CHW among those who sought care from other providers"
lab val d_zincoth2 yn
tab d_zincoth2 survey, col

*treated with ORS AND Zinc by provider other than CHW (INDICATOR 14A)
gen d_orszincoth = 0
replace d_orszincoth = 1 if d_orszinc == 1 & q711 != 16 & q716 != 16
replace d_orszincoth =. if d_case != 1
lab var d_orszincoth "Took both ORS and zinc for diarrhea from a provider other than CHW"
lab val d_orszincoth yn
tab d_orszincoth survey, col

*treated with ORS AND Zinc by provider other than CHW among those who sought care from other providers
gen d_orszincoth2 = .
replace d_orszincoth2 = 0 if (d_provtot == 1 & d_chw != 1) | (d_provtot >=2 & d_provtot !=.)
replace d_orszincoth2 = 1 if d_orszincoth == 1 & ((d_provtot == 1 & d_chw != 1) | (d_provtot >=2 & d_provtot !=.)) 
lab var d_orszincoth2 "Got both ORS and zinc from provider other than CHW among those who sought care from other providers"
lab val d_orszincoth2 yn
tab d_orszincoth2 survey, col

*took both ORS AND Zinc in presence of CHW (INDICATOR 15C)
gen d_bothfirstdose =.
replace d_bothfirstdose = 1 if q713 == 1 & q718 == 1
replace d_bothfirstdose = 0 if q711 == 16 & q716 == 16 & d_bothfirstdose ==.
lab var d_bothfirstdose "Took first dose of both ORS and zinc in presense of CHW"
lab val d_bothfirstdose yn
tab d_bothfirstdose survey, col

*was counseled on admin of both ORS AND Zinc by CHW (INDICATOR 16C)
gen d_bothcounsel =.
replace d_bothcounsel = 1 if q714 == 1 & q719 == 1
replace d_bothcounsel = 0 if q711 == 16 & q716 == 16 & d_bothcounsel ==.
lab var d_bothcounsel "Was counseled on admin of both ORS and zinc by CHW"
lab val d_bothcounsel yn
tab d_bothcounsel survey, col

*if CHW visited, was available at first visit
tab q724 survey
***5 missing responses
recode q724 2 8 9 =0, gen(d_chwavail)
lab val d_chwavail yn
lab var d_chwavail "CHW available at first visit (diarrhea cases)"
tab d_chwavail survey, col


*if CHW visited, did CHW refer the child to a health center?
tab q725 survey
***9 missing responses, coded to 0 "no"
recode q725 2 8 9 =0, gen(d_chwrefer)
lab val d_chwrefer yn
lab var d_chwrefer "CHW referred child to health center"
tab d_chwrefer survey, col

****completed CHW referral (INDICATOR 17A)
tab q726 survey
*1 missing response, coded to .
recode q726 2 =0, gen(d_referadhere)
lab val d_referadhere yn
lab var d_referadhere "CG completed referral for diarrhea case"
tab d_referadhere survey, col 

***reason did not comply with CHW referral
sort survey
by survey: tab1 q727*
*Only 3 responses - 1 for option D and 2 for option E

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

***CHW follow-up 
tab q728
*5 missing responses, coded to no
recode q728 2 8 9=0, gen(d_chw_fu)
lab val d_chw_fu yn
lab var d_chw_fu "CHW did a follow-up visit (diarrhea case)"
tab d_chw_fu survey, col

***when was CHW follow-up
tab q729 survey, col
*recoded 2 missing responses to .
recode q729 9=.

*did the child take anything else for diarrhea (among all diarrhea cases)
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
  replace `x' = 0 if `x' == . & d_case == 1
  lab val `x' yn
  }


*********************MODULE 8: Fever *******************************************
*recoding of fever cases where there is missing info for whole module
recode q803 9=2 if q828x=="X"
recode q803 9=. 
recode f_case 1=. if q803==.

*Age of children with fever (not really needed)
recode f_age min/23=1 24/60=2 98/99=.,gen(f_agecat)

*continued fluids (same amount or more than usual?) 
tab q801 survey
gen f_cont_fluids = .
replace f_cont_fluids = 1 if q801 == 3 | q801 == 4
replace f_cont_fluids = 0 if f_case == 1 & q801 !=. & f_cont_fluids == .
lab var f_cont_fluids "Child with fever was offered same or more fluids"
lab val f_cont_fluids yn
tab f_cont_fluids survey, col

*continued feeding (same amount or more than usual) 
tab q802 survey
gen f_cont_feed = .
replace f_cont_feed = 1 if q802 == 3 | q802 == 4
replace f_cont_feed = 0 if f_case == 1 & q802 !=. & f_cont_feed == .
lab var f_cont_feed "Child with fever was offered same or more to eat"
lab val f_cont_feed yn
tab f_cont_feed survey, col

*sought any advice or treatment for fever
*Need to recode if there is a reponse to q828
tab q803 survey, col
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

*decided to seek care jointly with partner
tab q804 survey, col
tab q805a
gen f_joint = .
replace f_joint = 1 if q805a=="A" & maritalstat==1 & q803==1
replace f_joint = 0 if f_joint==. & f_case==1 & maritalstat==1 
lab var f_joint "cg sought care jointly w/partner (fever cases)"
lab val f_joint yn

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

*sought advice or treatment from an appropriate provider 
egen f_apptot = rownonmiss(q806a-q806f q806h q806i),strok
replace f_apptot = . if f_case != 1
lab var f_apptot "Total number of appropriate providers where sought care"
recode f_apptot 1 2 3 = 1, gen(f_app_prov)
lab var f_app_prov "Sought care from 1+ appropriate provider"
lab val f_app_prov yn 
tab f_app_prov survey, col

*careseeking locations
gen f_cs_hosp = 1 if q806_a == 1 
gen f_cs_hcent = 1 if q806_b == 1 
gen f_cs_hpost = 1 if q806_c == 1
gen f_cs_ngo = 1 if q806_d == 1
gen f_cs_clin = 1 if q806_e == 1
gen f_cs_chw = 1 if q806_f == 1
gen f_cs_trad = 1 if q806_g == 1
gen f_cs_ppmv = 1 if q806_h == 1
gen f_cs_phar = 1 if q806_i == 1
gen f_cs_friend = 1 if q806_j == 1
gen f_cs_mark = 1 if q806_k == 1
gen f_cs_other = 1 if q806_x == 1

foreach x of varlist f_cs_* {
  replace `x' = 0 if f_case == 1 & q803 == 1 & `x' ==.
  lab val `x' yn
}

*visited a CHW (CORP - Option 'F')
tab q806f survey
tab q808 survey
gen f_chw = 1 if q806f == "F"
replace f_chw = 0 if f_chw ==. & f_case == 1 
lab var f_chw "Sought care from CHW for fever"
lab val f_chw yn
tab f_chw survey, col

*did not seek care from a CHW
gen f_nocarechw = .
replace f_nocarechw = 0 if f_case == 1 & q803 == 1
replace f_nocarechw = 1 if q806f != "F" & q803 == 1 & f_case == 1
lab var f_nocarechw "Sought care for fever - but not from CHW"
lab val f_nocarechw yn
tab f_nocarechw survey, col

*visited an CHW as first (*or only*) source of care (among all fever cases)
gen f_chwfirst = .
replace f_chwfirst = 1 if q808 == "F"
replace f_chwfirst = 1 if q806f == "F" & f_provtot == 1
replace f_chwfirst = 0 if f_case == 1 & f_chwfirst ==.
lab var f_chwfirst "Sought care from CHW first"
lab val f_chwfirst yn
tab f_chwfirst survey, col

*visited an CHW as first (*or only*) source of care (among only fever cases that sought any care)
gen f_chwfirst_anycare = .
replace f_chwfirst_anycare = 0 if f_case == 1 & q803 == 1
replace f_chwfirst_anycare = 1 if q808 == "F"
replace f_chwfirst_anycare = 1 if q806f == "F" & f_provtot == 1
lab var f_chwfirst_anycare "Sought care from CHW first among those who sought any care"
lab val f_chwfirst_anycare yn
tab f_chwfirst_anycare survey, col

*first source of care locations
gen f_fcs_hosp = 1 if q808 == "A" 
gen f_fcs_hcent = 1 if q808 == "B" 
gen f_fcs_hpost = 1 if q808 == "C" 
gen f_fcs_ngo = 1 if q808 == "D" 
gen f_fcs_clin = 1 if q808 == "E" 
gen f_fcs_chw = 1 if q808 == "F" 
gen f_fcs_trad = 1 if q808 == "G"
gen f_fcs_ppmv = 1 if q808 == "H" 
gen f_fcs_phar = 1 if q808 == "I"
gen f_fcs_friend = 1 if q808 == "J" 
gen f_fcs_mark = 1 if q808 == "K" 
gen f_fcs_other = 1 if q808 == "X"

replace f_fcs_hosp = 1 if q806_a == 1 & f_provtot == 1
replace f_fcs_hcent = 1 if q806_b == 1 & f_provtot == 1
replace f_fcs_hpost = 1 if q806_c == 1 & f_provtot == 1
replace f_fcs_ngo = 1 if q806_d == 1 & f_provtot == 1
replace f_fcs_clin = 1 if q806_e == 1 & f_provtot == 1
replace f_fcs_chw = 1 if q806_f == 1 & f_provtot == 1
replace f_fcs_trad = 1 if q806_g == 1 & f_provtot == 1
replace f_fcs_ppmv = 1 if q806_h == 1 & f_provtot == 1
replace f_fcs_phar = 1 if q806_i == 1 & f_provtot == 1
replace f_fcs_friend = 1 if q806_j == 1 & f_provtot == 1
replace f_fcs_mark = 1 if q806_k == 1 & f_provtot == 1
replace f_fcs_other = 1 if q806_x == 1 & f_provtot == 1

foreach x of varlist f_fcs_* {
  replace `x' = 0 if f_case == 1 & q803 == 1 & `x' ==.
  lab val `x' yn
}
	
****reason(s) did not go to CHW for care (ENDLINE ONLY)
tab1 q808ba-q808bz
egen tot_q808b = rownonmiss(q808ba-q808bx),strok
replace tot_q808b = . if survey == 1
replace tot_q808b = . if f_case != 1
replace tot_q808b = . if q806f == "F"
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
  replace `x' = 0 if `x' == . & f_case == 1 & survey == 2 & q803 == 1 & q806f != "F"
  lab val `x' yn
}

*had blood taken 
tab q809 survey
*recoded 7 missing responses as no
recode q809 2 8 9 =0, gen(f_bloodtaken)
replace f_bloodtaken = 0 if f_bloodtaken ==. & f_case == 1
lab var f_bloodtaken "Child had blood taken"
lab val f_bloodtaken yn
tab f_bloodtaken survey, col 

***Location of the blood test (hospital, hcenter, hpost, other or don't know)
tab1 q809aa-q809az

gen q809a_a = 1 if q809aa=="A"
gen q809a_b = 1 if q809ab=="B"
gen q809a_c = 1 if q809ac=="C"
gen q809a_x = 1 if q809ax=="X"
gen q809a_z = 1 if q809az=="Z"

foreach x of varlist q809a_* {
  replace `x' = 0 if `x' ==. & q809 == 1
  lab val `x' yn
}

lab var q809a_a "blood test taken at hospital"
lab var q809a_b "blood test taken at hcenter"
lab var q809a_c "blood test taken at hpost"
lab var q809a_x "blood test taken at other location"
lab var q809a_z "cg doesn't know location of blood test"

*Health worker who performed the blood test
tab1 q810a-q810z
gen q810_a = 1 if q810a == "A"
gen q810_b = 1 if q810b == "B"
gen q810_c = 1 if q810c == "C"
gen q810_d = 1 if q810d == "D"
gen q810_e = 1 if q810e == "E"
gen q810_x = 1 if q810x == "X"
gen q810_z = 1 if q810z == "Z"

foreach x of varlist q810_* {
  replace `x' = 0 if `x' ==. & q809 == 1
  lab val `x' yn
}

lab var q810_a "blood test taken by CHW"
lab var q810_b "blood test taken by medical assist"
lab var q810_c "blood test taken by clinical officer"
lab var q810_d "blood test taken by nurse"
lab var q810_e "blood test taken by doctor"
lab var q810_x "blood test taken by other"
lab var q810_z "cg doesn't know who took blood test"

*caregiver received results of blood test (INDICATOR 11)
tab q811 survey
*recoded 2 missing and 3 don't know responses to no
recode q811 2 8 9 = 0, gen(f_gotresult)
lab val f_gotresult yn
lab var f_gotresult "Caregiver received results of blood test"
tab f_gotresult survey, col

*blood test results
tab q812 survey
*recoded 1 missing and 2 don't know responses to no
recode q812 2 8 9 =0, gen(f_result)
lab def result 0 "Negative" 1 "Positive"
lab val f_result result
tab f_result survey, col 

*had blood taken by CHW 
gen f_bloodtakenchw =.
replace f_bloodtakenchw = 0 if f_chw == 1
replace f_bloodtakenchw = 1 if f_chw == 1 & q810_a == 1
lab var f_bloodtakenchw "Child had blood taken by CHW"
lab val f_bloodtakenchw yn
tab f_bloodtakenchw survey, col 

*caregiver received results of blood test done by CHW 
gen f_gotresultchw =.
replace f_gotresultchw = 0 if f_bloodtakenchw == 1
replace f_gotresultchw = 1 if f_gotresult == 1 & f_chw == 1 & q810_a == 1
lab val f_gotresultchw yn
lab var f_gotresultchw "Caregiver received results of blood test done by CHW"
tab f_gotresultchw survey, col

*blood test results (neg or pos) from blood test done by CHW 
gen f_resultchw =.
replace f_resultchw = 0 if f_gotresultchw == 1
replace f_resultchw = 1 if f_result == 1 & f_chw == 1 & q810_a == 1
lab var f_resultchw "Result of test done by CHW"
lab val f_resultchw result
tab f_resultchw survey, col 

*had blood taken by provider other than CHW
egen f_bloodtaken_tot = anycount(q810_a-q810_x), values(1)
replace f_bloodtaken_tot = . if f_bloodtaken != 1

gen f_bloodtakenoth = .
replace f_bloodtakenoth = 0 if (f_provtot == 1 & f_chw != 1) | (f_provtot >=2 & f_provtot !=.)
replace f_bloodtakenoth = 1 if (f_bloodtaken_tot == 1 & f_bloodtakenchw != 1) | f_bloodtaken_tot == 2
replace f_bloodtakenoth = . if f_bloodtaken_tot == 0
lab var f_bloodtakenoth "Child had blood taken by provider other than CHW"
lab val f_bloodtakenoth yn
tab f_bloodtakenoth survey

*caregiver received results of blood test done by provider other than CHW 
gen f_gotresultoth = .
replace f_gotresultoth = 0 if f_bloodtakenoth == 1
replace f_gotresultoth = 1 if f_gotresult == 1 & f_bloodtakenoth == 1
lab var f_gotresultoth "Caregiver recieved results from provider other than CHW"
lab val f_gotresultoth yn
tab f_gotresultoth survey

*Cases managed by provider other than CORP: Blood test was positive
gen f_resultoth = .
replace f_resultoth = 0 if f_gotresultoth == 1
replace f_resultoth = 1 if f_result == 1 & f_gotresultoth == 1
lab var f_resultoth "Received positive blood test result from provider other than CHW"
lab val f_resultoth yn
tab f_resultoth survey

*blood test results (neg or pos) from blood test done by provider other than CHW 

***took any treatment 
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
* replace `x' = 0 if `x' ==. & f_case == 1
  lab val `x' yn
}
*took any antimalarial among all fever cases
gen f_antim = 1 if q814a == "A" | q814b == "B" | q814c == "C"
replace f_antim = 0 if f_antim ==. & f_case == 1
lab var f_antim "Took antimalarial for fever"
lab val f_antim yn
tab f_antim survey, col

****took antimalarial - among those that had a positive blood test)
gen f_antimc = 1 if (q814a == "A" | q814b == "B" | q814c == "C") & q812 == 1
replace f_antimc = 0 if f_antimc ==. & f_case == 1 & q812==1
lab var f_antimc "Took antimalarial for fever after positive blood test (among those w/pos RDT)"
lab val f_antimc yn
tab f_antimc survey, col

*took ACT (among all fever cases)
gen f_act = 0 if f_case == 1
replace f_act = 1 if q814a == "A"
lab var f_act "Took ACT for fever"
lab val f_act yn
tab f_act survey, col

*did not take ACT
gen f_noact =.
replace f_noact = 0 if f_case == 1
replace f_noact = 1 if f_act == 0
lab var f_noact "Did not take ACT for fever"
lab val f_noact yn
tab f_noact survey, col

*took ACT - confirmed malaria, positive blood test
gen f_actc = 1 if f_act == 1 & f_result == 1
replace f_actc = 0 if f_actc ==. & f_case == 1
lab var f_actc "Took ACT for fever - positive blood test"
lab val f_actc yn
tab f_actc survey, col

***ACT treatment, among those who had a positive blood test result
gen f_actc2 = .
replace f_actc2 = 0 if f_result == 1
replace f_actc2 = 1 if f_actc == 1  
lab var f_actc2 "ACT treatment after positive blood test, among those with a positive RDT"
lab val f_actc2 yn
tab f_actc2 survey, col

*took ACT, but negative blood test
gen f_actneg =.
replace f_actneg = 0 if f_case == 1
replace f_actneg = 1 if f_result == 0 & f_act == 1
lab var f_actneg "Took ACT, but blood test was negative"
lab val f_actneg yn
tab f_actneg survey, col

*No ACT - but confirmed malaria, positive blood test
gen f_noactc =.
replace f_noactc = 0 if f_case == 1
replace f_noactc = 1 if f_result == 1 & f_act != 1
lab var f_noactc "No ACT but positive blood test"
lab val f_noactc yn
tab f_noactc survey, col

*No ACT, negative blood test
gen f_noactnoc=.
replace f_noactnoc = 0 if f_case == 1
replace f_noactnoc = 1 if f_result == 0 & f_act != 1
lab var f_noactnoc "No ACT, negative blood test"
lab val f_noactnoc yn
tab f_noactnoc survey, col

*took ACT within 24 hours (same or next day)
gen f_act24 = 1 if f_act == 1 & q817 < 2
replace f_act24 = 0 if f_act24 ==. & f_case == 1
lab var f_act24 "Took ACT within 24 hours of start of fever"
lab val f_act24 yn
tab f_act24 survey, col

*took ACT within 24 hours (same or next day), confirmed malaria - positive blood test
gen f_act24c = .
replace f_act24c = 0 if f_case == 1
replace f_act24c = 1 if f_actc == 1 & q817 < 2 
lab var f_act24c "Confirmed malaria treatment, same or next day"
lab val f_act24c yn
tab f_act24c survey, col

*took ACT within 24 hours (same or next day), confirmed malaria - positive blood test, among those w/positive RDT
gen f_act24c2 = .
replace f_act24c2 = 0 if f_case == 1 & f_result==1
replace f_act24c2 = 1 if f_actc == 1 & q817 < 2 
lab var f_act24c2 "Confirmed malaria treatment, same or next day"
lab val f_act24c2 yn
tab f_act24c2 survey, col

*Source of ACT
tab q816 survey, col

gen f_act_hosp = 1 if q816 == 11 
gen f_act_hcent = 1 if q816 == 12
gen f_act_hpost = 1 if q816 == 13
gen f_act_ngo = 1 if q816 == 14
gen f_act_clin = 1 if q816 == 15
gen f_act_chw = 1 if q816 == 16
gen f_act_trad = 1 if q816 == 21 
gen f_act_ppmv = 1 if q816 == 22
gen f_act_phar = 1 if q816 == 23 
gen f_act_friend = 1 if q816 == 24
gen f_act_mark = 1 if q816 == 25
gen f_act_other = 1 if q816 == 31 

foreach x of varlist f_act_* {
  replace `x' = 0 if f_case == 1 & f_act == 1 & `x' ==.
  lab val `x' yn
}

***ACT treatment from CHW 
gen f_actchw = .
replace f_actchw = 0 if f_case == 1
replace f_actchw = 1 if f_act == 1 & q816 == 16 
lab var f_actchw "ACT treatment by a CHW"
lab val f_actchw yn
tab f_actchw survey, col

***ACT treatment from provider other than CHW 
gen f_actoth = .
replace f_actoth = 0 if f_case == 1
replace f_actoth = 1 if f_act == 1 & q816 != 16 
lab var f_actoth "ACT treatment by a provider other than CHW"
lab val f_actoth yn
tab f_actoth survey, col

***ACT treatment from CHW among those who sought care from CHW
gen f_actchw2 = .
replace f_actchw2 = 0 if f_chw==1
replace f_actchw2 = 1 if f_actchw == 1 & f_chw == 1 
lab var f_actchw2 "ACT treatment by a CHW if sought care from CHW"
lab val f_actchw2 yn
tab f_actchw2 survey, col

***ACT treatment from CHW within 2 days among those who sought care from CHW
gen f_act24chw2 = .
replace f_act24chw2 = 0 if f_chw==1
replace f_act24chw2 = 1 if f_actchw == 1 & q817 < 2 & f_chw == 1 
lab var f_act24chw2 "ACT treatment by a CHW within 2 days if sought care from CHW"
lab val f_act24chw2 yn
tab f_act24chw2 survey, col

***ACT treatment from provider other than CHW among those who sought care from other providers
gen f_actoth2 = .
replace f_actoth2 = 0 if (f_provtot == 1 & f_chw != 1) | (f_provtot >=2 & f_provtot !=.)
replace f_actoth2 = 1 if f_actoth == 1 & ((f_provtot == 1 & f_chw != 1) | (f_provtot >=2 & f_provtot !=.))
lab var f_actoth2 "ACT treatment by a CHW if sought care from CHW"
lab val f_actoth2 yn
tab f_actoth2 survey, col

***ACT treatment from CHW - positive blood test
gen f_actcchw = .
replace f_actcchw = 0 if f_result == 1
replace f_actcchw = 1 if f_actchw == 1 & f_resultchw == 1 
lab var f_actcchw "ACT treatment by a CHW - after positive blood test"
lab val f_actcchw yn
tab f_actcchw survey, col

***ACT treatment from provider other than CHW - positive blood test
gen f_actcoth = .
replace f_actcoth = 0 if f_result == 1
replace f_actcoth = 1 if f_actoth == 1 & f_result == 1
lab var f_actcoth "ACT treatment by a provider other than CHW - positive blood test"
lab val f_actcoth yn
tab f_actcoth survey, col

***ACT treatment from CHW among those who had a positive blood test 
gen f_actcchw2 = .
replace f_actcchw2 = 0 if f_resultchw==1
replace f_actcchw2 = 1 if f_actchw == 1 & f_resultchw == 1 
lab var f_actcchw2 "ACT treatment by a CHW after positive blood test by CHW"
lab val f_actcchw2 yn
tab f_actcchw2 survey, col

***ACT treatment from provider other than CHW among those who had a positive blood test by other provider
gen f_actcoth2 = .
replace f_actcoth2 = 0 if f_resultoth == 1 
replace f_actcoth2 = 1 if f_resultoth == 1 & f_actcoth == 1 
replace f_actcoth2 = . if f_bloodtaken_tot == 0
lab var f_actcoth2 "ACT treatment from provider other than CHW among those who had a positive blood test by other provider"
lab val f_actcoth2 yn
tab f_actcoth2 survey, col

***ACT within 24 hours from CHW 
gen f_act24chw = .
replace f_act24chw = 0 if f_case == 1
replace f_act24chw = 1 if f_actchw == 1 & q817 < 2
lab var f_act24chw "ACT treatment with 24 hours by a CHW"
lab val f_act24chw yn
tab f_act24chw survey, col

***ACT treatment from provider other than CHW within 2 days
gen f_act24oth = .
replace f_act24oth = 0 if f_case == 1
replace f_act24oth = 1 if f_act == 1 & q816 != 16 & q817 < 2
lab var f_act24oth "ACT treatment by a provider other than CHW within 2 days"
lab val f_act24oth yn
tab f_act24oth survey, col

***ACT treatment from provider other than CHW among those who sought care from other providers
gen f_act24oth2 = .
replace f_act24oth2 = 0 if (f_provtot == 1 & f_chw != 1) | (f_provtot >=2 & f_provtot !=.)
replace f_act24oth2 = 1 if f_act24oth == 1 & ((f_provtot == 1 & f_chw != 1) | (f_provtot >=2 & f_provtot !=.))
lab var f_act24oth2 "ACT treatment by a CHW within 2 days if sought care from CHW"
lab val f_act24oth2 yn
tab f_act24oth2 survey, col

***ACT within 24 hours (same or next day), confirmed malaria treatment by CHW
gen f_act24cchw = .
replace f_act24cchw = 0 if f_result == 1
replace f_act24cchw = 1 if f_actcchw == 1 & q817 < 2
lab var f_act24cchw "Confirmed fever treatment by an CHW within 2 days - positive blood test"
lab val f_act24cchw yn
tab f_act24cchw survey, col

***ACT within 24 hours (same or next day), confirmed malaria treatment by provider other than CHW
gen f_act24coth =.
replace f_act24coth = 0 if f_result == 1
replace f_act24coth = 1 if f_result == 1 & f_act24c == 1 & q816 != 16
lab var f_act24coth "Confirmed fever treatment by an oth"
lab val f_act24coth yn
tab f_act24coth survey, col

***ACT treatment with 24 hours from CHW - positive blood test, among those who sought care from a CHW
gen f_act24cchw2 = .
replace f_act24cchw2 = 0 if f_resultchw == 1
replace f_act24cchw2 = 1 if f_act24cchw == 1  & f_resultchw==1
lab var f_act24cchw2 "ACT treatment within 24 hours by a CHW - blood test+, among those who sought care from a CHW"
lab val f_act24cchw2 yn
tab f_act24cchw2 survey, col

***ACT treatment from provider within 24 hours other than CHW among those who had a positive blood test by other provider
gen f_act24coth2 = .
replace f_act24coth2 = 0 if f_resultoth == 1 
replace f_act24coth2 = 1 if f_resultoth == 1 & f_act24coth == 1 
replace f_act24coth2 = . if f_bloodtaken_tot == 0
lab var f_act24coth2 "ACT treatment from provider other than CHW within 24 hours among those who had a positive blood test by other provider"
lab val f_act24coth2 yn
tab f_act24coth2 survey, col

*if from CHW, did child take ACT in presence of CHW? (INDICATOR 15B)
tab q819 survey
recode q819 2 9 =0, gen(f_act_chwp)
lab val f_act_chwp yn
tab f_act_chwp survey, col

*if from CHW, did caregiver get counseled on how to give ACT at home? 
tab q820 survey
*recoded 1 missing response to no
recode q820 2 9 =0, gen(f_act_chwc)
lab val f_act_chwc yn
lab var f_act_chwp "child took first dose of ACT in presence of CHW"
tab f_act_chwc survey, col

*if CHW visited, was available at first visit
tab q822 survey, col
*recoded 6 missing responses to no
recode q822 2 9 =0, gen(f_chwavail)
lab val f_chwavail yn
lab var f_chwavail "CHW available first time visited"
tab f_chwavail survey, col 

*if CHW visited, did CHW refer the child to a health center?
tab q823 survey
*recoded 8 missing responses to no
recode q823 2 9=0, gen(f_chwrefer)
lab val f_chwrefer yn
lab var f_chwrefer "CHW referred child to health facility"
tab f_chwrefer survey, col 

***completed referral by CHW (INDICATOR 17B)
tab q824 survey
*recoded 1 missing response to no
recode q824 2 9=0, gen(f_referadhere)
lab val f_referadhere yn
lab var f_referadhere "Followed CHW's advice and went to health facility"
tab f_referadhere survey, col

***reason did not comply with CHW referral
sort survey
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
  replace `x' = 0 if `x' == . & (q824 == 2|q824 == 9)
  lab val `x' yn
}

***CHW follow-up (INDICATOR 18B)
tab q826 survey
*recoded 8 missing responses to no
recode q826 2 9 =0, gen(f_chw_fu)
lab val f_chw_fu yn
lab var f_chw_fu "CHW follow-up visit"
tab f_chw_fu survey, col 

***when was CHW follow-up
*missing 4 responses, coded to .
tab q827 survey, col
recode q827 9=.

***********************MODULE 9: Fast Breathing*********************************
*Age of children with fast breathing (not really needed)
recode fb_age min/23=1 24/60=2 98/99=.,gen (fb_agecat)

*recoding of fb_cases where whole module is missing information
recode q903 9=2 if q925x=="X"
recode q903 9=. 
recode fb_case 1=. if q903==.

*continued fluids (same amount or more than usual?) 
tab q901 survey
gen fb_cont_fluids = .
replace fb_cont_fluids = 1 if q901 == 3 | q901 == 4
replace fb_cont_fluids = 0 if fb_case == 1 & q901 !=. & fb_cont_fluids == .
lab var fb_cont_fluids "Child with fast breathing was offered same or more fluids"
lab val fb_cont_fluids yn
tab fb_cont_fluids survey, col

*continued feeding (same amount or more than usual) 
tab q902 survey
gen fb_cont_feed = .
replace fb_cont_feed = 1 if q902 == 3 | q902 == 4
replace fb_cont_feed = 0 if fb_case == 1 & q902 !=. & fb_cont_feed == .
lab var fb_cont_feed "Child with fast breathing was offered same or more to eat"
lab val fb_cont_feed yn
tab fb_cont_feed survey, col

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

*decided to seek care jointly with partner
tab q904 survey, col
tab q905a
gen fb_joint = .
replace fb_joint = 1 if q905a=="A" & maritalstat==1 & q903==1
replace fb_joint = 0 if fb_joint==. & fb_case==1 & maritalstat==1 
lab var fb_joint "cg sought care jointly w/partner (fb cases)"
lab val fb_joint yn

*where care was sought
sort survey
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

*sought advice or treatment from an appropriate provider 
egen fb_apptot = rownonmiss(q906a-q906f q906i),strok
replace fb_apptot = . if fb_case != 1
lab var fb_apptot "Total number of appropriate providers where sought care"
recode fb_apptot 1 2 3 = 1, gen(fb_app_prov)
lab var fb_app_prov "Sought care from 1+ appropriate provider"
lab val fb_app_prov yn 
tab fb_app_prov survey, col
*/

*careseeking locations
gen fb_cs_hosp = 1 if q906_a == 1 
gen fb_cs_hcent = 1 if q906_b == 1 
gen fb_cs_hpost = 1 if q906_c == 1 
gen fb_cs_ngo = 1 if q906_d == 1 
gen fb_cs_clin = 1 if q906_e == 1 
gen fb_cs_chw = 1 if q906_f == 1 
gen fb_cs_trad = 1 if q906_g == 1 
gen fb_cs_ppmv = 1 if q906_h == 1 
gen fb_cs_phar = 1 if q906_i == 1 
gen fb_cs_friend = 1 if q906_j == 1 
gen fb_cs_mark = 1 if q906_k == 1 
gen fb_cs_other = 1 if q906_x == 1

foreach x of varlist fb_cs_* {
  replace `x' = 0 if fb_case == 1 & q903 == 1 & `x' ==.
  lab val `x' yn
}

*visited an CHW (option 'F')
tab q906f survey, col
tab q908 survey, col
gen fb_chw = 1 if q906f == "F"
replace fb_chw = 0 if fb_chw ==. & fb_case == 1
lab var fb_chw "Sought care from CHW for cough/fast breathing"
lab val fb_chw yn
tab fb_chw survey, col

*did not seek care from a CHW
gen fb_nocarechw = .
replace fb_nocarechw = 0 if fb_case == 1 & q903 == 1
replace fb_nocarechw = 1 if q906f != "F" & q903 == 1 & fb_case == 1
lab var fb_nocarechw "Sought care for fast breathing - but not from CHW"
lab val fb_nocarechw yn
tab fb_nocarechw survey, col

*visited an CHW as first (*or only*) source of care (INDICATOR 9C)
gen fb_chwfirst = .
replace fb_chwfirst = 1 if q908 == "F"
replace fb_chwfirst = 1 if q906f == "F" & fb_provtot == 1
replace fb_chwfirst = 0 if fb_case == 1 & fb_chwfirst ==.
lab var fb_chwfirst "Sought care from CHW first"
lab val fb_chwfirst yn
tab fb_chwfirst survey, col

*visited an CHW as first (*or only*) source of care 
gen fb_chwfirst_anycare = .
replace fb_chwfirst_anycare = 0 if fb_case == 1 & q903 == 1
replace fb_chwfirst_anycare = 1 if q908 == "F"
replace fb_chwfirst_anycare = 1 if q906f == "F" & fb_provtot == 1
lab var fb_chwfirst_anycare "Sought care from CHW first among those who sought any care"
lab val fb_chwfirst_anycare yn
tab fb_chwfirst_anycare survey, col

*first source of care locations
gen fb_fcs_hosp = 1 if q908 == "A" 
gen fb_fcs_hcent = 1 if q908 == "B" 
gen fb_fcs_hpost = 1 if q908 == "C" 
gen fb_fcs_ngo = 1 if q908 == "D" 
gen fb_fcs_clin = 1 if q908 == "E" 
gen fb_fcs_chw = 1 if q908 == "F" 
gen fb_fcs_trad = 1 if q908 == "G" 
gen fb_fcs_ppmv = 1 if q908 == "H" 
gen fb_fcs_phar = 1 if q908 == "I" 
gen fb_fcs_friend = 1 if q908 == "J" 
gen fb_fcs_mark = 1 if q908 == "K" 
gen fb_fcs_other = 1 if q908 == "X"

replace fb_fcs_hosp = 1 if q906_a == 1 & fb_provtot == 1
replace fb_fcs_hcent = 1 if q906_b == 1 & fb_provtot == 1
replace fb_fcs_hpost = 1 if q906_c == 1 & fb_provtot == 1
replace fb_fcs_ngo = 1 if q906_d == 1 & fb_provtot == 1
replace fb_fcs_clin = 1 if q906_e == 1 & fb_provtot == 1
replace fb_fcs_chw = 1 if q906_f == 1 & fb_provtot == 1
replace fb_fcs_trad = 1 if q906_g == 1 & fb_provtot == 1
replace fb_fcs_ppmv = 1 if q906_h == 1 & fb_provtot == 1
replace fb_fcs_phar = 1 if q906_i == 1 & fb_provtot == 1
replace fb_fcs_friend = 1 if q906_j == 1 & fb_provtot == 1
replace fb_fcs_mark = 1 if q906_k == 1 & fb_provtot == 1
replace fb_fcs_other = 1 if q906_x == 1 & fb_provtot == 1

foreach x of varlist fb_fcs_* {
  replace `x' = 0 if fb_case == 1 & q903 == 1 & `x' ==.
  lab val `x' yn
}

****reason(s) did not go to CHW for care (ENDLINE ONLY)
tab1 q908ba-q908bz
egen tot_q908b = rownonmiss(q908ba-q908bx),strok
replace tot_q908b = . if survey == 1
replace tot_q908b = . if q903 != 1
replace tot_q908b = . if q906f == "F"
lab var tot_q908b "Total number of reasons CG did not go to an CHW"
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
  replace `x' = 0 if `x' == . & fb_case == 1 & survey == 2 & q903 == 1 & q906f != "F"
  lab val `x' yn
}

*assessed for fast breathing (INDICATOR 12)
tab q909 survey
*recoded don't know and 6 missing responses to no
recode q909 2 8 9 =0, gen(fb_assessed)
replace fb_assessed = 0 if fb_assessed ==. & fb_case == 1
lab var fb_assessed "Child assessed for fast breathing"
lab val fb_assessed yn
tab fb_assessed survey, col

*Location of where breathing was checked
sort survey
by survey: tab1 q909aa-q909az

encode q909aa, gen(q909a_a)
encode q909ab, gen(q909a_b)
encode q909ac, gen(q909a_c)
encode q909ax, gen(q909a_x)
encode q909az, gen(q909a_z)

foreach x of varlist q909a_* {
  replace `x' = 0 if `x' ==. & q909 == 1
  lab val `x' yn
}
lab var q909a_a "breathing checked at hospital"
lab var q909a_b "breathing checked at hcenter"
lab var q909a_c "breathing checked at hpost"
lab var q909a_x "breathing checked at other"
lab var q909a_z "CG didn't know location of where breathing was checked"

*Health provider who checked breathing
sort survey
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
lab var q910_a "breathing checked by CHW"
lab var q910_b "breathing checked by medical assist"
lab var q910_c "breathing checked by clinical officer"
lab var q910_d "breathing checked by nurse"
lab var q910_e "breathing checked by doctor"
lab var q910_x "breathing checked by other"
lab var q910_z "CG didn't know who checked breathing"

*assessed for fast breathing during CHW visit (INDICATOR 12)
gen fb_assessedchw =.
replace fb_assessedchw = 0 if fb_chw == 1
replace fb_assessedchw = 1 if fb_assessed == 1 & q910_a == 1
lab var fb_assessedchw "Child assessed for fast breathing by CHW"
lab val fb_assessedchw yn
tab fb_assessedchw survey, col

egen fb_assessed_tot = anycount(q910_a-q910_x), values(1)
replace fb_assessed_tot = . if fb_assessed == 0 | fb_case !=1
tab fb_assessed_tot survey

*Child assessed for fast breathing by provider other than CHW, among those who sought care from other providers
gen fb_assessedoth = .
replace fb_assessedoth = 0 if fb_case == 1 & ((fb_provtot == 1 & fb_chw != 1) | fb_provtot >= 2 )
replace fb_assessedoth = 1 if fb_assessed == 1 & ((fb_assessed_tot == 1 & fb_assessedchw != 1) | fb_assessed_tot == 2) & fb_case == 1 & ((fb_provtot == 1 & fb_chw != 1) | fb_provtot >= 2 )
replace fb_assessedoth = . if fb_assessed_tot == 0
lab var fb_assessedoth "Child assessed for fast breathing by provider other than CHW"
lab val fb_assessedoth yn
tab fb_assessedoth survey, m

*received any treatment 
sort survey
by survey: tab1 q912*

encode q912a, gen(q912_a)
encode q912b, gen(q912_b)
encode q912c, gen(q912_c)
encode q912d, gen(q912_d)
encode q912e, gen(q912_e)
encode q912f, gen(q912_f)
encode q912g, gen(q912_g)
encode q912x, gen(q912_x)
encode q912z, gen(q912_z)

foreach x of varlist q912_* {
  replace `x' = 0 if `x' ==. & q911 == 1
*  replace `x' = 0 if `x' ==. & fb_case == 1
  lab val `x' yn
} 

*took any medication for fast breathing (excludes 'other' option)
egen fb_rxany = rownonmiss(q912a-q912g), strok
replace fb_rxany = 1 if fb_rxany > 0 & fb_rxany !=.
replace fb_rxany = . if fb_case != 1
lab var fb_rxany "Took any medication for fast breathing"
lab val fb_rxany yn
tab fb_rxany survey, col 

*treated with any antibiotic
gen fb_abany = .
replace fb_abany = 0 if fb_case == 1
replace fb_abany = 1 if q912d == "D" | q912e == "E"
lab val fb_abany yn
lab var fb_abany "Took any antibiotic for fast breathing"
tab fb_abany survey, col

* treated with first line antibiotics (option 'D')
*note: first line antibiotic is country-specific, in Nigeria it is amoxicillin
gen fb_flab = 1 if q912d == "D"
replace fb_flab = 0 if fb_flab ==. & fb_case == 1
replace fb_flab =. if fb_case != 1
lab var fb_flab "Took first line antibiotic for fast breathing"
lab val fb_flab yn
tab fb_flab survey, col

* treated with first line antibiotics by a CHW (among all fb cases)
gen fb_flabchw = 0 if fb_case == 1
replace fb_flabchw = 1 if q912d == "D" & q914 == 16
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

* treated with first line antibiotics by a provider other than CHW (among all fb cases)
gen fb_flaboth = 0 if fb_case == 1
replace fb_flaboth = 1 if q912d == "D" & q914 != 16
replace fb_flaboth =. if fb_case != 1
lab var fb_flaboth "Got first line antibiotic for fast breathing from provider other than CHW"
lab val fb_flaboth yn
tab fb_flaboth survey, col

*Recieved appropriate treatment from provider other than CHW
gen fb_flaboth2 = .
replace fb_flaboth2 = 0 if (fb_provtot >= 2 | (fb_provtot == 1 & fb_chw != 1)) & fb_case == 1
replace fb_flaboth2 = 1 if fb_flaboth == 1 & (fb_provtot >= 2 | (fb_provtot == 1 & fb_chw != 1)) & fb_case == 1
lab var fb_flaboth2 "recived first line antibiotics from provider other than CHW for fast breathing"
lab val fb_flaboth2 yn
tab fb_flaboth2 survey, m

*where did caregiver get the firstline antibiotic?
tab q914 survey, col

gen fb_flab_hosp = 1 if q914 == 11 & fb_flab == 1
gen fb_flab_hcent = 1 if q914 == 12 & fb_flab == 1
gen fb_flab_hpost = 1 if q914 == 13 & fb_flab == 1
gen fb_flab_ngo = 1 if q914 == 14 & fb_flab == 1
gen fb_flab_clin = 1 if q914 == 15 & fb_flab == 1
gen fb_flab_chw = 1 if q914 == 16 & fb_flab == 1
gen fb_flab_trad = 1 if q914 == 21 & fb_flab == 1
gen fb_flab_ppmv = 1 if q914 == 22 & fb_flab == 1
gen fb_flab_phar = 1 if q914 == 23 & fb_flab == 1
gen fb_flab_friend = 1 if q914 == 24 & fb_flab == 1
gen fb_flab_mark = 1 if q914 == 25 & fb_flab == 1
gen fb_flab_other = 1 if q914 == 31 & fb_flab == 1

foreach x of varlist fb_flab_* {
  replace `x' = 0 if fb_case == 1 & fb_flab == 1 & `x' ==. & q914 !=.
  lab val `x' yn
}

*if from CHW, did child take antibiotic in presence of CHW? 
tab q916 survey
recode q916 2=0, gen(fb_flab_chwp)
replace fb_flab_chwp =. if q912d != "D"
lab val fb_flab_chwp yn
lab var fb_flab_chwp "child took first dose of amoxicillin in presence of CHW"
tab fb_flab_chwp survey, col 

*if from CHW, did caregiver get counseled on how to give antibiotic at home? (INDICATOR 16C)
tab q917 survey
*recoded 2 missing responses to no
recode q917 2 9 =0, gen(fb_flab_chwc)
replace fb_flab_chwc =. if q912d != "D"
lab val fb_flab_chwc yn
tab fb_flab_chwc survey, col

*if CHW visited, was available at first visit
tab q919 survey
*recoded don't know and 4 missing responses to no
recode q919 2 8 9=0, gen(fb_chwavail)
lab val fb_chwavail yn
lab var fb_chwavail "CHW available first time visited (fb case)"
tab fb_chwavail survey, col

*if CHW visited, did CHW refer the child to a health center?
tab q920 survey
*recoded don't know and 6 missing responses to no
recode q920 2 8 9=0, gen(fb_chwrefer)
lab val fb_chwrefer yn
lab var fb_chwrefer "CHW referred child to health facility (fb_case)"
tab fb_chwrefer survey, col 

***completed CHW referral 
tab q921 survey
recode q921 2=0, gen(fb_referadhere)
lab val fb_referadhere yn
lab var fb_referadhere "CG followed CHW's advice and went to health facility (fb_case)"
tab fb_referadhere survey, col

***reason did not comply with CHW referral
sort survey
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

***CHW follow-up
tab q923 survey
*recoded don't know and 5 missing responses to no
recode q923 2 8 9 =0, gen(fb_chw_fu)
lab val fb_chw_fu yn
lab var fb_chw_fu "CHW follow-up visit (fb case)"
tab fb_chw_fu survey, col

***when was CHW follow-up
*6 missing responses coded to .
tab q924 survey, col
recode q924 9=.

save "cg_combined_hh_roster_post.dta", replace

********************************************************************************
********************************************************************************
*cd "C:\Users\25592\Documents\Documents\RAcE Project\SFH Endline HH survey\Dataset\Analyses\Overall dataset"
set more off

*Overall indicators across all three illnesses
*First create a variable in the final analysis file to indicate that will be used to indicate the illness
*Used the variable "set" and created three separate files
*SET: 1 = diarrhea, 2 = fever, and 3 = fast breathing.
use "cg_combined_hh_roster_post.dta", clear
gen set = 1
save "cg_combined_hh_roster_post1.dta", replace
replace set = 2
save "cg_combined_hh_roster_post2.dta", replace
replace set = 3
save "cg_combined_hh_roster_post3.dta", replace

*In the diarrhea file, drop any caregiver records without a child who had diarrhea
use "cg_combined_hh_roster_post1.dta", clear
tab d_case
drop if d_case != 1
save "cg_combined_hh_roster_post1.dta", replace

*In the fever file, drop any caregiver records without a child who had fever
use "cg_combined_hh_roster_post2.dta", clear
tab f_case
drop if f_case != 1
save "cg_combined_hh_roster_post2.dta", replace

*In the fast breathing file, drop any caregiver records without a child who had fast breathing
use "cg_combined_hh_roster_post3.dta", clear
tab fb_case
drop if fb_case != 1
save "cg_combined_hh_roster_post3.dta", replace

*Append the three illness files together & save the resulting file
use "cg_combined_hh_roster_post1.dta", clear
append using "cg_combined_hh_roster_post2.dta", nolabel
append using "cg_combined_hh_roster_post3.dta", nolabel
save "cg_combined_hh_roster_overall.dta", replace

***Calculate each of the key indicators across all three illnesses
****NOTE - NEED TO DETERMINE IF CAN USE 0 FOR ALL, OR IF NEED TO SPECIFY SET1, SET2, SET3

*continued fluids when child was sick (offered the same or more fluids)
gen all_cont_fluids = 0 if (set==1 | set==2) | (set==3)
replace all_cont_fluids = 1 if (set==1 & d_cont_fluids==1) | (set==2 & f_cont_fluids==1) | (set==3 & fb_cont_fluids==1)

*continued feeding when child was sick (offered the same or more food)
gen all_cont_feed = 0 if (set==1 | set==2) | (set==3)
replace all_cont_feed = 1 if (set==1 & d_cont_feed==1) | (set==2 & f_cont_feed==1) | (set==3 & fb_cont_feed==1)

*care-seeking from an appropriate provider, all 3 illnesses
gen all_app_prov = 0 if (set==1 | set==2) | (set==3)
replace all_app_prov = 1 if (set == 1 & d_app_prov == 1) | (set == 2 & f_app_prov == 1) | (set == 3 & fb_app_prov == 1)

*CHW first source of care, all 3 illnesses
gen all_chwfirst = 0 if (set==1) | (set==2) | (set==3)
replace all_chwfirst = 1 if (set == 1 & d_chwfirst == 1) | (set == 2 & f_chwfirst == 1) | (set == 3 & fb_chwfirst == 1)

*CHW first source of care among those who sought any care, all 3 illnesses
gen all_chwfirst_anycare = .
replace all_chwfirst_anycare = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_chwfirst_anycare = 1 if (set == 1 & d_chwfirst_anycare == 1) | (set == 2 & f_chwfirst_anycare == 1) | (set == 3 & fb_chwfirst_anycare == 1)

*Correct treatment, all 3 illnesses, among all cases (for malaria this includes ACT w/in 24 hours)
***This includes only confirmed cases of malaria in the denominator
gen all_correct_rx = 0 if (set == 1) | (set == 2 & f_result==1) | (set == 3)
replace all_correct_rx = 1 if (set == 1 & d_orszinc == 1) | (set == 2 & f_act24c2 == 1) | (set == 3 & fb_flab == 1)

*Correct treatment from a CHW, all 3 illnesses among all cases (for malaria this includes ACT w/in 24 hours)
***This includes only confirmed cases of malaria in the denominator
gen all_correct_rxchw = 0 if (set == 1) | (set == 2 & f_result==1) | (set == 3)
replace all_correct_rxchw = 1 if (set == 1 & d_orszincchw == 1) | (set == 2 & f_act24cchw == 1) | (set == 3 & fb_flabchw == 1)

*Correct treatment from a CHW, all 3 illnesses among all cases (for malaria this includes ACT w/in 24 hours)
***This includes only confirmed cases of malaria in the denominator
gen all_correct_rxoth = 0 if (set == 1) | (set == 2 & f_result==1) | (set == 3)
replace all_correct_rxoth = 1 if (set == 1 & d_orszincoth == 1) | (set == 2 & f_act24coth == 1) | (set == 3 & fb_flaboth == 1)

*Correct treatment from a CHW, all 3 illnesses (for malaria this includes ACT w/in 24 hours)
***This includes only confirmed cases of malaria in the denominator and cases managed by a CHW
gen all_correct_rxchw2 = 0 if (set == 1 & d_chw==1) | (set == 2 & f_result==1 & f_chw==1) | (set == 3 & fb_chw==1)
replace all_correct_rxchw2 = 1 if (set == 1 & d_orszincchw2 == 1) | (set == 2 & f_act24cchw2 == 1) | (set == 3 & fb_flabchw2 == 1)

*Correct treatment from provider other than CHW, all 3 illnesses (for malaria this includes ACT w/in 24 hours)
***This includes only confirmed cases of malaria in the denominator 
gen all_correct_rxoth2 = 0 if (set == 1 & d_orszincoth2 !=.) | (set == 2 & f_act24coth2 !=.) | (set == 3 & fb_flaboth2 !=.)
replace all_correct_rxoth2 = 1 if (set == 1 & d_orszincoth2 == 1) | (set == 2 & f_act24coth2 == 1) | (set == 3 & fb_flaboth2 == 1)

*Received 1st dose treatment in front of CHW, all 3 illnesses (for diarrhea this includes both ORS and zinc)
*note to adapt q711, q716, q816, q914 to ensure it reflects CHW option (16 in Abiq questionnaire)
gen all_firstdose = .
replace all_firstdose = 0 if (q711==16 & q716==16 & set == 1 ) | (q816==16 & set == 2) | (q914==16 & set == 3 & fb_flabchw == 1)
replace all_firstdose = 1 if (set == 1 & q711==16 & d_ors_chwp==1 & q716==16 & d_zinc_chwp==1) | (set==2 & q816==16 & f_act_chwp==1) | (set==3 & q914==16 & fb_flab_chwp==1)

*Received counseling on treatment administration from CHW, all 3 illnesses 
*note to adapt q711, q716, q816, q914 to ensure it reflects CHW option (16 in Abia questionnaire)
gen all_counsel = .
replace all_counsel = 0 if (q711==16 & q716==16 & set==1 ) | (q816==16 & set==2) | (q914==16 & set==3 & fb_flabchw==1)
replace all_counsel = 1 if (set==1 & d_bothcounsel==1) | (set==2 & f_act_chwc==1) | (set==3 & fb_flab_chwc==1)

*Referred to health facility by CHW, all 3 illnesses
gen all_chwrefer = .
replace all_chwrefer = 0 if (d_chwrefer!=. & set==1 ) | (f_chwrefer!=. & set==2) | (fb_chwrefer!=. & set==3)
replace all_chwrefer = 1 if (set==1 & d_chwrefer==1) | (set==2 & f_chwrefer==1) | (set==3 & fb_chwrefer==1)

*Adhered to referral advice from CHW, all 3 illnesses
gen all_referadhere = .
replace all_referadhere = 0 if (d_chwrefer==1 & set==1 ) | (f_chwrefer==1 & set==2) | (fb_chwrefer==1 & set==3)
replace all_referadhere = 1 if (set==1 & d_referadhere==1) | (set==2 & f_referadhere==1) | (set==3 & fb_referadhere==1)

*Received a follow-up visit from a CHW, all 3 illnesses
gen all_followup = .
replace all_followup = 0 if (d_chw==1 & set == 1 ) | (f_chw==1 & set == 2) | (fb_chw==1 & set == 3)
replace all_followup = 1 if (set==1 & d_chw_fu==1) | (set==2 & f_chw_fu==1) | (set==3 & fb_chw_fu==1)

*decided to seek care jointly, all 3 illnesses
gen all_joint = .
replace all_joint = 0 if maritalstat==1
replace all_joint = 1 if (set==1 & d_joint==1) | (set==2 & f_joint==1) | (set==3 & fb_joint==1)

*did not seek care, all 3 illnesses
gen all_nocare = 0
replace all_nocare = 1 if (set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1)

*sought care but not from a CHW, all 3 illnesses
gen all_nocarechw = .
replace all_nocarechw = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_nocarechw = 1 if (set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1)

*where sought care first, all 3 illnesses
gen all_fcs_hosp = .
replace all_fcs_hosp = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_hosp = 1 if (set == 1 & d_fcs_hosp == 1) | (set == 2 & f_fcs_hosp == 1) | (set == 3 & fb_fcs_hosp == 1)

gen all_fcs_hcent = .
replace all_fcs_hcent = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_hcent = 1 if (set == 1 & d_fcs_hcent == 1) | (set == 2 & f_fcs_hcent == 1) | (set == 3 & fb_fcs_hcent == 1)

gen all_fcs_hpost = .
replace all_fcs_hpost = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_hpost = 1 if (set == 1 & d_fcs_hpost == 1) | (set == 2 & f_fcs_hpost == 1) | (set == 3 & fb_fcs_hpost == 1)

gen all_fcs_ngo = .
replace all_fcs_ngo = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_ngo = 1 if (set == 1 & d_fcs_ngo == 1) | (set == 2 & f_fcs_ngo == 1) | (set == 3 & fb_fcs_ngo == 1)

gen all_fcs_clin = .
replace all_fcs_clin = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_clin = 1 if (set == 1 & d_fcs_clin == 1) | (set == 2 & f_fcs_clin == 1) | (set == 3 & fb_fcs_clin == 1)

gen all_fcs_chw = .
replace all_fcs_chw = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_chw = 1 if (set == 1 & d_fcs_chw == 1) | (set == 2 & f_fcs_chw == 1) | (set == 3 & fb_fcs_chw == 1)

gen all_fcs_trad = .
replace all_fcs_trad = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_trad = 1 if (set == 1 & d_fcs_trad == 1) | (set == 2 & f_fcs_trad == 1) | (set == 3 & fb_fcs_trad == 1)

gen all_fcs_ppmv = .
replace all_fcs_ppmv = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_ppmv = 1 if (set == 1 & d_fcs_ppmv == 1) | (set == 2 & f_fcs_ppmv == 1) | (set == 3 & fb_fcs_ppmv == 1)

gen all_fcs_phar = .
replace all_fcs_phar = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_phar = 1 if (set == 1 & d_fcs_phar == 1) | (set == 2 & f_fcs_phar == 1) | (set == 3 & fb_fcs_phar == 1)

gen all_fcs_friend = .
replace all_fcs_friend = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_friend = 1 if (set == 1 & d_fcs_friend == 1) | (set == 2 & f_fcs_friend == 1) | (set == 3 & fb_fcs_friend == 1)

gen all_fcs_mark = .
replace all_fcs_mark = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_mark = 1 if (set == 1 & d_fcs_mark == 1) | (set == 2 & f_fcs_mark == 1) | (set == 3 & fb_fcs_mark == 1)

gen all_fcs_other = .
replace all_fcs_other = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_other = 1 if (set == 1 & d_fcs_other == 1) | (set == 2 & f_fcs_other == 1) | (set == 3 & fb_fcs_other == 1)

*sources of care, all 3 illnesses
gen all_cs_hosp = .
replace all_cs_hosp = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_hosp = 1 if (set == 1 & d_cs_hosp == 1) | (set == 2 & f_cs_hosp == 1) | (set == 3 & fb_cs_hosp == 1)

gen all_cs_hcent = .
replace all_cs_hcent = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_hcent = 1 if (set == 1 & d_cs_hcent == 1) | (set == 2 & f_cs_hcent == 1) | (set == 3 & fb_cs_hcent == 1)

gen all_cs_hpost = .
replace all_cs_hpost = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_hpost = 1 if (set == 1 & d_cs_hpost == 1) | (set == 2 & f_cs_hpost == 1) | (set == 3 & fb_cs_hpost == 1)

gen all_cs_ngo = .
replace all_cs_ngo = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_ngo = 1 if (set == 1 & d_cs_ngo == 1) | (set == 2 & f_cs_ngo == 1) | (set == 3 & fb_cs_ngo == 1)

gen all_cs_clin = .
replace all_cs_clin = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_clin = 1 if (set == 1 & d_cs_clin == 1) | (set == 2 & f_cs_clin == 1) | (set == 3 & fb_cs_clin == 1)

gen all_cs_chw = .
replace all_cs_chw = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_chw = 1 if (set == 1 & d_cs_chw == 1) | (set == 2 & f_cs_chw == 1) | (set == 3 & fb_cs_chw == 1)

gen all_cs_trad = .
replace all_cs_trad = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_trad = 1 if (set == 1 & d_cs_trad == 1) | (set == 2 & f_cs_trad == 1) | (set == 3 & fb_cs_trad == 1)

gen all_cs_ppmv = .
replace all_cs_ppmv = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_ppmv = 1 if (set == 1 & d_cs_ppmv == 1) | (set == 2 & f_cs_ppmv == 1) | (set == 3 & fb_cs_ppmv == 1)

gen all_cs_phar = .
replace all_cs_phar = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_phar = 1 if (set == 1 & d_cs_phar == 1) | (set == 2 & f_cs_phar == 1) | (set == 3 & fb_cs_phar == 1)

gen all_cs_friend = .
replace all_cs_friend = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_friend = 1 if (set == 1 & d_cs_friend == 1) | (set == 2 & f_cs_friend == 1) | (set == 3 & fb_cs_friend == 1)

gen all_cs_mark = .
replace all_cs_mark = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_mark = 1 if (set == 1 & d_cs_mark == 1) | (set == 2 & f_cs_mark == 1) | (set == 3 & fb_cs_mark == 1)

gen all_cs_other = .
replace all_cs_other = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_other = 1 if (set == 1 & d_cs_other == 1) | (set == 2 & f_cs_other == 1) | (set == 3 & fb_cs_other == 1)

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
*Note: 2 missing responses under q729, 4 from q826, and 6 missing/don't know responses from q924
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

gen all_nocarechw_x = .
replace all_nocarechw_x = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
replace all_nocarechw_x = 1 if (set == 1 & q708b_x == 1) | (set == 2 & q808b_x == 1) | (set == 3 & q908b_x == 1)

gen all_nocarechw_z = .
replace all_nocarechw_z = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
replace all_nocarechw_z = 1 if (set == 1 & q708b_z == 1) | (set == 2 & q808b_z == 1) | (set == 3 & q908b_z == 1)

*Correct treatment, all 3 illnesses (diarrhea = ORS + zinc, confirmed malaria case (+RDT) = ACT w/in 24 hrs, fb = amoxicillin)
***This includes only confirmed cases of malaria in the denominator 
gen all_correct_rxc = 0 if (set==1) | (set==2 & f_result==1) | (set==3)
replace all_correct_rxc = 1 if (set == 1 & d_orszinc == 1) | (set == 2 & f_act24c == 1) | (set == 3 & fb_flab == 1)

*Correct treatment from a CHW, all 3 illnesses, among all cases
***This includes only confirmed cases of malaria in the denominator 
gen all_correct_rxchwc = 0 if (set==1) | (set==2 & f_result==1) | (set==3)
replace all_correct_rxchwc = 1 if (set == 1 & d_orszincchw == 1) | (set == 2 & f_act24cchw == 1) | (set == 3 & fb_flabchw == 1)

*Correct treatment from a CHW, all 3 illnesses, among those that sought care from chw
***This includes This includes only confirmed cases of malaria in the denominator and those that sought care from a CHW
gen all_correct_rxchwc2 = .
replace all_correct_rxchwc2 = 0 if (set == 1 & d_chw == 1) | (set == 2 & f_resultchw==1) | (set == 3 & fb_chw == 1)
replace all_correct_rxchwc2 = 1 if (set == 1 & d_orszincchw2 == 1) | (set == 2 & f_act24cchw2 == 1) | (set == 3 & fb_flabchw2 == 1)

save "cg_combined_hh_roster_overall_final.dta", replace
