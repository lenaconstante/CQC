/*******************************************************************************
STATA coding tips folder - https://github.com/lenaconstante/CQC

Here you will find some coding tips related to LOOPS, which were used by me
at some point in my academic life
- Oficial documentation: 
	* https://www.stata.com/manuals13/pforeach.pdf
	* https://www.stata.com/manuals13/pforvalues.pdf
- Publication from STATA's coding tip master: Prof Nicholas J. Cox
	* https://doi.org/10.1177/1536867X2097634
	
Who am I? Hi, I am Helena M Constante!
*******************************************************************************/

/*******************************************************************************
//	1. Cross-sectional data - measured one time
*******************************************************************************/

//	1.1 To tabulate one and two-way and recode multiple variables 
//	(e.g. var1, var2) at the same time

	foreach var in var1 var2 var3 var4  {
		ta `var', r
	}

	foreach var in var1 var2 var3 var4  {
		ta var5 `var', r
	}

	foreach var in var1 var2 var3 var4 {
		recode `var' 0=0 1/2=1 3=2
	}
	
/*******************************************************************************
//	2. Longitudinal - multiple measures over time
*******************************************************************************/
	
//	2.1 Generating a new variable in order, based on longitudinal variables

	* First consider ordering the original variables
	order weight_*
	
	* Looping from 1
	local index 1
	foreach v of varlist weight_1 weight_2 weight_3 weight_4 weight_5 ///
		weight_6 weight_7 weight_8 weight_9 weight_10 weight_11 weight_12 ///
		weight_13 weight_14 weight_15 weight_16 weight_17 weight_18 weight_19 { 
		generate New_weight_`index' = `v'
		local index = `index' + 1
	  }

	* Considering 2 decimal points to the new variable
	forvalues i=1/19 { 
		replace New_weight_`i'= round(New_weight_`i', 0.01) 
		format New_weight_`i' %8.2f
	}
	
//	2.2 Looping a loop

	* Creating a fake weight variable
	local index 1
	foreach v of varlist New_weight_1-New_weight_19 {
		generate New_weightFAKE`index' = `v'
		 local index = `index' + 1
	  }
	
	* If date(n)=date(n+1) & weight(n)=weight(n+1) 
	* Keep weight(n) and change weight(n+1) to missing.	
	* List ID with errors
	forvalues i=2/19 {
		forvalues j=2/19 {
			if(`=`i'-1'<`j') {
			list id if (date`j'==date`=`i'-1' ///
			& New_weightFAKE`j'==New_weightFAKE`=`i'-1') & ///
			(date`j'!=. & date`=`i'-1'!=. & New_weightFAKE`j'!=. ///
			& New_weightFAKE`=`i'-1'!=.)
			}
		}
	}
	
	* Replace errors
	forvalues i=2/15 {
		forvalues j=2/19 {
			if(`=`i'-1'<`j') {
			replace New_weight_`j'=. if (date`j'==date`=`i'-1' ///
			& New_weightFAKE`j'==New_weightFAKE`=`i'-1') & ///
			(date`j'!=. & date`=`i'-1'!=. & New_weightFAKE`j'!=. ///
			& New_weightFAKE`=`i'-1'!=.)
			}
		}
	}
	
//	2.3 Looping considering multiple datasets in a folder

	* waves from "a" to "r"
	foreach i in a b c d e f g h i j k l m n o p q r {
		use ".\dataset_`i'", clear
		duplicates report id 
	}

