/*log file*/
proc printto log='/home/u63774111/Project/Project_2C/2C_Submission/TLF6.log';

proc import datafile='/home/u63774111/Project/Project_2C/AdamInput/ADRS.xls'
    out=adrs
    dbms=xls 
    replace;
    getnames=yes;
run;

data adrs;
set adrs;
where paramcd='BOR' and ITTFL='Y';
run;

data adrs1;
set adrs;
if avalc in ('CR','PR') THEN type=1;
else type=2;
output;
TRT01A='ALL';
output;
run;

data adrs2;
set adrs1;
length TRT $10.;
/*Keeping only required variables*/
keep USUBJID AGEGR1 TRT ORD AVALC NEREASN type;
if index(TRT01A, "CMP123")>0 then do;
   TRT="A";
   ORD=1;
   end;
if index(TRT01A, "Placebo")>0 then do;
   TRT="B";
   ORD=2;
   end;  
if index(TRT01A, "ALL")>0 then do;
   TRT="ALL";
   ORD=3;
   end;  
run;

proc sort data=adrs2;
by USUBJID ORD;
run;

proc sql noprint;
select count (distinct USUBJID) into : N1 - :N3 from adrs2
group by ORD
order by ORD;
quit;

%PUT &N1 &N2 &N3;

proc freq data=adrs2 nlevels;
tables AVALC;
run;

proc freq data=adrs2 nlevels;
tables AVALC*NEREASN;
where AVALC='NE';
run;

proc freq data=adrs2 nlevels;
tables AGEGR1;
run;

data grp1;
set adrs2;
where AGEGR1='<65';
run;

data grp2;
set adrs2;
where AGEGR1='>=65';
run;

proc freq data=grp1 noprint;
tables ORD*TRT*AVALC / out=grp1_avalc_freq (drop=PERCENT);
run;

data grp1_avalc_freq;
set grp1_avalc_freq;
length BOR1 $100.;
if AVALC='CR' then do;
   BOR1='COMPLETE RESPONSE (CR)';
   OD=2;
   end;
if AVALC='PR' then do;
   BOR1='PARTIAL RESPONSE (PR)';
   OD=3;
   end;
if AVALC='SD' then do;
   BOR1='STABLE DISEASE (SD)';
   OD=4;
   end;
if AVALC='PD' then do;
   BOR1='PROGRESSIVE DISEASE (PD)';
   OD=5;
   end;
if AVALC='NE' then do;
   BOR1='UNABLE TO DETERMINE (NE)';
   OD=6;
   end;
run;

proc sort data=grp1_avalc_freq;
by OD BOR1;
run;

proc transpose data=grp1_avalc_freq out=part2(drop=_:);
by OD BOR1 ;
id TRT;
var COUNT;
run;

proc freq data=grp2 noprint;
tables ORD*TRT*AVALC / out=grp2_avalc_freq (drop=PERCENT);
run;

data grp2_avalc_freq;
set grp2_avalc_freq;
length BOR1 $100.;

if AVALC='CR' then do;
   BOR1='COMPLETE RESPONSE (CR)';
   OD=2;
   end;
   
if AVALC='PR' then do;
   BOR1='PARTIAL RESPONSE (PR)';
   OD=3;
   end;
  
if AVALC='SD' then do;
   BOR1='STABLE DISEASE (SD)';
   OD=4;
   end;
   
if AVALC='PD' then do;
   BOR1='PROGRESSIVE DISEASE (PD)';
   OD=5;
   end;
   
if AVALC='NE' then do;
   BOR1='UNABLE TO DETERMINE (NE)';
   OD=6;
   end;
run;

proc sort data=grp2_avalc_freq;
by OD BOR1;
run;

proc transpose data=grp2_avalc_freq out=part2_1(drop=_:);
by OD BOR1 ;
id TRT;
var COUNT;
run;

data adrs3;
set adrs2;
where AVALC='NE';
run;

data grp1_1;
set adrs3;
where AGEGR1='<65';
run;

proc freq data=grp1_1 noprint;
tables ORD*TRT*NEREASN / out=grp1_nereasn_freq (drop=PERCENT);
run;

data grp1_nereasn_freq;
set grp1_nereasn_freq;
length BOR1 $100.;
if NEREASN='Death Before Measurement' then do;
   BOR1='     '||upcase(NEREASN);
   OD=7;
   end;
if NEREASN='Droped Study' then do;
   BOR1='     '||upcase(NEREASN);
   OD=8;
   end;
if NEREASN='Withdrown Consent' then do;
   BOR1='     '||upcase(NEREASN);
   OD=9;
   end;
run;

proc sort data=grp1_nereasn_freq;
by OD BOR1;
run;

proc transpose data=grp1_nereasn_freq out=part3(drop=_:);
by OD BOR1;
id TRT;
var COUNT;
run;

data grp2_1;
set adrs3;
where AGEGR1='>=65';
run;

