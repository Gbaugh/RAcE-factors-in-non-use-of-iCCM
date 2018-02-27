***********************************
** Niger Endline Survey Analysis **
** Data prep do file             **
** Kirsten Zalisk                **
** February 14, 2017             **
***********************************

cd "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Niger\Endline Data for Analysis\Endline data 2.25.2017"
set more off

use child_roster, clear
count
*540 records
foreach x of varlist q101- q108a {
  destring `x', replace
}

duplicates list codevil nummen
*two HHs have 2 children with a line number == 1, change 1 of the 2 entries to be 2 for each HH
*For the first one, changed the 1 with missing illness history fields
*For the second one, changed the 2nd entry since both children had fever and only fever
replace q101 = 2 if codevil == 8 & nummen == 14 & q105 == .
replace q101 = 2 if codevil == 10 & nummen == 6 & q104 == 48
*two HHs have children that do not match the master merged file.
*For the first one, the wrong line number is in the child roster
*For the second one, there is no entry in module 1 or in the child roster, so age/sex info will be missing
replace q101 = 1 if codevil == 8 & nummen == 13 & q101 == 2
save child_roster_kz, replace

use intro, clear 
count
*491 records
keep codevil nummen Coddep date_V1 result1 date_v2 result2 resultf nbr_totv
replace nbr_totv = 2 if nbr_totv == 1 & date_v2 != " "
gen modintro = 1
rename Coddep coddep
destring coddep, replace
rename date_V1 date_v1
save intro_kz, replace

use module0, clear
count
*511 records
keep codevil cod_loc nummen consent q001 q002 q003 q004
tab1 consent-q004
*510/511 gave consent
gen mod0 = 1
save module0_kz, replace

use module1, clear
count
*511 records
keep codevil nummen coddep q109_1 q110_1 q111_1
*Dropped caregiver number fields because all were set = 1
gen mod1 = 1
destring coddep, replace
save module1_kz, replace

use module2, clear
count
*501 records
tab1 q203-q205
*One record = no school, but grade and level provided. Changing no school to yes school.
replace q203 = 1 if q203 == 2 & q204 == "1"
*5 records with grade = ? but no school. Changing to missing.
replace q204 = " " if q204 == "?"
replace q204 = "" if q204 == " "
tab1 q206-q207a
*3 caregivers not selected for asset questions, but only 1 caregiver per HH
*Only 497 caregivers responded to asset questions.
rename Coddep coddep
preserve
keep codevil coddep nummen q206-q230
save assets_kz, replace
restore
keep codevil coddep nummen q202- q205
foreach x of varlist q202-q205 {
  destring `x', replace
}
gen mod2 = 1
destring coddep, replace
save module2_kz, replace

use module3, clear
count
*463 records
keep codevil coddep nummen q305 mom_cont q301 q302 q303 q304
gen mod3 = 1 
destring coddep, replace
save module3_kz, replace

use module4, clear
count
*480 records
tab1 q401-q424
keep codevil nummen coddep q401-q424
gen mod4 = 1
foreach x of varlist coddep q401-q424 {
  destring `x', replace
}
rename q406 q406s
gen q406 = 1 if q406s == "yes"
replace q406 = 2 if q406s == "no"
lab def yn_orig 1 "Yes" 2 "No"
lab val q406 yn_orig
lab var q406 "Votre conjoint est t-il alle a l'ecole?"

rename q410 q410s
gen q410 = 1 if q410s == "yes"
replace q410 = 2 if q410s == "no"
lab val q410 yn_orig
lab var q410 "En dehors des travaux domestiques,avez-vous fait un autre travail au cours des"

tostring q414, replace
save module4_kz, replace

use module5, clear
count
*481 records
tab1 q501-q516
keep codevil coddep nummen q501 q502 q503-q505Z q507-q516
gen mod5 = 1
foreach x of varlist coddep q501-q516 {
  destring `x', replace
}
save module5_kz, replace

use module6, clear
count
*501 records
tab1 q601-q605_autre
keep codevil nummen coddep q601-q605_autre
gen mod6 = 1
foreach x of varlist q601-q605 {
  destring `x', replace
}
tostring q605, replace
save module6_kz, replace

use module7, clear
count
*297 records
keep codevil nummen numenf q705 q705_autre q701-q732 q733-q743
gen mod7 = 1
rename numenf d_child_no
*There is 1 record in the dataset that does not have any data in it other than a child number
drop if q701 ==.

rename q705 q705s
gen q705 = 1 if q705s == "A"
replace q705 = 2 if q705s == "B"
replace q705 = 3 if q705s == "C"
replace q705 = 96 if q705s == "X"
drop q705s

foreach x of varlist q701- q743 {
  destring `x', replace 
}
save module7_kz, replace

use module8, clear
count
*308 records
rename numligne_enfant numenfant
*replace numenf = 1 if codevil == 20 & nummen == 15 & numenf == 2
keep codevil nummen numenf q801-q841
gen mod8 = 1
rename numenf f_child_no
rename q805 q805s
gen q805 = 1 if q805s == "A"
replace q805 = 2 if q805s == "B"
replace q805 = 3 if q805s == "C"
replace q805 = 96 if q805s == "X"
drop q805s

