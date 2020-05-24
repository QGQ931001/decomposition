#delimit ;
set more off;
set mem 50m;
log using dfl8.log, replace;
******;
use men7988_cell;
******;** do graph 4a) for all males;
replace wage=wage*65.8/104.3 if year88==1; /*transform to 1979 dollars*/ 
gen lwage=log(wage);
*to simplify the kernel density estimation, it will be estimate only at 200 values;
sum lwage, detail;
gen xstep=(r(max)-r(min))/200;
*kwage will be the wage at which the density is estimated;
gen kwage=r(min)+(_n-1)*xstep if _n<=200;
gen hweight=eweight*uhrswk; /*hours weighted*/
kdensity lwage [aweight=hweight] if year88==1 , at(kwage) gauss width(0.065) 
     generate(w88 fd88) nograph ;
kdensity lwage [aweight=hweight] if year88==0 , at(kwage) gauss width(0.065) 
     generate(w79 fd79) nograph ;
label var fd88 "Men 1988";
label var fd79 "Men 1979";
label var kwage "Log(Wage)";
graph twoway (connected fd88 kwage if kwage>=0 & kwage<=3.91, msymbol(i) clwidth(medium)  ) 
      (connected fd79 kwage if kwage>=0 & kwage<=3.91, msymbol(i) lpattern(dash) clwidth(medium) ), 
       xlabel(.69 1.61 2.3 3.22) xline(0.748 1.065)scheme(sj) saving(dflfig4a,replace);
***graph for equivalent of Figure 4d ; 
***probit for year effect;                                            
probit year88 ee1-ee15 exper exper2 exper3 exper4 edex educ reg1-reg3
               ind1-ind18 occ1 occ2 nonwhite partt married smsa [pweight=eweight];
predict py88, p;
summ py88 , detail;
summ year88 [weight=eweight] ;
gen pbar=r(mean);
gen phix=((1-py88)/py88)*(pbar/(1-pbar)) if year88==1;
replace phix=phix*hweight;  */sample and hours weighted*/
**** reweighing for changes X2=all other variables besides education;
probit year88 exper exper2 exper3 exper4 reg1-reg3
               ind1-ind18 occ1 occ2 nonwhite partt married smsa [pweight=eweight];
predict py88noed, p;
sum py88noed, detail;
gen phix2=((1-py88)/py88)*(py88noed/(1-py88noed))*(pbar/(1-pbar)) if year88==1;
replace phix2=phix2*hweight;  */sample and hours weighted*/
****;
kdensity lwage [aweight=phix] if year88==1 , at(kwage) gauss width(0.065) 
     generate(w88x79 fd88x79) nograph ;
kdensity lwage [aweight=phix2] if year88==1 , at(kwage) gauss width(0.065) 
     generate(w88ed79 fd88ed79) nograph ;
label var fd88 "Men 1988";
label var fd88x79 "Men 1988x79";
label var fd88ed79 "Men 1988ed79";
label var kwage "Log(Wage)";
graph twoway (connected fd88 kwage if kwage>=0 & kwage<=3.91, msymbol(i) clwidth(medium)  ) 
      (connected fd88x79 kwage if kwage>=0 & kwage<=3.91, msymbol(i) lpattern(dash) clwidth(medium) )
      (connected fd88ed79 kwage if kwage>=0 & kwage<=3.91, msymbol(i) lpattern(longdash) clwidth(medium) ), 
       xlabel(.69 1.61 2.3 3.22) xline(0.748 1.065) scheme(sj) saving(dflfig4c,replace);
*****;
****distributional measures for 1988;
integ fd88 w88, generate(cint);
gen cent10=w88 if cint>.1 & cint[_n-1]<.1 & cint~=.;
sum cent10;
gen d10=r(mean);
gen cent90=w88 if cint>.9 & cint[_n-1]<.9 & cint~=.;
sum cent90;
gen d90=r(mean);
gen cent50=w88 if cint>.5 & cint[_n-1]<.5 & cint~=.;
sum cent50;
gen d50=r(mean);
gen d9010=d90-d10; di d9010;
gen d9050=d90-d50; di d9050;
gen d5010=d50-d10; di d5010;
***STANDARD DEVIATION OF LOG WAGES;
gen m1=w88*fd88;
integ m1 w88, generate(mint);
summ mint;
gen mrw=_result(6);
di mrw;
gen v1=((w88-mrw)^2)*fd88;
integ v1 w88, generate(vint);
summ vint;
gen var=_result(6);
di var;
gen std=sqrt(var);
di std;

