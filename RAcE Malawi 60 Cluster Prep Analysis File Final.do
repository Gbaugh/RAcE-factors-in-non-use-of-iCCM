*************************************
* MALAWI ENDLINE HH SURVEY ANALYSIS *
* Master file prep                  *
* By: Kirsten Zalisk                *
* October 2016                      *
*************************************


******************************************
******************************************
** Create unique IDs for each HH record **
******************************************
******************************************

***BASELINE
cd "C:\Users\26167\Documents\WHO RAcE\Malawi\Endline Survey\Survey Data\Sick Child\Race Childillness Data\Baseline data"

***create unique identifiers for the BL data files to be able to merge into one master file
*BL CAREGIVER FILE
use cg1,clear
gen survey=1 
gen clust=string(hhclust,"%02.0f")
gen hh=string(hhnumber,"%02.0f")
egen hhid=concat(clust hh)
egen cgid=concat(hhid cgnumber)
drop clust hh
destring hhid,replace
destring cgid,replace
save cg1_mergeready,replace

*BL ASSETS FILE
use assets1,clear
gen survey=1
gen clust=string(hhclust,"%02.0f")
gen hh=string(hhnumber,"%02.0f")
egen hhid=concat(clust hh)
egen cgid_assets=concat(hhid cgnumber)
drop clust hh
destring hhid,replace
destring cgid_assets,replace
save assets1_mergeready,replace

*BL ROSTER FILE
use roster1,clear
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
replace hhresult = 7 if hhid == 5404
destring cid,replace
save roster1_mergeready,replace

*BL HOUSEHOLD FILE
use hh1,clear
gen survey=1
gen clust=string(hhclust,"%02.0f")
gen hh=string(hhnumber,"%02.0f")
egen hhid=concat(clust hh)
drop clust hh
destring hhid,replace
***custom line for Malawi
replace hhresult=7 if hhid==5404
save hh1_mergeready, replace

***ENDLINE
cd "C:\Users\26167\Documents\WHO RAcE\Malawi\Endline Survey\Survey Data\Sick Child\Race Childillness Data"	

*EL CAREGIVER FILE
use cg,clear
***custom line for Malawi
rename q105c q805c
gen survey=2
gen clust=string(hhclust,"%02.0f")
gen hh=string(hhnumber,"%02.0f")
egen hhid=concat(clust hh)
egen cgid=concat(hhid cgnumber)
drop clust hh
destring cgid,replace
destring hhid,replace
save cg_mergeready,replace

*EL ASSETS FILE
use assets,clear
gen survey=2
gen clust=string(hhclust,"%02.0f")
gen hh=string(hhnumber,"%02.0f")
egen hhid=concat(clust hh)
egen cgid_assets=concat(hhid cgnumber)
drop clust hh 
destring hhid,replace
destring cgid_assets,replace
save assets_mergeready,replace

*EL ROSTER FILE
use roster,clear
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
save roster_mergeready,replace

*EL HOUSEHOLD FILE
use hh,clear
gen survey=2
gen clust=string(hhclust,"%02.0f")
gen hh=string(hhnumber,"%02.0f")
egen hhid=concat(clust hh)
drop clust hh
destring hhid,replace
save hh_mergeready,replace

*********************************
*********************************
** Append and merge data files **
*********************************
*********************************

*Append BL & EL household files
use hh_mergeready, clear
append using "C:\Users\26167\Documents\WHO RAcE\Malawi\Endline Survey\Survey Data\Sick Child\Race Childillness Data\Baseline data\hh1_mergeready"
save hh_combined,replace

*Append BL & EL roster files
use roster_mergeready, clear
append using "C:\Users\26167\Documents\WHO RAcE\Malawi\Endline Survey\Survey Data\Sick Child\Race Childillness Data\Baseline data\roster1_mergeready"
*Create a variable that links caregiver # to each child
gen cgnumber = q109cg if q109cg !=. & q109ch == q101
replace cgnumber = q110cg if q110cg !=. & q110ch == q101
replace cgnumber = q111cg if q111cg !=. & q111ch == q101
save roster_combined,replace

