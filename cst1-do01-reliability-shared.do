capture log close

log using "cst1-do01-reliability-shared.log", replace text

**************************************************************** 
//  #0
//  setup
****************************************************************
 
// CST1 - Comparing Status Tasks Experiment (Lab Sample) 
// Examine scale reliabilities now that data is clean
 
 version 14.1
 set linesize 80
 clear all
 macro drop _all

 
 local pgm   cst1-do01-reliability-shared.do
 local dte   2020-05-29
 local who   "bianca manago - trenton mize" 
 local tag   "`pgm'.do `who' `dte'"
 
 di "`tag'"
 
****************************************************************
// #1
// Load Data
**************************************************************** 

	use "- data/cst1-data03-shared", clear
	
	
****************************************************************
// #2
// Examine scale alpha reliability
**************************************************************** 
  
alpha 	w_friendly w_wellint w_trustworthy w_warm w_goodnat w_sincere ///
		if suspicious == 0, item
 
alpha 	c_competent c_confident c_capable c_efficient c_intell c_skillful ///
		if suspicious == 0, item 
 
****************************************************************
// 
// 
**************************************************************** 
		log close
		exit

	
