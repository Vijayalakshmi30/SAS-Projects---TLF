proc printto log='/home/u63774111/Project/Project_2C/2C_Submission/TLF7.log';

proc import datafile='/home/u63774111/Project/Project_2C/AdamInput/ADEFF.xls'
    out=adeff
    dbms=xls 
    replace;
    getnames=yes;
run;

data adeff1;
keep USUBJID PARAM PARAMCD AVISITN AVISITN_1 AVAL Base CHG Trt01p Trt01an;
set adeff;
where ANL01FL='Y' and PARAMCD='VLOAD' and ITTFL='Y';
run;

PROC SQL NOPRINT;
	CREATE TABLE viralcounts AS SELECT AVISITN_1, Trt01p, COUNT (DISTINCT USUBJID) AS N 
	FROM ADEFF1 
	GROUP BY AVISITN_1, Trt01p;
QUIT;

proc sort data=adeff1;
by AVISITN AVISITN_1 Trt01p;
run;

proc means data=adeff1 n mean stderr;
    var AVAL;
    by AVISITN AVISITN_1 Trt01p;
    output out=table11(drop=_:) n=N mean=Mean stderr=StdErr;
run;

data table11(drop=Mean StdErr);
set table11;
Unadj_mean=cat(put(round(Mean,0.001),5.3),' (',put(round(StdErr,0.001),5.3),')');
run;

options nonumber nodate;
ods pdf file = '/home/u63774111/Project/Project_2C/2C_Submission/Table11.pdf';
title1 font="Arial" height=10pt 'Table 11:';
title2 ' ';
title3 font="Arial" height=10pt 'Summary of Viral Load over time';
title4 ' ';
title5 font="Arial" height=10pt 'ITT Population';
title6 ' ';

proc report data=table11 headline headskip nowd spacing=3 style=journal
            style(report) = [cellspacing=6 cellpadding=4]
            style(header)=[borderbottomcolor=black borderbottomwidth=0.5pt bordertopcolor=black bordertopwidth=0.5pt];
columns AVISITN AVISITN_1 Trt01p N Unadj_mean;
define AVISITN / order order=internal noprint;
define AVISITN_1 / group center  style(column)=[cellwidth=100pt] 'Test Day';
define Trt01p / display center  style(column)=[cellwidth=100pt] 'Treatment';
define N / display center  style(column)=[cellwidth=100pt] 'N';
define Unadj_mean / display center  style(column)=[cellwidth=100pt]'Unadjusted Mean (SE)';
compute after AVISITN_1;
line @1 " ";
line @1 " ";
endcomp;
compute after _page_;
line@1 "___________________________________________________________________________________________";
endcomp;
run;

data adeff2;
keep USUBJID PARAM PARAMCD AVISITN AVISITN_1 AVAL BASE CHG TRT01P TRT01AN;
set adeff1;
where AVISITN_1 in ('Week 12', 'Week 16');
run;

proc freq data=adeff2 noprint;
tables AVISITN_1*TRT01P / list out=bigN;
run;


ods select lsmeans;
proc mixed data=adeff2;
class AVISITN_1 TRT01P;
model CHG=AVISITN_1*TRT01P;
lsmeans AVISITN_1 * TRT01P;
ods output LSMeans=LSMeans;
run;
quit;

data means;
set lsmeans;
Estimate=abs(Estimate);
tValue=abs(tValue);
run;

data table12;
merge bigN(keep=AVISITN_1 TRT01P COUNT)
      means(keep=AVISITN_1 TRT01P Estimate StdErr);
by AVISITN_1 TRT01P;
mean_se=strip(put(Estimate, 6.3))||' ('||strip(put(StdErr, 5.3))||')';
run;

options nodate pagesize=800 nonumber;
ods pdf file = '/home/u63774111/Project/Project_2C/2C_Submission/Table12.pdf';
title1 bold "Table 12";
title2 BOLD 
	"Summary of Adjusted Mean of Change from Baseline Viral Load at Week 12 and 16";
title3 BOLD "ITT Population";
title4 ' ';

proc report data=table12 nowd headline headskip spacing=3;
	column AVISITN_1 Trt01p COUNT mean_se;
	define AVISITN_1 / group 'Test Day' center width=10;
	define Trt01p/'Treatment' center width=10;
	define COUNT/"N" center width=2;
	define mean_se/"Adjusted Mean (SE)" center width=10;
	compute after AVISITN_1;
		line @1 " ";
		line @1 " ";
	endcomp;
	break after AVISITN_1/skip;
	compute after _page_;
		line @1 80* "_";
		line @1 
			"Adjusted mean is calculated using PROC MIXED stage as factor and treatment.";
	endcomp;
run;

ods pdf close;

proc printto;
run;