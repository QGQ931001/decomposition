#delimit ;
set more off;
set mem 700m;
program drop _all;

*define the program to do the bootstrap std;
    program define bsdfldecomp;
    version 6.0;
      {  ;
        local reps = `1';
        *** bootstrap loop;
                local j 1 ;
                di "bootstrap loop step " `j' ;                  
         while `j'<= `reps' { ;
                display  "doing rep `j' " ;
                use usmen0305_occ;
                drop marr nonwhite uhrswk class alloc pub occ* ind*;
                gen time=1; 
                bsample;
                save temp1, replace;
                use usmen8385_occ,clear;
                drop marr nonwhite uhrswk class alloc pub occ* ind*;
                gen time=0; 
                bsample;
                save temp0, replace ;
                append using temp1;
                gen bsloop=`j';
                scalar bsrep=`reps' ;
                save temp01,replace;
        quietly do DM_mineq_T5a4boot;
                local j = `j' + 1;
                };
                *** end j loop ;
                
       };
      display "bsdecomp done";
      end;

******;
******;
* 1) begin by setting the no of reps below to 1 and save the output files for each of the quantile ;
* of interest as "out_dfl9010.dta" "out_dfl9050.dta" "out_dfl5010.dta" "out_dflgini.dta" "out_dflvar.dta" ;
* 2) put back the no of reps to 100 (or the no of desired reps);
* 3) 100 estimates of the measures of interest will be found in the "out_genrif*.data" files;
* 4) use the summary command to compute the related se ;
******;

******;
* number indicates no reps;
bsdfldecomp 100;

******;


