****************************************
** DRC RAcE Household Survey Analysis **
**          January 30, 2017          **
**           Allison Schmale          **
****************************************
*Reviewed and revised by Samantha Herrera and Kirsten Zalisk
*Final updates made on May 11, 2017

cd "C:\Users\26167\Documents\WHO RAcE\Endline household survey\DRC"
use "DRC_combined_BL_EL.dta", clear

set more off
lab define yn 0 "No" 1 "Yes"
svyset hhclust
numlabel, add

*******************MODULE 1: SICK CHILD INFORMATION*****************************
*Create binary variables for child that has illness from line number variable
tab q7child, m
tab q8child, m
tab q9child, m

recode q7child 1 2 3 4=1 96 0=0, gen (d_case)
recode q8child 1 2 3 4=1 96 0=0, gen (f_case)
recode q9child 1 2 3 4 5=1 96 0=0, gen (fb_case)

tab d_case survey, col
tab f_case survey, col
tab fb_case survey, col

*Sex of sick children by fever, diarrhea, and fast breathing
tab f_sex survey, m
svy: tab f_sex survey, col ci pear
tab d_sex survey, m
svy: tab d_sex survey, col ci pear
tab fb_sex survey, m
svy: tab fb_sex survey, col ci pear

/*
gen child_sex = f_sex
replace child_sex = d_sex if child_sex == .
replace child_sex = fb_sex if child_sex == .
lab var child_sex "Sex of sick child"
lab def sex 1 "male" 2 "female", modify
lab val child_sex sex
tab child_sex, m
tab child_sex survey, col
svy: tab child_sex survey, col ci pear

*Age of sick children by fever, diarrhea, and fast breathing
sort survey
by survey: sum f_age
by survey: sum d_age
by survey: sum fb_age
*broken down into categories defined in table
tab f_age, m
tab d_age, m
tab fb_age, m

gen child_age = f_age
replace child_age = d_age if child_age == .
replace child_age = fb_age if child_age == .
recode child_age 0/11=1 12/23=2 24/35=3 36/47=4 48/59=5, gen (agecat)
lab var agecat "Age in months for child"
lab def age_cat 1 "0-11 months" 2 "12-23 months" 3 "24-35 months" 4 "36-47 months" 5 "48-59 months"
lab val agecat age_cat
tab agecat survey, m

*/

*Two week history of illnesses by illness
tab f_case survey, col
tab d_case survey, col
tab fb_case survey, col

*Average number of illnesses
egen ave_illness = anycount (f_case d_case fb_case), values(1)
lab var ave_illness "Number of illnesses reported"
tab ave_illness, m
sort survey
by survey: summarize ave_illness, detail

*Total number of sick children included
gen tot_children = 0
replace tot_children = 1 if q109ch >= 1 & q109ch !=.
replace tot_children = tot_children + 1 if q110ch >= 1 & q110ch !=. & q110ch != q109ch
replace tot_children = tot_children + 1 if q111ch >= 1 & q111ch !=. & q111ch != q110ch & q111ch != q109ch
tab tot_children survey

preserve
collapse (sum) tot_children, by(survey)
tab tot_children survey
restore


***then calculated by manually 1*A+2*B+3*C= 742 total number of sick children


*Cases of illness in survey
by survey: tab f_case, m
by survey: tab d_case, m
by survey: tab fb_case, m

********************MODULE 2: CAREGIVERS' INFORMATION***************************

*Number of caregivers included in survey
tab cgnumber, m
gen tot_cg = .
replace tot_cg = 1 if cgnumber != .
lab var tot_cg "Total number of CG's interviewed"
tab tot_cg, m
sort survey 
by survey: tab tot_cg, m

*Caregiver's sex
tab q202a, m
gen cg_sex = q202a
replace cg_sex = . if q202a == 9
lab var cg_sex "Sex of caregiver"
lab val cg_sex sex
tab cg_sex, m
tab cg_sex survey, col

*Caregiver's age
tab q202, m
by survey: summarize q202
recode q202 min/24=1 25/34=2 35/44=3 45/max=4, gen (cg_agecat)
lab var cg_agecat "Age of caregiver in years"
lab def age_cat2 1 "15-24 yrs" 2 "25-34 yrs" 3 "35-44 yrs" 4 "45 yrs and older"
lab val cg_agecat age_cat2
tab cg_agecat, m
tab cg_agecat survey, col

*Caregiver's education
tab q203 survey, m
tab q204 survey, m
tab q205 survey, m
recode q203 q204 q205 (9 99 = .)
recode q204 (0 = 1)
tab q203, m
tab q204, m
tab q205, m
*three observations had only missing info for education questions
recode q203 1=1 2=0, gen (cg_everedu)
tab cg_everedu, m
gen cg_educat = .
replace cg_educat = 0 if cg_everedu == 0 | q204 == 0
replace cg_educat = 1 if cg_everedu == 1 & q204 == 1 & q205 <= 4
replace cg_educat = 2 if cg_everedu == 1 & q204 == 1 & q205 >= 5
replace cg_educat = 3 if cg_everedu == 1 & q204 == 2
lab var cg_educat "Education level of Caregiver"
lab def cg_edu 0 "No education" 1 "Primary school 1-4" 2 "Primary school 5 or more" 3 "Secondary or higher"
lab val cg_educat cg_edu
tab cg_educat, m
tab cg_educat survey, col
*for two of the observations they have a 'yes' for ever having education but missing information for the 
*other two questions

*Caregiver's marital status (endline only)
tab q401, m
gen union = 0 if survey == 2
replace union = 1 if q401 == 1 | q401 == 2
tab union survey, m

*Married and living with partner--Endline only
tab q402, m
gen cohabitate = .
replace cohabitate = 0 if q402 == 2 
replace cohabitate = 1 if q401 == 1 
lab var cohabitate "Married and living with partner"
lab val cohabitate yn
tab cohabitate, m
svy: tab cohabitate survey, col ci pear

*************MODULE 4: HOUSEHOLD DECISION MAKING: ENDLINE ONLY******************
*Caregiver living with partner
tab q402, m

*Income decision maker (Indicator 19, optional)
tab q403, m
recode q403 6 = 4, gen (dm_income)
lab var dm_income "Income decision maker"
lab def dmincome 1 "Respondent" 2 "Husband, partner" 3 "Husband and respondent jointly" 4 "Someone else"
lab val dm_income dmincome
tab dm_income, m

*Health care decision maker (Indicator 20, optional)
tab q404, m
recode q404 6 = 4, gen (dm_health)
lab var dm_health "Who makes decsions about seeking health care"
lab val dm_health dmincome
tab dm_health, m

recode dm_health 1 2 4 = 0 3 = 1, gen (dm_health_joint)
lab var dm_health_joint "Caregiver and partner makes joint decisions about seeking health care"
lab val dm_health_joint yn
tab dm_health_joint, m

*********************MODULE 6: CAREGIVER ILLNESS KNOWLEDGE**********************
*denominator--all caregivers completing the survey
gen cg_survey = .
replace cg_survey = 1 if cgnumber >= 1 & cgnumber != .
lab var cg_survey "Caregivers participating in survey"
tab cg_survey, m

*Infant under 2 months
tab q601a, m
gen ds_under2 = .
replace ds_under2 = 0 if cg_survey == 1
replace ds_under2 = 1 if q601a == "A"
lab var ds_under2 "Infant under two months"
lab val ds_under2 yn 
tab ds_under2, m
*High fever
tab q601b, m
gen ds_hifever = .
replace ds_hifever = 0 if cg_survey == 1
replace ds_hifever = 1 if q601b == "B"
lab var ds_hifever "High fever"
lab val ds_hifever yn 
tab ds_hifever, m
*Fever for 7 days or more
tab q601c, m
gen ds_7daysfever = .
replace ds_7daysfever = 0 if cg_survey == 1
replace ds_7daysfever = 1 if q601c == "C"
lab var ds_7daysfever "Fever for 7 days or more"
lab val ds_7daysfever yn 
tab ds_7daysfever, m
*Fever
tab q601d, m
gen ds_fever = .
replace ds_fever = 0 if cg_survey == 1
replace ds_fever = 1 if q601d == "D"
lab var ds_fever "Fever"
lab val ds_fever yn 
tab ds_fever, m
*Bloody diarrhea
tab q601f survey, m
tab q601e survey, m
gen ds_blddia = .
replace ds_blddia = 0 if cg_survey == 1
replace ds_blddia = 1 if (q601f == "F" & survey == 2) | (q601e == "E" & survey == 1)
lab var ds_blddia "Bloody diarrhea"
lab val ds_blddia yn 
tab ds_blddia, m
*Diarrhea with dehydration
tab q601g survey, m
tab q601f survey, m
gen ds_dyhdia = .
replace ds_dyhdia = 0 if cg_survey == 1
replace ds_dyhdia = 1 if (q601g == "G" & survey == 2) | (q601f == "F" & survey == 1)
lab var ds_dyhdia "Bloody diarrhea"
lab val ds_dyhdia yn 
tab ds_dyhdia, m
*Diarrhea for 14 days or more
tab q601h survey, m
tab q601g survey, m
gen ds_14daysdia = .
replace ds_14daysdia = 0 if cg_survey == 1
replace ds_14daysdia = 1 if (q601h == "H" & survey == 2) | (q601g == "G" & survey == 1)
lab var ds_14daysdia "Diarrhea for 14 days"
lab val ds_14daysdia yn 
tab ds_14daysdia, m
*Diarrhea for a long time
tab q601i survey, m
tab q601h survey, m
gen ds_lgtmdia = .
replace ds_lgtmdia = 0 if cg_survey == 1
replace ds_lgtmdia = 1 if (q601i == "I" & survey == 2) | (q601h == "H" & survey == 1)
lab var ds_lgtmdia "Diarrhea for a long time"
lab val ds_lgtmdia yn 
tab ds_lgtmdia, m
*Fast breathing
tab q601j survey, m
tab q601i survey, m
gen ds_fb = .
replace ds_fb = 0 if cg_survey == 1
replace ds_fb = 1 if (q601j == "J" & survey == 2) | (q601i == "I" & survey == 1)
lab var ds_fb "Fast breathing"
lab val ds_fb yn 
tab ds_fb, m
*Cough for 21 days or more
tab q601m survey, m
tab q601j survey, m
gen ds_21daycough = .
replace ds_21daycough = 0 if cg_survey == 1
replace ds_21daycough = 1 if (q601m == "M" & survey == 2) | (q601j == "J" & survey == 1)
lab var ds_21daycough "Cough for 21 days or more"
lab val ds_21daycough yn 
tab ds_21daycough, m
*Cough for a long time
tab q601n survey, m
tab q601k survey, m
gen ds_lgtmcough = .
replace ds_lgtmcough = 0 if cg_survey == 1
replace ds_lgtmcough = 1 if (q601n == "N" & survey == 2) | (q601k == "K" & survey == 1)
lab var ds_lgtmcough "Cough for a long time"
lab val ds_lgtmcough yn 
tab ds_lgtmcough, m
*Refuse to breastfeed
tab q601o survey, m
tab q601l survey, m
gen ds_nobf = .
replace ds_nobf = 0 if cg_survey == 1
replace ds_nobf = 1 if (q601o == "O" & survey == 2) | (q601l == "L" & survey == 1)
lab var ds_nobf "Refuse to breastfeed"
lab val ds_nobf yn 
tab ds_nobf, m
*Not able to eat or drink
tab q601p survey, m
tab q601m survey, m
gen ds_noeat = .
replace ds_noeat = 0 if cg_survey == 1
replace ds_noeat = 1 if (q601p == "P" & survey == 2) | (q601m == "M" & survey == 1)
lab var ds_noeat "Not able to eat or drink"
lab val ds_noeat yn 
tab ds_noeat, m
*Vomits everything
tab q601q survey, m
tab q601n survey, m
gen ds_vomit = .
replace ds_vomit = 0 if cg_survey == 1
replace ds_vomit = 1 if (q601q == "Q" & survey == 2) | (q601n == "N" & survey == 1)
lab var ds_vomit "Vomits everything"
lab val ds_vomit yn 
tab ds_vomit, m
*Lean arms and swelling of feet
tab q601r survey, m
tab q601o survey, m
gen ds_armfeet = .
replace ds_armfeet = 0 if cg_survey == 1
replace ds_armfeet = 1 if (q601r == "R" & survey == 2) | (q601o == "O" & survey == 1)
lab var ds_armfeet "Lean arms and swelling feet"
lab val ds_armfeet yn 
tab ds_armfeet, m
*Convulsions
tab q601s survey, m
tab q601p survey, m
gen ds_convul = .
replace ds_convul = 0 if cg_survey == 1
replace ds_convul = 1 if (q601s == "S" & survey == 2) | (q601p == "P" & survey == 1)
lab var ds_convul "Convulsions"
lab val ds_convul yn 
tab ds_convul, m
*Loss of consciousness
tab q601t survey, m
tab q601q survey, m
gen ds_conscious = .
replace ds_conscious = 0 if cg_survey == 1
replace ds_conscious = 1 if (q601t == "T" & survey == 2) | (q601q == "Q" & survey == 1)
lab var ds_conscious "Loss of consciousness"
lab val ds_conscious yn 
tab ds_conscious, m
*Lethargy
tab q601u survey, m
tab q601r survey, m
gen ds_lethargy = .
replace ds_lethargy = 0 if cg_survey == 1
replace ds_lethargy = 1 if (q601u == "U" & survey == 2) | (q601r == "R" & survey == 1)
lab var ds_lethargy "Lethargy"
lab val ds_lethargy yn 
tab ds_lethargy, m
*Stiff neck
tab q601v survey, m
tab q601s survey, m
gen ds_stfneck = .
replace ds_stfneck = 0 if cg_survey == 1
replace ds_stfneck = 1 if (q601v == "V" & survey == 2) | (q601s == "S" & survey == 1)
lab var ds_stfneck "Lethargy"
lab val ds_stfneck yn 
tab ds_stfneck, m
*Don't know
tab q601z survey, m
tab q601t survey, m
gen ds_dontknow = .
replace ds_dontknow = 0 if cg_survey == 1
replace ds_dontknow = 1 if (q601z == "Z" & survey == 2) | (q601t == "T" & survey == 1)
lab var ds_dontknow "Don't know"
lab val ds_dontknow yn 
tab ds_dontknow, m

***Endline only dangersigns 
*Diarrhea
tab q601e survey, m
gen ds_dia = .
replace ds_dia = 0 if cg_survey == 1
replace ds_dia = 1 if q601e == "E" & survey == 2
lab var ds_dia "Diarrhea"
lab val ds_dia yn 
tab ds_dia, m
*Chest in-drawing
tab q601k survey, m
gen ds_chest = .
replace ds_chest = 0 if cg_survey == 1
replace ds_chest = 1 if q601k == "K" & survey == 2
lab var ds_chest "Chest in-drawing"
lab val ds_chest yn 
tab ds_chest, m
*Cough
tab q601l survey, m
gen ds_cough = .
replace ds_cough = 0 if cg_survey == 1
replace ds_cough = 1 if q601l == "L" & survey == 2
lab var ds_cough "Cough"
lab val ds_cough yn 
tab ds_cough, m

*Caregiver knows 2 or more child illness signs (Indicator 3)
egen tot_q601 = anycount (ds_dia ds_chest ds_cough ds_under2 ds_hifever ds_7daysfever ds_fever ds_blddia ds_dyhdia ds_14daysdia ds_lgtmdia ds_fb ds_21daycough ds_lgtmcough ds_nobf ds_noeat ds_vomit ds_armfeet ds_convul ds_conscious ds_lethargy ds_stfneck), value (1)
tab tot_q601, m
gen cgknow2 = .
replace cgknow2 = 0 if cgnumber !=.
replace cgknow2 = 1 if tot_q601 >=2 & tot_q601 != .
lab var cgknow2 "Caregiver knows more than 2 child illness signs"
lab val cgknow2 yn
tab cgknow2, m
tab cgknow2 survey, col
svy: tab cgknow2 survey, col ci pear

*Caregiver knows 3 or more child illness signs (Option Indicator 3A)
gen cgknow3 = .
replace cgknow3 = 0 if cgnumber !=.
replace cgknow3 = 1 if tot_q601 >=3 & tot_q601 != .
lab var cgknow3 "Caregiver knows more than 3 child illness signs"
lab val cgknow3 yn
tab cgknow3, m
tab cgknow3 survey, col
svy: tab cgknow3 survey, col ci pear

*Knows of malaria (endline only)
tab q602, m
gen malaria = .
replace malaria = 0 if q602 == 2 | q602 == 8
replace malaria = 1 if q602 == 1
lab var malaria "Caregiver knows cause of malaria"
lab val malaria yn
tab malaria, m

*Knows mosquito bites cause malaria (endline only)
tab1 q603*
tab q603a, m
gen mal_cause = .
replace mal_cause = 0 if survey == 2
replace mal_cause = . if survey == 2 & q602 == .
replace mal_cause = 1 if q603a == "A"
lab var mal_cause "Caregiver knows mosquito bites cause malaria"
lab val mal_cause yn
tab mal_cause, m

*Knows fever is a sign of malaria (endline only)
tab1 q604*
tab q604a, m
gen mal_fever = .
replace mal_fever = 0 if survey == 2
replace mal_fever = . if survey == 2 & q602 == .
replace mal_fever = 1 if q604a == "A"
lab var mal_fever "Caregiver knows fever is a sign of malaria"
lab val mal_fever yn
tab mal_fever, m

*Knows at least 2 sympotms of malaria (endline only) (did not includ 'other')
tab1 q604*
egen tot_q604 = rownonmiss (q604a-q604i), strok
tab tot_q604, m
gen mal_know2 = .
replace mal_know2 = 0 if survey == 2
replace mal_know2 = 1 if tot_q604 >=2 & tot_q604 !=.
lab var mal_know2 "Caregiver knows 2 signs of malaria"
lab val mal_know2 yn
tab mal_know2, m

*Knows correct treatment for malaria (ACT) (endline only)
tab q605, m
gen mal_act = .
replace mal_act = 0 if survey == 2
replace mal_act = . if survey == 2 & q605 == .
replace mal_act = 1 if q605 == 1
lab var mal_act "Caregiver knows ACT is the treatment for malaria"
lab val mal_act yn
tab mal_act, m


*********MODULE 5: CAREGIVER KNOWLEDGE AND PERCEPTIONS OF iCCM CHWs*************
svyset hhclust
*Caregiver knows CHW works in the community (Indicator 1)
tab q504, m
gen chw_know = .
replace chw_know = . if q504 == 9
replace chw_know = 0 if q504 == 2 | q504 == 8 
replace chw_know = 1 if q504 == 1
lab var chw_know "Caregiver knows of CHW in community"
lab val chw_know yn
tab chw_know, m
tab chw_know survey, m
svy: tab chw_know survey, col ci pear

*Caregiver knows location of CHW
*missing observations replied they did not know of CHW in commmunity
*Not sure what the 46 zeros represent...they replied they knew of a CHW...so maybe do not know location? 
*Coded these 0's as did not know location
tab q506, m
gen chw_location = .
replace chw_location = 0 if q506 == 0 | q506 == 8
replace chw_location = 1 if q506 == 1 | q506 == 2 | q506 == 3
lab var chw_location "Knows CHW location"
lab val chw_location yn
tab chw_location, m
tab chw_location survey, m
svy: tab chw_location survey, col ci pear

*Caregiver knows CHW activities
tab1 q505*

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

svy: tab q505_a survey, col ci obs //com mobilization//
svy: tab q505_b survey, col ci obs //distribution of llins//
svy: tab q505_c survey, col ci obs //org of health campaigns
svy: tab q505_d survey, col ci obs //dissemination of health messages
svy: tab q505_e survey, col ci obs //help hang nets
svy: tab q505_f survey, col ci obs //provide health info in hhs
svy: tab q505_g survey, col ci obs //provide health info at com events
svy: tab q505_h survey, col ci obs //provide water tx tabs
svy: tab q505_i survey, col ci obs //collect info on health 
svy: tab q505_j survey, col ci obs //other preventive activity
svy: tab q505_k survey, col ci obs //refer to health facility
svy: tab q505_l survey, col ci obs //test for malaria
svy: tab q505_m survey, col ci obs //assess for sus pneumonia
svy: tab q505_n survey, col ci obs //provide tx for malaria
svy: tab q505_o survey, col ci obs //provide tx for pneumonia
svy: tab q505_p survey, col ci obs //provide ors
svy: tab q505_q survey, col ci obs //provide zinc
svy: tab q505_r survey, col ci obs //assess for malnutrition
svy: tab q505_s survey, col ci obs //follow-up sick children 
svy: tab q505_t survey, col ci obs //other curative activity

*Caregiver knows 2+ curative services among those that know there is a CHW in their community(Indicator 2)
egen tot_q505 = anycount (q505_k-q505_s), value (1)
tab tot_q505, m
tab tot_q505 survey, col
gen chw_services2 = .
replace chw_services2 = 0 if chw_know == 1
replace chw_services2 = 1 if tot_q505 >=2 & tot_q601 != . & chw_know ==1
lab var chw_services2 "Caregiver knows 2+ curative services"
lab val chw_services2 yn
tab chw_services2, m
tab chw_services2 survey, col
svy: tab chw_services2 survey, col ci pear

