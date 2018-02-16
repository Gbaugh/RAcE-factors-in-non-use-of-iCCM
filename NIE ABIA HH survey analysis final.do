*******************************************
* SFH BASELINE/ENDLINE HH SURVEY ANALYSIS *
* Analysis do file			              *
* By: Samantha Herrera                    *
* March 2017                              *
*******************************************

use "cg_combined_hh_roster_post.dta", clear
set more off
svyset hhclust

************Caregiver Characteristics Table************

*Age
svy: tab cagecat survey, col obs
svy: mean q202, over(survey)

*Education
svy: tab cgeduccat survey, col obs

*Marital Status
svy: tab maritalstat survey, col obs

*Partner living with caregiver
svy: tab q402 survey if maritalstat==1, col obs

*****************Nearest Facility Table*****************

*Distance to nearest facility
svy: tab distcat survey, col obs 
svy: mean q501 if (q501~=98 & q501~=99), over(survey)
svy: regress q501 survey

*Mode of Transport
svy: tab transport survey, col obs

*Time to nearest facility
svy: tab timecat survey, col obs
svy: mean q503 if q503 <998, over(survey)

*Time to nearest facility
svy: tab timewalk survey, col obs
svy: mean q503 if q503 <998 & q502 == 1, over(survey)

************Fever Management (by sex) Table for Endline only************

*Sought any advice or treatment
*note 6 missing responses on f_sex
svy: tab q803 f_sex if survey==2, col ci obs

*Sought tx from appropriate provider (includes: hospital, health center, health post, clinic, NGO, CORP, pharmacy and PPMV)
svy: tab f_app_prov f_sex if survey==2, col ci obs

*Sought tx from a CORP
svy: tab f_chw f_sex if survey==2, col ci obs

*Sought tx from a CORP as first choice
svy: tab f_chwfirst f_sex if survey==2, col ci obs

*Given same or more than usual to drink
svy: tab f_cont_fluids f_sex if survey==2, col ci obs

*Given same or more than usual to eat
svy: tab f_cont_feed f_sex if survey==2, col ci obs

*Had blood taken from finger or heel
svy: tab f_bloodtaken f_sex if survey==2, col ci obs

*Fever tx (any antimalarial, ACT, and ACT within 24 hours) - among all fever cases
svy: tab f_antim f_sex if survey==2, col ci obs
svy: tab f_act f_sex if survey==2, col ci obs
svy: tab f_act24 f_sex if survey==2, col ci obs

*Confirmed malaria tx (any antimalarial, ACT, and ACT within 24 hours) - among positive RDT cases only
svy: tab f_antimc f_sex if survey==2, col ci obs
svy: tab f_actc2 f_sex if survey==2, col ci obs
svy: tab f_act24c2 f_sex if survey==2, col ci obs

************Fever Diagnostics (by sex) Table for Endline only************

*Had blood taken from finger or heel
svy: tab f_bloodtaken f_sex if survey==2, col ci obs

*Were given results
svy: tab f_gotresult f_sex if survey==2, col ci obs

*tested positive 
svy: tab f_result f_sex if survey==2, col ci obs


************Diarrhea Management (by sex)*****************

*Sought any advice or treatment
svy: tab q703 d_sex if survey==2, col ci obs

*Sought tx from appropriate provider (includes: includes: hospital, health center, health post, clinic, NGO, CORP, pharmacy and PPMV)
svy: tab d_app_prov d_sex if survey==2, col ci obs

*Sought tx from a CORP
svy: tab d_chw d_sex if survey==2, col ci obs

*Sought tx from a CORP as first choice
svy: tab d_chwfirst d_sex if survey==2, col ci obs

*Given same or more than usual to drink
svy: tab d_cont_fluids d_sex if survey==2, col ci obs

*Given same or more than usual to eat
svy: tab d_cont_feed d_sex if survey==2, col ci obs

*Tx (ORS, home-made fluid, zinc, ORS + zinc)
svy: tab d_ors d_sex if survey==2, col ci obs
svy: tab d_hmfl d_sex if survey==2, col ci obs
svy: tab d_zinc d_sex if survey==2, col ci obs
svy: tab d_orszinc d_sex if survey==2, col ci obs

*****************Cought with Fast or Difficult Breathing (by sex)*****************

