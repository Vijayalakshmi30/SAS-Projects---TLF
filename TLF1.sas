proc printto log='/home/u63774111/Project/Project_2C/2C_Submission/TLF1.log';

libname tlfip "/home/u63774111/Project/Project_2C/TLF_input";
libname adtlf xport "/home/u63774111/Project/Project_2C/AdamInput/ADSL.xpt" 
	access=readonly;
proc copy inlib=adtlf outlib=tlfip;
run;

data dm(keep=AGE AGEGR1 SEX1 ETHNIC RACE BWT BECOG ARM REMISS1 PRTXDUR);
	set tlfip.adsl(keep=AGE AGEGR1 SEX ETHNIC RACE BWT BECOG REMISS ARM PRTXDUR);
	length SEX1 REMISS1 $32;
	REMISS1 = REMISS;
	if SEX='F' then SEX1='Female';
	if REMISS='SECOND COMPLETE REMISSION' then REMISS1='2nd';
	else if REMISS='THIRD COMPLETE REMISSION' then REMISS1='3rd';
run;

proc sort data=dm out=sort_dm;
	by ARM;
run;

proc means data=sort_dm n mean std median min max;
	var AGE;
	by ARM;
	output out=Age_stats n=N1 mean=Mean1 std=StdDev1 median=Median1 min=Min1 
		max=Max1;
run;

data age(drop=_: N1 Mean1 StdDev1 Median1 Min1 Max1);
	set Age_stats;
	N=put(N1, 3.);
	Mean=put(round(Mean1, 0.1), 5.1);
	StdDev=put(round(StdDev1, 0.1), 5.1);
	Median=put(round(Median1, 0.1), 5.1);
	Range=catx(' ', put(min1, 2.), '-', put(max1, 2.));
	'Mean (SD)'n=cat(Mean, ' (', strip(StdDev), ')');
run;

proc transpose data=age out=transp_age(rename=(_NAME_=Group1));
	id ARM;
	var N 'Mean (SD)'n Median Range;
run;

data age1_;
	retain Variable Group1 Placebo;
	length Variable $27 Group1 $32;
	set transp_age;
	Variable='Age (yr)';
run;

proc means data=sort_dm n mean std median min max;
	var AGE;
	output out=tot_age n=N1 mean=Mean1 std=StdDev1 median=Median1 min=Min1 
		max=Max1;
run;

data agetot(drop=_: N1 Mean1 StdDev1 Median1 Min1 Max1);
	set tot_age;
	N=put(N1, 3.);
	Mean=put(round(Mean1, 0.1), 5.1);
	StdDev=put(round(StdDev1, 0.1), 5.1);
	Median=put(round(Median1, 0.1), 5.1);
	Range=catx(' ', put(min1, 2.), '-', put(max1, 2.));
	'Mean (SD)'n=cat(Mean, ' (', strip(StdDev), ')');
run;

proc transpose data=agetot out=transp_agetot(rename=(_NAME_=Group1 COL1='All Patients'n));
	var N 'Mean (SD)'n Median Range;
run;

data age_;
merge age1_ transp_agetot;
run;

proc freq data=sort_dm noprint;
    tables AGEGR1 / out=AgeGr_stats;
    by ARM;
run;

data agegr;
    set AgeGr_stats;
    percent = round(PERCENT, 0.1); /* Round percent to one decimal place */
    percent1 = put(PERCENT, 6.1) || '%'; /* Convert percent to character and append % symbol */
    freq=cat(COUNT,' (',strip(percent1),')');
run;

proc sort data=agegr out=sort_agegr;
by AGEGR1;
run;

proc transpose data=sort_agegr out=transp_agegr(drop=_NAME_ rename=(AGEGR1=Group1));
	by AGEGR1;
	id ARM;
	var freq;
run;

data agegr_1;
	retain Variable Group1 Placebo;
	length Variable $27 Group1 $32;
	set transp_agegr;
	Variable='Age Group (yr)';
run;

data agegr_2;
    input @1 Variable $27. @28 Group1 $32. @60 Placebo $15. @75 'CMP-135'n $15.;
    datalines;
