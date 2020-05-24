#delimit ;
set more off;

******;
use temp01, clear;
sort time;
summ time [weight=eweight] ;
gen pbar=r(mean);

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
gen cdvar=var_1-var_0;
gen cdgini=gini_1-gini_0;

*compute weights; 
* interactions;
gen uned0=ed0*covered; gen uned1=ed1*covered; gen uned2=ed2*covered;
gen uned4=ed4*covered; gen uned5=ed5*covered; gen unex1=ex1*covered;
gen unex2=ex2*covered; gen unex3=ex3*covered; gen unex4=ex4*covered;
gen unex6=ex6*covered; gen unex7=ex7*covered; gen unex8=ex8*covered;
gen unex9=ex9*covered;

*quadratic interactions;
gen ex1ed0=ed0*ex1; gen ex1ed1=ed1*ex1; gen ex1ed2=ed2*ex1;
gen ex1ed4=ed4*ex1; gen ex1ed5=ed5*ex1; gen ex2ed0=ed0*ex2;
gen ex2ed1=ed1*ex2; gen ex2ed2=ed2*ex2; gen ex2ed4=ed4*ex2;
gen ex2ed5=ed5*ex2; gen ex3ed0=ed0*ex3; gen ex3ed1=ed1*ex3;                
gen ex3ed2=ed2*ex3; gen ex3ed4=ed4*ex3; gen ex3ed5=ed5*ex3;
gen ex4ed0=ed0*ex4; gen ex4ed1=ed1*ex4; gen ex4ed2=ed2*ex4;
gen ex4ed4=ed4*ex4; gen ex4ed5=ed5*ex4; gen ex6ed0=ed0*ex6;
gen ex6ed1=ed1*ex6; gen ex6ed2=ed2*ex6; gen ex6ed4=ed4*ex6;
gen ex6ed5=ed5*ex6; gen ex7ed0=ed0*ex7; gen ex7ed1=ed1*ex7;                
gen ex7ed2=ed2*ex7; gen ex7ed4=ed4*ex7; gen ex7ed5=ed5*ex7;
gen ex8ed0=ed0*ex8; gen ex8ed1=ed1*ex8; gen ex8ed2=ed2*ex8;
gen ex8ed4=ed4*ex8; gen ex8ed5=ed5*ex8; gen ex9ed0=ed0*ex9;
gen ex9ed1=ed1*ex9; gen ex9ed2=ed2*ex9; gen ex9ed4=ed4*ex9;
gen ex9ed5=ed5*ex9;

***probit for year effect;                                   
probit time covered ed0 ed1 ed3 ed4 ed5 ex1-ex4 ex6-ex9  /*
   */ uned* unex* ex1ed* ex2ed* ex3ed* ex4ed* ex6ed* /*
   */ ex7ed* ex8ed* ex9ed* [iweight=eweight] ;
predict py0305, p;
summ py0305 , detail;
*do 83 reweigh 03;
gen phix0=(py0305)/(1-py0305)*((1-pbar)/pbar) if time==0;
replace phix0=phix0*eweight;  */sample weighted*/

*compute stats with weighted sample;
  sum lwage [weight=phix0] if time==0, detail;
  gen d9010_01=r(p90)-r(p10);
  gen d9050_01=r(p90)-r(p50);
  gen d5010_01=r(p50)-r(p10);
  gen var_01=r(sd)^2;
  fastgini lwage [w=phix0] if time==0;
  gen gini_01=r(gini);    
  gen cadginic=gini_1-gini_01;
  gen cad9010c=d9010_01-d9010_0;
  gen cad9050c=d9050_01-d9050_0;
  gen cad5010c=d5010_01-d5010_0;
  gen cadvarc=var_01-var_0;
  drop d9010_01 d9050_01 d5010_01 var_01 gini_01  ;


keep if _n==1;
keep cd* cad*  bs*;
save tempr, replace; 

foreach dif of numlist 5010 9010 9050 {;
use tempr, clear;
mkmat cd`dif' cad`dif'c , matrix(Rt`dif');
matrix list Rt`dif' ;
svmat Rt`dif';
gen wdif=`dif';
keep wdif bsloop Rt`dif'* ;
append using out_dfl`dif';
sort bsloop;
keep if _n<= bsloop+1.5;
save out_dfl`dif', replace;
}; 


use tempr, clear;
mkmat cdgini cadginic , matrix(Rtgini);
matrix list Rtgini ;
svmat Rtgini;
gen wdif="gini";
keep wdif bsloop Rtgini* ;
append using out_dflgini;
sort bsloop;
keep if _n<= bsloop+1.5;
save out_dflgini, replace;

use tempr, clear;
mkmat cdvar cadvarc , matrix(Rtvar);
matrix list Rtvar ;
svmat Rtvar;
gen wdif="var";
keep wdif bsloop Rtvar*; 
append using out_dflvar;
sort bsloop;
keep if _n<= bsloop+1.5;
save out_dflvar, replace;