*Sought any advice or treatment
svy: tab q903 fb_sex if survey==2, col ci obs

*Sought tx from appropriate provider (includes: hospital, health center, health post, clinic, NGO, CORP, and pharmacy - no PPMV)
svy: tab fb_app_prov fb_sex if survey==2, col ci obs

*Sought tx from a CORP
svy: tab fb_chw fb_sex if survey==2, col ci obs

*Sought tx from a CORP as first choice
svy: tab fb_chwfirst fb_sex if survey==2, col ci obs
*Given same or more than usual to drink
svy: tab fb_cont_fluids fb_sex if survey==2, col ci obs

*Given same or more than usual to eat
svy: tab fb_cont_feed fb_sex if survey==2, col ci obs

*Assessed for rapid breathing
svy: tab fb_assessed fb_sex if survey==2, col ci obs

*Tx (any antibiotic, amoxicillin)
svy: tab fb_abany fb_sex if survey==2, col ci obs
svy: tab fb_flab fb_sex if survey==2, col ci obs

*****************Household decision-making table*****************

*Income and care-seeking decisions 
svy: tab dm_income survey, col ci obs
svy: tab dm_income_joint survey, col ci obs

svy: tab dm_health survey, col ci obs
svy: tab dm_health_joint survey, col ci obs

*****************Caregiver Knowledge Tables*****************

*Knows 2+ and 3+ illness signs
svy: tab cgdsknow2 survey, col ci obs
svy: tab cgdsknow3 survey, col ci obs

*Knows cause of malaria, fevers is sign of malaria, and malaria tx
svy: tab malaria_get survey, col ci obs
svy: tab malaria_fev_sign survey, col ci obs
svy: tab malaria_rx survey, col ci obs

*Knows correct management of diarrhea
svy: tab diarrhea_rx survey, col ci obs

*Knows CORP works in community
svy: tab chw_know survey, col ci obs

*Knows location of CORP
svy: tab chw_loc survey, col ci obs

*Knows role of CORP (2+ curative services)
svy: tab cgcurknow2 survey, col ci obs

*Knows CORP activities
svy: tab q505_a survey, col ci obs /*com mobilization*/
svy: tab q505_b survey, col ci obs /*distribution of llins*/
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

*illness/danger signs noted by cg
svy: tab Q601a survey, col ci obs
svy: tab Q601b survey, col ci obs
svy: tab Q601c survey, col ci obs
svy: tab Q601d survey, col ci obs
svy: tab Q601e survey, col ci obs
svy: tab Q601f survey, col ci obs
svy: tab Q601g survey, col ci obs
svy: tab Q601h survey, col ci obs
svy: tab Q601i survey, col ci obs
svy: tab Q601j survey, col ci obs
svy: tab Q601k survey, col ci obs
svy: tab Q601l survey, col ci obs
svy: tab Q601m survey, col ci obs
svy: tab Q601n survey, col ci obs
svy: tab Q601o survey, col ci obs
svy: tab Q601p survey, col ci obs
svy: tab Q601q survey, col ci obs
svy: tab Q601r survey, col ci obs
svy: tab Q601s survey, col ci obs
svy: tab Q601t survey, col ci obs

*****************Caregiver perceptions*****************

*View CORPs as trusted provider
svy: tab chwtrusted survey, col ci obs

*Believe CORP provides quality services
svy: tab chwquality survey, col ci obs

*Found CORP at first visit (for all instances of care seeking included in survey - use overall dataset for analysis)
svy: tab chwalwaysavail survey, col ci obs

*Cite CORP as convenient source of tx
svy: tab chwconvenient survey, col ci obs

*****************Joint Care-seeking table*****************

*Sought care jointly w/partner (overall, fever, diarrhea, cough w/fast or difficult breathing)
svy: tab f_joint survey, col ci obs
svy: tab d_joint survey, col ci obs
svy: tab fb_joint survey, col ci obs

*Overall dataset
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_joint survey, col ci obs

*****************Continued feeding table*****************

*Continued fluids (overall, fever, diarrhea, cough w/fast or difficult breathing)
use "cg_combined_hh_roster_post.dta", clear
svy: tab f_cont_fluids survey, col ci obs
svy: tab d_cont_fluids survey, col ci obs
svy: tab fb_cont_fluids survey, col ci obs

