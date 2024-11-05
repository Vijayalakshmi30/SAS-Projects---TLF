proc printto log='/home/u63774111/Project/Project_2C/2C_Submission/TLF3.log';

libname tlfip "/home/u63774111/Project/Project_2C/TLF_input";
libname adtlf xport "/home/u63774111/Project/Project_2C/AdamInput/ADTTE.xpt" 
	access=readonly;
proc copy inlib=adtlf outlib=tlfip;
run;

data adtte1(keep=USUBJID TRT01A TRT01AN REMISS REMISSN PARAM PARAMCD CNSR EVNTDESC AVAL);
set tlfip.adtte;
where ITTFL='Y' and PARAMCD='TTPFS';
output;
REMISS='Overall';
REMISSN=9;
output;
run;

data adtte2;
set adtte1;
if (REMISSN=1) and (TRT01AN=0) then do;
   TRT="2P";
   ORD=1;
   end;
if (REMISSN=1) and (TRT01AN=1) then do;
   TRT="2C";
   ORD=2;
   end;
if (REMISSN=2) and (TRT01AN=0) then do;
   TRT="3P";
   ORD=3;
   end;
if (REMISSN=2) and (TRT01AN=1) then do;
   TRT="3C";
   ORD=4;
   end;
if (REMISSN=9) and (TRT01AN=0) then do;
   TRT="9P";
   ORD=5;
   end;
if (REMISSN=9) and (TRT01AN=1) then do;
   TRT="9C";
   ORD=6;
   end;
run;

PROC SQL NOPRINT;
	SELECT strip(put(COUNT (DISTINCT USUBJID),5.)) INTO : N1 - :N6 FROM adtte2 GROUP BY ORD 
		ORDER BY ORD;
QUIT;

%PUT &N1 &N2 &N3 &N4 &N5 &N6;

proc freq data=adtte2 noprint;
table TRT / out=freq1_1 nocum nopercent;
run;

proc freq data=adtte2 noprint;
table TRT*CNSR / out=freq1_2(where=(CNSR=0)) nocum nopercent norow nocol;
run;

proc freq data=adtte2 noprint;
tables TRT*CNSR*EVNTDESC / out=freq1_3(where=(CNSR=0)) list nocum nopercent norow nocol;
run;

data event;
set freq1_3;
EVNTDESC=propcase(EVNTDESC);
OUTPUT;
EVNTDESC='Death';
COUNT=.;
OUTPUT;
run;

proc sort data=event;
by descending EVNTDESC;
run;

proc freq data=adtte2 noprint;
table TRT*CNSR / out=freq1_4(where=(CNSR=1)) nocum nopercent norow nocol;
run;

proc sort data=freq1_1 out=dummy_ds_trt(keep=trt) nodupkey;
by TRT;
run;

data block1(drop=COUNT PERCENT CNSR EVNTDESC);
set freq1_1(in=a) freq1_2(in=b) dummy_ds_trt(in=b1) event(in=c) freq1_4(in=d);

length txt $40 value $15;
ORD1=1;
if a then do;
     ORD2=1;
     txt="No. of Subjects";
     value=put(count,3.);
     end;
if b then do;
     ORD2=2;
     txt="    No. of Subjects with an event (%)";
     if count=. then value="  0 (0.0%) ";
     else if TRT='2P' then do;
        if count=&N1 then value= put(count,3.)||" (100%)";
	    else value= put(count,3.) ||" ("|| put((count/&N1)*100, 4.1)||"%)";
        end;
     else if TRT='2C' then do;
        if count=&N2 then value= put(count,3.)||" (100%)";
	    else value= put(count,3.) ||" ("|| put((count/&N2)*100, 4.1)||"%)";
        end;
     else if TRT='3P' then do;
        if count=&N3 then value= put(count,3.)||" (100%)";
	    else value= put(count,3.) ||" ("|| put((count/&N3)*100, 4.1)||"%)";
        end;
      else if TRT='3C' then do;
        if count=&N4 then value= put(count,3.)||" (100%)";
	    else value= put(count,3.) ||" ("|| put((count/&N4)*100, 4.1)||"%)";
        end;
      else if TRT='9P' then do;
        if count=&N5 then value= put(count,3.)||" (100%)";
	    else value= put(count,3.) ||" ("|| put((count/&N5)*100, 4.1)||"%)";
        end;
      else if TRT='9C' then do;
        if count=&N6 then value= put(count,3.)||" (100%)";
	    else value= put(count,3.) ||" ("|| put((count/&N6)*100, 4.1)||"%)";
        end;
     end;     
