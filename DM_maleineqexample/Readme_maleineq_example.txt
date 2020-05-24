This archive contains the data and programs used to construct Tables 5-6 from the "Decomposition Methods" chapter.

The following *.do file are runned from Stata 
DM_mineq_T5ad.do computes DFL and RIF (no reweigh) decompositions for Table 5, Panel A and D and Table 6 odd columns
DM_mineq_T5bc.do computes Melly's counterfactual decomp for Table 5, Panel B and C
DM_mineq_T6even.do computes RIF with reweighting for Table 6 even columns

For faster results, none of the programs invokes the bootstrap options, these can be turned on as desired
for DFL and RIF, the easiest thing is to boostrap the entire procedure
as shown in
DM_mineq_bootT5a.do which uses DM_mineq_T5a4boot.do  

The computation make use to the following ado files, which need to be copied along with the accompanying help files in
the relevant directories in your Stata ado directories
For example, "counterfactual.ado" and "cdeco.ado" should be copied in "c:\ado\plus\c\" 
"fastgini.ado" should be copied in "c:\ado\plus\f\" 
"rifreg" should be copied in "c:\ado\plus\r\"

