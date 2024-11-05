proc printto log='/home/u63774111/Project/Project_2C/2C_Submission/TLF2.log';

libname tlfip "/home/u63774111/Project/Project_2C/TLF_input";
libname adtlf xport "/home/u63774111/Project/Project_2C/AdamInput/ADSL.xpt" 
	access=readonly;
proc copy inlib=adtlf outlib=tlfip;
run;

data demog_1;
set tlfip.adsl;
if SAFFL='Y';
run;

data demog_2;
keep USUBJID TRT ORD;
set demog_1;
if index(TRT01A, "Placebo")>0 then do;
   TRT="A";
   ORD=1;
   end;
if index(TRT01A, "CMP-135")>0 then do;
   TRT="B";
   ORD=2;
   end;  
run;

proc sql noprint;
select count(distinct USUBJID) into : N1 - :N2 
from demog_2
group by ORD
order by ORD;
QUIT;

%PUT &N1 &N2;

data adae;
keep USUBJID TRT ORD AEBODSYS AEDECOD AETOXGR;
set tlfip.adae;
if SAFFL='Y' and TRTEM='Y';
if index(TRT01A, "Placebo")>0 then do;
   TRT="A";
   ORD=1;
   end;
if index(TRT01A, "CMP-135")>0 then do;
   TRT="B";
   ORD=2;
   end;
run;

PROC SQL NOPRINT;
	CREATE TABLE ANY AS SELECT TRT, COUNT (DISTINCT USUBJID) AS N FROM ADAE GROUP BY TRT;
	CREATE TABLE SOC AS SELECT TRT, AEBODSYS, COUNT (DISTINCT USUBJID) AS N FROM 
		ADAE GROUP BY TRT, AEBODSYS;
	CREATE TABLE PT AS SELECT TRT, AEBODSYS, AEDECOD, COUNT (DISTINCT USUBJID) AS 
		N FROM ADAE GROUP BY TRT, AEBODSYS, AEDECOD;
	CREATE TABLE ANY_GRADE AS SELECT TRT, AETOXGR, COUNT (DISTINCT USUBJID) AS N FROM ADAE GROUP BY TRT, AETOXGR;
    CREATE TABLE SOC_GRADE AS SELECT TRT, AEBODSYS, AETOXGR, COUNT (DISTINCT USUBJID) AS N FROM 
		ADAE GROUP BY TRT, AEBODSYS, AETOXGR;
	CREATE TABLE PT_GRADE AS SELECT TRT, AEBODSYS, AEDECOD, AETOXGR, COUNT (DISTINCT USUBJID) AS 
		N FROM ADAE GROUP BY TRT, AEBODSYS, AEDECOD, AETOXGR;	
QUIT;

data four;
set ANY;
run;

proc transpose data=four out=transp_four(drop=_:);
id TRT;
var N;
run;

data four_1(drop=A B);
retain AEBODSYS AEDECOD AETOXGR DRUGA DRUGB;
length AEBODSYS AEDECOD $100. AETOXGR $50. DRUGA DRUGB $25.;
set transp_four;
AEBODSYS='-Any adverse events-';
AETOXGR='-All Grades-';
DRUGA=PUT(A, 3.)||" ("||PUT(A/&N1*100, 4.1)||"%) ";
DRUGB=PUT(B, 3.)||" ("||PUT(B/&N2*100, 4.1)||"%) ";
run;

data five;
set ANY_GRADE;
run;

proc sort data=five;
by AETOXGR;
run;

proc transpose data=five out=transp_five(drop=_:);
by AETOXGR;
id TRT;
var N;
run;

%MACRO missingrades(transpdata);
       data grades;
       do AETOXGR = 1 to 5;
          output;
          end;
       run;

       data &transpdata(drop=AETOXGR rename=AETOXGRn=AETOXGR);
       set &transpdata;
       AETOXGRn=input(AETOXGR, best.);
       run;

       data &transpdata;
       merge grades &transpdata;
       run;
%MEND missingrades;

%missingrades(transp_five);