*All caregiver CHW perception responses
tab1 q507-q516
tab q507, m
foreach var of varlist q507-q516 {
recode `var' 2 8 =0
lab val `var' yn
}

tab1 q507-q515

*CHW is a trusted provider (Indicator 4)
tab q509, m
tab q512, m
gen chw_trusted = .
replace chw_trusted = 0 if q504 == 1
replace chw_trusted = 1 if q509 == 1 & q512 == 1
lab var chw_trusted "Caregivers trust CHWs"
lab val chw_trusted yn
tab chw_trusted, m
tab chw_trusted survey,col
svy: tab chw_trusted survey, col ci pear

*Caregiver believes the CHW provides quality services (answer yes for 3+ for q510, q511, q513, q514) (Indicator 5)
*SH Comment - recoded, incorrectly coded the denominator
tab q510, m
tab q511, m
tab q513, m
tab q514, m
egen tot_quality = anycount (q510 q511 q513 q514), value (1)
tab tot_quality, m

*recoded
gen chw_quality = .
replace chw_quality = 0 if q504==1
replace chw_quality = 1 if tot_quality==3|tot_quality==4
lab var chw_quality "Caregiver believes CHW provides quality services"
lab val chw_quality yn

*Percentage of caregivers who found the CHW at first visit (Indicator 6)
*SH Comment: not correctly coded, updated the code 
tab q724, m
tab q822, m
tab q919, m
tab q708, m
tab q808, m
tab q908, m

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

*CHW is a convenient source of treatment (Indicator 7)
tab q507, m
tab q508, m
gen chw_conv = .
replace chw_conv = 0 if q504 == 1
replace chw_conv = 1 if q507 == 1 | q508 == 1
lab var chw_conv "CHW is a convenient source of treatment)
lab val chw_conv yn
tab chw_conv, m
tab chw_conv survey, col
svy: tab chw_conv survey, col ci pear

*****************************MODULE 7: DIARRHEA*********************************
tab d_case, m
tab d_case survey, col

*Sought any advice or treatment for diarrhea
tab q703, m
gen d_soughtcare = .
replace d_soughtcare = 0 if d_case == 1 
replace d_soughtcare = 1 if q703 == 1 
lab var d_soughtcare "Sought advice or care for diarrhea"
lab val d_soughtcare yn
tab d_soughtcare, m
tab d_soughtcare survey, col
svy: tab d_soughtcare survey, col ci pear

*Sought any advice or treatment-endline only (per tables)
tab q703, m
gen d_soughtcare_el = .
replace d_soughtcare_el = 0 if d_case == 1 & survey == 2
replace d_soughtcare_el = 1 if q703 == 1 & survey == 2
lab var d_soughtcare_el "Sought advice or care for diarrhea-endline"
lab val d_soughtcare_el yn
tab d_soughtcare_el, m
tab d_soughtcare_el d_sex, col

*Sought care jointly with partner
tab q704, m
gen d_joint	= .
replace d_joint = 0 if union == 1 & d_case == 1
replace d_joint = 1 if q703 == 1 & q705a == "A" & d_joint == 0
lab var d_joint "Sought care jointly with partner"
lab val d_joint yn
tab d_joint, m
tab d_joint survey, col

*Sought care from an appropriate provider
*q706a
tab q706a, m
gen d_hosp = .
replace d_hosp = 0 if d_case == 1 & q703 == 1
replace d_hosp = 1 if q706a == "A"
lab var d_hosp "Sought care at hospital"
lab val d_hosp yn
tab d_hosp, m
tab d_hosp survey, col
*q706b
tab q706b, m
gen d_hcent = .
replace d_hcent = 0 if d_case == 1 & q703 == 1
replace d_hcent = 1 if q706b == "B"
lab var d_hcent "Sought care at health center"
lab val d_hcent yn
tab d_hcent, m
tab d_hcent survey, col
*q706c
tab q706c, m
gen d_hpost = .
replace d_hpost = 0 if d_case == 1 & q703 == 1
replace d_hpost = 1 if q706c == "C"
lab var d_hpost "Sought care at health post"
lab val d_hpost yn
tab d_hpost, m
tab d_hpost survey, col
*q706d
tab q706d, m
gen d_disp = .
replace d_disp = 0 if d_case == 1 & q703 == 1
replace d_disp = 1 if q706d == "D"
lab var d_disp "Sought care at dispensary"
lab val d_disp yn
tab d_disp, m
tab d_disp survey, col
*q706e
tab q706e, m
gen d_clinic = .
replace d_clinic = 0 if d_case == 1 & q703 == 1
replace d_clinic = 1 if q706e == "E"
lab var d_clinic "Sought care at clinic"
lab val d_clinic yn
tab d_clinic, m
tab d_clinic survey, col
*q706f
tab q706f, m
gen d_reco = .
replace d_reco = 0 if d_case == 1 & q703 == 1
replace d_reco = 1 if q706f == "F"
lab var d_reco "Sought care from ReCO"
lab val d_reco yn
tab d_reco, m
tab d_reco survey, col
*q706g
tab q706g, m
gen d_trad = .
replace d_trad = 0 if d_case == 1 & q703 == 1
replace d_trad = 1 if q706g == "G"
lab var d_trad"Sought care from traditional healer"
lab val d_trad yn
tab d_trad, m
tab d_trad survey, col
*q706h
tab q706h, m
gen d_shop = .
replace d_shop = 0 if d_case == 1 & q703 == 1
replace d_shop = 1 if q706h == "H"
lab var d_shop "Sought care from pharmacy"
lab val d_shop yn
tab d_shop, m
tab d_shop survey, col
*q706i
tab q706i, m
gen d_pharm = .
replace d_pharm = 0 if d_case == 1 & q703 == 1
replace d_pharm = 1 if q706i == "I"
lab var d_pharm "Sought care from pharmacy"
lab val d_pharm yn
tab d_pharm, m
tab d_pharm survey, col
*q706j
tab q706j, m
gen d_friend = .
replace d_friend = 0 if d_case == 1 & q703 == 1
replace d_friend = 1 if q706j == "J"
lab var d_friend "Sought care from friend or parent"
lab val d_friend yn
tab d_friend, m
tab d_friend survey, col
*q706k
tab q706k, m
gen d_market = .
replace d_market = 0 if d_case == 1 & q703 == 1
replace d_market = 1 if q706k == "K"
lab var d_market "Sought care from market"
lab val d_market yn
tab d_market, m
tab d_market survey, col
*q706x
tab q706x, m
gen d_other = .
replace d_other = 0 if d_case == 1 & q703 == 1
replace d_other = 1 if q706x == "X"
lab var d_other "Sought care from other"
lab val d_other yn
tab d_other, m
tab d_other survey, col

*total number of providers visited 
*SH Comment: Added in this variable in case it is needed

foreach x of varlist q706a-q706x {
  replace `x' = "" if `x' =="."
}
egen d_provtot = rownonmiss(q706a-q706x),strok
replace d_provtot = . if d_case != 1
lab var d_provtot "Total number of providers where sought care"
tab d_provtot survey, col

gen d_appprov = .
replace d_appprov = 0 if d_case==1 
replace d_appprov = 1 if (d_hosp == 1 | d_hcent == 1 | d_hpost == 1 | d_disp == 1 | d_clinic == 1 | d_reco == 1) 
lab var d_appprov "CG sought care from an appropriate provider for diarrhea"
lab val d_appprov yn
tab d_appprov, m
tab d_appprov survey, col

*Sought treatment from a CHW
tab q706f, m
gen d_chw = .
replace d_chw = 0 if d_case==1 
replace d_chw = 1 if d_reco == 1 
lab var d_chw "CG sought treatment from a CHW for diarrhea"
lab val d_chw yn
tab d_chw, m
tab d_chw d_sex if survey == 2, col

*first source of care locations - diarrhea
gen d_fcs_hosp= 1 if q708 == "A" 
gen d_fcs_hcent = 1 if q708 == "B" 
gen d_fcs_hpost = 1 if q708 == "C"
gen d_fcs_disp = 1 if q708 == "D" 
gen d_fcs_clinic = 1 if q708 == "E"
gen d_fcs_reco = 1 if q708 == "F"
gen d_fcs_trad = 1 if q708 == "G"
gen d_fcs_shop = 1 if q708 == "H"
gen d_fcs_pharm = 1 if q708 == "I"
gen d_fcs_friend = 1 if q708 == "J"
gen d_fcs_market = 1 if q708 == "K"
gen d_fcs_other = 1 if q708 == "X"

replace d_fcs_hosp = 1 if q706a == "A" & d_provtot == 1
replace d_fcs_hcent = 1 if q706b == "B" & d_provtot == 1
replace d_fcs_hpost = 1 if q706c == "C" & d_provtot == 1
replace d_fcs_disp = 1 if q706d == "D" & d_provtot == 1
replace d_fcs_clinic = 1 if q706e == "E" & d_provtot == 1
replace d_fcs_reco = 1 if q706f == "F" & d_provtot == 1
replace d_fcs_trad = 1 if q706g == "G" & d_provtot == 1
replace d_fcs_shop = 1 if q706h == "H" & d_provtot == 1
replace d_fcs_pharm = 1 if q706i == "I" & d_provtot == 1
replace d_fcs_friend = 1 if q706j == "J" & d_provtot == 1
replace d_fcs_market = 1 if q706k == "K" & d_provtot == 1
replace d_fcs_other = 1 if q706x == "X" & d_provtot == 1

