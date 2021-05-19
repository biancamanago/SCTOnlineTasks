capture log close

log using "cst2-do03-deference-shared", replace text

**************************************************************** 
//  #0
//  setup
****************************************************************
 
// CST2 - Comparing Status Tasks Experiment (Online Prolific Sample) 
// Examine deference DV findings
 
 version 14.1
 set linesize 80
 clear all
 macro drop _all

 
 local pgm   cst2-do03-deference-shared.do
 local dte   2020-05-29
 local who   bianca manago - trent mize  
 local tag   "`pgm'.do `who' `dte'"
 
 di "`tag'"
 
 ****************************************************************
 // #1
 // Load Data
 **************************************************************** 
 
	use "- data/cst2-data04-shared_wide_nosus", clear
	
****************************************************************
// #1
// Examine Ns
**************************************************************** 
	
	fre 	task
	
	tab		o_man   o_highstat, m
	tab		o_man   p_highstat, m	
	tab 	o_highstat o_educ, m	
	tab 	o_educ task, m
	
****************************************************************
// #2
// Preliminary Analyses / Descriptives
**************************************************************** 
	
	tabstat total_def, by(o_highstat) statistics(mean sd n min max) format(%5.3f)
	tabstat total_def, by(task) statistics(mean sd n min max)  format(%5.3f)

	* meaning insight	
	tabstat total_def if task==1, by(o_highstat) ///
			statistics(mean sd n min max) format(%5.3f)
	ttest total_def if task==1, by(o_highstat)
	
	* contrast sensitivity
	tabstat total_def if task==2, by(o_highstat) ///
			statistics(mean sd n min max) format(%5.3f)
	ttest total_def if task==2, by(o_highstat)
	
	* decision-making
	tabstat total_def if task==3, by(o_highstat) ///
		statistics(mean sd n min max) format(%5.3f)
	ttest total_def if task==3, by(o_highstat)
	

****************************************************************
// #3
// Analyses for CST SM Paper
**************************************************************** 
*Determine if control variables are needed (no)
reg 	total_def i.task##i.o_educ r_incomeC r_numsurveyC i.r_married ///
		i.r_parent i.r_pol p_ageyrs i.p_man i.p_white
test 	2.r_pol	3.r_pol

*Main model for paper
reg 	total_def i.task##i.o_educ
mtable, at(task=(1 2 3) o_educ=(0 2)) stat(est se)
margins, dydx(o_educ) over(task) // Divide p-values by two for one-tailed test
mlincom	3 - 1, stat(est se p)

nbreg 	total_def i.task##i.o_educ, irr
mtable, at(task=(1 2 3) o_educ=(0 2)) stat(est se)
margins, dydx(o_educ) over(task) // Divide p-values by two for one-tailed test
	
	// same findings with linear and negative binomial

****************************************************************
// #4
// Graphs - Deference
**************************************************************** 
set 	scheme cleanplots	
graph 	set window fontface "Arial"

cibar total_def, over1(o_educ) over2(task) ///
	graphopts(title("Mean Number of Times Participant Deferred to Partner (Online Study)") ///
	subtitle("By Education Level of Partner, Over Task") legend(position(6) rows(1)) ///
	ytitle("# Times Deferred") xlab(1.5 `""Meaning" "Insight""' ///
		4.2 `""Contrast" "Sensitivty""' 6.8 `""Decision-" "Making""') ///
	title("Online Sample") ylab(1(1)9) ///
	name(cst_bargraph_education, replace))  level(68)
	
		graph export "- figures/cst2-00-def-education-2019-01-11-SE.pdf", replace

*Figure for paper with titles removed
cibar total_def, over1(o_educ) over2(task) ///
	graphopts(legend(position(6) rows(1)) scale(1.2) ///
	ytitle("# Times Deferred") xlab(1.5 `""Meaning" "Insight""' ///
		4.2 `""Contrast" "Sensitivty""' 6.8 `""Decision-" "Making""') ///
	title("Online Sample") ylab(1(1)9) ///
	name(cst_bargraph_education, replace)) level(68)
	
		graph export "- figures/cst2-Figure4-def-education.png", replace
		graph save 	" - figures/cst2-Figure4", replace		
	
****************************************************************
// 
// 
**************************************************************** 
		log close
		exit

	