*Overall dataset
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_cont_fluids survey, col ci obs

*Continued feeding (overall, fever, diarrhea, cough w/fast or difficult breathing)
use "cg_combined_hh_roster_post.dta", clear
svy: tab f_cont_feed survey, col ci obs
svy: tab d_cont_feed survey, col ci obs
svy: tab fb_cont_feed survey, col ci obs

*Overall dataset
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_cont_feed survey, col ci obs

*****************Care-seeking*****************

*Sought care from appropriate provider (overall, fever, diarrhea, cough w/f or db)
use "cg_combined_hh_roster_post.dta", clear
svy: tab f_app_prov survey, col ci obs
svy: tab d_app_prov survey, col ci obs
svy: tab fb_app_prov survey, col ci obs

*overall dataset
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_app_prov survey, col ci obs

*CORP was first source of care (overall, fever, diarrhea, cough w/f or db)
use "cg_combined_hh_roster_post.dta", clear
svy: tab f_chwfirst survey, col ci obs
svy: tab d_chwfirst survey, col ci obs
svy: tab fb_chwfirst survey, col ci obs

*overall dataset
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_chwfirst survey, col ci obs

*CORP was first source of care among those that sought any care (overall, fever, diarrhea, cough w/f or db)
use "cg_combined_hh_roster_post.dta", clear
svy: tab f_chwfirst_anycare survey, col ci obs
svy: tab d_chwfirst_anycare survey, col ci obs
svy: tab fb_chwfirst_anycare survey, col ci obs

*overall dataset
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_chwfirst_anycare survey, col ci obs

***************CS sources table*****************

*Source of care (overall dataset) 
svy: tab all_cs_hosp survey, col ci obs
svy: tab all_cs_hcent survey, col ci obs
svy: tab all_cs_hpost survey, col ci obs
svy: tab all_cs_ngo survey, col ci obs
svy: tab all_cs_clin survey, col ci obs
svy: tab all_cs_chw survey, col ci obs
svy: tab all_cs_trad survey, col ci obs
svy: tab all_cs_ppmv survey, col ci obs
svy: tab all_cs_phar survey, col ci obs
svy: tab all_cs_friend survey, col ci obs
svy: tab all_cs_mark survey, col ci obs
svy: tab all_cs_other survey, col ci obs

*First source of care (overall dataset)
svy: tab all_fcs_hosp survey, col ci obs
svy: tab all_fcs_hcent survey, col ci obs
svy: tab all_fcs_hpost survey, col ci obs
*Removed col - all no's
svy: tab all_fcs_ngo survey, ci obs
svy: tab all_fcs_clin survey, col ci obs
svy: tab all_fcs_chw survey, col ci obs
svy: tab all_fcs_trad survey, col ci obs
svy: tab all_fcs_ppmv survey, col ci obs
svy: tab all_fcs_phar survey, col ci obs
svy: tab all_fcs_friend survey, col ci obs
svy: tab all_fcs_mark survey, col ci obs
svy: tab all_fcs_other survey, col ci obs

***************Assessment tables***************
use "cg_combined_hh_roster_post.dta", clear

***Among all cases
*Child had blood drawn
svy: tab f_bloodtaken survey, col ci obs

*Caregiver received result of blood test
svy: tab f_gotresult survey, col ci obs

*Blood test positive for malaria
svy: tab f_result survey, col ci obs

*Received ACT after positive RDT (among those w/positive blood test)
svy: tab f_actc2 survey, col ci obs

*Respiratory rate assessed
svy: tab fb_assessed survey, col ci obs

***Among cases in which care was sought from a CORP
*Child had blood drawn
svy: tab f_bloodtakenchw survey, col ci obs

*Caregiver received result of blood test
svy: tab f_gotresultchw survey, col ci obs

*Blood test positive for malaria
svy: tab f_resultchw survey, col ci obs

*Received ACT after positive RDT (among those w/positive blood test)
svy: tab f_actcchw2 survey, col ci obs

***Among cases in which care was sought from providers other than CORP
*Respiratory rate assessed
svy: tab fb_assessedoth survey, col ci obs

***Among cases managed by a CORP
*Child had blood drawn
svy: tab f_bloodtakenchw survey, col ci obs

