capture log close

log using "cst2-do02-competence-shared", replace text

**************************************************************** 
//  #0
//  setup
****************************************************************
 
// CST2 - Comparing Status Tasks Experiment (Online Prolific Sample) 
// Examine competence DV findings
 
 version 15.1
 set linesize 80
 clear all
 macro drop _all

 
 local pgm   cst2-do02-competence-shared.do
 local dte   2020-05-29
 local who   bianca manago - trent mize 
 local tag   "`pgm'.do `who' `dte'"
 
 di "`tag'"
 
 ****************************************************************
 // #1
 // Load Data
 **************************************************************** 
 
	use "- data/cst2-data04-shared_wide_nosus.dta", clear
	
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
	
	tabstat comp_scl, by(o_highstat) statistics(mean n min max) format(%5.3f)
	tabstat comp_scl, by(task) statistics(mean n min max)  format(%5.3f)

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
// #3
// Regression Analyses 
**************************************************************** 
*Determine if control variables are needed (no)
reg 	comp_scl i.task##i.o_educ r_incomeC r_numsurveyC i.r_married ///
		i.r_parent i.r_pol p_ageyrs i.p_man i.p_white
test 	2.r_pol	3.r_pol

*Main model for paper
reg 	comp_scl i.task##i.o_educ
mtable, at(task=(1 2 3) o_educ=(0 2))  stat(est se)
margins, dydx(o_educ) over(task) post
mlincom	3 - 1, stat(est se p)
	
	
****************************************************************
// #4
// Graphs - Competence
**************************************************************** 
set 	scheme cleanplots	
graph 	set window fontface "Arial"

	
cibar comp_scl, over1(o_educ) over2(task) ///
	graphopts(title("Mean Rating of Partner's Competence (Online Study)") ///
	subtitle("By Education Level of Partner, Over Task") legend(position(6) rows(1)) ///
	ytitle("Evaluation of Competence") ///
	ylab(3(1)7) name(cst_bargraph_education, replace)) level(68) 
	
		graph export "- figures/cst2-do02-competence-education-2019-01-11-SE.pdf", replace
	
*Figure for paper with titles removed
	cibar comp_scl, over1(o_educ) over2(task) ///
	graphopts(legend(position(6) rows(1)) scale(1.2) ///
	ytitle("Evaluation of Competence") xlab(1.5 `""Meaning" "Insight""' ///
		4.2 `""Contrast" "Sensitivty""' 6.8 `""Decision-" "Making""') ///
	title("Online Sample") ylab(3(1)7)  ///
	legend(order(1 "GED / High School Degree" 2 "Master's")) ///
	name(cst_bargraph_education, replace))  level(68)
	
		graph export "- figures/cst2-Figure3-competence-education.pdf", replace	
		graph save	"- figures/cst2-Figure3", replace			
		
				
****************************************************************
// close out
**************************************************************** 

log close
exit	