Age Group (yr)             n                               32             33             
;
run;

data agegr1_;
retain Variable Group1 Placebo;
set agegr_2 agegr_1;
run;

proc freq data=sort_dm noprint;
    tables AGEGR1 / out=AgeGr_tot nocum;
run;

data agegrtot;
    set AgeGr_tot;
    percent = round(PERCENT, 0.1); 
    percent1 = put(PERCENT, 6.1) || '%';
    freq=cat(COUNT,' (',strip(percent1),')');
run;

proc sort data=agegrtot out=sort_agegrtot;
by AGEGR1;
run;

proc transpose data=sort_agegrtot out=transp_agegrtot(drop=_NAME_ rename=(AGEGR1=Group1 COL1='All Patients'n));
	by AGEGR1;
	var freq;
run;

data agegrtot_2;
    input @1 Group1 $32. @33 'All Patients'n $15.;
    datalines;
n                               65             
;
run;

data agegr2_;
retain Variable Group1 Placebo;
set agegrtot_2 transp_agegrtot;
run;

data agegr_;
merge agegr1_ agegr2_;
run;

proc freq data=sort_dm noprint;
    tables SEX1 / out=Sex_stats;
    by ARM;
run;

data sex(drop=count percent percent1);
    set Sex_stats;
    percent1 = put(PERCENT, 6.1) || '%';
    freq=cat(COUNT,' (',strip(percent1),')');
run;

proc sort data=sex out=sort_sex;
by Sex1;
run;

proc transpose data=sort_sex out=transp_sex(drop=_: rename=(SEX1=Group1));
by Sex1;
id ARM;
var freq;
run;

data sex_1;
retain Variable Group1 Placebo;
length Variable $27 Group1 $32;
set transp_sex;
Variable='Sex';
run;

data sex_2;
    input @1 Variable $27. @28 Group1 $32. @60 Placebo $15. @75 'CMP-135'n $15.;
    datalines;
Sex                        n                               32             33             
;
run;

data sex1_;
retain Variable Group1 Placebo;
set sex_2 sex_1;
run;

proc freq data=sort_dm noprint;
    tables SEX1 / out=Sex_tot;
run;

data sextot(drop=count percent percent1);
    set Sex_tot;
    percent1 = put(PERCENT, 6.1) || '%';
    freq=cat(COUNT,' (',strip(percent1),')');
run;

proc sort data=sextot out=sort_sex;
by Sex1;
run;

proc transpose data=sort_sex out=transp_sextot(drop=_: rename=(SEX1=Group1 COL1='All Patients'n));
by Sex1;
var freq;
run;

data sex2_;
set agegrtot_2 transp_sextot;
run;

data sex_;
merge sex1_ sex2_;
run;

proc freq data=sort_dm noprint;
    tables ETHNIC / missing out=ethnic_stats;
    by ARM;
run;

data ethnic(drop=count percent percent1);
    set ethnic_stats;
    percent1 = put(PERCENT, 6.1) || '%';
    freq=cat(COUNT,' (',strip(percent1),')');
run;

proc sort data=ethnic out=sort_ethnic;
by ethnic;
run;

proc transpose data=sort_ethnic out=transp_ethnic(drop=_: rename=(ETHNIC=Group1));
by Ethnic;
id ARM;
var freq;
run;

data ethnic_1;
retain Variable Group1 Placebo;
length Variable $27 Group1 $32;
set transp_ethnic;
Variable='Ethnicity';
run;

data ethnic_2;
    input @1 Variable $27. @28 Group1 $32. @60 Placebo $15. @75 'CMP-135'n $15.;
    datalines;
Ethnicity                  n                               32             33             
;
run;

data ethnic_3;
    input @1 Variable $27. @28 Group1 $32. @60 Placebo $15. @75 'CMP-135'n $15.;
    datalines;
Ethnicity                  Not Available                   0 (0%)         0 (0%)         
;
run;

data ethnic1_;
retain Variable Group1 Placebo;
set ethnic_2 ethnic_1 ethnic_3;
Group1=propcase(Group1);
run;

