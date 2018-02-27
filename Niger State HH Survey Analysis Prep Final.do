**********************************************
** RAcE Niger State HH Survey Analysis Prep **
**     Allison Schmale, April 6,2017        **
**********************************************

*Create Unique IDs for each HH record
set more off

***BASELINE
*cd "C:\Users\36763\Desktop\RACE Data Analysis\Nigeria\Niger State (MC)\Baseline files"
***create unique identifiers for the BL data files to be able to merge into one master file
*BASELINE
use "MC Nigeria merged baseline.dta", clear
gen survey=1 
gen clust=string(hhclust,"%02.0f")
gen hh=string(hhnumber,"%02.0f")
egen hhid=concat(clust hh)
egen cgid=concat(hhid cgnumber)
drop clust hh
destring hhid,replace
destring cgid,replace
drop _merge
save "MC Nigeria BL_mergeready.dta", replace

*BL ROSTER FILE
use "roster_baseline.dta", clear
gen survey=1
gen clust=string(hhclust,"%02.0f")
gen hh=string(hhnumber,"%02.0f")
egen hhid=concat(clust hh)
destring hhid,replace
drop clust hh
*get_sex_age
gen cline=string(q101,"%02.0f")
egen cid=concat(hhid cline)
drop cline
destring cid,replace
save "roster_BL_mergeready.dta", replace

***ENDLINE
*cd "C:\Users\36763\Desktop\RACE Data Analysis\Nigeria\Niger State (MC)\Endline files"
*EL CAREGIVER FILE
use "caregiver.dta", clear
gen survey=2
gen clust=string(hhclust,"%02.0f")
gen hh=string(hhnumber,"%02.0f")
egen hhid=concat(clust hh)
egen cgid=concat(hhid cgnumber)
drop clust hh
destring cgid,replace
destring hhid,replace
save "cg_mergeready.dta", replace

*EL ASSETS FILE
use "assets.dta", clear
gen survey=2
gen clust=string(hhclust,"%02.0f")
gen hh=string(hhnumber,"%02.0f")
egen hhid=concat(clust hh)
egen cgid_assets=concat(hhid cgnumber)
drop clust hh 
destring hhid,replace
destring cgid_assets,replace
save "assets_mergeready.dta", replace

*EL ROSTER FILE
use "roster.dta", clear
gen survey=2
gen clust=string(hhclust,"%02.0f")
gen hh=string(hhnumber,"%02.0f")
egen hhid=concat(clust hh)
destring hhid,replace
drop clust hh 
*get_sex_age
gen cline=string(q101,"%02.0f")
egen cid=concat(hhid cline)
drop cline
destring cid,replace
save "roster_mergeready.dta", replace

*EL HOUSEHOLD FILE
use "hh.dta", clear
gen survey=2
gen clust=string(hhclust,"%02.0f")
gen hh=string(hhnumber,"%02.0f")
egen hhid=concat(clust hh)
drop clust hh
destring hhid,replace
save "hh_mergeready.dta", replace


*Removal/cleaning of duplicate files in baseline hh file 
*Cleaing check for basline file
use "MC Nigeria BL_mergeready.dta", clear
duplicates list survey hhid cgid

*Removal/cleaning of duplicate file in endline HH file
use "hh_mergeready.dta", clear 
duplicates list survey hhid 

*Removal/cleaning of duplicate file in endline cg file
use "cg_mergeready.dta", clear 
duplicates list survey hhid cgnumber
*q605 is coded differently in the baseline and endline surveys, so adjusting the endline responses to match the baseline responses
replace q605 = "1" if q605 == "A"
replace q605 = "2" if q605 == "B"
replace q605 = "3" if q605 == "C"
replace q605 = "4" if q605 == "D"
replace q605 = "5" if q605 == "E"
replace q605 = "6" if q605 == "X"
replace q605 = "8" if q605 == "Z"
destring q605, replace
save "cg_mergeready.dta", replace

*Cleaning of duplicate file in endline assets file
use "assets_mergeready.dta", clear
duplicates list hhid

*Cleaning of duplicate file in endline roster file
use "roster_mergeready.dta", clear
duplicates list hhid cid


***Append and merge data files***
pwd
*cd "C:\Users\36763\Desktop\RACE Data Analysis\Nigeria\Niger State (MC)\Endline files"

