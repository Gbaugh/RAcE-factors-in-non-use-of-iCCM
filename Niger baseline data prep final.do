
cd "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Niger\Niger Baseline data\From Patsy"

set more off

* Check Parent_Information File
*-contains hh_number field
use "Parent_Info", clear
count
*645 records
***Set up a field to use as a key to link all of the modules together
***Parent record ID in all of the other modules corresponds to the ID field in this first module
rename PARENT_RECORD_ID PARENT_RECORD_IDorig
rename ID PARENT_RECORD_ID
destring PARENT_RECORD_ID, replace
gen modintro = 1
save "Parent_Info KZ", replace

*Check Consent File
*-no household_number or hh_number field
use "Consent", clear
*631 records
duplicates list PARENT_RECORD_ID
duplicates report PARENT_RECORD_ID
*32 duplicates found
tab survey_consent
*2 HHs did not provide consent
sort PARENT_RECORD_ID survey_date
by PARENT_RECORD_ID : gen n = _n
tab n
duplicates tag PARENT_RECORD_ID, gen(dup)
list PARENT_RECORD_ID survey_date children_under_5_001 caregiver_002 caregiver_all_003 caregiver_how_many_004 survey_consent n if dup == 1
tab survey_consent, m
***drop duplicate records - should only be one per Parent ID since no HH number in this file
***most duplicate records are identical, a few differ, will systematically keep one with later date/time
drop if n == 1 & dup == 1
drop n
gen mod0 = 1
save "Consent KZ", replace

*Check Caregiver Background file
*-contains household_number field only
use "CG_Background", clear
duplicates report PARENT_RECORD_ID
*21 duplicates
duplicates report PARENT_RECORD_ID household_number
*1 duplicate
duplicates list PARENT_RECORD_ID household_number
*One duplicate: Parent ID 613, HH 20
replace household_number = 19 if PARENT_RECORD_ID == 613 & CREATED_DATE == "2013-09-11 09:07:21"
*Changed HH number for record that was created around 9am on 9/11
duplicates list PARENT_RECORD_ID 
duplicates tag PARENT_RECORD_ID, gen(dup)
replace household_number = 41 if PARENT_RECORD_ID == 760 & household_number == .
replace household_number = 6 if PARENT_RECORD_ID == 1516 & household_number == .
replace household_number = 8 if PARENT_RECORD_ID == 1828 & household_number == .
gen mod2 = 1
save "Module2 KZ", replace

*Check and clean Caregiver Decision-making file
*contains household_number field
use "CG_decisionmaking", clear
duplicates report PARENT_RECORD_ID
duplicates report PARENT_RECORD_ID household_number
duplicates list PARENT_RECORD_ID household_number
*One duplicate: Parent ID 919, HH 13 - exact duplicate, delete one
bysort PARENT_RECORD_ID household_number: gen n = _n
tab n
drop if n==2
tostring caregiver_number, replace
drop if PARENT_RECORD_ID == 73 & household_number == .
replace household_number = 18 if PARENT_RECORD_ID == 91 & household_number == .
replace household_number = 7 if PARENT_RECORD_ID == 607 & household_number == .
replace household_number = 12 if PARENT_RECORD_ID == 703 & household_number == .
replace household_number = 41 if PARENT_RECORD_ID == 760 & household_number == .
replace household_number = 22 if PARENT_RECORD_ID == 394 & household_number == .
replace household_number = 45 if PARENT_RECORD_ID == 820 & household_number == .
replace household_number = 5 if PARENT_RECORD_ID == 1054 & household_number == 8
replace household_number = 1 if PARENT_RECORD_ID == 1468 & household_number == 17
replace household_number = 1 if PARENT_RECORD_ID == 1228 & household_number == 15
replace household_number = 3 if PARENT_RECORD_ID == 1165 & household_number == 8
replace household_number = 10 if PARENT_RECORD_ID == 1096 & household_number == 17
gen mod4 = 1
save "Module4 KZ", replace

*Check and clean Caregiver Knowledge file
*-contains household number field
use "CG_knowledge", clear
duplicates report PARENT_RECORD_ID household_number 
*No duplicates
tostring child_number, replace
tostring caregiver_number, replace
drop if PARENT_RECORD_ID == 73 & household_number == .
replace household_number = 11 if PARENT_RECORD_ID == 145 & household_number == .
replace household_number = 16 if PARENT_RECORD_ID == 292 & household_number == 13
replace household_number = 23 if PARENT_RECORD_ID == 397 & household_number == .
replace household_number = 19 if PARENT_RECORD_ID == 613 & household_number == 21
replace household_number = 5 if PARENT_RECORD_ID == 1054 & household_number == 8
replace household_number = 1 if PARENT_RECORD_ID == 1468 & household_number == 17
replace household_number = 1 if PARENT_RECORD_ID == 1228 & household_number == 15
replace household_number = 3 if PARENT_RECORD_ID == 1165 & household_number == 8
replace household_number = 10 if PARENT_RECORD_ID == 1096 & household_number == 17
replace household_number = 45 if PARENT_RECORD_ID == 820 & household_number == .
replace household_number = 18 if PARENT_RECORD_ID == 1399 & household_number == .
replace household_number = 16 if PARENT_RECORD_ID == 1417 & household_number == .
replace household_number = 41 if PARENT_RECORD_ID == 760 & household_number == .
gen mod6 = 1
save "Module6 KZ", replace

*Check and clean CHW knowledge file
*-contains household number field
use "CHW", clear
tostring child_number, replace
tostring caregiver_number, replace
drop if PARENT_RECORD_ID == 73 & household_number == .
duplicates report PARENT_RECORD_ID household_number caregiver_number
duplicates list PARENT_RECORD_ID household_number caregiver_number
drop if MODIFIED_DATE=="2013-09-13 08:16:20"
bysort PARENT_RECORD_ID household_number: gen n = _n
tab n
drop if n==2
drop n
replace household_number = 18 if PARENT_RECORD_ID == 1399  & household_number == .
*replace household_number =  if PARENT_RECORD_ID == 991  & household_number == .
replace household_number = 45  if PARENT_RECORD_ID == 820  & household_number == .
replace household_number = 12 if PARENT_RECORD_ID == 703  & household_number == .
replace household_number = 6 if PARENT_RECORD_ID == 268 & household_number == 1
replace household_number = 27 if PARENT_RECORD_ID == 655 & household_number == 1
replace household_number = 5 if PARENT_RECORD_ID == 1054 & household_number == 8
replace household_number = 10 if PARENT_RECORD_ID == 1096 & household_number == 17
replace household_number = 3 if PARENT_RECORD_ID == 1120 & household_number == 1
replace household_number = 3 if PARENT_RECORD_ID == 1165 & household_number == 8
replace household_number = 1 if PARENT_RECORD_ID == 1228 & household_number == 15
replace household_number = 1 if PARENT_RECORD_ID == 1468 & household_number == 17
replace household_number = 3 if PARENT_RECORD_ID == 1549 & household_number == 1
gen mod5 = 1
save "Module5 KZ", replace

