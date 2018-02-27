********************************************************************************
********************************************************************************
cd "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Nigeria - MC\Allison's analysis 4.17.2017"
set more off

use "Niger State Caregiver Illness Analysis Final", clear

***Calculate each of the key indicators across all three illnesses
*SET: 1 = diarrhea, 2 = fever, and 3 = fast breathing.
gen set = 1
save "NS_overallvariables_set1.dta", replace
replace set = 2
save "NS_overallvariables_set2.dta", replace
replace set = 3
save "NS_overallvariables_set3.dta", replace

*In the diarrhea file, drop any caregiver records without a child who had diarrhea
use "NS_overallvariables_set1.dta", clear
tab d_case
drop if d_case != 1
save "NS_overallvariables_set1.dta", replace

*In the fever file, drop any caregiver records without a child who had fever
use "NS_overallvariables_set2.dta", clear
tab f_case
drop if f_case != 1
save "NS_overallvariables_set2.dta", replace

*In the fast breathing file, drop any caregiver records without a child who had fast breathing
use "NS_overallvariables_set3.dta", clear
tab fb_case
drop if fb_case != 1
save "NS_overallvariables_set3.dta", replace

*Append the three illness files together & save the resulting file
use "NS_overallvariables_set1.dta", clear
append using "NS_overallvariables_set2.dta", nolabel
append using "NS_overallvariables_set3.dta", nolabel
save "NS_overallvariables_all.dta", replace

*Total number of child sick cases
tab set, m
egen tot_illcases = rownonmiss (set)
lab var tot_illcases "Total number of illness cases"
lab val tot_illcases yn
tab tot_illcases, m

*sought care, all 3 illnesses
gen all_soughtcare = 0 if (set==1) | (set==2) | (set==3)
replace all_soughtcare = 1 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
*analysis
svy: tab all_soughtcare survey, col ci pear obs

*care-seeking from an appropriate provider, all 3 illnesses
gen all_app_prov = 0 if (set==1) | (set==2) | (set==3)
replace all_app_prov = 1 if (set == 1 & d_app_prov == 1) | (set == 2 & f_app_prov == 1) | (set == 3 & fb_app_prov == 1)
*analysis
svy: tab all_app_prov survey, col ci pear obs

*CHW first source of care, all 3 illnesses
gen all_chwfirst = 0 if (set==1) | (set==2) | (set==3)
replace all_chwfirst = 1 if (set == 1 & d_chwfirst == 1) | (set == 2 & f_chwfirst == 1) | (set == 3 & fb_chwfirst == 1)
*analysis
svy: tab all_chwfirst survey, col ci pear obs

*CHW first source of care among those who sought any care, all 3 illnesses
gen all_chwfirst_anycare = .
replace all_chwfirst_anycare = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_chwfirst_anycare = 1 if (set == 1 & d_chwfirst_anycare == 1) | (set == 2 & f_chwfirst_anycare == 1) | (set == 3 & fb_chwfirst_anycare == 1)
*analysis
svy: tab all_chwfirst_anycare survey, col ci pear obs

*Correct treatment, all 3 illnesses, among all cases (for malaria this includes ACT w/in 24 hours)
***This includes only confirmed cases of malaria in the denominator
gen all_correct_rx = 0 if (set == 1) | (set == 2 & f_result==1) | (set == 3)
replace all_correct_rx = 1 if (set == 1 & d_orszinc == 1) | (set == 2 & f_act24c == 1) | (set == 3 & fb_flab == 1)
*analysis
svy: tab all_correct_rx survey, col ci pear obs

*Correct treatment from provider other than CHW, all 3 illnesses, among all cases (for malaria this includes ACT w/in 24 hours)
***This includes only confirmed cases of malaria in the denominator
gen all_correct_rxother = 0 if (set == 1) | (set == 2 & f_result==1) | (set == 3)
replace all_correct_rxother = 1 if (set == 1 & d_orszincother == 1) | (set == 2 & f_actc24other == 1) | (set == 3 & fb_flabother == 1)
*analysis
svy: tab all_correct_rxother survey, col ci pear obs

