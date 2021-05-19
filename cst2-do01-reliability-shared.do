capture log close

log using "cst2-do01-reliability-shared.log", replace text


**************************************************************** 
//  #0
//  setup
****************************************************************
 
// CST2 - Comparing Status Tasks Experiment (Online Prolific Sample) 
// Examine scale reliabilities and content-coded reliabilities

 version 14.1
 set linesize 80
 clear all
 macro drop _all

 
 local pgm   cst2-do01-reliability-shared.do
 local dte   2020-05-29
 local who   "bianca manago - trenton mize" 
 local tag   "`pgm'.do `who' `dte'"
 
 di "`tag'"
 
****************************************************************
// #1
// Load Data
**************************************************************** 
 
use "- data/cst2-data04-shared_wide", clear	


****************************************************************
// #2
// Examine scale alpha reliability
**************************************************************** 
  
alpha 	w_friendly w_wellint w_trustworthy w_warm w_goodnat w_sincere ///
		if suspicious == 0, item
 
alpha 	c_competent c_confident c_capable c_efficient c_intell c_skillful ///
		if suspicious == 0, item 

*********************************************************************
// #2 - Calculate reliability stats that require data in wide form
*********************************************************************
local codes "s_focus_S s_focus_C s_task_S s_task_C" 
local codes "`codes' s_partner_S s_partner_C"

matrix define reli = J(8,12,.)

*These analyses treat data as nominal
local row = 1
foreach c in `codes' {
	kappaetc 	`c'*
	matrix 		coefs = r(b)
	mat 		reli[`row',2] = coefs[1,1]
	mat 		reli[`row',4] = coefs[1,3]	
	mat 		reli[`row',5] = coefs[1,6]
	mat 		reli[`row',9] = coefs[1,2]
	mat 		reli[`row',10] = coefs[1,4]	
	mat 		reli[`row',11] = coefs[1,5]	
	local 		++row
	}
*These analyses treat data as nominal	
local row = 1
foreach c in `codes' {
	corr `c'_1 `c'_2
	local 	prho = `r(rho)'
	mat 	reli[`row',8] = `prho'
	
	capture noisily tetrachoric `c'_1 `c'_2
	if _rc == 198 {
		local 	rho = 0
		mat 	reli[`row',3] = `rho'
		}
	else {
		local 	rho = `r(rho)'
		mat 	reli[`row',3] = `rho'
		}	
	local 	++row
	}
*This analyses treat var as ordinal	
local ocodes "s_focus_ s_task_ s_partner_"
local row = 1
foreach c in `ocodes' {
	polychoric `c'1 `c'2
	local 	rho = `r(rho)'
	mat 	reli[`row',12] = `rho'
	
	local 	++row
	local 	++row
	}	
	
matrix rownames reli = `codes'	

matlist reli

*********************************************************************
// #3 - Calculate reliability stats that require data in long form
*********************************************************************
use 	"- data/cst2-data04-shared_long", clear

*Calculate ICCs
local codes "s_focus_S s_focus_C s_task_S s_task_C" 
local codes "`codes' s_partner_S s_partner_C"
local row = 1
foreach c in `codes' {		
	tabstat `c', save
	mat 	temp = r(StatTotal)
	local 	propor = temp[1,1]
	mat 	reli[`row',1] = `propor'

	icc 	`c' ID ra
	local 	icc = `r(icc_i)'
	mat 	reli[`row',6] = `icc'
	local 	icc = `r(icc_avg)'
	mat 	reli[`row',7] = `icc'	
	local 	++row
	}

	
*********************************************************************
// #4 - Final table of all reliability statistics; examine similarities
*********************************************************************
	
matrix colnames reli = 	prop agree tet_corr c_kappa k_alpha icc_i icc_avg ///
						corr bren_pr fleiss_pi gwet_ac polych

matlist reli, title("Inter-rater reliability statistics") ///
				twidth(20) format(%9.3f)
	
	
*Create variables for statistics to examine similarities
svmat 	reli, names(col)
corr 	prop agree tet_corr c_kappa k_alpha icc_i icc_avg corr ///
			bren_pr fleiss_pi gwet_ac polych
	
		
****************************************************************
// 
// 
**************************************************************** 
		log close
		exit

	
	
