*-----------------------------------------------------------------------------------*
|                   		  SAS Innovate 2025                       			    |
| 				Learning SAS Programming with Help from ChatGPT						|
*-----------------------------------------------------------------------------------*;
options 	orientation=landscape mlogic symbolgen pageno=1 error=3;
title1 		"Global Academic Programs Workshop";
title2 		"Learning SAS Programming with Help from ChatGPT";
footnote 	"File = SAS Programming + ChatGPT";

libname HHS "~/HHS_OTJ";


*-----------------------------------------------------------*
| 					Import Data from GitHub					|
*-----------------------------------------------------------*;

filename mycsv url "https://raw.githubusercontent.com/lincolngroves/SAS-OTJ-HHS/main/ACS_2015_2022_ltd.csv";

* Import the CSV file directly from the GitHub raw URL;
proc import datafile=mycsv
    out=HHS.HHS_OTJ_Raw
    dbms=csv
    replace;
    getnames=yes;
	guessingrows=100000;
run;

* Print the data to verify the import;
proc print data=HHS.HHS_OTJ_Raw (obs=100);
run;


*-----------------------------------------------------------*
|	 				Explore Data Set						|
*-----------------------------------------------------------*;
* Step 1: Summary of numeric variables;
proc means data=HHS.HHS_OTJ_Raw n mean std min max maxdec=2;
    var _numeric_;  * This will automatically include all numeric variables;
run;

* Step 2: Summary of non-numeric variables;
proc freq data=HHS.HHS_OTJ_Raw;
    tables _character_;  * This will automatically include all character variables;
run;

* Step 3: Bonus Graph - Histogram for numeric variables;
proc univariate data=HHS.HHS_OTJ_Raw;
    var _numeric_;  /* Automatically includes all numeric variables */
    histogram / normal;  /* Adds a histogram with a normal curve for each numeric variable */
    inset mean std min max / position=ne;  /* Adds summary statistics to the plot */
run;


* Step 4: Bonus Graph - Bar chart for non-numeric (categorical) variables;
proc freq data=HHS.HHS_OTJ_Raw;
    tables _character_ / plots=freqplot;  /* Automatically includes all character variables and generates a frequency plot */
run;


*-------------------------------------------------------------------------------------*
|    	   						  Collapse Data 									  | 
|	                    	Produce State-Level Estimates          	          		  |
*-------------------------------------------------------------------------------------*;

********************************************************  By State ;
proc sql;
	create 	table hhs.covid_labor_supply as 
	select	distinct state_fip, state_name, 
            year(yearquarter) as Year format 9.,
			
/*******************************************************************  Labor Force Status | All  */
			sum( ( unemp=1 ) * WTFINL ) 											/ sum( ( in_LF=1 ) *   	WTFINL )									as UE_Women				label="Unemployment Rate"	format percent9.1 		,
			sum( ( in_LF=1 ) * WTFINL ) 											/ sum(  				WTFINL )									as LFP_Women			label="LFP Rate"			format percent9.1 		,


/*******************************************************************  Labor Force Status | By Education  */

			/*******************************************************  Unemployment */
			sum( ( educ_ltd="High School Diploma" ) * ( unemp=1 ) * WTFINL ) 		/ sum( ( educ_ltd="High School Diploma" ) * ( in_LF=1 ) * WTFINL )	as UE_Women_HS			label="EDUC <= HS" 		format percent9.1 		,
			sum( ( educ_ltd="Some College" ) * ( unemp=1 ) * WTFINL ) 				/ sum( ( educ_ltd="Some College" ) * ( in_LF=1 ) * WTFINL ) 		as UE_Women_SCollege	label="Some College"	format percent9.1 		,
			sum( ( educ_ltd="College +" ) * ( unemp=1 ) * WTFINL ) 					/ sum( ( educ_ltd="College +" ) * ( in_LF=1 ) * WTFINL ) 			as UE_Women_CollegeP	label="College +" 		format percent9.1 		,

			/*******************************************************  LFP */
			sum( ( educ_ltd="High School Diploma" ) * ( in_LF=1 ) * WTFINL ) 		/ sum( ( educ_ltd="High School Diploma" ) * WTFINL ) 				as LFP_Women_HS			label="EDUC <= HS" 		format percent9.1 		,
			sum( ( educ_ltd="Some College" ) * ( in_LF=1 ) * WTFINL ) 				/ sum( ( educ_ltd="Some College" ) * WTFINL ) 						as LFP_Women_SCollege	label="Some College" 	format percent9.1 		,
			sum( ( educ_ltd="College +" ) * ( in_LF=1 ) * WTFINL ) 					/ sum( ( educ_ltd="College +" ) * WTFINL ) 							as LFP_Women_CollegeP	label="College +" 		format percent9.1 		,


