proc printto log='/home/u63774111/Project/Project_2C/2C_Submission/TLF4.log';

libname tlfip "/home/u63774111/Project/Project_2C/TLF_input";
libname adtlf xport "/home/u63774111/Project/Project_2C/AdamInput/ADLBSI.xpt" 
	access=readonly;
proc copy inlib=adtlf outlib=tlfip;
run;

data adlbsi;
set tlfip.adlbsi;
where ADY>=1 and ABLFL^='Y' and ANL01FL='Y' and PARCAT2='SI' and SAFFL='Y';
run;

data adlb;
set adlbsi;
where TRT01A='CMP-135';
run;

data adlb1;
set adlbsi;
where TRT01A='Placebo';
run;

data adlb;
keep USUBJID SUBJID labtest labtestcd ATOXDIR BTOXDIR ATOXGR BTOXGR TRT01A ontreat ANL01FL SAFFL ABLFL ADY AVALC;
length testdes $40 testnm $8 ontreat $1;
set adlb;
where PARAMCD in ('CALPS', 'CALTS', 'CASTS', 'CBILIS', 'CBUNS', 'CCREATS', 'CKS', 'CMGS', 'CSODIUMS', 'UPROTN');
labtest = strip(scan(PARAM,2,'|(')); 
lnparamcd = length(PARAMCD);
end = lnparamcd-2;
labtestcd = strip(substr(PARAMCD,2,END));
if ADY>=1 then ontreat='Y';
else ontreat='';
run;

data adlb1;
keep USUBJID SUBJID labtest labtestcd ATOXDIR BTOXDIR ATOXGR BTOXGR TRT01A ontreat ANL01FL SAFFL ABLFL ADY AVALC;
length testdes $40 testnm $8 ontreat $1;
set adlb1;
where PARAMCD in ('CALPS', 'CALTS', 'CASTS', 'CBILIS', 'CBUNS', 'CCREATS', 'CKS', 'CMGS', 'CSODIUMS', 'UPROTN');
labtest = strip(scan(PARAM,2,'|(')); 
lnparamcd = length(PARAMCD);
end = lnparamcd-2;
labtestcd = strip(substr(PARAMCD,2,END));
if ADY>=1 then ontreat='Y';
else ontreat='';
run;

proc freq data=adlb;
tables labtest*labtestcd / list norow nopercent missing;
run;

proc freq data=adlb1;
tables labtest*labtestcd / list norow nopercent missing;
run;

proc freq data=adlb;
tables BTOXDIR BTOXGR ATOXDIR ATOXGR;
run;

proc freq data=adlb1;
tables BTOXDIR BTOXGR ATOXDIR ATOXGR;
run;

data rpt;
set adlb;
if labtestcd in ('SODIUM', 'K', 'MG') then do;
   if BTOXDIR='' then do;
      BTOXDIR='L';
      BTOXGR='0';
      end;
   if ATOXDIR='' then do;
      ATOXDIR='L';
      ATOXGR='0';
      end;
   end;
if labtestcd in ('ALP', 'ALT', 'AST', 'BILI', 'BUN', 'CREAT','PROT') then do;
   if BTOXDIR='' then do;
      BTOXDIR='H'; 
      BTOXGR='0'; 
      end;
   if ATOXDIR='' then do;
      ATOXDIR='H';
      ATOXGR='0'; 
      end;
   end;
run;

proc freq data=rpt;
tables BTOXDIR BTOXGR ATOXDIR ATOXGR;
run;

proc print data=rpt;
where BTOXGR is missing;
run;

data rpt1;
set adlb1;
if labtestcd in ('SODIUM', 'K', 'MG') then do;
   if BTOXDIR='' then do;
      BTOXDIR='L';
      BTOXGR='0'; 
      end;
   if ATOXDIR='' then do;
      ATOXDIR='L'; 
      ATOXGR='0';
      end;
   end;
if labtestcd in ('ALP', 'ALT', 'AST', 'BILI', 'BUN', 'CREAT', 'PROT') then do;
   if BTOXDIR='' then do;
      BTOXDIR='H';
      BTOXGR='0'; 
      end;
   if ATOXDIR='' then do;
      ATOXDIR='H'; 
      ATOXGR='0'; 
      end;
   end;
run;

proc freq data=rpt1;
tables BTOXDIR BTOXGR ATOXDIR ATOXGR;
run;

proc sort data=rpt out=rpt_base(keep=SUBJID labtestcd BTOXDIR BTOXGR TRT01A);
by SUBJID labtestcd BTOXGR BTOXDIR;
run;