*Caregiver received result of blood test
svy: tab f_gotresultoth survey, col ci obs

*Blood test positive for malaria
svy: tab f_resultoth survey, col ci obs

*Received ACT after positive RDT (among those w/positive blood test)
svy: tab f_actcoth2 survey, col ci obs

*Respiratory rate assessed
svy: tab fb_assessedoth survey, col ci obs

***Location of assessment (RDT and breathing checked)

*blood test
svy: tab q809a_a survey, col ci obs
svy: tab q809a_b survey, col ci obs
svy: tab q809a_c survey, col ci obs
svy: tab q809a_x survey, col ci obs
svy: tab q809a_z survey, col ci obs

*Breathing checked
svy: tab q909a_a survey, col ci obs
svy: tab q909a_b survey, col ci obs
svy: tab q909a_c survey, col ci obs
svy: tab q909a_x survey, col ci obs
svy: tab q909a_z survey, col ci obs

***Provider of assessment (RDT and breathing checked)

*blood test
svy: tab q810_a survey, col ci obs
svy: tab q810_b survey, col ci obs
svy: tab q810_c survey, col ci obs
svy: tab q810_d survey, col ci obs
svy: tab q810_e survey, col ci obs
svy: tab q810_x survey, col ci obs

*Breathing checked
svy: tab q910_a survey, col ci obs
svy: tab q910_b survey, col ci obs
svy: tab q910_c survey, col ci obs
svy: tab q910_d survey, col ci obs
svy: tab q910_e survey, col ci obs
svy: tab q910_x survey, col ci obs

***************Appropriate treatment tables***************

***Among all sick child cases
*Received appropriate treatment - all cases (ACT w/RDT+, ACT within 24 hrs w/RDT+, ORS+zinc, and amoxicillin)
svy: tab f_act24c2 survey, col ci obs
svy: tab d_orszinc survey, col ci obs
svy: tab fb_flab survey, col ci obs

*overall dataset
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_correct_rx survey, col ci obs

*Received appropriate treatment from CORP (ACT w/RDT+, ACT within 24 hrs w/RDT+, ORS+zinc, and amoxicillin)
use "cg_combined_hh_roster_post.dta", clear
svy: tab f_act24cchw survey if f_result==1, col ci obs
svy: tab d_orszincchw survey, col ci obs
svy: tab fb_flabchw survey, col ci obs

*overall dataset
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_correct_rxchw survey, col ci obs

*Received appropriate treatment from provider other than CORP (ACT w/RDT+, ACT within 24 hrs w/RDT+, ORS+zinc, and amoxicillin)
use "cg_combined_hh_roster_post.dta", clear
svy: tab f_act24coth survey if f_result==1, col ci obs
svy: tab d_orszincoth survey, col ci obs
svy: tab fb_flaboth survey, col ci obs

*overall dataset
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_correct_rxoth survey, col ci obs

***Among cases in which care was sought from X
*Received appropriate treatment from CORP among those that sought care from CORP (ACT w/RDT+, ACT within 24 hrs w/RDT+, ORS+zinc, and amoxicillin)
use "cg_combined_hh_roster_post.dta", clear
svy: tab f_act24cchw2 survey, col ci obs
svy: tab d_orszincchw2 survey, col ci obs
svy: tab fb_flabchw2 survey, col ci obs

*overall dataset
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_correct_rxchw2 survey, col ci obs

**Received appropriate treatment from provider other than CORP among those that sought care from other providers (ACT w/RDT+, ACT within 24 hrs w/RDT+, ORS+zinc, and amoxicillin)
use "cg_combined_hh_roster_post.dta", clear
svy: tab f_act24coth2 survey, col ci obs
svy: tab d_orszincoth2 survey, col ci obs
svy: tab fb_flaboth2 survey, col ci obs

*overall dataset
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_correct_rxoth survey, col ci obs

*Diarrhea tx taken (ORS, Zinc, homemade fluid)
use "cg_combined_hh_roster_post.dta", clear
svy: tab d_ors survey, col obs
svy: tab d_zinc survey, col obs
svy: tab d_hmfl survey, col obs

