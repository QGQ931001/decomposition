#delimit ;
set more off;
set mem 500m;
log using DM_mineq_T5ad.log, replace;

******;
use usmen0305_occ;
gen time=1;
append using usmen8385_occ ;
replace time=0 if time~=1;
rename lwage1 lwage;
sort time;

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

*next do DFL procedure for Table 5, Panel A;
*begin with reweighting;
* interactions;
gen uned0=ed0*covered;
gen uned1=ed1*covered;               
gen uned2=ed2*covered;
gen uned4=ed4*covered;
gen uned5=ed5*covered;
gen unex1=ex1*covered;
gen unex2=ex2*covered;
gen unex3=ex3*covered;
gen unex4=ex4*covered;
gen unex6=ex6*covered;
gen unex7=ex7*covered;
gen unex8=ex8*covered;
gen unex9=ex9*covered;

*quadratic interactions;
gen ex1ed0=ed0*ex1;
gen ex1ed1=ed1*ex1;                
gen ex1ed2=ed2*ex1;
gen ex1ed4=ed4*ex1;
gen ex1ed5=ed5*ex1;
gen ex2ed0=ed0*ex2;
gen ex2ed1=ed1*ex2;                
gen ex2ed2=ed2*ex2;
gen ex2ed4=ed4*ex2;
gen ex2ed5=ed5*ex2;
gen ex3ed0=ed0*ex3;
gen ex3ed1=ed1*ex3;                
gen ex3ed2=ed2*ex3;
gen ex3ed4=ed4*ex3;
gen ex3ed5=ed5*ex3;
gen ex4ed0=ed0*ex4;
gen ex4ed1=ed1*ex4;                
gen ex4ed2=ed2*ex4;
gen ex4ed4=ed4*ex4;
gen ex4ed5=ed5*ex4;
gen ex6ed0=ed0*ex6;
gen ex6ed1=ed1*ex6;                
gen ex6ed2=ed2*ex6;
gen ex6ed4=ed4*ex6;
gen ex6ed5=ed5*ex6;
gen ex7ed0=ed0*ex7;
gen ex7ed1=ed1*ex7;                
gen ex7ed2=ed2*ex7;
gen ex7ed4=ed4*ex7;
gen ex7ed5=ed5*ex7;
gen ex8ed0=ed0*ex8;
gen ex8ed1=ed1*ex8;                
gen ex8ed2=ed2*ex8;
gen ex8ed4=ed4*ex8;
gen ex8ed5=ed5*ex8;
gen ex9ed0=ed0*ex9;
gen ex9ed1=ed1*ex9;                
gen ex9ed2=ed2*ex9;
gen ex9ed4=ed4*ex9;
gen ex9ed5=ed5*ex9;


***probit for year effect;                                   
probit time covered ed0 ed1 ed3 ed4 ed5 ex1-ex4 ex6-ex9  
    uned* unex* ex1ed* ex2ed* ex3ed* ex4ed* ex6ed* 
    ex7ed* ex8ed* ex9ed* [iweight=eweight] ;
predict py0305, p;
summ py0305 , detail;
summ time [weight=eweight] ;
gen pbar=r(mean);
gen phix0=(py0305)/(1-py0305)*((1-pbar)/pbar) if time==0;
*/sample weighted*/;
replace phix0=phix0*eweight;  

  sum lwage [weight=phix0] if time==0, detail;
  gen d9010_01=r(p90)-r(p10);
  gen d9050_01=r(p90)-r(p50);
  gen d5010_01=r(p50)-r(p10);
  gen var_01=r(sd)^2;
  fastgini lwage [w=phix0] if time==0;
  gen gini_01=r(gini);    
  gen chginic=(gini_01-gini_0);
* get composition effects as Fc:F01-F0;
  gen cad9010c1=(d9010_01-d9010_0);
  gen cad9050c1=(d9050_01-d9050_0);
  gen cad5010c1=(d5010_01-d5010_0);
  gen cavarc1=var_01-var_0;
  di " c9010=" cad9010c1 " c9050=" cad9050c1 " c5010=" cad5010c1 " 
       cvar=" cavarc1 " cgini=" chginic;