data five_1(drop=A B);
retain AEBODSYS AEDECOD AETOXGR DRUGA DRUGB;
length AEBODSYS AEDECOD $100. DRUGA DRUGB $25.;
set transp_five;

IF A=. THEN DRUGA="  0 (0.0%)";
ELSE IF A=&N1 THEN DRUGA=PUT(A, 3.)||"(100%)";
ELSE DRUGA=PUT(A, 3.)||" ("||PUT(A/&N1*100, 4.1)||"%) ";

IF B=. THEN DRUGB="  0 (0.0%)";
ELSE IF B=&N2 THEN DRUGB=PUT(B, 3.)||"(100%)";
ELSE DRUGB=PUT(B, 3.)||" ("||PUT(B/&N2*100, 4.1)||"%) ";
run;

proc sort data=five_1;
by descending AETOXGR;
run;

data five_2(drop=AETOXGR rename=AETOXGRc=AETOXGR);
retain AEBODSYS AEDECOD AETOXGRc DRUGA DRUGB;
length AEBODSYS AEDECOD $100. AETOXGRc $50. DRUGA DRUGB $25.;
set five_1;
AETOXGRc=put(AETOXGR, 2.);
run;

data ANY_;
set four_1 five_2;
run;

data seven;
set SOC;
run;

proc sort data=seven;
by AEBODSYS;
run;

proc transpose data=seven out=transp_seven(drop=_:);
by AEBODSYS;
id TRT;
var N;
run;

data seven_1(drop=A B);
retain AEBODSYS AEDECOD AETOXGR DRUGA DRUGB;
length AEBODSYS AEDECOD $100. AETOXGR $50. DRUGA DRUGB $25.;
set transp_seven;
AEDECOD='-Overall-';
AETOXGR='-All Grades-';

IF A=. THEN DRUGA="  0 (0.0%)";
ELSE IF A=&N1 THEN DRUGA=PUT(A, 3.)||"(100%)";
ELSE DRUGA=PUT(A, 3.)||" ("||PUT(A/&N1*100, 4.1)||"%) ";

IF B=. THEN DRUGB="  0 (0.0%)";
ELSE IF B=&N2 THEN DRUGB=PUT(B, 3.)||"(100%)";
ELSE DRUGB=PUT(B, 3.)||" ("||PUT(B/&N2*100, 4.1)||"%) ";
run;

data eight;
set SOC_GRADE;
run;

proc sort data=eight;
by AEBODSYS AETOXGR;
run;

proc transpose data=eight out=transp_eight(drop=_:);
by AEBODSYS AETOXGR;
id TRT;
var N;
run;

proc sql;
create table unique_AEBODSYS as
select distinct AEBODSYS
from transp_eight;
quit;

data template;
    set unique_AEBODSYS;
    do AETOXGR = 1 to 5;
        output;
    end;
run;

data transp_eight(drop=AETOXGR rename=AETOXGRn=AETOXGR);
       set transp_eight;
       AETOXGRn=input(AETOXGR, best.);
       run;
       
data transp_eight_complete;
    merge template transp_eight;
    by AEBODSYS AETOXGR;
    run;
       
data eight_1(drop=A B);
retain AEBODSYS AEDECOD AETOXGR DRUGA DRUGB;
length AEBODSYS AEDECOD $100. DRUGA DRUGB $25.;
set transp_eight_complete;

IF A=. THEN DRUGA="  0 (0.0%)";
ELSE IF A=&N1 THEN DRUGA=PUT(A, 3.)||"(100%)";
ELSE DRUGA=PUT(A, 3.)||" ("||PUT(A/&N1*100, 4.1)||"%) ";

IF B=. THEN DRUGB="  0 (0.0%)";
ELSE IF B=&N2 THEN DRUGB=PUT(B, 3.)||"(100%)";
ELSE DRUGB=PUT(B, 3.)||" ("||PUT(B/&N2*100, 4.1)||"%) ";
run;

proc sort data=eight_1;
by AEBODSYS descending AETOXGR;
run;