*Append BL & EL asset files
use assets_mergeready, clear
append using "C:\Users\26167\Documents\WHO RAcE\Malawi\Endline Survey\Survey Data\Sick Child\Race Childillness Data\Baseline data\assets1_mergeready"
save assets_combined,replace

*Append BL & EL caregiver files
use cg_mergeready, clear
append using "C:\Users\26167\Documents\WHO RAcE\Malawi\Endline Survey\Survey Data\Sick Child\Race Childillness Data\Baseline data\cg1_mergeready"
save cg_combined,replace

*Merge master household and caregiver files
use hh_combined, clear
merge 1:m survey hhid using "C:\Users\26167\Documents\WHO RAcE\Malawi\Endline Survey\Survey Data\Sick Child\Race Childillness Data\cg_combined.dta"
drop _merge
drop if hhresult != 1
save cg_combined_hh, replace

*Merge master household and asset files
use hh_combined, clear
merge m:m hhid survey using "C:\Users\26167\Documents\WHO RAcE\Malawi\Endline Survey\Survey Data\Sick Child\Race Childillness Data\assets_combined.dta"
drop _merge
drop if hhresult != 1
save assets_combined_hh, replace

*Pull age and sex information for sick child included in survey from master roster file
*Pull total number of children under 5 from roster file as well
*Determine total number of illnesses each child has (0-3)
use cg_combined_hh, clear
merge 1:m survey hhid cgnumber using "C:\Users\26167\Documents\WHO RAcE\Malawi\Endline Survey\Survey Data\Sick Child\Race Childillness Data\all_children 21OCT.dta"
drop _merge
drop if hhresult != 1
save cg_combined_hh_rosterFEB2, replace

**************************Selected sick child information*******************************
use cg_combined_hh_rosterFEB2, clear
sort survey hhid q101
bysort survey hhid: gen no=_n
bysort survey hhid: gen totchild=_N
egen totill = anycount(q105 q106 q107a), values(1)

*Total number of children in households per survey, by number of illnesses
tab totill survey, col

*Total number & proportion of selected sick children per survey, by number of illnesses
tab totill survey if (q7child == q101 | q8child == q101 | q9child == q101), col
svyset hhclust 
svy: tab totill survey if (q7child == q101 | q8child == q101 | q9child == q101), col ci pear

*Average number of illnesses per selected sick children per survey
svy: mean totill if (q7child == q101 | q8child == q101 | q9child == q101), over(survey)

*Sex of selected sick children in households per survey
svy: tab q103 survey if (q7child == q101 | q8child == q101 | q9child == q101), col

*Generate an age category vfbable (current age variable is continuous)
recode q104a min/11=1 12/23=2 24/35=3 36/47=4 48/60=5 98/99=.,gen (ch_agecat)
lab define ch_agecat 1 "<12 months" 2 "12-23 months" 3 "24-35 months" 4 "36-47 months" 5 "48-59 months"
lab val ch_agecat ch_agecat 

*Calc age categories for selected sick children by survey
svy: tab ch_agecat survey if (q7child == q101 | q8child == q101 | q9child == q101), col ci pear

*Calc number of selected children with fever, by survey
svy: tab q105 survey if q8child == q101 | q7child == q101 | q9child == q101, col ci

*Calc number of selected children with diarrhea, by survey
svy: tab q106 survey if q8child == q101 | q7child == q101 | q9child == q101, col

*Calc number of selected children with fast breathing, by survey
replace q107a = 2 if q107a ==.
svy: tab q107a survey if q8child == q101 | q7child == q101 | q9child == q101, col

*Calc number of children with fever included, by survey
tab q8child survey if q8child == q101, col