if b1 then do;
     txt="    Earliest contributing event:";
     ORD2=2.1;
     end;
if c then do;
     txt="       "||EVNTDESC;
     if EVNTDESC='Disease Progression' then do;
         ORD2=2.5;
         value=put(count,3.);
         end;
     else if EVNTDESC='Death' then do;
         ORD2=2.6;
         value=put(count,3.);
         if value='' then value='0';
         end;
     end;
if d then do;
     ORD2=3;
     txt="    No. of Subjects without an event (%)";
     if count=. then value="  0 (0.0%) ";
     else if TRT='2P' then do;
        if count=&N1 then value= put(count,3.)||" (100%)";
	    else value= put(count,3.) ||" ("|| put((count/&N1)*100, 4.1)||"%)";
        end;
     else if TRT='2C' then do;
        if count=&N2 then value= put(count,3.)||" (100%)";
	    else value= put(count,3.) ||" ("|| put((count/&N2)*100, 4.1)||"%)";
        end;
     else if TRT='3P' then do;
        if count=&N3 then value= put(count,3.)||" (100%)";
	    else value= put(count,3.) ||" ("|| put((count/&N3)*100, 4.1)||"%)";
        end;
      else if TRT='3C' then do;
        if count=&N4 then value= put(count,3.)||" (100%)";
	    else value= put(count,3.) ||" ("|| put((count/&N4)*100, 4.1)||"%)";
        end;
      else if TRT='9P' then do;
        if count=&N5 then value= put(count,3.)||" (100%)";
	    else value= put(count,3.) ||" ("|| put((count/&N5)*100, 4.1)||"%)";
        end;
      else if TRT='9C' then do;
        if count=&N6 then value= put(count,3.)||" (100%)";
	    else value= put(count,3.) ||" ("|| put((count/&N6)*100, 4.1)||"%)";
        end;
     end;     
run;

proc sort data=adtte2;
by REMISS REMISSN TRT01AN;
run;

ods trace on;
ods output HomTests=pvalue (where=(test in ("Log-Rank", "Wilcoxon"))) Quartiles=qrts;
proc lifetest data = adtte2 alpha=0.05 outsurv=outsurv1;
by REMISS REMISSN;
time AVAL*CNSR(1);
strata TRT01AN;
run;
ods trace off;

data a;
set qrts;
run;

data Q1 (keep= TRT Q1 ORD1)
     Q2 (keep= TRT Q2 ORD1)
     Q3 (keep= TRT Q3 ORD1);
set qrts;
if (REMISSN=1) and (TRT01AN=0) then TRT="2P";
if (REMISSN=1) and (TRT01AN=1) then TRT="2C";
if (REMISSN=2) and (TRT01AN=0) then TRT="3P";
if (REMISSN=2) and (TRT01AN=1) then TRT="3C";
if (REMISSN=9) and (TRT01AN=0) then TRT="9P";
if (REMISSN=9) and (TRT01AN=1) then TRT="9C";
ORD1=2;

if estimate NE . then _estimate = put(estimate, 4.1);
else _estimate="NA";

if percent=25 then Q1 = strip(_estimate);
else if percent=50 then Q2 = strip(_estimate);
else if percent=75 then Q3 = strip(_estimate);

if percent=25 then output Q1;
else if percent=50 then output Q2;
else if percent=75 then output Q3;
run;

data Q2CI(keep=TRT CI1 ORD1);
set qrts;
if (REMISSN=1) and (TRT01AN=0) then TRT="2P";
if (REMISSN=1) and (TRT01AN=1) then TRT="2C";
if (REMISSN=2) and (TRT01AN=0) then TRT="3P";
if (REMISSN=2) and (TRT01AN=1) then TRT="3C";
if (REMISSN=9) and (TRT01AN=0) then TRT="9P";
if (REMISSN=9) and (TRT01AN=1) then TRT="9C";
ord1=2;
if upperlimit ne . then upperlimit_ = put(upperlimit,5.2);
else upperlimit_ = "NA";
CI1 = "(" || strip(put(LowerLimit,5.2)) || ", " || strip(UpperLimit_) || ")";
if percent eq 50 then output q2ci;
run;


proc sort data=Q1;
by TRT;
run;

