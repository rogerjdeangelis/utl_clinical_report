OBJECTIVE IS TO PRODUCE THIS REPORT
===================================

see for rtf report
https://www.dropbox.com/s/d8no2cqpvr6j9q0/utl_clinical_report.rtf?dl=0

PAGE 1

                                      Table : Demographics
                                   (Intent to Treat Population)

                                               Aspirin     Placebo     All
                                               (N= 45)     (N= 46)     (N= 91)
Sex - n (%)
  Male                                         9(20%)      12(26%)     21(23%)
  Female                                       36(80%)     34(74%)     70(77%)

Race - n (%)
  Non-White or Caucasian                       11(24%)     5(11%)      16(18%)
  White or Caucasian                           34(76%)     41(89%)     75(82%)
  Black or African American                    3(7%)       4(9%)       7(8%)
  Hispanic or Latino                           5(11%)      1(2%)       6(7%)
  Asian                                        2(4%)       0(0%)       2(2%)
  Japanese                                     0(0%)       0(0%)       0(0%)
  American Indian or Alaska Native             0(0%)       0(0%)       0(0%)
  Native Hawaiian or Other Pacific Islander    0(0%)       0(0%)       0(0%)
  Other                                        1(2%)       0(0%)       1(1%)

                                                                     Page 1 of 2
  Program: c:/utl/dm.sas_09FEB17
  Log: c:/utl/dm.log_09FEB17
  see Protocol 1013.6(Oncology)


PAGE 2
                                      Table : Demographics
                                   (Intent to Treat Population)

                                              Aspirin     Placebo     All
                                              (N= 45)     (N= 46)     (N= 91)
Age
  N                                              45          46          91
  Mean(SD)                                    52(8.6)     51(9.6)     51(9.1)
  Median                                      31, 68      26, 71      26, 71

Weight
  N                                              45          46         91
  Mean(SD)                                    74(15.2)    78(19.7)   76(17.7)
  Median                                      49, 125     41, 120    41, 125