*Check and clean Selected Children file
*-contains household_number field
use "Selected_Children", clear	
duplicates report PARENT_RECORD_ID household_number
duplicates list PARENT_RECORD_ID household_number
replace household_number = 19 if PARENT_RECORD_ID == 613 & CREATED_DATE == "2013-09-11 08:58:00"
bysort PARENT_RECORD_ID household_number: gen n = _n 
tab n
drop if n == 2
drop n
replace household_number = 2 if PARENT_RECORD_ID == 379 & household_number == 1
replace household_number = 16 if PARENT_RECORD_ID == 379 & household_number == .
replace household_number = 21 if PARENT_RECORD_ID == 10 & household_number == .
replace household_number = 5 if PARENT_RECORD_ID == 73 & household_number == .
replace household_number = 18 if PARENT_RECORD_ID == 115 & household_number == 181
replace household_number = 2 if PARENT_RECORD_ID == 142 & household_number == .
replace household_number = 2 if PARENT_RECORD_ID == 244 & household_number == .
replace household_number = 14 if PARENT_RECORD_ID == 271 & household_number == 1
replace household_number = 10 if PARENT_RECORD_ID == 352 & household_number == .
replace household_number = 21 if PARENT_RECORD_ID == 370 & household_number == .
replace household_number = 18 if PARENT_RECORD_ID == 391 & household_number == .
replace household_number = 23 if PARENT_RECORD_ID == 397 & household_number == .
replace household_number = 24 if PARENT_RECORD_ID == 445 & household_number == .
replace household_number = 9 if PARENT_RECORD_ID == 550 & household_number == .
replace household_number = 19 if PARENT_RECORD_ID == 574 & household_number == .
replace household_number = 27 if PARENT_RECORD_ID == 598 & household_number == .
replace household_number = 16 if PARENT_RECORD_ID == 631 & household_number == .
replace household_number = 27 if PARENT_RECORD_ID == 655 & household_number == .
replace household_number = 35 if PARENT_RECORD_ID == 688 & household_number == .
replace household_number = . if PARENT_RECORD_ID == 694 & household_number == 1
replace household_number = 14 if PARENT_RECORD_ID == 727 & household_number == 13
replace household_number = 27 if PARENT_RECORD_ID == 754 & household_number == .
replace household_number = 41 if PARENT_RECORD_ID == 760 & household_number == .
replace household_number = 3 if PARENT_RECORD_ID == 787 & household_number == .
replace household_number = 24 if PARENT_RECORD_ID == 907 & household_number == .
replace household_number = 37 if PARENT_RECORD_ID == 910 & household_number == .
replace household_number = 38 if PARENT_RECORD_ID == 913 & household_number == .
replace household_number = 4 if PARENT_RECORD_ID == 916 & household_number == .
replace household_number = 17 if PARENT_RECORD_ID == 994 & household_number == .
replace household_number = 5 if PARENT_RECORD_ID == 1048 & household_number == .
replace household_number = 5 if PARENT_RECORD_ID == 1054 & household_number == 8
replace household_number = 19 if PARENT_RECORD_ID == 1060 & household_number == .
replace household_number = 8 if PARENT_RECORD_ID == 1066 & household_number == .
replace household_number = 10 if PARENT_RECORD_ID == 1096 & household_number == 17
replace household_number = 16 if PARENT_RECORD_ID == 1108 & household_number == .
replace household_number = 20 if PARENT_RECORD_ID == 1114 & household_number == .
replace household_number = 3 if PARENT_RECORD_ID == 1117 & household_number == .
replace household_number = 16 if PARENT_RECORD_ID == 1153 & household_number == .
replace household_number = 3 if PARENT_RECORD_ID == 1165 & household_number == 8
replace household_number = 1 if PARENT_RECORD_ID == 1228 & household_number == 15
replace household_number = 16 if PARENT_RECORD_ID == 1258 & household_number == .
replace household_number = 4 if PARENT_RECORD_ID == 1270 & household_number == .
replace household_number = 18 if PARENT_RECORD_ID == 1282 & household_number == .
replace household_number = 16 if PARENT_RECORD_ID == 1306 & household_number == 13
replace household_number = 4 if PARENT_RECORD_ID == 1309 & household_number == 3
replace household_number = 18 if PARENT_RECORD_ID == 1399 & household_number == .
replace household_number = 1 if PARENT_RECORD_ID == 1414 & household_number == .
replace household_number = 16 if PARENT_RECORD_ID == 1417 & household_number == .
replace household_number = 5 if PARENT_RECORD_ID == 1450 & household_number == 1
replace household_number = 1 if PARENT_RECORD_ID == 1468 & household_number == 17
replace household_number = 18 if PARENT_RECORD_ID == 1585 & household_number == 0
replace household_number = 11 if PARENT_RECORD_ID == 1618 & household_number == .
replace household_number = 19 if PARENT_RECORD_ID == 1669 & household_number == 18
replace household_number = 7 if PARENT_RECORD_ID == 1690 & household_number == 1
replace household_number = 18 if PARENT_RECORD_ID == 1696 & household_number == .
replace household_number = 14 if PARENT_RECORD_ID == 1711 & household_number == 0
replace household_number = 20 if PARENT_RECORD_ID == 1783 & household_number == 22
replace household_number = 21 if PARENT_RECORD_ID == 1888 & household_number == 0

replace child_name_fever_109 = "" if PARENT_RECORD_ID == 613 & household_number == 19
replace fever_caregiver_109a = "" if PARENT_RECORD_ID == 613 & household_number == 19
replace caregiver_number_fever = . if PARENT_RECORD_ID == 613 & household_number == 19
gen mod1 = 1
save "Module1 KZ", replace

*Check and clean Diarrhea file
*-contains household_number field
use "Diarrhea", clear
duplicates report PARENT_RECORD_ID household_number
duplicates list PARENT_RECORD_ID household_number
*One duplicate Parent ID 103, HH 5
drop if PARENT_RECORD_ID == 103 & CREATED_DATE == "2013-09-11 09:17:00"
replace household_number = 18 if PARENT_RECORD_ID == 91 & household_number == 10
*replace household_number = 25 if PARENT_RECORD_ID == 100 & household_number == 4
*replace household_number = 19 if PARENT_RECORD_ID == 106 & household_number == 11
replace household_number = 18 if PARENT_RECORD_ID == 115 & household_number == 20
*replace household_number = 15 if PARENT_RECORD_ID == 121 & household_number == 22
replace household_number = 17 if PARENT_RECORD_ID == 130 & household_number == 16
*replace household_number = 22 if PARENT_RECORD_ID == 133 & household_number == 7
*replace household_number = 31 if PARENT_RECORD_ID == 139 & household_number == 17
replace household_number = 2 if PARENT_RECORD_ID == 142 & household_number == 16
replace household_number = 7 if PARENT_RECORD_ID == 154 & household_number == 6
*replace household_number = 11 if PARENT_RECORD_ID == 157 & household_number == 8
*replace household_number = 15 if PARENT_RECORD_ID == 163 & household_number == 10
*replace household_number = 2 if PARENT_RECORD_ID == 166 & household_number == 14
replace household_number = 23 if PARENT_RECORD_ID == 169 & household_number == 25
replace household_number = 25 if PARENT_RECORD_ID == 175 & household_number == 19
replace household_number = 20 if PARENT_RECORD_ID == 178 & household_number == 12
replace household_number = 27 if PARENT_RECORD_ID == 181 & household_number == 1
*replace household_number = 8 if PARENT_RECORD_ID == 187 & household_number == 9
replace household_number = 26 if PARENT_RECORD_ID == 190 & household_number == 15
*replace household_number = 9 if PARENT_RECORD_ID == 196 & household_number == 8
replace household_number = 28 if PARENT_RECORD_ID == 202 & household_number == 22
replace household_number = 16 if PARENT_RECORD_ID == 205 & household_number == 3
replace household_number = 10 if PARENT_RECORD_ID == 208 & household_number == 31
*replace household_number = 12 if PARENT_RECORD_ID == 214 & household_number == 11
replace household_number = 24 if PARENT_RECORD_ID == 220 & household_number == 4
replace household_number = 32 if PARENT_RECORD_ID == 226 & household_number == 11
*replace household_number = 3 if PARENT_RECORD_ID == 232 & household_number == 15
replace household_number = 1 if PARENT_RECORD_ID == 235 & household_number == 2
replace household_number = 4 if PARENT_RECORD_ID == 247 & household_number == 6
replace household_number = 28 if PARENT_RECORD_ID == 253 & household_number == 29
replace household_number = 5 if PARENT_RECORD_ID == 256 & household_number == 8
*replace household_number = 5 if PARENT_RECORD_ID == 265 & household_number == 9
*replace household_number = 6 if PARENT_RECORD_ID == 268 & household_number == 3
*replace household_number = 11 if PARENT_RECORD_ID == 280 & household_number == 6
*replace household_number = 7 if PARENT_RECORD_ID == 283 & household_number == 12
replace household_number = 17 if PARENT_RECORD_ID == 298 & household_number == 33
*replace household_number = 12 if PARENT_RECORD_ID == 301 & household_number == 3
replace household_number = 22 if PARENT_RECORD_ID == 307 & household_number == 10
replace household_number = 15 if PARENT_RECORD_ID == 310 & household_number == 8
*replace household_number = 1 if PARENT_RECORD_ID == 316 & household_number == 6
replace household_number = 19 if PARENT_RECORD_ID == 613 & household_number == 20
replace household_number = . if PARENT_RECORD_ID == 694 & household_number == 1
replace household_number = 5 if PARENT_RECORD_ID == 1054 & household_number == 8
replace household_number = 3 if PARENT_RECORD_ID == 1165 & household_number == 8
replace household_number = 1 if PARENT_RECORD_ID == 1228 & household_number == 15
gen mod7 = 1
save "Module7 KZ", replace

*Check and clean Fever file
*-contains household_number field
use "Fever", clear
duplicates report PARENT_RECORD_ID household_number
*No duplicates
replace household_number = 1 if PARENT_RECORD_ID == 67 & household_number == .
replace household_number = 33 if PARENT_RECORD_ID == 859 & household_number == .
replace household_number = 3 if PARENT_RECORD_ID == 1015 & household_number == 0
replace household_number = 5 if PARENT_RECORD_ID == 1054 & household_number == 8
replace household_number = 3 if PARENT_RECORD_ID == 1165 & household_number == 8
replace household_number = 16 if PARENT_RECORD_ID == 1168 & household_number == 14
replace household_number = 1 if PARENT_RECORD_ID == 1228 & household_number == 15
replace household_number = 1 if PARENT_RECORD_ID == 1468 & household_number == 17
replace household_number = 15 if PARENT_RECORD_ID == 1492 & household_number == 0
replace household_number = 21 if PARENT_RECORD_ID == 1591 & household_number == .
gen mod8 = 1
save "Module8 KZ", replace

