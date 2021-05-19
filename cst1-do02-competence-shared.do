capture log close

log using "cst1-do02-competence-shared", replace text

**************************************************************** 
//  #0
//  setup
****************************************************************
 
// CST1 - Comparing Status Tasks Experiment (Lab Sample)
// Examine patterns for competence
 
 version 14.1
 set linesize 80
 clear all
 macro drop _all

 
 local pgm   cst1-do02-competence-shared.do
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
	
	tabstat comp_scl, by(o_highstat) statistics(mean sd n min max) format(%5.3f)
	tabstat comp_scl, by(task) statistics(mean sd n min max)  format(%5.3f)

	* meaning insight	
	tabstat comp_scl if task==1, by(o_highstat) ///
			statistics(mean sd n min max) format(%5.3f)
	ttest comp_scl if task==1, by(o_highstat)
	
	* contrast sensitivity
	tabstat comp_scl if task==2, by(o_highstat) ///
			statistics(mean sd n min max) format(%5.3f)
	ttest comp_scl if task==2, by(o_highstat)
	
	* decision-making
	tabstat comp_scl if task==3, by(o_highstat) ///
			statistics(mean sd n min max) format(%5.3f)
	ttest comp_scl if task==3, by(o_highstat)

		
	
****************************************************************
// #4
// Regression Analyses for CST Paper
**************************************************************** 
reg 	comp_scl i.task##i.o_educ
mtable, at(task=(1 2 3) o_educ=(0 2)) stat(est se)
margins, dydx(o_educ) over(task) 	// These are hypothesized so cut p-value 
									// in half for one-tailed test 

	
****************************************************************
// #5
// Graphs - Competence
**************************************************************** 
set 	scheme cleanplots	
graph 	set window fontface "Arial"

cibar comp_scl, over1(o_educ) over2(task) ///
	graphopts(title("Mean Rating of Partner's Competence (Lab Study)") ///
	subtitle("By Education Level of Partner, Over Task") legend(position(6) rows(1)) ///
	ytitle("Evaluation of Competence") ylab(3(1)7) ///
	name(cst_bargraph_education, replace)) level(68)
	
		graph export "- figures/cst1-do02-competence-education-2019-01-11-SE.pdf", replace
		
*Figure for paper with titles removed and legend altered so it works when
*	combined with online sample figure
cibar comp_scl, over1(o_educ) over2(task) ///
	graphopts(legend(position(6) rows(1)) scale(1.2) ///
	ytitle("Evaluation of Competence") xlab(1.5 `""Meaning" "Insight""' ///
		4.2 `""Contrast" "Sensitivty""' 6.8 `""Decision-" "Making""') ///
	title("Lab Sample") ylab(3(1)7) ///
	legend(order(1 "GED / High School Degree" 2 "Master's")) ///
	name(cst_bargraph_education, replace)) level(68)
	
		graph export "- figures/cst1-Figure3-competence-education.pdf", replace
		graph save "- figures/cst1-Figure3", replace	
		
	
				
****************************************************************
// close out
**************************************************************** 

log close
exit	