proc freq data=sort_dm noprint;
    tables ETHNIC / missing out=ethnic_tot;
run;

data ethnictot(drop=count percent percent1);
    set ethnic_tot;
    percent1 = put(PERCENT, 6.1) || '%';
    freq=cat(COUNT,' (',strip(percent1),')');
run;

proc sort data=ethnictot out=sort_ethnictot;
by ethnic;
run;

proc transpose data=sort_ethnictot out=transp_ethnictot(drop=_: rename=(ETHNIC=Group1 COL1='All Patients'n));
by Ethnic;
var freq;
run;

data tot_na;
    input @1 Group1 $32. @33 'All Patients'n $15.;
    datalines;
Not Available                   0 (0.0%)         
;
run;

data ethnic2_;
set agegrtot_2 transp_ethnictot tot_na;
Group1=propcase(Group1);
run;

data ethnic_;
merge ethnic1_ ethnic2_;
run;

proc freq data=sort_dm noprint;
    tables RACE / missing out=race_stats;
    by ARM;
run;

data race(drop=count percent percent1);
    set race_stats;
    percent1 = put(PERCENT, 6.1) || '%';
    freq=cat(COUNT,' (',strip(percent1),')');
run;

* 7.3 Transposing the data *;
proc sort data=race out=sort_race;
by RACE;
run;

proc transpose data=sort_race out=transp_race(drop=_: rename=(RACE=Group1));
by RACE;
id ARM;
var freq;
run;

* 7.4 Race_ *;
data race_1;
length Variable $27;
retain Variable _NAME_ Placebo;
set transp_race;
Variable='Race';
run;

*For n*;
data race_2;
    input @1 Variable $26. @27 Group1 $32. @59 Placebo $15. @74 'CMP-135'n $15.;
    datalines;
Race                      n                               32             33             
;
run;

* For Not Available *;
data race_3;
    input @1 Variable $27. @28 Group1 $32. @60 Placebo $15. @75 'CMP-135'n $15.;
    datalines;
Race                       Not Available                    0 (0.0%)         0 (0.0%)    
;
run;

data race1_;
retain Variable Group1 Placebo;
set race_2 race_1 race_3;
Group1=propcase(Group1);
run;

* 7.5 For Total (Race) *;
proc freq data=sort_dm noprint;
    tables RACE / missing nocum out=race_tot;
run;

data racetot(drop=count percent percent1);
    set race_tot;
    percent1 = put(PERCENT, 6.1) || '%';
    freq=cat(COUNT,' (',strip(percent1),')');
run;

proc sort data=racetot out=sort_racetot;
by RACE;
run;

proc transpose data=sort_racetot out=transp_racetot(drop=_: rename=(RACE=Group1 COL1='All Patients'n));
by RACE;
var freq;
run;

data race2_;
set agegrtot_2 transp_racetot tot_na;
Group1=propcase(Group1);
run;

data race_;
merge race1_ race2_;
run;

proc means data=sort_dm n mean std median min max;
	var BWT;
	by ARM;
	output out=Wt_stats n=N1 mean=Mean1 std=StdDev1 median=Median1 min=Min1 
		max=Max1;
run;

data wt(drop=_: N1 Mean1 StdDev1 Median1 Min1 Max1);
	set Wt_stats;
	N=put(N1, 3.);
	Mean=put(round(Mean1, 0.1), 5.1);
	StdDev=put(round(StdDev1, 0.1), 5.1);
	Median=put(round(Median1, 0.1), 5.1);
	Range=catx(' ', put(min1, 2.), '-', put(max1, 2.));
	'Mean (SD)'n=cat(Mean, ' (', strip(StdDev), ')');
run;

proc transpose data=wt out=transp_wt(rename=(_NAME_=Group1));
	id ARM;
	var N 'Mean (SD)'n Median Range;
run;

data wt1_;
	retain Variable Group1 Placebo;
	length Variable $27 Group1 $32;
	set transp_wt;
	Variable='Weight (kg) at (timepoint)';
run;