*Check and clean Fast Breathing file
*-contains household_number field
use "FastBreathing", clear
duplicates report PARENT_RECORD_ID household_number
*No duplicates
replace household_number = 21 if PARENT_RECORD_ID == 277 & household_number == 12
replace household_number = 4 if PARENT_RECORD_ID == 364 & household_number == 0
replace household_number = 10 if PARENT_RECORD_ID == 1096 & household_number == 17
replace household_number = 3 if PARENT_RECORD_ID == 1165 & household_number == 8
replace household_number = 1 if PARENT_RECORD_ID == 1468 & household_number == 17
replace household_number = 10 if PARENT_RECORD_ID == 1522 & household_number == 0
replace household_number = 21 if PARENT_RECORD_ID == 1591 & household_number == .
replace household_number = 6 if PARENT_RECORD_ID == 1627 & household_number == 0
gen mod9 = 1
save "Module9 KZ", replace

use "Child_Identifier", clear
duplicates report PARENT_RECORD_ID household_number child_number
duplicates list PARENT_RECORD_ID household_number child_number

replace child_number = 2 if PARENT_RECORD_ID == 241 & child_name_1_102 == "Djafarou daouda"
replace child_number = 2 if PARENT_RECORD_ID == 220 & child_name_1_102 == "Anifa"
replace child_number = 2 if PARENT_RECORD_ID == 304 & child_name_1_102 == "Nafissa"
replace child_number = 2 if PARENT_RECORD_ID == 424 & child_name_1_102 == "Issouffou"
replace household_number = 19 if PARENT_RECORD_ID == 613 & child_name_1_102 == "Moussa"
replace household_number = 19 if PARENT_RECORD_ID == 613 & child_name_1_102 == "Issaka"
replace child_number = 2 if PARENT_RECORD_ID == 1291 & child_name_1_102 == "Nazirou"
replace child_number = 1 if PARENT_RECORD_ID == 1318 & child_name_1_102 == "Nasirou"
replace child_number = 2 if PARENT_RECORD_ID == 1318 & child_name_1_102 == "Nazifou"
replace child_number = 2 if PARENT_RECORD_ID == 1537 & child_name_1_102 == "Zeinabou "
replace child_number = 3 if PARENT_RECORD_ID == 1606 & child_name_1_102 == "Mansoura"
drop if CREATED_DATE == "2013-09-15 08:21:39" & PARENT_RECORD_ID == 1201
tostring child_number, replace
rename child_name_1_102 q102
rename child_gender_1_103 q103
rename age_1_104 q104
rename fever_two_weeks_1_105 q105
rename child_diarrhea_1_106 q106
rename child_cough_1_107 q107
rename child_cough_1_108 q108
rename more_child_1_108A q108a
rename household_number nummen

foreach x of varlist q102- child_number {
  destring `x', replace
}
save "Module1a KZ", replace

use "CG_Assets", clear
duplicates report PARENT_RECORD_ID household_number
duplicates list PARENT_RECORD_ID household_number
* Three duplicates
replace household_number = 19 if household_number == 20 & PARENT_RECORD_ID == 613 & CREATED_DATE == "2013-09-11 09:05:49"
drop if household_number == 5 & PARENT_RECORD_ID == 103 & CREATED_DATE == "2013-09-11 08:13:43"
drop if household_number == 5 & PARENT_RECORD_ID == 172 & CREATED_DATE == "2013-09-12 08:14:06"
*replace household_number = 5 if PARENT_RECORD_ID == 73 & household_number == 0
replace household_number = 18 if PARENT_RECORD_ID == 91 & household_number == 10
*replace household_number = 14 if PARENT_RECORD_ID == 97 & household_number == 24
*replace household_number = 1 if PARENT_RECORD_ID == 112 & household_number == 17
*replace household_number = 18 if PARENT_RECORD_ID == 115 & household_number == 20
*replace household_number = 9 if PARENT_RECORD_ID == 118 & household_number == 4
replace household_number = 1 if PARENT_RECORD_ID == 124 & household_number == 9
*replace household_number = 8 if PARENT_RECORD_ID == 127 & household_number == 3
replace household_number = 17 if PARENT_RECORD_ID == 130 & household_number == 16
*replace household_number = 3 if PARENT_RECORD_ID == 136 & household_number == 6
replace household_number = 31 if PARENT_RECORD_ID == 148 & household_number == 24
*replace household_number = 7 if PARENT_RECORD_ID == 154 & household_number == 6
*replace household_number = 11 if PARENT_RECORD_ID == 160 & household_number == 0
replace household_number = 23 if PARENT_RECORD_ID == 169 & household_number == 25
replace household_number = 25 if PARENT_RECORD_ID == 175 & household_number == 19
*replace household_number = 20 if PARENT_RECORD_ID == 178 & household_number == 12
replace household_number = 27 if PARENT_RECORD_ID == 181 & household_number == 1
replace household_number = 29 if PARENT_RECORD_ID == 184 & household_number == 1
*replace household_number = 26 if PARENT_RECORD_ID == 190 & household_number == 15
*replace household_number = 28 if PARENT_RECORD_ID == 202 & household_number == 22
replace household_number = 16 if PARENT_RECORD_ID == 205 & household_number == 3
*replace household_number = 10 if PARENT_RECORD_ID == 208 & household_number == 31
*replace household_number = 6 if PARENT_RECORD_ID == 211 & household_number == 2
replace household_number = 24 if PARENT_RECORD_ID == 220 & household_number == 4
replace household_number = 30 if PARENT_RECORD_ID == 223 & household_number == 7
*replace household_number = 32 if PARENT_RECORD_ID == 226 & household_number == 11
*replace household_number = 33 if PARENT_RECORD_ID == 229 & household_number == 11
replace household_number = 1 if PARENT_RECORD_ID == 235 & household_number == 2
*replace household_number = 8 if PARENT_RECORD_ID == 241 & household_number == 5
replace household_number = 2 if PARENT_RECORD_ID == 244 & household_number == .
*replace household_number = 4 if PARENT_RECORD_ID == 247 & household_number == 20
replace household_number = 28 if PARENT_RECORD_ID == 253 & household_number == 1
replace household_number = 5 if PARENT_RECORD_ID == 256 & household_number == 8
replace household_number = 5 if PARENT_RECORD_ID == 259 & household_number == 26
replace household_number = 6 if PARENT_RECORD_ID == 268 & household_number == 1
*replace household_number = 14 if PARENT_RECORD_ID == 271 & household_number == 28
*replace household_number = 21 if PARENT_RECORD_ID == 277 & household_number == 10
replace household_number = 18 if PARENT_RECORD_ID == 295 & household_number == 32
replace household_number = 17 if PARENT_RECORD_ID == 298 & household_number == 33
*replace household_number = 22 if PARENT_RECORD_ID == 307 & household_number == 10
*replace household_number = 15 if PARENT_RECORD_ID == 310 & household_number == 8
*replace household_number = 2 if PARENT_RECORD_ID == 313 & household_number == .
*replace household_number = 1 if PARENT_RECORD_ID == 316 & household_number == 4
replace household_number = 27 if PARENT_RECORD_ID == 655 & household_number == .
replace household_number = 34 if PARENT_RECORD_ID == 685 & household_number == .
replace household_number = 35 if PARENT_RECORD_ID == 688 & household_number == .
replace household_number = 41 if PARENT_RECORD_ID == 760 & household_number == .
replace household_number = 5 if PARENT_RECORD_ID == 853 & household_number == 4
replace household_number = 5 if PARENT_RECORD_ID == 1054 & household_number == 8
replace household_number = 3 if PARENT_RECORD_ID == 1075 & household_number == 1
replace household_number = 10 if PARENT_RECORD_ID == 1096 & household_number == 17
replace household_number = 3 if PARENT_RECORD_ID == 1165 & household_number == 8
replace household_number = 1 if PARENT_RECORD_ID == 1228 & household_number == 15
replace household_number = 14 if PARENT_RECORD_ID == 1360 & household_number == 1
replace household_number = 18 if PARENT_RECORD_ID == 1399 & household_number == 1
replace household_number = 1 if PARENT_RECORD_ID == 1468 & household_number == 17
replace household_number = 14 if PARENT_RECORD_ID == 1558 & household_number == 1
replace household_number = 13 if PARENT_RECORD_ID == 1870 & household_number == 12
save "Module2a KZ", replace


****CREATE CAREGIVER FILE****
use "Module2 KZ", clear
merge 1:1 PARENT_RECORD_ID household_number using "Module4 KZ"
*527 matched, 1 in master only, 6 in using only
list PARENT_RECORD_ID household_number _merge if _merge != 3
*1207/13
*91/18
*121/15
*352/10
*604/16
*607/7
*703/12
drop _merge
merge 1:1 PARENT_RECORD_ID household_number using "Module5 KZ"
*538 matched, 6 in master only
list PARENT_RECORD_ID household_number _merge if _merge != 3
*91/18
*382/9
*607/7
*616/29
*760/41
*1207/23
drop _merge
merge 1:1 PARENT_RECORD_ID household_number using "Module6 KZ"
*530 matched, 14 in master only
list PARENT_RECORD_ID household_number _merge if _merge != 3
*91/18
*199/3
*382/3
*394/22
*556/25
*607/7
*631/16
*685/34
*691/1
*703/12
*964/12
*985/8
*1207/23
*1789/14
drop _merge
foreach x of varlist mod* {
  replace `x' = 0 if `x' ==.
}