*Correct treatment from a CHW, all 3 illnesses among all cases (for malaria this includes ACT w/in 24 hours)
***This includes only confirmed cases of malaria in the denominator
gen all_correct_rxchw = 0 if (set == 1) | (set == 2 & f_result==1) | (set == 3)
replace all_correct_rxchw = 1 if (set == 1 & d_orszincchw == 1) | (set == 2 & f_act24cchw == 1) | (set == 3 & fb_flabchw == 1)
*analysis
svy: tab all_correct_rxchw survey, col ci pear obs

*Correct treatment from a CHW, all 3 illnesses (for malaria this includes ACT w/in 24 hours)
***This includes only confirmed cases of malaria in the denominator and cases managed by a CHW
gen all_correct_rxchw2 = 0 if (set == 1 & d_chw==1) | (set == 2 & f_resultchw==1 & f_chw==1) | (set == 3 & fb_chw==1)
replace all_correct_rxchw2 = 1 if (set == 1 & d_orszincchw2 == 1) | (set == 2 & f_act24cchw2 == 1) | (set == 3 & fb_flabchw2 == 1)
*analysis
svy: tab all_correct_rxchw2 survey, col ci pear obs

*Correct treatment from provider other than CHW, all 3 illnesses (for malaria this includes ACT w/in 24 hours)
***This includes only confirmed cases of malaria in the denominator 
gen all_correct_rxoth2 = 0 if (set == 1 & d_orszincoth2 !=.) | (set == 2 & f_actc24oth2 !=.) | (set == 3 & fb_flaboth2 !=.)
replace all_correct_rxoth2 = 1 if (set == 1 & d_orszincoth2 == 1) | (set == 2 & f_actc24oth2 == 1) | (set == 3 & fb_flaboth2 == 1)
*analysis
svy: tab all_correct_rxoth2 survey, col ci pear obs

*Received 1st dose treatment in front of CHW, all 3 illnesses (for diarrhea this includes both ORS and zinc)
gen all_firstdose = .
replace all_firstdose = 0 if (d_bothfirstdose !=. & set == 1 ) | (f_act_chwp!=. & set == 2) | (fb_flab_chwp !=. & set == 3)
replace all_firstdose = 1 if (d_bothfirstdose == 1 & set == 1 ) | (f_act_chwp ==1 & set == 2) | (fb_flab_chwp == 1 & set == 3)
*analysis
svy: tab all_firstdose survey, col ci pear obs

*Received counseling on treatment administration from CHW, all 3 illnesses 
gen all_counsel = .
replace all_counsel = 0 if (d_bothcounsel!=. & set == 1 ) | (f_act_chwc!=. & set == 2) | (fb_flab_chwc !=. & set == 3)
replace all_counsel = 1 if (d_bothcounsel == 1 & set == 1 ) | (f_act_chwc ==1 & set == 2) | (fb_flab_chwc == 1 & set == 3)
*analysis
svy: tab all_counsel survey, col ci pear obs

*Given referral from CHW, all 3 illnesses
gen all_chwrefer = .
replace all_chwrefer = 0 if (d_chw==1 & set==1) | (f_chw==1 & set ==2) | (fb_chw==1 & set==3)
replace all_chwrefer = 1 if (d_chwrefer==1 & set==1 ) | (f_chwrefer==1 & set==2) | (fb_chwrefer==1 & set==3)
*analysis
svy: tab all_chwrefer survey, col ci pear obs

*Adhered to referral advice from CHW, all 3 illnesses
gen all_referadhere = .
replace all_referadhere = 0 if (d_chwrefer==1 & set==1 ) | (f_chwrefer==1 & set==2) | (fb_chwrefer==1 & set==3)
replace all_referadhere = 1 if (set==1 & d_referadhere==1) | (set==2 & f_referadhere==1) | (set==3 & fb_referadhere==1)
*analysis
svy: tab all_referadhere survey, col ci pear obs

*Received a follow-up visit from a CHW, all 3 illnesses
gen all_followup = .
replace all_followup = 0 if (d_chw==1 & set == 1 ) | (f_chw==1 & set == 2) | (fb_chw==1 & set == 3)
replace all_followup = 1 if (set==1 & d_chw_fu==1) | (set==2 & f_chw_fu==1) | (set==3 & fb_chw_fu==1)
*analysis
svy: tab all_followup survey, col ci pear obs