use "hh_mergeready.dta", clear
merge 1:m survey hhid using "cg_mergeready.dta"
*510 matched, 1 in master only, 0 in using only
list if _merge != 3
drop if _merge != 3
drop _merge
tab hhresult
drop if hhresult != 1
save "cg_hh_combined_el.dta", replace

*Merge BL and EL roster for selected child illness indicators
*Append BL & EL roster files
use "roster_mergeready.dta", clear
append using "roster_BL_mergeready.dta"
*Create a variable that links caregiver # to each child
gen cgnumber = q109cg if q109cg !=. & q109ch == q101
replace cgnumber = q110cg if q110cg !=. & q110ch == q101
replace cgnumber = q111cg if q111cg !=. & q111ch == q101
count
tab cgnumber survey
tab cgnumber survey, m
save "BL EL complete_roster.dta", replace

*Append EL and BL caregeiver and HH data sets
use "MC Nigeria BL_mergeready.dta", clear
append using "cg_hh_combined_el.dta"
save "BL EL cg_hh_combined.dta", replace

*Merge BL EL roster with BL EL caregiver and household data sets
use "BL EL cg_hh_combined.dta", clear
merge 1:m survey hhid cgnumber using "BL EL complete_roster.dta"
*1580 matched, 0 in master only, 929 in using only
save "BL EL complete_roster_cg_hh.dta", replace
drop _merge


**************************Selected sick child information*******************************
use "BL EL complete_roster_cg_hh.dta", clear
sort survey hhid q101
bysort survey hhid: gen no=_n
bysort survey hhid: gen totchild=_N
egen totill = anycount(q105 q106 q108), values(1)

*Total number & proportion of selected sick children per survey, by number of illnesses
tab totill survey if (q7child == q101 | q8child == q101 | q9child == q101), col
svyset hhclust 
svy: tab totill survey if (q7child == q101 | q8child == q101 | q9child == q101), col ci pear obs

svy: tab q105 survey if (q7child == q101 | q8child == q101 | q9child == q101), col ci pear obs
svy: tab q106 survey if (q7child == q101 | q8child == q101 | q9child == q101), col ci pear obs
replace q108 = 0 if q108 ==.
svy: tab q108 survey if (q7child == q101 | q8child == q101 | q9child == q101), col ci pear obs

*Average number of illnesses per selected sick children per survey
svy: mean totill if (q7child == q101 | q8child == q101 | q9child == q101), over(survey)

*Sex of selected sick children in households per survey
svy: tab q103 survey if (q7child == q101 | q8child == q101 | q9child == q101), col

tab q104

drop if q104 < 2 | (q104 > 59 & q104 <98)

*Generate an age category vfbable (current age variable is continuous)
recode q104 2/11=1 12/23=2 24/35=3 36/47=4 48/59=5 98/99=.,gen (ch_agecat)
lab define ch_agecat 1 "2-11 months" 2 "12-23 months" 3 "24-35 months" 4 "36-47 months" 5 "48-59 months", modify
lab val ch_agecat ch_agecat

*Calc age categories for selected sick children by survey
svy: tab ch_agecat survey if (q7child == q101 | q8child == q101 | q9child == q101), col ci pear obs

*Calc number of children with fever included, by survey
tab q8child survey if q8child == q101, col

*Calc number of children with diarrhea included, by survey
tab q7child survey if q7child == q101, col

*Calc number of children with fast breathing included, by survey
tab q9child survey if q9child == q101, col

*Calc total number of selected sick children, by survey
tab survey if (q7child == q101 | q8child == q101 | q9child == q101)

*Determine the roster line number of the selected children
tab q109ch
tab q110ch
tab q111ch

keep survey hhid q109ch-q111cg q101-q108 no totchild
reshape wide q101-q108, i(survey hhid) j(no)

*Pull sex of selected children from roster data
*Age and sex information from roster file with total number of children under 5
***Sex of selected child with fever
gen f_sex = .
replace f_sex = q1031 if q109ch==1
replace f_sex = q1032 if q109ch==2
replace f_sex = q1033 if q109ch==3
replace f_sex = q1034 if q109ch==4
replace f_sex = q1035 if q109ch==5
replace f_sex = q1036 if q109ch==6
replace f_sex = q1037 if q109ch==7
replace f_sex = q1038 if q109ch==8
replace f_sex = q1039 if q109ch==18
*tab f_sex
lab var f_sex "Sex of selected child with fever"
lab define sex 1 "male" 2 "female"
lab val f_sex sex

