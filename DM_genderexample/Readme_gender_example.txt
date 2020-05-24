This archive contains the data and programs used to construct Tables 2-4 from the "Decomposition Methods" chapter.

The data is an extract from the NLSY79 used by O'Neill and O'Neill (2005) "What Do Wage Differentials Tells us about
Labor Market Discrimination?" NBER WP 11240.

The following *.do file are runned from Stata 
DM_gender_T23.do  computes the output for Table 2 and Table3
DM_gender_T4.do  computes the output for Table 4
DM_gender_T4_bootrif.do performs the bootstrap of the RIF se for Table 4

The computation make use to the following ado files, which need to be copied along with the help files in the relevant directories in  your 
Stata ado directories
for example "oaxaca.ado" would be copied in "c:\ado\plus\o\" 
and "rqdeco" would be copied in "c:\ado\plus\r\"

