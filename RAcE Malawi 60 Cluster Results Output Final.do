***************************************
***************************************
* Export Malawi results to Excel      *
* Kirsten Zalisk                      *
* Oct 14 2016                         *
***************************************
***************************************

cd "C:\Users\26167\Documents\WHO RAcE\Malawi\Endline Survey\Survey Data\Sick Child\Race Childillness Data"
set more off

use "cg_combined_hh_roster_FINAL60FEB9 post", clear
svyset hhclust

*Binary variables with cluster specified
***Binary child indicators
***could not run f_gotresultchw, f_resultchw, f_act24cchw - only at endline; f_act24p, f_act24pchw - only at baseline
putexcel set "results 2.1.2017.xlsx", sheet("child_binary") modify

putexcel A1=("variable") B1=("BL %") C1=("LB") D1=("UB") E1=("EL %") F1=("LB") G1=("UB") H1=("p") I1=("PP Change") J1=("BL N") K1=("EL N") 
local row = 2

foreach x of varlist d_cont_fluids d_cont_feed f_app_prov d_app_prov fb_app_prov ///
				     f_joint d_joint fb_joint f_chw d_chw fb_chw f_chwfirst ///
					 d_chwfirst fb_chwfirst f_antim f_act f_act24 f_actc f_actp f_acto ///
					 f_antimc f_act24c f_act24o d_ors d_zinc d_orszinc fb_abany ///
					 fb_flab f_actchw f_actcchw f_actpchw f_actochw f_act24ochw d_orschw ///
					 d_zincchw d_orszincchw fb_flabchw f_act_chwp d_ors_chwp d_zinc_chwp ///
					 d_bothfirstdose fb_flab_chwp f_act_chwc d_ors_chwc d_zinc_chwc ///
					 d_bothcounsel fb_flab_chwc f_chwavail d_chwavail fb_chwavail ///
					 f_chwrefer d_chwrefer fb_chwrefer f_referadhere d_referadhere ///
					 fb_referadhere f_chw_fu d_chw_fu fb_chw_fu f_bloodtaken f_gotresult ///
					 f_result f_result f_result f_bloodtakenchw fb_assessed ///
					 fb_assessedchw fb_ab f_nocare d_nocare fb_nocare f_nocarechw ///
					 d_nocarechw fb_nocarechw q703 q803 q903 f_acto f_acto f_actc ///
					 d_chwfirst_anycare f_chwfirst_anycare fb_chwfirst_anycare fb_chwfirst_anycare ///
					 f_bloodtakenchw2 f_gotresultchw2 f_resultchw2 f_act24pchw f_act24p ///
					 f_act_app f_act_appchw f_actneg f_actneg f_noactc f_noactnoc ///
					 f_noactnotest f_act24chw f_noact d_orszincchw2 fb_flabchw2 f_act_appchw2 ///
					 f_app_joint d_app_joint fb_app_joint f_actchw2 f_act24chw2 f_actpchw2 ///
					 f_noactnotestchw fb_flabchw_rr f_actnotest {

	qui: tab `x' survey, matcell(x)
	scalar `x'_bl_n = x[1,1] + x[2,1]
	scalar `x'_el_n = x[1,2] + x[2,2]
			  
	qui svy: prop `x', over(survey) 
	mat a = r(table)
	scalar `x'_bl_per = a[1,3]*100
	scalar `x'_bl_lb = a[5,3]*100
	scalar `x'_bl_ub = a[6,3]*100
	scalar `x'_el_per = a[1,4]*100
	scalar `x'_el_lb = a[5,4]*100
	scalar `x'_el_ub = a[6,4]*100

	qui svy: tab survey `x', col pear
	scalar `x'_p = e(p_Pear)
	
	scalar `x'_change = `x'_el_per - `x'_bl_per

	putexcel A`row'=("`x'") B`row'=(`x'_bl_per) C`row'=(`x'_bl_lb) D`row'=(`x'_bl_ub) ///
	         E`row'=(`x'_el_per) F`row'=(`x'_el_lb) G`row'=(`x'_el_ub) H`row'=(`x'_p) ///
			 I`row'=(`x'_change) J`row'=(`x'_bl_n) K`row'=(`x'_el_n)
				 
	local row = `row' + 1
}

*Binary variables with cluster specified
***Binary caregiver indicators
use "cg_combined_hh_roster_FINAL60FEB9 post", clear
svyset hhclust

putexcel set "results 2.1.2017.xlsx", sheet("cg_binary") modify

putexcel A1=("variable") B1=("BL %") C1=("LB") D1=("UB") E1=("EL %") F1=("LB") G1=("UB") H1=("p") I1=("PP Change") J1=("BL N") K1=("EL N")  
local row = 2

foreach x of varlist chw_know cgcurknow2 chwtrusted chwquality chwalwaysavail ///
					 chwconvenient cgdsknow2 cgdsknow3 malaria_get malaria_fev_sign ///
					 malaria_signs2 malaria_rx chw_loc dm_income_joint dm_health_joint q402 {

	qui: tab `x' survey, matcell(x)
	scalar `x'_bl_n = x[1,1] + x[2,1]
	scalar `x'_el_n = x[1,2] + x[2,2]
			  
	qui svy: prop `x', over(survey) 
	mat a = r(table)
	scalar `x'_bl_per = a[1,3]*100
	scalar `x'_bl_lb = a[5,3]*100
	scalar `x'_bl_ub = a[6,3]*100
	scalar `x'_el_per = a[1,4]*100
	scalar `x'_el_lb = a[5,4]*100
	scalar `x'_el_ub = a[6,4]*100

	qui svy: tab survey `x', col pear
	scalar `x'_p = e(p_Pear)

	scalar `x'_change = `x'_el_per - `x'_bl_per
		
	putexcel A`row'=("`x'") B`row'=(`x'_bl_per) C`row'=(`x'_bl_lb) D`row'=(`x'_bl_ub) ///
	         E`row'=(`x'_el_per) F`row'=(`x'_el_lb) G`row'=(`x'_el_ub) H`row'=(`x'_p) ///
			 I`row'=(`x'_change) J`row'=(`x'_bl_n) K`row'=(`x'_el_n)
				 
	local row = `row' + 1
}

***Categorical variables
use "cg_combined_hh_roster_FINAL60FEB9 post", clear
svyset hhclust

putexcel set "results 2.1.2017.xlsx", sheet("cg_cat") modify

putexcel A1=("variable") B1=("category") C1=("BL %") D1=("LB") E1=("UB") F1=("EL %") ///
         G1=("LB") H1=("UB") I1=("p") J1=("BL N") K1=("EL N")
local row = 2

foreach x of varlist q401 distcat transport cagecat cgeduccat dm_income dm_health ///
                     timecat q729 q827 q924 {
 
 if "`x'" == "q401" | "`x'" == "transport" | "`x'" == "dm_health" {
	qui: tab `x' survey, matcell(x)
	scalar `x'_bl_n = x[1,1] + x[2,1] + x[3,1]
	scalar `x'_el_n = x[1,2] + x[2,2] + x[3,2]
  }
					 
  qui svy: prop `x', over(survey) 
  mat a = r(table)
  scalar `x'1_bl_per = a[1,1]*100
  scalar `x'1_bl_lb = a[5,1]*100
  scalar `x'1_bl_ub = a[6,1]*100
  scalar `x'1_el_per = a[1,2]*100
  scalar `x'1_el_lb = a[5,2]*100
  scalar `x'1_el_ub = a[6,2]*100

  scalar `x'2_bl_per = a[1,3]*100
  scalar `x'2_bl_lb = a[5,3]*100
  scalar `x'2_bl_ub = a[6,3]*100
  scalar `x'2_el_per = a[1,4]*100
  scalar `x'2_el_lb = a[5,4]*100
  scalar `x'2_el_ub = a[6,4]*100

  scalar `x'3_bl_per = a[1,5]*100
  scalar `x'3_bl_lb = a[5,5]*100
  scalar `x'3_bl_ub = a[6,5]*100
  scalar `x'3_el_per = a[1,6]*100
  scalar `x'3_el_lb = a[5,6]*100
  scalar `x'3_el_ub = a[6,6]*100

  if "`x'" == "cagecat" | "`x'" == "cgeduccat" | "`x'" == "dm_income" {
	qui: tab `x' survey, matcell(x)
	scalar `x'_bl_n = x[1,1] + x[2,1] + x[3,1] + x[4,1]
	scalar `x'_el_n = x[1,2] + x[2,2] + x[3,2] + x[4,2]
   }
   if "`x'" == "cagecat" | "`x'" == "cgeduccat" | "`x'" == "distcat" | "`x'" == "dm_income" | ///
	  "`x'" == "timecat" | "`x'" == "q729" | "`x'" == "q827" | "`x'" == "q924" {
    scalar `x'4_bl_per = a[1,7]*100
	scalar `x'4_bl_lb = a[5,7]*100
	scalar `x'4_bl_ub = a[6,7]*100
	scalar `x'4_el_per = a[1,8]*100
	scalar `x'4_el_lb = a[5,8]*100
	scalar `x'4_el_ub = a[6,8]*100
  }
  if "`x'" == "timecat" | "`x'" == "distcat" | "`x'" == "q729"  {
	qui: tab `x' survey, matcell(x)
	scalar `x'_bl_n = x[1,1] + x[2,1] + x[3,1] + x[4,1] + x[5,1]
	scalar `x'_el_n = x[1,2] + x[2,2] + x[3,2] + x[4,2] + x[5,2]
  }
  if "`x'" == "timecat" | "`x'" == "distcat" | "`x'" == "q729" | "`x'" == "q827" | "`x'" == "q924" {
    scalar `x'5_bl_per = a[1,9]*100
	scalar `x'5_bl_lb = a[5,9]*100
	scalar `x'5_bl_ub = a[6,9]*100
	scalar `x'5_el_per = a[1,10]*100
	scalar `x'5_el_lb = a[5,10]*100
	scalar `x'5_el_ub = a[6,10]*100
  }
  
    if "`x'" == "q827" | "`x'" == "q924" {
	qui: tab `x' survey, matcell(x)
	scalar `x'_bl_n = x[1,1] + x[2,1] + x[3,1] + x[4,1] + x[5,1] + x[6,1]
	scalar `x'_el_n = x[1,2] + x[2,2] + x[3,2] + x[4,2] + x[5,2] + x[6,2]
  
    scalar `x'6_bl_per = a[1,11]*100
	scalar `x'6_bl_lb = a[5,11]*100
	scalar `x'6_bl_ub = a[6,11]*100
	scalar `x'6_el_per = a[1,12]*100
	scalar `x'6_el_lb = a[5,12]*100
	scalar `x'6_el_ub = a[6,12]*100
  }
  
  qui svy: tab survey `x', col pear
  scalar `x'_p = e(p_Pear)
	
  putexcel A`row'=("`x'") B`row'=("Cat1") C`row'=(`x'1_bl_per) D`row'=(`x'1_bl_lb) ///
	       E`row'=(`x'1_bl_ub) F`row'=(`x'1_el_per) G`row'=(`x'1_el_lb) H`row'=(`x'1_el_ub) ///
	       I`row'=(`x'_p) J`row'=(`x'_bl_n) K`row'=(`x'_el_n)
  local row = `row' + 1

  putexcel B`row'=("Cat2") C`row'=(`x'2_bl_per) D`row'=(`x'2_bl_lb) ///
	       E`row'=(`x'2_bl_ub) F`row'=(`x'2_el_per) G`row'=(`x'2_el_lb) H`row'=(`x'2_el_ub) 
  local row = `row' + 1
	
  putexcel B`row'=("Cat3") C`row'=(`x'3_bl_per) D`row'=(`x'3_bl_lb) ///
	       E`row'=(`x'3_bl_ub) F`row'=(`x'3_el_per) G`row'=(`x'3_el_lb) H`row'=(`x'3_el_ub)  
  local row = `row' + 1
	
  if "`x'" == "cagecat" | "`x'" == "distcat" | "`x'" == "cgeduccat" | "`x'" == "dm_income" | ///
	 "`x'" == "timecat" | "`x'" == "q729" | "`x'" == "q827" | "`x'" == "q924" {
	putexcel B`row'=("Cat4")  C`row'=(`x'4_bl_per) D`row'=(`x'4_bl_lb) E`row'=(`x'4_bl_ub) /// 
			 F`row'=(`x'4_el_per) G`row'=(`x'4_el_lb) H`row'=(`x'4_el_ub) 
	local row = `row' + 1
  }
  
  if "`x'" == "timecat" | "`x'" == "distcat" | "`x'" == "q729" | "`x'" == "q827" | "`x'" == "q924" {
	putexcel B`row'=("Cat5")  C`row'=(`x'5_bl_per) D`row'=(`x'5_bl_lb) E`row'=(`x'5_bl_ub) F`row'=(`x'5_el_per) ///
			 G`row'=(`x'5_el_lb) H`row'=(`x'5_el_ub) 
	local row = `row' + 1
  }
  if "`x'" == "q827" | "`x'" == "q924" {
	putexcel B`row'=("Cat6")  C`row'=(`x'6_bl_per) D`row'=(`x'6_bl_lb) E`row'=(`x'6_bl_ub) F`row'=(`x'6_el_per) ///
			 G`row'=(`x'6_el_lb) H`row'=(`x'6_el_ub) 
	local row = `row' + 1
  }
}