gen modcg_tot = mod2 + mod4 + mod5 + mod6
tab modcg_tot
*3 with 1 mod, 2 with 2, 14 with 3 and 525 with 4
save caregiver_baseline, replace

***ADD THE SICK CHILD MODULES TO THE CAREGIVER FILE***
merge 1:1 PARENT_RECORD_ID household_number using "Module7 KZ"
*345 matched, 199 in master only, 30 in using only
list PARENT_RECORD_ID household_number _merge if _merge ==2
drop _merge
merge 1:1 PARENT_RECORD_ID household_number using "Module8 KZ"
*352 matched, 222 in master only, 1 in using only
list PARENT_RECORD_ID household_number _merge if PARENT_RECORD_ID == 67
drop _merge
merge 1:1 PARENT_RECORD_ID household_number using "Module9 KZ"
*319 matched, 256 in master only
drop _merge

foreach x of varlist mod* {
  replace `x' = 0 if `x' ==.
}
gen modsick_tot = mod7 + mod8 + mod9
tab modsick_tot
*16 with 0 mods, 210 with 1, 210 with 2, and 139 with 3

gen modcgi_tot = mod2 + mod4 + mod5 + mod6 + mod7 + mod8 + mod9
tab modcgi_tot
*1 with 32 mods, 3 with 2, 3 with 3, 18 with 4, 173 with 5, 210 with 6, 136 with 7
list mod* if modcgi_tot == 1
list mod* if modcgi_tot == 2
list mod* if modcgi_tot == 3
list mod* if modcgi_tot == 4

save caregiver_sick_baseline, replace


***CREATE A CLUSTER VARIABLE in the Parent_Consent data file***
use "Parent_Info KZ", clear
merge 1:1 PARENT_RECORD_ID using "Consent KZ"
*599 matched, 46 in master only
drop _merge
gen community_name = other_placename
replace community_name = community if community_name == ""
tab community_name

replace community_name = "Angoual Magagi" if community_name == "ANGOUAL MAGAGI"
replace community_name = "Angoual Magagi" if community_name == "Angoual magagi"
replace community_name = "Angoual Magagi" if community_name == "Angouale magagi"
replace community_name = "Angoual Magagi" if community_name == "Hangouale magagi"
replace community_name = "Angoual Magagi" if community_name == "Houngoi magagi"
replace community_name = "Angoualkera Jirkita" if community_name == "ANGOUALKERA JIRKITA"
replace community_name = "Angouelsaoulo" if community_name == "ANGOUEL SAOULO"
replace community_name = "Angouelsaoulo" if community_name == "Angoual solo"
replace community_name = "Angoual Danfada Moussa" if community_name == "Angouale dahodamissou"
replace community_name = "Angoual Danfada Moussa" if community_name == "Angoual dan fada moussou"
replace community_name = "Angoual Danfada Moussa" if community_name == "Angoual dan fadamousou"
replace community_name = "Angoual Danfada Moussa" if community_name == "Angoual dan fadamoussou"
replace community_name = "Angoual Danfada Moussa" if community_name == "Angoual danfada moussou"
replace community_name = "Angoual Danfada Moussa" if community_name == "Angoual danfadamoussou"
replace community_name = "Angoual Danfada Moussa" if community_name == "Angoual danhodamoussou"
replace community_name = "Angoual Danfada Moussa" if community_name == "Angoual fadamoussou"
replace community_name = "Angoual Danfada Moussa" if community_name == "Oungouwa dan fada moussou"
replace community_name = "Angoual Danfada Moussa" if community_name == "angoual dan hodamoussou"
replace community_name = "Angoual Danfada Moussa" if community_name == "angouale danhodamoussou"
replace community_name = "Angoual Danfada Moussa" if community_name == "Angoual Danfada Moussou"
replace community_name = "Attawari" if community_name == "Attaware"
replace community_name = "Attawari" if community_name == "Attawari "
replace community_name = "Attawari" if community_name == "Attware"
replace community_name = "Batamberi 2" if community_name == "BATAMBERI 2"
replace community_name = "Batamberi 2" if community_name == "Batamberi 2 "
replace community_name = "Campement Peulh Nakinfada" if community_name == "Campement peul"
replace community_name = "Campement Peulh Nakinfada" if community_name == "Campement peul nakifandou"
replace community_name = "Campement Peulh Nakinfada" if community_name == "Campement peulh nakinfada"
replace community_name = "Campement Peulh Nakinfada" if community_name == "Nakinfada peulh"
replace community_name = "Dandiborakoira" if community_name == "DANDIBORAKOIRA"
replace community_name = "Dandiborakoira" if community_name == "Dandi bora koira"
replace community_name = "Dandiborakoira" if community_name == "Dandibora koira"
replace community_name = "Dandiborakoira" if community_name == "Dandiboraoira"
replace community_name = "Dandiborakoira" if community_name == "Denbiborakoira"
replace community_name = "Dandiborakoira" if community_name == "Dendikoirabora"
replace community_name = "Fanna" if community_name == "FANNA"
replace community_name = "Fanna" if community_name == "Fznna"
replace community_name = "Gobro" if community_name == "GOBRO"
replace community_name = "Gobro" if community_name == "Gobbro"
replace community_name = "Gobro" if community_name == "goboro"
replace community_name = "Gobro" if community_name == "Gari maigoboro"
replace community_name = "Gobro" if community_name == "Gari goboro"
replace community_name = "Garin Garba" if community_name == "Gadir guida"
replace community_name = "Garin Garba" if community_name == "Gadirga guida"
replace community_name = "Garin Garba" if community_name == "gadirga guida"
replace community_name = "Garin Sabo" if community_name == "Garin  sabo"
replace community_name = "Garin Sabo" if community_name == "Garin sabo"
replace community_name = "Guinge" if community_name == "Giinge"
replace community_name = "Golo Soli" if community_name == "Golo soli"
replace community_name = "Gongomoussa" if community_name == "GONGOMOUSSA"
replace community_name = "Gongomoussa" if community_name == "Gong8 moussa"
replace community_name = "Gongomoussa" if community_name == "Gonga moussa"
replace community_name = "Gongomoussa" if community_name == "Gongo Moussa"
replace community_name = "Gongomoussa" if community_name == "Gongo moussa"
replace community_name = "Gongomoussa" if community_name == "Kongo moussa"
replace community_name = "Guinge" if community_name == "Guige"
replace community_name = "Guinge" if community_name == "Guinje"
replace community_name = "Kourouroubi M'Dakao" if community_name == "KOUROUROUBI MâDAKAO"
replace community_name = "Keda" if community_name == "KEDA"
replace community_name = "Koakoarédaji" if community_name == "KOAKOARÃDAJI"
replace community_name = "Koakoarédaji" if community_name == "Koakoadaji"
replace community_name = "Koakoarédaji" if community_name == "Koakoaredadji"
replace community_name = "Koakoarédaji" if community_name == "Koakoaredaji"
replace community_name = "Massafandou" if community_name == "MASSAFANDOU"
replace community_name = "Massafandou" if community_name == "Massa fandou"
replace community_name = "Modikoira" if community_name == "MODI KOIRA"
replace community_name = "Modikoira" if community_name == "Modi koira"
replace community_name = "Modikoira" if community_name == "Modokoira"
replace community_name = "Modikoira" if community_name == "Koli koira"
replace community_name = "Modikoira" if community_name == "Kolikoira"
replace community_name = "N'Gonga Djerma" if community_name == "N GONGA DJARMA"
replace community_name = "N'Gonga Djerma" if community_name == "N gonga"
replace community_name = "N'Gonga Djerma" if community_name == "N gonga djarma"
replace community_name = "N'Gonga Djerma" if community_name == "N gonga djerma"
replace community_name = "N'Gonga Djerma" if community_name == "N' gonga djerma"
replace community_name = "N'Gonga Djerma" if community_name == "N'GONGA DJERMA"
replace community_name = "N'Gonga Djerma" if community_name == "N'gonga Djarma"
replace community_name = "N'Gonga Djerma" if community_name == "N'gonga djerma"
replace community_name = "Tamokoira" if community_name == "Dogua koira"
replace community_name = "Tamokoira" if community_name == "TAMOKOIRA"
replace community_name = "Tamokoira" if community_name == "Tamo koira"
replace community_name = "Tamokoira" if community_name == "Tamoloira"
replace community_name = "Tamokoira" if community_name == "Tomokoira"
replace community_name = "Tamokoira" if community_name == "Tamoukoira"
replace community_name = "Tombo Dogo" if community_name == "Tambodogo"
replace community_name = "Tombo Dogo" if community_name == "Tambondogo"
replace community_name = "Tombo Dogo" if community_name == "Tombo dogo"
replace community_name = "Tombo Dogo" if community_name == "Tombon dogo"
replace community_name = "Tombo Dogo" if community_name == "Tombon dogo "
replace community_name = "Tombo Dogo" if community_name == "Tombondogo"
replace community_name = "Tombotessa" if community_name == "Tombo tessa"
replace community_name = "Tombotessa" if community_name == "Tomotessa"
replace community_name = "Aggue" if community_name == "Aggue goumanday"
replace community_name = "Gardi Peulh" if community_name == "GARDI PEULH"
replace community_name = "Garin Garba" if community_name == "Aggue"