Height
  N                                              45          46         91
  Mean(SD)                                    133(27.3    141(35.5)  137(31.8)
  Median                                      88, 224     73, 216    73, 224

                                                                   Page 2 of 2
  Program: c:/utl/dm.sas_09FEB17
  Log: c:/utl/dm.log_09FEB17
  see Protocol 1013.6(Oncology)



WORKING CODE (full solution below this is just documentation)
==============================================================

        You have to layout your report ahead of time in a format

        This method does require that you layout the entire report
        It might be better in the future to add a treatment format - even though it is not needed

     LAYOUT THE REPORT
     =================

      EXAMPLE OF SEX and AGE formats (see below for all formats)
      ==========================================================
                     Major     Page #      Page Line       Line Description      Minor
                     Categ                                                       Category
                     =====    ========    ===========
              1 =     'SEX    @Page @01    @Order @010     @Sex - n (%)              @\li360 Male'
              2 =     'SEX    @Page @01    @Order @020     @Sex - n (%)              @\li360 Female';


              1  =    "AGE    @Page @02    @Order @010     @Age    @\li360 N"        @N
              2  =    "AGE    @Page @02    @Order @020     @Age    @\li360 Mean(SD)" @MEAN STD
              3  =    "AGE    @Page @02    @Order @030     @Age    @\li360 Median"   @MEDIAN
              4  =    "AGE    @Page @02    @Order @040     @Age    @\li360 Min, Max" @MIN MAX   ;


         * COMPLETE FORMAT;
         proc format;
           value sex
              1  ='SEX @Page @01 @Order @010 @Sex - n (%)  @\li360 Male'
              2 = 'SEX @Page @01 @Order @020 @Sex - n (%)  @\li360 Female';


     NORMALIZE AND ADD SOME FORMATTED VALUES
     ========================================
           set dm;
           question=put(sex,sex.); answer=1;   link all;
           question=put(rcd,rcd.); answer=1;   link all;
           question=put(rcd,rcx.); answer=1;   link all;
           question='AGE'        ; answer=age; link all;
           question='WGT'        ; answer=wgt; link all;
           question='HGT'        ; answer=hgt; link all;
         return;
         all:
           output;
           savtrt=trt;
           trt="All";
           output;
           trt=savtrt;
         return;

          Obs    QUESTION                                                              TRT        ANSWER

            1    SEX @Page @01 @Order @020 @Sex - n (%)  @\li360 Female                Aspirin      1.00
            2    SEX @Page @01 @Order @020 @Sex - n (%)  @\li360 Female                All          1.00
            3    RCD @Page @01 @Order @030 @Race - n (%) @\li360 White or Caucasian    Aspirin      1.00


     BUILD SHELL FROM FORMAT SO MISSING CATEGORIES CAN BE REPRESENTED (note weigh of 0)
     ==================================================================================
          keep trt question answer;
          set unv1st(where=(scan(label,8,'@') eq ''));      * only categorical variables ;
          trt="Placebo"; question=label; answer=0; output;
          trt="Aspirin"; question=label; answer=0; output;
          trt="All"    ; question=label; answer=0; output;
         run;

     FILL IN THE MISSING CATEGORIES WITH 0 ANSWERS(WEIGHTS)
     ========================================================
          select
            coalesce(dat.trt,shl.trt)                                   as trt
           ,coalesce(substr(dat.question,1,3),substr(shl.question,1,3)) as grp       length=3
           ,coalesce(dat.question,shl.question)                         as question
           ,coalesce(dat.answer,shl.answer)                             as answer
          from
           (select distinct * from shl) as shl left join nrm1st as dat
          on
           shl.question = dat.question  and
           shl.trt      = dat.trt

     CALCULATE N(PCT) FOR CATEGORICAL VARIABLES
     ==========================================

            select
             distinct
              l.trt
             ,l.grp
             ,l.question
             ,r.sumgrp
             ,cats(put(sum(l.answer),4.),'(',put(sum(l.answer)/r.sumgrp,percent.),')') as answer
           from
              shldat as l, (select trt, grp, sum(answer) as sumgrp from shldat group by trt, grp) as r
           where
              l.trt        =  r.trt  and
              l.grp        =  r.grp
           group
              by l.trt, l.grp, l.question

         Up to 40 obs WORK.CNTPCT total obs=36

         Obs    TRT        GRP    QUESTION                                                                     SUMGRP   ANSWER

           1    All        RCD    RCD @Page @01 @Order @030 @Race - n (%) @\li360 White or Caucasian               91   75(82%)
           2    All        RCD    RCD @Page @01 @Order @050 @Race - n (%) @\li360 Black or African American        91   7(8%)
           3    All        RCD    RCD @Page @01 @Order @060 @Race - n (%) @\li360 Hispanic or Latino               91   6(7%)

    GET THE STATISTICS WE NEED FROM THE FORMAT
    ===========================================
          select distinct(scan(label,8,'@')) into :unvanl separated by ' ' from unv1st where index(fmtname,'_N')>0;
          select distinct(quote(strip(scan(label,1,'@')))) into :unvvar separated by ' ' from unv1st where index(fmtname,'_N')>0;

        UNVANL=MEAN STD MEDIAN MIN MAX N
        UNVVAR="AGE" "HGT" "WGT"


    COMPUTE STATISTICS FOR NUMERIC VARIABLES
    ========================================

        * this tip predates the median in SQL - simplification is possible now;
        proc means data=nrm1st(where=(scan(question,1,'@') in (&unvvar))) &unvanl nway;
        class trt question;
        var answer;
                                                          ANSWER_         ANSWER_
       TRT         QUESTION  NOBS     ANSWER_MEAN          STDDEV          MEDIAN      ANSWER_MIN      ANSWER_MAX        ANSWER_N

       Aspirin     AGE         45    51.733333333    8.5610109853              53              31              68              45
       Aspirin     HGT         45         133.056    27.306971338          129.78            88.2           224.1              45
       Aspirin     WGT         45           73.92    15.170539632            72.1              49           124.5              45


    PUT CATEGORICAL AND NUMERIC INTO NORMALIZED FORM

       * normalize numeric variables;
        do until (dne);
          set demunv end=dne;
          grp=question;
          fmt=strip(question)!!'_n';

          question=putn(1,fmt);
          answer=put(answer_n,5.);
          output;

          question=putn(2,fmt);
          answer=cats(put(answer_mean,??5.),'(',put(answer_stddev,??5.1),')');
          output;

          question=putn(3,fmt);
          answer=strip(put(answer_min,5.))!!', '!!strip(put(answer_max,5.));
          output;

        end;
        * cat variables;
        do until (dn1);
          set cntpct end=dn1;
          format _all_;
          output;
        end;
        stop;
       run;


       QUESTION                                                                                     ANSWER       TRT        GRP

       AGE @Page @02 @Order @010 @Age    @\li360 N        @N                                           91        All        AGE
       AGE @Page @02 @Order @020 @Age    @\li360 Mean(SD) @MEAN STD                                 51(9.1)      All        AGE
       AGE @Page @02 @Order @030 @Age    @\li360 Median   @MEDIAN                                   26, 71       All        AGE
       SEX @Page @01 @Order @010 @Sex - n (%)  @\li360 Male                                         21(23%)      All        SEX
       SEX @Page @01 @Order @020 @Sex - n (%)  @\li360 Female                                       70(77%)      All        SEX


   SORT TRANSPOSE, PARSE QUESTION, GET BIG Ns, NUMBER OF PAGES ANS TITLES AND FOOTNOTES

       proc sort data=nrmunv out=srt nodupkey;
         by question trt;

       proc transpose data=srt out=xpo(drop=_name_) ;
        by question;
        id trt;
        var answer;

        select
           input(scan(question,3,'@'),5.) as pge
          ,scan(question,5,'@')           as odr length=3
          ,scan(question,6,'@')           as mjr length=64
          ,scan(question,7,'@')           as mnr length=64
          ,aspirin  length=24
          ,placebo  length=24
          ,all      length=24
        from
          xpo
        where
          scan(question,5,'@') ne 'XX'
        order
          by pge, odr

       select max(pge) into :maxpge separated by '' from prerpt;quit;

       MAXPGE=2

       BIG Ns
         select resolve('%Let '!!trt!!'=%sysfunc(compbl('!!trt!!'#(N='!!Put(Count(answer),4.)!!');))')
         from nrm1st where question='AGE'  Group by Trt


       ALL=All #(N= 91)
       ASPIRIN=Aspirin #(N= 45)
       PLACEBO=Placebo #(N= 46)


       %let ttl1=Table : Demographics;
       %let TTL2=Safety Dataset;
       %let TTL3=(Intent to Treat Population);
       %let TTL4=Placebo-Aspirin;

   CREATE REPORT

        ods rtf file="&output1" style=utl_rtflan100 notoc_data;
        %macro mny(pgemax);
         %do pge=1 %to &pgemax;
          ods rtf prepage="^S={outputwidth=100% just=c font_size=11pt font_face=arial} {&ttl1}^{newline}{&ttl3}";
          proc report data=prerpt (where=(pge=&pge)) nowd split='#' missing;
             cols  mjr mnr aspirin placebo all;
              define mjr           / order    noprint order=data;
              define mnr           / display  ""         style={cellwidth=30%  just=l } order=data;
              define aspirin       / display  "&aspirin" style={cellwidth=22%  just=c } order=data;
              define placebo       / display  "&placebo" style={cellwidth=22%  just=c } order=data;
              define All           / display  "&All"     style={cellwidth=23%  just=c } order=data;
              compute before mjr / style=[just=l];
                line mjr $96.;
              endcomp;
          run;quit;
          ods rtf text="^S={outputwidth=100% just=r font_size=9pt} Page &pge of &pgemax";
          ods rtf text="^S={outputwidth=100% just=l font_size=8pt font_style=italic}  {Program: c:/utl/dm.sas_&sysdate}";
          ods rtf text="^S={outputwidth=100% just=l font_size=8pt font_style=italic}  {Log: c:/utl/dm.log_&sysdate}";
          ods rtf text="^S={outputwidth=100% just=l font_size=8pt font_style=italic}  {see Protocol 1013.6(Oncology)}";
          run;quit;
         %end;
        %mend mny;
        %mny(&maxpge);


HAVE
====

Up to 40 obs from dm total obs=91

Obs     TRT     PAT     WGT       HGT     RCD    AGE    SEX

  1   Aspirin     1     77.1    138.78      1     50     2
  2   Aspirin    50     76.2    137.16      1     49     2
  3   Placebo     2     71.4    128.52      1     58     2
  4   Placebo    51    112.0    201.60      1     67     2
  5   Aspirin     3     56.0    100.80      1     61     2
  6   Placebo    52     84.4    151.92      1     61     2
  7   Aspirin     4     76.2    137.16      1     38     2
  8   Aspirin    53     70.3    126.54      1     64     2
  9   Aspirin     5     88.9    160.02      1     54     2
....

 87   Placebo    45     59.5    107.10      1     59     2
 88   Placebo    48     62.6    112.68      1     44     2
 89   Placebo    46     40.8     73.44      1     55     2
 90   Placebo    49     74.4    133.92      1     60     2
 91   Aspirin    47     64.2    115.56      1     55     2

LAYOUT OF REPORT
================

WANT
====

see for rtf report
https://dl.dropboxusercontent.com/u/15716238/utl_datnul.rtf

Text version

PAGE 1

                                      Table : Demographics
                                   (Intent to Treat Population)

                                               Aspirin     Placebo     All
                                               (N= 45)     (N= 46)     (N= 91)
Sex - n (%)
  Male                                         9(20%)      12(26%)     21(23%)
  Female                                       36(80%)     34(74%)     70(77%)

Race - n (%)
  Non-White or Caucasian                       11(24%)     5(11%)      16(18%)
  White or Caucasian                           34(76%)     41(89%)     75(82%)
  Black or African American                    3(7%)       4(9%)       7(8%)
  Hispanic or Latino                           5(11%)      1(2%)       6(7%)
  Asian                                        2(4%)       0(0%)       2(2%)
  Japanese                                     0(0%)       0(0%)       0(0%)
  American Indian or Alaska Native             0(0%)       0(0%)       0(0%)
  Native Hawaiian or Other Pacific Islander    0(0%)       0(0%)       0(0%)
  Other                                        1(2%)       0(0%)       1(1%)

                                                                     Page 1 of 2
  Program: c:/utl/dm.sas_09FEB17
  Log: c:/utl/dm.log_09FEB17
  see Protocol 1013.6(Oncology)


PAGE 2
                                    Table : Demographics
                                 (Intent to Treat Population)

                                              Aspirin     Placebo     All
                                              (N= 45)     (N= 46)     (N= 91)
Age
  N                                              45          46          91
  Mean(SD)                                    52(8.6)     51(9.6)     51(9.1)
  Median                                      31, 68      26, 71      26, 71

Weight
  N                                              45          46         91
  Mean(SD)                                    74(15.2)    78(19.7)   76(17.7)
  Median                                      49, 125     41, 120    41, 125

Height
  N                                              45          46         91
  Mean(SD)                                    133(27.3    141(35.5)  137(31.8)
  Median                                      88, 224     73, 216    73, 224

                                                                   Page 2 of 2
  Program: c:/utl/dm.sas_09FEB17
  Log: c:/utl/dm.log_09FEB17
  see Protocol 1013.6(Oncology)


*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;


/* cannot have formats prior to this code - could backup and restore */
proc datasets library=work kill;
  delete formats;
run;quit;


%let output1=d:/rtf/utl_clinical_report.rtf;

options validvarname=upcase; /* will not work without this */
proc sql;
   Create table dm(pat float, wgt float, hgt float, rcd float, trt varchar(8), age float, sex float);
   Insert into dm(pat, wgt, hgt, rcd, trt, age, sex)
   Values(1, 77.1, 138.78, 1, "Aspirin" 50, 2)    Values(50, 76.2, 137.16, 1, "Aspirin" 49, 2)
   Values(2, 71.4, 128.52, 1, "Placebo" 58, 2)    Values(51, 112.0, 201.60, 1, "Placebo" 67, 2)
   Values(3, 56.0, 100.80, 1, "Aspirin" 61, 2)    Values(52, 84.4, 151.92, 1, "Placebo" 61, 2)
   Values(4, 76.2, 137.16, 1, "Aspirin" 38, 2)    Values(53, 70.3, 126.54, 1, "Aspirin" 64, 2)
   Values(5, 88.9, 160.02, 1, "Aspirin" 54, 2)    Values(54, 87.1, 156.78, 2, "Placebo" 54, 2)
   Values(6, 119.8, 215.64, 2, "Placebo" 50, 2)   Values(55, 89.4, 160.92, 1, "Placebo" 49, 2)
   Values(7, 66.7, 120.06, 1, "Placebo" 43, 2)    Values(56, 88.5, 159.30, 1, "Aspirin" 56, 2)
   Values(8, 111.6, 200.88, 1, "Placebo" 66, 2)   Values(57, 67.5, 121.50, 1, "Placebo" 42, 2)
   Values(9, 67.4, 121.32, 1, "Placebo" 47, 2)    Values(58, 102.5, 184.50, 1, "Placebo" 48, 2)
   Values(10, 92.1, 165.78, 1, "Placebo" 59, 2)   Values(59, 81.1, 145.98, 1, "Placebo" 53, 2)
   Values(11, 102.1, 183.78, 1, "Aspirin" 56, 2)  Values(60, 72.6, 130.68, 1, "Aspirin" 59, 2)
   Values(12, 66.2, 119.16, 1, "Placebo" 45, 2)   Values(61, 124.5, 224.10, 1, "Aspirin" 47, 2)
   Values(13, 112.5, 202.50, 2, "Placebo" 57, 2)  Values(62, 70.0, 126.00, 1, "Placebo" 43, 2)
   Values(14, 103.9, 187.02, 2, "Aspirin" 47, 2)  Values(63, 62.6, 112.68, 3, "Aspirin" 53, 2)
   Values(15, 70.8, 127.44, 1, "Placebo" 56, 2)   Values(64, 60.8, 109.44, 4, "Aspirin" 50, 2)
   Values(17, 79.8, 143.64, 1, "Aspirin" 68, 2)   Values(65, 58.7, 105.66, 1, "Placebo" 47, 2)
   Values(18, 65.1, 117.18, 1, "Placebo" 35, 2)   Values(66, 63.7, 114.66, 1, "Aspirin" 43, 2)
   Values(19, 100.7, 181.26, 1, "Placebo" 45, 2)  Values(67, 77.1, 138.78, 88, "Aspirin" 49, 2)
   Values(20, 61.7, 111.06, 1, "Aspirin" 54, 1)   Values(68, 53.5, 96.30, 1, "Placebo" 49, 2)
   Values(21, 79.2, 142.56, 2, "Placebo" 50, 1)   Values(69, 95.7, 172.26, 1, "Aspirin" 55, 2)
   Values(22, 89.8, 161.64, 1, "Placebo" 54, 1)   Values(70, 68.0, 122.40, 3, "Aspirin" 57, 2)
   Values(23, 63.1, 113.58, 2, "Aspirin" 38, 1)   Values(71, 54.0, 97.20, 3, "Aspirin" 66, 2)
   Values(24, 67.8, 122.04, 1, "Placebo" 57, 1)   Values(72, 85.3, 153.54, 3, "Aspirin" 44, 2)
   Values(25, 82.6, 148.68, 1, "Aspirin" 53, 1)   Values(74, 52.2, 93.96, 1, "Aspirin" 55, 2)
   Values(26, 90.7, 163.26, 1, "Placebo" 38, 1)   Values(75, 86.2, 155.16, 1, "Aspirin" 58, 2)
   Values(27, 73.0, 131.40, 1, "Aspirin" 60, 1)   Values(76, 59.0, 106.20, 3, "Placebo" 46, 2)
   Values(28, 64.4, 115.92, 1, "Placebo" 38, 1)   Values(77, 59.0, 106.20, 4, "Aspirin" 45, 2)
   Values(29, 59.4, 106.92, 1, "Placebo" 51, 1)   Values(78, 116.6, 209.88, 1, "Placebo" 51, 2)
   Values(30, 70.8, 127.44, 1, "Aspirin" 61, 1)   Values(79, 55.1, 99.18, 1, "Placebo" 39, 2)
   Values(31, 72.1, 129.78, 1, "Aspirin" 56, 1)   Values(80, 64.9, 116.82, 1, "Aspirin" 40, 2)
   Values(32, 54.0, 97.20, 1, "Aspirin" 56, 1)    Values(81, 85.3, 153.54, 1, "Aspirin" 53, 2)
   Values(33, 62.8, 113.04, 1, "Aspirin" 37, 1)   Values(82, 45.8, 82.44, 1, "Placebo" 57, 2)
   Values(34, 62.6, 112.68, 1, "Placebo" 37, 1)   Values(83, 71.7, 129.06, 2, "Aspirin" 52, 2)
   Values(35, 79.4, 142.92, 1, "Placebo" 44, 1)   Values(84, 61.9, 111.42, 1, "Aspirin" 34, 2)
   Values(36, 60.8, 109.44, 1, "Placebo" 50, 1)   Values(85, 82.1, 147.78, 1, "Aspirin" 46, 2)
   Values(37, 89.8, 161.64, 3, "Aspirin" 50, 1)   Values(86, 58.5, 105.30, 1, "Aspirin" 53, 2)
   Values(38, 76.8, 138.24, 1, "Placebo" 40, 1)   Values(87, 68.9, 124.02, 1, "Aspirin" 66, 2)
   Values(39, 87.1, 156.78, 1, "Placebo" 51, 1)   Values(88, 68.9, 124.02, 1, "Aspirin" 42, 2)
   Values(40, 64.3, 115.74, 1, "Placebo" 26, 1)   Values(89, 104.8, 188.64, 1, "Placebo" 69, 2)
   Values(41, 109.0, 196.20, 1, "Placebo" 58, 2)  Values(90, 79.4, 142.92, 1, "Placebo" 65, 2)
   Values(42, 77.2, 138.96, 1, "Placebo" 44, 2)   Values(91, 87.1, 156.78, 1, "Aspirin" 58, 2)
   Values(43, 78.0, 140.40, 1, "Aspirin" 57, 2)   Values(92, 89.8, 161.64, 1, "Placebo" 71, 2)
   Values(44, 49.0, 88.20, 1, "Aspirin" 31, 2)    Values(93, 75.3, 135.54, 1, "Aspirin" 52, 2)
   Values(45, 59.5, 107.10, 1, "Placebo" 59, 2)   Values(48, 62.6, 112.68, 1, "Placebo" 44, 2)
   Values(46, 40.8, 73.44, 1, "Placebo" 55, 2)    Values(49, 74.4, 133.92, 1, "Placebo" 60, 2)
   Values(47, 64.2, 115.56, 1, "Aspirin" 55, 2)
 ;quit;

proc print width=min;
run;quit;


/* this method does require that you layout the entire report - see non format method for work around */
/* it might be better in the future to add a treatment format - even though it is not needed */
proc format;
  value sex
     1  ='SEX @Page @01 @Order @010 @Sex - n (%)  @\li360 Male'
     2 = 'SEX @Page @01 @Order @020 @Sex - n (%)  @\li360 Female';
  value rcd
     1 = "RCD @Page @01 @Order @030 @Race - n (%) @\li360 White or Caucasian"
     2 = "RCD @Page @01 @Order @050 @Race - n (%) @\li360 Black or African American"
     3 = "RCD @Page @01 @Order @060 @Race - n (%) @\li360 Hispanic or Latino"
     4 = "RCD @Page @01 @Order @070 @Race - n (%) @\li360 Asian"
     5 = "RCD @Page @01 @Order @080 @Race - n (%) @\li360 Japanese"
     6 = "RCD @Page @01 @Order @090 @Race - n (%) @\li360 American Indian or Alaska Native"
     7 = "RCD @Page @01 @Order @100 @Race - n (%) @\li360 Native Hawaiian or Other Pacific Islander"
    88 = "RCD @Page @01 @Order @110 @Race - n (%) @\li360 Other";
  value rcx
    2, 3, 4, 5, 6, 7, 88
        = "RCX @Page @01 @Order @022 @Race - n (%) @\li360 Non-White or Caucasian"
    1   = "RCX @Page @XX @Order @0XX @Race - n (%) @\li360 White Caucasian";    /* not in report */
  value age_n
    1  = "AGE @Page @02 @Order @010 @Age    @\li360 N"        @N
    2  = "AGE @Page @02 @Order @020 @Age    @\li360 Mean(SD)" @MEAN STD
    3  = "AGE @Page @02 @Order @030 @Age    @\li360 Median"   @MEDIAN
    4  = "AGE @Page @02 @Order @040 @Age    @\li360 Min, Max" @MIN MAX   ;  /* 8th item means univariate stat */
  value wgt_n
    1  = "WGT @Page @02 @Order @050 @Weight @\li360 N"        @N
    2  = "WGT @Page @02 @Order @060 @Weight @\li360 Mean(SD)" @MEAN STD
    3  = "WGT @Page @02 @Order @070 @Weight @\li360 Median"   @MEDIAN
    4  = "WGT @Page @02 @Order @080 @Weight @\li360 Min, Max" @MIN MAX  ;
  value hgt_n
    1  = "HGT @Page @02 @Order @090 @Height @\li360 N"        @N
    2  = "HGT @Page @02 @Order @100 @Height @\li360 Mean(SD)" @MEAN STD
    3  = "HGT @Page @02 @Order @110 @Height @\li360 Median"   @MEDIAN
    4  = "HGT @Page @02 @Order @120 @Height @\li360 Min, Max" @MIN MAX   ;
    /* expects all variables to have the same stats*/
    /* but can be generalized */
run;quit;


%Macro utl_rtflan100
    (
      style=utl_rtflan100,
      frame=box,
      rules=groups,
      bottommargin=1.0in,
      topmargin=1.5in,
      rightmargin=1.0in,
      cellheight=10pt,
      cellpadding = 7,
      cellspacing = 3,
      leftmargin=.75in,
      borderwidth = 1
    ) /  Des="SAS Rtf Template for CompuCraft";

options orientation=landscape;run;quit;

ods path work.templat(update) sasuser.templat(update) sashelp.tmplmst(read);

Proc Template;

   define style &Style;
   parent=styles.rtf;


        replace body from Document /

               protectspecialchars=off
               asis=on
               bottommargin=&bottommargin
               topmargin   =&topmargin
               rightmargin =&rightmargin
               leftmargin  =&leftmargin
               ;

        replace color_list /
              'link' = blue
               'bgH'  = _undef_
               'fg'  = black
               'bg'   = _undef_;

        replace fonts /
               'TitleFont2'           = ("Arial, Helvetica, Helv",11pt,Bold)
               'TitleFont'            = ("Arial, Helvetica, Helv",11pt,Bold)

               'HeadingFont'          = ("Arial, Helvetica, Helv",10pt)
               'HeadingEmphasisFont'  = ("Arial, Helvetica, Helv",10pt,Italic)

               'StrongFont'           = ("Arial, Helvetica, Helv",10pt,Bold)
               'EmphasisFont'         = ("Arial, Helvetica, Helv",10pt,Italic)

               'FixedFont'            = ("Courier New, Courier",9pt)
               'FixedEmphasisFont'    = ("Courier New, Courier",9pt,Italic)
               'FixedStrongFont'      = ("Courier New, Courier",9pt,Bold)
               'FixedHeadingFont'     = ("Courier New, Courier",9pt,Bold)
               'BatchFixedFont'       = ("Courier New, Courier",7pt)

               'docFont'              = ("Arial, Helvetica, Helv",10pt)

               'FootFont'             = ("Arial, Helvetica, Helv", 9pt)
               'StrongFootFont'       = ("Arial, Helvetica, Helv",8pt,Bold)
               'EmphasisFootFont'     = ("Arial, Helvetica, Helv",8pt,Italic)
               'FixedFootFont'        = ("Courier New, Courier",8pt)
               'FixedEmphasisFootFont'= ("Courier New, Courier",8pt,Italic)
               'FixedStrongFootFont'  = ("Courier New, Courier",7pt,Bold);

        replace GraphFonts /
               'GraphDataFont'        = ("Arial, Helvetica, Helv",8pt)
               'GraphAnnoFont'        = ("Arial, Helvetica, Helv",8pt)
               'GraphValueFont'       = ("Arial, Helvetica, Helv",10pt)
               'GraphUnicodeFont'     = ("Arial, Helvetica, Helv",10pt)
               'GraphLabelFont'       = ("Arial, Helvetica, Helv",10pt,Bold)
               'GraphLabel2Font'      = ("Arial, Helvetica, Helv",10pt,Bold)
               'GraphFootnoteFont'    = ("Arial, Helvetica, Helv",8pt)
               'GraphTitle1Font'      = ("Arial, Helvetica, Helv",11pt,Bold)
               'GraphTitleFont'       = ("Arial, Helvetica, Helv",11pt,Bold);

        style table from table /
                outputwidth=100%
                protectspecialchars=off
                asis=on
                background = colors('tablebg')
                frame=&frame
                rules=&rules
                cellheight  = &cellheight
                cellpadding = &cellpadding
                cellspacing = &cellspacing
                bordercolor = colors('tableborder')
                borderwidth = &borderwidth;

         replace Footer from HeadersAndFooters

                / font = fonts('FootFont')  just=left asis=on protectspecialchars=off ;

                replace FooterFixed from Footer
                / font = fonts('FixedFootFont')  just=left asis=on protectspecialchars=off;

                replace FooterEmpty from Footer
                / font = fonts('FootFont')  just=left asis=on protectspecialchars=off;

                replace FooterEmphasis from Footer
                / font = fonts('EmphasisFootFont')  just=left asis=on protectspecialchars=off;

                replace FooterEmphasisFixed from FooterEmphasis
                / font = fonts('FixedEmphasisFootFont')  just=left asis=on protectspecialchars=off;

                replace FooterStrong from Footer
                / font = fonts('StrongFootFont')  just=left asis=on protectspecialchars=off;

                replace FooterStrongFixed from FooterStrong
                / font = fonts('FixedStrongFootFont')  just=left asis=on protectspecialchars=off;

                replace RowFooter from Footer
                / font = fonts('FootFont')  asis=on protectspecialchars=off just=left;

                replace RowFooterFixed from RowFooter
                / font = fonts('FixedFootFont')  just=left asis=on protectspecialchars=off;

                replace RowFooterEmpty from RowFooter
                / font = fonts('FootFont')  just=left asis=on protectspecialchars=off;

                replace RowFooterEmphasis from RowFooter
                / font = fonts('EmphasisFootFont')  just=left asis=on protectspecialchars=off;

                replace RowFooterEmphasisFixed from RowFooterEmphasis
                / font = fonts('FixedEmphasisFootFont')  just=left asis=on protectspecialchars=off;

                replace RowFooterStrong from RowFooter
                / font = fonts('StrongFootFont')  just=left asis=on protectspecialchars=off;

                replace RowFooterStrongFixed from RowFooterStrong
                / font = fonts('FixedStrongFootFont')  just=left asis=on protectspecialchars=off;

                replace SystemFooter from TitlesAndFooters / asis=on
                        protectspecialchars=off just=left;

    end;
run;

quit;

%Mend utl_rtflan100;


 ____        _       _   _
/ ___|  ___ | |_   _| |_(_) ___  _ __
\___ \ / _ \| | | | | __| |/ _ \| '_ \
 ___) | (_) | | |_| | |_| | (_) | | | |
|____/ \___/|_|\__,_|\__|_|\___/|_| |_|

;

/* normalize the data                                                   */
/* you could generate this data step from the format - I choose to KISS */
data nrm1st;
  keep    trt question answer;
  length  question  $96;
  set dm;
  question=put(sex,sex.); answer=1;   link all;
  question=put(rcd,rcd.); answer=1;   link all;
  question=put(rcd,rcx.); answer=1;   link all;
  question='AGE'        ; answer=age; link all;
  question='WGT'        ; answer=wgt; link all;
  question='HGT'        ; answer=hgt; link all;
return;
all:
  output;
  savtrt=trt;
  trt="All";
  output;
  trt=savtrt;
return;
run;

/*
Up to 40 obs WORK.NRM1ST total obs=1,092

 Obs QUESTION                                                              TRT            ANSWER

   1 SEX @Page @01 @Order @020 @Sex - n (%)  @\li360 Female                Aspirin             1
   2 SEX @Page @01 @Order @020 @Sex - n (%)  @\li360 Female                All                 1
   3 RCD @Page @01 @Order @030 @Race - n (%) @\li360 White or Caucasian    Aspirin             1
   4 RCD @Page @01 @Order @030 @Race - n (%) @\li360 White or Caucasian    All                 1
   5 RCX @Page @XX @Order @0XX @Race - n (%) @\li360 White Caucasian       Aspirin             1
   6 RCX @Page @XX @Order @0XX @Race - n (%) @\li360 White Caucasian       All                 1
   7 AGE                                                                   Aspirin            50
   8 AGE                                                                   All                50
   9 WGT                                                                   Aspirin          77.1
  10 WGT                                                                   All              77.1
  11 HGT                                                                   Aspirin        138.78
  12 HGT                                                                   All            138.78
*/


* layot format to table;
proc format library=work.formats cntlout=unv1st;
run;

/* need the shell so missing categories can be represented in the report         */
/* note we use the format to generate all combinations                           */
/* answer will be the weights missing categories will have 0 counts and percents */
data shl;
 length  question  $96;
 keep trt question answer;
 set unv1st(where=(scan(label,8,'@') eq ''));      /* only categorical variables */
 trt="Placebo"; question=label; answer=0; output;
 trt="Aspirin"; question=label; answer=0; output;
 trt="All"    ; question=label; answer=0; output;
run;

/*
Up to 40 obs WORK.SHL total obs=54

Obs  QUESTION                                                                   TRT            ANSWER

  1  RCD @Page @01 @Order @030 @Race - n (%) @\li360 White or Caucasian         Placebo             0
  2  RCD @Page @01 @Order @030 @Race - n (%) @\li360 White or Caucasian         Aspirin             0
  3  RCD @Page @01 @Order @030 @Race - n (%) @\li360 White or Caucasian         All                 0
  4  RCD @Page @01 @Order @050 @Race - n (%) @\li360 Black or African American  Placebo             0
  5  RCD @Page @01 @Order @050 @Race - n (%) @\li360 Black or African American  Aspirin             0
  6  RCD @Page @01 @Order @050 @Race - n (%) @\li360 Black or African American  All                 0
*/

/* fill in the missing categories with 0 answers(weights) */
proc sql;
 create
   table shldat  as
 select
   coalesce(dat.trt,shl.trt)                                   as trt
  ,coalesce(substr(dat.question,1,3),substr(shl.question,1,3)) as grp       length=3
  ,coalesce(dat.question,shl.question)                         as question
  ,coalesce(dat.answer,shl.answer)                             as answer
 from
  (select distinct * from shl) as shl left join nrm1st as dat
 on
  shl.question = dat.question  and
  shl.trt      = dat.trt
 order
  by grp, trt, question;
;quit;

/*
All Obs(560) from dataset shldat
                                                                                                              Weights
Obs  TRT      GRP  QUESTION                                                                                    ANSWER

133  Aspirin  RCD  RCD @Page @01 @Order @060 @Race - n (%) @\li360 Hispanic or Latino                               1
134  Aspirin  RCD  RCD @Page @01 @Order @060 @Race - n (%) @\li360 Hispanic or Latino                               1
135  Aspirin  RCD  RCD @Page @01 @Order @060 @Race - n (%) @\li360 Hispanic or Latino                               1
136  Aspirin  RCD  RCD @Page @01 @Order @060 @Race - n (%) @\li360 Hispanic or Latino                               1
137  Aspirin  RCD  RCD @Page @01 @Order @070 @Race - n (%) @\li360 Asian                                            1
138  Aspirin  RCD  RCD @Page @01 @Order @070 @Race - n (%) @\li360 Asian                                            1
139  Aspirin  RCD  RCD @Page @01 @Order @080 @Race - n (%) @\li360 Japanese                                         0 Not in data
140  Aspirin  RCD  RCD @Page @01 @Order @090 @Race - n (%) @\li360 American Indian or Alaska Native                 0 Not in data
141  Aspirin  RCD  RCD @Page @01 @Order @100 @Race - n (%) @\li360 Native Hawaiian or Other Pacific Islander        0
142  Aspirin  RCD  RCD @Page @01 @Order @110 @Race - n (%) @\li360 Other                                            1
*/


/* categorical n(pct) variables */
proc sql;
   create
     table cntpct as
   select
    distinct
     l.trt
    ,l.grp
    ,l.question
    ,r.sumgrp
    ,cats(put(sum(l.answer),4.),'(',put(sum(l.answer)/r.sumgrp,percent.),')') as answer
  from
     shldat as l, (select trt, grp, sum(answer) as sumgrp from shldat group by trt, grp) as r
  where
     l.trt        =  r.trt  and
     l.grp        =  r.grp
  group
     by l.trt, l.grp, l.question
;quit;

/*
Up to 40 obs WORK.CNTPCT total obs=36

Obs    TRT        GRP    QUESTION                                                                                  SUMGRP   ANSWER

  1    All        RCD    RCD @Page @01 @Order @030 @Race - n (%) @\li360 White or Caucasian                            91   75(82%)
  2    All        RCD    RCD @Page @01 @Order @050 @Race - n (%) @\li360 Black or African American                     91   7(8%)
  3    All        RCD    RCD @Page @01 @Order @060 @Race - n (%) @\li360 Hispanic or Latino                            91   6(7%)
  4    All        RCD    RCD @Page @01 @Order @070 @Race - n (%) @\li360 Asian                                         91   2(2%)
  5    All        RCD    RCD @Page @01 @Order @080 @Race - n (%) @\li360 Japanese                                      91   0(0%)
  6    All        RCD    RCD @Page @01 @Order @090 @Race - n (%) @\li360 American Indian or Alaska Native              91   0(0%)
  7    All        RCD    RCD @Page @01 @Order @100 @Race - n (%) @\li360 Native Hawaiian or Other Pacific Islander     91   0(0%)
  8    All        RCD    RCD @Page @01 @Order @110 @Race - n (%) @\li360 Other                                         91   1(1%)
  9    All        RCX    RCX @Page @01 @Order @022 @Race - n (%) @\li360 Non-White or Caucasian                        91   16(18%)
 10    All        RCX    RCX @Page @XX @Order @0XX @Race - n (%) @\li360 White Caucasian                               91   75(82%)
 11    All        SEX    SEX @Page @01 @Order @010 @Sex - n (%)  @\li360 Male                                          91   0(0%)
 12    All        SEX    SEX @Page @01 @Order @020 @Sex - n (%)  @\li360 Female                                        91   91(100%)
 13    Aspirin    RCD    RCD @Page @01 @Order @030 @Race - n (%) @\li360 White or Caucasian                            45   34(76%)
 14    Aspirin    RCD    RCD @Page @01 @Order @050 @Race - n (%) @\li360 Black or African American                     45   3(7%)
 15    Aspirin    RCD    RCD @Page @01 @Order @060 @Race - n (%) @\li360 Hispanic or Latino                            45   5(11%)
 16    Aspirin    RCD    RCD @Page @01 @Order @070 @Race - n (%) @\li360 Asian                                         45   2(4%)
*/

/* lets get the statistics we need from the format */
proc sql;
  select distinct(scan(label,8,'@')) into :unvanl separated by ' ' from unv1st where index(fmtname,'_N')>0;
  select distinct(quote(strip(scan(label,1,'@')))) into :unvvar separated by ' ' from unv1st where index(fmtname,'_N')>0;
quit;
%put &=unvanl;
%put &=unvvar;

/*
UNVANL=MEAN STD MEDIAN MIN MAX N
UNVVAR="AGE" "HGT" "WGT"
*/

ods output summary=demunv;
proc means data=nrm1st(where=(scan(question,1,'@') in (&unvvar))) &unvanl nway;
format question $3.;
class trt question;
var answer;
run;
ods output close;

/*
Up to 40 obs from demunv total obs=9

                                                          ANSWER_         ANSWER_
Obs    TRT         QUESTION  NOBS     ANSWER_MEAN          STDDEV          MEDIAN      ANSWER_MIN      ANSWER_MAX        ANSWER_N

 1     All         AGE         91    51.164835165    9.0740946733              52              26              71              91
 2     All         HGT         91    137.14021978    31.816178344          130.68           73.44           224.1              91
 3     All         WGT         91    76.189010989    17.675654635            72.6            40.8           124.5              91

 4     Aspirin     AGE         45    51.733333333    8.5610109853              53              31              68              45
 5     Aspirin     HGT         45         133.056    27.306971338          129.78            88.2           224.1              45
 6     Aspirin     WGT         45           73.92    15.170539632            72.1              49           124.5              45

 7     Placebo     AGE         46    50.608695652    9.6112856369              50              26              71              46
 8     Placebo     HGT         46    141.13565217    35.530819151          136.08           73.44          215.64              46
 9     Placebo     WGT         46    78.408695652    19.739343973            75.6            40.8           119.8              46
*/

* normalize;
data nrmunv;
 keep trt grp question answer;
 length question answer $96;
 do until (dne);
   set demunv end=dne;
   format _all_;
   grp=question;
   fmt=strip(question)!!'_n';
   question=putn(1,fmt);
   answer=put(answer_n,5.);
   output;
   question=putn(2,fmt);
   answer=cats(put(answer_mean,??5.),'(',put(answer_stddev,??5.1),')');
   output;
   question=putn(3,fmt);
   answer=strip(put(answer_min,5.))!!', '!!strip(put(answer_max,5.));
   output;
 end;
 do until (dn1);
   set cntpct end=dn1;
   format _all_;
   output;
 end;
 stop;
run;

/*
Obs    QUESTION                                                                                     ANSWER       TRT        GRP

  1    AGE @Page @02 @Order @010 @Age    @\li360 N        @N                                           91        All        AGE
  2    AGE @Page @02 @Order @020 @Age    @\li360 Mean(SD) @MEAN STD                                 51(9.1)      All        AGE
  3    AGE @Page @02 @Order @030 @Age    @\li360 Median   @MEDIAN                                   26, 71       All        AGE
  4    HGT @Page @02 @Order @090 @Height @\li360 N        @N                                           91        All        HGT
  5    HGT @Page @02 @Order @100 @Height @\li360 Mean(SD) @MEAN STD                                 137(31.8)    All        HGT
  6    HGT @Page @02 @Order @110 @Height @\li360 Median   @MEDIAN                                   73, 224      All        HGT
  7    WGT @Page @02 @Order @050 @Weight @\li360 N        @N                                           91        All        WGT
  8    WGT @Page @02 @Order @060 @Weight @\li360 Mean(SD) @MEAN STD                                 76(17.7)     All        WGT
  9    WGT @Page @02 @Order @070 @Weight @\li360 Median   @MEDIAN                                   41, 125      All        WGT
 28    RCD @Page @01 @Order @030 @Race - n (%) @\li360 White or Caucasian                           75(82%)      All        RCD
 29    RCD @Page @01 @Order @050 @Race - n (%) @\li360 Black or African American                    7(8%)        All        RCD
 30    RCD @Page @01 @Order @060 @Race - n (%) @\li360 Hispanic or Latino                           6(7%)        All        RCD
 31    RCD @Page @01 @Order @070 @Race - n (%) @\li360 Asian                                        2(2%)        All        RCD
 32    RCD @Page @01 @Order @080 @Race - n (%) @\li360 Japanese                                     0(0%)        All        RCD
 33    RCD @Page @01 @Order @090 @Race - n (%) @\li360 American Indian or Alaska Native             0(0%)        All        RCD
 34    RCD @Page @01 @Order @100 @Race - n (%) @\li360 Native Hawaiian or Other Pacific Islander    0(0%)        All        RCD
 38    SEX @Page @01 @Order @010 @Sex - n (%)  @\li360 Male                                         21(23%)      All        SEX
 39    SEX @Page @01 @Order @020 @Sex - n (%)  @\li360 Female                                       70(77%)      All        SEX
*/


proc sort data=nrmunv out=srt nodupkey;
  by question trt;
run;

proc transpose data=srt out=xpo(drop=_name_) ;
 by question;
 id trt;
 var answer;
run;

/*
proc print width=min;
run;quit;

Obs    QUESTION                                                                                     ALL          ASPIRIN      PLACEBO

  1    AGE @Page @02 @Order @010 @Age    @\li360 N        @N                                           91           45           46
  2    AGE @Page @02 @Order @020 @Age    @\li360 Mean(SD) @MEAN STD                                 51(9.1)      52(8.6)      51(9.6)
  3    AGE @Page @02 @Order @030 @Age    @\li360 Median   @MEDIAN                                   26, 71       31, 68       26, 71
  4    HGT @Page @02 @Order @090 @Height @\li360 N        @N                                           91           45           46
  5    HGT @Page @02 @Order @100 @Height @\li360 Mean(SD) @MEAN STD                                 137(31.8)    133(27.3)    141(35.5)
  6    HGT @Page @02 @Order @110 @Height @\li360 Median   @MEDIAN                                   73, 224      88, 224      73, 216
  7    RCD @Page @01 @Order @030 @Race - n (%) @\li360 White or Caucasian                           75(82%)      34(76%)      41(89%)
  8    RCD @Page @01 @Order @050 @Race - n (%) @\li360 Black or African American                    7(8%)        3(7%)        4(9%)
  9    RCD @Page @01 @Order @060 @Race - n (%) @\li360 Hispanic or Latino                           6(7%)        5(11%)       1(2%)
 10    RCD @Page @01 @Order @070 @Race - n (%) @\li360 Asian                                        2(2%)        2(4%)        0(0%)
 11    RCD @Page @01 @Order @080 @Race - n (%) @\li360 Japanese                                     0(0%)        0(0%)        0(0%)
 12    RCD @Page @01 @Order @090 @Race - n (%) @\li360 American Indian or Alaska Native             0(0%)        0(0%)        0(0%)
 13    RCD @Page @01 @Order @100 @Race - n (%) @\li360 Native Hawaiian or Other Pacific Islander    0(0%)        0(0%)        0(0%)
 14    RCD @Page @01 @Order @110 @Race - n (%) @\li360 Other                                        1(1%)        1(2%)        0(0%)
 15    RCX @Page @01 @Order @022 @Race - n (%) @\li360 Non-White or Caucasian                       16(18%)      11(24%)      5(11%)
 16    RCX @Page @XX @Order @0XX @Race - n (%) @\li360 White Caucasian                              75(82%)      34(76%)      41(89%)
 17    SEX @Page @01 @Order @010 @Sex - n (%)  @\li360 Male                                         21(23%)      9(20%)       12(26%)
 18    SEX @Page @01 @Order @020 @Sex - n (%)  @\li360 Female                                       70(77%)      36(80%)      34(74%)
 19    WGT @Page @02 @Order @050 @Weight @\li360 N        @N                                           91           45           46
 20    WGT @Page @02 @Order @060 @Weight @\li360 Mean(SD) @MEAN STD                                 76(17.7)     74(15.2)     78(19.7)
 21    WGT @Page @02 @Order @070 @Weight @\li360 Median   @MEDIAN                                   41, 125      49, 125      41, 120
*/

proc sql;
 create
   table prerpt as
 select
    input(scan(question,3,'@'),5.) as pge
   ,scan(question,5,'@')           as odr length=3
   ,scan(question,6,'@')           as mjr length=64
   ,scan(question,7,'@')           as mnr length=64
   ,aspirin  length=24
   ,placebo  length=24
   ,all      length=24
 from
   xpo
 where
   scan(question,5,'@') ne 'XX'
 order
   by pge, odr
;quit;

proc sql;select max(pge) into :maxpge separated by '' from prerpt;quit;

%put &=maxpge;
/* MAXPGE=2 */

/* lets get big N's */
proc sql;
  select resolve('%Let '!!trt!!'=%sysfunc(compbl('!!trt!!'#(N='!!Put(Count(answer),4.)!!');))')
  from nrm1st where question='AGE'  Group by Trt
;quit;

%put &=all;
%put &=aspirin;
%put &=placebo;

/*
ALL=All #(N= 91)
ASPIRIN=Aspirin #(N= 45)
PLACEBO=Placebo #(N= 46)
%put &=sysdate;
*/

%let ttl1=Table : Demographics;
%let TTL2=Safety Dataset;
%let TTL3=(Intent to Treat Population);
%let TTL4=Placebo-Aspirin;


%put &=ttl1;

%utl_rtflan100;

options nodate nonumber orientation=portrait;
title;footnote;
ods escapechar='^';
ods listing close;
ods rtf file="&output1" style=utl_rtflan100 notoc_data;
%macro mny(pgemax);
 %do pge=1 %to &pgemax;
  ods rtf prepage="^S={outputwidth=100% just=c font_size=11pt font_face=arial} {&ttl1}^{newline}{&ttl3}";
  proc report data=prerpt (where=(pge=&pge)) nowd split='#' missing;
     cols  mjr mnr aspirin placebo all;
      define mjr           / order    noprint order=data;
      define mnr           / display  ""         style={cellwidth=30%  just=l } order=data;
      define aspirin       / display  "&aspirin" style={cellwidth=22%  just=c } order=data;
      define placebo       / display  "&placebo" style={cellwidth=22%  just=c } order=data;
      define All           / display  "&All"     style={cellwidth=23%  just=c } order=data;
      compute before mjr / style=[just=l];
        line mjr $96.;
      endcomp;
  run;quit;
  ods rtf text="^S={outputwidth=100% just=r font_size=9pt} Page &pge of &pgemax";
  ods rtf text="^S={outputwidth=100% just=l font_size=8pt font_style=italic}  {Program: c:/utl/dm.sas_&sysdate}";
  ods rtf text="^S={outputwidth=100% just=l font_size=8pt font_style=italic}  {Log: c:/utl/dm.log_&sysdate}";
  ods rtf text="^S={outputwidth=100% just=l font_size=8pt font_style=italic}  {see Protocol 1013.6(Oncology)}";
  run;quit;
 %end;
%mend mny;
%mny(&maxpge);
ods rtf close;
ods listing;


/*

PAGE 1

                                      Table : Demographics
                                   (Intent to Treat Population)

                                               Aspirin     Placebo     All
                                               (N= 45)     (N= 46)     (N= 91)
Sex - n (%)
  Male                                         9(20%)      12(26%)     21(23%)
  Female                                       36(80%)     34(74%)     70(77%)

Race - n (%)
  Non-White or Caucasian                       11(24%)     5(11%)      16(18%)
  White or Caucasian                           34(76%)     41(89%)     75(82%)
  Black or African American                    3(7%)       4(9%)       7(8%)
  Hispanic or Latino                           5(11%)      1(2%)       6(7%)
  Asian                                        2(4%)       0(0%)       2(2%)
  Japanese                                     0(0%)       0(0%)       0(0%)
  American Indian or Alaska Native             0(0%)       0(0%)       0(0%)
  Native Hawaiian or Other Pacific Islander    0(0%)       0(0%)       0(0%)
  Other                                        1(2%)       0(0%)       1(1%)

                                                                     Page 1 of 2
  Program: c:/utl/dm.sas_09FEB17
  Log: c:/utl/dm.log_09FEB17
  see Protocol 1013.6(Oncology)


PAGE 2
                                      Table : Demographics
                                   (Intent to Treat Population)

                                              Aspirin     Placebo     All
                                              (N= 45)     (N= 46)     (N= 91)
Age
  N                                              45          46          91
  Mean(SD)                                    52(8.6)     51(9.6)     51(9.1)
  Median                                      31, 68      26, 71      26, 71

Weight
  N                                              45          46         91
  Mean(SD)                                    74(15.2)    78(19.7)   76(17.7)
  Median                                      49, 125     41, 120    41, 125

Height
  N                                              45          46         91
  Mean(SD)                                    133(27.3    141(35.5)  137(31.8)
  Median                                      88, 224     73, 216    73, 224

                                                                   Page 2 of 2
  Program: c:/utl/dm.sas_09FEB17
  Log: c:/utl/dm.log_09FEB17
  see Protocol 1013.6(Oncology)