/*******************************************************************  Labor Force Status | By Child Status  */

			/*******************************************************  Unemployment */
			sum( ( child_status="No Children" ) * ( unemp=1 ) * WTFINL ) 			/ sum( ( child_status="No Children" ) * ( in_LF=1 ) * WTFINL ) 		as UE_Women_NoKids		label="No Children" 	format percent9.1 		,
			sum( ( child_status="Older Children" ) * ( unemp=1 ) * WTFINL ) 		/ sum( ( child_status="Older Children" ) * ( in_LF=1 ) * WTFINL ) 	as UE_Women_OlderKids	label="Older Children" 	format percent9.1 		,
			sum( ( child_status="Child < 5" ) * ( unemp=1 ) * WTFINL ) 				/ sum( ( child_status="Child < 5" ) * ( in_LF=1 ) * WTFINL ) 		as UE_Women_YoungKids	label="Young Children"	format percent9.1 		,

			/*******************************************************  LFP */
			sum( ( child_status="No Children" ) * ( in_LF=1 ) * WTFINL ) 			/ sum( ( child_status="No Children" ) * WTFINL ) 					as LFP_Women_NoKids		label="No Children" 	format percent9.1 		,
			sum( ( child_status="Older Children" ) * ( in_LF=1 ) * WTFINL ) 		/ sum( ( child_status="Older Children" ) * WTFINL ) 				as LFP_Women_OlderKids	label="Older Children" 	format percent9.1 		,
			sum( ( child_status="Child < 5" ) * ( in_LF=1 ) * WTFINL ) 				/ sum( ( child_status="Child < 5" ) * WTFINL ) 						as LFP_Women_YoungKids	label="Young Children"	format percent9.1 		


	from 	hhs.hhs_otj_raw
	group	by 1,2,3 
	order	by 1,2,3 ;
quit;


*-------------------------------------------------------------------------------------*
|    	   					Summarize State-Level Estimates							  | 
*-------------------------------------------------------------------------------------*;
/* Summarizing the new variables in the hhs.covid_labor_supply dataset */

/* Step 1: Use PROC MEANS to summarize the numeric variables (rates) */
proc means data=hhs.covid_labor_supply n mean std min max median maxdec=2;
    var UE_Women LFP_Women 
        UE_Women_HS UE_Women_SCollege UE_Women_CollegeP 
        LFP_Women_HS LFP_Women_SCollege LFP_Women_CollegeP
        UE_Women_NoKids UE_Women_OlderKids UE_Women_YoungKids
        LFP_Women_NoKids LFP_Women_OlderKids LFP_Women_YoungKids;
    title "Summary Statistics for New Variables in the covid_labor_supply Dataset";
run;

/* Step 2: Use PROC FREQ to summarize categorical variables (if any, like state and year) */
proc freq data=hhs.covid_labor_supply;
    tables state_fip state_name Year;
    title "Frequency Distribution for State and Year Variables";
run;


*-------------------------------------------------------------------------------------*
|    	   					Plots over time by State								  | 
*-------------------------------------------------------------------------------------*;
/* Step 1: Sort the data by state_name to use the BY statement */
proc sort data=hhs.covid_labor_supply;
    by state_name;
run;

/* Step 2: Create a plot for UE_Women by state over time */
proc sgplot data=hhs.covid_labor_supply;
    by state_name; /* This will create separate plots for each state */
    series x=Year y=UE_Women / lineattrs=(pattern=solid) markers;
    title "Unemployment Rate for Women (UE_Women) by State Over Time";
    xaxis label="Year" grid;
    yaxis label="Unemployment Rate" grid;
run;

/* Step 3: Create a plot for UE_Women_NoKids by state over time */
proc sgplot data=hhs.covid_labor_supply;
    by state_name; /* This will create separate plots for each state */
    series x=Year y=UE_Women_NoKids / lineattrs=(pattern=solid) markers;
    title "Unemployment Rate for Women (No Kids) by State Over Time";
    xaxis label="Year" grid;
    yaxis label="Unemployment Rate (No Kids)" grid;
run;

/* Step 4: Create a plot for UE_Women_OlderKids by state over time */
proc sgplot data=hhs.covid_labor_supply;
    by state_name; /* This will create separate plots for each state */
    series x=Year y=UE_Women_OlderKids / lineattrs=(pattern=solid) markers;
    title "Unemployment Rate for Women (Older Kids) by State Over Time";
    xaxis label="Year" grid;
    yaxis label="Unemployment Rate (Older Kids)" grid;
run;

/* Step 5: Create a plot for UE_Women_YoungKids by state over time */
proc sgplot data=hhs.covid_labor_supply;
    by state_name; /* This will create separate plots for each state */
    series x=Year y=UE_Women_YoungKids / lineattrs=(pattern=solid) markers;
    title "Unemployment Rate for Women (Young Kids) by State Over Time";
    xaxis label="Year" grid;
    yaxis label="Unemployment Rate (Young Kids)" grid;
run;