*One interviewer did not always enter the community, but can infer from dates, times, and info in other entries
replace community_name = "Garin Garba" if PARENT_RECORD_ID == 772 & community_name == ""
replace community_name = "Garin Garba" if PARENT_RECORD_ID == 775 & community_name == ""
replace community_name = "Batamberi 2" if PARENT_RECORD_ID == 970 & community_name == ""
replace community_name = "Batamberi 2" if PARENT_RECORD_ID == 976 & community_name == ""
replace community_name = "Fanna" if PARENT_RECORD_ID == 1393 & community_name == ""
replace community_name = "Fanna" if PARENT_RECORD_ID == 1399 & community_name == ""

drop if community_name == "" | community_name == "autre_localite_dogondoutchi" | community_name == "autre_localite_keita" | community_name == "Gadirga"
*17 observations dropped
encode community_name, gen(codevil)
numlabel, add
tab codevil

replace hh_number = "10" if hh_number == "1o"
replace hh_number = "20" if hh_number == "2o"
replace hh_number = "40" if hh_number == "4o"
destring hh_number, replace
*12 observations without a HH number
save "Parent_Consent_Cluster", replace

*Merge the Cluster file with the caregiver/sick child file
merge 1:m PARENT_RECORD_ID using caregiver_sick_baseline
*558 matched, 111 in master only, 17 in using only
list PARENT_RECORD_ID hh_number household_number if _merge == 2
*Those that are in using only had records in Parent Info file but they were dropped because community information missing
drop if _merge == 2
*17 observations dropped
drop _merge
save caregiver_sick_cluster_baseline, replace

*Merge Module 1 with caregiver/sich child file
use caregiver_sick_cluster_baseline, clear
replace household_number = hh_number if household_number == .
merge 1:1 PARENT_RECORD_ID household_number using "Module1 KZ"
*536 matched, 133 in master only, 6 in using only
*Drop if only in Module 1 (6 records)
drop if _merge == 2
save caregiver_sick_cluster_baseline, replace

use caregiver_sick_cluster_baseline, clear
*Drop records without a completed illness module ==> 13 records
drop if modsick_tot == 0 
foreach x of varlist mod* {
  replace `x' = 0 if `x' ==.
}
gen mod_tot = modintro + mod0 + mod1 + mod2 + mod4 + mod5+ mod6 + mod7 + mod8 + mod9
*Drop records that include fewer than 6 modules (144 records)
drop if mod_tot <6
tab mod_tot
*512 records remaining

*Keep only needed variables
drop PARENT_RECORD_IDorig- MODIFIED_DEVICE_ID community- other_placename visit_number- survey_date
drop dup child_number child_numero n community_name
drop caregiver_number house_own_other_206a
drop child_name_fever_109 child_name_diarrhea_110 child_name_breathing_111 diarrhea_caregiver_110a 
drop diarrhe fever_caregiver_109a caregiver_number_diarrhea caregiver_number_fever caregiver_number_breathing _merge
rename child_number_diarrhea d_child_no
rename child_number_fever f_child_no
rename child_number_breathing fb_child_no

*****Rename variables to align with endline data
*Intro variables
rename children_under_5_001 q001
rename caregiver_002 q002
rename caregiver_all_003 q003
rename caregiver_how_many_004 q004 
rename survey_consent consent
lab var codevil "Community"
rename household_number nummen
gen cod_loc = 301 if district == "Boboye"
replace cod_loc = 303 if district == "Dogondoutchi"
replace cod_loc = 304 if district == "Dosso"
replace cod_loc = 504 if district == "Keita"
lab def district 301 "Boboye" 303 "Dogondoutchi" 304 "Dosso" 504 "Keita"
lab val cod_loc district


foreach x of varlist q001-q004 consent {
  destring `x', replace
}

*Module 2 variable
rename DateTime_CG_201 q201
rename school_lvl_204 q204
rename house_own_206 q206
rename school_attend_203 q203
rename child_age_202 q202
rename school_grade_205 q205

foreach x of varlist q204 q206 q203 {
  destring `x', replace
}

*Module 4 variables
rename current_married_401 q401
rename married_ever_402 q402
rename marital_status_403 q403
rename where_live_404 q404
rename partner_age_405 q405
rename partner_school_406 q406
rename partner_edu_level_407 q407
rename partner_grade_level_408 q408
rename partner_occupation_409 q409
rename work_7days_410 q410
rename income_other_411 q411
rename work_missed_412 q412
rename work_12months q413
rename occupation_414 q414
rename work_for_415 q415
rename work_year_416 q416
rename paid_method_417 q417
rename money_spend_yours_420 q420 
rename money_spend_yours_other_420 q420_autre
rename partner_earn_amount_421 q421
rename money_spend_partner_422 q422
rename money_spend_partner_other_422 q422_autre 
rename health_care_yours_423 q423
rename major_purchase_424 q424

foreach x of varlist q401-q408 {
  destring `x', replace
}

*Module 5 variables
rename healthcentre_proximity_501 q501 
rename transport_502 q502
rename time_min_503 q503
rename CCM_workers_504 q504
rename clinic_nearby_507 q507
rename CHW_accessbile_508 q508
rename CHW_first_trest_509 q509
rename avail_medicine_510 q510
rename quality_medicine_511 q511
rename trust_CHW_512 q512
rename respect_CHW_513 q513
rename home_visit_514 q514
rename time_less_515 q515
rename costs_less_516 q516

rename pre_com_mobili_505a q505A
rename pre_distribution_llins_505b q505B
rename pre_health_campaigns_505c q505C
rename pre_health_messages_505d q505D
rename pre_hang_nets_505e q505E
rename pre_info_events_505f q505F
rename pre_info_events_505fa q505G
rename pre_water_tablets_505g q505H
rename pre_collect_info_505h q505I
rename pre_other_505 q505J
rename cure_refer_facility_505a q505K
rename cure_test_malaria_505b q505L
rename cure_assess_pneumonia_505c q505M
rename cure_treat_malaria_505d q505N
rename cure_treat_pneumonia_505e q505O
rename cure_ors_diarrhea_505f q505P
rename cure_zinc_diarrhea_505g q505Q
rename cure_assess_malnutrition_505h q505R 
rename cure_follow_up_505i q505S
rename cure_other_505j q505T

replace q502 = "3" if q502 =="charette"

foreach x of varlist q501- q505G {
  destring `x', replace
}

*Module 6 variables
rename sign_illness_601 q601
rename heard_malaria_602 q602
rename acquire_malaria_603 q603
rename acquire_malaria_other_603 q603_autre 
rename symp_malaria_604 q604
rename symp_malaria_other_604a q604_autre 
rename treatment_malaria_605 q605
rename treatment_malaria_other_605a q605_autre 

gen q601A = 1 if strpos(q601, "11")
gen q601B = 1 if strpos(q601, "21")
gen q601C = 1 if strpos(q601, "22")
gen q601E = 1 if strpos(q601, "31")
gen q601F = 1 if strpos(q601, "32")
gen q601G = 1 if strpos(q601, "33")
gen q601I = 1 if strpos(q601, "41")
gen q601K = 1 if strpos(q601, "42")
gen q601L = 1 if strpos(q601, "51")
gen q601M = 1 if strpos(q601, "52")
gen q601N = 1 if strpos(q601, "53")
gen q601O = 1 if strpos(q601, "54")
gen q601P = 1 if strpos(q601, "61")
gen q601Q = 1 if strpos(q601, "62")
gen q601R = 1 if strpos(q601, "63")
gen q601S = 1 if strpos(q601, "71")
gen q601X = 1 if strpos(q601, "96")
gen q601Z = 1 if strpos(q601, "98")

gen q603A = 1 if strpos(q603, "11")
gen q603B = 1 if strpos(q603, "12")
gen q603C = 1 if strpos(q603, "13")
gen q603D = 1 if strpos(q603, "14")
gen q603E = 1 if strpos(q603, "15")
gen q603F = 1 if strpos(q603, "16")
gen q603G = 1 if strpos(q603, "17")
gen q603X = 1 if strpos(q603, "96")
gen q603Z = 1 if strpos(q603, "98")

