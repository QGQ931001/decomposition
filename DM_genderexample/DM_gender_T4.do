#delimit ;
set more off;
log using DM_gender_T4.log, replace;
** data is from O'Neill and O'Neill (2005), NBER WP no. 11240 with ind3 added by caseid ;
** See that paper for details about data;

use nlsy00_ind.dta, clear;
drop if ind3<=0 | ind3>=990;

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

*******;
sort female;
replace afqtp89=afqtp89/10.0;
*check summary statistics ;
sort female;
by female: sum lropc00 black age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10 sch10_12 diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89 
        famrspb wkswk_18 yrsmil78_00 pcntpt_22  primary manuf  eduheal othind  ;
*******;

*compute the raw wage differentials at quantiles 10, 50, and 90;
sort female;
sum lropc00 if female==1, detail;
gen f90=r(p90);
gen f50=r(p50);
gen f10=r(p10);
sum lropc00 if female==0, detail;
gen m90=r(p90);
gen m50=r(p50);
gen m10=r(p10);
gen dif90=m90-f90;
gen dif50=m50-f50;
gen dif10=m10-f10;
di "  m-f q10 =" dif10 "  m-f q50 =" dif50 "  m-f q90 ="  dif90;

**perform the RIF decomposition
*** graph the densities to check bandwidth ;
kdensity lropc00 if female==0, gen(evalm1 densm1) width(0.10) nograph ;
kdensity lropc00 if female==1, gen(evalf1 densf1) width(0.10) nograph ;
set scheme s1color;
label var evalf "Log(wage)";
label var evalm "Log(wage)";
graph twoway  (connected densf1 evalf1, msymbol(i) lpattern(dash) clwidth(medium) lc(red) )  /*
   */   (connected densm1  evalm1, msymbol(i) lpattern(longdash) clwidth(medium) lc(blue) )  /*
   */   , ytitle("Density")ylabel(0.0 0.2 0.4 0.6 0.8 1.0) /*
   */   xlabel(1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5)  /* 
   */   legend(pos(7) col(2) lab(1 "Women")  lab(2 "Men")    /*
   */   region(lstyle(none)) symxsize(8) keygap(1) textwidth(34) ) /*
   */   saving(nlsy00_dens,replace);

* compute RIF for the 10th, 50th and 90th quantiles for men and women ;
forvalues qt = 10(40)90 {	;
   gen rif_`qt'=.;
};
pctile eval1=lropc00 if female==1 , nq(100) ;
kdensity lropc00 if female==1, at(eval1) gen(evalf densf) width(0.10) nograph ;
forvalues qt = 10(40)90 {	;
 local qc = `qt'/100.0;
 replace rif_`qt'=evalf[`qt']+`qc'/densf[`qt'] if lropc00>=evalf[`qt'] & female==1;
 replace rif_`qt'=evalf[`qt']-(1-`qc')/densf[`qt'] if lropc00<evalf[`qt']& female==1;
};
pctile eval2=lropc00 if female==0, nq(100) ;
kdensity lropc00 if female==0, at(eval2) gen(evalm densm) width(0.10) nograph ;
forvalues qt = 10(40)90 {	;
 local qc = `qt'/100.0;
 replace rif_`qt'=evalm[`qt']+`qc'/densm[`qt'] if lropc00>=evalm[`qt'] & female==0;
 replace rif_`qt'=evalm[`qt']-(1-`qc')/densm[`qt'] if lropc00<evalm[`qt']& female==0;
};
sort female;
by female: sum rif_10 rif_50 rif_90;

** perform oaxaca decomposition;
** to get correct standard errors use DM_gender_T4boot.do ;
oaxaca rif_10 age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10 sch10_12 diploma_hs ged_hs bachelor_col master_col doctor_col  afqtp89 
        famrspb wkswk_18 yrsmil78_00 pcntpt_22  manuf  eduheal othind,
        by(female) weight(1) 
        detail(groupdem:age00 msa ctrlcity north_central south00 west hispanic black,
        groupaf:afqtp89, 
        grouped:sch_10 sch10_12 diploma_hs ged_hs bachelor_col master_col doctor_col ,
        groupfam:famrspb, 
        groupex:wkswk_18 yrsmil78_00 pcntpt_22 ,
        groupind:manuf  eduheal othind) ;
oaxaca rif_50 age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10 sch10_12 diploma_hs ged_hs bachelor_col master_col doctor_col  afqtp89 
        famrspb wkswk_18 yrsmil78_00 pcntpt_22  manuf  eduheal othind,
        by(female) weight(1) 
        detail(groupdem:age00 msa ctrlcity north_central south00 west hispanic black,
        groupaf:afqtp89, 
        grouped:sch_10 sch10_12 diploma_hs ged_hs bachelor_col master_col doctor_col ,
        groupfam:famrspb, 
        groupex:wkswk_18 yrsmil78_00 pcntpt_22 ,
        groupind:manuf  eduheal othind) ;
oaxaca rif_90 age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10 sch10_12 diploma_hs ged_hs bachelor_col master_col doctor_col  afqtp89 
        famrspb wkswk_18 yrsmil78_00 pcntpt_22  manuf  eduheal othind,
        by(female) weight(1) 
        detail(groupdem:age00 msa ctrlcity north_central south00 west hispanic black,
        groupaf:afqtp89, 
        grouped:sch_10 sch10_12 diploma_hs ged_hs bachelor_col master_col doctor_col ,
        groupfam:famrspb, 
        groupex:wkswk_18 yrsmil78_00 pcntpt_22 ,
        groupind:manuf  eduheal othind) ;


* perform the MM procedure for these quantiles using Melly's rqdeco ;
rqdeco lropc00  age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10   diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89 
        famrspb wkswk_18 yrsmil78_00 pcntpt_22  manuf  eduheal othind  
        , by(female)  quantiles(0.1 0.5 0.9) vce(none);

*use bootstrap option to get the se;
rqdeco lropc00  age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10   diploma_hs ged_hs smcol bachelor_col master_col doctor_col afqtp89 
        famrspb wkswk_18 yrsmil78_00 pcntpt_22  manuf  eduheal othind  
        , by(female)  quantiles(0.1 0.5 0.9)
    vce(boot) reps(100) noprint;
matrix list r(se);