*Other diarrhea tx taken
svy: tab q721_a survey, col obs
svy: tab q721_b survey, col obs
svy: tab q721_c survey, col obs
svy: tab q721_d survey, col obs
svy: tab q721_e survey, col obs
*Removed col - all No's
svy: tab q721_f survey, obs
svy: tab q721_g survey, col obs
svy: tab q721_h survey, col obs
svy: tab q721_i survey, col obs
svy: tab q721_x survey, col obs

*Fever tx take (ACT, quinine, SP/Fansidar, antibiotic drug, aspirin, paracetamol)
svy: tab q814_a survey, col obs
svy: tab q814_b survey, col obs
svy: tab q814_c survey, col obs
svy: tab q814_d survey, col obs
svy: tab q814_e survey, col obs
svy: tab q814_f survey, col obs
svy: tab q814_g survey, col obs
svy: tab q814_x survey, col obs

*Cough w/d or fb (ACT, quinine, SP/Fansidar, amoxicillin, antiobitic injection, aspririn and paracetamol)
svy: tab q912_a survey, col obs
svy: tab q912_b survey, col obs
svy: tab q912_c survey, col obs
svy: tab q912_d survey, col obs
svy: tab q912_e survey, col obs
svy: tab q912_f survey, col obs
svy: tab q912_g survey, col obs
svy: tab q912_x survey, col obs

***************Other treatment tables*******************
*Received treatment (ACT, ACT within 24 hours, ACT w/RDT+, ORS, zinc)
svy: tab f_act survey, col ci obs
svy: tab f_act24 survey, col ci obs
svy: tab f_actc2 survey, col ci obs
svy: tab d_ors survey, col ci obs
svy: tab d_zinc survey, col ci obs

*Received treatment from CHW (ACT, ACT within 24 hours, ACT w/RDT+, ORS, zinc)
svy: tab f_actchw survey if f_result==1, col ci obs
svy: tab f_act24chw survey if f_result==1, col ci obs
svy: tab f_actcchw survey if f_result==1, col ci obs
svy: tab d_orschw survey, col ci obs
svy: tab d_zincchw survey, col ci obs

*Received treatment from provider other than CHW (ACT, ACT within 24 hours, ACT w/RDT+, ORS, zinc)
svy: tab f_actoth survey, col ci obs
svy: tab f_act24oth survey, col ci obs
svy: tab f_actcoth survey, col ci obs
svy: tab d_orsoth survey, col ci obs
svy: tab d_zincoth survey, col ci obs

*Received treatment from CHW, among those who sought care from CHW (ACT, ACT within 24 hours, ACT w/RDT+, ORS, zinc)
svy: tab f_actchw2 survey, col ci obs
svy: tab f_act24chw2 survey, col ci obs
svy: tab f_actcchw2 survey, col ci obs
svy: tab d_orschw2 survey, col ci obs
svy: tab d_zincchw2 survey, col ci obs

*Received treatment from provider other than CHW, among those who sought care from other providers (ACT, ACT within 24 hours, ACT w/RDT+, ORS, zinc)
svy: tab f_actoth2 survey, col ci obs
svy: tab f_act24oth2 survey, col ci obs
svy: tab f_actcoth2 survey, col ci obs
svy: tab d_orsoth2 survey, col ci obs
svy: tab d_zincoth2 survey, col ci obs

***************Source of treatment tables***************

*Malaria (ACT)
svy: tab f_act_hosp survey, col ci obs
svy: tab f_act_hcent survey, col ci obs
svy: tab f_act_hpost survey, col ci obs
*Removed col - all no's
svy: tab f_act_ngo survey, ci obs
svy: tab f_act_clin survey, col ci obs
svy: tab f_act_chw survey, col ci obs
*Removed col - all no's
svy: tab f_act_trad survey, ci obs
svy: tab f_act_ppmv survey, col ci obs
svy: tab f_act_phar survey, col ci obs
svy: tab f_act_friend survey, col ci obs
*Removed col - all no's
svy: tab f_act_mark survey, ci obs
svy: tab f_act_other survey, col ci obs