* do RIF regressions without reweighing for Table 5, Panel D and Table 6;
forvalues qt = 10(40)90 {	;
   gen rif1_`qt'=.; gen rif0_`qt'=.; gen rifc_`qt'=.;
};

sort time;
pctile eval=lwage if time==1 [aweight=eweight], nq(100) ;
kdensity lwage [aweight=eweight] if time==1, at(eval) gen(evalt1 denst1) width(0.065) nograph ;
forvalues qt = 10(40)90 {	;
 local qc = `qt'/100.0;
 replace rif1_`qt'=evalt1[`qt']+`qc'/denst1[`qt'] if lwage>=evalt1[`qt'] & time==1;
 replace rif1_`qt'=evalt1[`qt']-(1-`qc')/denst1[`qt'] if lwage<evalt1[`qt']& time==1;
};
sum rif1* [aweight=eweight];
drop eval;
pctile eval=lwage if time==0 [aweight=eweight], nq(100) ;
kdensity lwage [aweight=eweight] if time==0, at(eval) gen(evalt0 denst0) width(0.065) nograph ;
 forvalues qt = 10(40)90 {	;
 local qc = `qt'/100.0;
 replace rif0_`qt'=evalt0[`qt']+`qc'/denst0[`qt'] if lwage>=evalt0[`qt'] & time==0;
 replace rif0_`qt'=evalt0[`qt']-(1-`qc')/denst0[`qt'] if lwage<evalt0[`qt']& time==0;
};

gen rifat=.;
forvalues qt = 10(40)90 {	;
 display "doing quantile " `qt';
 replace rifat=rif0_`qt' if time==0;
 replace rifat=rif1_`qt' if time==1;
 oaxaca rifat covered ed0 ed1 ed3 ed4 ed5 ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 [aweight=eweight], 
        by(time) weight(1) 
        detail(groupun:covered,
        grouped:ed0 ed1 ed3 ed4 ed5 ,
        groupex:ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 ); 
matrix Rt`qt'=e(b);
 };       


matrix DR9010=Rt90-Rt10;
matrix DR9050=Rt90-Rt50;
matrix DR5010=Rt50-Rt10;
matrix list DR9010;
matrix list DR9050;
matrix list DR5010;


rifreg lwage covered ed0-ed1 ed3-ed5 ex1-ex4 ex6-ex9 
   [aweight=eweight] if time==0 , var retain(rif0_var);
rifreg lwage covered ed0-ed1 ed3-ed5 ex1-ex4 ex6-ex9 
   [aweight=eweight] if time==1 , var retain(rif1_var);

replace rifat=rif0_var if time==0;
replace rifat=rif1_var if time==1;
oaxaca rifat covered ed0 ed1 ed3 ed4 ed5 ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 [aweight=eweight], 
        by(time) weight(1) 
        detail(groupun:covered,
        grouped:ed0 ed1 ed3 ed4 ed5 ,
        groupex:ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 ); 
     
rifreg lwage covered ed0-ed1 ed3-ed5 ex1-ex4 ex6-ex9 
   [aweight=eweight] if time==0 , gini retain(rif0_gin);
rifreg lwage covered ed0-ed1 ed3-ed5 ex1-ex4 ex6-ex9 
   [aweight=eweight] if time==1 , gini retain(rif1_gin);

replace rifat=rif0_gin if time==0;
replace rifat=rif1_gin if time==1;
oaxaca rifat covered ed0 ed1 ed3 ed4 ed5 ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 [aweight=eweight], 
        by(time) weight(1) 
        detail(groupun:covered,
        grouped:ed0 ed1 ed3 ed4 ed5 ,
        groupex:ex1 ex2 ex3 ex4 ex6 ex7 ex8 ex9 ); 