*decided to seek care jointly, all 3 illnesses
gen all_joint = .
replace all_joint = 0 if maritalstat==1
replace all_joint = 1 if (set==1 & d_joint==1) | (set==2 & f_joint==1) | (set==3 & fb_joint==1)
*analysis
svy: tab all_joint survey, col ci pear obs

*did not seek care, all 3 illnesses
gen all_nocare = 0
replace all_nocare = 1 if (set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1)
*analysis
svy: tab all_nocare survey, col ci pear obs

*sought care but not from a CHW, all 3 illnesses
gen all_nocarechw = .
replace all_nocarechw = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_nocarechw = 1 if (set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1)
*analysis
svy: tab all_nocarechw survey, col ci pear obs

*where sought care first, all 3 illnesses
gen all_fcs_hosp = .
replace all_fcs_hosp = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_hosp = 1 if (set == 1 & d_fcs_hosp == 1) | (set == 2 & f_fcs_hosp == 1) | (set == 3 & fb_fcs_hosp == 1)
*analysis
svy: tab all_fcs_hosp survey, col ci pear obs

gen all_fcs_hcent = .
replace all_fcs_hcent = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_hcent = 1 if (set == 1 & d_fcs_hcent == 1) | (set == 2 & f_fcs_hcent == 1) | (set == 3 & fb_fcs_hcent == 1)
*analysis
svy: tab all_fcs_hcent survey, col ci pear obs

gen all_fcs_hpost = .
replace all_fcs_hpost = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_hpost = 1 if (set == 1 & d_fcs_hpost == 1) | (set == 2 & f_fcs_hpost == 1) | (set == 3 & fb_fcs_hpost == 1)
*analysis 
svy: tab all_fcs_hpost survey, col ci pear obs

gen all_fcs_ngo = .
replace all_fcs_ngo = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_ngo = 1 if (set == 1 & d_fcs_ngo == 1) | (set == 2 & f_fcs_ngo == 1) | (set == 3 & fb_fcs_ngo == 1)
*analysis
svy: tab all_fcs_ngo survey, col ci pear obs

gen all_fcs_clin = .
replace all_fcs_clin = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_clin = 1 if (set == 1 & d_fcs_clin == 1) | (set == 2 & f_fcs_clin == 1) | (set == 3 & fb_fcs_clin == 1)
*analysis
svy: tab all_fcs_clin survey, col ci pear obs

gen all_fcs_chw = .
replace all_fcs_chw = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_chw = 1 if (set == 1 & d_fcs_chw == 1) | (set == 2 & f_fcs_chw == 1) | (set == 3 & fb_fcs_chw == 1)
*analysis
svy: tab all_fcs_chw survey, col ci pear obs

gen all_fcs_rmod = .
replace all_fcs_rmod = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_rmod = 1 if (set == 1 & d_fcs_rmod == 1) | (set == 2 & f_fcs_rmod == 1) | (set == 3 & fb_fcs_rmod == 1)
*analysis
svy: tab all_fcs_rmod survey, col ci pear obs

gen all_fcs_trad = .
replace all_fcs_trad = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_trad = 1 if (set == 1 & d_fcs_trad == 1) | (set == 2 & f_fcs_trad == 1) | (set == 3 & fb_fcs_trad == 1)
*analysis
svy: tab all_fcs_trad survey, col ci pear obs

gen all_fcs_ppmv = .
replace all_fcs_ppmv = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_ppmv = 1 if (set == 1 & d_fcs_ppmv == 1) | (set == 2 & f_fcs_ppmv == 1) | (set == 3 & fb_fcs_ppmv == 1)
*analysis
svy: tab all_fcs_ppmv survey, col ci pear obs

gen all_fcs_phar = .
replace all_fcs_phar = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_phar = 1 if (set == 1 & d_fcs_phar == 1) | (set == 2 & f_fcs_phar == 1) | (set == 3 & fb_fcs_phar == 1)
*analysis
svy: tab all_fcs_phar survey, col ci pear obs

gen all_fcs_friend = .
replace all_fcs_friend = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_friend = 1 if (set == 1 & d_fcs_friend == 1) | (set == 2 & f_fcs_friend == 1) | (set == 3 & fb_fcs_friend == 1)
*analysis
svy: tab all_fcs_friend survey, col ci pear obs