foreach x of varlist d_fcs_* {
  replace `x' = 0 if d_case == 1 & q703 == 1 & `x' ==.
  lab val `x' yn
}

*Sought treatment from CHW first
tab q708, m
gen d_chwfirst = .
replace d_chwfirst = 0 if d_case == 1 
replace d_chwfirst = 1 if q708 == "F" 
replace d_chwfirst = 1 if q706f == "F" & d_provtot == 1
lab var d_chwfirst "Sought treatment for diarrhea from CHW first"
lab val d_chwfirst yn
tab d_chwfirst, m
tab d_chwfirst d_sex, col


***New variable for second table in careseeking tab
*visited an CHW as first (*or only*) source of care
gen d_chwfirst_anycare = .
replace d_chwfirst_anycare = 0 if d_case == 1 & q703 == 1
replace d_chwfirst_anycare = 1 if q708 == "F"
replace d_chwfirst_anycare = 1 if q706f == "F" & d_provtot == 1
lab var d_chwfirst_anycare "Sought care from CHW first among those who sought any care"
lab val d_chwfirst_anycare yn
tab d_chwfirst_anycare survey, col

*Treatment for Diarrhea
*ORS
tab q709a, m
tab q709b, m
gen d_ors = .
replace d_ors = 0 if d_case == 1 
replace d_ors = 1 if q709a == 1 | q709b == 1
lab var d_ors "Used ORS treatment for diarrhea"
lab val d_ors yn
tab d_ors, m
tab d_ors survey, col
*Government recommended home made fluid
tab q709c, m
tab q709c survey, col
gen d_hmfl = .
replace d_hmfl = 0 if d_case == 1 
replace d_hmfl = 1 if q709c == 1 
lab var d_hmfl "Used gov't recommended fluid for diarrhea"
lab val d_hmfl yn
tab d_hmfl, m
tab d_hmfl d_sex, col

*Child with diarrhea given zinc
tab q715, m
gen d_zinc = .
replace d_zinc = 0 if d_case == 1 
replace d_zinc = 1 if q715 == 1
lab var d_zinc "Child given zinc for diarrhea"
lab val d_zinc yn
tab d_zinc, m
tab d_zinc survey, col

*Child with diarrhea given ORS and zinc for diarrhea
gen d_orszinc = .
replace d_orszinc = 0 if d_case == 1
replace d_orszinc = 1 if (q709a == 1|q709b==1) & q715 == 1
lab var d_orszinc "Child with diarrhea is given ORS and zinc"
lab val d_orszinc yn
tab d_orszinc, m
tab d_orszinc survey, col

*Child recieved ORS and Zinc from CHW
tab q711, m
tab q716, m
gen d_orszincchw = .
replace d_orszincchw = 0 if d_case==1
replace d_orszincchw = 1 if q711 == 16 & q716 == 16
lab var d_orszincchw "Child recieved ORS and ZN from CHW"
lab val d_orszincchw yn
tab d_orszincchw, m
tab d_orszincchw survey, col

*Child recieved ORS from CHW
tab q711, m
tab q716, m
gen d_orschw = .
replace d_orschw = 0 if d_case==1
replace d_orschw = 1 if q711 == 16 
replace d_orschw = . if d_ors == 1 & q711 == .
lab var d_orschw "Child recieved ORS from CHW"
lab val d_orschw yn
tab d_orschw, m
tab d_orschw survey, col

*Child recieved ORS from CHW
tab q711, m
tab q716, m
gen d_zincchw = .
replace d_zincchw = 0 if d_case==1
replace d_zincchw = 1 if q716 == 16 
replace d_zincchw = . if d_zinc == 1 & q716 == .
lab var d_zincchw "Child recieved zinc from CHW"
lab val d_zincchw yn
tab d_zincchw, m
tab d_zincchw survey, col

*treated with ORS AND Zinc by CHW, among those who sought care from a CHW
gen d_orszincchw2 = .
replace d_orszincchw2 = 0 if d_chw == 1
replace d_orszincchw2 = 1 if d_orszincchw == 1 & d_chw == 1
lab var d_orszincchw2 "Got ORS & zinc from CHW, among those who sought care from a CHW"
lab val d_orszincchw2 yn
tab d_orszincchw2 survey, col

*Child recieved ORS from CHW
tab q711, m
tab q716, m
gen d_orschw2 = .
replace d_orschw2 = 0 if d_chw == 1
replace d_orschw2 = 1 if d_orschw == 1 & d_chw == 1 
replace d_orschw2 = . if d_ors == 1 & q711 == .
lab var d_orschw2 "Child recieved ORS from CHW"
lab val d_orschw2 yn
tab d_orschw2, m
tab d_orschw2 survey, col

*Child recieved ORS from CHW
tab q711, m
tab q716, m
gen d_zincchw2 = .
replace d_zincchw2 = 0 if d_chw == 1
replace d_zincchw2 = 1 if d_zincchw == 1 & d_chw == 1 
replace d_zincchw2 = . if d_zinc == 1 & q716 == .
lab var d_zincchw2 "Child recieved zinc from CHW"
lab val d_zincchw2 yn
tab d_zincchw2, m
tab d_zincchw2 survey, col

*treated with ORS AND Zinc by provider other than CHW (INDICATOR 14A)
gen d_orszincoth = 0
replace d_orszincoth = 1 if d_orszinc == 1 & q711 != 16 & q716 != 16
replace d_orszincoth =. if d_case != 1
lab var d_orszincoth "Took both ORS and zinc for diarrhea from a provider other than CHW"
lab val d_orszincoth yn
tab d_orszincoth survey, col

*treated with ORS AND Zinc by provider other than CHW (INDICATOR 14A)
gen d_orszincoth2 = 0 if (d_provtot == 1 & d_chw != 1) | (d_provtot >= 2 & d_provtot != .)
replace d_orszincoth2 = 1 if d_orszincoth == 1 & ((d_provtot == 1 & d_chw != 1) | (d_provtot >= 2 & d_provtot != .))
lab var d_orszincoth2 "Took both ORS and zinc for diarrhea from a provider other than CHW"
lab val d_orszincoth2 yn
tab d_orszincoth2 survey, col

*Child recieved ORS from CHW
gen d_orsoth = .
replace d_orsoth = 0 if d_case==1
replace d_orsoth = 1 if q711 != 16 & d_ors == 1
replace d_orsoth = . if d_ors == 1 & q711 == .
lab var d_orsoth "Child recieved ORS from provider other than CHW"
lab val d_orsoth yn
tab d_orsoth, m
tab d_orsoth survey, col

*Child recieved ORS from CHW
gen d_zincoth = .
replace d_zincoth = 0 if d_case==1
replace d_zincoth = 1 if q716 != 16 & d_zinc == 1
replace d_zincoth = . if d_zinc == 1 & q716 == .
lab var d_zincoth "Child recieved zinc from provider other than CHW"
lab val d_zincoth yn
tab d_zincoth, m
tab d_zincoth survey, col

*treated with ORS by provider other than CHW (INDICATOR 14A)
gen d_orsoth2 = 0 if (d_provtot == 1 & d_chw != 1) | (d_provtot >= 2 & d_provtot != .)
replace d_orsoth2 = 1 if d_orsoth == 1 & ((d_provtot == 1 & d_chw != 1) | (d_provtot >= 2 & d_provtot != .))
lab var d_orsoth2 "Took ORS for diarrhea from a provider other than CHW"
lab val d_orsoth2 yn
tab d_orsoth2 survey, col

*treated with zinc by provider other than CHW (INDICATOR 14A)
gen d_zincoth2 = 0 if (d_provtot == 1 & d_chw != 1) | (d_provtot >= 2 & d_provtot != .)
replace d_zincoth2 = 1 if d_zincoth == 1 & ((d_provtot == 1 & d_chw != 1) | (d_provtot >= 2 & d_provtot != .))
lab var d_zincoth2 "Took zinc for diarrhea from a provider other than CHW"
lab val d_zincoth2 yn
tab d_zincoth2 survey, col

*Other Diarrhea treatments taken
*Antibiotic pill/syrup
tab q721a, m
gen d_antibps = .
replace d_antibps = 0 if d_case==1
replace d_antibps = 1 if q721a == "A"
lab var d_antibps "Given anitibiotic pill or syrup for diarrhea"
lab val d_antibps yn
tab d_antibps, m
tab d_antibps survey, col
*Antimotility pill or syrup
tab q721b, m
gen d_antimps = .
replace d_antimps = 0 if d_case==1
replace d_antimps = 1 if q721b == "B"
lab var d_antimps "Given anitimotility pill or syrup for diarrhea"
lab val d_antimps yn
tab d_antimps, m
tab d_antimps survey, col
*Other pill or syrup
tab q721c, m
gen d_otherps = .
replace d_otherps = 0 if d_case == 1
replace d_otherps = 1 if q721c == "C"
lab var d_otherps "Given other pill or syrup for diarrhea"
lab val d_otherps yn
tab d_otherps, m
tab d_otherps survey, col
*Unknown pill or syrup
tab q721d, m
gen d_unknownps = .
replace d_unknownps = 0 if d_case == 1
replace d_unknownps = 1 if q721d == "D"
lab var d_unknownps "Given unknown pill or syrup for diarrhea"
lab val d_unknownps yn
tab d_unknownps, m
tab d_unknownps survey, col
*Antibiotic injection
tab q721e, m
gen d_anti_inj = .
replace d_anti_inj = 0 if d_case == 1
replace d_anti_inj = 1 if q721e == "E"
lab var d_anti_inj "Given antibiotic injection for diarrhea"
lab val d_anti_inj yn
tab d_anti_inj, m
tab d_anti_inj survey, col
*Non-antibiotic injection
tab q721f, m
gen d_nonanti_inj = .
replace d_nonanti_inj = 0 if d_case == 1
replace d_nonanti_inj = 1 if q721f == "F"
lab var d_nonanti_inj "Given non-antibiotic injection for diarrhea"
lab val d_nonanti_inj yn
tab d_nonanti_inj, m
tab d_nonanti_inj survey, col
*Unknown injection
tab q721g, m
gen d_unknown_inj = .
replace d_unknown_inj = 0 if d_case == 1
replace d_unknown_inj = 1 if q721g == "G"
lab var d_unknown_inj "Given unkown injection for diarrhea"
lab val d_unknown_inj yn
tab d_unknown_inj, m
tab d_unknown_inj survey, col
*Intravenous treatment
tab q721h, m
gen d_intrav = .
replace d_intrav = 0 if d_case == 1
replace d_intrav = 1 if q721h == "H"
lab var d_intrav "Given intravenous treatment for diarrhea"
lab val d_intrav yn
tab d_intrav, m
tab d_intrav survey, col
*Home remedy/herbal medicine
tab q721i, m
gen d_homeremedy = .
replace d_homeremedy = 0 if d_case == 1
replace d_homeremedy = 1 if q721i == "I"
lab var d_homeremedy "Given home remedy for diarrhea"
lab val d_homeremedy yn
tab d_homeremedy, m
tab d_homeremedy survey, col
*Other treatment
tab q721x, m
gen d_othertx = .
replace d_othertx = 0 if d_case == 1
replace d_othertx = 1 if q721x == "X"
lab var d_othertx "Given other treatment for diarrhea"
lab val d_othertx yn
tab d_othertx, m
tab d_othertx survey, col

*Source of treatment for Diarrhea-ORS
tab q711, m
tab q711 survey, col

*Hospital 
gen ors_hosp = .
replace ors_hosp = 0 if d_ors == 1
replace ors_hosp = 1 if q711 == 11 
lab var ors_hosp "ORS from hospital"
lab val ors_hosp yn
tab ors_hosp, m
tab ors_hosp survey, col
*Health center
gen ors_hcent = .
replace ors_hcent = 0 if d_ors == 1
replace ors_hcent = 1 if q711 == 12 
lab var ors_hcent "ORS from health center"
lab val ors_hcent yn
tab ors_hcent, m
tab ors_hcent survey, col
*Health post
gen ors_hpost = .
replace ors_hpost = 0 if d_ors == 1
replace ors_hpost = 1 if q711 == 13 
lab var ors_hpost "ORS from health post"
lab val ors_hpost yn
tab ors_hpost, m
tab ors_hpost survey, col
*Dispensary
gen ors_disp = .
replace ors_disp = 0 if d_ors == 1
replace ors_disp = 1 if q711 == 14 
lab var ors_disp "ORS from dispensary"
lab val ors_disp yn
tab ors_disp, m
tab ors_disp survey, col
*Clinic
gen ors_clinic = .
replace ors_clinic = 0 if d_ors == 1 
replace ors_clinic = 1 if q711 == 15 
lab var ors_clinic "ORS from dispensary"
lab val ors_clinic yn
tab ors_clinic, m
tab ors_clinic survey, col
*ReCO
gen ors_reco = .
replace ors_reco = 0 if d_ors == 1
replace ors_reco = 1 if q711 == 16 
lab var ors_reco "ORS from ReCO"
lab val ors_reco yn
tab ors_reco, m
tab ors_reco survey, col
*Traditional Healer
gen ors_trad = .
replace ors_trad = 0 if d_ors == 1
replace ors_trad = 1 if q711 == 21 
lab var ors_trad "ORS from traditional healer"
lab val ors_trad yn
tab ors_trad, m
tab ors_trad survey, col
*Shop
gen ors_shop = .
replace ors_shop = 0 if d_ors == 1
replace ors_shop = 1 if q711 == 22 
lab var ors_shop "ORS from shop"
lab val ors_shop yn
tab ors_shop, m
tab ors_shop survey, col
*Pharmacy
gen ors_pharm = .
replace ors_pharm = 0 if d_ors == 1
replace ors_pharm = 1 if q711 == 23 
lab var ors_pharm "ORS from pharmacy"
lab val ors_pharm yn
tab ors_pharm, m
tab ors_pharm survey, col
*Friend or parent
gen ors_friend = .
replace ors_friend = 0 if d_ors == 1
replace ors_friend = 1 if q711 == 26 
lab var ors_friend "ORS from friend or parent"
lab val ors_friend yn
tab ors_friend, m
tab ors_friend survey, col
*Market
gen ors_market = .
replace ors_market = 0 if d_ors == 1
replace ors_market = 1 if q711 == 27 
lab var ors_market "ORS from market"
lab val ors_market yn
tab ors_market, m
tab ors_market survey, col
*Other
gen ors_other = .
replace ors_other = 0 if d_ors == 1
replace ors_other = 1 if q711 == 96 
lab var ors_other "ORS from other source"
lab val ors_other yn
tab ors_other, m
tab ors_other survey, col
*Source missing
gen ors_missing = .
replace ors_missing = 0 if d_ors == 1
replace ors_missing = 1 if q711 == . 
lab var ors_missing "ORS source missing"
lab val ors_missing yn
tab ors_missing, m
tab ors_missing survey, col

*Source of treatment for diarrhea-Zinc; n=200
tab q716, m
tab q716 survey, col
*Hospital 
gen zn_hosp = .
replace zn_hosp = 0 if d_zinc == 1
replace zn_hosp = 1 if q716 == 11 & q715 == 1
lab var zn_hosp "Zinc from hospital"
lab val zn_hosp yn
tab zn_hosp, m
tab zn_hosp survey, col
*Health center
gen zn_hcent = .
replace zn_hcent = 0 if d_zinc == 1
replace zn_hcent = 1 if q716 == 12 & q715 == 1
lab var zn_hcent "Zinc from health center"
lab val zn_hcent yn
tab zn_hcent, m
tab zn_hcent survey, col
*Health post
gen zn_hpost = .
replace zn_hpost = 0 if d_zinc == 1
replace zn_hpost = 1 if q716 == 13 & q715 == 1
lab var zn_hpost "Zinc from health post"
lab val zn_hpost yn
tab zn_hpost, m
tab zn_hpost survey, col
*Dispensary
gen zn_disp = .
replace zn_disp = 0 if d_zinc == 1
replace zn_disp = 1 if q716 == 14 & q715 == 1
lab var zn_disp "Zinc from dispensary"
lab val zn_disp yn
tab zn_disp, m
tab zn_disp survey, col
*Clinic
gen zn_clinic = .
replace zn_clinic = 0 if d_zinc == 1
replace zn_clinic = 1 if q716 == 15 & q715 == 1
lab var zn_clinic "Zinc from clinic"
lab val zn_clinic yn
tab zn_clinic, m
tab zn_clinic survey, col
*ReCO
gen zn_reco = .
replace zn_reco = 0 if d_zinc == 1
replace zn_reco = 1 if q716 == 16 & q715 == 1
lab var zn_reco "Zinc from ReCO"
lab val zn_reco yn
tab zn_reco, m
tab zn_reco survey, col
*Traditional Healer
gen zn_trad = .
replace zn_trad = 0 if d_zinc == 1
replace zn_trad = 1 if q716 == 21 & q715 == 1
lab var zn_trad "Zinc from traditional healer"
lab val zn_trad yn
tab zn_trad, m
tab zn_trad survey, col
*Shop
gen zn_shop = .
replace zn_shop = 0 if d_zinc == 1
replace zn_shop = 1 if q716 == 22 & q715 == 1
lab var zn_shop "Zinc from shop"
lab val zn_shop yn
tab zn_shop, m
tab zn_shop survey, col
*Pharmacy
gen zn_pharm = .
replace zn_pharm = 0 if d_zinc == 1
replace zn_pharm = 1 if q716 == 23 & q715 == 1
lab var zn_pharm "Zinc from pharmacy"
lab val zn_pharm yn
tab zn_pharm, m
tab zn_pharm survey, col
*Friend or parent
gen zn_friend = .
replace zn_friend = 0 if d_zinc == 1
replace zn_friend = 1 if q716 == 26 & q715 == 1
lab var zn_friend "Zinc from friend or parent"
lab val zn_friend yn
tab zn_friend, m
tab zn_friend survey, col
*Market
gen zn_market = .
replace zn_market = 0 if d_zinc == 1
replace zn_market = 1 if q716 == 27 & q715 == 1
lab var zn_market "Zinc from friend or parent"
lab val zn_market yn
tab zn_market, m
tab zn_market survey, col
*Other
gen zn_other = .
replace zn_other = 0 if d_zinc == 1
replace zn_other = 1 if q716 == 96 & q715 == 1
lab var zn_other "Zinc from other source"
lab val zn_other yn
tab zn_other, m
tab zn_other survey, col

*Received ORS and zinc from CHW among those who received ORS and zinc
gen orszn_reco = .
replace orszn_reco = 0 if d_ors == 1 & d_zinc == 1
replace orszn_reco = 1 if ors_reco == 1 & zn_reco == 1
lab var orszn_reco "ORS and zinc from ReCo"
lab val orszn_reco yn
tab orszn_reco survey, col

*Recieved first dose of ORS in presence of CHW
tab q713, m
tab ors_reco, m
gen ors_chwfstdose = .
replace ors_chwfstdose = 0 if ors_reco == 1
replace ors_chwfstdose = 1 if q713 == 1 & ors_reco == 1
lab var ors_chwfstdose "Child recieved first dose of ORS in presence of CHW"
lab val ors_chwfstdose yn
tab ors_chwfstdose, m
tab ors_chwfstdose survey, col

*Recieved first dose of zinc in presence of CHW
tab q718, m
tab zn_reco, m
gen zn_chwfstdose = .
replace zn_chwfstdose = 0 if zn_reco == 1
replace zn_chwfstdose = 1 if q718 == 1 & zn_reco == 1
lab var zn_chwfstdose "Child recieved first dose of zinc in presence of CHW"
lab val zn_chwfstdose yn
tab zn_chwfstdose, m
tab zn_chwfstdose survey, col
svy: tab zn_chwfstdose survey, col ci pear

*Recieved first does of ORS and ZN in presence of CHW
gen orszn_chwfstdose = .
replace orszn_chwfstdose = 0 if ors_reco == 1 & zn_reco == 1 
replace orszn_chwfstdose = 1 if ors_chwfstdose == 1 & zn_chwfstdose == 1
lab var orszn_chwfstdose "Recieved first dose of ORS and ZN in presence of CHW"
lab val orszn_chwfstdose yn
tab orszn_chwfstdose, m
tab orszn_chwfstdose survey, col 

*Counseled on administering ORS
tab q714, m
gen ors_counsel = .
replace ors_counsel = 0 if ors_reco == 1
replace ors_counsel = 1 if q714 == 1 & ors_reco == 1
lab var ors_counsel "CG recieved counseling for how to give ORS"
lab val ors_counsel yn
tab ors_counsel, m
tab ors_counsel survey, col
svy: tab ors_counsel survey, col ci pear

*Counseled on adminstering zinc
tab q719, m
gen zn_counsel = .
replace zn_counsel = 0 if zn_reco == 1
replace zn_counsel = 1 if q719 == 1 & zn_reco == 1
lab var zn_counsel "CG recieved counseling for how to give zinc"
lab val zn_counsel yn
tab zn_counsel, m
tab zn_counsel survey, col
svy: tab zn_counsel survey, col ci pear

*Counseled on administering ORS and zinc
gen orszn_counsel = .
replace orszn_counsel = 0 if ors_reco == 1 & zn_reco == 1
replace orszn_counsel = 1 if ors_counsel == 1 & zn_counsel == 1
lab var orszn_counsel "CG recieved counseling on giving ORS and zinc"
lab val orszn_counsel yn
tab orszn_counsel, m
tab orszn_counsel survey, col

*Given referral from ReCO
tab q725, m
gen dref_given = .
replace dref_given = 0 if d_reco == 1
replace dref_given = 1 if q725 == 1
lab var dref_given "ReCO gave a referral to caregiver"
lab val dref_given yn
tab dref_given, m
tab dref_given survey, col
svy: tab dref_given survey, col ci pear

*Caregiver completed the referral
tab q726, m
gen dref_complete = .
replace dref_complete = 0 if dref_given == 1
replace dref_complete = 1 if q726 == 1
lab var dref_complete "Caregiver completed referral"
lab val dref_complete yn
tab dref_complete, m
tab dref_complete survey, col
svy: tab dref_complete survey, col ci pear

*Reason did not comply with ReCO referral
tab1 q727*
*q727a: Too far
tab q727a, m
gen dref_toofar = .
replace dref_toofar = 0 if dref_complete == 0
replace dref_toofar = 1 if q727a == "A"
lab var dref_toofar "Did not complete referral b/c too far"
lab val dref_toofar yn
tab dref_toofar, m
tab dref_toofar survey, col
*q727b: Did not have the money
tab q727b, m
gen dref_nomoney = .
replace dref_nomoney = 0 if dref_complete == 0
replace dref_nomoney = 1 if q727b == "B"
lab var dref_nomoney "Did not complete referral b/c did not have money"
lab val dref_nomoney yn
tab dref_nomoney, m
tab dref_nomoney survey, col
*q727c: No transportation
tab q727c, m
gen dref_transport = .
replace dref_transport = 0 if dref_complete == 0
replace dref_transport = 1 if q727c == "C"
lab var dref_transport "Did not have trasnportation"
lab val dref_transport yn
tab dref_transport, m
tab dref_transport survey, col
*q727d: Did not think illness serious enough
tab q727d, m
gen dref_serious = .
replace dref_serious = 0 if dref_complete == 0
replace dref_serious = 1 if q727d == "D"
lab var dref_serious "Did not think illness serious enough"
lab val dref_serious yn
tab dref_serious, m
tab dref_serious survey, col
*q727e: The child improved
tab q727e, m
gen dref_improved = .
replace dref_improved = 0 if dref_complete == 0
replace dref_improved = 1 if q727e == "E"
lab var dref_improved "Did not complete referral b/c child improved"
lab val dref_improved yn
tab dref_improved, m
tab dref_improved survey, col
*q727f: Did not have time to go
tab q727f, m
gen dref_notime = .
replace dref_notime = 0 if dref_complete == 0
replace dref_notime = 1 if q727f == "F"
lab var dref_notime "Did not have time to go"
lab val dref_notime yn
tab dref_notime, m
tab dref_notime survey, col
*q727g: Went somewhere else
tab q727g, m
gen dref_somewhere = .
replace dref_somewhere = 0 if dref_complete == 0
replace dref_somewhere = 1 if q727g == "G"
lab var dref_somewhere "Went somewhere else"
lab val dref_somewhere yn
tab dref_somewhere, m
tab dref_somewhere survey, col
*q727h: Did not have husband's permission
tab q727h, m
gen dref_permiss = .
replace dref_permiss = 0 if dref_complete == 0
replace dref_permiss = 1 if q727h == "H"
lab var dref_permiss "Did not have permission"
lab val dref_permiss yn
tab dref_permiss, m
tab dref_permiss survey, col
*q727x: Other
tab q727x, m
gen dref_other = .
replace dref_other = 0 if dref_complete == 0
replace dref_other = 1 if q727x == "X"
lab var dref_other "Other reason"
lab val dref_other yn
tab dref_other, m
tab dref_other survey, col

*Follow up - ReCO visited child
tab q728, m
gen d_followup = .
replace d_followup = 0 if d_reco == 1
replace d_followup = 1 if q728 == 1
lab var d_followup "ReCO followed up with child at home"
lab val d_followup yn
tab d_followup, m
tab d_followup survey, col
svy: tab d_followup survey, col ci pear

*Follow up - caregiver brought child to ReCo
tab q728, m
gen d_followup2 = .
replace d_followup2 = 0 if d_reco == 1
replace d_followup2 = 1 if q728 == 2
lab var d_followup2 "Caregiver brought child to ReCo for follow-up"
lab val d_followup2 yn
tab d_followup2, m
tab d_followup2 survey, col
svy: tab d_followup2 survey, col ci pear

*When the follow up took place
tab q729, m
tab q729 survey, col
svy: tab q729 survey, col ci pear

*Did not seek care
tab d_soughtcare, m
gen d_nocare = .
replace d_nocare = 0 if d_case == 1
replace d_nocare = 1 if d_soughtcare == 0
lab var d_nocare "Did not seek care"
lab val d_nocare yn
tab d_nocare, m
tab d_nocare survey, col
svy: tab d_nocare survey, col ci pear

*Did not seek care from a CHW
tab d_reco, m
gen d_chwnocare = .
replace d_chwnocare = 0 if q703 == 1
replace d_chwnocare = 1 if q703 == 1 & d_reco == 0
lab var d_chwnocare "Sought care but not from CHW"
lab val d_chwnocare yn
tab d_chwnocare, m
tab d_chwnocare survey, col
svy: tab d_chwnocare survey, col ci pear

*Reasons caregiver did not seek care from CHW--Only observations for 'other'
*N=395
tab1 q708b*
*q708ba: ReCO not avail
tab q708ba, m
gen dnochw_avail = .
replace dnochw_avail = 0 if d_chwnocare == 1 & survey == 2
replace dnochw_avail = 1 if q708ba == "A"
lab var dnochw_avail "CHW not available"
lab val dnochw_avail yn
tab dnochw_avail, m
*q708bb: ReCO did not have supplies
tab q708bb, m
gen dnochw_supp = .
replace dnochw_supp = 0 if d_chwnocare == 1 & survey == 2
replace dnochw_supp = 1 if q708bb == "B"
lab var dnochw_supp "CHW does not have supplies"
lab val dnochw_supp yn
tab dnochw_supp, m
*q708bc: Did not trust ReCO
tab q708bc, m
gen dnochw_trust = .
replace dnochw_trust = 0 if d_chwnocare == 1 & survey == 2
replace dnochw_trust = 1 if q708bc == "C"
lab var dnochw_trust "Does not trust CHW"
lab val dnochw_trust yn
tab dnochw_trust, m
*q708bd: Thought condition too serious for ReCO
tab q708bd, m
gen dnochw_serious = .
replace dnochw_serious = 0 if d_chwnocare == 1 & survey == 2
replace dnochw_serious = 1 if q708bd == "D"
lab var dnochw_serious "Thought condition too serious"
lab val dnochw_serious yn
tab dnochw_serious, m
*q708be: Prefer health center/other provider
tab q708be, m
gen dnochw_prefother = .
replace dnochw_prefother = 0 if d_chwnocare == 1 & survey == 2
replace dnochw_prefother = 1 if q708be == "E"
lab var dnochw_prefother "Prefer other health center or provider"
lab val dnochw_prefother yn
tab dnochw_prefother, m
*q708bf: ReCO too far
tab q708bf, m
gen dnochw_toofar = .
replace dnochw_toofar = 0 if d_chwnocare == 1 & survey == 2
replace dnochw_toofar = 1 if q708bf == "F"
lab var dnochw_toofar "CHW too far"
lab val dnochw_toofar yn
tab dnochw_toofar, m
*q708bx: Other
tab q708bx, m
gen dnochw_other = .
replace dnochw_other = 0 if d_chwnocare == 1 & survey == 2
replace dnochw_other = 1 if q708bx == "X"
lab var dnochw_other "did not seek care from CHW for other reason"
lab val dnochw_other yn
tab dnochw_other, m
*q708bz: Don't know
tab q708bz, m
gen dnochw_dk = .
replace dnochw_dk = 0 if d_chwnocare == 1 & survey == 2
replace dnochw_dk = 1 if q708bz == "Z"
lab var dnochw_dk "Don't know"
lab val dnochw_dk yn
tab dnochw_dk, m

*Reasons did not seek care at all, n=100
tab1 q708c*
tab d_nocare, m
*q708ca: did not think condition was serious
tab q708ca, m
gen dnocare_serious = .
replace dnocare_serious = 0 if d_soughtcare == 0 
replace dnocare_serious = 1 if q708ca == "A"
lab var dnocare_serious "CG did not seek care b/c did not think condition serious"
lab val dnocare_serious yn
tab dnocare_serious, m
*q708cb: The condition passed
tab q708cb, m
gen dnocare_condpassed = .
replace dnocare_condpassed = 0 if d_soughtcare == 0 
replace dnocare_condpassed = 1 if q708cb == "B"
lab var dnocare_condpassed "CG did not seek care b/c condition passed"
lab val dnocare_condpassed yn
tab dnocare_condpassed, m
*q708cc: Place was too far
tab q708cc, m
gen dnocare_toofar = .
replace dnocare_toofar = 0 if d_soughtcare == 0 
replace dnocare_toofar = 1 if q708cc == "C"
lab var dnocare_toofar "CG did not seek care b/c too far"
lab val dnocare_toofar yn
tab dnocare_toofar, m
*q708cd: Did not have time
tab q708cd, m
gen dnocare_notime = .
replace dnocare_notime = 0 if d_soughtcare == 0 
replace dnocare_notime = 1 if q708cd == "D"
lab var dnocare_notime "CG did not seek care b/c did not have time"
lab val dnocare_notime yn
tab dnocare_notime, m
*q708ce: Did not have permission
tab q708ce, m
gen dnocare_nopermiss = .
replace dnocare_nopermiss = 0 if d_soughtcare == 0 
replace dnocare_nopermiss = 1 if q708ce == "E"
lab var dnocare_nopermiss "CG did not seek care b/c did not have permission"
lab val dnocare_nopermiss yn
tab dnocare_nopermiss, m
*q708cf: Did not have money
tab q708cf, m
gen dnocare_nomoney = .
replace dnocare_nomoney = 0 if d_soughtcare == 0 
replace dnocare_nomoney = 1 if q708cf == "F"
lab var dnocare_nomoney "CG did not seek care b/c did not have money"
lab val dnocare_nomoney yn
tab dnocare_nomoney, m
*q708cg: Could treat condition at home
tab q708cg, m
gen dnocare_hometx = .
replace dnocare_hometx = 0 if d_soughtcare == 0 
replace dnocare_hometx = 1 if q708cg == "G"
lab var dnocare_hometx "CG did not seek care b/c could treat at home"
lab val dnocare_hometx yn
tab dnocare_hometx, m
*q708cx: Other
tab q708cx, m
gen dnocare_other = .
replace dnocare_other = 0 if d_soughtcare == 0 
replace dnocare_other = 1 if q708cx == "X"
lab var dnocare_other "CG did not seek care b/c other reason"
lab val dnocare_other  yn
tab dnocare_other, m
*q708cz: Don't know
tab q708cz, m
gen dnocare_dk = .
replace dnocare_dk = 0 if d_soughtcare == 0 
replace dnocare_dk = 1 if q708cz == "Z"
lab var dnocare_dk "CG did not seek care b/c do not know"
lab val dnocare_dk yn
tab dnocare_dk, m

********************************MODULE 8: FEVER*********************************
tab f_case, m

*Sought any advice or treatment- BL and EL
tab q803, m
gen f_soughtcare = .
replace f_soughtcare = 0 if f_case == 1 
replace f_soughtcare = 1 if q803 == 1 
lab var f_soughtcare "Caregiver sought care for fever"
lab val f_soughtcare yn
tab f_soughtcare, m
tab f_soughtcare survey, col

*Sought care from appropriate provider 
tab1 q806*
*q806a: Hospital
tab q806a, m
gen f_hosp = .
replace f_hosp = 0 if f_case == 1 & q803 == 1
replace f_hosp = 1 if q806a == "A" 
lab var f_hosp "Sought care at hospital"
lab val f_hosp yn
tab f_hosp, m
*q806b: Health Center
tab q806b, m
gen f_hcent = .
replace f_hcent = 0 if f_case == 1 & q803 == 1
replace f_hcent = 1 if q806b == "B" 
lab var f_hcent "Sought care at health center"
lab val f_hcent yn
tab f_hcent, m
*q806c: Health post
tab q806c, m
gen f_hpost = .
replace f_hpost = 0 if f_case == 1 & q803 == 1
replace f_hpost = 1 if q806c == "C" 
lab var f_hpost "Sought care at health post"
lab val f_hpost yn
tab f_hpost, m
*q806d: Dispensary
tab q806d, m
gen f_disp = .
replace f_disp = 0 if f_case == 1 & q803 == 1
replace f_disp = 1 if q806d == "D" 
lab var f_disp "Sought care at dispensary"
lab val f_disp yn
tab f_disp, m
*q806e: Clinic
tab q806e, m
gen f_clinic = .
replace f_clinic = 0 if f_case == 1 & q803 == 1
replace f_clinic = 1 if q806e == "E" 
lab var f_clinic "Sought care at clinic"
lab val f_clinic yn
tab f_clinic, m
*q806f: RECO
tab q806f, m
gen f_reco = .
replace f_reco = 0 if f_case == 1 & q803 == 1
replace f_reco = 1 if q806f == "F" 
lab var f_reco "Sought care from ReCO"
lab val f_reco yn
tab f_reco, m
*q806g: traditional healer
tab q806g, m
gen f_trad = .
replace f_trad = 0 if f_case == 1 & q803 == 1
replace f_trad = 1 if q806g == "G" 
lab var f_trad "Sought care from traditional healer"
lab val f_trad yn
tab f_trad, m
*q806h: shop
tab q806h, m
gen f_shop = .
replace f_shop = 0 if f_case == 1 & q803 == 1
replace f_shop = 1 if q806h == "H" 
lab var f_shop "Sought care from shop"
lab val f_shop yn
tab f_shop, m
*q806i: pharmacy
tab q806i, m
gen f_pharm = .
replace f_pharm = 0 if f_case == 1 & q803 == 1
replace f_pharm = 1 if q806i == "I" 
lab var f_pharm "Sought care from pharmacy"
lab val f_pharm yn
tab f_pharm, m
*q806j: friend or parent
tab q806j, m
gen f_friend = .
replace f_friend = 0 if f_case == 1 & q803 == 1
replace f_friend = 1 if q806j == "J" 
lab var f_friend "Sought care from friend or parent"
lab val f_friend yn
tab f_friend, m
*q806k: market
tab q806k, m
gen f_market = .
replace f_market = 0 if f_case == 1 & q803 == 1
replace f_market = 1 if q806k == "K" 
lab var f_market "Sought care from market"
lab val f_market yn
tab f_market, m
*q806x: other
tab q806x, m
gen f_other = .
replace f_other = 0 if f_case == 1 & q803 == 1
replace f_other = 1 if q806x == "X" 
lab var f_other "Sought care from other source"
lab val f_other yn
tab f_other, m

*total number of providers visited 
foreach x of varlist q806a-q806x {
  replace `x' = "" if `x' =="."
}
egen f_provtot = rownonmiss(q806a-q806x),strok
replace f_provtot = . if f_case != 1
lab var f_provtot "Total number of providers where sought care"
tab f_provtot survey, col