*Diarrhea (ORS)
svy: tab d_ors_hosp survey, col ci obs
svy: tab d_ors_hcent survey, col ci obs
*Removed col - all no's
svy: tab d_ors_hpost survey, ci obs
*Removed col - all no's
svy: tab d_ors_ngo survey, ci obs
svy: tab d_ors_clin survey, col ci obs
svy: tab d_ors_chw survey, col ci obs
*Removed col - all no's
svy: tab d_ors_trad survey, ci obs
svy: tab d_ors_ppmv survey, col ci obs
svy: tab d_ors_phar survey, col ci obs
svy: tab d_ors_friend survey, col ci obs
svy: tab d_ors_mark survey, col ci obs
svy: tab d_ors_other survey, col ci obs

*Diarrhea (Zinc)
svy: tab d_zinc_hosp survey, col ci obs
svy: tab d_zinc_hcent survey, col ci obs
svy: tab d_zinc_hpost survey, col ci obs
*Removed col - all no's
svy: tab d_zinc_ngo survey, ci obs
*Removed col - all no's
svy: tab d_zinc_clin survey, ci obs
svy: tab d_zinc_chw survey, col ci obs
*Removed col - all no's
svy: tab d_zinc_trad survey, ci obs
svy: tab d_zinc_ppmv survey, col ci obs
svy: tab d_zinc_phar survey, col ci obs
*Removed col - all no's
svy: tab d_zinc_friend survey, ci obs
*Removed col - all no's
svy: tab d_zinc_mark survey, ci obs
svy: tab d_zinc_other survey, col ci obs

*Cough w/d or fb (Amoxicillin)
svy: tab fb_flab_hosp survey, col ci obs
svy: tab fb_flab_hcent survey, col ci obs
svy: tab fb_flab_hpost survey, col ci obs
*Removed col - all no's
svy: tab fb_flab_ngo survey, ci obs
svy: tab fb_flab_clin survey, col ci obs
svy: tab fb_flab_chw survey, col ci obs
*Removed col - all no's
svy: tab fb_flab_trad survey, ci obs
svy: tab fb_flab_ppmv survey, col ci obs
svy: tab fb_flab_phar survey, col ci obs
*Removed col - all no's
svy: tab fb_flab_friend survey, ci obs
*Removed col - all no's
svy: tab fb_flab_mark survey, ci obs
*Removed col - all no's
svy: tab fb_flab_other survey, ci obs

***************CHW First Dose tables***************

*Overall (across all 3 illnesses - ACT, ORS/Zinc, and amoxicillin)
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_firstdose survey, col ci obs

*Individual for each (ACT, ORS, zinc, ORS + zinc, amoxicillin)
use "cg_combined_hh_roster_post.dta", clear
svy: tab f_act_chwp survey, col ci obs
svy: tab d_ors_chwp survey, col ci obs
svy: tab d_zinc_chwp survey, col ci obs
svy: tab d_bothfirstdose survey, col ci obs
svy: tab fb_flab_chwp survey, col ci obs

***************CHW Counsel tables***************

*Overall (across all 3 illnesses - ACT, ORS/Zinc and amoxicillin)
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_counsel survey, col ci obs

*Individual for each (ACT, ORS, zinc, ORS + zinc, amoxicillin)
use "cg_combined_hh_roster_post.dta", clear
svy: tab f_act_chwc survey, col ci obs
svy: tab d_ors_chwc survey, col ci obs
svy: tab d_zinc_chwc survey, col ci obs
svy: tab d_bothcounsel survey, col ci obs
svy: tab fb_flab_chwc survey, col ci obs

***************Referred by CHW tables***************

*Overall (across all 3 illnesses)
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_chwrefer survey, col ci obs

*Individual (fever, diarrhea, and cough w/d or fb)
use "cg_combined_hh_roster_post.dta", clear
svy: tab f_chwrefer survey, col ci obs
svy: tab d_cwhrefer survey, col ci obs
svy: tab fb_cwhrefer survey, col ci obs

***************Referral Adherence tables***************

*Overall (across all 3 illnesses)
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_referadhere survey, col ci obs

*Individual (fever, diarrhea, and cough w/d or fb)
use "cg_combined_hh_roster_post.dta", clear
svy: tab f_referadhere survey, col ci obs
svy: tab d_referadhere survey, col ci obs
svy: tab fb_referadhere survey, col ci obs