gen all_fcs_mark = .
replace all_fcs_mark = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_mark = 1 if (set == 1 & d_fcs_mark == 1) | (set == 2 & f_fcs_mark == 1) | (set == 3 & fb_fcs_mark == 1)
*analysis
svy: tab all_fcs_mark survey, col ci pear obs

gen all_fcs_other = .
replace all_fcs_other = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_fcs_other = 1 if (set == 1 & d_fcs_other == 1) | (set == 2 & f_fcs_other == 1) | (set == 3 & fb_fcs_other == 1)
*analysis 
svy: tab all_fcs_other survey, col ci pear obs

*sources of care, all 3 illnesses
gen all_cs_hosp = .
replace all_cs_hosp = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_hosp = 1 if (set == 1 & d_cs_hosp == 1) | (set == 2 & f_cs_hosp == 1) | (set == 3 & fb_cs_hosp == 1)
*analysis
svy: tab all_cs_hosp survey, col ci pear obs

gen all_cs_hcent = .
replace all_cs_hcent = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_hcent = 1 if (set == 1 & d_cs_hcent == 1) | (set == 2 & f_cs_hcent == 1) | (set == 3 & fb_cs_hcent == 1)
*analysis
svy: tab all_cs_hcent survey, col ci pear obs

gen all_cs_hpost = .
replace all_cs_hpost = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_hpost = 1 if (set == 1 & d_cs_hpost == 1) | (set == 2 & f_cs_hpost == 1) | (set == 3 & fb_cs_hpost == 1)
*analysis
svy: tab all_cs_hpost survey, col ci pear obs

gen all_cs_ngo = .
replace all_cs_ngo = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_ngo = 1 if (set == 1 & d_cs_ngo == 1) | (set == 2 & f_cs_ngo == 1) | (set == 3 & fb_cs_ngo == 1)
*analysis
svy: tab all_cs_ngo survey, col ci pear obs

gen all_cs_clin = .
replace all_cs_clin = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_clin = 1 if (set == 1 & d_cs_clin == 1) | (set == 2 & f_cs_clin == 1) | (set == 3 & fb_cs_clin == 1)
*analysis
svy: tab all_cs_clin survey, col ci pear obs

gen all_cs_chw = .
replace all_cs_chw = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_chw = 1 if (set == 1 & d_cs_chw == 1) | (set == 2 & f_cs_chw == 1) | (set == 3 & fb_cs_chw == 1)
*analysis
svy: tab all_cs_chw survey, col ci pear obs

gen all_cs_rmod = .
replace all_cs_rmod = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_rmod = 1 if (set == 1 & d_cs_rmod == 1) | (set == 2 & f_cs_rmod == 1) | (set == 3 & fb_cs_rmod == 1)
*analysis-removed 'col' b/c single row
svy: tab all_cs_rmod survey, ci pear obs

gen all_cs_trad = .
replace all_cs_trad = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_trad = 1 if (set == 1 & d_cs_trad == 1) | (set == 2 & f_cs_trad == 1) | (set == 3 & fb_cs_trad == 1)
*analysis
svy: tab all_cs_trad survey, col ci pear obs

gen all_cs_ppmv = .
replace all_cs_ppmv = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_ppmv = 1 if (set == 1 & d_cs_ppmv == 1) | (set == 2 & f_cs_ppmv == 1) | (set == 3 & fb_cs_ppmv == 1)
*analysis
svy: tab all_cs_ppmv survey, col ci pear obs

gen all_cs_phar = .
replace all_cs_phar = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_phar = 1 if (set == 1 & d_cs_phar == 1) | (set == 2 & f_cs_phar == 1) | (set == 3 & fb_cs_phar == 1)
*analysis
svy: tab all_cs_phar survey, col ci pear obs

gen all_cs_friend = .
replace all_cs_friend = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_friend = 1 if (set == 1 & d_cs_friend == 1) | (set == 2 & f_cs_friend == 1) | (set == 3 & fb_cs_friend == 1)
*analysis 
svy: tab all_cs_friend survey, col ci pear obs