*Sought treatment from appropriate provider-BL and EL
gen f_appprov = .
replace f_appprov = 0 if f_case==1
replace f_appprov = 1 if (f_hosp == 1 | f_hcent == 1 | f_hpost == 1 | f_disp == 1 | f_clinic == 1 | f_reco == 1)
lab var f_appprov "Sought treatment from appropriate provider"
lab val f_appprov yn
tab f_appprov, m
tab f_appprov survey, col

*Sought treatment from CHW
gen f_chw = .
replace f_chw = 0 if f_case == 1 
replace f_chw = 1 if f_reco == 1 
lab var f_chw "Sought treatment from ReCO"
lab val f_chw yn
tab f_chw, m
tab f_chw f_sex, col

*Sought treatment from CHW first
tab q808, m
gen f_chwfirst = .
replace f_chwfirst = 0 if f_case==1 
replace f_chwfirst = 1 if q808 == "F" 
replace f_chwfirst = 1 if q806f == "F" & f_provtot == 1
lab var f_chwfirst "Sought care from CHW first"
lab val f_chwfirst yn
tab f_chwfirst, m
tab f_chwfirst f_sex, col

***New variable for second table in careseeking tab
*visited an CHW as first (*or only*) source of care
gen f_chwfirst_anycare = .
replace f_chwfirst_anycare = 0 if f_case == 1 & q803 == 1
replace f_chwfirst_anycare = 1 if q808 == "F"
replace f_chwfirst_anycare = 1 if q806f == "F" & f_provtot == 1
lab var f_chwfirst_anycare "Sought care from CHW first among those who sought any care"
lab val f_chwfirst_anycare yn
tab f_chwfirst_anycare survey, col

*Decided to seek care jointly with partner
tab q804, m
gen f_joint = .
replace f_joint = 0 if union == 1 & f_case == 1
replace f_joint = 1 if union == 1 & f_case == 1 & q803 == 1 & q805a =="A"
lab var f_joint "Sought care jointly with partner"
lab val f_joint yn
tab f_joint, m
tab f_joint survey, col

*Sources of care for fever
tab1 q806*
*Hospital
tab f_hosp, m
tab f_hosp survey, col
*Health center
tab f_hcent, m
tab f_hcent survey, col
*Health post
tab f_hpost, m
tab f_hpost survey, col
*Dispensary
tab f_disp, m
tab f_disp survey, col
*Clinc 
tab f_clinic, m
tab f_clinic survey, col
*RECO
tab f_reco, m
tab f_reco survey, col
*Traditional Healer
tab f_trad, m
tab f_trad survey, col
*Shop
tab f_shop, m
tab f_shop survey, col
*Pharmacy
tab f_pharm, m
tab f_pharm survey, col
*Friend or parent
tab f_friend, m
tab f_friend survey, col
*Market
tab f_market, m
tab f_market survey, col
*Other
tab f_other, m
tab f_other survey, col

*first source of care locations - fever
gen f_fcs_hosp = 1 if q808 == "A" 
gen f_fcs_hcent = 1 if q808 == "B" 
gen f_fcs_hpost = 1 if q808 == "C"
gen f_fcs_disp = 1 if q808 == "D" 
gen f_fcs_clinic = 1 if q808 == "E"
gen f_fcs_reco = 1 if q808 == "F"
gen f_fcs_trad = 1 if q808 == "G"
gen f_fcs_shop = 1 if q808 == "H"
gen f_fcs_pharm = 1 if q808 == "I"
gen f_fcs_friend = 1 if q808 == "J"
gen f_fcs_market = 1 if q808 == "K"
gen f_fcs_other = 1 if q808 == "X"

replace f_fcs_hosp = 1 if q806a == "A" & f_provtot == 1
replace f_fcs_hcent = 1 if q806b == "B" & f_provtot == 1
replace f_fcs_hpost = 1 if q806c == "C" & f_provtot == 1
replace f_fcs_disp = 1 if q806d == "D" & f_provtot == 1
replace f_fcs_clinic = 1 if q806e == "E" & f_provtot == 1
replace f_fcs_reco = 1 if q806f == "F" & f_provtot == 1
replace f_fcs_trad = 1 if q806g == "G" & f_provtot == 1
replace f_fcs_shop = 1 if q806h == "H" & f_provtot == 1
replace f_fcs_pharm = 1 if q806i == "I" & f_provtot == 1
replace f_fcs_friend = 1 if q806j == "J" & f_provtot == 1
replace f_fcs_market = 1 if q806k == "K" & f_provtot == 1
replace f_fcs_other = 1 if q806x == "X" & f_provtot == 1