*Reason did not comply w/referral (overall across all 3 illnesses)
use "cg_combined_hh_roster_overall_final.dta", clear
*Removed col - all no's
svy: tab all_noadhere_a survey, ci obs //too far
*Removed col - all no's
svy: tab all_noadhere_b survey, ci obs //did not have money
*Removed col - all no's
svy: tab all_noadhere_c survey, ci obs //no transport
svy: tab all_noadhere_d survey, col ci obs //didn't think illness serious
svy: tab all_noadhere_e survey, col ci obs //child improved
*Removed col - all no's
svy: tab all_noadhere_f survey, ci obs //no time to go
*Removed col - all no's
svy: tab all_noadhere_g survey, ci obs //went somewhere else
*Removed col - all no's
svy: tab all_noadhere_h survey, ci obs //didn't have permission
svy: tab all_noadhere_x survey, col ci obs //other
svy: tab all_noadhere_z survey, col ci obs //don't know

***************Follow-up tables***************

*Overall (across all 3 illnesses)
svy: tab all_followup survey, col ci obs

*Individual (fever, diarrhea, and cough w/d or fb)
use "cg_combined_hh_roster_post.dta", clear
svy: tab f_chw_fu survey, col ci obs
svy: tab d_chw_fu survey, col ci obs
svy: tab fb_chw_fu survey, col ci obs

*When follow-up took place (overall, diarrhea, fever and cough w/d or fb)
*Overall (across all 3 illnesses)
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_when_fu survey, col ci obs

*Individual (fever, diarrhea, and cough w/d or fb)
use "cg_combined_hh_roster_post.dta", clear
svy: tab q729 survey if q728==1, col ci obs
svy: tab q827 survey if q826==1, col ci obs
svy: tab q924 survey if q923==1, col ci obs

***************No care seeking tables***************

*Did not seek care (overall and across all 3 illnesses)
*Overall (across all 3 illnesses)
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_nocare survey, col ci obs

*Individual (fever, diarrhea, and cough w/d or fb)
use "cg_combined_hh_roster_post.dta", clear
svy: tab f_nocare survey, col ci obs
svy: tab d_nocare survey, col ci obs
svy: tab fb_nocare survey, col ci obs

*Sought care but not from CORP (overall and across all 3 illnesses)
*Overall (across all 3 illnesses)
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_nocarechw survey, col ci obs

*Individual (fever, diarrhea, and cough w/d or fb)
use "cg_combined_hh_roster_post.dta", clear
svy: tab f_nocarechw survey, col ci obs
svy: tab d_nocarechw survey, col ci obs
svy: tab fb_nocarechw survey, col ci obs

*Reasons did not seek care from a CORP (overall and across all 3 illnesses) - endline only
*Overall (across all 3 illnesses)
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_nocarechw_a //CORP not available
svy: tab all_nocarechw_b //CORP didn't have medicines/supplies
svy: tab all_nocarechw_c //don't trust CORP
svy: tab all_nocarechw_d //thought condition too serious
svy: tab all_nocarechw_e //prefer to go to health center/other provider
svy: tab all_nocarechw_f //CORP too far
svy: tab all_nocarechw_x //other
svy: tab all_nocarechw_z //don't know

*Reason did not seek care (overall and across all 3 illnesses) - endline only
svy: tab all_nocare_a, obs
svy: tab all_nocare_b, obs 
svy: tab all_nocare_c, obs 
svy: tab all_nocare_d, obs 
svy: tab all_nocare_e, obs 
svy: tab all_nocare_f, obs 
svy: tab all_nocare_g, obs
svy: tab all_nocare_x, obs 
svy: tab all_nocare_z, obs 

use "cg_combined_hh_roster_post.dta", clear
*diarrhea
svy: tab q708b_a
svy: tab q708b_b
svy: tab q708b_c
svy: tab q708b_d
svy: tab q708b_e
svy: tab q708b_f
svy: tab q708b_x
svy: tab q708b_z

*fever
svy: tab q808b_a
svy: tab q808b_b
svy: tab q808b_c
svy: tab q808b_d
svy: tab q808b_e
svy: tab q808b_f
svy: tab q808b_x
svy: tab q808b_z

*fb
svy: tab q908b_a
svy: tab q908b_b
svy: tab q908b_c
svy: tab q908b_d
svy: tab q908b_e
svy: tab q908b_f
svy: tab q908b_x
svy: tab q908b_z