***Sex of selected child with diarrhea
gen d_sex = .
replace d_sex = q1031 if q110ch==1
replace d_sex = q1032 if q110ch==2
replace d_sex = q1033 if q110ch==3
replace d_sex = q1034 if q110ch==4
replace d_sex = q1035 if q110ch==5
replace d_sex = q1036 if q110ch==6
replace d_sex = q1037 if q110ch==7
replace d_sex = q1038 if q110ch==8
replace d_sex = q1039 if q110ch==9
*tab d_sex
lab var d_sex "Sex of selected child with diarrhea"
lab val d_sex sex

***Sex of selected child with fast breathing
gen fb_sex = .
replace fb_sex = q1031 if q111ch==1
replace fb_sex = q1032 if q111ch==2
replace fb_sex = q1033 if q111ch==3
replace fb_sex = q1034 if q111ch==4
replace fb_sex = q1035 if q111ch==5
replace fb_sex = q1036 if q111ch==6
replace fb_sex = q1037 if q111ch==7
replace fb_sex = q1038 if q111ch==8
replace fb_sex = q1039 if q111ch==12
*tab fb_sex
lab var fb_sex "Sex of selected child with cough and fast/difficult breathing"
lab val fb_sex sex

*Pull age of selected children from roster data
***Age of selected child with fever
gen f_age = .
replace f_age = q1041 if q109ch==1
replace f_age = q1042 if q109ch==2
replace f_age = q1043 if q109ch==3
replace f_age = q1044 if q109ch==4
replace f_age = q1045 if q109ch==5
replace f_age = q1046 if q109ch==6
replace f_age = q1047 if q109ch==7
replace f_age = q1048 if q109ch==8
replace f_age = q1049 if q109ch==18
*tab f_age
lab var f_age "Age (months) of selected child with fever"

***Age of selected child with diarhhea
gen d_age = .
replace d_age = q1041 if q110ch==1
replace d_age = q1042 if q110ch==2
replace d_age = q1043 if q110ch==3
replace d_age = q1044 if q110ch==4
replace d_age = q1045 if q109ch==5
replace d_age = q1046 if q109ch==6
replace d_age = q1047 if q109ch==7
replace d_age = q1048 if q109ch==8
replace d_age = q1049 if q109ch==9
*tab d_age
lab var d_age "Age (months) of selected child with diarrhea"

***Age of selected child with fast breathing
gen fb_age = .
replace fb_age = q1041 if q111ch==1
replace fb_age = q1042 if q111ch==2
replace fb_age = q1043 if q111ch==3
replace fb_age = q1044 if q111ch==4
replace fb_age = q1045 if q111ch==5
replace fb_age = q1046 if q111ch==6
replace fb_age = q1047 if q111ch==7
replace fb_age = q1048 if q111ch==8
replace fb_age = q1049 if q111ch==12
*tab fb_age
lab var fb_age "Age (months) of selected child with cough and fast/difficult breathing"

preserve
keep survey hhid totchild-fb_age
save "sex_age_selected_children.dta", replace
restore
reshape long
drop if q101 == .
save "all_children.dta", replace

use "BL EL cg_hh_combined.dta", clear
merge m:1 hhid survey using "sex_age_selected_children.dta", keepusing(totchild-fb_age)
*1231 matched, 0 master only, 1 using only
drop if _merge != 3
drop _merge

*Save master file by cargeiver with household and child information for analysis
save "Niger State_complete_BL_EL.dta", replace

*Determine the number of households with multiple caregivers of selected sick children in surveys
duplicates report survey hhid

*List the survey and household id for the households with multiple cargeivers
duplicates list survey hhid

*Remove sex,fever & total illness info from records in which household has multiple caregivers but record is not for child with that illness
replace fb_sex =. if q9child ==.
replace fb_age =. if q9child ==.
*replace fb_totillness =. if q9child ==.
replace f_sex =. if q8child ==.
replace f_age =. if q8child ==.
*replace fev_totillness =. if q8child ==.
replace d_sex =. if q7child ==.
replace d_age =. if q7child ==.
*replace dia_totillness =. if q7child ==.

*Save master file by cargeiver with household and child information for analysis
save "Niger State_complete_BL_EL.dta" ,replace