proc means data=sort_dm n mean std median min max;
	var BWT;
	output out=Wt_tot n=N1 mean=Mean1 std=StdDev1 median=Median1 min=Min1 
		max=Max1;
run;

data wt_tot(drop=_: N1 Mean1 StdDev1 Median1 Min1 Max1);
	set Wt_tot;
	N=put(N1, 3.);
	Mean=put(round(Mean1, 0.1), 5.1);
	StdDev=put(round(StdDev1, 0.1), 5.1);
	Median=put(round(Median1, 0.1), 5.1);
	Range=catx(' ', put(min1, 2.), '-', put(max1, 2.));
	'Mean (SD)'n=cat(Mean, ' (', strip(StdDev), ')');
run;

proc transpose data=wt_tot out=transp_wt_tot(rename=(_NAME_=Group1 COL1='All Patients'n));
	var N 'Mean (SD)'n Median Range;
run;

data wt_;
retain Variable Group1 Placebo;
merge wt1_ transp_wt_tot;
run;

proc freq data=sort_dm noprint;
    tables BECOG / out=ecog_stats;
    by ARM;
run;

data ecog(drop=count percent percent1);
    set ecog_stats;
    percent1 = put(PERCENT, 6.1) || '%';
    freq=cat(COUNT,' (',strip(percent1),')');
run;

proc sort data=ecog out=sort_ecog;
by BECOG;
run;

proc transpose data=sort_ecog out=transp_ecog(drop=_: rename=(BECOG=_NAME_1));
by BECOG;
id ARM;
var freq;
run;

data ECOG_1(drop=_NAME_1);
retain Variable Group1 Placebo;
set transp_ecog;
Variable='ECOG Score';
Group1=put(_NAME_1, 1.);
run;

data ECOG_2;
    input @1 Variable $27. @28 Group1 $32. @60 Placebo $15. @75 'CMP-135'n $15.;
    datalines;
ECOG Score                 n                               32             33             
;
run;

data ECOG1_;
retain Variable Group1 Placebo;
set ECOG_2 ECOG_1;
run;

proc freq data=sort_dm noprint;
    tables BECOG / out=ecog_tot;
run;

data ecogtot(drop=count percent percent1);
    set ecog_tot;
    percent1 = put(PERCENT, 6.1) || '%';
    freq=cat(COUNT,' (',strip(percent1),')');
run;

proc sort data=ecogtot out=sort_ecogtot;
by BECOG;
run;

proc transpose data=sort_ecogtot out=transp_ecogtot(drop=_: rename=(BECOG=_NAME_1 COL1='All Patients'n));
by BECOG;
var freq;
run;

data ECOGtot_1(drop=_NAME_1);
retain Group1;
set transp_ecogtot;
Group1=put(_NAME_1, 1.);
run;

data ECOG2_;
set agegrtot_2 ECOGtot_1;
run;

data ECOG_;
merge ECOG1_ ECOG2_;
run;

proc freq data=sort_dm noprint;
    tables REMISS1 / out=Remiss_stats;
    by ARM;
run;

data remiss(drop=count percent percent1);
    set Remiss_stats;
    percent1 = put(PERCENT, 6.1) || '%';
    freq=cat(COUNT,' (',strip(percent1),')');
run;

proc sort data=remiss out=sort_remiss;
by REMISS1;
run;

proc transpose data=sort_remiss out=transp_remiss(drop=_: rename=(REMISS1=Group1));
by Remiss1;
id ARM;
var freq;
run;

data remiss_1;
retain Variable Group1 Placebo;
length Variable $27 Group1 $32;
set transp_remiss;
Variable='Current remission Status';
run;

data remiss_2;
    input @1 Variable $27. @28 Group1 $32. @60 Placebo $15. @75 'CMP-135'n $15.;
    datalines;
Current remission Status   n                               32             33             
;
run;

data remiss1_;
    retain Variable Group1 Placebo;
    set remiss_2 remiss_1; 
run;

proc freq data=sort_dm;
    tables REMISS1 / out=Remiss_tot;
run;

data remisstot(drop=count percent percent1);
    set Remiss_tot;
    percent1 = put(PERCENT, 6.1) || '%';
    freq=cat(COUNT,' (',strip(percent1),')');
