#delimit ;
set more off;
log using DM_gender_T23.log, replace;
** data is from O'Neill and O'Neill (2005), NBER WP no. 11240 with ind3 added by caseid ;
** See that paper for details about data;
use nlsy00_ind.dta, clear;
drop if ind3<=0 | ind3>=990;
*******;
sort female;
replace afqtp89=afqtp89/10.0;
*** generate dummies for industrial sectors;
gen primary=0;
replace primary=1 if indd1==1 | indd2==1 | indd7==1 ;
gen manuf=0 ;
replace manuf=1 if indd3==1 | indd4==1;
gen eduheal=0;
replace eduheal=1 if indd11==1 | indd13==1;
gen othind=0;
replace othind=1 if indd5==1 | indd6==1 | indd8==1 | indd9==1 | indd10==1 | indd12==1;  
gen ind5sum=primary+manuf+eduheal+othind;
tab ind5sum;
drop if ind5sum==0;

sum female ;
*** Means in Table 2, Column 1;
by female: sum black age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10 sch10_12 diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89 
        famrspb wkswk_18 yrsmil78_00 pcntpt_22 primary manuf eduheal othind lropc00;
*******;
*** Table 2, Column 2; 
reg lropc00  age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10  diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89 
        famrspb wkswk_18 yrsmil78_00 pcntpt_22 manuf  eduheal othind 
      if female==0;   
*** Table 2, Column 3;  
reg lropc00  age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10  diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89 
        famrspb wkswk_18 yrsmil78_00 pcntpt_22 manuf  eduheal othind 
      if female==1; 
*** Table 2, Column 4;     
reg lropc00 age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10   diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89 
        famrspb wkswk_18 yrsmil78_00 pcntpt_22 primary manuf  othind 
       if female==0; 
*** Table 2, Column 5;     
reg lropc00 female age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10   diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89 
        famrspb wkswk_18 yrsmil78_00 pcntpt_22 manuf  eduheal othind ;
*** Table 3, Column 1;     
oaxaca lropc00 age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col  afqtp89 
        famrspb wkswk_18 yrsmil78_00 pcntpt_22 manuf eduheal othind,
       by(female) weight(1) 
        detail(groupdem:age00 msa ctrlcity north_central south00 west hispanic black,
        groupaf:afqtp89, 
        grouped:sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col ,
        groupfam:famrspb, 
        groupex:wkswk_18 yrsmil78_00 pcntpt_22 ,
        groupind: manuf eduheal othind) ;
*** Table 3, Column 2;  
oaxaca lropc00 age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col  afqtp89 
        famrspb wkswk_18 yrsmil78_00 pcntpt_22  primary eduheal othind,
       by(female) weight(1) 
        detail(groupdem:age00 msa ctrlcity north_central south00 west hispanic black,
        groupaf:afqtp89, 
        grouped:sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col ,
        groupfam:famrspb, 
        groupex:wkswk_18 yrsmil78_00 pcntpt_22 ,
        groupind: primary eduheal othind) ;
*** Table 3, Column 3;  
oaxaca lropc00 age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10 sch10_12 diploma_hs ged_hs bachelor_col master_col doctor_col  afqtp89 
        famrspb wkswk_18 yrsmil78_00 pcntpt_22  manuf eduheal othind,
        by(female) weight(0) 
        detail(groupdem:age00 msa ctrlcity north_central south00 west hispanic black,
        groupaf:afqtp89, 
        grouped:sch_10 sch10_12 diploma_hs ged_hs bachelor_col master_col doctor_col ,
        groupfam:famrspb, 
        groupex:wkswk_18 yrsmil78_00 pcntpt_22 ,
        groupind: manuf eduheal othind) ;
*** Table 3, Column 4;  
oaxaca lropc00 age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col  afqtp89 
        famrspb wkswk_18 yrsmil78_00 pcntpt_22  manuf eduheal othind,
       by(female) weight(0.500926) 
        detail(groupdem:age00 msa ctrlcity north_central south00 west hispanic black,
        groupaf:afqtp89, 
        grouped:sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col ,
        groupfam:famrspb, 
        groupex:wkswk_18 yrsmil78_00 pcntpt_22 ,
        groupind: manuf eduheal othind) ;
*** Table 3, Column 5;  
oaxaca lropc00 age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col  afqtp89 
        famrspb wkswk_18 yrsmil78_00 pcntpt_22  manuf eduheal othind,
       by(female) pooled 
        detail(groupdem:age00 msa ctrlcity north_central south00 west hispanic black,
        groupaf:afqtp89, 
        grouped:sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col ,
        groupfam:famrspb, 
        groupex:wkswk_18 yrsmil78_00 pcntpt_22 ,
        groupind: manuf eduheal othind) ;