data rpt_base_cmp;
set rpt_base;
by SUBJID labtestcd BTOXGR BTOXDIR;
if last.labtestcd;
run;

proc sort data=rpt1 out=rpt_base1(keep=SUBJID labtestcd BTOXDIR BTOXGR TRT01A);
by SUBJID labtestcd BTOXGR BTOXDIR;
run;

data rpt_base_placebo;
set rpt_base1;
by SUBJID labtestcd BTOXGR BTOXDIR;
if last.labtestcd;
run;

proc sort data=rpt out=rpt_post(keep=SUBJID labtestcd ATOXDIR ATOXGR TRT01A);
by SUBJID labtestcd ATOXGR ATOXDIR;
run;

data rpt_post_cmp;
set rpt_post;
by SUBJID labtestcd ATOXGR ATOXDIR;
if last.labtestcd;
run;

proc sort data=rpt1 out=rpt_post1(keep=SUBJID labtestcd ATOXDIR ATOXGR TRT01A);
by SUBJID labtestcd ATOXGR ATOXDIR;
run;

data rpt_post_placebo;
set rpt_post1;
by SUBJID labtestcd ATOXGR ATOXDIR;
if last.labtestcd;
run;

proc sort data=rpt_base_cmp;
by SUBJID labtestcd;
run;

proc sort data=rpt_post_cmp;
by SUBJID labtestcd;
run;

data rpt_final(drop=BTOXGR ATOXGR);
merge rpt_base_cmp(in=a) rpt_post_cmp(in=b);
by SUBJID labtestcd;
if a and b;
btoxgr1=BTOXGR;
if labtestcd in ('SODIUM', 'K', 'MG') and BTOXDIR='H' then btoxgr1= 9;
atoxgr1=ATOXGR;
if labtestcd in ('SODIUM', 'K', 'MG') and ATOXDIR='H' then atoxgr1= 9;
run;

proc freq data=rpt_final;
tables labtestcd*BTOXDIR*btoxgr1 / list;
run;

proc freq data=rpt_final;
tables labtestcd*ATOXDIR*atoxgr1 / list;
run;

proc sort data=rpt_base_placebo;
by SUBJID labtestcd;
run;

proc sort data=rpt_post_placebo;
by SUBJID labtestcd;
run;

data rpt_final1(drop=BTOXGR ATOXGR);
merge rpt_base_placebo(in=a) rpt_post_placebo(in=b);
by SUBJID labtestcd;
if a and b;
btoxgr1=BTOXGR;
if labtestcd in ('SODIUM', 'K', 'MG') and BTOXDIR='H' then btoxgr1= 9;
atoxgr1=ATOXGR;
if labtestcd in ('SODIUM', 'K', 'MG') and ATOXDIR='H' then atoxgr1= 9;
run;

proc freq data=rpt_final1;
tables labtestcd*BTOXDIR*btoxgr1 / list;
run;

proc freq data=rpt_final1;
tables labtestcd*ATOXDIR*atoxgr1 / list;
run;

proc sort data=rpt_final nodupkey out=denom;
by SUBJID TRT01A labtestcd BTOXDIR btoxgr1;
run;

proc freq data=denom;
table TRT01A*labtestcd*BTOXDIR*btoxgr1/out=bign(rename=(count=bign)drop=percent) missing list nopercent norow nocol;
run;

proc sort data=rpt_final1 nodupkey out=denom1;
by SUBJID TRT01A labtestcd BTOXDIR btoxgr1;
run;

proc freq data=denom1;
table TRT01A*labtestcd*BTOXDIR*btoxgr1/out=bign1(rename=(count=bign1)drop=percent) missing list nopercent norow nocol;
run;

data a;
set bign1;
run;

proc sort data=rpt_final;
by TRT01A labtestcd BTOXDIR;
run;

proc freq data=rpt_final;
table TRT01A*labtestcd*BTOXDIR*btoxgr1*atoxgr1/out=stats;
run;

data a;
set stats;
run;

proc transpose data=stats out=transp_stats(drop=_:) prefix=col;
by TRT01A labtestcd BTOXDIR btoxgr1;
id atoxgr1;
var COUNT;
run;

proc sort data=rpt_final1;
by TRT01A labtestcd BTOXDIR;
run;

proc freq data=rpt_final1;
table TRT01A*labtestcd*BTOXDIR*btoxgr1*atoxgr1/out=stats1;
run;

data b;
set stats1;
run;

proc transpose data=stats1 out=transp_stats1(drop=_:) prefix=col;
by TRT01A labtestcd BTOXDIR btoxgr1;
id atoxgr1;
var COUNT;
run;