***************Key Indicator Table comparing baseline to endline***************

*1. Caregivers aware of CORP in community 
svy: tab chw_know survey, col ci obs

*2. Caregivers know role of CORP in community
svy: tab cgcurknow2 survey, col ci obs

*3. Caregivers who know 2+ signs of child illness
svy: tab cgdsknow2 survey, col ci obs

*4. Caregivers view CORPs as trusted providers
svy: tab chwtrusted survey, col ci obs

*5. Caregivers believe CORPs provide quality services
svy: tab chwquality survey, col ci obs

*6. Caregivers found CORP at first visit (overall dataset)
svy: tab chwalwaysavail survey, col ci obs

*7. Caregivers believe CORP is convenient source of tx
svy: tab chwconvenient survey, col ci obs

*8. Appropriate provider was sought (overall, fever, diarrhea, and cough w/f or db)
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_app_prov survey, col ci obs

use "cg_combined_hh_roster_post.dta", clear
svy: tab f_app_prov survey, col ci obs
svy: tab d_app_prov survey, col ci obs
svy: tab fb_app_prov survey, col ci obs

*9. Child taken to CORP as first source of care (overall, fever, diarrhea, and cough w/f or db)
*Overall (across all 3 illnesses)
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_chwfirst survey, col ci obs

use "cg_combined_hh_roster_post.dta", clear
svy: tab f_chwfirst survey, col ci obs
svy: tab d_chwfirst survey, col ci obs
svy: tab fb_chwfirst survey, col ci obs

*10. Child had finger or heel stick 
svy: tab f_bloodtaken survey, col ci obs

*11. Caregiver received results of RDT
svy: tab f_gotresult survey, col ci obs

*12. Respiratory rate assessed
svy: tab fb_assessed survey, col ci obs

*13. Child had finger or heel stick by CORP
svy: tab f_bloodtakenchw survey, col ci obs

*14. Caregiver received results of RDT from CORP
svy: tab f_gotresultchw survey, col ci obs

*15. Respiratory rate assessed by CORP
svy: tab fb_assessedchw survey, col ci obs

*16. Child received appropriate tx - all cases (overall, ACT w/in 24 w/RDT+, ORS + zinc, and amoxicillin)
*Overall (across all 3 illnesses)
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_correct_rx survey, col ci obs

use "cg_combined_hh_roster_post.dta", clear
svy: tab d_orszinc survey, col ci obs
svy: tab f_act24c2 survey if f_result==1, col ci obs
svy: tab fb_flab survey, col ci obs

*17. Child received appropriate tx from a CORP (overall, ACT w/in 24 w/RDT+, ORS + zinc, and amoxicillin)
*Overall (across all 3 illnesses)
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_correct_rxchw survey, col ci obs

use "cg_combined_hh_roster_post.dta", clear
svy: tab d_orszincchw survey, col ci obs
svy: tab f_act24cchw survey if f_result==1, col ci obs
svy: tab fb_flabchw survey, col ci obs

*18. Child received first dose of tx in presence of CORP (overall, ACT, ORS + zinc, and amoxicillin)
*Overall (across all 3 illnesses)
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_firstdose survey, col ci obs

use "cg_combined_hh_roster_post.dta", clear
svy: tab f_act_chwp survey, col ci obs
svy: tab d_bothfirstdose survey, col ci obs
svy: tab fb_flab_chwp survey, col ci obs

*19. Caregiver received counseling on how to administer drug (overall, ACT w/in 24 w/RDT+, ORS + zinc, and amoxicillin)
*Overall (across all 3 illnesses)
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_counsel survey, col ci obs

use "cg_combined_hh_roster_post.dta", clear
svy: tab f_act_chwc survey, col ci obs
svy: tab d_bothcounsel survey, col ci obs
svy: tab fb_flab_chwc survey, col ci obs
 
*20. Caregiver adhered to referral (all illnesses - use overall dataset)
*Overall (across all 3 illnesses)
use "cg_combined_hh_roster_overall_final.dta", clear
svy: tab all_referadhere survey, col ci obs

*21. Child received follow-up visit from CORP (all illnesses - use overall dataset) 
svy: tab all_followup survey, col ci obs