gen all_cs_mark = .
replace all_cs_mark = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_mark = 1 if (set == 1 & d_cs_mark == 1) | (set == 2 & f_cs_mark == 1) | (set == 3 & fb_cs_mark == 1)
*analysis
svy: tab all_cs_mark survey, col ci pear obs

gen all_cs_other = .
replace all_cs_other = 0 if (set == 1 & q703 == 1) | (set == 2 & q803 == 1) | (set == 3 & q903 == 1)
replace all_cs_other = 1 if (set == 1 & d_cs_other == 1) | (set == 2 & f_cs_other == 1) | (set == 3 & fb_cs_other == 1)
*analysis
svy: tab all_cs_other survey, col ci pear obs

*reasons for not complying with CHW referral
gen all_noadhere_a = .
replace all_noadhere_a = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_a = 1 if (set == 1 & q727_a == 1) | (set == 2 & q825_a == 1) | (set == 3 & q922_a == 1)
*analysis
svy: tab all_noadhere_a survey, col ci pear obs

gen all_noadhere_b = .
replace all_noadhere_b = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_b = 1 if (set == 1 & q727_b == 1) | (set == 2 & q825_b == 1) | (set == 3 & q922_b == 1)
*analysis
svy: tab all_noadhere_b survey, col ci pear obs

gen all_noadhere_c = .
replace all_noadhere_c = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_c = 1 if (set == 1 & q727_c == 1) | (set == 2 & q825_c == 1) | (set == 3 & q922_c == 1)
*analysis-removed 'col' b/c single row
svy: tab all_noadhere_c survey, ci pear obs

gen all_noadhere_d = .
replace all_noadhere_d = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_d = 1 if (set == 1 & q727_d == 1) | (set == 2 & q825_d == 1) | (set == 3 & q922_d == 1)
*analysis
svy: tab all_noadhere_d survey, col ci pear obs

gen all_noadhere_e = .
replace all_noadhere_e = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_e = 1 if (set == 1 & q727_e == 1) | (set == 2 & q825_e == 1) | (set == 3 & q922_e == 1)
*analysis 
svy: tab all_noadhere_e survey, col ci pear obs

gen all_noadhere_f = .
replace all_noadhere_f = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_f = 1 if (set == 1 & q727_f == 1) | (set == 2 & q825_f == 1) | (set == 3 & q922_f == 1)
*analysis-removed 'col' b/c single row
svy: tab all_noadhere_f survey, ci pear obs

gen all_noadhere_g = .
replace all_noadhere_g = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_g = 1 if (set == 1 & q727_g == 1) | (set == 2 & q825_g == 1) | (set == 3 & q922_g == 1)
*analysis
svy: tab all_noadhere_g survey, col ci pear obs

gen all_noadhere_h = .
replace all_noadhere_h = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_h = 1 if (set == 1 & q727_h == 1) | (set == 2 & q825_h == 1) | (set == 3 & q922_h == 1)
*analysis
svy: tab all_noadhere_h survey, col ci pear obs

gen all_noadhere_x = .
replace all_noadhere_x = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_x = 1 if (set == 1 & q727_x == 1) | (set == 2 & q825_x == 1) | (set == 3 & q922_x == 1)
*analysis-removed 'col' b/c single row
svy: tab all_noadhere_x survey, ci pear obs

gen all_noadhere_z = .
replace all_noadhere_z = 0 if (set == 1 & d_referadhere == 0) | (set == 2 & f_referadhere == 0) | (set == 3 & fb_referadhere == 0)
replace all_noadhere_z = 1 if (set == 1 & q727_z == 1) | (set == 2 & q825_z == 1) | (set == 3 & q922_z == 1)
*analysis
svy: tab all_noadhere_z survey, col ci pear obs

*reasons for not seeking care, endline only
gen all_nocare_a = .
replace all_nocare_a = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_a = 1 if (set == 1 & q708c_a == 1) | (set == 2 & q827_a == 1) | (set == 3 & q924_a == 1)
*analysis 
svy: tab all_nocare_a survey, col ci pear obs

gen all_nocare_b = .
replace all_nocare_b = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_b = 1 if (set == 1 & q708c_b == 1) | (set == 2 & q827_b == 1) | (set == 3 & q924_b == 1)
*analysis 
svy: tab all_nocare_b survey, col ci pear obs

