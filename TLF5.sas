/*log file*/
proc printto log='/home/u63774111/Project/Project_2C/2C_Submission/TLF7.log';

*1. Use ADSL data to select ITT records --> for Randomized subjects;
libname tlfip "/home/u63774111/Project/Project_2C/TLF_input";
libname adtlf xport "/home/u63774111/Project/Project_2C/AdamInput/ADSL.xpt" 
	access=readonly;
proc copy inlib=adtlf outlib=tlfip;
run;

proc sort data=tlfip.adsl out=adsl;
by USUBJID;
where ITTFL='Y'; /*Select ITT Flag records*/
run;

*2. Use ADTTE data to select PFS records --> for Progression Free Survival;
libname tlfip "/home/u63774111/Project/Project_2C/TLF_input";
libname adtlf xport "/home/u63774111/Project/Project_2C/AdamInput/ADTTE.xpt" 
	access=readonly;
proc copy inlib=adtlf outlib=tlfip;
run;

proc sort data=tlfip.adtte out=adtte;
by USUBJID;
where PARAMCD='TTPFS'; /*Select ITT Flag records*/
run;

*3. Merge with ADSL to select ITT flags only;
data adtte1(keep=USUBJID PARAM PARAMCD CNSR EVNTDESC ITTFL AVAL TRT01P TRT01AN REMISS:);
merge adsl(in=a) adtte(in=b);
by USUBJID;
if a; /*ITT Population*/
run;

*4. Sorting the data by Remission as we're focusing on 2nd remission;
proc sort data=adtte1;
by REMISS REMISSN TRT01AN;
run;

*5. Generating survival curves by treatment group and At risk table;
*   -->Generates survival curves stratified by trt01p and conducts a log-rank 
   test to compare them, adjusting p-values using the Sidak method.;
   
* i. Survival curves by treatment
  ii. At risk table (No. of subjects at risk at different time points);

ods output Survivalplot=SurvivalPlotData;
ods graphics on;
proc lifetest data=adtte1 plots=survival(atrisk=0 to 15 by 3);
time aval * cnsr(1);
strata trt01p/ test=logrank adjust=sidak;
run;



*6. Generating survival curves by treatment group for each remission and survival statistics;

* i. Survival curves by Remission
  ii. Survival statistics: Median Time (mo);
  
ods output HomTests=pvalue (where=(test in ("Log-Rank", "Wilcoxon"))) Quartiles=qrts;
proc lifetest data=adtte1 alpha=0.05 outsurv=outsurv1;
by remiss remissn;
time aval*cnsr(1);
strata trt01p;
run;
ods trace off;

*Note: In qrts data, we can get Median time. It contains the median survival times for
       each treatment group; 

/* Create macro variables for the median survival times */
proc sql noprint;
    select round(estimate,0.1) into :median_time_placebo
    from qrts
    where trt01p='Placebo' and percent=50;

    select round(estimate,0.1) into :median_time_cmp135
    from qrts
    where trt01p='CMP-135' and percent=50;
quit;


*7. Hazard Ratio and 95% CI;

proc phreg data=adtte1;
    class trt01p (ref="Placebo");
    model aval*cnsr(1) = trt01p;
    hazardratio 'Hazard Ratio' trt01p;
run;



*8. Using Approcah2: PROC TEMPLATE & PROC SGRENDER to create a final KM figure;
ods escapechar='^';
ods listing  gpath="/home/u63774111/Project/Project_2C/2C_Submission";
ods graphics / reset width=8in height=10in imagename="Survival_Plot_SG" ;
title1 j=c "^S={fontweight=light} Figures 14.2.1/2";
title2 j=c "^S={fontweight=light} Kaplan Meier Curves for Progression Free Survival by Treatment Arm in Second Remission";
title3 j=c "^S={fontweight=light} Randomized Subjects with 2nd Remission";
footnote1 "           ";
footnote2 j=l h=6pt  "Study PRJ5457C" j=r "Page 1 of 1";
footnote3 j=l h=6pt  "TLG Specifications, Version 1.0";

Proc template;
define statgraph SurvivalPlotAtRisk_Outside; /*giving template name*/
begingraph;
   layout lattice / columns=1 rowweights=(0.85 0.15) rowgutter=10;
      layout overlay / yaxisopts=(label="Progression-Free Rate" linearopts=(viewmin=0))
                       xaxisopts=(label="Time to Progression (months)");
          
          /* Kaplan-Meier Survival Plot*/
          stepplot x=time y=survival / group=stratum lineattrs=(pattern=solid) name='s';
          scatterplot x=time y=censored / markerattrs=(symbol=plus color=black) name='c';
          scatterplot x=time y=censored / markerattrs=(symbol=plus color=black) GROUP=stratum;

          discretelegend 'c' / location=inside halign=left valign=bottom;
          discretelegend 's';
      endlayout;
      layout overlay / xaxisopts=(display=none) walldisplay=none yaxisopts=(display=none reverse=true);
         blockplot x=tatrisk block=atrisk / class=stratum display=(values label) valuehalign=start valueattrs=(size=8) labelattrs=(size=8);
      endlayout;
   endlayout;
endgraph;
end;
run;

ods graphics / reset width=5in height=3in imagename='SurvivalPlotAtRisk_Outside';
proc sgrender data=SurvivalPlotData template=SurvivalPlotAtRisk_Outside;
run;




/*            layout overlay / xaxisopts=(display=none) yaxisopts=(display=none);
              entry halign=right valign=top "Placebo CMP-135" / textattrs=(size=8 weight=bold) location=inside pad=(top=10px right=10px);
              entry halign=right "Median Time (mo):        &median_time_placebo       &median_time_cmp135"  / textattrs=(size=8 weight=light) location=inside pad=(bottom=10px);
              entry halign=right "Hazard Ratio:                                &hazard_ratio" / textattrs=(size=8 weight=light) location=inside pad=(bottom=10px);
              entry halign=right "(95% CI):                                    &hazard_ratio_CI" / textattrs=(size=8 weight=light) location=inside pad=(bottom=10px);
              entry halign=right "Log-rank p-value:                         &logrank_pvalue" / textattrs=(size=8 weight=light) location=inside;
              */