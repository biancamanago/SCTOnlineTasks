capture log close

log using "cst1-do03-deference-shared", replace text

**************************************************************** 
//  #0
//  setup
****************************************************************

// CST1 - Comparing Status Tasks Experiment (Lab Sample)
// Examine patterns for deference

 version 14.1
 set linesize 80
 clear all
 macro drop _all

 
 local pgm   cst1-do03-deference-shared.do
 local dte   2020-05-29
 local who   bianca manago - trent mize  
 local tag   "`pgm'.do `who' `dte'"
 
 di "`tag'"
 
****************************************************************
// #1
// Load Data
**************************************************************** 
 
	use "- data/cst1-data03-shared", clear
	
****************************************************************
// #2
// Examine Ns
**************************************************************** 
	
	fre 	task
	
	tab		o_man   o_highstat, m
	tab		o_man   p_highstat, m	
	tab 	o_highstat o_educ, m	
	tab 	o_educ task, m
	
****************************************************************
// #3
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
// #4
// Regression Analyses for CST Paper
**************************************************************** 
reg 	total_def i.task##i.o_educ 
mtable, at(task=(1 2 3) o_educ=(0 2)) stat(est se)
margins, dydx(o_educ) over(task) // Divide p-values by two for one-tailed test

	
nbreg 	total_def i.task##i.o_educ 
mtable, at(task=(1 2 3) o_educ=(0 2)) stat(est se)
margins, dydx(o_educ) over(task) // Divide p-values by two for one-tailed test
	
	// same findings with linear and negative binomial
	
****************************************************************
// #5
// Graphs - Deference
**************************************************************** 
set 	scheme cleanplots	
graph 	set window fontface "Arial"

cibar total_def, over1(o_educ) over2(task) ///
	graphopts(title("Mean Number of Times Participant Deferred to Partner (Lab Study)") ///
	subtitle("By Education Level of Partner, Over Task") legend(position(6) rows(1)) ///
	ytitle("# Times Deferred") ylab(1(1)9) ///
	name(cst_bargraph_education, replace)) level(68)
	
		graph export "- figures/cst1-00-def-education-2019-01-11-SE.pdf", replace	

*Figure for paper with titles removed
	cibar total_def, over1(o_educ) over2(task) ///
	graphopts(legend(position(6) rows(1)) scale(1.2) ///
	ytitle("# Times Deferred") xlab(1.5 `""Meaning" "Insight""' ///
		4.2 `""Contrast" "Sensitivty""' 6.8 `""Decision-" "Making""') ///
	title("Lab Sample") ylab(1(1)9) ///
	legend(order(1 "GED / High School Degree" 2 "Master's")) ///
	legend(order(1 "GED / High School Degree" 2 "Master's")) ///	
	name(cst_bargraph_education, replace)) level(68)
	
		graph export "- figures/cst1-Figure4-def-education.pdf", replace	
		graph save 	" - figures/cst1-Figure4", replace
		

	
****************************************************************
// 
// 
**************************************************************** 
		log close
		exit