foreach x of varlist f_fcs_* {
  replace `x' = 0 if f_case == 1 & q803 == 1 & `x' ==.
  lab val `x' yn
}

*Child had blood drawn - all fever cases(Indicator 10)
tab q809, m
gen f_bloodtaken = .
replace f_bloodtaken = 0 if f_case==1
replace f_bloodtaken = 1 if q809 == 1 
lab var f_bloodtaken "Blood test done- all cases"
lab val f_bloodtaken yn
tab f_bloodtaken, m
tab f_bloodtaken survey, col
svy: tab f_bloodtaken survey, col ci pear

*Child had blood drawn by CHW - care sought from CHW
tab q809, m
gen f_bloodtakenchw = .
replace f_bloodtakenchw = 0 if f_chw==1
replace f_bloodtakenchw = 1 if q809 == 1 & q810a == "A"  
lab var f_bloodtakenchw "Blood test done by CHW - care sought from CHW"
lab val f_bloodtakenchw yn
tab f_bloodtakenchw, m
tab f_bloodtakenchw survey, col
svy: tab f_bloodtakenchw survey, col ci pear

*Caregiver recieved test results - all cases
tab q811, m
gen f_gotresult = .
replace f_gotresult = 0 if f_bloodtaken == 1
replace f_gotresult = 1 if f_bloodtaken == 1 & q811 == 1 
lab var f_gotresult "Caregiver recieved test results-all cases"
lab val f_gotresult yn
tab f_gotresult, m
tab f_gotresult survey, col
svy: tab f_gotresult survey, col ci pear

*Caregiver recieved test results - all cases
tab q812, m
gen f_result = .
replace f_result = 0 if f_gotresult == 1
replace f_result = 1 if f_gotresult == 1 & q812 == 1 
lab var f_result "Result of malaria diagnostic test-all cases"
lab def result 0 "negative" 1 "positive", modify
lab val f_result result 
tab f_result, m
tab f_result survey, col
svy: tab f_result survey, col ci pear

*Caregiver recieved test results from CHW
tab q811, m
gen f_gotresultchw = .
replace f_gotresultchw = 0 if f_bloodtakenchw == 1 
replace f_gotresultchw = 1 if f_bloodtakenchw == 1 & q811 == 1 
lab var f_gotresultchw "Caregiver recieved test results from CHW"
lab val f_gotresultchw yn
tab f_gotresultchw, m
tab f_gotresultchw survey, col
svy: tab f_gotresultchw survey, col ci pear

*Caregiver recieved test results - sought care from CHW
gen f_resultchw = .
replace f_resultchw = 0 if f_gotresultchw == 1
replace f_resultchw = 1 if f_gotresultchw == 1 & q812 == 1 
lab var f_resultchw "Result of malaria diagnostic test-sought care from CHW"
lab val f_resultchw result 
tab f_resultchw, m
tab f_resultchw survey, col
svy: tab f_resultchw survey, col ci pear

*Child had blood drawn by provider other than CHW - care sought from other provider
gen f_bloodtakenoth = .
replace f_bloodtakenoth = 0 if f_oth==1
replace f_bloodtakenoth = 0 if (f_provtot == 1 & f_chw != 1) | (f_provtot >=2 & f_provtot !=.)
replace f_bloodtakenoth = 1 if ((f_provtot == 1 & f_chw != 1) | (f_provtot >=2 & f_provtot !=.)) & (q810b =="B"| q810c =="C"| q810d =="D"| q810e =="E"| q810x =="X")
lab var f_bloodtakenoth "Child had blood taken by provider other than CHW"
lab val f_bloodtakenoth yn
tab f_bloodtakenoth survey
svy: tab f_bloodtakenoth survey, col ci pear obs

*Caregiver recieved test results - other provider
tab q811, m
gen f_gotresultoth = .
replace f_gotresultoth = 0 if f_bloodtakenoth == 1 
replace f_gotresultoth = 1 if f_bloodtakenoth == 1 & q811 == 1 
lab var f_gotresultoth "Caregiver recieved test results from oth"
lab val f_gotresultoth yn
tab f_gotresultoth, m
tab f_gotresultoth survey, col
svy: tab f_gotresultoth survey, col ci pear obs

*Blood test positive for malaria - other provider
tab q812, m
gen f_resultoth = .
replace f_resultoth = 0 if f_gotresultoth == 1
replace f_resultoth = 1 if f_gotresultoth == 1 & q812 == 1 
lab var f_resultoth "Blood test positive for malaria-oth"
lab val f_resultoth yn
tab f_resultoth, m
tab f_resultoth survey, col
svy: tab f_resultoth survey, col ci pear obs

*took antimalarial
gen f_antim = .
replace f_antim = 0 if f_case == 1
replace f_antim = 1 if q814a == "A" | q814b == "B" | q814c == "C" 
lab var f_antim "Took antimalarial - all cases"
lab val f_antim yn
tab f_antim survey, col

*took antimalarial - confirmed malaria cases
gen f_antimc = .
replace f_antimc = 0 if f_result == 1
replace f_antimc = 1 if q814a == "A" | q814b == "B" | q814c == "C" 
lab var f_antimc "Took antimalarial - confirmed malaria cases"
lab val f_antimc yn
tab f_antimc survey, col

*took ACT 
gen f_act = .
replace f_act = 0 if f_case == 1
replace f_act = 1 if q814a == "A" 
lab var f_act "Took ACT-all cases"
lab val f_act yn 
tab f_act, m
tab f_act survey, col

*took ACT same day or next day
gen f_act24 = .
replace f_act24 = 0 if f_case == 1
replace f_act24 = 1 if f_act == 1 & q817 < 2
lab var f_act24 "Took ACT same day or next day-all cases"
lab val f_act24 yn 
tab f_act24, m
tab f_act24 survey, col

*took ACT from CHW
gen f_actchw = .
replace f_actchw = 0 if f_case == 1
replace f_actchw = 1 if q814a == "A" & q816 == 16
lab var f_actchw "Took ACT from CHW-all cases"
lab val f_actchw yn 
tab f_actchw, m
tab f_actchw survey, col

*took ACT same day or next day from CHW
gen f_act24chw = .
replace f_act24chw = 0 if f_case == 1
replace f_act24chw = 1 if f_actchw == 1 & f_act24 == 1
lab var f_act24chw "Took ACT same day or next day from CHW-all cases"
lab val f_act24chw yn 
tab f_act24chw, m
tab f_act24chw survey, col

*took ACT from provider other than CHW
gen f_actoth = .
replace f_actoth = 0 if f_case == 1
replace f_actoth = 1 if q814a == "A" & q816 != 16
lab var f_actoth "Took ACT from provider other than CHW-all cases"
lab val f_actoth yn 
tab f_actoth, m
tab f_actoth survey, col

*took ACT same day or next day from provider other than CHW
gen f_act24oth = .
replace f_act24oth = 0 if f_case == 1
replace f_act24oth = 1 if f_actoth == 1 & f_act24 == 1
lab var f_act24oth "Took ACT same day or next day from provider other than CHW-all cases"
lab val f_act24oth yn 
tab f_act24oth, m
tab f_act24oth survey, col

*took ACT after positive blood test-all cases
gen f_actc = .
replace f_actc = 0 if f_result == 1
replace f_actc = 1 if f_act == 1 & f_result == 1
lab var f_actc "Took ACT after malaria confirmed by blood test-all cases"
lab val f_actc yn 
tab f_actc, m
tab f_actc survey, col

*took ACT from CHW after positive blood test-all cases
gen f_actcchw = .
replace f_actcchw = 0 if f_result == 1
replace f_actcchw = 1 if f_actchw == 1 & f_result == 1
lab var f_actcchw "Took ACT from CHW after malaria confirmed by blood test-all cases"
lab val f_actcchw yn 
tab f_actcchw, m
tab f_actcchw survey, col

*took ACT from provider other than CHW after positive blood test-all cases
gen f_actcoth = .
replace f_actcoth = 0 if f_result == 1
replace f_actcoth = 1 if f_actoth == 1 & f_result == 1
lab var f_actcoth "Took ACT from provider other than CHW after malaria confirmed by blood test-all cases"
lab val f_actcoth yn 
tab f_actcoth, m
tab f_actcoth survey, col

*took ACT after positive blood test same or next day-all cases
gen f_act24c = .
replace f_act24c = 0 if f_result == 1
replace f_act24c = 1 if f_act24 == 1 & f_result == 1
lab var f_act24c "Took ACT after malaria confirmed by blood test same or next day-all cases"
lab val f_act24c yn 
tab f_act24c, m
tab f_act24c survey, col

*took ACT from CHW after positive blood test same or next day-all cases
gen f_act24cchw = .
replace f_act24cchw = 0 if f_result == 1
replace f_act24cchw = 1 if f_act24chw == 1 & f_result == 1
lab var f_act24cchw "Took ACT from CHW after malaria confirmed by blood test same or next day-all cases"
lab val f_act24cchw yn 
tab f_act24cchw, m
tab f_act24cchw survey, col

*took ACT from provider other than CHW after positive blood test same or next day-all cases
gen f_act24coth = .
replace f_act24coth = 0 if f_result == 1
replace f_act24coth = 1 if f_act24oth == 1 & f_result == 1
lab var f_act24coth "Took ACT from provider other than CHW after malaria confirmed by blood test same or next day-all cases"
lab val f_act24coth yn 
tab f_act24coth, m
tab f_act24coth survey, col

*took ACT from RECO, among those that sought care from RECO
gen f_actchw2 = .
replace f_actchw2 = 0 if f_chw == 1
replace f_actchw2 = 1 if f_actchw == 1 & f_chw == 1 
lab var f_actchw2 "Took ACT from RECO, sought care from ReCo"
lab val f_actchw2 yn 
tab f_actchw2, m
tab f_actchw2 survey, col

*took ACT from RECO same or next day, among those that sought care from RECO
gen f_act24chw2 = .
replace f_act24chw2 = 0 if f_chw == 1
replace f_act24chw2 = 1 if f_act24chw == 1 & f_chw == 1 
lab var f_act24chw2 "Took ACT from RECO same or next day, sought care from ReCo"
lab val f_act24chw2 yn 
tab f_act24chw2, m
tab f_act24chw2 survey, col

*took ACT from RECO after positive blood test, among those that sought care from RECO
gen f_actcchw2 = .
replace f_actcchw2 = 0 if f_resultchw == 1
replace f_actcchw2 = 1 if f_actchw == 1 & f_resultchw == 1 
lab var f_actcchw2 "Took ACT from RECO after malaria confirmed by blood test, sought care from ReCo"
lab val f_actcchw2 yn 
tab f_actcchw2, m
tab f_actcchw2 survey, col

*took ACT from RECO after positive blood test same or next day, among those that sought care from RECO
gen f_act24cchw2 = .
replace f_act24cchw2 = 0 if f_resultchw == 1
replace f_act24cchw2 = 1 if f_act24chw == 1 & f_resultchw == 1 
lab var f_act24cchw2 "Took ACT from RECO same or next day after malaria confirmed by blood test, sought care from ReCo"
lab val f_act24cchw2 yn 
tab f_act24cchw2, m
tab f_act24cchw2 survey, col

*Sought care from provider other than RCom and ASC
gen f_careoth = 0 if f_case == 1
replace f_careoth = 1 if f_provtot == 1 & f_chw != 1 
replace f_careoth = 1 if f_provtot >= 2 & f_provtot !=.
tab f_careoth survey

*ACT from provider other than CHW - sought care from other providers
gen f_actoth2 = .
replace f_actoth2 = 0 if f_careoth == 1  
replace f_actoth2 = 1 if f_actoth == 1 & f_careoth == 1
replace f_actoth2 = . if q816 == . & f_act == 1
lab var f_actoth2 "ACT treatment by provider other than CHW, sought care from other providers"
lab val f_actoth2 yn
tab f_actoth2 survey, col 

*ACT from provider other than CHW within 24 hours - sought care from other providers
gen f_act24oth2 = .
replace f_act24oth2 = 0 if f_careoth == 1  
replace f_act24oth2 = 1 if f_act24oth == 1 & f_careoth == 1
replace f_act24oth2 = . if q816 == . & f_act == 1
lab var f_act24oth2 "ACT treatment by provider other than CHW, sought care from other providers"
lab val f_act24oth2 yn
tab f_act24oth2 survey, col 

*ACT from provider other than CHW  - confirmed among all fever cases
gen f_actcoth2 = .
replace f_actcoth2 = 0 if f_resultoth == 1 & f_careoth == 1
replace f_actcoth2 = 1 if f_careoth == 1 & f_actcoth == 1 & f_careoth == 1
lab var f_actcoth2 "ACT treatment by provider other than CHW, malaria confirmed by blood test"
lab val f_actcoth2 yn
tab f_actcoth2 survey, col 

*appropriate fever treatment from provider other than CHW - confirmed within 24 hours (INDICATOR 14C)
gen f_act24coth2 = .
replace f_act24coth2 = 0 if f_resultoth == 1 & f_careoth == 1
replace f_act24coth2 = 1 if f_resultoth == 1 & f_careoth == 1 & f_act24coth == 1 
lab var f_act24coth2 "ACT treatment by provider other than CHW - confirmed malaria within 2 days"
lab val f_act24coth2 yn
tab f_act24coth2 survey, col 

*Location of assessment for malaria--
*not available in DRC dataset (q809a), they only collected who did the blood test, so removed

*Provider of malaria blood test for child with fever
*ReCO
tab q810a, m
gen fassess_reco = .
replace fassess_reco = 0 if q809 == 1
replace fassess_reco = 1 if q810a == "A"
lab var fassess_reco "ReCO did blood test"
lab val fassess_reco yn
tab fassess_reco, m
tab fassess_reco survey, col
svy: tab fassess_reco survey, col ci pear
*Medical Assistant
tab q810b, m
gen fassess_medassist = .
replace fassess_medassist = 0 if q809 == 1
replace fassess_medassist = 1 if q810b == "B"
lab var fassess_medassist "Medical assistant did blood test"
lab val fassess_medassist yn
tab fassess_medassist, m
tab fassess_medassist survey, col
svy: tab fassess_medassist survey, col ci pear
*Clinical Officer
tab q810c, m
gen fassess_clofficer = .
replace fassess_clofficer = 0 if q809 == 1
replace fassess_clofficer = 1 if q810c == "C"
lab var fassess_clofficer "Clinical officer did blood test"
lab val fassess_clofficer yn
tab fassess_clofficer, m
tab fassess_clofficer survey, col
svy: tab fassess_clofficer survey, col ci pear
*Nurse
tab q810d, m
gen fassess_nurse = .
replace fassess_nurse = 0 if q809 == 1
replace fassess_nurse = 1 if q810d == "D"
lab var fassess_nurse "Nurse did blood test"
lab val fassess_nurse yn
tab fassess_nurse, m
tab fassess_nurse survey, col
svy: tab fassess_nurse survey, col ci pear
*Doctor
tab q810e, m
gen fassess_doctor = .
replace fassess_doctor = 0 if q809 == 1
replace fassess_doctor = 1 if q810e == "E"
lab var fassess_doctor "Doctor did blood test"
lab val fassess_doctor yn
tab fassess_doctor, m
tab fassess_doctor survey, col
svy: tab fassess_doctor survey, col ci pear
*Other
tab q810x, m
gen fassess_other2 = .
replace fassess_other2 = 0 if q809 == 1
replace fassess_other2 = 1 if q810x == "X"
lab var fassess_other2 "Other provider did blood test"
lab val fassess_other2 yn
tab fassess_other2, m
tab fassess_other2 survey, col
svy: tab fassess_other2 survey, col ci pear

*Fever treatment taken by child
tab q813, m
*ACT
tab q814a, m
gen ftx_act = .
replace ftx_act = 0 if f_case == 1
replace ftx_act = 1 if q814a == "A"
lab var ftx_act "Child given ACT for fever"
lab val ftx_act yn
tab ftx_act, m
svy: tab ftx_act survey if q813 == 1, col ci obs
*Quinine
tab q814b, m
gen ftx_qui = .
replace ftx_qui = 0 if f_case == 1
replace ftx_qui = 1 if q814b == "B"
lab var ftx_qui "Child given quinine for fever"
lab val ftx_qui yn
tab ftx_qui, m
svy: tab ftx_qui survey if q813 == 1, col ci obs
*SP 
tab q814c, m
gen ftx_sp = .
replace ftx_sp = 0 if f_case == 1
replace ftx_sp = 1 if q814c == "C"
lab var ftx_sp "Child given SP for fever"
lab val ftx_sp yn
tab ftx_sp, m
svy: tab ftx_sp survey if q813 == 1, col ci obs
*Antibiotic pills or syrups
tab q814d, m
gen ftx_antibps = .
replace ftx_antibps = 0 if f_case == 1
replace ftx_antibps = 1 if q814d == "D"
lab var ftx_antibps "Child given antibiotic pills or syrup for fever"
lab val ftx_antibps yn
tab ftx_antibps, m
svy: tab ftx_antibps survey if q813 == 1, col ci obs
*Antibiotic injection
tab q814e, m
gen ftx_antibinj = .
replace ftx_antibinj = 0 if f_case == 1
replace ftx_antibinj = 1 if q814e == "E"
lab var ftx_antibinj "Child given antibiotic injection for fever"
lab val ftx_antibinj yn
tab ftx_antibinj, m
svy: tab ftx_antibinj survey if q813 == 1, col ci obs
*Aspirin
tab q814f, m
gen ftx_aspirn = .
replace ftx_aspirn = 0 if f_case == 1
replace ftx_aspirn = 1 if q814f == "F"
lab var ftx_aspirn "Child given aspirin for fever"
lab val ftx_aspirn yn
tab ftx_aspirn, m
svy: tab ftx_aspirn survey if q813 == 1, col ci obs
*Paracetamol
tab q814g, m
gen ftx_para = .
replace ftx_para = 0 if f_case == 1
replace ftx_para = 1 if q814g == "G"
lab var ftx_para "Child given paracetamol for fever"
lab val ftx_para yn
tab ftx_para, m
svy: tab ftx_para survey if q813 == 1, col ci obs
*Other
tab q814x, m
gen ftx_other = .
replace ftx_other = 0 if f_case == 1
replace ftx_other = 1 if q814x == "X"
lab var ftx_other "Child given other treatment for fever"
lab val ftx_other yn
tab ftx_other, m
svy: tab ftx_other survey if q813 == 1, col ci obs
*Don't know
tab q814z, m
gen ftx_dk = .
replace ftx_dk = 0 if f_case == 1
replace ftx_dk = 1 if q814z == "Z"
lab var ftx_dk "Caregiver doesn't know what treatment was given"
lab val ftx_dk yn
tab ftx_dk, m
svy: tab ftx_dk survey if q813 == 1, col ci obs

*Where caregiver got ACTs
tab q812, m
tab q816, m
tab q816 survey, col

*Caregiver got ACT from CHW, among confirmed malaria cases that got ACT
gen actc_reco = .
replace actc_reco = 0 if f_actc == 1
replace actc_reco = 1 if f_actcchw == 1
lab var actc_reco "Caregiver got ACT from CHW, among confirmed malaria cases that got ACT"
lab val actc_reco yn
tab actc_reco survey, col

*First dose taken in presence of CHW
gen act_chwfstdose = .
replace act_chwfstdose = 0 if f_actchw == 1
replace act_chwfstdose = 1 if q819 == 1 & f_actchw == 1
lab val act_chwfstdose yn
lab var act_chwfstdose "child took first dose of ACT in presence of CHW"
tab act_chwfstdose survey, col
svy: tab act_chwfstdose survey, col ci pear obs

*Caregiver counseled on how to administered ACTs at home
gen act_counsel =.
replace act_counsel = 0 if f_actchw == 1
replace act_counsel = 1 if q820 == 1 & f_actchw == 1
lab val act_counsel yn
lab var act_counsel "child received counseling on how to give ACT at home"
tab act_counsel survey, col
svy: tab act_counsel survey, col ci pear

*Referral given from ReCO for Fever
tab q823, m
gen fref_given = .
replace fref_given = 0 if f_reco == 1
replace fref_given = 1 if q823 == 1
lab var fref_given "Referral given"
lab val fref_given yn
tab fref_given, m
tab fref_given survey, col
svy: tab fref_given survey, col ci pear obs

*Referral completed from ReCO for fever
tab q824, m
gen fref_complete = .
replace fref_complete = 0 if fref_given == 1
replace fref_complete = 1 if q824 == 1
lab var fref_complete "Caregiver completed referral"
lab val fref_complete yn
tab fref_complete, m
tab fref_complete survey, col
svy: tab fref_complete survey, col ci pear

*Reasons for not completeing referral 
tab1 q825*
*Too far
tab q825a, m
gen fref_toofar = .
replace fref_toofar = 0 if fref_complete == 0
replace fref_toofar = 1 if q825a == "A"
lab var fref_toofar "Too Far"
lab val fref_toofar yn
tab fref_toofar, m
tab fref_toofar survey, col
svy: tab fref_toofar survey, col ci pear
*Did not have money
tab q825b, m
gen fref_nomoney = .
replace fref_nomoney = 0 if fref_complete == 0
replace fref_nomoney = 1 if q825b == "B"
lab var fref_nomoney "No money"
lab val fref_nomoney yn
tab fref_nomoney, m
tab fref_nomoney survey, col
svy: tab fref_nomoney survey, col ci pear
*No transportaion
tab q825c, m
gen fref_notransport = .
replace fref_notransport = 0 if fref_complete == 0
replace fref_notransport = 1 if q825c == "C"
lab var fref_notransport "No transport"
lab val fref_notransport yn
tab fref_notransport, m
tab fref_notransport survey, col
*Did not think the illness serious enough
tab q825d, m
gen fref_serious = .
replace fref_serious = 0 if fref_complete == 0
replace fref_serious = 1 if q825d == "D"
lab var fref_serious "Did not think illness serious"
lab val fref_serious yn
tab fref_serious, m
tab fref_serious survey, col
svy: tab fref_serious survey, col ci pear
*Child improved
tab q825e, m
gen fref_improved = .
replace fref_improved  = 0 if fref_complete == 0
replace fref_improved  = 1 if q825e == "E"
lab var fref_improved  "Child improved"
lab val fref_improved  yn
tab fref_improved , m
tab fref_improved  survey, col
svy: tab fref_improved  survey, col ci pear
*No time to go
tab q825f, m
gen fref_notime = .
replace fref_notime = 0 if fref_complete == 0
replace fref_notime = 1 if q825f == "F"
lab var fref_notime "No time to go"
lab val fref_notime yn
tab fref_notime, m
tab fref_notime survey, col
svy: tab fref_notime survey, col ci pear
*Went somewhere else
tab q825g, m
gen fref_somewhere = .
replace fref_somewhere = 0 if fref_complete == 0
replace fref_somewhere = 1 if q825g == "G"
lab var fref_somewhere "Went somewhere else"
lab val fref_somewhere yn
tab fref_somewhere, m
tab fref_somewhere survey, col
*Did not have husband's permission
tab q825h, m
gen fref_permiss = .
replace fref_permiss = 0 if fref_complete == 0
replace fref_permiss = 1 if q825h == "H"
lab var fref_permiss "Did not have permission"
lab val fref_permiss yn
tab fref_permiss, m
tab fref_permiss survey, col
*Other
tab q825x, m
gen fref_other = .
replace fref_other = 0 if fref_complete == 0
replace fref_other = 1 if q825x == "X"
lab var fref_other "Other"
lab val fref_other yn
tab fref_other, m
tab fref_other survey, col
svy: tab fref_other survey, col ci pear
*Don't know
tab q825z, m
gen fref_dk = .
replace fref_dk = 0 if fref_complete == 0
replace fref_dk = 1 if q825z == "Z"
lab var fref_dk "Don't know"
lab val fref_dk yn
tab fref_dk, m
tab fref_dk survey, col

*ReCO follow up - ReCo visited child
tab q826, m
gen f_followup = .
replace f_followup = 0 if f_reco == 1 
replace f_followup = 1 if q826 == 1 
lab var f_followup "ReCo visited child to follow up"
lab val f_followup yn
tab f_followup, m
tab f_followup survey, col
svy: tab f_followup survey, col ci pear

*ReCO follow up - caregiver brought child to ReCo
tab q826, m
gen f_followup2 = .
replace f_followup2 = 0 if f_reco == 1 
replace f_followup2 = 1 if q826 == 2 
lab var f_followup2 "Caregiver brought child to ReCo to follow up"
lab val f_followup2 yn
tab f_followup2, m
tab f_followup2 survey, col
svy: tab f_followup2 survey, col ci pear

*When follow up took place
tab q827, m
tab q827 survey, col
svy: tab q827 survey, col ci pear

*Caregiver did not seek care
tab f_soughtcare
gen f_nocare = .
replace f_nocare = 0 if f_case == 1
replace f_nocare = 1 if f_soughtcare == 0 
lab var f_nocare "Did not seek care"
lab val f_nocare yn
tab f_nocare, m
tab f_nocare survey, col
svy: tab f_nocare survey, col ci pear

*Caregiver did not seek care from CHW, among those that sought care
gen f_chwnocare = 0 if q803==1
replace f_chwnocare = 1 if q803==1 & f_reco==0
lab var f_chwnocare "Did not seek care from CHW"
lab val f_chwnocare yn
tab f_chwnocare, m
tab f_chwnocare survey, col
svy: tab f_chwnocare survey, col ci pear

*Reasons did not seek care from CHW
tab1 q808b*
*ReCO not available
tab q808ba, m
gen fnochw_avail = .
replace fnochw_avail = 0 if f_chwnocare == 1 & survey == 2
replace fnochw_avail = 1 if q808ba == "A"
lab var fnochw_avail "Did not go to CHW b/c not available"
lab val fnochw_avail yn
tab fnochw_avail, m
*ReCO did not have supplies
tab q808bb, m
gen fnochw_supp = .
replace fnochw_supp  = 0 if f_chwnocare == 1 & survey == 2
replace fnochw_supp  = 1 if q808bb == "B"
lab var fnochw_supp  "Did not go to CHW b/c did not have supplies"
lab val fnochw_supp  yn
tab fnochw_supp , m
*Did not trust ReCO
tab q808bc, m
gen fnochw_trust = .
replace fnochw_trust = 0 if f_chwnocare == 1 & survey == 2
replace fnochw_trust = 1 if q808bc == "C"
lab var fnochw_trust "Did not go to CHW b/c did not trust them"
lab val fnochw_trust yn
tab fnochw_trust , m
*Condition too serious for ReCO
tab q808bd, m
gen fnochw_serious = .
replace fnochw_serious = 0 if f_chwnocare == 1  & survey == 2
replace fnochw_serious = 1 if q808bd == "D"
lab var fnochw_serious "Did not go to CHW b/c thought illness too serious"
lab val fnochw_serious yn
tab fnochw_serious , m
*Prefer health center
tab q808be, m
gen fnochw_hcent = .
replace fnochw_hcent = 0 if f_chwnocare == 1 & survey == 2
replace fnochw_hcent = 1 if q808be == "E"
lab var fnochw_hcent "Did not go to CHW b/c prefer health center"
lab val fnochw_hcent yn
tab fnochw_hcent , m
*ReCO too far
tab q808bf, m
gen fnochw_toofar = .
replace fnochw_toofar = 0 if f_chwnocare == 1  & survey == 2
replace fnochw_toofar = 1 if q808bf == "F"
lab var fnochw_toofar "Did not go to CHW b/c too far"
lab val fnochw_toofar yn
tab fnochw_toofar, m
*Other
tab q808bx, m
gen fnochw_other = .
replace fnochw_other = 0 if f_chwnocare == 1 & survey == 2
replace fnochw_other = 1 if q808bx == "X"
lab var fnochw_other "Did not go to CHW for other reason"
lab val fnochw_other yn
tab fnochw_other, m
*Don't know
tab q808bz, m
gen fnochw_dk = .
replace fnochw_dk = 0 if f_chwnocare == 1  & survey == 2
replace fnochw_dk = 1 if q808bz == "Z"
lab var fnochw_dk "Do not know reason"
lab val fnochw_dk yn
tab fnochw_dk, m

*Reasons did not seek care
tab1 q828*
*Did not think condition serious
tab q828a, m
gen fnocare_serious = .
replace fnocare_serious = 0 if f_nocare == 1
replace fnocare_serious = 1 if q828a == "A"
lab var fnocare_serious "Did not think illness serious"
lab val fnocare_serious yn
tab fnocare_serious, m
*The condition passed
tab q828b, m
gen fnocare_passed = .
replace fnocare_passed = 0 if f_nocare == 1
replace fnocare_passed = 1 if q828b == "B"
lab var fnocare_passed "Condition passed"
lab val fnocare_passed yn
tab fnocare_passed, m
*Place of care was too far
tab q828c, m
gen fnocare_toofar = .
replace fnocare_toofar = 0 if f_nocare == 1
replace fnocare_toofar = 1 if q828c == "C"
lab var fnocare_toofar "Place too far"
lab val fnocare_toofar yn
tab fnocare_toofar, m
*Did not have time
tab q828d, m
gen fnocare_notime = .
replace fnocare_notime = 0 if f_nocare == 1
replace fnocare_notime = 1 if q828d == "D"
lab var fnocare_notime "Did not have time"
lab val fnocare_notime yn
tab fnocare_notime, m
*Did not have permission
tab q828e, m
gen fnocare_nopermiss = .
replace fnocare_nopermiss = 0 if f_nocare == 1
replace fnocare_nopermiss = 1 if q828e == "E"
lab var fnocare_nopermiss "Did not have permission"
lab val fnocare_nopermiss yn
tab fnocare_nopermiss, m
*Did not have money for transport
tab q828f, m
gen fnocare_transport = .
replace fnocare_transport = 0 if f_nocare == 1
replace fnocare_transport = 1 if q828f == "F"
lab var fnocare_transport "Did not have money for transport"
lab val fnocare_transport yn
tab fnocare_transport, m
*Could treat condition at home
tab q828g, m
gen fnocare_hometx = .
replace fnocare_hometx = 0 if f_nocare == 1
replace fnocare_hometx = 1 if q828g == "G"
lab var fnocare_hometx "Could treat at home"
lab val fnocare_hometx yn
tab fnocare_hometx, m
*Other reason did not seek care
tab q828x, m
gen fnocare_other = .
replace fnocare_other = 0 if f_nocare == 1
replace fnocare_other = 1 if q828x == "X"
lab var fnocare_other "Other reason"
lab val fnocare_other yn
tab fnocare_other, m
*Don't know
tab q828z, m
gen fnocare_dk = .
replace fnocare_dk = 0 if f_nocare == 1
replace fnocare_dk = 1 if q828z == "Z"
lab var fnocare_dk "Don't know"
lab val fnocare_dk yn
tab fnocare_dk, m

******************************Fast Breathing************************************
tab fb_case survey, m

*Sought any advice or treatment for fast breathing
tab q903, m
gen fb_soughtcare = .
replace fb_soughtcare = 0 if fb_case == 1 
replace fb_soughtcare = 1 if q903 == 1 
lab var fb_soughtcare "Sought treatment for fast breathing"
lab val fb_soughtcare yn
tab fb_soughtcare, m
tab fb_soughtcare survey, col

*Sought treatment from appropriate provider
tab1 q906a-q906f
*Hospital
tab q906a, m
gen fb_hosp = .
replace fb_hosp = 0 if fb_soughtcare == 1
replace fb_hosp = 1 if q906a == "A"
lab var fb_hosp "Sought treatment from hospital"
lab val fb_hosp yn
tab fb_hosp, m
*Health center
tab q906b, m
gen fb_hcent = .
replace fb_hcent = 0 if fb_soughtcare == 1
replace fb_hcent = 1 if q906b == "B"
lab var fb_hcent "Sought treatment from health center"
lab val fb_hcent yn
tab fb_hcent, m
*Health post
tab q906c, m
gen fb_hpost = .
replace fb_hpost = 0 if fb_soughtcare == 1
replace fb_hpost = 1 if q906c == "C"
lab var fb_hpost "Sought treatment from health post"
lab val fb_hpost yn
tab fb_hpost, m
*Dispensary
tab q906d, m
gen fb_disp = .
replace fb_disp = 0 if fb_soughtcare == 1
replace fb_disp = 1 if q906d == "D"
lab var fb_disp "Sought treatment from dispensary"
lab val fb_disp yn
tab fb_disp, m
*Clinic
tab q906e, m
gen fb_clinic = .
replace fb_clinic = 0 if fb_soughtcare == 1
replace fb_clinic = 1 if q906e == "E"
lab var fb_clinic "Sought treatment from clinic"
lab val fb_clinic yn
tab fb_clinic, m
*ReCO
tab q906f, m
gen fb_reco = .
replace fb_reco = 0 if fb_soughtcare == 1
replace fb_reco = 1 if q906f == "F"
lab var fb_reco "Sought treatment from ReCO"
lab val fb_reco yn
tab fb_reco, m
*Traditional healer
tab q906g, m
gen fb_trad = .
replace fb_trad = 0 if fb_soughtcare == 1 
replace fb_trad = 1 if q906g == "G" 
lab var fb_trad "Sought care from traditional healer"
lab val fb_trad yn
tab fb_trad, m
*Shop
tab q906h, m
gen fb_shop = .
replace fb_shop = 0 if fb_soughtcare == 1
replace fb_shop = 1 if q906h == "H" 
lab var fb_shop "Sought care from shop"
lab val fb_shop yn
tab fb_shop, m
*Pharmacy
tab q906i, m
gen fb_pharm = .
replace fb_pharm = 0 if fb_soughtcare == 1
replace fb_pharm = 1 if q906i == "I" 
lab var fb_pharm "Sought care from pharmacy"
lab val fb_pharm yn
tab fb_pharm, m
*Friend or parent
tab q906j, m
gen fb_friend = .
replace fb_friend = 0 if fb_soughtcare == 1
replace fb_friend = 1 if q906j == "J" 
lab var fb_friend "Sought care from friend or parent"
lab val fb_friend yn
tab fb_friend, m
*Market
tab q906k, m
gen fb_market = .
replace fb_market = 0 if fb_soughtcare == 1 
replace fb_market = 1 if q906k == "K" 
lab var fb_market "Sought care from market"
lab val fb_market yn
tab fb_market, m
*Other
tab q906x, m
gen fb_other = .
replace fb_other = 0 if fb_soughtcare == 1
replace fb_other = 1 if q906x == "X" 
lab var fb_other "Sought care from other source"
lab val fb_other yn
tab fb_other, m

*total number of providers visited 
foreach x of varlist q906a-q906x {
  replace `x' = "" if `x' =="."
}
egen fb_provtot = rownonmiss(q906a-q906x),strok
replace fb_provtot = . if fb_case != 1
lab var fb_provtot "Total number of providers where sought care"
tab fb_provtot survey, col