gen q604A = 1 if strpos(q604, "11")
gen q604B = 1 if strpos(q604, "12")
gen q604C = 1 if strpos(q604, "13")
gen q604D = 1 if strpos(q604, "14")
gen q604E = 1 if strpos(q604, "15")
gen q604F = 1 if strpos(q604, "16")
gen q604G = 1 if strpos(q604, "17")
gen q604H = 1 if strpos(q604, "18")
gen q604I = 1 if strpos(q604, "19")
gen q604X = 1 if strpos(q604, "96")
gen q604Z = 1 if strpos(q604, "98")

foreach x of varlist q601A {
  replace `x' = 0 if `x' ==. & mod6 == 1
}

destring q602, replace

*Module 7 variables
rename Usual_drink_701 q701
rename Usual_eat_702 q702
rename seek_advice_703 q703
rename Seek_treatment_704 q704
rename Make_decision_705 q705
rename Advice_treatment_706 q706
rename seek_advice_other_706b q706_autre
rename seek_multiplace_707 q707
rename first_seek_advice_or_treatment_7 q708
rename ors_packet_709a q709a
rename ors_liquid_709b q709b
rename selected_710 q710
rename where_got_ors_711 q711 
rename other_ors_source_711a q711_autre
rename ors_taken_chwccm_713 q713
rename counseled_ors_athome_714 q714
rename given_zinc_715 q715
rename where_got_zinc_716 q716
rename where_got_zinc_other_716a q716_autre 
rename zonc_taken_w_chw q717
rename counseled_zinc_athome_719 q719
rename first_zinc_w_ccw_720 q720
rename other_diarrhea_treatment_721 q721
rename other_diarrhea_treatment_text_72 q721_autre2
rename was_ccmchw_consulted_722 q722
rename ccmchw_avail1st_time_724 q724
rename ccmchw_refer_healthfac_725 q725
rename followed_ccmchws_referral_726 q726
rename novisit_health_centre_727 q727
rename novisit_health_centre_other_727a q727_autre
rename CHW_visit_after_advice_treatment q728
rename CHW_home_visit_729 q729
rename vaccine_record_730 q730

rename bcg_731 q731a
rename polio_0_731 q731b
rename polio_1_731 q731c
rename polio_2_731 q731d
rename polio_3_731 q731e
rename penta_1_731 q731f
rename penta_2_731 q731h
rename penta_3_731 q731i
rename yellow_fever_731 q731j 
rename measles_731 q731m
rename vitamin_a_731 q731n
rename vaccine_other_732 q732
rename vaccine_location_733 q733
rename polio_mouth_734 q734
rename polio_time_735 q735
rename polio_frequency_736 q736 
rename penta_thigh_737 q737
rename penta_times_738 q738
rename vaccine_yellow_fever_739 q739
rename measles_inject_741 q741
rename vitamina_dose_742 q742
rename vitamina_6months_743 q743

replace q705 = "1" if q705 == "conjoint"

gen q706A = 1 if strpos(q706, "11")
gen q706B = 1 if strpos(q706, "12")
gen q706C = 1 if strpos(q706, "13")
gen q706D = 1 if strpos(q706, "14")
gen q706E = 1 if strpos(q706, "16")
gen q706F = 1 if strpos(q706, "17")
gen q706G = 1 if strpos(q706, "18")
gen q706H = 1 if strpos(q706, "15")
gen q706I = 1 if strpos(q706, "21")
gen q706J = 1 if strpos(q706, "22")
gen q706K = 1 if strpos(q706, "23")
gen q706L = 1 if strpos(q706, "26")
gen q706X = 1 if strpos(q706, "96")

clonevar q708s = q708
replace q708 = "15" if q708s == "16"
replace q708 = "16" if q708s == "17"
replace q708 = "17" if q708s == "18"
replace q708 = "18" if q708s == "15"
drop q708s

*separate responses for other treatment into unique 3 variables
split q721, parse(,)
gen q721A = 1 if q7211 == "1" | q7212 == "1" | q7213 == "1"
gen q721B = 1 if q7211 == "2" | q7212 == "2" | q7213 == "2"
gen q721C = 1 if q7211 == "3" | q7212 == "3" | q7213 == "3"
gen q721D = 1 if q7211 == "4" | q7212 == "4" | q7213 == "4"
gen q721E = 1 if q7211 == "5" | q7212 == "5" | q7213 == "5"
gen q721F = 1 if q7211 == "6" | q7212 == "6" | q7213 == "6"
gen q721G = 1 if q7211 == "7" | q7212 == "7" | q7213 == "7"
gen q721H = 1 if q7211 == "8" | q7212 == "8" | q7213 == "8"
gen q721I = 1 if q7211 == "9" | q7212 == "9" | q7213 == "9"
gen q721X = 1 if q7211 == "96" | q7212 == "96" | q7213 == "96"

foreach x of varlist q701-q730 q732-q743 q704-q739 {
  destring `x', replace
}

clonevar q711temp = q711
replace q711 = 15 if q711temp == 16
replace q711 = 16 if q711temp == 17
replace q711 = 17 if q711temp == 18 
replace q711 = 18 if q711temp == 15
replace q711 = 24 if q711temp == 26
replace q711 = 31 if q711temp == 96
drop q711temp

clonevar q716temp = q716
replace q716 = 15 if q716temp == 16
replace q716 = 16 if q716temp == 17
replace q716 = 17 if q716temp == 18 
replace q716 = 18 if q716temp == 15
replace q716 = 24 if q716temp == 26
replace q716 = 31 if q716temp == 96
drop q716temp

tostring q708, replace
tostring q721_autre2, replace
tostring q727, replace
tostring q727_autre, replace

*Module 8 variables
rename fever_drink_801 q801
rename fever_eat_802 q802
rename ilness_advice_803 q803
rename treatment_decision_804 q804 
rename joint_decision_805 q805
rename treatment_advice_place_806 q806 
rename other_source_of_treatment_806a q806_autre
rename check_806_807 q807
rename first_treatment_808 q808
rename blood_testing_809 q809
rename took_blood_810 q810
rename took_blood_other_810a q810_autre
rename blood_test_shared_811 q811
rename blood_test_result_812 q812
rename name_take_drugs_813 q813
rename drugs_name_take_814 q814 
rename drugs_name_take_other_814a q814_autre
rename act_verify_815 q815
rename Where_get_act_816 q816
rename get_act_other_816b q816_autre
rename first_take_act_817 q817
rename act_verify_818 q818
rename dose_one_provider_819 q819
rename counseled_on_act_820 q820
rename verify_consulted_821 q821
rename chw_first_time_822 q822
rename chw_refer_823 q823
rename follow_the_chws_824 q824 
rename novisit_healthfacility_825 q825
rename no_health_facility_other_825a q825_autre
rename chw_visit_home_826 q826
rename chw_vist_num_days_827 q827
rename verify_diarrhea_828a q828_av
rename vaccine_record_828 q828

rename bcg_829 q829a
rename polio_0_829 q829b
rename polio_1_829 q829c
rename polio_2_829 q829d
rename penta_1_829 q829e
rename penta_3_829 q829f
rename penta_2_829 q829h
rename polio_3_829 q829i
rename yellow_fever_829 q829j
rename measles_829 q829m
rename vitamin_a_829 q829n
rename vaccine_other_830 q830
rename bcg_vaccine_831 q831
rename polio_location_832 q832
rename polio_time_ q833
rename polio_frequency_834 q834
rename penta_thigh_835 q835
rename penta_times_836 q836
rename vaccine_yellow_fever_837 q837
rename measles_inject_839 q839
rename vitamina_dose_840 q840
rename vitamina_6months_841 q841

replace q805 = "1" if q805 == "conjoint"

gen q806A = 1 if strpos(q806, "11")
gen q806B = 1 if strpos(q806, "12")
gen q806C = 1 if strpos(q806, "13")
gen q806D = 1 if strpos(q806, "14")
gen q806E = 1 if strpos(q806, "16")
gen q806F = 1 if strpos(q806, "17")
gen q806G = 1 if strpos(q806, "18")
gen q806H = 1 if strpos(q806, "15")
gen q806I = 1 if strpos(q806, "21")
gen q806J = 1 if strpos(q806, "22")
gen q806K = 1 if strpos(q806, "23")
gen q806L = 1 if strpos(q806, "26")
gen q806X = 1 if strpos(q806, "96")

clonevar q808s = q808
replace q808 = "15" if q808s == "16"
replace q808 = "16" if q808s == "17"
replace q808 = "17" if q808s == "18"
replace q808 = "18" if q808s == "15"
drop q808s

*Split medicines received inthe 4 variables
split q814, parse(,)
gen q814A = 1 if q8141 == "1" | q8142 == "1" | q8143 == "1" | q8144 == "1"
gen q814B = 1 if q8141 == "2" | q8142 == "2" | q8143 == "2" | q8144 == "2"
gen q814C = 1 if q8141 == "3" | q8142 == "3" | q8143 == "3" | q8144 == "3"
gen q814D = 1 if q8141 == "4" | q8142 == "4" | q8143 == "4" | q8144 == "4"
gen q814E = 1 if q8141 == "5" | q8142 == "5" | q8143 == "5" | q8144 == "5"
gen q814F = 1 if q8141 == "6" | q8142 == "6" | q8143 == "6" | q8144 == "6"
gen q814G = 1 if q8141 == "7" | q8142 == "7" | q8143 == "7" | q8144 == "7"
gen q814H = 1 if q8141 == "8" | q8142 == "8" | q8143 == "8" | q8144 == "8"
gen q814I = 1 if q8141 == "9" | q8142 == "9" | q8143 == "9" | q8144 == "9"
gen q814J = 1 if q8141 == "10" | q8142 == "10" | q8143 == "10" | q8144 == "10"
gen q814X = 1 if q8141 == "96" | q8142 == "96" | q8143 == "96" | q8144 == "96"
gen q814Z = 1 if q8141 == "98" | q8142 == "98" | q8143 == "98" | q8144 == "98"

foreach x of varlist q801-q837 {
  destring `x', replace
}