proc sort data=stats nodupkey out=template(keep=TRT01A labtestcd BTOXDIR);
by TRT01A labtestcd BTOXDIR;
run;

proc sort data=stats1 nodupkey out=template1(keep=TRT01A labtestcd BTOXDIR);
by TRT01A labtestcd BTOXDIR;
run;

data template;
length btoxgr1 $1;
set template;
by TRT01A labtestcd BTOXDIR;
if (labtestcd in ('SODIUM','K','MG')and BTOXDIR='L') or
labtestcd in ('ALP','ALT','AST','BILI','BUN','CREAT','PROT') then do;
     btoxgr1='0';
     output;
     btoxgr1='1';
     output;
     btoxgr1='2';
     output;
     btoxgr1='3';
     output;
     btoxgr1='4';
     output;
     end;
else if labtestcd in ('SODIUM','K','MG') and BTOXDIR='H' then do;
     btoxgr1='9';
     output;
     end;
run;

data template1;
length btoxgr1 $1;
set template1;
by TRT01A labtestcd BTOXDIR;
if (labtestcd in ('SODIUM','K','MG')and BTOXDIR='L') or
labtestcd in ('ALP','ALT','AST','BILI','BUN','CREAT','PROT') then do;
     btoxgr1='0';
     output;
     btoxgr1='1';
     output;
     btoxgr1='2';
     output;
     btoxgr1='3';
     output;
     btoxgr1='4';
     output;
     end;
else if labtestcd in ('SODIUM','K','MG') and BTOXDIR='H' then do;
     btoxgr1='9';
     output;
     end;
run;

data template;
set template;
col0=0;
col1=0;
col2=0;
col3=0;
col4=0;
col9=0;
run;

data template1;
set template1;
col0=0;
col1=0;
col2=0;
col3=0;
col4=0;
col9=0;
run;

proc sort data=template;
by TRT01A labtestcd BTOXDIR btoxgr1;
run;

proc sort data=template1;
by TRT01A labtestcd BTOXDIR btoxgr1;
run;
  
proc format;
invalue $testordf (notsorted)
'SODIUM' = 1
'K'      = 2
'MG'     = 3
'ALP'    = 4
'AST'    = 5
'ALT'    = 6
'BILI'   = 7
'BUN'    = 8
'CREAT'  = 9
'PROT'   = 10;
run;

data cmp(drop=testord1);
length gr0-gr4 gr9 $12;
merge template(in=a) transp_stats bign;
by TRT01A labtestcd BTOXDIR btoxgr1;
if a;
if col0 > 0 then gr0= put(col0,3.)||' ('||strip(put(100*col0/bign,5.1))||'%)';
else gr0='   '||'0 (0.0%)';
if col1 > 0 then gr1= put(col1,3.)||' ('||strip(put(100*col1/bign,5.1))||'%)';
else gr1='   '||'0 (0.0%)';
if col2 > 0 then gr2= put(col2,3.)||' ('||strip(put(100*col2/bign,5.1))||'%)';
else gr2='   '||'0 (0.0%)';
if col3 > 0 then gr3= put(col3,3.)||' ('||strip(put(100*col3/bign,5.1))||'%)';
else gr3='   '||'0 (0.0%)';
if col4 > 0 then gr4= put(col4,3.)||' ('||strip(put(100*col4/bign,5.1))||'%)';
else gr4='   '||'0 (0.0%)';
if col9 > 0 then gr9= put(col9,3.)||' ('||strip(put(100*col9/bign,5.1))||'%)';
else gr9='   '||'0 (0.0%)';
if bign=. then bign=0;
testord1 = input(labtestcd,$testordf.);
testord= input(testord1,best.);
run;

proc sort data=cmp out=sort_cmp;
by TRT01A testord labtestcd descending BTOXDIR descending btoxgr1;
run;

