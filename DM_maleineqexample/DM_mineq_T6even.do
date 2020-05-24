#delimit ;
set more off;
set mem 500m;
log using DM_mineq_T6even.log, replace;

use usmen0305_occ_10;
drop marr nonwhite uhrswk class alloc pub occ* ind*;
gen time=1; 
save temp1, replace;
use usmen8385_occ_10,clear;
drop marr nonwhite uhrswk class alloc pub occ* ind*;
gen time=0; 
save temp0, replace ;
*** use artificial time=2 to store reweighted sample;
replace time=2; 
append using temp0;
append using temp1;
save temp012,replace;

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
   */ ex7ed* ex8ed* ex9ed* [iweight=eweight] if time==0 | time==1 ;
predict py0305, p;
summ py0305 , detail;
summ time [weight=eweight] if time==0 | time==1 ;
gen pbar=r(mean);
replace eweight=eweight*py0305/(1-py0305)*((1-pbar)/pbar)  if time==2;

forvalues it = 0(1)2 {	;
** get rif for 10, 50 and 90 centiles;
pctile valx=lwage if time==`it' [aweight=eweight], nq(100) ;
kdensity lwage [aweight=eweight] if time==`it', at(valx) gen(evalt`it' denst`it') width(0.065) nograph ;
 forvalues qt = 10(40)90 {	;
 local qc = `qt'/100.0;
 gen rif`it'_`qt'=evalt`it'[`qt']+`qc'/denst`it'[`qt'] if lwage>=evalt`it'[`qt'] & time==`it';
 replace rif`it'_`qt'=evalt`it'[`qt']-(1-`qc')/denst`it'[`qt'] if lwage<evalt`it'[`qt']& time==`it';
  };
 drop valx;

** get rif for gini and variance;
foreach stat of newlist gini var {;
rifreg lwage covered ed0-ed1 ed3-ed5 ex1-ex4 ex6-ex9 
   [aweight=eweight] if time==`it' , `stat' retain(rif`it'_`stat');
   };
sum lwage [weight=eweight] if time==`it' , detail;
gen var_`it'=r(sd)^2;
fastgini lwage [w=eweight] if time==`it' ; 
gen gini_`it'=r(gini); 

}; 

drop eval* denst*;

gen rifat=.;
forvalues qt = 10(40)90 {	;
di "evaluating quantile= " `qt';
** get decomposition without reweighing [E(X_1|t=1)- E(X_0|t=0)]B_0   ;
 replace rifat=rif0_`qt' if time==0;
 replace rifat=rif1_`qt' if time==1;
 oaxaca rifat covered ed0 ed1 ed3 ed4 ed5 ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 
   [aweight=eweight] if time==0 | time==1, 
        by(time) weight(1) 
        detail(groupun:covered,
        grouped:ed0 ed1 ed3 ed4 ed5 ,
        groupex:ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 ); 
matrix Ra`qt'=e(b);


replace rifat=.;
*** get composition effects with reweighing [E(X_0|t=1)- E(X_0|t=0)]B_c  as explained in ;
 replace rifat=rif2_`qt' if time==2;
 replace rifat=rif0_`qt' if time==0;
 oaxaca rifat covered ed0 ed1 ed3 ed4 ed5 ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 
[aweight=eweight] if time==0 | time==2,  
        by(time) weight(1) 
        detail(groupun:covered,
        grouped:ed0 ed1 ed3 ed4 ed5 ,
        groupex:ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 ); 
matrix Rc=e(b);

 
replace rifat=.;
*** get wage structure effects E(X_1|t=1)*[B_1-B_c]  as unexplained in ;
 replace rifat=rif1_`qt' if time==1;
 replace rifat=rif2_`qt' if time==2;
 oaxaca rifat covered ed0 ed1 ed3 ed4 ed5 ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 
 [aweight=eweight] if time==1 | time==2,  
        by(time) weight(0) 
        detail(groupun:covered,
        grouped:ed0 ed1 ed3 ed4 ed5 ,
        groupex:ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 ); 
matrix Rw=e(b);
matrix Rcrwer=Ra`qt'[1,7]-Rc[1,7];
matrix colnames Rcrwer = Rwerror;
matrix Rwc=Rw[1,11];
matrix colnames Rwc = constant;
matrix Rt`qt'=Ra`qt'[1,1..3],Rc[1,4..7],-Rw[1,8..10],-Rwc,-Rw[1,12],Rcrwer;
matrix list Rt`qt';
 };       


foreach qt of newlist gini var {;
*di "evaluating stat= " `qt';
** get decomposition without reweighing [E(X_1|t=1)- E(X_0|t=0)]B_0   ;
 replace rifat=rif0_`qt' if time==0;
 replace rifat=rif1_`qt' if time==1;
 oaxaca rifat covered ed0 ed1 ed3 ed4 ed5 ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 
   [aweight=eweight] if time==0 | time==1, 
        by(time) weight(1) 
        detail(groupun:covered,
        grouped:ed0 ed1 ed3 ed4 ed5 ,
        groupex:ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 ); 
matrix Ra`qt'=e(b);


replace rifat=.;
*** get composition effects with reweighing [E(X_0|t=1)- E(X_0|t=0)]B_c  as explained in ;
 replace rifat=rif2_`qt' if time==2;
 replace rifat=rif0_`qt' if time==0;
 oaxaca rifat covered ed0 ed1 ed3 ed4 ed5 ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 
[aweight=eweight] if time==0 | time==2,  
        by(time) weight(1) 
        detail(groupun:covered,
        grouped:ed0 ed1 ed3 ed4 ed5 ,
        groupex:ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 ); 
matrix Rc=e(b);

 
replace rifat=.;
*** get wage structure effects E(X_1|t=1)*[B_1-B_c]  as unexplained in ;
 replace rifat=rif1_`qt' if time==1;
 replace rifat=rif2_`qt' if time==2;
 oaxaca rifat covered ed0 ed1 ed3 ed4 ed5 ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 
 [aweight=eweight] if time==1 | time==2,  
        by(time) weight(0) 
        detail(groupun:covered,
        grouped:ed0 ed1 ed3 ed4 ed5 ,
        groupex:ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 ); 
matrix Rw=e(b);
matrix Rcrwer=Ra`qt'[1,7]-Rc[1,7];
matrix colnames Rcrwer = Rwerror;
matrix Rwc=Rw[1,11];
matrix colnames Rwc = constant;
matrix Rt`qt'=Ra`qt'[1,1..3],Rc[1,4..7],-Rw[1,8..10],-Rwc,-Rw[1,12],Rcrwer;
matrix list Rt`qt';
 };       


matrix DR9010=Rt90-Rt10;
matrix DR9050=Rt90-Rt50;
matrix DR5010=Rt50-Rt10;
matrix DA9010=Ra90-Ra10;
matrix DA9050=Ra90-Ra50;
matrix DA5010=Ra50-Ra10;

matrix list DR9010;
matrix list DA9010;
matrix list DR5010;
matrix list DA5010;
matrix list DR9050;
matrix list DA9050;
matrix list Rtvar;
matrix list Ravar;
matrix list Rtgini;
matrix list Ragini;