clonevar q816temp = q816
replace q816 = 15 if q816temp == 16
replace q816 = 16 if q816temp == 17
replace q816 = 17 if q816temp == 18 
replace q816 = 18 if q816temp == 15
drop q816temp

tostring q808, replace
tostring q810, replace
tostring q810_autre, replace
tostring q825, replace
tostring q828, replace

*Module 9 variables
rename given_drink_901 q901
rename eating_902 q902
rename seek_treatment_903 q903 
rename treatment_decision_904 q904
rename care_decision_whom_905 q905
rename other_treatment_advice_905a q905_autre
rename where_treated_906 q906
rename where_treated_other_906 q906_autre 
rename verify_last_907 q907
rename first_seek_treatment_908 q908
rename breath_timer_909 q909
rename breath_checker_910 q910
rename second_breath_checker_910a q910_autre 
rename take_drugs_911 q911
rename drugs_type_912 q912
rename drugstype_others_912a q912_autre
rename other_drugs_verify_913 q913
rename source_anitbiotic_pillsyrup_914 q914
rename source_anitbiotic_pillsyrup_othe q914_autre
rename antibio_verify_915 q915
rename Antibiotic_observed_916 q916
rename antibiotic_counseled_917 q917
rename asc_verify_918 q918
rename ccmchw_available_YN_919 q919
rename chw_referred_920 q920
rename chw_referral_advice_921 q921 
rename health_centre_novisit_why_922 q922
rename novisit_other_reason_922a q922_autre
rename chw_visit_923 q923
rename chw_homevisit_924 q924
rename verify_diarrhea_fever_924a q924b
rename vaccine_record_925 q925

rename bcg_926 q926a
rename polio_0_926 q926b
rename polio_1_926 q926c
rename polio_2_926 q926d
rename polio_3_926 q926e
rename penta_1_926 q926f
rename penta_2_926 q926h
rename penta_3_926 q926i
rename yellow_fever_926 q926j
rename measles_926 q926m
rename vitamin_a_926 q926n
rename vaccine_other_927 q927
rename bcg_vaccine_928 q928
rename polio_mouth_929 q929
rename polio_time_930 q930
rename polio_frequency_931 q931 
rename penta_thigh_932 q932
rename penta_times_936 q933
rename vaccine_yellow_fever_934 q934
rename measles_inject_936 q936
rename vitamina_dose_937 q937
rename vitamina_6months_938 q938

replace q905 = "1" if q905 == "conjoint"

gen q906A = 1 if strpos(q906, "11")
gen q906B = 1 if strpos(q906, "12")
gen q906C = 1 if strpos(q906, "13")
gen q906D = 1 if strpos(q906, "14")
gen q906E = 1 if strpos(q906, "16")
gen q906F = 1 if strpos(q906, "17")
gen q906G = 1 if strpos(q906, "18")
gen q906H = 1 if strpos(q906, "15")
gen q906I = 1 if strpos(q906, "21")
gen q906J = 1 if strpos(q906, "22")
gen q906K = 1 if strpos(q906, "23")
gen q906L = 1 if strpos(q906, "26")
gen q906X = 1 if strpos(q906, "96")

clonevar q908s = q908
replace q908 = "15" if q908s == "16"
replace q908 = "16" if q908s == "17"
replace q908 = "17" if q908s == "18"
replace q908 = "18" if q908s == "15"
drop q908s

*Split medicines received inthe 4 variables
split q912, parse(,)
gen q912A = 1 if q9121 == "1" | q9122 == "1" | q9123 == "1" | q9124 == "1"
gen q912B = 1 if q9121 == "2" | q9122 == "2" | q9123 == "2" | q9124 == "2"
gen q912C = 1 if q9121 == "3" | q9122 == "3" | q9123 == "3" | q9124 == "3"
gen q912D = 1 if q9121 == "4" | q9122 == "4" | q9123 == "4" | q9124 == "4"
gen q912E = 1 if q9121 == "5" | q9122 == "5" | q9123 == "5" | q9124 == "5"
gen q912F = 1 if q9121 == "6" | q9122 == "6" | q9123 == "6" | q9124 == "6"
gen q912G = 1 if q9121 == "7" | q9122 == "7" | q9123 == "7" | q9124 == "7"
gen q912H = 1 if q9121 == "8" | q9122 == "8" | q9123 == "8" | q9124 == "8"
gen q912I = 1 if q9121 == "9" | q9122 == "9" | q9123 == "9" | q9124 == "9"
gen q912J = 1 if q9121 == "10" | q9122 == "10" | q9123 == "10" | q9124 == "10"
gen q912X = 1 if q9121 == "96" | q9122 == "96" | q9123 == "96" | q9124 == "96"
gen q912Z = 1 if q9121 == "98" | q9122 == "98" | q9123 == "98" | q9124 == "98"