proc sort data=Q3;
by TRT;
run;

data q1q3;
merge q1 q3;
by TRT ORD1;
q1q3 = "(" || strip(Q1) || ", " || strip(Q3) || ")";
ORD2=3;
txt="25th-75th percentile";
run;

proc sort data=adtte2;
by TRT;
run;

proc means data=adtte2 noprint;
by TRT;
var AVAL;
output out=MinMax (keep= TRT AVAL _stat_ where=(_stat_ in ("MIN", "MAX")));
run;

proc transpose data=MinMax out=minmax1(keep=TRT MIN MAX);
by TRT;
var AVAL;
id _stat_;
run;

data minmax2(keep=TRT MinMax);
set minmax1;
MinMax=strip(put(Min,4.1)) || " - " || strip(put(Max,4.1)) || "+";
run;

data block2(keep=TRT txt value ORD1 ORD2);
length txt $40. value $20.;
set Q2(in=a) Q2CI(in=b) Q1Q3(in=c) minmax2(in=d) dummy_ds_trt(in=e);
ORD1=2;
if a then do;
   txt="     Median";
   ORD2=1;
   value = Q2;
   end;
else if b then do;
   txt="     (95% CI)";
   ORD2=2;
   value = CI1;
   end;
else if c then do;
   txt="     25th-75th percentile";
   ORD2=3;
   value = 	q1q3;
   end;
else if d then do;
   txt = '     Minimum-maximum';
   ORD2=4;
   value = MinMax;
   end;
else if e then do;
   txt="Progression Free Survival (Months)";
   ORD1=2;
   ORD2=0;
   end;
 run;
 
proc sort data=adtte2;
by REMISS REMISSN;
run;

ods trace on;
ods listing close;

ods output ParameterEstimates=HR;
proc phreg data=adtte2;
by REMISS REMISSN;
model AVAL*CNSR(1)=TRT01AN / ties=exact risklimits;
run;

data HR1(keep= trt txt ord1 ord2 value)
     HRCi(keep= trt txt ord1 ord2 value);
length txt $40.;
set hr;
if (REMISSN=1) then TRT="2C";
if (REMISSN=2) then TRT="3C";
if (REMISSN=9) then TRT="9C";
retain value;
length value $40;
ord1=3;
if not missing(HazardRatio) then value= strip(put(HazardRatio,5.3));
else value='NA';
ord2=6;
txt="     Hazard ratio (relative to placebo)";
output HR1;
if not missing(HRLowerCL) then value ='('||strip(put(round(HRlowerCL,0.001),5.2))||',';
else value='NA';
if not missing(HRupperCL) then value =trim(value)||' '||strip(put(round(HRUpperCL,0.001),5.2))||')';
else value = trim(value)||'(NA)';
if missing(Hazardratio) and missing(HRLowerCL) and missing(HRUpperCL) then value='NA';
txt="          (95% CI)";
ord2=7;
output HRci;
run;

data pvalue1(keep=trt ord1 ord2 value txt)
     pvalue2(keep=trt ord1 ord2 value txt);
length value $40.;
set pvalue;
if not missing(ProbChiSq) then do;
if (ProbChiSq<0.0001) then value='     '||'<0.0001';
else value='     '||strip(put(round(ProbChisq,.0001),6.4));
end;
if (REMISSN=1) then TRT="2C";
if (REMISSN=2) then TRT="3C";
if (REMISSN=9) then TRT="9C";
value=strip(value);
txt="          Log-rank";
ord1=3;
ord2=9;
if test="Log-Rank" then output pvalue1;
txt="          Wilcoxon";
ord1=3;
ord2=10;
if test="Wilcoxon" then output pvalue2;
run;

data dummy_ds_trt1;
set dummy_ds_trt;
run;

data block3;
set HR1(in=a) HRci(in=b) pvalue1(in=c) pvalue2(in=d) dummy_ds_trt(in=e) dummy_ds_trt1(in=f);
if e then do;
   txt="Unstratified Analysis";
   ord1=3;
   ord2=0;
   end;
if f then do;
   txt="     p-value (relative to placebo)";
   ord1=3;
   ord2=8;
   end;
run;

proc sort data = block3;
by trt ord1 ord2;
run;

ods output ParameterEstimates=HR2;
proc phreg data=adtte2;
model AVAL*CNSR(1)=TRT01AN / ties=exact risklimits;
strata REMISS;
ods listing close;
run;