*Calc number of children with diarrhea included, by survey
tab q7child survey if q7child == q101, col

*Calc number of children with fast breathing included, by survey
tab q9child survey if q9child == q101, col

*Calc total number of selected sick children, by survey
gen tot_children = 0
replace tot_children = 1 if q109ch >= 1 & q109ch !=. & q8child == q101
replace tot_children = tot_children + 1 if q110ch >= 1 & q110ch !=. & q110ch != q109ch & q7child == q101
replace tot_children = tot_children + 1 if q111ch >= 1 & q111ch !=. & q111ch != q110ch & q111ch != q109ch & q9child == q101
tab tot_children survey

*Determine the roster line number of the selected children
*If more than 3 or 4 code for pulling sex and fever below must be adjusted
tab q109ch
tab q110ch
tab q111ch

keep survey hhid q109ch-q111cg q101-q108 no totchild
reshape wide q101-q108, i(survey hhid) j(no)

*Pull sex of selected children from roster data
*Adjust the line numbers (q109ch, q110ch, q111ch to reflect those in the dataset - may not be the same as for Malawi)
***Sex of selected child with fever
gen f_sex = .
replace f_sex = q1031 if q109ch==1
replace f_sex = q1032 if q109ch==2
replace f_sex = q1033 if q109ch==3
replace f_sex = q1034 if q109ch==4
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
*tab d_sex
lab var d_sex "Sex of selected child with diarrhea"
lab val d_sex sex

***Sex of selected child with fast breathing
gen fb_sex = .
replace fb_sex = q1031 if q111ch==1
replace fb_sex = q1032 if q111ch==2
replace fb_sex = q1033 if q111ch==3
*tab fb_sex
lab var fb_sex "Sex of selected child with cough and fast/difficult breathing"
lab val fb_sex sex

*Pull age of selected children from roster data
***Age of selected child with fever
gen f_age = .
replace f_age = q104a1 if q109ch==1
replace f_age = q104a2 if q109ch==2
replace f_age = q104a3 if q109ch==3
replace f_age = q104a4 if q109ch==4
*tab f_age
lab var f_age "Age (months) of selected child with fever"

***Age of selected child with diarhhea
gen d_age = .
replace d_age = q104a1 if q110ch==1
replace d_age = q104a2 if q110ch==2
replace d_age = q104a3 if q110ch==3
replace d_age = q104a4 if q110ch==4
*tab d_age
lab var d_age "Age (months) of selected child with diarrhea"

***Age of selected child with fast breathing
gen fb_age = .
replace fb_age = q104a1 if q111ch==1
replace fb_age = q104a2 if q111ch==2
replace fb_age = q104a3 if q111ch==3
*tab fb_age
lab var fb_age "Age (months) of selected child with cough and fast/difficult breathing"

preserve
keep survey hhid totchild-fb_age
save sex_age_selected_children, replace
restore
reshape long
drop if q101 == .
save all_children, replace

use cg_combined_hh, clear
merge m:1 hhid survey using "sex_age_selected_children.dta", keepusing(totchild-fb_age)
drop _merge

*Save master file by cargeiver with household and child information for analysis
save cg_combined_hh_roster_FINALFEB2,replace

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

*Redefine variable and value labels for q109ch & q111ch because were incorrect
lab define dia_select 0 "No child with diarrhea" 1 "1" 2 "2" 3 "3" 4 "4"
lab values q109ch dia_select
lab var q109ch "Diarrhea: child selected"

lab define fb_select 0 "No child with fast breathing" 1 "1" 2 "2" 3 "3" 4 "4"
lab values q111ch fb_select
lab var q111ch "Fast breathing: child selected"

save cg_combined_hh_roster_FINALFEB2,replace

*Malawi only
merge m:m survey hhclust hhnumber cgnumber  using "endline q605.dta", keepusing(q605string)
drop _merge

save cg_combined_hh_roster_FINALFEB2,replace