*Sougth care from appropriate provider- BL and EL
gen fb_appprov = .
replace fb_appprov = 0 if fb_case == 1 
replace fb_appprov = 1 if fb_hosp == 1 | fb_hcent == 1 | fb_hpost == 1 | fb_disp == 1 | fb_clinic == 1 | fb_reco == 1
lab var fb_appprov "Sought appropriate care"
lab val fb_appprov yn
tab fb_appprov, m
tab fb_appprov survey, col

*Sought care from CHW, among all fever cases by sex
gen fb_chw = .
replace fb_chw = 0 if fb_case == 1 
replace fb_chw = 1 if fb_reco == 1
lab var fb_chw "Sought care from ReCO"
lab val fb_chw yn
tab fb_chw, m
tab fb_chw fb_sex, col

*Sougth care from CHW first
tab q908, m
gen fb_chwfirst = .
replace fb_chwfirst = 0 if fb_case == 1
replace fb_chwfirst = 1 if q908 == "F"
replace fb_chwfirst = 1 if q906f == "F" & fb_provtot == 1
lab var fb_chwfirst "Sought care from CHW first"
lab val fb_chwfirst yn
tab fb_chwfirst, m
tab fb_chwfirst survey, col

*visited an CHW as first (*or only*) source of care 
gen fb_chwfirst_anycare = .
replace fb_chwfirst_anycare = 0 if fb_case == 1 & q903 == 1
replace fb_chwfirst_anycare = 1 if q908 == "F"
replace fb_chwfirst_anycare = 1 if q906f == "F" & fb_provtot == 1
lab var fb_chwfirst_anycare "Sought care from CHW first among those who sought any care"
lab val fb_chwfirst_anycare yn
svy: tab fb_chwfirst_anycare survey, col ci obs pear

*CHW assessed rapid breathing using counting beads (among those assessed by CHW)
tab q910bb, m
tab fb_reco q910bb, col m
gen fb_cbchw = .
replace fb_cbchw = 0 if fb_reco==1
replace fb_cbchw = 1 if q910bb==1
lab var fb_cbchw "CHW used counting beads to assess rapid breathing"
lab val fb_cbchw yn
svy: tab fb_cbchw survey, col ci obs

*Sought care jointly with partner, among those that sought care
tab q904, m
gen fb_joint = .
replace fb_joint = 0 if union == 1 & fb_case == 1
replace fb_joint = 1 if union == 1 & fb_case == 1 & q903 == 1 & q905a =="A"
lab var fb_joint "Sought care jointly with partner"
lab val fb_joint yn
tab fb_joint, m
tab fb_joint survey, col

*Source of care for fast breathing
tab1 q906*
*Hospital
tab fb_hosp, m
tab fb_hosp survey, col
*health center
tab fb_hcent, m
tab fb_hcent survey, col
*Health post
tab fb_hpost, m
tab fb_hpost survey, col
*Dispensary
tab fb_disp, m
tab fb_disp survey, col
*Clinic
tab fb_clinic, m
tab fb_clinic survey, col
*ReCO
tab fb_reco, m
tab fb_reco survey, col
*Traditional healer
tab fb_trad, m
tab fb_trad survey, col
*Shop
tab fb_shop, m
tab fb_shop survey, col
*Pharmacy
tab fb_pharm, m
tab fb_pharm survey, col
*Friend or parent
tab fb_friend, m
tab fb_friend survey, col
*Market
tab fb_market, m
tab fb_market survey, col
*Other
tab fb_other, m
tab fb_other survey, col

*Source caregiver first sought care from
tab q908, m

*first source of care locations - fast breathing
gen fb_fcs_hosp = 1 if q908 == "A" 
gen fb_fcs_hcent = 1 if q908 == "B" 
gen fb_fcs_hpost = 1 if q908 == "C"
gen fb_fcs_disp = 1 if q908 == "D" 
gen fb_fcs_clinic = 1 if q908 == "E"
gen fb_fcs_reco = 1 if q908 == "F"
gen fb_fcs_trad = 1 if q908 == "G"
gen fb_fcs_shop = 1 if q908 == "H"
gen fb_fcs_pharm = 1 if q908 == "I"
gen fb_fcs_friend = 1 if q908 == "J"
gen fb_fcs_market = 1 if q908 == "K"
gen fb_fcs_other = 1 if q908 == "X"

replace fb_fcs_hosp = 1 if q906a == "A" & fb_provtot == 1
replace fb_fcs_hcent = 1 if q906b == "B" & fb_provtot == 1
replace fb_fcs_hpost = 1 if q906c == "C" & fb_provtot == 1
replace fb_fcs_disp = 1 if q906d == "D" & fb_provtot == 1
replace fb_fcs_clinic = 1 if q906e == "E" & fb_provtot == 1
replace fb_fcs_reco = 1 if q906f == "F" & fb_provtot == 1
replace fb_fcs_trad = 1 if q906g == "G" & fb_provtot == 1
replace fb_fcs_shop = 1 if q906h == "H" & fb_provtot == 1
replace fb_fcs_pharm = 1 if q906i == "I" & fb_provtot == 1
replace fb_fcs_friend = 1 if q906j == "J" & fb_provtot == 1
replace fb_fcs_market = 1 if q906k == "K" & fb_provtot == 1
replace fb_fcs_other = 1 if q906x == "X" & fb_provtot == 1