gen all_nocare_c = .
replace all_nocare_c = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_c = 1 if (set == 1 & q708c_c == 1) | (set == 2 & q827_c == 1) | (set == 3 & q924_c == 1)
*analysis 
svy: tab all_nocare_c survey, col ci pear obs

gen all_nocare_d = .
replace all_nocare_d = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_d = 1 if (set == 1 & q708c_d == 1) | (set == 2 & q827_d == 1) | (set == 3 & q924_d == 1)
*analysis 
svy: tab all_nocare_d survey, col ci pear obs

gen all_nocare_e = .
replace all_nocare_e = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_e = 1 if (set == 1 & q708c_e == 1) | (set == 2 & q827_e == 1) | (set == 3 & q924_e == 1)
*analysis 
svy: tab all_nocare_e survey, col ci pear obs

gen all_nocare_f = .
replace all_nocare_f = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_f = 1 if (set == 1 & q708c_f == 1) | (set == 2 & q827_f == 1) | (set == 3 & q924_f == 1)
*analysis 
svy: tab all_nocare_f survey, col ci pear obs

gen all_nocare_g = .
replace all_nocare_g = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_g = 1 if (set == 1 & q708c_g == 1) | (set == 2 & q827_g == 1) | (set == 3 & q924_g == 1)
*analysis 
svy: tab all_nocare_g survey, col ci pear obs

gen all_nocare_x = .
replace all_nocare_x = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_x = 1 if (set == 1 & q708c_x == 1) | (set == 2 & q827_x == 1) | (set == 3 & q924_x == 1)
*analysis 
svy: tab all_nocare_x survey, col ci pear obs

gen all_nocare_z = .
replace all_nocare_z = 0 if survey == 2 & ((set == 1 & d_nocare == 1) | (set == 2 & f_nocare == 1) | (set == 3 & fb_nocare == 1))
replace all_nocare_z = 1 if (set == 1 & q708c_z == 1) | (set == 2 & q827_z == 1) | (set == 3 & q924_z == 1)
*analysis 
svy: tab all_nocare_z survey, col ci pear obs

*reasons for not seeking care from a CHW among those who sought care, endline only
gen all_nocarechw_a = .
replace all_nocarechw_a = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
replace all_nocarechw_a = 1 if (set == 1 & q708b_a == 1) | (set == 2 & q808b_a == 1) | (set == 3 & q908b_a == 1)
*analysis 
svy: tab all_nocarechw_a survey, col ci pear obs

gen all_nocarechw_b = .
replace all_nocarechw_b = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
replace all_nocarechw_b = 1 if (set == 1 & q708b_b == 1) | (set == 2 & q808b_b == 1) | (set == 3 & q908b_b == 1)
*analysis 
svy: tab all_nocarechw_b survey, col ci pear obs

gen all_nocarechw_c = .
replace all_nocarechw_c = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
replace all_nocarechw_c = 1 if (set == 1 & q708b_c == 1) | (set == 2 & q808b_c == 1) | (set == 3 & q908b_c == 1)
*analysis 
svy: tab all_nocarechw_c survey, col ci pear obs

gen all_nocarechw_d = .
replace all_nocarechw_d = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
replace all_nocarechw_d = 1 if (set == 1 & q708b_d == 1) | (set == 2 & q808b_d == 1) | (set == 3 & q908b_d == 1)
*analysis 
svy: tab all_nocarechw_d survey, col ci pear obs

gen all_nocarechw_e = .
replace all_nocarechw_e = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
replace all_nocarechw_e = 1 if (set == 1 & q708b_e == 1) | (set == 2 & q808b_e == 1) | (set == 3 & q908b_e == 1)
*analysis 
svy: tab all_nocarechw_e survey, col ci pear obs

gen all_nocarechw_f = .
replace all_nocarechw_f = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
replace all_nocarechw_f = 1 if (set == 1 & q708b_f == 1) | (set == 2 & q808b_f == 1) | (set == 3 & q908b_f == 1)
*analysis 
svy: tab all_nocarechw_f survey, col ci pear obs

