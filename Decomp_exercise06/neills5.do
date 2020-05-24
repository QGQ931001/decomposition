#delimit ;
set more off;
log using neills5.log, replace;
use nlsy00;
*******;
* Table 3, column 1;
*******;
replace afqtp89=afqtp89/100.0;
reg lropc00 black         
       if female==0 & hispanic==0; 
reg lropc00 black age00 msa ctrlcity north_central south00 west        
       if female==0 & hispanic==0; 
reg lropc00 black age00 msa ctrlcity north_central south00 west 
       sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col 
       if female==0 & hispanic==0; 
reg lropc00 black age00 msa ctrlcity north_central south00 west 
       sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89  
       if female==0 & hispanic==0; 
reg lropc00 black age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89 
       wkswk_18 yrsmil78_00 if female==0 & hispanic==0 ; 
*******;
reg lropc00 black  [weight=wgt00] if female==0 & hispanic==0; 
reg lropc00 black age00 msa ctrlcity north_central south00 west        
       if female==0 & hispanic==0; 
reg lropc00 black age00 msa ctrlcity north_central south00 west 
       sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col 
        [weight=wgt00] if female==0 & hispanic==0; 
reg lropc00 black age00 msa ctrlcity north_central south00 west 
       sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89  
        [weight=wgt00] if female==0 & hispanic==0; 
reg lropc00 black age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89 
        wkswk_18 yrsmil78_00 
         [weight=wgt00] if female==0 & hispanic==0 ; 
*******;
*Table 6, column 1;
*******;
reg lropc00 black         
       if female==1 & hispanic==0; 
reg lropc00 black age00 msa ctrlcity north_central south00 west        
       if female==1 & hispanic==0; 
reg lropc00 black age00 msa ctrlcity north_central south00 west 
       sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col 
       if female==1 & hispanic==0; 
reg lropc00 black age00 msa ctrlcity north_central south00 west 
       sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89  
       if female==1 & hispanic==0; 
reg lropc00 black age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89 
       age1stb30 
       if female==1 & hispanic==0; 
reg lropc00 black age00 msa ctrlcity north_central south00 west  
	 sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89 
       age1stb30 wkswk_18 yrsmil78_00 famrspb pcntpt_22
       if female==1 & hispanic==0;  
* Question b);
sum sch_10  sch10_12 diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89 
       if female==0 & hispanic==0 & black==0;
sum sch_10   sch10_12 diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89 
       if female==0 & black==1;
sum sch_10  sch10_12 diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89 
       if female==0 & hispanic==1;
reg lropc00 age00 msa ctrlcity north_central south00 west 
       sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89  
       if female==0 & white==1; 
reg lropc00 age00 msa ctrlcity north_central south00 west 
       sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89  
       if female==0 & black==1; 
reg lropc00 age00 msa ctrlcity north_central south00 west 
       sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89  
       if female==0 & hispanic==1; 
reg lropc00 age00 msa ctrlcity north_central south00 west 
       sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89  
       if female==0 & hispanic==0 ; 
reg lropc00 age00 msa ctrlcity north_central south00 west 
       sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89  
       if female==0 & black==0 ; 
*********;
* Oaxaca decomposition;
*********;
*********;
sum black if (white==1 | black==1) & female==0 ;
sum white if (white==1 | black==1) & female==0 ;
reg lropc00 age00 msa ctrlcity north_central south00 west 
      sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col  afqtp89  
       if female==0 & white==1;
estimates store white;
reg lropc00 age00 msa ctrlcity north_central south00 west 
      sch_10 diploma_hs ged_hs smcol bachelor_col master_col doctor_col  afqtp89  
       if female==0 & black==1;
estimates store black;
oaxaca8 white black, weight(1 0 0.651) detail notf;
*********;
reg lropc00 age00 msa ctrlcity north_central south00 west 
      sch_10 sch10_12 diploma_hs  ged_hs smcol master_col doctor_col   afqtp89  
       if female==0 & white==1;
estimates store white2;
reg lropc00 age00 msa ctrlcity north_central south00 west 
      sch_10 sch10_12 diploma_hs  ged_hs smcol master_col doctor_col   afqtp89  
       if female==0 & black==1;
estimates store black2;
oaxaca8 white2 black2, weight(1 0 0.651) detail(north_central south00 west) notf;
************;
gen east=0;
replace east=1 if west==0 & north_central==0 & south00==0;
reg lropc00 age00 msa ctrlcity east north_central west 
       sch10_12 diploma_hs  ged_hs smcol bachelor_col  master_col doctor_col afqtp89  
       if female==0 & white==1;
estimates store white3;
reg lropc00 age00 msa ctrlcity east north_central west 
       sch10_12 diploma_hs  ged_hs smcol bachelor_col master_col doctor_col  afqtp89  
       if female==0 & black==1;
estimates store black3;
oaxaca8 white3 black3, weight(1 0 0.651) detail(east north_central west)  notf;