foreach x of varlist  q901-q925 q927-q937 q938-q934 {
  destring `x', replace
}

clonevar q914temp = q914
replace q914 = 15 if q914temp == 16
replace q914 = 16 if q914temp == 17
replace q914 = 17 if q914temp == 18 
replace q914 = 18 if q914temp == 15
replace q914 = 24 if q914temp == 26
replace q914 = 31 if q914temp == 96
drop q914temp

tostring q908, replace
tostring q910, replace
tostring q922, replace

tab mod_tot
*Drop records that only include 1 sick child or caregiver module (31 records)
drop if mod_tot == 1
*Drop records that only include 2 sick child or caregiver modules (2 records)
drop if mod_tot == 2
tab mod_tot

order _all, seq
order region
gen survey = 1
save caregiver_sick_cluster_baseline, replace

keep region-q605_autre q724 q822 q919 q706H q806H q906H survey
drop *child_no
save caregiver_baseline, replace

use caregiver_sick_cluster_baseline, clear
keep region- nummen q701-q938 survey q401 q404
save illness_baseline_pre, replace

use illness_baseline_pre, clear
keep PARENT_RECORD_ID codevil nummen mod* d_child_no q701-q743 survey q401 q404
drop if mod7 != 1
gen d_case = 1
save diarrhea_bl, replace

use illness_baseline_pre, clear
keep PARENT_RECORD_ID codevil nummen mod* f_child_no q801-q841 survey q401 q404
drop if mod8 != 1
gen f_case = 1
save fever_bl, replace

use illness_baseline_pre, clear
keep PARENT_RECORD_ID codevil nummen mod* fb_child_no q901-q938 survey q401 q404
drop if mod9 != 1
gen fb_case = 1
save fastb_bl, replace

use diarrhea_bl, clear
append using fever_bl
append using fastb_bl
save illness_baseline, replace

*Pull roster information for selected sick children
gen child_number = d_child_no if d_child_no !=.
replace child_number = f_child_no if f_child_no !=.
replace child_number = fb_child_no if fb_child_no !=.
merge m:1 PARENT_RECORD_ID nummen child_number using "Module1a KZ"
*929 matched, 70 in master only, 383 in using only
drop if _merge == 2
drop q102 _merge ID- MODIFIED_DEVICE_ID
save illness_baseline, replace


use "Malaria_Context", clear
duplicates list PARENT_RECORD_ID household_number
*One duplicate (Parent ID 613, HH 20)
replace household_number = 19 if PARENT_RECORD_ID == 613 & CREATED_DATE == "2013-09-11 09:08:12"
replace household_number = 10 if PARENT_RECORD_ID == 7 & household_number == .
*replace household_number = 5 if PARENT_RECORD_ID == 73 & household_number == .
replace household_number = 11 if PARENT_RECORD_ID == 157 & household_number == .
replace household_number = 32 if PARENT_RECORD_ID == 226 & household_number == 1
replace household_number = 10 if PARENT_RECORD_ID == 238 & household_number == 1
replace household_number = 2 if PARENT_RECORD_ID == 244 & household_number == .
replace household_number = 14 if PARENT_RECORD_ID == 271 & household_number == 1
replace household_number = 19 if PARENT_RECORD_ID == 574 & household_number == 1
*replace household_number = 6 if PARENT_RECORD_ID == 604 & household_number == 16
replace household_number = 7 if PARENT_RECORD_ID == 631 & household_number == .
replace household_number = 41 if PARENT_RECORD_ID == 760 & household_number == .
replace household_number = 43 if PARENT_RECORD_ID == 817 & household_number == .
replace household_number = 3 if PARENT_RECORD_ID == 835 & household_number == .
replace household_number = 10 if PARENT_RECORD_ID == 838 & household_number == .
replace household_number = 17 if PARENT_RECORD_ID == 880 & household_number == 1
replace household_number = 5 if PARENT_RECORD_ID == 1054 & household_number == 8
replace household_number = 10 if PARENT_RECORD_ID == 1096 & household_number == 17
replace household_number = 7 if PARENT_RECORD_ID == 1102 & household_number == .
replace household_number = 3 if PARENT_RECORD_ID == 1117 & household_number == 1
replace household_number = 3 if PARENT_RECORD_ID == 1165 & household_number == 8
replace household_number = 1 if PARENT_RECORD_ID == 1228 & household_number == 15
replace household_number = 1 if PARENT_RECORD_ID == 1468 & household_number == 17
replace household_number = 7 if PARENT_RECORD_ID == 1471 & household_number == .
replace household_number = 13 if PARENT_RECORD_ID == 1486 & household_number == .
replace household_number = 16 if PARENT_RECORD_ID == 1624 & household_number == 17
replace household_number = 2 if PARENT_RECORD_ID == 1864 & household_number == 12
save "Module3 KZ", replace

use "Bednets", clear
duplicates report PARENT_RECORD_ID household_number
replace household_number = 24 if PARENT_RECORD_ID == 223 & household_number == .
replace household_number = 17 if PARENT_RECORD_ID == 235 & household_number == 14
replace household_number = 20 if PARENT_RECORD_ID == 238 & household_number == 0
replace household_number = 22 if PARENT_RECORD_ID == 244 & household_number == 0
replace household_number = 9 if PARENT_RECORD_ID == 247 & household_number == .
replace household_number = 8 if PARENT_RECORD_ID == 289 & household_number == .
replace household_number = 14 if PARENT_RECORD_ID == 301 & household_number == .
replace household_number = 19 if PARENT_RECORD_ID == 310 & household_number == 1
replace household_number = 31 if PARENT_RECORD_ID == 337 & household_number == 28
replace household_number = 4 if PARENT_RECORD_ID == 346 & household_number == .
replace household_number = 26 if PARENT_RECORD_ID == 376 & household_number == .
replace household_number = 1 if PARENT_RECORD_ID == 406 & household_number == 10
replace household_number = 1 if PARENT_RECORD_ID == 427 & household_number == 14
replace household_number = 21 if PARENT_RECORD_ID == 433 & household_number == 12
replace household_number = 21 if PARENT_RECORD_ID == 433 & household_number == .
replace household_number = 12 if PARENT_RECORD_ID == 451 & household_number == 25
replace household_number = 2 if PARENT_RECORD_ID == 529 & household_number == 1
replace household_number = 25 if PARENT_RECORD_ID == 553 & household_number == 1
replace household_number = 24 if PARENT_RECORD_ID == 607 & household_number == .
replace household_number = 23 if PARENT_RECORD_ID == 610 & household_number == .
replace household_number = 10 if PARENT_RECORD_ID == 664 & household_number == .
replace household_number = 20 if PARENT_RECORD_ID == 676 & household_number == .
replace household_number = 19 if PARENT_RECORD_ID == 679 & household_number == 20
replace household_number = . if PARENT_RECORD_ID == 706 & household_number == 7
replace household_number = 8 if PARENT_RECORD_ID == 745 & household_number == .
replace household_number = 1 if PARENT_RECORD_ID == 760 & household_number == .
replace household_number = 1 if PARENT_RECORD_ID == 898 & household_number == 17
replace household_number = 23 if PARENT_RECORD_ID == 916 & household_number == .
replace household_number = 5 if PARENT_RECORD_ID == 1006 & household_number == 1
replace household_number = 12 if PARENT_RECORD_ID == 1024 & household_number == 13
replace household_number = 12 if PARENT_RECORD_ID == 1036 & household_number == 1
replace household_number = 10 if PARENT_RECORD_ID == 1084 & household_number == .
replace household_number = . if PARENT_RECORD_ID == 1096 & household_number == 7
replace household_number = 1 if PARENT_RECORD_ID == 1111 & household_number == .
replace household_number = 13 if PARENT_RECORD_ID == 1129 & household_number == .
replace household_number = 22 if PARENT_RECORD_ID == 1177 & household_number == .
replace household_number = 15 if PARENT_RECORD_ID == 1225 & household_number == .
replace household_number = 11 if PARENT_RECORD_ID == 1255 & household_number == .
replace household_number = 2 if PARENT_RECORD_ID == 1324 & household_number == .
replace household_number = 4 if PARENT_RECORD_ID == 1342 & household_number == .
replace household_number = 6 if PARENT_RECORD_ID == 1363 & household_number == .
replace household_number = 15 if PARENT_RECORD_ID == 1366 & household_number == .
replace household_number = 13 if PARENT_RECORD_ID == 1369 & household_number == .
replace household_number = 18 if PARENT_RECORD_ID == 1372 & household_number == .
replace household_number = 1 if PARENT_RECORD_ID == 1381 & household_number == .
replace household_number = 5 if PARENT_RECORD_ID == 1393 & household_number == .
replace household_number = 1 if PARENT_RECORD_ID == 1405 & household_number == .
replace household_number = . if PARENT_RECORD_ID == 1438 & household_number == 7
replace household_number = 12 if PARENT_RECORD_ID == 1468 & household_number == 15
replace household_number = 6 if PARENT_RECORD_ID == 1483 & household_number == .
replace household_number = 21 if PARENT_RECORD_ID == 1546 & household_number == .
replace household_number = 17 if PARENT_RECORD_ID == 1573 & household_number == 16
replace household_number = 13 if PARENT_RECORD_ID == 1651 & household_number == .
replace household_number = 16 if PARENT_RECORD_ID == 1663 & household_number == .
replace household_number = 18 if PARENT_RECORD_ID == 1753 & household_number == 19
replace household_number = 12 if PARENT_RECORD_ID == 1771 & household_number == 2
replace household_number = 11 if PARENT_RECORD_ID == 1801 & household_number == 1
replace household_number = 32 if PARENT_RECORD_ID == 397 & household_number == 1
replace household_number = 10 if PARENT_RECORD_ID == 406 & household_number == 1
replace household_number = 14 if PARENT_RECORD_ID == 427 & household_number == 1
replace household_number = 7 if PARENT_RECORD_ID == 706 & household_number == .
replace household_number = 17 if PARENT_RECORD_ID == 898 & household_number == 1
replace household_number = 5 if PARENT_RECORD_ID == 1054 & household_number == 8
replace household_number = 10 if PARENT_RECORD_ID == 1090 & household_number == 17
replace household_number = 7 if PARENT_RECORD_ID == 1096 & household_number == .
replace household_number = 3 if PARENT_RECORD_ID == 1111 & household_number == 1
replace household_number = 1 if PARENT_RECORD_ID == 1210 & household_number == 15
replace household_number = 1 if PARENT_RECORD_ID == 1435 & household_number == 17
replace household_number = 7 if PARENT_RECORD_ID == 1438 & household_number == .
replace household_number = 16 if PARENT_RECORD_ID == 1573 & household_number == 17
replace household_number = 2 if PARENT_RECORD_ID == 1771 & household_number == 12
bysort PARENT_RECORD_ID household_number: gen bednet_n = _n
duplicates report PARENT_RECORD_ID household_number bednet_n
save "Bednets KZ", replace

use "Module3 KZ", clear
rename PARENT_RECORD_ID PARENT_RECORD_IDorig
rename ID PARENT_RECORD_ID 
destring PARENT_RECORD_ID, replace
merge 1:m PARENT_RECORD_ID household_number using "Bednets KZ"
*775 matched, 61 in master only
drop _merge ID
rename PARENT_RECORD_ID ID
rename PARENT_RECORD_IDorig PARENT_RECORD_ID 
replace household_number = 13 if PARENT_RECORD_ID == 58 & household_number == 28
replace household_number = 5 if PARENT_RECORD_ID == 73 & household_number == .
replace household_number = 1 if PARENT_RECORD_ID == 616 & household_number == 29
replace household_number = 16 if PARENT_RECORD_ID == 631 & household_number == 7
replace household_number = 5 if PARENT_RECORD_ID == 73 & household_number == .

rename household_number nummen
save "Module3 Bednets KZ", replace

use "caregiver_baseline", clear
merge 1:m PARENT_RECORD_ID nummen using "Module3 Bednets KZ"
*809 matched, 2 in master only, 27 in using only
list PARENT_RECORD_ID nummen if _merge == 2
*Records for Parent ID 604 HH16 and Parent ID 73 HH . 
save "caregiver_baseline nets KZ", replace