foreach x of varlist fb_fcs_* {
  replace `x' = 0 if fb_case == 1 & q903 == 1 & `x' ==.
  lab val `x' yn
}

*Respiratory rate assessed by CHW - any method
tab q909, m
gen fb_assessedchw = .
replace fb_assessedchw = 0 if fb_reco==1
replace fb_assessedchw = 1 if fb_reco==1 & (q910a == "A" | q910bb == 1)
lab var fb_assessedchw "Respiratory rate assessed by CHW, among those that sought care from RECO"
lab val fb_assessedchw yn
tab fb_assessedchw, m
tab fb_assessedchw survey, col
svy: tab fb_assessedchw survey, col ci pear

*Respiratory rate assessed by CHW - using watch/timer
tab q909, m
gen fb_assessedchwtimer = .
replace fb_assessedchwtimer = 0 if fb_reco==1
replace fb_assessedchwtimer = 1 if fb_reco==1 & q910a == "A" 
lab var fb_assessedchwtimer "Respiratory rate assessed by CHW using watch or timer, among those that sought care from RECO"
lab val fb_assessedchwtimer yn
tab fb_assessedchwtimer, m
tab fb_assessedchwtimer survey, col
svy: tab fb_assessedchwtimer survey, col ci pear

*Respiratory rate assessed by CHW - using counting beads
tab q909, m
gen fb_assessedchwcb = .
replace fb_assessedchwcb = 0 if fb_reco==1
replace fb_assessedchwcb = 1 if fb_reco==1 & q910bb == 1
lab var fb_assessedchwcb "Respiratory rate assessed by CHW using counting beads, among those that sought care from RECO"
lab val fb_assessedchwcb yn
tab fb_assessedchwcb, m
tab fb_assessedchwcb survey, col
svy: tab fb_assessedchwcb survey, col ci pear obs

*Respiratory rate assessed-all cases
tab q909, m
gen fb_assessed = .
replace fb_assessed = 0 if fb_case == 1
replace fb_assessed = 1 if q909 == 1 
lab var fb_assessed "Respiratory rate assessed-All cases"
lab val fb_assessed yn
tab fb_assessed, m
tab fb_assessed survey, col
svy: tab fb_assessed survey, col ci pear

*Who assessed breathing
tab1 q910*
*ReCO
tab q910a, m
gen q910_a = .
replace q910_a = 0 if q909 == 1
replace q910_a = 1 if q910a == "A" | q910 == 1
lab var q910_a "CHW assessed breathing"
lab val q910_a yn
tab q910_a, m
tab q910_a survey, col
*Medical assistant
tab q910b, m
gen q910_b = .
replace q910_b = 0 if q909 == 1
replace q910_b = 1 if q910b == "B" | q910 == 2
lab var q910_b "Medical assistant assessed breathing"
lab val q910_b yn
tab q910_b, m
tab q910_b survey, col
*Clinical officer
tab q910c, m
gen q910_c = .
replace q910_c = 0 if q909 == 1
replace q910_c = 1 if q910c == "C" | q910 == 3
lab var q910_c "Clinical officer assessed breathing"
lab val q910_c yn
tab q910_c, m
tab q910_c survey, col
*Nurse
tab q910d, m
gen q910_d = .
replace q910_d = 0 if q909 == 1
replace q910_d = 1 if q910d == "D" | q910 == 4
lab var q910_d "Nurse assessed breathing"
lab val q910_d yn
tab q910_d, m
tab q910_d survey, col
*Doctor
tab q910e, m
gen q910_e = .
replace q910_e = 0 if q909 == 1
replace q910_e = 1 if q910e == "E" | q910 == 5
lab var q910_e "Doctor assessed breathing"
lab val q910_e yn
tab q910_e, m
tab q910_e survey, col
*Other
tab q910x, m
gen q910_x = .
replace q910_x = 0 if q909 == 1
replace q910_x = 1 if q910x == "X" | q910 == 6
lab var q910_x "Other provider assessed breathing"
lab val q910_x yn
tab q910_x, m
tab q910_x survey, col
*Missing
gen q910_missing = .
replace q910_missing = 0 if q909 == 1
replace q910_missing = 1 if q910 == 9 | (q910_a==0 & q910_b==0 & q910_c==0 & q910_d==0 & q910_e==0 & q910_x==0) 
lab var q910_missing "Other provider assessed breathing"
lab val q910_missing yn
tab q910_missing, m
tab q910_missing survey, col

*Child assessed for fast breathing by provider other than CHW, among those who sought care from other providers
gen fb_assessedoth = .
replace fb_assessedoth = 0 if (fb_provtot == 1 & fb_chw != 1) | (fb_provtot !=. & fb_provtot >= 2 )
replace fb_assessedoth = 1 if ((fb_provtot == 1 & fb_chw != 1) | (fb_provtot !=. & fb_provtot >= 2 )) & (q910_b==1 | q910_c==1 | q910_d==1 | q910_e==1 | q910_x==1)
replace fb_assessedoth =. if q910_missing == 1
lab var fb_assessedoth "Child assessed for fast breathing by provider other than CHW"
lab val fb_assessedoth yn
tab fb_assessedoth survey, m

*Child recieved appropriate treatment-all cases
gen fb_flab = .
replace fb_flab = 0 if fb_case == 1
replace fb_flab = 1 if q912d == "D" 
lab var fb_flab "Recieved flabicillin-all cases"
lab val fb_flab yn
tab fb_flab, m
tab fb_flab survey, col
svy: tab fb_flab survey, col ci pear

*Child recieved appropriate treatment from CHW, among all fb cases
tab q912d, m
tab q914, m
gen fb_flabchw = .
replace fb_flabchw = 0 if fb_case == 1
replace fb_flabchw = 1 if q912d == "D" & q914 == 16
lab var fb_flabchw "Recieved amoxicillin from CHW"
lab val fb_flabchw yn
tab fb_flabchw, m
tab fb_flabchw survey, col
svy: tab fb_flabchw survey, col ci pear

*Child recieved appropriate treatment from provider other than CHW, among all fb cases
gen fb_flaboth = .
replace fb_flaboth = 0 if fb_case == 1
replace fb_flaboth = 1 if q912d == "D" & q914 != 16
lab var fb_flaboth "Recieved amoxicillin from provider other than CHW"
lab val fb_flaboth yn
tab fb_flaboth, m
tab fb_flaboth survey, col
svy: tab fb_flaboth survey, col ci pear

*treated with first line antibiotics by a CHW, among those who sought care from a CHW
gen fb_flabchw2 = .
replace fb_flabchw2 = 0 if fb_reco == 1
replace fb_flabchw2 = 1 if fb_flabchw == 1 & fb_reco == 1
lab var fb_flabchw2 "Got 1st line antibiotic from CHW, among those who sought care from CHW"
lab val fb_flabchw2 yn
tab fb_flabchw2 survey, col
svy: tab fb_flabchw2 survey, col ci pear obs

*Sought care from provider other than RCom and ASC
gen fb_careoth = 0 if fb_case == 1
replace fb_careoth = 1 if fb_provtot == 1 & fb_chw != 1
replace fb_careoth = 1 if fb_provtot >= 2 & fb_provtot !=.
tab fb_careoth survey

* treated with first line antibiotics by provider other than ASC and CHW (INDICATOR 14D) 
gen fb_flaboth2 = 0 if fb_careoth == 1
replace fb_flaboth2 = 1 if fb_flaboth == 1 & fb_careoth == 1
replace fb_flaboth2 = . if fb_flab == 1 & q914 == .
lab var fb_flaboth2 "Got first line antibiotic for fast breathing from provider other than CHW"
lab val fb_flaboth2 yn
tab fb_flaboth2 survey, col

*Treatment for fast breathing
tab1 q912*
*ACT
tab q912a, m
gen fbtx_act = .
replace fbtx_act = 0 if fb_case == 1
replace fbtx_act = 1 if q912a == "A"
lab var fbtx_act "Given ACT for fast breathing"
lab val fbtx_act yn
tab fbtx_act, m
svy: tab fbtx_act survey if q911 == 1, col ci obs
*Quinine
tab q912b, m
gen fbtx_qui = .
replace fbtx_qui = 0 if fb_case == 1
replace fbtx_qui = 1 if q912b == "B"
lab var fbtx_qui "Given quinine for fast breathing"
lab val fbtx_qui yn
tab fbtx_qui, m
svy: tab fbtx_qui survey if q911 == 1, col ci obs
*SP
tab q912c, m
gen fbtx_sp = .
replace fbtx_sp = 0 if fb_case == 1
replace fbtx_sp = 1 if q912c == "C"
lab var fbtx_sp "Given SP for fast breathing"
lab val fbtx_sp yn
tab fbtx_sp, m
svy: tab fbtx_sp survey if q911 == 1, col ci obs
*Amoxicillin
tab q912d, m
gen fbtx_amox = .
replace fbtx_amox = 0 if fb_case == 1
replace fbtx_amox = 1 if q912d == "D"
lab var fbtx_amox "Given amoxicillin for fast breathing"
lab val fbtx_amox yn
tab fbtx_amox, m
tab fbtx_amox, m
svy: tab fbtx_amox survey if q911 == 1, col ci obs
*Cotrim
tab q912e, m
gen fbtx_cotrim = .
replace fbtx_cotrim = 0 if fb_case == 1
replace fbtx_cotrim = 1 if q912e == "E"
lab var fbtx_cotrim "Given cotrim for fast breathing"
lab val fbtx_cotrim yn
tab fbtx_cotrim, m
svy: tab fbtx_cotrim survey if q911 == 1, col ci obs
*Antibiotic pills/syrup
tab q912f, m
gen fbtx_antibps = .
replace fbtx_antibps = 0 if fb_case == 1
replace fbtx_antibps = 1 if q912f == "F"
lab var fbtx_antibps "Given antibiotic pills or syrup for fast breathing"
lab val fbtx_antibps yn
tab fbtx_antibps, m
svy: tab fbtx_antibps survey if q911 == 1, col ci obs
*Antibiotic injection
tab q912g, m
gen fbtx_antibinj = .
replace fbtx_antibinj = 0 if fb_case == 1
replace fbtx_antibinj = 1 if q912g == "G"
lab var fbtx_antibinj "Given antibiotic injection for fast breathing"
lab val fbtx_antibinj yn
tab fbtx_antibinj, m
svy: tab fbtx_antibinj survey if q911 == 1, col ci obs
*Aspirin
tab q912h, m
gen fbtx_aspirin = .
replace fbtx_aspirin = 0 if fb_case == 1
replace fbtx_aspirin = 1 if q912h == "H"
lab var fbtx_aspirin "Given aspirin for fast breathing"
lab val fbtx_aspirin yn
tab fbtx_aspirin, m
svy: tab fbtx_aspirin survey if q911 == 1, col ci obs
*Paracetamol
tab q912i, m
gen fbtx_para = .
replace fbtx_para = 0 if fb_case == 1
replace fbtx_para = 1 if q912i == "I"
lab var fbtx_para "Given paracetamol for fast breathing"
lab val fbtx_para yn
tab fbtx_para, m
svy: tab fbtx_para survey if q911 == 1, col ci obs
*Other
tab q912x, m
gen fbtx_other = .
replace fbtx_other = 0 if fb_case == 1
replace fbtx_other = 1 if q912x == "X"
lab var fbtx_other "Given other treatment for fast breathing"
lab val fbtx_other yn
tab fbtx_other, m
svy: tab fbtx_other survey if q911 == 1, col ci obs
*Do not know what child was given
tab q912z, m
gen fbtx_dk = .
replace fbtx_dk = 0 if fb_case == 1
replace fbtx_dk = 1 if q912z == "Z"
lab var fbtx_dk "Do not know treatment given for fast breathing"
lab val fbtx_dk yn
tab fbtx_dk, m
svy: tab fbtx_dk survey if q911 == 1, col ci obs

*Source of amoxicillin for child with fast breathing
tab q914, m
*Hospital
gen fbamox_hosp = .
replace fbamox_hosp = 0 if fbtx_amox == 1
replace fbamox_hosp = 1 if fbtx_amox==1 & q914 == 11
lab var fbamox_hosp "Given amoxicillin at hospital"
lab val fbamox_hosp yn
tab fbamox_hosp, m
tab fbamox_hosp survey, col
*Health center
gen fbamox_hcent = .
replace fbamox_hcent = 0 if fbtx_amox == 1
replace fbamox_hcent = 1 if fbtx_amox==1 & q914 == 12
lab var fbamox_hcent "Given amoxicillin at health center"
lab val fbamox_hcent yn
tab fbamox_hcent, m
tab fbamox_hcent survey, col
*Health post
gen fbamox_hpost = .
replace fbamox_hpost = 0 if fbtx_amox == 1
replace fbamox_hpost = 1 if fbtx_amox==1 & q914 == 13
lab var fbamox_hpost "Given amoxicillin at health post"
lab val fbamox_hpost yn
tab fbamox_hpost, m
tab fbamox_hpost survey, col
*Dispensary
gen fbamox_disp = .
replace fbamox_disp = 0 if fbtx_amox == 1
replace fbamox_disp = 1 if fbtx_amox==1 & q914 == 14
lab var fbamox_disp "Given amoxicillin at dispensary"
lab val fbamox_disp yn
tab fbamox_disp, m
tab fbamox_disp survey, col
*Clinic
gen fbamox_clinic = .
replace fbamox_clinic = 0 if fbtx_amox == 1
replace fbamox_clinic = 1 if fbtx_amox==1 & q914 == 15
lab var fbamox_clinic "Given amoxicillin at clinic"
lab val fbamox_clinic yn
tab fbamox_clinic, m
tab fbamox_clinic survey, col
*ReCO
gen fbamox_reco = .
replace fbamox_reco = 0 if fbtx_amox == 1
replace fbamox_reco = 1 if fbtx_amox==1 & q914 == 16
lab var fbamox_reco "Given amoxicillin from CHW"
lab val fbamox_reco yn
tab fbamox_reco, m
tab fbamox_reco survey, col
*Traditional healer
gen fbamox_trad = .
replace fbamox_trad = 0 if fbtx_amox == 1
replace fbamox_trad = 1 if fbtx_amox==1 & q914 == 21
lab var fbamox_trad "Given amoxicillin from traditional healer"
lab val fbamox_trad yn
tab fbamox_trad, m
tab fbamox_trad survey, col
*Shop
gen fbamox_shop = .
replace fbamox_shop = 0 if fbtx_amox == 1
replace fbamox_shop = 1 if fbtx_amox==1 & q914 == 22
lab var fbamox_shop "Given amoxicillin at a shop"
lab val fbamox_shop yn
tab fbamox_shop, m
tab fbamox_shop survey, col
*Pharmacy
gen fbamox_pharm = .
replace fbamox_pharm = 0 if fbtx_amox == 1
replace fbamox_pharm = 1 if fbtx_amox==1 & q914 == 23
lab var fbamox_pharm "Given amoxicillin at a pharmacy"
lab val fbamox_pharm yn
tab fbamox_pharm, m
tab fbamox_pharm survey, col
*Friend or parent
gen fbamox_friend = .
replace fbamox_friend = 0 if fbtx_amox == 1
replace fbamox_friend = 1 if fbtx_amox==1 & q914 == 26
lab var fbamox_friend "Given amoxicillin from a friend or parent"
lab val fbamox_friend yn
tab fbamox_friend, m
tab fbamox_friend survey, col
*Market
gen fbamox_market = .
replace fbamox_market = 0 if fbtx_amox == 1
replace fbamox_market = 1 if fbtx_amox==1 & q914 == 27
lab var fbamox_market "Given amoxicillin at a market"
lab val fbamox_market yn
tab fbamox_market, m
tab fbamox_market survey, col
*Other
gen fbamox_other = .
replace fbamox_other = 0 if fbtx_amox == 1
replace fbamox_other = 1 if fbtx_amox==1 & q914 == 31
lab var fbamox_other "Given amoxicillin from other source"
lab val fbamox_other yn
tab fbamox_other, m
tab fbamox_other survey, col

*Recieved first amoxicillin treatment in presence of CHW
tab q916, m
gen amox_chwfstdose = .
replace amox_chwfstdose = 0 if fb_flabchw == 1
replace amox_chwfstdose = 1 if q916 == 1 & fb_flabchw == 1
lab var amox_chwfstdose "Recieved first amox. dose in presence of CHW"
lab val amox_chwfstdose yn
tab amox_chwfstdose, m
tab amox_chwfstdose survey, col
svy: tab amox_chwfstdose survey, col ci pear

*Caregiver counseled on administration of amoxicillin
tab q917, m
gen amox_counsel = .
replace amox_counsel = 0 if fb_flabchw == 1
replace amox_counsel = 1 if q917 == 1 & fb_flabchw == 1
lab var amox_counsel "Caregiver counseled on admin of amox."
lab val amox_counsel yn
tab amox_counsel, m
tab amox_counsel survey, col
svy: tab amox_counsel survey, ci pear

*Referral given for fast breathing from CHW
tab q920, m
gen fbref_given = .
replace fbref_given = 0 if fb_reco == 1
replace fbref_given = 1 if q920 == 1
lab var fbref_given "Referral given for fast breathing"
lab val fbref_given yn
tab fbref_given, m
tab fbref_given survey, col
svy: tab fbref_given survey, col ci pear obs

*Referral completed for fast breathing
tab q921, m
gen fbref_complete = .
replace fbref_complete = 0 if fbref_given==1
replace fbref_complete = 1 if q921 == 1
lab var fbref_complete "Referral completed for fast breathing"
lab val fbref_complete yn
tab fbref_complete, m
tab fbref_complete survey, col
svy: tab fbref_complete survey, col ci pear obs

*Reasons for not completing referral
tab1 q922*
*Too Far
tab q922a, m
gen fbref_toofar = .
replace fbref_toofar = 0 if fbref_complete == 0
replace fbref_toofar = 1 if q922a == "A"
lab var fbref_toofar "Did not complete referral b/c too far"
lab val fbref_toofar yn
tab fbref_toofar, m
tab fbref_toofar survey, col
svy: tab fbref_toofar survey, col ci pear
*Did not have money
tab q922b, m
gen fbref_nomoney = .
replace fbref_nomoney = 0 if fbref_complete == 0
replace fbref_nomoney = 1 if q922b == "B"
lab var fbref_nomoney "Did not complete referral b/c no money"
lab val fbref_nomoney yn
tab fbref_nomoney, m
tab fbref_nomoney survey, col
svy: tab fbref_nomoney survey, col ci pear
*No transport
tab q922c, m
gen fbref_transport = .
replace fbref_transport = 0 if fbref_complete == 0
replace fbref_transport = 1 if q922c == "C"
lab var fbref_transport "Did not complete referral b/c no transport"
lab val fbref_transport yn
tab fbref_transport, m
tab fbref_transport survey, col
svy: tab fbref_transport survey, col ci pear
*Did not think illness serious enough
tab q922d, m
gen fbref_serious = .
replace fbref_serious = 0 if fbref_complete == 0
replace fbref_serious = 1 if q922d == "D"
lab var fbref_serious "Did not complete referral b/c did not think illness serious"
lab val fbref_serious yn
tab fbref_serious, m
tab fbref_serious survey, col
svy: tab fbref_serious survey, col ci pear
*The child improved
tab q922e, m
gen fbref_improved = .
replace fbref_improved = 0 if fbref_complete == 0
replace fbref_improved = 1 if q922e == "E"
lab var fbref_improved "Did not complete referral b/c child improved"
lab val fbref_improved yn
tab fbref_improved, m
tab fbref_improved survey, col
svy: tab fbref_improved survey, col ci pear
*No time to go
tab q922f, m
gen fbref_notime = .
replace fbref_notime = 0 if fbref_complete == 0
replace fbref_notime = 1 if q922f == "F"
lab var fbref_notime "Did not complete referral b/c no time"
lab val fbref_notime yn
tab fbref_notime, m
tab fbref_notime survey, col
svy: tab fbref_notime survey, col ci pear
*Went somehwere else
tab q922g, m
gen fbref_somewhere = .
replace fbref_somewhere = 0 if fbref_complete == 0
replace fbref_somewhere = 1 if q922g == "G"
lab var fbref_somewhere "Did not complete referral b/c went somewhere else"
lab val fbref_somewhere yn
tab fbref_somewhere, m
*Did not have permission 
tab q922h, m
gen fbref_permiss = .
replace fbref_permiss = 0 if fbref_complete == 0
replace fbref_permiss = 1 if q922h == "H"
lab var fbref_permiss "Did not complete referral b/c did not have permission"
lab val fbref_permiss yn
tab fbref_permiss, m
tab fbref_permiss survey, col
*Other
tab q922x, m
gen fbref_other = .
replace fbref_other = 0 if fbref_complete == 0
replace fbref_other = 1 if q922x == "X"
lab var fbref_other "Did not complete referral b/c other reason"
lab val fbref_other yn
tab fbref_other, m
tab fbref_other survey, col
svy: tab fbref_other survey, col ci pear
*Do not know
tab q922z, m
gen fbref_dk = .
replace fbref_dk = 0 if fbref_complete == 0
replace fbref_dk = 1 if q922z == "Z"
lab var fbref_dk "Did not complete referral b/c do not know"
lab val fbref_dk yn
tab fbref_dk, m
tab fbref_dk survey, col
svy: tab fbref_dk survey, col ci pear

*ReCo follow up - ReCo visited child
tab q923, m
gen fb_followup = .
replace fb_followup = 0 if fb_reco == 1
replace fb_followup = 1 if q923 == 1
lab var fb_followup "ReCo visited child to follow up"
lab val fb_followup yn
tab fb_followup, m
tab fb_followup survey, col
svy: tab fb_followup survey, col ci pear obs

*ReCo follow-up - Caregiver brought child to ReCo
tab q923, m
gen fb_followup2 = .
replace fb_followup2 = 0 if fb_reco == 1
replace fb_followup2 = 1 if q923 == 2
lab var fb_followup2 "Caregiver brought child to ReCo to follow up"
lab val fb_followup2 yn
tab fb_followup2, m
tab fb_followup2 survey, col
svy: tab fb_followup2 survey, col ci pear obs

*How many days it took for the CHW to follow up with FB case
tab q924, m
tab q924 survey, col

*Did not seek care
tab fb_soughtcare, m
gen fb_nocare = .
replace fb_nocare = 0 if fb_case == 1
replace fb_nocare = 1 if fb_soughtcare == 0
lab var fb_nocare "Did not seek care"
lab val fb_nocare yn
tab fb_nocare, m
tab fb_nocare survey, col
svy: tab fb_nocare survey, col ci pear obs

*Did not seek care from a CHW
gen fb_chwnocare = fb_reco
recode fb_chwnocare 0=2
recode fb_chwnocare 1=0
recode fb_chwnocare 2=1
lab var fb_chwnocare "Sought care but not from CHW"
lab val fb_chwnocare yn
tab fb_chwnocare, m
tab fb_chwnocare survey, col
svy: tab fb_chwnocare survey, col ci pear obs

**Reasons did not seek care from CHW
tab1 q908b*
*ReCO not available
tab q908ba, m
gen fbnochw_avail = .
replace fbnochw_avail = 0 if fb_chwnocare == 1 & survey == 2
replace fbnochw_avail = 1 if q908ba == "A"
lab var fbnochw_avail "Did not go to CHW b/c not available"
lab val fbnochw_avail yn
tab fbnochw_avail, m
*ReCO did not have supplies
tab q908bb, m
gen fbnochw_supp = .
replace fbnochw_supp  = 0 if fb_chwnocare == 1 & survey == 2 
replace fbnochw_supp  = 1 if q908bb == "B"
lab var fbnochw_supp  "Did not go to CHW b/c did not have supplies"
lab val fbnochw_supp  yn
tab fbnochw_supp , m
*Did not trust ReCO
tab q908bc, m
gen fbnochw_trust = .
replace fbnochw_trust = 0 if fb_chwnocare == 1 & survey == 2 
replace fbnochw_trust = 1 if q908bc == "C"
lab var fbnochw_trust "Did not go to CHW b/c did not trust them"
lab val fbnochw_trust yn
tab fbnochw_trust , m
*Condition too serious for ReCO
tab q908bd, m
gen fbnochw_serious = .
replace fbnochw_serious = 0 if fb_chwnocare == 1 & survey == 2
replace fbnochw_serious = 1 if q908bd == "D"
lab var fbnochw_serious "Did not go to CHW b/c thought illness too serious"
lab val fbnochw_serious yn
tab fbnochw_serious , m
*Prefer health center
tab q908be, m
gen fbnochw_hcent = .
replace fbnochw_hcent = 0 if fb_chwnocare == 1 & survey == 2 
replace fbnochw_hcent = 1 if q908be == "E"
lab var fbnochw_hcent "Did not go to CHW b/c prefer health center"
lab val fbnochw_hcent yn
tab fbnochw_hcent , m
*ReCO too far
tab q908bf, m
gen fbnochw_toofar = .
replace fbnochw_toofar = 0 if fb_chwnocare == 1 & survey == 2 
replace fbnochw_toofar = 1 if q908bf == "F"
lab var fbnochw_toofar "Did not go to CHW b/c too far"
lab val fbnochw_toofar yn
tab fbnochw_toofar, m
*Other
tab q908bx, m
gen fbnochw_other = .
replace fbnochw_other = 0 if fb_chwnocare == 1 & survey == 2 
replace fbnochw_other = 1 if q908bx == "X"
lab var fbnochw_other "Did not go to CHW for other reason"
lab val fbnochw_other yn
tab fbnochw_other, m
*Don't know
tab q908bz, m
gen fbnochw_dk = .
replace fbnochw_dk = 0 if fb_chwnocare == 1 & survey == 2
replace fbnochw_dk = 1 if q908bz == "Z"
lab var fbnochw_dk "Do not know reason"
lab val fbnochw_dk yn
tab fbnochw_dk, m

*Reasons did not seek care
tab1 q925*
*Did not think condition serious
tab q925a, m
gen fbnocare_serious = .
replace fbnocare_serious = 0 if fb_soughtcare == 0
replace fbnocare_serious = 1 if q925a == "A"
lab var fbnocare_serious "Did not think illness serious"
lab val fbnocare_serious yn
tab fbnocare_serious, m
*The condition passed
tab q925b, m
gen fbnocare_passed = .
replace fbnocare_passed = 0 if fb_soughtcare == 0
replace fbnocare_passed = 1 if q925b == "B"
lab var fbnocare_passed "Condition passed"
lab val fbnocare_passed yn
tab fbnocare_passed, m
*Place of care was too far
tab q925c, m
gen fbnocare_toofar = .
replace fbnocare_toofar = 0 if fb_soughtcare == 0
replace fbnocare_toofar = 1 if q925c == "C"
lab var fbnocare_toofar "Place too far"
lab val fbnocare_toofar yn
tab fbnocare_toofar, m
*Did not have time
tab q925d, m
gen fbnocare_notime = .
replace fbnocare_notime = 0 if fb_soughtcare == 0
replace fbnocare_notime = 1 if q925d == "D"
lab var fbnocare_notime "Did not have time"
lab val fbnocare_notime yn
tab fbnocare_notime, m
*Did not have permission
tab q925e, m
gen fbnocare_nopermiss = .
replace fbnocare_nopermiss = 0 if fb_soughtcare == 0
replace fbnocare_nopermiss = 1 if q925e == "E"
lab var fbnocare_nopermiss "Did not have permission"
lab val fbnocare_nopermiss yn
tab fbnocare_nopermiss, m
*Did not have money for transport
tab q925f, m
gen fbnocare_transport = .
replace fbnocare_transport = 0 if fb_soughtcare == 0
replace fbnocare_transport = 1 if q925f == "F"
lab var fbnocare_transport "Did not have money for transport"
lab val fbnocare_transport yn
tab fbnocare_transport, m
*Could treat condition at home
tab q925g, m
gen fbnocare_hometx = .
replace fbnocare_hometx = 0 if fb_soughtcare == 0
replace fbnocare_hometx = 1 if q925g == "G"
lab var fbnocare_hometx "Could treat at home"
lab val fbnocare_hometx yn
tab fbnocare_hometx, m
*Other reason did not seek care
tab q925x, m
gen fbnocare_other = .
replace fbnocare_other = 0 if fb_soughtcare == 0
replace fbnocare_other = 1 if q925x == "X"
lab var fbnocare_other "Other reason"
lab val fbnocare_other yn
tab fbnocare_other, m
*Don't know
tab q925z, m
gen fbnocare_dk = .
replace fbnocare_dk = 0 if fb_soughtcare == 0
replace fbnocare_dk = 1 if q925z == "Z"
lab var fbnocare_dk "Don't know"
lab val fbnocare_dk yn
tab fbnocare_dk, m

save "DRC HH Analysis", replace

******************************Overall Indicators********************************
********************************************************************************
*Overall indicators across all three illnesses
*First create a variable in the final analysis file to indicate that will be used to indicate the illness
*Used the variable "set" and created three separate files
*SET: 1 = diarrhea, 2 = fever, and 3 = fast breathing.
use "DRC HH Analysis.dta", clear
gen set = 1
save "DRC_overallvariables_set1.dta", replace
replace set = 2
save "DRC_overallvariables_set2.dta", replace
replace set = 3
save "DRC_overallvariables_set3.dta", replace

*In the diarrhea file, drop any caregiver records without a child who had diarrhea
use "DRC_overallvariables_set1.dta", clear
tab d_case
drop if d_case != 1
save "DRC_overallvariables_set1.dta", replace

*In the fever file, drop any caregiver records without a child who had fever
use "DRC_overallvariables_set2.dta", clear
tab f_case
drop if f_case != 1
save "DRC_overallvariables_set2.dta", replace

*In the fast breathing file, drop any caregiver records without a child who had fast breathing
use "DRC_overallvariables_set3.dta", clear
tab fb_case
drop if fb_case != 1
save "DRC_overallvariables_set3.dta", replace

*Append the three illness files together & save the resulting file
use "DRC_overallvariables_set1.dta", clear
append using "DRC_overallvariables_set2.dta", nolabel
append using "DRC_overallvariables_set3.dta", nolabel
save "DRC_overallvariables_all.dta", replace

*Total number of child sick cases
tab set, m
egen tot_illcases = rownonmiss (set)
lab var tot_illcases "Total number of illness cases"
lab val tot_illcases yn
tab tot_illcases, m

*Appropriate provder sought for treatment-overall (Indicator 8)
gen all_appprov = .
replace all_appprov = 0
replace all_appprov = 1 if (d_appprov == 1 & set == 1) | (f_appprov == 1 & set == 2) | (fb_appprov == 1 & set == 3)
lab var all_appprov "Caregiver sought appropriate care for all illnesses"
lab val all_appprov yn
tab all_appprov, m
tab all_appprov survey, col
svy: tab all_appprov survey, col ci pear obs

*Taken to CHW first for care-overall (Indicator 9)
gen all_chwfirst = .
replace all_chwfirst = 0  
replace all_chwfirst = 1 if (d_chwfirst == 1 & set == 1) | (f_chwfirst == 1 & set == 2) | (fb_chwfirst == 1 & set == 3)
lab var all_chwfirst "Taken to CHW first for care-Overall"
lab val all_chwfirst yn
tab all_chwfirst, m
tab all_chwfirst survey, col
svy: tab all_chwfirst survey, col ci pear obs

*CHW first source of care among those who sought any care, all 3 illnesses
gen all_chwfirst_anycare = .
replace all_chwfirst_anycare = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_chwfirst_anycare = 1 if (set == 1 & d_chwfirst_anycare == 1) | (set == 2 & f_chwfirst_anycare == 1) | (set == 3 & fb_chwfirst_anycare == 1)
svy: tab all_chwfirst_anycare survey, col ci pear obs

*Decided to seek care jointly
gen all_joint = .
replace all_joint = 0 if (set == 1 & d_joint !=.) | (set == 2 & f_joint !=.) | (set == 3 & fb_joint !=.)
replace all_joint = 1 if (d_joint == 1 & set == 1) | (f_joint == 1 & set == 2) | (fb_joint == 1 & set == 3)
lab var all_joint "Decided to seek care jointly-Overall"
lab val all_joint yn
tab all_joint, m
tab all_joint survey, col
svy: tab all_joint survey, col ci pear obs

*Did not seek care
gen all_nocare = .
replace all_nocare = 0 
replace all_nocare = 1 if (d_nocare == 1 & set == 1) | (f_nocare == 1 & set == 2) | (fb_nocare == 1 & set == 3)
lab var all_nocare "Did not seek care-Overall"
lab val all_nocare yn
tab all_nocare, m
tab all_nocare survey, col
svy: tab all_nocare survey, col ci pear obs

*Sought care but not from CHW
gen all_chwnocare = .
replace all_chwnocare = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_chwnocare = 1 if (d_chwnocare == 1 & set == 1) | (f_chwnocare == 1 & set == 2) | (fb_chwnocare == 1 & set == 3)
lab var all_chwnocare "Did not seek care from a CHW-Overall"
lab val all_chwnocare yn
tab all_chwnocare, m
tab all_chwnocare survey, col
svy: tab all_chwnocare survey, col ci pear obs

*Children who recieved appropriate treatment (Indicator 16) 
gen all_apptx = .
replace all_apptx = 0 if (set == 1 & d_case == 1) | (set == 2 & f_result == 1) | (set == 3 & fb_case == 1)
replace all_apptx = 1 if (d_orszinc == 1 & set == 1) | (f_act24c == 1 & set == 2) | (fb_flab == 1 & set == 3)
lab var all_apptx "Sick child recieved appropriate treatment for illness-Overall"
lab val all_apptx yn
tab all_apptx, m
tab all_apptx survey, col
svy: tab all_apptx survey, col ci pear obs

*Child received appropriate treatment from CHW (Indicator 14) 
gen all_chwapptx = .
replace all_chwapptx = 0 if (set == 1 & d_case == 1) | (set == 2 & f_result==1) | (set == 3 & fb_case == 1)
replace all_chwapptx = 1 if (d_orszincchw == 1 & set == 1) | (f_act24cchw == 1 & set == 2) | (fb_flabchw == 1 & set == 3)
lab var all_chwapptx "Sick child recieved appropriate treatment from CHW-overall"
lab val all_chwapptx yn
tab all_chwapptx, m
tab all_chwapptx survey, col
svy: tab all_chwapptx survey, col ci pear obs

*Child received appropriate treatment from provider other than CHW (Indicator 14) 
gen all_othapptx = .
replace all_othapptx = 0 if (set == 1 & d_case == 1) | (set == 2 & f_result==1) | (set == 3 & fb_case == 1)
replace all_othapptx = 1 if (d_orszincoth == 1 & set == 1) | (f_act24coth == 1 & set == 2) | (fb_flaboth == 1 & set == 3)
lab var all_othapptx "Sick child recieved appropriate treatment from provider other than CHW-overall"
lab val all_othapptx yn
tab all_othapptx, m
tab all_othapptx survey, col
svy: tab all_othapptx survey, col ci pear obs

*Child received appropriate treatment from CHW, among those that sought care from CHW
gen all_chwapptx2 = .
replace all_chwapptx2 = 0 if (set == 1 & d_orszincchw2 !=.) | (set == 2 & f_act24cchw2 !=.) | (set == 3 & fb_flabchw2 !=.)
replace all_chwapptx2 = 1 if (d_orszincchw2 == 1 & set == 1) | (f_act24cchw2 == 1 & set == 2) | (fb_flabchw2 == 1 & set == 3)
lab var all_chwapptx2 "Sick child recieved appropriate treatment from CHW-overall, among those that sought care from CHW"
lab val all_chwapptx2 yn
svy: tab all_chwapptx2 survey, col ci pear obs

*Child received appropriate treatment from provider other than CHW, among those that sought care from other providers
gen all_othapptx2 = .
replace all_othapptx2 = 0 if (set == 1 & d_orszincoth2 !=.) | (set == 2 & f_act24coth2 !=.) | (set == 3 & fb_flaboth2 !=.)
replace all_othapptx2 = 1 if (d_orszincoth2 == 1 & set == 1) | (f_act24coth2 == 1 & set == 2) | (fb_flaboth2 == 1 & set == 3)
lab var all_othapptx2 "Sick child recieved appropriate treatment from provider other than CHW, among those that sought care from others"
lab val all_othapptx2 yn
svy: tab all_othapptx2 survey, col ci pear obs

***Updated how diarrhea is calculated - both ORS & zinc must be received
*Received 1st dose treatment in front of CHW, all 3 illnesses
gen all_firstdose = .
replace all_firstdose = 0 if (orszn_chwfstdose !=. & set == 1 ) | (act_chwfstdose !=. & set == 2) | (amox_chwfstdose !=. & set == 3)
replace all_firstdose = 1 if (orszn_chwfstdose == 1 & set == 1) | (act_chwfstdose == 1 & set == 2) | (set == 3 & amox_chwfstdose==1)
svy: tab all_firstdose survey, col ci pear obs

***Updated how diarrhea is calculated - both ORS & zinc must be received
*Received counseling on treatment administration from CHW, all 3 illnesses
gen all_counsel = .
replace all_counsel = 0 if (orszn_counsel !=. & set == 1 ) | (act_counsel !=. & set == 2) | (amox_counsel !=. & set == 3)
replace all_counsel = 1 if (orszn_counsel == 1 & set == 1) | (act_counsel == 1 & set == 2) | (set == 3 & amox_counsel==1)
svy: tab all_counsel survey, col ci pear obs

*Caregiver refered by CHW 
gen all_chwrefer = .
replace all_chwrefer = 0 if (set == 1 & dref_given !=.) | (set == 2 & fref_given !=.) | (set == 3 & fbref_given !=.)
replace all_chwrefer = 1 if (set == 1 & dref_given == 1) | (set == 2 & fref_given == 1) | (set == 3 & fbref_given == 1)
lab var all_chwrefer "Caregiver referred by CHW - overall"
lab val all_chwrefer yn
tab all_chwrefer, m
tab all_chwrefer survey, col
svy: tab all_chwrefer survey, col ci pear obs

*Caregiver recieved and adhered to referral (Indicator 17)
gen all_compref = .
replace all_compref = 0 if (set == 1 & dref_given==1) | (set == 2 & fref_given==1) | (set == 3 & fbref_given==1)
replace all_compref = 1 if (dref_complete == 1 & set == 1) | (fref_complete == 1 & set == 2) | (fbref_complete == 1 & set == 3)
lab var all_compref "Caregiver recieved and completed referral-Overall"
lab val all_compref yn
tab all_compref, m
tab all_compref survey, col
svy: tab all_compref survey, col ci pear obs

*Sick child recieved a follow up visit (Indicator 18)
gen all_followup = .
replace all_followup = 0 if (set == 1 & d_reco==1) | (set == 2 & f_reco == 1) | (set == 3 & fb_reco == 1)
replace all_followup = 1 if (d_followup == 1 & set == 1) | (f_followup == 1 & set == 2) | (fb_followup == 1 & set == 3)
lab var all_followup "Sick child recieved a follow up visit from CHW-Overall"
lab val all_followup yn
tab all_followup, m
tab all_followup survey, col
svy: tab all_followup survey, col ci pear obs

*Caregiver brought child to ReCo for followup (Indicator 18)
gen all_followup2 = .
replace all_followup2 = 0 if (set == 1 & d_reco==1) | (set == 2 & f_reco == 1) | (set == 3 & fb_reco == 1)
replace all_followup2 = 1 if (d_followup2 == 1 & set == 1) | (f_followup2 == 1 & set == 2) | (fb_followup2 == 1 & set == 3)
lab var all_followup2 "Caregiver brought child to ReCo for follow-up"
lab val all_followup2 yn
tab all_followup2, m
tab all_followup2 survey, col
svy: tab all_followup2 survey, col ci pear obs

*Caregiver brought child to ReCo for followup (Indicator 18)
gen all_followup_any = .
replace all_followup_any = 0 if (set == 1 & d_reco==1) | (set == 2 & f_reco == 1) | (set == 3 & fb_reco == 1)
replace all_followup_any = 1 if ((d_followup == 1 | d_followup2 == 1) & set == 1) | ((f_followup == 1 | f_followup2 == 1) & set == 2) | ((fb_followup == 1 | fb_followup2 == 1) & set == 3)
lab var all_followup_any "Caregiver brought child to ReCo for follow-up or ReCo visited child"
lab val all_followup_any yn
tab all_followup_any, m
tab all_followup_any survey, col
svy: tab all_followup_any survey, col ci pear obs

*when CHW followed up with caregiver over all there illnesses
gen all_when_fu = 0
replace all_when_fu = q729 if set == 1
replace all_when_fu = q827 if set == 2
replace all_when_fu = q924 if set == 3
tab all_when_fu
svy: tab all_when_fu survey, col ci obs pear

*sources of care, all 3 illnesses
gen all_cs_hosp = .
replace all_cs_hosp = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_hosp = 1 if (set == 1 & d_hosp == 1) | (set == 2 & f_hosp == 1) | (set == 3 & fb_hosp == 1)

gen all_cs_hcent = .
replace all_cs_hcent = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_hcent = 1 if (set == 1 & d_hcent == 1) | (set == 2 & f_hcent == 1) | (set == 3 & fb_hcent == 1)

gen all_cs_hpost = .
replace all_cs_hpost = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_hpost = 1 if (set == 1 & d_hpost == 1) | (set == 2 & f_hpost == 1) | (set == 3 & fb_hpost == 1)

gen all_cs_disp = .
replace all_cs_disp = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_disp = 1 if (set == 1 & d_disp == 1) | (set == 2 & f_disp == 1) | (set == 3 & fb_disp == 1)

gen all_cs_clinic = .
replace all_cs_clinic = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_clinic = 1 if (set == 1 & d_clinic == 1) | (set == 2 & f_clinic == 1) | (set == 3 & fb_clinic == 1)

gen all_cs_reco = .
replace all_cs_reco = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_reco = 1 if (set == 1 & d_reco == 1) | (set == 2 & f_reco == 1) | (set == 3 & fb_reco == 1)

gen all_cs_trad = .
replace all_cs_trad= 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_trad = 1 if (set == 1 & d_trad == 1) | (set == 2 & f_trad == 1) | (set == 3 & fb_trad == 1)

gen all_cs_shop = .
replace all_cs_shop = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_shop = 1 if (set == 1 & d_shop == 1) | (set == 2 & f_shop == 1) | (set == 3 & fb_shop == 1)

gen all_cs_pharm = .
replace all_cs_pharm = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_pharm = 1 if (set == 1 & d_pharm == 1) | (set == 2 & f_pharm == 1) | (set == 3 & fb_pharm == 1)

gen all_cs_friend = .
replace all_cs_friend = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_friend= 1 if (set == 1 & d_friend== 1) | (set == 2 & f_friend == 1) | (set == 3 & fb_friend == 1)

gen all_cs_market = .
replace all_cs_market = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_market = 1 if (set == 1 & d_market == 1) | (set == 2 & f_market == 1) | (set == 3 & fb_market == 1)

gen all_cs_other = .
replace all_cs_other = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_other = 1 if (set == 1 & d_other == 1) | (set == 2 & f_other == 1) | (set == 3 & fb_other == 1)

*reasons for not complying with CHW referral
gen all_noadhere_a = .
replace all_noadhere_a = 0 if (set == 1 & dref_complete == 0) | (set == 2 & fref_complete == 0) | (set == 3 & fbref_complete == 0)
replace all_noadhere_a = 1 if (set == 1 & dref_toofar == 1) | (set == 2 & fref_toofar == 1) | (set == 3 & fbref_toofar == 1)

gen all_noadhere_b = .
replace all_noadhere_b = 0 if (set == 1 & dref_complete == 0) | (set == 2 & fref_complete == 0) | (set == 3 & fbref_complete == 0)
replace all_noadhere_b = 1 if (set == 1 & dref_nomoney == 1) | (set == 2 & fref_nomoney == 1) | (set == 3 & fbref_nomoney == 1)

gen all_noadhere_c = .
replace all_noadhere_c = 0 if (set == 1 & dref_complete == 0) | (set == 2 & fref_complete == 0) | (set == 3 & fbref_complete == 0)
replace all_noadhere_c = 1 if (set == 1 & dref_transport == 1) | (set == 2 & fref_notransport == 1) | (set == 3 & fbref_transport == 1)

gen all_noadhere_d = .
replace all_noadhere_d = 0 if (set == 1 & dref_complete == 0) | (set == 2 & fref_complete == 0) | (set == 3 & fbref_complete == 0)
replace all_noadhere_d = 1 if (set == 1 & dref_serious == 1) | (set == 2 & fref_serious == 1) | (set == 3 & fbref_serious == 1)

gen all_noadhere_e = .
replace all_noadhere_e = 0 if (set == 1 & dref_complete == 0) | (set == 2 & fref_complete == 0) | (set == 3 & fbref_complete == 0)
replace all_noadhere_e = 1 if (set == 1 & dref_improved == 1) | (set == 2 & fref_improved == 1) | (set == 3 & fbref_improved == 1)

gen all_noadhere_f = .
replace all_noadhere_f = 0 if (set == 1 & dref_complete == 0) | (set == 2 & fref_complete == 0) | (set == 3 & fbref_complete == 0)
replace all_noadhere_f = 1 if (set == 1 & dref_notime == 1) | (set == 2 & fref_notime == 1) | (set == 3 & fbref_notime == 1)

gen all_noadhere_g = .
replace all_noadhere_g = 0 if (set == 1 & dref_complete == 0) | (set == 2 & fref_complete == 0) | (set == 3 & fbref_complete == 0)
replace all_noadhere_g = 1 if (set == 1 & dref_somewhere == 1) | (set == 2 & fref_somewhere == 1) | (set == 3 & fbref_somewhere == 1)

gen all_noadhere_h = .
replace all_noadhere_h = 0 if (set == 1 & dref_complete == 0) | (set == 2 & fref_complete == 0) | (set == 3 & fbref_complete == 0)
replace all_noadhere_h = 1 if (set == 1 & dref_permiss == 1) | (set == 2 & fref_permiss == 1) | (set == 3 & fbref_permiss == 1)

gen all_noadhere_x = .
replace all_noadhere_x = 0 if (set == 1 & dref_complete == 0) | (set == 2 & fref_complete == 0) | (set == 3 & fbref_complete == 0)
replace all_noadhere_x = 1 if (set == 1 & dref_other == 1) | (set == 2 & fref_other == 1) | (set == 3 & fbref_other == 1)

*reasons for not seeking care, endline only
gen all_nocare_a = .
replace all_nocare_a = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_a = 1 if (set == 1 & dnocare_serious == 1) | (set == 2 & fnocare_serious == 1) | (set == 3 & fbnocare_serious == 1)

gen all_nocare_b = .
replace all_nocare_b = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_b = 1 if (set == 1 & dnocare_condpassed == 1) | (set == 2 & fnocare_passed == 1) | (set == 3 & fbnocare_passed == 1)

gen all_nocare_c = .
replace all_nocare_c = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_c = 1 if (set == 1 & dnocare_toofar == 1) | (set == 2 & fnocare_toofar == 1) | (set == 3 & fbnocare_toofar == 1)

gen all_nocare_d = .
replace all_nocare_d = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_d = 1 if (set == 1 & dnocare_notime == 1) | (set == 2 & fnocare_notime == 1) | (set == 3 & fbnocare_notime == 1)

gen all_nocare_e = .
replace all_nocare_e = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_e = 1 if (set == 1 & dnocare_nopermiss == 1) | (set == 2 & fnocare_nopermiss == 1) | (set == 3 & fbnocare_nopermiss == 1)

gen all_nocare_f = .
replace all_nocare_f = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_f = 1 if (set == 1 & dnocare_nomoney == 1) | (set == 2 & fnocare_transport == 1) | (set == 3 & fbnocare_transport== 1)

gen all_nocare_g = .
replace all_nocare_g = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_g = 1 if (set == 1 & dnocare_hometx == 1) | (set == 2 & fnocare_hometx == 1) | (set == 3 & fbnocare_hometx == 1)

gen all_nocare_x = .
replace all_nocare_x = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_x = 1 if (set == 1 & dnocare_other == 1) | (set == 2 & fnocare_other == 1) | (set == 3 & fbnocare_other == 1)

gen all_nocare_z = .
replace all_nocare_z = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_z = 1 if (set == 1 & dnocare_dk == 1) | (set == 2 & fnocare_dk == 1) | (set == 3 & fbnocare_dk == 1)

*reasons for not seeking care from a CHW among those who sought care, endline only
*gen all_nocarechw_a = .
*replace all_nocarechw_a = 0 if survey == 2 & ((set == 1 & d_chwnocare == 1) | (set == 2 & f_chwnocare == 1) | (set == 3 & fb_chwnocare == 1))
*replace all_nocarechw_a = 1 if (set == 1 & q708ba == 1) | (set == 2 & q808ba == 1) | (set == 3 & q908ba == 1)

*gen all_nocarechw_b = .
*replace all_nocarechw_b = 0 if survey == 2 & ((set == 1 & d_chwnocare == 1) | (set == 2 & f_chwnocare == 1) | (set == 3 & fb_chwnocare == 1))
*replace all_nocarechw_b = 1 if (set == 1 & q708b_b == 1) | (set == 2 & q808b_b == 1) | (set == 3 & q908b_b == 1)

*gen all_nocarechw_c = .
*replace all_nocarechw_c = 0 if survey == 2 & ((set == 1 & d_chwnocare == 1) | (set == 2 & f_chwnocare == 1) | (set == 3 & fb_chwnocare == 1))
*replace all_nocarechw_c = 1 if (set == 1 & q708b_c == 1) | (set == 2 & q808b_c == 1) | (set == 3 & q908b_c == 1)

*gen all_nocarechw_d = .
*replace all_nocarechw_d = 0 if survey == 2 & ((set == 1 & d_chwnocare == 1) | (set == 2 & f_chwnocare == 1) | (set == 3 & fb_chwnocare == 1))
*replace all_nocarechw_d = 1 if (set == 1 & q708b_d == 1) | (set == 2 & q808b_d == 1) | (set == 3 & q908b_d == 1)

gen all_nocarechw_e = .
replace all_nocarechw_e = 0 if survey == 2 & ((set == 1 & d_chwnocare == 1) | (set == 2 & f_chwnocare == 1) | (set == 3 & fb_chwnocare == 1))
replace all_nocarechw_e = 1 if (set == 1 & q708be == "E") | (set == 2 & q808be == "E") | (set == 3 & q908be == "E")

*gen all_nocarechw_f = .
*replace all_nocarechw_f = 0 if survey == 2 & ((set == 1 & d_chwnocare == 1) | (set == 2 & f_chwnocare == 1) | (set == 3 & fb_chwnocare == 1))
*replace all_nocarechw_f = 1 if (set == 1 & q708b_f == 1) | (set == 2 & q808b_f == 1) | (set == 3 & q908b_f == 1)

*gen all_nocarechw_g = .
*replace all_nocarechw_g = 0 if survey == 2 & ((set == 1 & d_chwnocare == 1) | (set == 2 & f_chwnocare == 1) | (set == 3 & fb_chwnocare == 1))
*replace all_nocarechw_g = 1 if (set == 1 & q708b_g == 1) | (set == 2 & q808b_g == 1) | (set == 3 & q908b_g == 1)

gen all_nocarechw_x = .
replace all_nocarechw_x = 0 if survey == 2 & ((set == 1 & d_chwnocare == 1) | (set == 2 & f_chwnocare == 1) | (set == 3 & fb_chwnocare == 1))
replace all_nocarechw_x = 1 if (set == 1 & q708bx == "X") | (set == 2 & q808bx == "X") | (set == 3 & q908bx == "X")

*gen all_nocarechw_z = .
*replace all_nocarechw_z = 0 if survey == 2 & (set == 1 & d_chwnocare == 1) | (set == 2 & f_chwnocare == 1) | (set == 3 & fb_chwnocare == 1))
*replace all_nocarechw_z = 1 if (set == 1 & q708b_z == 1) | (set == 2 & q808b_z == 1) | (set == 3 & q908b_z == 1)

*location of first source of care across all 3 illnesses
gen all_fcs_hosp = .
replace all_fcs_hosp = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_hosp= 1 if (set == 1 & d_fcs_hosp == 1) | (set == 2 & f_fcs_hosp == 1) | (set == 3 & fb_fcs_hosp == 1)

gen all_fcs_hcent = .
replace all_fcs_hcent = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_hcent = 1 if (set == 1 & d_fcs_hcent == 1) | (set == 2 & f_fcs_hcent == 1) | (set == 3 & fb_fcs_hcent == 1)

gen all_fcs_hpost = .
replace all_fcs_hpost = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_hpost = 1 if (set == 1 & d_fcs_hpost == 1) | (set == 2 & f_fcs_hpost == 1) | (set == 3 & fb_fcs_hpost == 1)

gen all_fcs_disp = .
replace all_fcs_disp = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_disp = 1 if (set == 1 & d_fcs_disp == 1) | (set == 2 & f_fcs_disp == 1) | (set == 3 & fb_fcs_disp == 1)

gen all_fcs_clinic = .
replace all_fcs_clinic = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_clinic = 1 if (set == 1 & d_fcs_clinic == 1) | (set == 2 & f_fcs_clinic == 1) | (set == 3 & fb_fcs_clinic == 1)

gen all_fcs_reco = .
replace all_fcs_reco = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_reco = 1 if (set == 1 & d_fcs_reco == 1) | (set == 2 & f_fcs_reco == 1) | (set == 3 & fb_fcs_reco == 1)

gen all_fcs_trad = .
replace all_fcs_trad = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_trad = 1 if (set == 1 & d_fcs_trad == 1) | (set == 2 & f_fcs_trad == 1) | (set == 3 & fb_fcs_trad == 1)

gen all_fcs_shop = .
replace all_fcs_shop = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_shop = 1 if (set == 1 & d_fcs_shop == 1) | (set == 2 & f_fcs_shop == 1) | (set == 3 & fb_fcs_shop == 1)

gen all_fcs_pharm = .
replace all_fcs_pharm = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_pharm = 1 if (set == 1 & d_fcs_pharm == 1) | (set == 2 & f_fcs_pharm == 1) | (set == 3 & fb_fcs_pharm == 1)

gen all_fcs_friend = .
replace all_fcs_friend = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_friend = 1 if (set == 1 & d_fcs_friend == 1) | (set == 2 & f_fcs_friend == 1) | (set == 3 & fb_fcs_friend == 1)

gen all_fcs_market = .
replace all_fcs_market = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_market = 1 if (set == 1 & d_fcs_market == 1) | (set == 2 & f_fcs_market == 1) | (set == 3 & fb_fcs_market == 1)

gen all_fcs_other = .
replace all_fcs_other = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_other = 1 if (set == 1 & d_fcs_other == 1) | (set == 2 & f_fcs_other == 1) | (set == 3 & fb_fcs_other == 1)

save "DRC HH Analysis-Overall Variables", replace

drop if q8child == q7child & set == 2
drop if q9child == q7child & set == 3
drop if q9child == q8child & set == 3

gen child_sex = 1 if (set == 1 & d_sex == 1) | (set == 2 & f_sex == 1) | (set == 3 & fb_sex == 1)
replace child_sex = 2 if (set == 1 & d_sex == 2) | (set == 2 & f_sex == 2) | (set == 3 & fb_sex == 2)
tab child_sex survey
svy: tab child_sex survey, col ci pear obs

gen child_age = d_age if set == 1
replace child_age = f_age if set == 2
replace child_age = fb_age if set == 3
recode child_age 2/11=1 12/23=2 24/35=3 36/47=4 48/59=5, gen (agecat)
lab var agecat "Age in months for child"
lab def age_cat 1 "2-11 months" 2 "12-23 months" 3 "24-35 months" 4 "36-47 months" 5 "48-59 months", modify
lab val agecat age_cat
tab agecat survey, m

gen q101 = q7child if set == 1
replace q101 = q8child if set == 2
replace q101 = q9child if set == 3

preserve

drop if survey == 2
merge 1:1 hhclust hhnumber q101 using "C:\Users\26167\Documents\WHO RAcE\Endline household survey\DRC\BL data\2014.02.26 Roster.dta"
*641 matched, 0 in master only, 232 in using only
drop if _merge != 3

svy: tab q105, ci obs
svy: tab q106, ci obs
replace q108 = 2 if q108 == .
svy: tab q108, ci obs

gen tot_illness = 0
replace tot_illness = 1 if q105 == 1
replace tot_illness = tot_illness + 1 if q106 == 1
replace tot_illness = tot_illness + 1 if q108 == 1
svy: tab tot_illness, ci obs
svy: mean tot_illness

restore
preserve

drop if survey == 1
merge 1:1 hhclust hhnumber q101 using "C:\Users\26167\Documents\WHO RAcE\Endline household survey\DRC\EL data\drc_endline_childroster_kz.dta"
*708 matched, 0 in master only, 399 in using only
drop if _merge != 3

svy: tab q105, ci obs
svy: tab q106, ci obs
replace q108 = 2 if q108 == .
svy: tab q108, ci obs

gen tot_illness = 0
replace tot_illness = 1 if q105 == 1
replace tot_illness = tot_illness + 1 if q106 == 1
replace tot_illness = tot_illness + 1 if q108 == 1
svy: tab tot_illness, ci obs
svy: mean tot_illness

restore
