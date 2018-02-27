***************************************
***************************************
* Export Niger results to Excel      *
* Kirsten Zalisk                      *
* February 2017                         *
***************************************
***************************************

*File was last updated on April 5, 2017 and does reflect any additions to the indicators calculated after that date

cd "C:\Users\26167\Documents\WHO RAcE\Endline household survey\Niger\Combined"

set more off
*Binary variables with cluster specified
***Caregiver file
use "caregiver_analysis", clear
svyset codevil
putexcel set "Niger results.xlsx", sheet("cg_binary") modify

putexcel A1=("variable") B1=("BL % (CI)") E1=("EL % (CI)") H1=("p") I1=("BL N") J1=("EL N")
local row = 2

foreach x of varlist chw_know cgcurknow2 chwtrusted chwquality chwconvenient  ///
              cgdsknow2 cgdsknow3 malaria_get malaria_fev_sign malaria_signs2 /// 
			  malaria_rx dm_income_joint dm_health_joint q404 chwalwaysavail {
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

	putexcel A`row'=("`x'") B`row'=(`x'_bl_per) C`row'=(`x'_bl_lb) D`row'=(`x'_bl_ub) ///
	         E`row'=(`x'_el_per) F`row'=(`x'_el_lb) G`row'=(`x'_el_ub) H`row'=(`x'_p) ///
			 I`row'=(`x'_bl_n) J`row'=(`x'_el_n)
			 				 
	local row = `row' + 1
}

*Sick child file
use "illness_analysis", clear
svyset codevil

putexcel set "Niger results.xlsx", sheet("illness_binary") modify

putexcel A1=("variable") B1=("BL % (CI)") E1=("EL % (CI)") H1=("p") I1=("BL N") J1=("EL N")
local row = 2
foreach x of varlist all_cont_fluids f_cont_fluids fb_cont_fluids all_cont_feed d_cont_feed ///
			  fb_cont_feed q703 q803 q903 all_app_prov f_app_prov d_app_prov fb_app_prov ///
			  all_joint f_joint d_joint fb_joint all_app_joint f_app_joint d_app_joint fb_app_joint ///
			  f_chw d_chw fb_chw all_chwfirst f_chwfirst d_chwfirst fb_chwfirst ///
			  all_chwfirst_anycare f_chwfirst_anycare d_chwfirst_anycare fb_chwfirst_anycare ///
			  all_correct_rx d_orszinc f_actc24 fb_flab all_correct_rxchw d_orszincchw ///
			  f_actc24chw fb_flabchw fb_flabchw fb_flabchw ///
			  f_bloodtaken f_gotresult f_result f_bloodtakenchw ///
			  fb_assessed all_nocare f_nocare d_nocare ///
			  fb_nocare all_nocarechw f_nocarechw d_nocarechw fb_nocarechw ///
			  d_ors d_zinc q721A-q721X f_antim f_antimc f_act f_act_am f_act24 ///
			  f_actc f_actc2 f_actc24 f_actchw f_actcchw f_actc24chw f_actneg ///
			  f_noactc f_noactnoc f_actnotest fb_rxany fb_ab d_cont_fluids f_cont_feed ///
			  fb_abany q105 q106 q107 q108 all_ascfirst f_ascfirst d_ascfirst fb_ascfirst ///
			  all_ascfirst_anycare f_ascfirst_anycare d_ascfirst_anycare fb_ascfirst_anycare ///
			  all_correct_rxoth f_actoth f_act24oth f_actcoth f_actc24oth d_orszincoth fb_flaboth ///
			  all_correct_rxasc f_actasc f_act24asc f_actcasc f_actc24asc d_orszincasc fb_flabasc ///
			  f_actchw_2 f_act24chw_2 f_act24chw {
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

	putexcel A`row'=("`x'") B`row'=(`x'_bl_per) C`row'=(`x'_bl_lb) D`row'=(`x'_bl_ub) ///
	         E`row'=(`x'_el_per) F`row'=(`x'_el_lb) G`row'=(`x'_el_ub) H`row'=(`x'_p) ///
			 I`row'=(`x'_bl_n) J`row'=(`x'_el_n)
    
	local row = `row' + 1
}

*Binary variable that are only available at endline
***Sick child file
use "illness_analysis", clear
svyset codevil

putexcel set "Niger results.xlsx", sheet("endline_only") modify

putexcel A1=("variable") B1=("EL % (CI)") E1=("EL N")
local row = 2

foreach x of varlist d_orszincchw2 fb_flabchw2 all_firstdose f_act_chwp d_ors_chwp ///
				d_zinc_chwp d_bothfirstdose fb_flab_chwp all_counsel f_act_chwc ///
				d_ors_chwc d_zinc_chwc d_bothcounsel fb_flab_chwc all_referadhere ///
				f_referadhere d_referadhere fb_referadhere all_followup f_chw_fu ///
				d_chw_fu fb_chw_fu f_gotresultchw f_resultchw fb_assessedchw d_hmfl ///
				all_noadhere_* q727a-q727z q825a-q825z q922a-q922z  f_actc24chw2 ///
				all_correct_rxchw2 all_chwrefer f_chwrefer d_chwrefer fb_chwrefer {
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


*Categorical variables - Caregiver file
use "caregiver_analysis", clear
svyset codevil

putexcel set "Niger results.xlsx", sheet("cg_categorical") modify

putexcel A1=("variable") B1=("category") C1=("BL % (CI)") F1=("EL % (CI)") I1=("p") J1=("BL N") K1=("EL N")
local row = 2

foreach x of varlist q401 distcat transport dm_income dm_health timecat cagecat cgeduccat {

  if "`x'" == "q401" | "`x'" == "transport" {
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

  if "`x'" == "cagecat" | "`x'" == "cgeduccat" | "`x'" == "dm_income" | "`x'" == "dm_health" | ///
	 "`x'" == "distcat" {
	qui: tab `x' survey, matcell(x)
	scalar `x'_bl_n = x[1,1] + x[2,1] + x[3,1] + x[4,1]
	scalar `x'_el_n = x[1,2] + x[2,2] + x[3,2] + x[4,2]
  }
  if "`x'" == "cagecat" | "`x'" == "cgeduccat" | "`x'" == "dm_income" | "`x'" == "dm_health" | ///
	 "`x'" == "timecat" | "`x'" == "distcat" {    
	scalar `x'4_bl_per = a[1,7]*100
	scalar `x'4_bl_lb = a[5,7]*100
	scalar `x'4_bl_ub = a[6,7]*100
	scalar `x'4_el_per = a[1,8]*100
	scalar `x'4_el_lb = a[5,8]*100
	scalar `x'4_el_ub = a[6,8]*100
	}
  if "`x'" == "timecat" {
	qui: tab `x' survey, matcell(x)
	scalar `x'_bl_n = x[1,1] + x[2,1] + x[3,1] + x[4,1] + x[5,1]
	scalar `x'_el_n = x[1,2] + x[2,2] + x[3,2] + x[4,2] + x[5,2]
    
	scalar `x'5_bl_per = a[1,9]*100
	scalar `x'5_bl_lb = a[5,9]*100
	scalar `x'5_bl_ub = a[6,9]*100
	scalar `x'5_el_per = a[1,10]*100
	scalar `x'5_el_lb = a[5,10]*100
	scalar `x'5_el_ub = a[6,10]*100
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
	
  if "`x'" == "cagecat" | "`x'" == "cgeduccat" | "`x'" == "dm_income" | "`x'" == "dm_health" | ///
	 "`x'" == "timecat" | "`x'" == "distcat" {
    putexcel B`row'=("Cat4") C`row'=(`x'4_bl_per) D`row'=(`x'4_bl_lb) ///
	         E`row'=(`x'4_bl_ub) F`row'=(`x'4_el_per) G`row'=(`x'4_el_lb) H`row'=(`x'4_el_ub) 
    local row = `row' + 1
  }
  if "`x'" == "timecat" {
	putexcel B`row'=("Cat5") C`row'=(`x'5_bl_per) D`row'=(`x'5_bl_lb) ///
	         E`row'=(`x'5_bl_ub) F`row'=(`x'5_el_per) G`row'=(`x'5_el_lb) H`row'=(`x'5_el_ub) 
	local row = `row' + 1
  }
}
use "illness_analysis", clear
svyset codevil

putexcel set "Niger results.xlsx", sheet("child_cat_ass") modify

putexcel A1=("variable") B1=("category") C1=("BL % (CI)") F1=("EL % (CI)") I1=("p") J1=("BL N") K1=("EL N")
local row = 2

foreach x of varlist q810 q910 agecat {

  if "`x'" == "q910" | "`x'" == "agecat"{
	qui: tab `x' survey, matcell(x)
	scalar `x'_bl_n = x[1,1] + x[2,1] + x[3,1] + x[4,1] + x[5,1]
	scalar `x'_el_n = x[1,2] + x[2,2] + x[3,2] + x[4,2] + x[5,2]
  }
  if "`x'" == "q810" {
	qui: tab `x' survey, matcell(x)
	scalar `x'_bl_n = x[1,1] + x[2,1] + x[3,1] + x[4,1] + x[5,1] + x[6,1]
	scalar `x'_el_n = x[1,2] + x[2,2] + x[3,2] + x[4,2] + x[5,2] + x[6,2]
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
	
  if "`x'" == "q810" {
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

    putexcel B`row'=("Cat4") C`row'=(`x'4_bl_per) D`row'=(`x'4_bl_lb) ///
	         E`row'=(`x'4_bl_ub) F`row'=(`x'4_el_per) G`row'=(`x'4_el_lb) H`row'=(`x'4_el_ub) 
    local row = `row' + 1

  putexcel B`row'=("Cat5") C`row'=(`x'5_bl_per) D`row'=(`x'5_bl_lb) ///
	         E`row'=(`x'5_bl_ub) F`row'=(`x'5_el_per) G`row'=(`x'5_el_lb) H`row'=(`x'5_el_ub) 
	local row = `row' + 1
  
  if "`x'" == "q810" {
	putexcel B`row'=("Cat6") C`row'=(`x'6_bl_per) D`row'=(`x'6_bl_lb) ///
	         E`row'=(`x'6_bl_ub) F`row'=(`x'6_el_per) G`row'=(`x'6_el_lb) H`row'=(`x'6_el_ub) 
	local row = `row' + 1
  }
}

*Categorical variables - sick child file ENDLINE ONLY
use "illness_analysis", clear
svyset codevil

putexcel set "Niger results.xlsx", sheet("child_categorical") modify

putexcel A1=("variable") B1=("category") C1=("BL % (CI)")
local row = 2

foreach x of varlist all_when_fu f_when_fu d_when_fu fb_when_fu {
	if "`x'" == "d_when_fu" { 
	  qui: tab `x' survey, matcell(x)
	  scalar `x'_el_n = x[1,1] + x[2,1] + x[3,1] + x[4,1]
	}
	if "`x'" == "f_when_fu" | "`x'" == "fb_when_fu" | "`x'" == "all_when_fu" { 
	  qui: tab `x' survey, matcell(x)
	  scalar `x'_el_n = x[1,1] + x[2,1] + x[3,1] + x[4,1] + x[5,1] 
	}
	qui svy: prop `x', over(survey) 
	mat a = r(table)
	scalar `x'1_el_per = a[1,1]*100
	scalar `x'1_el_lb = a[5,1]*100
	scalar `x'1_el_ub = a[6,1]*100

	scalar `x'2_el_per = a[1,2]*100
	scalar `x'2_el_lb = a[5,2]*100
	scalar `x'2_el_ub = a[6,2]*100

	scalar `x'3_el_per = a[1,3]*100
	scalar `x'3_el_lb = a[5,3]*100
	scalar `x'3_el_ub = a[6,3]*100

	scalar `x'4_el_per = a[1,4]*100
	scalar `x'4_el_lb = a[5,4]*100
	scalar `x'4_el_ub = a[6,4]*100

  if "`x'" == "f_when_fu" | "`x'" == "fb_when_fu" | "`x'" == "all_when_fu" { 
	scalar `x'5_el_per = a[1,5]*100
	scalar `x'5_el_lb = a[5,5]*100
	scalar `x'5_el_ub = a[6,5]*100
  }
	
	putexcel A`row'=("`x'") B`row'=("Cat1") C`row'=(`x'1_el_per) D`row'=(`x'1_el_lb) ///
	         E`row'=(`x'1_el_ub) F`row'=(`x'_el_n) 
	local row = `row' + 1
	
	putexcel B`row'=("Cat2") C`row'=(`x'2_el_per) D`row'=(`x'2_el_lb) ///
	         E`row'=(`x'2_el_ub) 
	local row = `row' + 1
	
	putexcel B`row'=("Cat3") C`row'=(`x'3_el_per) D`row'=(`x'3_el_lb) ///
	         E`row'=(`x'3_el_ub)  
	local row = `row' + 1

	putexcel B`row'=("Cat4") C`row'=(`x'4_el_per) D`row'=(`x'4_el_lb) ///
	         E`row'=(`x'4_el_ub)  
	local row = `row' + 1

  if "`x'" == "f_when_fu" | "`x'" == "fb_when_fu" | "`x'" == "all_when_fu" { 
	putexcel B`row'=("Cat5") C`row'=(`x'5_el_per) D`row'=(`x'5_el_lb) ///
	         E`row'=(`x'5_el_ub) 
	local row = `row' + 1
  }
}

*Variables that allow for multiple reponses - Sick child file
use "illness_analysis", clear
svyset codevil

putexcel set "Niger results.xlsx", sheet("child_multiple") modify

putexcel A1=("variable") B1=("BL % (CI)") E1=("EL % (CI)") H1=("BL N") I1=("EL N")
local row = 2

foreach x of varlist all_cs_* f_cs_* d_cs_* fb_cs_* all_fcs_* f_fcs_* d_fcs_* fb_fcs_* ///
				     q814A-q814Z q912A-q912Z all_rx_* d_ors_public-d_ors_asc ///
					 d_zinc_public-d_zinc_asc f_act_public-f_act_asc fb_flab_public-fb_flab_asc {
 
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

*Variables that allow for multiple reponses - Caregiver file
use "caregiver_analysis", clear
svyset codevil 

putexcel set "Niger results.xlsx", sheet("cg_multiple") modify

putexcel A1=("variable") B1=("BL % (CI)") E1=("EL % (CI)") H1=("BL N") I1=("EL N") 
local row = 2

foreach x of varlist q505A-q505Z q601A-q601Z {
 
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

/*
*Reasons for not careseeking variables that are only available at endline
***Sick child file
use "illness_analysis", clear
svyset codevil

putexcel set "Niger results.xlsx", sheet("no_care_reasons") modify

putexcel A1=("variable") B1=("EL % (CI)") E1=("EL N")
local row = 2

foreach x of varlist q708ca-q708cz q828a-q828z q924aa-q924az q708ba-q708bz q808bA-q808bZ ///
                     q908ba-q908bz all_nocare_* all_nocarechw_* {
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
*/

*Endline only sex-disaggregated results
***Sick child file
use "illness_analysis", clear
svyset codevil

recode survey 2=1 1=0
putexcel set "Niger results.xlsx", sheet("by_sex") modify

putexcel A1=("variable") B1=("Male % (CI)") E1=("Female % (CI)") H1=("p-value") I1=("Male N") J1=("Female N")
local row = 2

foreach x of varlist q703 d_app_prov d_chw d_chwfirst d_cont_fluids d_ors d_zinc ///
                     d_hmfl d_orszinc q803 f_app_prov f_chw f_chwfirst f_bloodtaken ///
					 f_gotresult f_result f_antim f_act f_act24 f_antimc f_actc f_actc24 ///
					 q903 fb_app_prov fb_chw fb_chwfirst fb_assessed fb_abany fb_flab d_cont_feed {
    qui: tab `x' child_sex if survey == 1, matcell(x)
	scalar `x'_male_n = x[1,1] + x[2,1]
    scalar `x'_female_n = x[1,2] + x[2,2]

	qui svy, subpop(survey): prop `x', over(child_sex)
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

***Child characteristics
use "child_chars", clear
svyset codevil

putexcel set "Niger results.xlsx", sheet("child_chars") modify

putexcel A1=("variable") B1=("category") C1=("BL % (CI)") F1=("EL % (CI)") I1=("p") J1=("BL N") K1=("EL N")
local row = 2

foreach x of varlist agecat {

  if "`x'" == "agecat"{
	qui: tab `x' survey, matcell(x)
	scalar `x'_bl_n = x[1,1] + x[2,1] + x[3,1] + x[4,1] + x[5,1]
	scalar `x'_el_n = x[1,2] + x[2,2] + x[3,2] + x[4,2] + x[5,2]
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

    putexcel B`row'=("Cat4") C`row'=(`x'4_bl_per) D`row'=(`x'4_bl_lb) ///
	         E`row'=(`x'4_bl_ub) F`row'=(`x'4_el_per) G`row'=(`x'4_el_lb) H`row'=(`x'4_el_ub) 
    local row = `row' + 1

  putexcel B`row'=("Cat5") C`row'=(`x'5_bl_per) D`row'=(`x'5_bl_lb) ///
	         E`row'=(`x'5_bl_ub) F`row'=(`x'5_el_per) G`row'=(`x'5_el_lb) H`row'=(`x'5_el_ub) 
	local row = `row' + 1
}

local row = 10
foreach x of varlist q103 q105 q106 q107 q108 {
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

	putexcel A`row'=("`x'") C`row'=(`x'_bl_per) D`row'=(`x'_bl_lb) E`row'=(`x'_bl_ub) ///
	         F`row'=(`x'_el_per) G`row'=(`x'_el_lb) H`row'=(`x'_el_ub) I`row'=(`x'_p) ///
			 J`row'=(`x'_bl_n) K`row'=(`x'_el_n)
    
	local row = `row' + 1
}
