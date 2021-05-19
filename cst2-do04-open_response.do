capture log close

log using "cst2-do04-open_response", replace text

**************************************************************** 
//  #0
//  setup
****************************************************************
 
 version 	14.1
 set 		linesize 80
 clear 		all
 macro drop _all

 
 local pgm   cst2-do04-open_response.do
 local dte   2020-04-10
 local who   "trenton mize"
 local tag   "`pgm'.do `who' `dte'"
 
 di "`tag'"
 
	
****************************************************************
// #1
// Patterns of scope condition problems across tasks
****************************************************************
*Load Data (wide form)
use "- data/cst2-data03-drop_wide", clear	

tab 	d_partner task if suspicious == 0, chi2
tab 	failscope task if suspicious == 0, chi2


****************************************************************
// #3
// Patterns of suspicion across tasks
**************************************************************** 	
*Load Data (long form)
use "- data/cst2-data03-drop_long", clear

local codes s_gen_educ_S s_gen_educ_C ///
			s_task_S s_task_C s_partner_S s_partner_C
sum `codes'			

matrix 	define susp = J(12,6,.)
local 	col = 1

foreach c in `codes' {
	local row = 1
	di _newline(1)
	di in red "Code = `c'"
	tabstat `c' if exp_educ == 1, by(o_educ) stat(mean sd n) format(%5.3f)
	tab 	`c' o_educ if exp_educ == 1, chi2
	tabstat `c' if exp_educ == 1, by(task) stat(mean sd n) format(%5.3f) save
	matrix 	stat1 = r(Stat1)
	matrix 	stat2 = r(Stat2)
	matrix 	stat3 = r(Stat3)
	mat 	susp[`row',`col'] = stat1[1,1]
	local 	++row
	mat 	susp[`row',`col'] = stat2[1,1]	
	local 	++row
	mat 	susp[`row',`col'] = stat3[1,1]		
	local 	++row	
	tab 	`c' task if exp_educ == 1, chi2
	mat 	susp[`row',`col'] = r(chi2)
	local 	++row
	mat 	susp[`row',`col'] = r(p)
	local 	++row
	tabstat `c' if exp_educ == 1, by(r_numsurvey2) stat(mean sd n) format(%5.3f)
	tab 	`c' r_numsurvey2 if exp_educ == 1, chi2
	tabstat `c' if exp_educ == 1, by(r_numsurvey3) stat(mean sd n) format(%5.3f) save
	matrix 	stat1 = r(Stat1)
	matrix 	stat2 = r(Stat2)
	matrix 	stat3 = r(Stat3)
	matrix 	stat4 = r(Stat4)
	matrix 	stat5 = r(Stat5)
	mat 	susp[`row',`col'] = stat1[1,1]
	local 	++row
	mat 	susp[`row',`col'] = stat2[1,1]	
	local 	++row
	mat 	susp[`row',`col'] = stat3[1,1]		
	local 	++row		
	mat 	susp[`row',`col'] = stat4[1,1]	
	local 	++row
	mat 	susp[`row',`col'] = stat5[1,1]		
	local 	++row			
	tab 	`c' r_numsurvey3 if exp_educ == 1, chi2	
	tabstat `c' if exp_educ == 1, by(r_numsurvey) stat(mean sd n) format(%5.3f)	
	tab 	`c' r_numsurvey if exp_educ == 1, chi2
	polychoric 	r_numsurveyC `c'
	mat 	susp[`row',`col'] = r(rho)
	local 	++row
	local 	zval = r(rho) / r(se_rho)
	local 	pval = 	2*(1 - normal(abs(`zval')))
	mat 	susp[`row',`col'] = `pval'
	local 	++col
	}			

matrix rownames susp = "Meaning Insight" "Contrast Sensitivty" ///
	"Workplace Decisions" "Chi-2 value" "Chi-2 p-val" "0" "1 to 10" "11 to 20" ///
	"21 to 100" "101 or more" "Polyserial correlation" "Corr p-value"
matrix colnames susp = "Focus:somewhat" "Focus:completely" "Task:somewhat" ///
	"Task:completely" "Partner:somewhat" "Partner:completely"

matlist susp, title("Suspicion rates") ///
				twidth(20) format(%10.3f)
				

*Examine correlations b/w P experience and suspicion across tasks
local codes s_gen_educ_S s_gen_educ_C ///
			s_task_S s_task_C s_partner_S s_partner_C
foreach c in `codes' {
	di _newline(1)
	di in red "Code = `: var label `c''"
	di _newline(1)
	di in white "Task = Meaning Insight"
	polychoric 	r_numsurveyC `c' if task == 1
	local 	zval = r(rho) / r(se_rho)
	local 	pval = 	2*(1 - normal(abs(`zval')))
	di "p-value = "
	di %5.3f `pval'	
	di _newline(1)
	di in white "Task = Contrast Sensitivity"
	polychoric 	r_numsurveyC `c' if task == 2
	local 	zval = r(rho) / r(se_rho)
	local 	pval = 	2*(1 - normal(abs(`zval')))
	di "p-value = "
	di %5.3f `pval'	
	di _newline(1)
	di in white "Task = Decision-Making"
	polychoric 	r_numsurveyC `c' if task == 3	
	local 	zval = r(rho) / r(se_rho)
	local 	pval = 	2*(1 - normal(abs(`zval')))
	di "p-value = "
	di %5.3f `pval'	
	}	
	
	
	

log close
exit	