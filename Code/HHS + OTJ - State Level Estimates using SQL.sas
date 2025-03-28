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