gen all_nocarechw_x = .
replace all_nocarechw_x = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
replace all_nocarechw_x = 1 if (set == 1 & q708b_x == 1) | (set == 2 & q808b_x == 1) | (set == 3 & q908b_x == 1)
*analysis 
svy: tab all_nocarechw_x survey, col ci pear obs

gen all_nocarechw_z = .
replace all_nocarechw_z = 0 if survey == 2 & ((set == 1 & d_nocarechw == 1) | (set == 2 & f_nocarechw == 1) | (set == 3 & fb_nocarechw == 1))
replace all_nocarechw_z = 1 if (set == 1 & q708b_z == 1) | (set == 2 & q808b_z == 1) | (set == 3 & q908b_z == 1)
*analysis-removed 'col' b/c single row
svy: tab all_nocarechw_z survey, ci pear obs

*Correct treatment, all 3 illnesses (diarrhea = ORS + zinc, confirmed malaria case (+RDT) = ACT w/in 24 hrs, fb = amoxicillin)
***This includes only confirmed cases of malaria in the denominator 
gen all_correct_rxc = 0 if (set==1) | (set==2 & f_result==1) | (set==3)
replace all_correct_rxc = 1 if (set == 1 & d_orszinc == 1) | (set == 2 & f_act24c == 1) | (set == 3 & fb_flab == 1)
*analysis
svy: tab all_correct_rxc survey, col ci pear obs

*Correct treatment from a CHW, all 3 illnesses, among all cases
***This includes only confirmed cases of malaria in the denominator 
gen all_correct_rxchwc = 0 if (set==1) | (set==2 & f_result==1) | (set==3)
replace all_correct_rxchwc = 1 if (set == 1 & d_orszincchw == 1) | (set == 2 & f_act24cchw == 1) | (set == 3 & fb_flabchw == 1)
*analysis
svy: tab all_correct_rxchwc survey, col ci pear obs

*Correct treatment from a CHW, all 3 illnesses, among those that sought care from chw
***This includes This includes only confirmed cases of malaria in the denominator and those that sought care from a CHW
gen all_correct_rxchwc2 = .
replace all_correct_rxchwc2 = 0 if (set == 1 & d_chw == 1) | (set == 2 & f_chw == 1 & f_resultchw==1) | (set == 3 & fb_chw == 1)
replace all_correct_rxchwc2 = 1 if (set == 1 & d_orszincchw2 == 1) | (set == 2 & f_act24cchw2 == 1) | (set == 3 & fb_flabchw2 == 1)
*analysis
svy: tab all_correct_rxchwc2 survey, col ci pear

*Child had booklet for vaccination, all 3 illnesses, among all cases
gen all_booklet = .
replace all_booklet = 0 if (set == 1 & d_booklet !=.) | (set == 2 & f_booklet !=.) | (set == 3 & fb_booklet !=.)
replace all_booklet = 1 if (set == 1 & d_booklet == 1) | (set == 2 & f_booklet == 1) | (set == 3 & fb_booklet == 1)
replace all_booklet = 2 if (set == 1 & d_booklet == 2) | (set == 2 & f_booklet == 2) | (set == 3 & fb_booklet == 2)
lab var all_booklet "child had booklet for vaccination, all 3 illness, among all cases"
lab def all_booklet 0 "no booklet" 1 "yes, seen booklet" 2 "yes, have not seen booklet"
lab val all_booklet all_booklet
tab all_booklet survey, m
*analysis
svy: tab all_booklet survey, col ci pear

*Booklet available for each child included in the survey 
gen all_booklet_child = .
replace all_booklet_child = d_booklet if set == 1
replace all_booklet_child = f_booklet if set == 2
replace all_booklet_child = fb_booklet if set == 3
replace all_booklet_child = . if q7child == q8child & set == 2
replace all_booklet_child = . if q7child == q9child & set == 3
replace all_booklet_child = . if q8child == q9child & set == 3
lab var all_booklet "child had booklet for vaccination, among all sick children"
lab val all_booklet_child all_booklet
tab all_booklet_child survey
*analysis
svy: tab all_booklet_child survey, col ci pear obs

save "Niger State_overall_final_BL_EL.dta", replace

