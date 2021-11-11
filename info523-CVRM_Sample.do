clear all
capture log close
log using info523-CVRM_Sample.log, replace 
set more off

cd "/Users/elliot/Desktop/Fall 2021/INFO523/Final Project/Data Analysis"

//---| Author: Elliot Ramo
//---| Contact: elliot@email.arizona.edu
//---| Course: FA21 INFO 523 - Data Mining and Discovery
//---| Instructor: Dr. Cristian Román-Palacios
//---| Program: info523-CVRM_Sample.do
//---| Task: Sample of CVRM Data for Final Project

/* NOTE:	* This .do file takes a random sample from a dataset compiled by
			  Elliot Truslow in Spring 2020. Data sources: US Census, US Bureau
			  of Labor Statistics, City of Chicago, and Heartland Alliance.
*/
			
*------------------------------------------------------------------------------*

/// ----> Generating Sample

* Bring in data
use Full_CVRM.dta

* Save new copy
save Full_CVRM-copy.dta // saving copy of original

* Setting seed
set seed 38118148 // true random number generated at www.random.org

* Generating random draws
gen random = runiform() // random #s between 0-1
	note random: random num 0-1  \ "info523-CVRM_Sample.do ELT 2021-11-10"
	lab var random "Random #s 0-1"
	describe // confirming change
	
* Sort to ensure randomness of sample
sort random

* Selecting sample
gen insample = _n <=1000 // dummy 1 = in the sample, 0 = not in the sample
	note insample: 1 = in sample, 0 = not  \ "soc561-HW5.do ELT 2021-10-06"
	lab var insample "1 = in, 0 = not in"
	describe // confirming change

* Confirming change
tab insample, missing // 1 = 1000, 0 = 312,469

* Keeping only observations in the sample
keep if insample==1
describe // confirming change

*------------------------------------------------------------------------------*

/// ----> Cleanup and Save

* Saving dataset as a separate file, adding datasignature
save info523-CVRM_Sample.dta // saving copy of original

* Adding metadata to dataset
datasignature set
note: Data signature: `r(datasignature)' // saving datasig to file metadata
note: info523-CVRM_Sample.dta \ rand samp CVRM data \ info-523 ELT 2021-11-10
note: seed = 38118148
	notes // confirming note is saved to dataset

* Labeling dataset
label data "Random Sample of CVRM Data"
describe // confirming change

* Save and Close
quietly compress // compress the file to save space
notes
codebook, compact

* Log and exit
log close // ending log to close output
exit // exiting, clearing when Stata is done running .do file