ods trace on;
ods output HomTests=pvalue1 (where=(test in ("Log-Rank","Wilcoxon")));
proc LifeTest data=adtte2 alpha=0.05 outsurv=outsurv1;
title"p-value (relative to placebo)";
time aval*cnsr(1);
strata remiss;
run;
ods trace off;

data HR3(keep= txt trt ord1 ord2 value);
length txt $40.;
set HR2;
trt='9C';
retain value;
length value $40;
if not missing(HazardRatio) then value= strip(put(HazardRatio,5.3));
else value='NA';
txt="     Hazard Ratio (relative to placebo)";
ord1=4;
ord2=12;
run;

data HRCI2(keep= txt trt ord1 ord2 value);
length txt $40.;
set hr2;
trt='9C';
retain value;
length value $40;
if not missing(HRLowerCL) then value ='('||strip(put(round(HRlowerCL,0.001),5.3))||',';
else value='NA';
if not missing(HRupperCL) then value =trim(value)||' '||strip(put(round(HRUpperCL,0.0001),5.3))||')';
else value = trim(value)||'NA';
if missing(HazardRatio) and missing(HRLowerCL) and missing(HRUpperCL) then value='NA';
txt="          (95% CI)";
ord1=4;
ord2=13;
run;

data pvalue1;
set pvalue1;
run;

data pvalue3(keep= ord1 trt ord2 value txt)
     pvalue4(keep= ord1 trt ord2 value txt);
length value $40.;
set pvalue1;
if not missing(ProbChiSq) then do;
       if (ProbChiSq<0.0001) then value='     '||'<0.0001';
       else value='     '||strip(put(round(ProbChiSq,.0001),6.4));
       end;
trt="9C";
value=strip(value);

txt="          Log-rank";
ord1=4;
ord2=15;
if test="Log-Rank" then output pvalue3;

txt="          Wilcoxon";
ord1=4;
ord2=16;
if test="Wilcoxon" then output pvalue4;
run;

data dummy_ds_trt3;
set dummy_ds_trt2;
run;

data block4;
length value $40;
set hr3(in=a) hrci2(in=b) pvalue3(in=c) pvalue4(in=d) dummy_ds_trt2(in=e) dummy_ds_trt3(in=f);
if e then do;
   txt="Stratified Analysis";
   ord1=4;
   ord2=0;
   end;
if f then do;
   txt="     p-value (relative to placebo)";
   ord1=4;
   ord2=14;
   end;
run;

data final(keep=ORD1 ORD2 TXT TRT value);
retain ORD1 ORD2 TRT txt value;
length value $40 txt $100;
set block1(in=a) block2(in=b) block3(in=c) block4(in=d);
run;

proc sort data=final out=final1 nodupkey;
by ord1 ord2 txt trt;
run;

proc transpose data=final1 prefix=Col out=final2;
by ord1 ord2 txt;
var value;
id trt;
run;

ods pdf file='/home/u63774111/Project/Project_2C/2C_Submission/pfsTable.pdf';
title1 j=c "^S={font_weight=light}Table 14.2/1";
title2 j=c "^S={font_weight=light}Progression-Free Survival by Remission Status" ;
title3 j=c "^S={font_weight=light}Randomized Subjects";
footnote1 j=l "Study PRJ5457C";
footnote2 j=l "TLG Specifications, Version v1.0" j=r "Date: &sysdate9";
ods listing;
options missing='' nodate nonumber ls=140;
ods escapechar="^";
proc report data=final2 nowd headline headskip split="#";
column (ord1 ord2 txt ('2nd remission' col2P col2C)
                           ('3rd remission' col3P col3C)
                           ('Overall' col9P col9C));
define ord1 / '' noprint order order=internal;
define ord2 / '' noprint order order=internal;
define txt / '' style(column)={asis=on} width=40 flow;

define col2P / "Placebo # (N=%left(&N1))" width=12 center;
define col2C / "CMP-135 # (N=%left(&N2))" width=12 center;
define col3P / "Placebo # (N=%left(&N3))" width=12 center;
define col3C / "CMP-135 # (N=%left(&N4))" width=12 center;
define col9P / "Placebo # (N=%left(&N5))" width=12 center;
define col9C / "CMP-135 # (N=%left(&N6))" width=12 center;
break after ord1 / skip;
compute before ord1;
line @1 '    ';
endcomp;
run;
ods pdf close;