#delimit ;
set more off;
set mem 500m;
program drop _all;
*clear mata;
log using DM_mineq_T5b.log, replace;
use usmen0305_occ;
gen time=1; 
append using usmen8385_occ;
drop marr nonwhite uhrswk class alloc pub occ* ind*;
replace time=0 if time~=1;

***first get raw wage differentials, variance and gini;
sum lwage [weight=eweight] if time==1, detail;
gen d9010_1=r(p90)-r(p10);
gen d9050_1=r(p90)-r(p50);
gen d5010_1=r(p50)-r(p10);
gen var_1=r(sd)^2;
fastgini lwage [w=eweight] if time==1; 
gen gini_1=r(gini); 

sum lwage [weight=eweight] if time==0, detail;
gen d9010_0=r(p90)-r(p10);
gen d9050_0=r(p90)-r(p50);
gen d5010_0=r(p50)-r(p10);
gen var_0=r(sd)^2;
fastgini lwage [w=eweight] if time==0; 
gen gini_0=r(gini); 

gen cd9010=d9010_1-d9010_0;
gen cd9050=d9050_1-d9050_0;
gen cd5010=d5010_1-d5010_0;
gen cvar=var_1-var_0;
gen chgini=gini_1-gini_0;
di " c9010=" cd9010 " c9050=" cd9050 " c5010=" cd5010 "
  cvar=" cvar " chgini=" chgini;

gen timeinv=1-time;
*do both with lpm and lpm as link;
*get fitted time0 and counterfactual distribution;
counterfactual lwage covered ed0 ed1 ed3 ed4 ed5 ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 
   [weight=eweight], group(time) method(lpm) quantiles(0.1 0.5 0.9) noboot;
matrix Rt=e(distributions);
matrix list Rt;
* fitted time0 in column 5;
matrix Rf10=Rt[1,5]; matrix Rf50=Rt[2,5]; matrix Rf90=Rt[3,5];
svmat Rf10; svmat Rf50; svmat Rf90;
gen d9010_f0=Rf901-Rf101;
gen d9050_f0=Rf901-Rf501;
gen d5010_f0=Rf501-Rf101;
* counterfactual in column 9;
matrix Rc10=Rt[1,9]; matrix Rc50=Rt[2,9]; matrix Rc90=Rt[3,9];
svmat Rc10; svmat Rc50; svmat Rc90;
gen d9010_01=Rc901-Rc101;
gen d9050_01=Rc901-Rc501;
gen d5010_01=Rc501-Rc101;

* get composition effects as Fc:F01-Ff0;
gen cad9010c1=(d9010_01-d9010_f0);
gen cad9050c1=(d9050_01-d9050_f0);
gen cad5010c1=(d5010_01-d5010_f0);

*****;

*now invert time to get fitted time 1;
counterfactual lwage covered ed0 ed1 ed3 ed4 ed5 ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 
   [weight=eweight], group(timeinv) method(lpm) quantiles(0.1 0.5 0.9)  noboot;
matrix Rtinv=e(distributions);
matrix list Rtinv;
* fitted time1 in column 5;
matrix Rif10=Rtinv[1,5]; matrix Rif50=Rtinv[2,5];  matrix Rif90=Rtinv[3,5];
svmat Rif10; svmat Rif50; svmat Rif90;
gen d9010_f1=Rif901-Rif101;
gen d9050_f1=Rif901-Rif501;
gen d5010_f1=Rif501-Rif101;

* get total effects as F1-F0;
gen cad9010t=(d9010_f1-d9010_f0);
gen cad9050t=(d9050_f1-d9050_f0);
gen cad5010t=(d5010_f1-d5010_f0);

* wage structure will be total minus composition;
 
gen cad9010s=cad9010t-cad9010c1;
gen cad9050s=cad9050t-cad9050c1;
gen cad5010s=cad5010t-cad5010c1;

di "total effect"  " c9010=" cad9010t " c9050=" cad9050t " c5010=" cad5010t  ;
di "composition" " c9010=" cad9010c1 " c9050=" cad9050c1 " c5010=" cad5010c1  ;
di "wage structure"    " c9010=" cad9010s " c9050=" cad9050s " c5010=" cad5010s  ;


*now to obtain variance and gini get;
counterfactual lwage covered ed0 ed1 ed3 ed4 ed5 ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 
   [weight=eweight], group(time) method(lpm) qlow(0.01) qhigh(0.99) qstep(0.01) noboot;
matrix D=e(distributions);
matrix list D;
svmat D;

counterfactual lwage covered ed0 ed1 ed3 ed4 ed5 ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 
   [weight=eweight], group(timeinv) method(lpm) qlow(0.01) qhigh(0.99) qstep(0.01) noboot;
matrix Dinv=e(distributions);
matrix list Dinv;
svmat Dinv;

drop if D1==.;
sum D5, detail;
gen varf0=r(Var);
fastgini D5;
gen ginif0=r(gini);

sum Dinv5, detail;
gen varf1=r(Var);
fastgini Dinv5;
gen ginif1=r(gini);

sum D9, detail;
gen varc=r(Var);
fastgini D9 ;
gen ginic=r(gini);

* get composition effects as Fc:F01-Ff0;
gen cginic=ginic-ginif0;
gen cvarc=varc-varf0;

* get total effects as F1-F0;
gen cginift=ginif1-ginif0;
gen cvarft=varf1-varf0;

* wage structure will be total minus composition;
gen cginis=cginift-cginic;
gen cvars=cvarft-cvarc;

di "total effect"  " cvar=" cvarft " cgini=" cginift  ;
di "composition" " cvar=" cvarc " cgini=" cginic  ;
di "wage structure"    " cvar=" cvars " cgini=" cginis ;