foreach x of varlist q801- q841 {
  destring `x', replace 
}
tostring q806_autre, replace
save module8_kz, replace

use module9, clear
count
*308 records
keep codevil nummen numenf coddep q901-q927 q928-q938
gen mod9 =1 
destring coddep, replace
rename numenf fb_child_no
rename q905 q905s
gen q905 = 1 if q905s == "A"
replace q905 = 2 if q905s == "B"
replace q905 = 3 if q905s == "C"
replace q905 = 96 if q905s == "X"
drop q905s

foreach x of varlist q901- q938 {
  destring `x', replace 
}

tostring q906_autre, replace
tostring q914_autre, replace

save module9_kz, replace

*Create a master caregiver EL file
use intro_kz, clear
merge 1:1 codevil nummen using module0_kz
*480 matched, 11 in master only, 31 in using only
drop _merge
merge 1:1 codevil nummen using module2_kz
*498 matched, 24 in master only, 3 in using only
drop _merge
merge 1:1 codevil nummen using module4_kz
*480 matched, 45 in master only
drop _merge
merge 1:1 codevil nummen using module5_kz
*479 matched, 46 in master only, 2 in using only
drop _merge
merge 1:1 codevil nummen using module6_kz
*501 matched, 26 in master only, 0 in using only
drop _merge
foreach x of varlist mod* {
  replace `x' = 0 if `x' ==.
}
gen mod_tot = modintro + mod0 + mod2 + mod4 + mod5 + mod6 
tab mod_tot
gen survey = 2
save caregiver_endline, replace

*Create a master sick child EL file - merged
use intro_kz, clear
merge 1:1 codevil nummen using module0_kz
*480 matched, 11 in master only, 31 in using only
drop _merge
merge 1:1 codevil nummen using module1_kz
*507 matched, 15 in master only, 4 in using only
drop _merge
merge 1:1 codevil nummen using module7_kz
*296 matched, 230 in master only
drop _merge
merge 1:1 codevil nummen using module8_kz
*308 matched, 218 in master only
drop _merge
merge 1:1 codevil nummen using module9_kz
*308 matched, 218 in master only
drop _merge
save illness_enline_merged,replace

*Create a master caregiver + sick child dataset
use caregiver_endline, clear
merge 1:1 codevil nummen using module1_kz
*509 matched, 18 in master only, 2 in using only
drop _merge
merge 1:1 codevil nummen using module7_kz
*296 matched, 233 in master only
drop _merge
merge 1:1 codevil nummen using module8_kz
*308 matched, 221 in master only
drop _merge
merge 1:1 codevil nummen using module9_kz
*308 matched, 221 in master only
drop _merge
drop mod_tot
foreach x of varlist mod* {
  replace `x' = 0 if `x' ==.
}
*Determine the total number of modules per HH
gen mod_tot = modintro + mod0 + mod1 + mod2 + mod4 + mod5 + mod6 + mod7 + mod8 + mod9
tab mod_tot
*Determine the total number of sick child modules per HH
gen mod_sick = mod7 + mod8 + mod9
tab mod_sick
***26 records have no sick children
drop if mod_sick == 0
tab mod_tot
***9 records have fewer than 6 completed modules
drop if mod_tot < 6
save all_valid_endline, replace

keep codevil-mod1 mod7 mod8 mod9 mod_tot mod_sick q724 q822 q919 q706H q806H q906H
save caregiver_endline, replace

use all_valid_endline, clear
keep codevil nummen coddep mod0 mod1 mod2 mod4 mod5 mod6 q109_1-mod_sick q401 q404
save all_valid_sick, replace

use all_valid_sick, clear
keep codevil nummen coddep mod* d_child_no- mod7 q705 q401 q404
drop if mod7 != 1
gen d_case = 1
save diarrhea_el, replace

use all_valid_sick, clear
keep codevil nummen coddep mod* f_child_no- mod8 q805 q401 q404
drop if mod8 != 1
gen f_case = 1
save fever_el, replace

use all_valid_sick, clear
keep codevil nummen coddep mod* fb_child_no- mod9 q905 q401 q404
drop if mod9 != 1
gen fb_case = 1
save fastb_el, replace

*Create illness master file
use diarrhea_el, clear
append using fever_el
append using fastb_el
save illness_endline, replace

gen child_number = d_child_no if d_child_no !=.
replace child_number = f_child_no if f_child_no !=.
replace child_number = fb_child_no if fb_child_no !=.
rename child_number q101
merge m:1 codevil nummen q101 using "child_roster_kz"
*903 matched, 1 in master only, 42 in using only
list codevil nummen q101 q105 q106 q107 q108 _merge if _merge != 3
drop if _merge == 2
drop q102 _merge 
gen survey = 2
save illness_endline, replace

use illness_endline, clear
append using "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Niger\Niger Baseline data\From Patsy\illness_baseline"
cd "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Niger\Combined"
save illness_combined, replace

use "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Niger\Endline Data for Analysis\Endline data 2.25.2017\caregiver_endline.dta", clear
append using "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Niger\Niger Baseline data\From Patsy\caregiver_baseline"
cd "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Niger\Combined"
save caregiver_combined, replace

*use "module3 KZ", clear