proc freq data=grp2_1 noprint;
tables ORD*TRT*NEREASN / out=grp2_nereasn_freq (drop=PERCENT);
run;

data grp2_nereasn_freq;
set grp2_nereasn_freq;
length BOR1 $100.;
if NEREASN='Death Before Measurement' then do;
   BOR1='     '||upcase(NEREASN);
   OD=7;
   end;
if NEREASN='Droped Study' then do;
   BOR1='     '||upcase(NEREASN);
   OD=8;
   end;
if NERASN='Withdrown Consent' then do;
   BOR1='     '||upcase(NEREASN);
   OD=9;
   end;
run;

proc sort data=grp2_nereasn_freq;
by OD BOR1;
run;

proc transpose data=grp2_nereasn_freq out=part3_1(drop=_:);
by OD BOR1;
id TRT;
var COUNT;
run;

data part3_1;
retain OD BOR1 A B ALL;
set part3_1;
run;

data one;
set part2 part3;
length DRUGA DRUGB ALLP $15.;
IF A=. THEN
		DRUGA="  0 (0.0)";
	ELSE IF A=&N1 THEN
		DRUGA=PUT(A, 3.)||" (100)";
	ELSE
		DRUGA=PUT(A, 3.)||" ("||PUT (A/&N1*100, 4.1)||")";
	IF B=. THEN
		DRUGB="  0 (0.0)";
	ELSE IF B=&N2 THEN
		DRUGB=PUT(B, 3.)||" (100)";
	ELSE
		DRUGB=PUT(B, 3.)||" ("||PUT (B/&N2*100, 4.1)||")";
	IF ALL=. THEN
		ALLP="  0 (0.0)";
	ELSE IF ALL=&N3 THEN
		ALLP=PUT(ALL, 3.)||" (100)";
	ELSE
		ALLP=PUT(ALL, 3.)||" ("||PUT (ALL/&N3*100, 4.1)||")";
run;

data two;
set part2_1 part3_1;
length DRUGA DRUGB ALLP $15.;
IF A=. THEN
		DRUGA="  0 (0.0)";
	ELSE IF A=&N1 THEN
		DRUGA=PUT(A, 3.)||" (100)";
	ELSE
		DRUGA=PUT(A, 3.)||" ("||PUT (A/&N1*100, 4.1)||")";
	IF B=. THEN
		DRUGB="  0 (0.0)";
	ELSE IF B=&N2 THEN
		DRUGB=PUT(B, 3.)||" (100)";
	ELSE
		DRUGB=PUT(B, 3.)||" ("||PUT (B/&N2*100, 4.1)||")";
	IF ALL=. THEN
		ALLP="  0 (0.0)";
	ELSE IF ALL=&N3 THEN
		ALLP=PUT(ALL, 3.)||" (100)";
	ELSE
		ALLP=PUT(ALL, 3.)||" ("||PUT (ALL/&N3*100, 4.1)||")";
run;

proc means data=one sum noprint;
    where BOR1 in ('COMPLETE RESPONSE (CR)', 'PARTIAL RESPONSE (PR)');
    var A B ALL;
    output out=summary_sum sum=total_A total_B total_ALL;
run;

data _null_;
    set summary_sum;
    call symputx('total_A', total_A);
    call symputx('total_B', total_B);
    call symputx('total_ALL', total_ALL);
run;

data orr_grp1;
    retain OD;
    length BOR1 $30;
    BOR1 = 'OBJECTIVE RESPONSE RATE (1)';
    A = &total_A; 
    B = &total_B;
    ALL = &total_ALL;
    OD = 10;
    DRUGA = cat(&total_A,'/',&N1,' (',PUT (A/&N1*100, 4.1),'%)');
    DRUGB = cat(&total_B,'/',&N2,' (',PUT (B/&N2*100, 4.1),'%)');
    ALLP = cat(&total_ALL,'/',&N3,' (',PUT (ALL/&N3*100, 4.1),'%)');
run;

proc means data=two sum noprint;
    where BOR1 in ('COMPLETE RESPONSE (CR)', 'PARTIAL RESPONSE (PR)');
    var A B ALL;
    output out=summary_sum sum=total_A total_B total_ALL;
run;

data _null_;
    set summary_sum;
    call symputx('total_A', total_A);
    call symputx('total_B', total_B);
    call symputx('total_ALL', total_ALL);
run;

data orr_grp2;
    retain OD;
    length BOR1 $30;
    BOR1 = 'OBJECTIVE RESPONSE RATE (1)';
    A = &total_A;
    B = &total_B;
    ALL = &total_ALL;
    OD = 10;
    DRUGA = cat(&total_A,'/',&N1,' (',PUT (A/&N1*100, 4.1),'%)');
    DRUGB = cat(&total_B,'/',&N2,' (',PUT (B/&N2*100, 4.1),'%)');
    ALLP = cat(&total_ALL,'/',&N3,' (',PUT (ALL/&N3*100, 4.1),'%)');