/*
***************Key Indicator Table comparing baseline to endline***************

use "Niger State_final_BL_EL.dta", clear
*1. Caregivers aware of CORP in community 
svy: tab chw_know survey, col ci pear obs

*2. Caregivers know role of CORP in community
svy: tab cgcurknow2 survey, col ci pear obs

*3. Caregivers who know 2+ signs of child illness
svy: tab cgdsknow2 survey, col ci pear obs

*4. Caregivers view CORPs as trusted providers
svy: tab chwtrusted survey, col ci pear obs

*5. Caregivers believe CORPs provide quality services
svy: tab chwquality survey, col ci pear obs

*6. Caregivers found CORP at first visit (overall dataset)
svy: tab chwalwaysavail survey, col ci pear obs

*7. Caregivers believe CORP is convenient source of tx
svy: tab chwconvenient survey, col ci pear obs


use "Niger State_overall_final_BL_EL.dta", clear

*8. Appropriate provider was sought (overall, fever, diarrhea, and cough w/f or db)
svy: tab all_app_prov survey, col ci pear obs
svy: tab f_app_prov survey if set == 1, col ci pear obs
svy: tab d_app_prov survey if set == 2, col ci pear obs
svy: tab fb_app_prov survey if set == 3, col ci pear obs

*9. Child taken to CORP as first source of care (overall, fever, diarrhea, and cough w/f or db)
svy: tab all_chwfirst survey, col ci pear obs
svy: tab f_chwfirst survey if set == 1, col ci pear obs
svy: tab d_chwfirst survey if set == 2, col ci pear obs
svy: tab fb_chwfirst survey if set == 3, col ci pear obs

*10. Child had finger or heel stick 
svy: tab f_bloodtaken survey if set == 2, col ci pear obs

*11. Caregiver received results of RDT
svy: tab f_gotresult survey if set == 2, col ci pear obs

*12. Respiratory rate assessed
svy: tab fb_assessed survey if set == 3, col ci pear obs

*13. Child had finger or heel stick by CORP
svy: tab f_bloodtakenchw survey if set == 2, col ci pear obs

*14. Caregiver received results of RDT from CORP
svy: tab f_gotresultchw survey if set == 2, col ci pear obs

*15. Respiratory rate assessed by CORP
svy: tab fb_assessedchw survey if set == 3, col ci pear obs

*16. Child received appropriate tx - all cases (overall, ACT w/in 24 w/RDT+, ORS + zinc, and amoxicillin)
svy: tab all_correct_rx survey, col ci pear obs
svy: tab d_orszinc survey if set == 1, col ci pear obs
svy: tab f_act24c survey if set == 2, col ci pear obs
svy: tab fb_flab survey if set == 3, col ci pear obs

*17. Child received appropriate tx from a CORP (overall, ACT w/in 24 w/RDT+, ORS + zinc, and amoxicillin)
svy: tab all_correct_rxchw survey, col ci pear obs
svy: tab d_orszincchw survey if set == 1, col ci pear obs
svy: tab f_act24cchw survey if set==2, ci pear obs
svy: tab fb_flabchw survey if set == 3, col ci pear obs

*18. Child received first dose of tx in presence of CORP (overall, ACT, ORS + zinc, and amoxicillin)
svy: tab all_firstdose survey, col ci pear obs
svy: tab d_bothfirstdose survey if set == 1, col ci pear obs
*removed 'col' for next variable b/c single row
svy: tab f_act_chwp survey if set == 2, ci pear obs
svy: tab fb_flab_chwp survey if set == 3, col ci pear obs

*19. Caregiver received counseling on how to administer drug (overall, ACT w/in 24 w/RDT+, ORS + zinc, and amoxicillin)
svy: tab all_counsel survey, col ci pear obs
svy: tab d_bothcounsel survey if set == 1, col ci pear obs
*removed 'col' for next variable b/c single row
svy: tab f_act_chwc survey if set == 2, col ci pear obs
svy: tab fb_flab_chwc survey if set == 3, col ci pear obs
 
*20. Caregiver adhered to referral (all illnesses - use overall dataset)
svy: tab all_referadhere survey, col ci pear obs

*21. Child received follow-up visit from CORP (all illnesses - use overall dataset) 
svy: tab all_followup survey, col ci pear obs
*/