data eight_2(drop=AETOXGR rename=AETOXGRc=AETOXGR);
retain AEBODSYS AEDECOD AETOXGRc DRUGA DRUGB;
length AEBODSYS AEDECOD $100. AETOXGRc $50. DRUGA DRUGB $25.;
set eight_1;
AETOXGRc=put(AETOXGR, 2.);
run;

data nine;
set seven_1 eight_2;
AEBODSYS = upcase(AEBODSYS);
run;

proc sort data = nine out=SOC_;
by AEBODSYS;
run;

data ten;
set PT;
run;

proc sort data=ten;
by AEBODSYS AEDECOD;
run;

proc transpose data=ten out=transp_ten(drop=_:);
by AEBODSYS AEDECOD;
id TRT;
var N;
run;

data ten_1(drop=A B);
retain AEBODSYS AEDECOD AETOXGR DRUGA DRUGB;
length AEBODSYS AEDECOD $100. AETOXGR $50. DRUGA DRUGB $25.;
set transp_ten;
AETOXGR='-All Grades-';
AEBODSYS = upcase(AEBODSYS);

IF A=. THEN DRUGA="  0 (0.0%)";
ELSE IF A=&N1 THEN DRUGA=PUT(A, 3.)||"(100%)";
ELSE DRUGA=PUT(A, 3.)||" ("||PUT(A/&N1*100, 4.1)||"%) ";

IF B=. THEN DRUGB="  0 (0.0%)";
ELSE IF B=&N2 THEN DRUGB=PUT(B, 3.)||"(100%)";
ELSE DRUGB=PUT(B, 3.)||" ("||PUT(B/&N2*100, 4.1)||"%) ";
run;

data eleven;
set PT_GRADE;
run;

proc sort data=eleven;
by AEBODSYS AEDECOD AETOXGR;
run;

proc transpose data=eleven out=transp_eleven(drop=_:);
by AEBODSYS AEDECOD AETOXGR;
id TRT;
var N;
run;

proc sql;
create table unique_AEBODSYS_AEDECOD as
select distinct AEBODSYS, AEDECOD
from transp_eleven;
quit;

data template;
    set unique_AEBODSYS_AEDECOD;
    do AETOXGR = 1 to 5;
        output;
    end;
run;

data transp_eleven(drop=AETOXGR rename=AETOXGRn=AETOXGR);
       set transp_eleven;
       AETOXGRn=input(AETOXGR, best.);
       run;
       
data transp_eleven_complete;
    merge template transp_eleven;
    by AEBODSYS AEDECOD AETOXGR;
    run;
       
data eleven_1(drop=A B);
retain AEBODSYS AEDECOD AETOXGR DRUGA DRUGB;
length AEBODSYS AEDECOD $100. DRUGA DRUGB $25.;
set transp_eleven_complete;

IF A=. THEN DRUGA="  0 (0.0%)";
ELSE IF A=&N1 THEN DRUGA=PUT(A, 3.)||"(100%)";
ELSE DRUGA=PUT(A, 3.)||" ("||PUT(A/&N1*100, 4.1)||"%) ";

IF B=. THEN DRUGB="  0 (0.0%)";
ELSE IF B=&N2 THEN DRUGB=PUT(B, 3.)||"(100%)";
ELSE DRUGB=PUT(B, 3.)||" ("||PUT(B/&N2*100, 4.1)||"%) ";
run;

proc sort data=eleven_1;
by AEBODSYS AEDECOD descending AETOXGR;
run;

data eleven_2(drop=AETOXGR rename=AETOXGRc=AETOXGR);
retain AEBODSYS AEDECOD AETOXGRc DRUGA DRUGB;
length AEBODSYS AEDECOD $100. AETOXGRc $50. DRUGA DRUGB $25.;
set eleven_1;
AETOXGRc=put(AETOXGR, 2.);
run;

data twelve;
set ten_1 eleven_2;
AEBODSYS = upcase(AEBODSYS);
run;

proc sort data = twelve out=PT_;
by AEBODSYS AEDECOD;
run;

data SOC1;
set SOC_ PT_;
run;