*Variables that allow for multiple reponses
use "cg_combined_hh_roster_FINAL60FEB9 post", clear
svyset hhclust

putexcel set "results 2.1.2017.xlsx", sheet("multiple") modify

putexcel A1=("variable") B1=("BL % (CI)") E1=("EL % (CI)") H1=("BL N") I1=("EL N")   
local row = 2

foreach x of varlist q505_* q601_* d_cs_* f_fcs_* d_ors_public-d_ors_other d_zinc_public-d_zinc_other ///
					 q721_* q727_* f_cs_* f_fcs_* q809a_* q810_* q814_* f_act_public-f_act_other ///
					 q825_* fb_cs_* fb_fcs_* q909a_* q910_* q912_* fb_flab_public-fb_flab_other q922_* {
					 

  qui: tab `x' survey, matcell(x)
  scalar `x'_bl_n = x[1,1] + x[2,1]
  scalar `x'_el_n = x[1,2] + x[2,2]
	
  qui svy: prop `x', over(survey) 
  mat a = r(table)
  scalar `x'_bl_per = a[1,3]*100
  scalar `x'_bl_lb = a[5,3]*100
  scalar `x'_bl_ub = a[6,3]*100
  scalar `x'_el_per = a[1,4]*100
  scalar `x'_el_lb = a[5,4]*100
  scalar `x'_el_ub = a[6,4]*100
	
  putexcel A`row'=("`x'") B`row'=(`x'_bl_per) C`row'=(`x'_bl_lb) D`row'=(`x'_bl_ub) ///
	       E`row'=(`x'_el_per) F`row'=(`x'_el_lb) G`row'=(`x'_el_ub) ///
		   H`row'=(`x'_bl_n) I`row'=(`x'_el_n)

  local row = `row' + 1
}

*Endline only sex-disaggregated results
use "cg_combined_hh_roster_FINAL60FEB9 post all", clear
svyset hhclust

recode survey 2=1 1=0
gen child_sex = 1 if (d_sex == 1 & set == 1) | (f_sex == 1 & set == 2) | (fb_sex == 1 & set == 3)
replace child_sex = 2 if (d_sex == 2 & set == 1) | (f_sex == 2 & set == 2) | (fb_sex == 2 & set == 3)
putexcel set "results 2.1.2017.xlsx", sheet("by_sex_el") modify

putexcel A1=("variable") B1=("Male % (CI)") E1=("Female % (CI)") H1=("p-value")
local row = 2

foreach x of varlist q703 d_app_prov d_chw d_chwfirst d_cont_fluids d_ors d_zinc ///
                     d_orszinc {
					 
    qui: tab `x' child_sex if survey == 1 & set == 1, matcell(x)
	scalar `x'_male_n = x[1,1] + x[2,1]
    scalar `x'_female_n = x[1,2] + x[2,2]

	qui svy, subpop(survey): prop `x' if set == 1, over(child_sex)
	mat a = r(table)
	scalar `x'_male_per = a[1,3]*100
	scalar `x'_male_lb = a[5,3]*100
	scalar `x'_male_ub = a[6,3]*100
    scalar `x'_female_per = a[1,4]*100
	scalar `x'_female_lb = a[5,4]*100
	scalar `x'_female_ub = a[6,4]*100

	qui svy, subpop(survey): tab child_sex `x', col pear
	scalar `x'_p = e(p_Pear)

	
	putexcel A`row'=("`x'") B`row'=(`x'_male_per) C`row'=(`x'_male_lb) D`row'=(`x'_male_ub) ///
	         E`row'=(`x'_female_per) F`row'=(`x'_female_lb) G`row'=(`x'_female_ub) H`row'=(`x'_p) ///
			 I`row'=(`x'_male_n) J`row'=(`x'_female_n)
				 
	local row = `row' + 1
}

local row = 10
foreach x of varlist q803 f_app_prov f_chw f_chwfirst f_bloodtaken f_gotresult ///
					 f_result f_antim f_act f_act24 f_antimc f_actc f_act24c {
					 
    qui: tab `x' child_sex if survey == 1 & set == 2, matcell(x)
	scalar `x'_male_n = x[1,1] + x[2,1]
    scalar `x'_female_n = x[1,2] + x[2,2]

	qui svy, subpop(survey): prop `x' if set == 2, over(child_sex)
	mat a = r(table)
	scalar `x'_male_per = a[1,3]*100
	scalar `x'_male_lb = a[5,3]*100
	scalar `x'_male_ub = a[6,3]*100
    scalar `x'_female_per = a[1,4]*100
	scalar `x'_female_lb = a[5,4]*100
	scalar `x'_female_ub = a[6,4]*100

	qui svy, subpop(survey): tab child_sex `x', col pear
	scalar `x'_p = e(p_Pear)

	
	putexcel A`row'=("`x'") B`row'=(`x'_male_per) C`row'=(`x'_male_lb) D`row'=(`x'_male_ub) ///
	         E`row'=(`x'_female_per) F`row'=(`x'_female_lb) G`row'=(`x'_female_ub) H`row'=(`x'_p) ///
			 I`row'=(`x'_male_n) J`row'=(`x'_female_n)
				 
	local row = `row' + 1
}

local row = 23
foreach x of varlist q903 fb_app_prov fb_chw fb_chwfirst fb_assessed fb_abany fb_flab  {
					 
    qui: tab `x' child_sex if survey == 1 & set == 3, matcell(x)
	scalar `x'_male_n = x[1,1] + x[2,1]
    scalar `x'_female_n = x[1,2] + x[2,2]

	qui svy, subpop(survey): prop `x' if set == 3, over(child_sex)
	mat a = r(table)
	scalar `x'_male_per = a[1,3]*100
	scalar `x'_male_lb = a[5,3]*100
	scalar `x'_male_ub = a[6,3]*100
    scalar `x'_female_per = a[1,4]*100
	scalar `x'_female_lb = a[5,4]*100
	scalar `x'_female_ub = a[6,4]*100

	qui svy, subpop(survey): tab child_sex `x' if set == 3, col pear
	scalar `x'_p = e(p_Pear)

	
	putexcel A`row'=("`x'") B`row'=(`x'_male_per) C`row'=(`x'_male_lb) D`row'=(`x'_male_ub) ///
	         E`row'=(`x'_female_per) F`row'=(`x'_female_lb) G`row'=(`x'_female_ub) H`row'=(`x'_p) ///
			 I`row'=(`x'_male_n) J`row'=(`x'_female_n)
				 
	local row = `row' + 1
}
*Forgot to include one diarrhea indicator
local row = 30
foreach x of varlist d_cont_feed {
					 
    qui: tab `x' child_sex if survey == 1 & set == 1, matcell(x)
	scalar `x'_male_n = x[1,1] + x[2,1]
    scalar `x'_female_n = x[1,2] + x[2,2]

	qui svy, subpop(survey): prop `x' if set == 1, over(child_sex)
	mat a = r(table)
	scalar `x'_male_per = a[1,3]*100
	scalar `x'_male_lb = a[5,3]*100
	scalar `x'_male_ub = a[6,3]*100
    scalar `x'_female_per = a[1,4]*100
	scalar `x'_female_lb = a[5,4]*100
	scalar `x'_female_ub = a[6,4]*100

	qui svy, subpop(survey): tab child_sex `x', col pear
	scalar `x'_p = e(p_Pear)

	
	putexcel A`row'=("`x'") B`row'=(`x'_male_per) C`row'=(`x'_male_lb) D`row'=(`x'_male_ub) ///
	         E`row'=(`x'_female_per) F`row'=(`x'_female_lb) G`row'=(`x'_female_ub) H`row'=(`x'_p) ///
			 I`row'=(`x'_male_n) J`row'=(`x'_female_n)
				 
	local row = `row' + 1
}

recode survey 0=1 1=2

use "cg_combined_hh_roster_FINAL60FEB9 post", clear
*Reasons for not careseeking variables that are only available at endline
putexcel set "results 2.1.2017.xlsx", sheet("no_care_reasons") modify

putexcel A1=("variable") B1=("EL % (CI)") E1=("EL N")
local row = 20

foreach x of varlist q708c_* q828_* q925_* q708b_* q808b_* q908b_*  f_actnegchw ///
					 f_gotresultchw f_gotresultchw f_resultchw f_actcchw2 f_act24cchw f_noactnocchw ///
					 f_noactcchw f_act24cchw2 {
    qui: tab `x' if survey == 2, matcell(x)
	scalar `x'_el_n = x[1,1] + x[2,1]

	qui svy: prop `x', over(survey) 
	mat a = r(table)
	scalar `x'_el_per = a[1,2]*100
	scalar `x'_el_lb = a[5,2]*100
	scalar `x'_el_ub = a[6,2]*100

	putexcel A`row'=("`x'") B`row'=(`x'_el_per) C`row'=(`x'_el_lb) D`row'=(`x'_el_ub) E`row'=(`x'_el_n)
				 
	local row = `row' + 1
}

*Overall results across all three illnesses
use "cg_combined_hh_roster_FINAL60FEB9 post all2", clear
svyset hhclust

putexcel set "results 2.1.2017.xlsx", sheet("overall") modify

putexcel A1=("variable") B1=("BL %") C1=("LB") D1=("UB") E1=("EL %") F1=("LB") G1=("UB") H1=("p") I1=("PP Change") J1=("BL N") K1=("EL N")
local row = 2

foreach x of varlist all_app_prov-all_followup all_joint-all_rx_store all_rx_other-all_noadhere_f all_noadhere_x ///
                     all_correct_rxc all_correct_rxchwc all_chwfirst_anycare all_correct_rxchw2 all_app_joint all_chwrefer {
	qui: tab `x' survey, matcell(x)
	scalar `x'_bl_n = x[1,1] + x[2,1]
	scalar `x'_el_n = x[1,2] + x[2,2]
	
	qui: prop `x', over(survey) cluster(hhclust)
	mat a = r(table)
	scalar `x'_bl_per = a[1,3]*100
	scalar `x'_bl_lb = a[5,3]*100
	scalar `x'_bl_ub = a[6,3]*100
	scalar `x'_el_per = a[1,4]*100
	scalar `x'_el_lb = a[5,4]*100
	scalar `x'_el_ub = a[6,4]*100

	qui svy: tab survey `x', col pear
	scalar `x'_p = e(p_Pear)
	
	scalar `x'_change = `x'_el_per - `x'_bl_per

	putexcel A`row'=("`x'") B`row'=(`x'_bl_per) C`row'=(`x'_bl_lb) D`row'=(`x'_bl_ub) ///
	         E`row'=(`x'_el_per) F`row'=(`x'_el_lb) G`row'=(`x'_el_ub) H`row'=(`x'_p) ///
			 I`row'=(`x'_change) J`row'=(`x'_bl_n) K`row'=(`x'_el_n)
					
	local row = `row' + 1
}

*Reasons for not careseeking variables that are only available at endline
putexcel set "results 2.1.2017.xlsx", sheet("no_care_reasons") modify

putexcel A1=("variable") B1=("EL % (CI)") E1=("EL N")
local row = 2

foreach x of varlist all_nocare_* all_nocarechw_* {
    qui: tab `x' if survey == 2, matcell(x)
	scalar `x'_el_n = x[1,1] + x[2,1]

	qui svy: prop `x', over(survey) 
	mat a = r(table)
	scalar `x'_el_per = a[1,2]*100
	scalar `x'_el_lb = a[5,2]*100
	scalar `x'_el_ub = a[6,2]*100

	putexcel A`row'=("`x'") B`row'=(`x'_el_per) C`row'=(`x'_el_lb) D`row'=(`x'_el_ub) E`row'=(`x'_el_n)
				 
	local row = `row' + 1
}

*When was follow-up across all three illnesses

putexcel set "results 2.1.2017.xlsx", sheet("all_followup") modify

putexcel A1=("variable") B1=("category") C1=("BL %") D1=("LB") E1=("UB") F1=("EL %") ///
         G1=("LB") H1=("UB") I1=("p") J1=("BL N") K1=("EL N")
local row = 2

foreach x of varlist all_when_fu {
 
  qui: tab `x' survey, matcell(x)
  scalar `x'_bl_n = x[1,1] + x[2,1] + x[3,1] + x[4,1] + x[5,1] + x[6,1]
  scalar `x'_el_n = x[1,2] + x[2,2] + x[3,2] + x[4,2] + x[5,2] + x[6,2]
					 
  qui svy: prop `x', over(survey) 
  mat a = r(table)
  scalar `x'1_bl_per = a[1,1]*100
  scalar `x'1_bl_lb = a[5,1]*100
  scalar `x'1_bl_ub = a[6,1]*100
  scalar `x'1_el_per = a[1,2]*100
  scalar `x'1_el_lb = a[5,2]*100
  scalar `x'1_el_ub = a[6,2]*100

  scalar `x'2_bl_per = a[1,3]*100
  scalar `x'2_bl_lb = a[5,3]*100
  scalar `x'2_bl_ub = a[6,3]*100
  scalar `x'2_el_per = a[1,4]*100
  scalar `x'2_el_lb = a[5,4]*100
  scalar `x'2_el_ub = a[6,4]*100

  scalar `x'3_bl_per = a[1,5]*100
  scalar `x'3_bl_lb = a[5,5]*100
  scalar `x'3_bl_ub = a[6,5]*100
  scalar `x'3_el_per = a[1,6]*100
  scalar `x'3_el_lb = a[5,6]*100
  scalar `x'3_el_ub = a[6,6]*100

  scalar `x'4_bl_per = a[1,7]*100
  scalar `x'4_bl_lb = a[5,7]*100
  scalar `x'4_bl_ub = a[6,7]*100
  scalar `x'4_el_per = a[1,8]*100
  scalar `x'4_el_lb = a[5,8]*100
  scalar `x'4_el_ub = a[6,8]*100
 
  scalar `x'5_bl_per = a[1,9]*100
  scalar `x'5_bl_lb = a[5,9]*100
  scalar `x'5_bl_ub = a[6,9]*100
  scalar `x'5_el_per = a[1,10]*100
  scalar `x'5_el_lb = a[5,10]*100
  scalar `x'5_el_ub = a[6,10]*100
    
  scalar `x'6_bl_per = a[1,11]*100
  scalar `x'6_bl_lb = a[5,11]*100
  scalar `x'6_bl_ub = a[6,11]*100
  scalar `x'6_el_per = a[1,12]*100
  scalar `x'6_el_lb = a[5,12]*100
  scalar `x'6_el_ub = a[6,12]*100
    
  qui svy: tab survey `x', col pear
  scalar `x'_p = e(p_Pear)
	
  putexcel A`row'=("`x'") B`row'=("Cat1") C`row'=(`x'1_bl_per) D`row'=(`x'1_bl_lb) ///
	       E`row'=(`x'1_bl_ub) F`row'=(`x'1_el_per) G`row'=(`x'1_el_lb) H`row'=(`x'1_el_ub) ///
	       I`row'=(`x'_p) J`row'=(`x'_bl_n) K`row'=(`x'_el_n)
  local row = `row' + 1

  putexcel B`row'=("Cat2") C`row'=(`x'2_bl_per) D`row'=(`x'2_bl_lb) ///
	       E`row'=(`x'2_bl_ub) F`row'=(`x'2_el_per) G`row'=(`x'2_el_lb) H`row'=(`x'2_el_ub) 
  local row = `row' + 1
	
  putexcel B`row'=("Cat3") C`row'=(`x'3_bl_per) D`row'=(`x'3_bl_lb) ///
	       E`row'=(`x'3_bl_ub) F`row'=(`x'3_el_per) G`row'=(`x'3_el_lb) H`row'=(`x'3_el_ub)  
  local row = `row' + 1
	
  putexcel B`row'=("Cat4")  C`row'=(`x'4_bl_per) D`row'=(`x'4_bl_lb) E`row'=(`x'4_bl_ub) /// 
	   	   F`row'=(`x'4_el_per) G`row'=(`x'4_el_lb) H`row'=(`x'4_el_ub) 
  local row = `row' + 1

  putexcel B`row'=("Cat5")  C`row'=(`x'5_bl_per) D`row'=(`x'5_bl_lb) E`row'=(`x'5_bl_ub) F`row'=(`x'5_el_per) ///
	       G`row'=(`x'5_el_lb) H`row'=(`x'5_el_ub) 
  local row = `row' + 1
  
  putexcel B`row'=("Cat6")  C`row'=(`x'6_bl_per) D`row'=(`x'6_bl_lb) E`row'=(`x'6_bl_ub) F`row'=(`x'6_el_per) ///
	       G`row'=(`x'6_el_lb) H`row'=(`x'6_el_ub) 
  local row = `row' + 1
}

*Reasons for not careseeking variables that are only available at endline
use "cg_combined_hh_roster_FINAL60FEB9 post", clear
svyset hhclust

putexcel set "results 2.1.2017.xlsx", sheet("no_care_reasons") modify

local row = 20

foreach x of varlist q708c_* q828_* q925_* q708b_* q808b_* q908b_* {
    qui: tab `x' if survey == 2, matcell(x)
	scalar `x'_el_n = x[1,1] + x[2,1]

	qui svy: prop `x', over(survey) 
	mat a = r(table)
	scalar `x'_el_per = a[1,2]*100
	scalar `x'_el_lb = a[5,2]*100
	scalar `x'_el_ub = a[6,2]*100

	putexcel A`row'=("`x'") B`row'=(`x'_el_per) C`row'=(`x'_el_lb) D`row'=(`x'_el_ub) E`row'=(`x'_el_n)
				 
	local row = `row' + 1
}