run;

proc sort data=remisstot out=sort_remisstot;
by REMISS1;
run;

proc transpose data=sort_remisstot out=transp_remisstot(drop=_: rename=(REMISS1=Group1 COL1='All Patients'n));
by Remiss1;
var freq;
run;

data remiss2_;
    retain Variable Group1 Placebo;
    set agegrtot_2 transp_remisstot; 
run;

data remiss_;
merge remiss1_ remiss2_;
run;

proc means data=sort_dm n mean std median min max;
	var PRTXDUR;
	by ARM;
	output out=Wk_stats n=N1 mean=Mean1 std=StdDev1 median=Median1 min=Min1 
		max=Max1;
run;

data wk(drop=_: N1 Mean1 StdDev1 Median1 Min1 Max1);
	set Wk_stats;
	N=put(N1, 3.);
	Mean=put(round(Mean1, 0.1), 4.1);
	StdDev=put(round(StdDev1, 0.1), 4.1);
	Median=put(round(Median1, 0.1), 4.1);
	Range=catx(' ', put(min1, 2.), '-', put(max1, 2.));
	'Mean (SD)'n=cat(Mean, ' (', strip(StdDev), ')');
run;

proc transpose data=wk out=transp_wk(rename=(_NAME_=Group1));
	id ARM;
	var N 'Mean (SD)'n Median Range;
run;

data wk1_;
	retain Variable Group1 Placebo;
	length Variable $27 Group1 $32;
	set transp_wk;
	Variable='Weeks from the last therapy';
run;

proc means data=sort_dm n mean std median min max;
	var PRTXDUR;
	output out=Wk_tot n=N1 mean=Mean1 std=StdDev1 median=Median1 min=Min1 
		max=Max1;
run;

data wk_tot(drop=_: N1 Mean1 StdDev1 Median1 Min1 Max1);
	set Wk_tot;
	N=put(N1, 3.);
	Mean=put(round(Mean1, 0.1), 4.1);
	StdDev=put(round(StdDev1, 0.1), 4.1);
	Median=put(round(Median1, 0.1), 4.1);
	Range=catx(' ', put(min1, 2.), '-', put(max1, 2.));
	'Mean (SD)'n=cat(Mean, ' (', strip(StdDev), ')');
run;

proc transpose data=wk_tot out=transp_wk_tot(rename=(_NAME_=Group1 COL1='All Patients'n));
	var N 'Mean (SD)'n Median Range;
run;

data wk_;
retain Variable Group1 Placebo;
merge wk1_ transp_wk_tot;
run;

data dm_set;
set age_ agegr_ sex_ ethnic_ race_ wt_ ECOG_ remiss_ wk_;
run;

%LET placebon = 32;
%LET cmpn = 33;

options number nodate;
ods escapechar='^';
ods pdf file = '/home/u63774111/Project/Project_2C/2C_Submission/DMTable.pdf' style=Journal;
footnote1 j=l "Study PRJ5457C";
footnote2 j=l "TLG Specifications, Version v1.0" j=r "Date: &sysdate9";
proc report data=dm_set spacing=1 nowd headline headskip
style(report) = [cellspacing=6 cellpadding=2];
title1 j=c "Table 14.1/5";
title2 j=c "^S={font_size=12pt}Demographic and Baseline Characteristics" ;
title3 j=c "^S={font_size=12pt}Randomized Subjects";
column Variable Group1 Placebo 'CMP-135'n 'All Patients'n;
define Variable / Group '    ' order style(column)=[cellwidth=135pt];
define Group1 / '   ' order style(column)=[cellwidth=165pt];
define Placebo / "Placebo / n=&placebon" style(column)=[cellwidth=75pt] center;
define 'CMP-135'n / display "CMP-135/ n=&cmpn" style(column)=[cellwidth=75pt] center;
define 'All Patients'n / display 'All Patients / n=65' style(column)=[cellwidth=75pt] center;
compute after Variable;
line ' ';
endcomp;
run;
ods pdf close;