proc sort data = SOC1 out=sort_soc_;
by AEBODSYS;
run;

data result;
    set sort_soc_;
    by AEBODSYS;
    retain orig_AEDECOD orig_AETOXGR orig_DRUGA orig_DRUGB;
    if first.AEBODSYS then do;
        orig_AEDECOD = AEDECOD;
        orig_AETOXGR = AETOXGR;
        orig_DRUGA = DRUGA;
        orig_DRUGB = DRUGB;
        AEDECOD = "";
        AETOXGR = "";
        DRUGA = "";
        DRUGB = "";
        output;
        AEDECOD = orig_AEDECOD;
        AETOXGR = orig_AETOXGR;
        DRUGA = orig_DRUGA;
        DRUGB = orig_DRUGB;
    end;
    output;
    if last.AEBODSYS then do;
        orig_AEDECOD = "";
        orig_AETOXGR = "";
        orig_DRUGA = "";
        orig_DRUGB = "";
    end;
run;

data result1(keep=AEBODSYS1 AETOXGR DRUGA DRUGB);
retain AEBODSYS1 AETOXGR DRUGA DRUGB;
set result;
length AEBODSYS1 $100;
	
IF AEDECOD EQ '' AND AEBODSYS NE '' THEN
   AEBODSYS1=AEBODSYS;
ELSE
   AEBODSYS1="              "||AEDECOD;	
if AETOXGR in (1,2,3,4,5) then AEBODSYS1='';
run;

data final;
set ANY_(rename=AEBODSYS=AEBODSYS1 drop=AEDECOD) result1;
run;

options number nodate ls=132 ps=40;
ods escapechar="^";
ods pdf file = '/home/u63774111/Project/Project_2C/2C_Submission/AETable.pdf' style=journal;
title1 j=c "^S={font_weight=light}Table 14.3/2";
title2 j=c "^S={font_weight=light}Patients with Treatment-Emergent Adverse Events by Highest NCI CTCAE Grade" ;
title3 j=c "^S={font_weight=light}Safety-Evaluable Patients";
footnote1 j=l "Study PRJ5457C";
footnote2 j=l "TLG Specifications, Version v1.0" j=r "Date: &sysdate9";

PROC REPORT DATA=FINAL NOWD HEADLINE HEADSKIP SPLIT="|" MISSING SPACING=1 WRAP 
        STYLE (HEADER)={JUST=C FONTWEIGHT=BOLD FONTSIZE=8pt}
        STYLE (COLUMN)={FONTSIZE=8pt}
        STYLE(REPORT)=[CELLSPACING=1 CELLPADDING=5];
	COLUMN AEBODSYS1 AETOXGR DRUGA DRUGB; 
	DEFINE AEBODSYS1 / DISPLAY ORDER=DATA "MedDRA System Organ Class and Preferred Term" 
		STYLE (COLUMN)=[CELLWIDTH=20% FONTSIZE=8pt]
		STYLE (HEADER)=[JUST=CENTER CELLWIDTH=20% FONTSIZE=8pt];
	DEFINE AETOXGR / DISPLAY "NCI-CTCAE Grade" CENTER
	    STYLE (COLUMN)=[CELLWIDTH=20% FONTSIZE=8pt] 
		STYLE (HEADER)=[JUST=CENTER CELLWIDTH=20% FONTSIZE=8pt];
	DEFINE DRUGA / DISPLAY "Placebo | (n=&N1)" CENTER 
	    STYLE (COLUMN)=[JUST=CENTER CELLWIDTH=20% FONTSIZE=8pt] 
		STYLE (HEADER)=[JUST=CENTER CELLWIDTH=20% FONTSIZE=8pt];
	DEFINE DRUGB / DISPLAY "CMP-135 | (n=&N2)" CENTER 
	    STYLE (COLUMN)=[JUST=CENTER CELLWIDTH=20% FONTSIZE=8pt] 
		STYLE (HEADER)=[JUST=CENTER CELLWIDTH=20% FONTSIZE=8pt];
RUN;
ODS _ALL_ CLOSE;

