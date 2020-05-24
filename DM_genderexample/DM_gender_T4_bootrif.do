#delimit ;
set more off;
set mem 700m;
program drop _all;

*define the program to do the bootstrap se;
    program define bsgenderif;
    version 6.0;
      {  ;
        local reps = `1';
        *** bootstrap loop;
                local j 1 ;
                di "bootstrap loop step " `j' ;                  
         while `j'<= `reps' { ;
                display  "doing rep `j' " ;
                use nlsy00_ind.dta;
                bsample;
                gen bsloop=`j';
                scalar bsrep=`reps' ;
                save tempg,replace;
       quietly  do DM_gender_rif4bs;
                local j = `j' + 1;
                };
                *** end j loop ;
                
       };
      display "bsgenderif done";
      end;

******;
* 1) begin by setting the no of reps below to 1 and save the output files for each of the quantile ;
* of interest as "out_genrif10.dta" "out_genrif50.dta" "out_genrif90.dta" ;
* 2) put back the no of reps to 100 (or the no of desired reps);
* 3) 100 estimates of the measures of interest will be found in the "out_genrif*.data" files;
* 4) use the summary command to compute the related se ;
******;
* number indicates no reps;
bsgenderif 100;

******;

