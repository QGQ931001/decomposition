#delimit ;
set more off;
use tempg.dta, clear;
drop if ind3<=0 | ind3>=990;
gen eduheal=0;
replace eduheal=1 if indd11==1 | indd13==1;
gen primary=0;
replace primary=1 if indd1==1 | indd2==1 | indd7==1 ;
gen manuf=0 ;
replace manuf=1 if indd3==1 | indd4==1;
gen othind=0;
replace othind=1 if indd5==1 | indd6==1 | indd8==1 | indd9==1 | indd10==1 | indd12==1;  
gen ind5sum=primary+manuf+eduheal+othind;
tab ind5sum;
drop if ind5sum==0;

*******;
sort female;
replace afqtp89=afqtp89/10.0;
forvalues qt = 10(40)90 {	;
   gen rif_`qt'=.;
};

sort female lropc00;
pctile eval1=lropc00 if female==1 , nq(100) ;
kdensity lropc00 if female==1, at(eval1) gen(evalf densf) width(0.10) nograph ;
forvalues qt = 10(40)90 {	;
 local qc = `qt'/100.0;
 replace rif_`qt'=evalf[`qt']+`qc'/densf[`qt'] if lropc00>=evalf[`qt'] & female==1;
 replace rif_`qt'=evalf[`qt']-(1-`qc')/densf[`qt'] if lropc00<evalf[`qt']& female==1;
};
pctile eval2=lropc00 if female==0, nq(100) ;
kdensity lropc00 if female==0, at(eval2) gen(evalm densm) width(0.10) nograph ;
forvalues qt = 10(40)90  {	;
 local qc = `qt'/100.0;
 replace rif_`qt'=evalm[`qt']+`qc'/densm[`qt'] if lropc00>=evalm[`qt'] & female==0;
 replace rif_`qt'=evalm[`qt']-(1-`qc')/densm[`qt'] if lropc00<evalm[`qt']& female==0;
};

sum female ;
forvalues qt = 10(40)90 {	;
   sum rif_`qt' if female==0;
   gen qlwm`qt'=r(mean);
   sum rif_`qt' if female==1;
   gen qlwf`qt'=r(mean);
   gen difq`qt'= qlwm`qt'-qlwf`qt';
   display difq`qt';

oaxaca rif_`qt' age00 msa ctrlcity north_central south00 west hispanic black 
	 sch_10 sch10_12 diploma_hs ged_hs bachelor_col master_col doctor_col  afqtp89 
        famrspb wkswk_18 yrsmil78_00 pcntpt_22  manuf  eduheal othind,
        by(female) weight(1) 
        detail(groupdem:age00 msa ctrlcity north_central south00 west hispanic black,
        groupaf:afqtp89, 
        grouped:sch_10 sch10_12 diploma_hs ged_hs bachelor_col master_col doctor_col ,
        groupfam:famrspb, 
        groupex:wkswk_18 yrsmil78_00 pcntpt_22 ,
        groupind:manuf  eduheal othind) ;
matrix Rt`qt'=e(b);
matrix list Rt`qt';
 };

keep if _n==1;
save tempgr, replace; 

forvalues qt = 10(40)90 {;
use tempgr, clear;
svmat Rt`qt';
keep bs* dif* Rt`qt'*;
gen qc=`qt'/100;
append using out_genrif`qt';
sort bsloop;
keep if _n<= bsloop+1.5;
save out_genrif`qt', replace;
}; 