data placebo(drop=testord1);
length gr0-gr4 gr9 $12;
merge template1(in=a) transp_stats1 bign1;
by TRT01A labtestcd BTOXDIR btoxgr1;
if a;
if col0 > 0 then gr0= put(col0,3.)||' ('||strip(put(100*col0/bign1,5.1))||'%)';
else gr0='   '||'0 (0.0%)';
if col1 > 0 then gr1= put(col1,3.)||' ('||strip(put(100*col1/bign1,5.1))||'%)';
else gr1='   '||'0 (0.0%)';
if col2 > 0 then gr2= put(col2,3.)||' ('||strip(put(100*col2/bign1,5.1))||'%)';
else gr2='   '||'0 (0.0%)';
if col3 > 0 then gr3= put(col3,3.)||' ('||strip(put(100*col3/bign1,5.1))||'%)';
else gr3='   '||'0 (0.0%)';
if col4 > 0 then gr4= put(col4,3.)||' ('||strip(put(100*col4/bign1,5.1))||'%)';
else gr4='   '||'0 (0.0%)';
if col9 > 0 then gr9= put(col9,3.)||' ('||strip(put(100*col9/bign1,5.1))||'%)';
else gr9='   '||'0 (0.0%)';
if bign1=. then bign1=0;
testord1 = input(labtestcd,$testordf.);
testord= input(testord1,best.);
run;

proc sort data=placebo out=sort_placebo;
by TRT01A testord labtestcd descending BTOXDIR descending btoxgr1;
run;

proc format;
value $lbtstnm (notsorted)
'SODIUM' = 'Sodium (mmol/L)'
'K' = 'Potassium (mmol/L)'
'MG' = 'Magnesium (mmol/L)'
'ALP' = 'Alkaline Phosphatase (U/L)'
'AST' = 'Aspartate Aminotransferase (U/L)'
'ALT' = 'Alanine Aminotransferase (U/L)'
'BILI' = 'Bilirubin (umol/L)'
'BUN' = 'Blood Urea Nitrogen (mmol/L)'
'CREAT' = 'Creatinine (umol/L)'
'PROT' = 'Urine Protein';
value $toxdir
'L' = 'Low'
'H' = 'High';
VALUE $gradef (notsorted)
'0' = '0'
'1' = '1'
'2' = '2'
'3' = '3'
'4' = '4'
'9' = '1-4';
run;

ods PDF file="/home/u63774111/Project/Project_2C/2C_Submission/LB_Table.pdf";
options nodate ls=140;
title1 "Table 14.3/10";
title2 "Change in Laboratory Events: Shift in NCI-CTC Grade from Baseline to Worst Post-Baseline Level";
title3 BOLD "Safety Event Patients";
title4 '  ';
title5 '  ';
title6 lspace=3 height=0.8 JUSTIFY=left font='Arial' "Treatment: CMP-135";
footnote2 j=l h=6pt  "Study PRJ5457C";
footnote3 j=l h=6pt  "TLG Specifications, Version v1.0";
proc report data=sort_cmp headskip missing headline spacing=2 nowd split='|';
COLUMNS labtestcd BTOXDIR btoxgr1 bign ("Post-Baseline NCI CTCAE Grade|____________________________________________" gr0 gr1 gr2 gr3 gr4 gr9);
define labtestcd/ order order=data "Lab Paramter" width=32 flow format=$lbtstnm.;
define BTOXDIR/order order=data "Lab Event" center width=11 format=$toxdir.;
define btoxgr1/order order=data "Baseline Grade" center width=8 format=$gradef.;
define bign/display width=4 "N";
define gr0/display width=11 "0" center;
define gr1/display width=11 "1" center;
define gr2/display width=11 "2" center;
define gr3/display width=11 "3" center;
define gr4/display width=11 "4" center;
define gr9/display width=19 "Other|(value > ULN)" center;
break after labtestcd/skip;
run;


options nodate ls=140;

title1 BOLD "Table 14.3/10";
title2 BOLD "Change in Laboratory Events: Shift in NCI-CTC Grade from Baseline to Worst Post-Baseline Level";
title3 BOLD "Safety Event Patients";
title4 '  ';
title5 '  ';
title6 lspace=3 height=0.8 JUSTIFY=left font='Arial' "Treatment: Placebo";
proc report data=sort_placebo headskip missing headline spacing=2 nowd split='|';
COLUMNS labtestcd BTOXDIR btoxgr1 bign1 ("Post-Baseline NCI CTCAE Grade|___________________________________________" gr0 gr1 gr2 gr3 gr4 gr9);
define labtestcd/ order order=data "Lab Paramter" width=32 flow format=$lbtstnm.;
define BTOXDIR/order order=data "Lab Event" center width=11 format=$toxdir.;
define btoxgr1/order order=data "Baseline Grade" center width=8 format=$gradef.;
define bign1/display width=4 "N";
define gr0/display width=11 "0" center;
define gr1/display width=11 "1" center;
define gr2/display width=11 "2" center;
define gr3/display width=11 "3" center;
define gr4/display width=11 "4" center;
define gr9/display width=19 "Other|(value > ULN)" center;
break after labtestcd/skip;
run;

ods PDF close;
ods listing;