run;

proc sort data=grp1;
by TRT;
run;

ods output OneWayFreqs=freq3_age1(rename=(frequency=count))
           BinomialCLs=binomialCL_age1 (where=(Type="Clopper-Pearson (Exact)"));       
proc freq data = grp1;
by TRT;
tables type/binomial (ac wilson exact) nocol norow nopercent;
run;
ods output close;

data binomialCL_age1(keep=OD BOR1 TRT CI);
retain OD BOR1 TRT CI;
set binomialCL_age1;
BOR1='(95% CI)';
OD=11;
CI = '('||put(round(LowerCL,0.0001),6.4)||', '||put(round(UpperCL,0.0001),6.4)||')';
run;

proc transpose data=binomialCL_age1 out=CI_grp1;
by OD BOR1;
id TRT;
var CI;
run;

data CI_grp1(drop=_: rename=(A=DRUGA B=DRUGB ALL=ALLP));
retain OD BOR1 DRUGA DRUGB ALLP;
set CI_grp1;
run;

proc sort data=grp2;
by TRT;
run;

ods output OneWayFreqs=freq3_age2(rename=(frequency=count))
           BinomialCLs=binomialCL_age2 (where=(Type="Clopper-Pearson (Exact)"));
proc freq data = grp2;
by TRT;
tables type/binomial (ac wilson exact) nocol norow nopercent;
run;
ods output close;

data binomialCL_age2(keep=OD BOR1 TRT CI);
retain OD BOR1 TRT CI;
set binomialCL_age2;
BOR1='(95% CI)';
OD=11;
CI = '('||put(round(LowerCL,0.0001),6.4)||', '||put(round(UpperCL,0.0001),6.4)||')';
run;

proc transpose data=binomialCL_age2 out=CI_grp2;
by OD BOR1;
id TRT;
var CI;
run;

data CI_grp2(drop=_: rename=(A=DRUGA B=DRUGB ALL=ALLP));
retain OD BOR1 DRUGA DRUGB ALLP;
set CI_grp2;
run;

data line1;
OD=1;
BOR1='BEST OVERALL RESPONSE';
run;

data one_(drop= A B ALL);
length BOR1 $100. DRUGA DRUGB ALLP $20.;
set line1 one orr_grp1 CI_grp1;
run;

data two_(drop= A B ALL);
length BOR1 $100. DRUGA DRUGB ALLP $20.;
set line1 two orr_grp2 CI_grp2;
run;

options nodate;
ods pdf file="/home/u63774111/Project/Project_2C/2C_Submission/BORTable.pdf";
title1 bold font="Arial" height=10pt "Table 13";
title2 bold font="Arial" height=10pt "Best Overall Response per Investigator by Age Category";
title3 bold font="Arial" height=10pt "ITT Subjects";
title4 '  ';
title5 '  ';
title6 lspace=3 height=0.8 JUSTIFY=left font='Arial' "Subgroup: Age Category - <65";
proc report data=one_ headskip headline spacing=2 nowd split='|';
columns OD BOR1 ("Number of Subjects (%)|_________________________" DRUGA DRUGB ALLP);
define OD / order noprint;
define BOR1 / display '' style(column)=[cellwidth=150pt];
define DRUGA / display "CMP123 | (N=&N1)" style(column)=[cellwidth=100pt];
define DRUGB / display "Placebo | (N=&N2)" style(column)=[cellwidth=100pt];
define ALLP / display "Total | (N=&N3)" style(column)=[cellwidth=100pt];
compute after _page_;
        line '_________________________________________________________________________________________';
        line '(1): 95% confidence interval computed using Clopper-Pearson approach.                              ';
    endcomp;
run;
title1 BOLD font="Arial" height=10pt "Table 13";
title2 BOLD font="Arial" height=10pt "Best Overall Response per Investigator by Age Category";
title3 BOLD font="Arial" height=10pt "ITT Subjects";
title4 '  ';
title5 '  ';
title6 lspace=3 height=0.8 JUSTIFY=left font='Arial' "Subgroup: Age Category - >=65";
proc report data=two_ headskip headline spacing=2 nowd split='|';
columns OD BOR1 ("Number of Subjects (%)|_________________________" DRUGA DRUGB ALLP);
define OD / order noprint;
define BOR1 / display '' style(column)=[cellwidth=150pt];
define DRUGA / display "CMP123 | (N=&N1)" style(column)=[cellwidth=100pt];
define DRUGB / display "Placebo | (N=&N2)" style(column)=[cellwidth=100pt];
define ALLP / display "Total | (N=&N3)" style(column)=[cellwidth=100pt];
compute after _page_;
        line '_________________________________________________________________________________________';
        line "(1): 95% confidence interval computed using Clopper-Pearson approach.                              ";
    endcomp;
run;
ods PDF close;
