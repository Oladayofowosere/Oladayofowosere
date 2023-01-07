/* ----------------------------------------
Code exported from SAS Enterprise Guide
DATE: Sunday, 9 January 2022     TIME: 1:45:08 am
PROJECT: Project
PROJECT PATH: C:\Users\Gratiam Suam\Desktop\Project.egp
---------------------------------------- */

/* ---------------------------------- */
/* MACRO: enterpriseguide             */
/* PURPOSE: define a macro variable   */
/*   that contains the file system    */
/*   path of the WORK library on the  */
/*   server.  Note that different     */
/*   logic is needed depending on the */
/*   server type.                     */
/* ---------------------------------- */
%macro enterpriseguide;
%global sasworklocation;
%local tempdsn unique_dsn path;

%if &sysscp=OS %then %do; /* MVS Server */
	%if %sysfunc(getoption(filesystem))=MVS %then %do;
        /* By default, physical file name will be considered a classic MVS data set. */
	    /* Construct dsn that will be unique for each concurrent session under a particular account: */
		filename egtemp '&egtemp' disp=(new,delete); /* create a temporary data set */
 		%let tempdsn=%sysfunc(pathname(egtemp)); /* get dsn */
		filename egtemp clear; /* get rid of data set - we only wanted its name */
		%let unique_dsn=".EGTEMP.%substr(&tempdsn, 1, 16).PDSE"; 
		filename egtmpdir &unique_dsn
			disp=(new,delete,delete) space=(cyl,(5,5,50))
			dsorg=po dsntype=library recfm=vb
			lrecl=8000 blksize=8004 ;
		options fileext=ignore ;
	%end; 
 	%else %do; 
        /* 
		By default, physical file name will be considered an HFS 
		(hierarchical file system) file. 
		*/
		%if "%sysfunc(getoption(filetempdir))"="" %then %do;
			filename egtmpdir '/tmp';
		%end;
		%else %do;
			filename egtmpdir "%sysfunc(getoption(filetempdir))";
		%end;
	%end; 
	%let path=%sysfunc(pathname(egtmpdir));
    %let sasworklocation=%sysfunc(quote(&path));  
%end; /* MVS Server */
%else %do;
	%let sasworklocation = "%sysfunc(getoption(work))/";
%end;
%if &sysscp=VMS_AXP %then %do; /* Alpha VMS server */
	%let sasworklocation = "%sysfunc(getoption(work))";                         
%end;
%if &sysscp=CMS %then %do; 
	%let path = %sysfunc(getoption(work));                         
	%let sasworklocation = "%substr(&path, %index(&path,%str( )))";
%end;
%mend enterpriseguide;

%enterpriseguide


/* Conditionally delete set of tables or views, if they exists          */
/* If the member does not exist, then no action is performed   */
%macro _eg_conditional_dropds /parmbuff;
	
   	%local num;
   	%local stepneeded;
   	%local stepstarted;
   	%local dsname;
	%local name;

   	%let num=1;
	/* flags to determine whether a PROC SQL step is needed */
	/* or even started yet                                  */
	%let stepneeded=0;
	%let stepstarted=0;
   	%let dsname= %qscan(&syspbuff,&num,',()');
	%do %while(&dsname ne);	
		%let name = %sysfunc(left(&dsname));
		%if %qsysfunc(exist(&name)) %then %do;
			%let stepneeded=1;
			%if (&stepstarted eq 0) %then %do;
				proc sql;
				%let stepstarted=1;

			%end;
				drop table &name;
		%end;

		%if %sysfunc(exist(&name,view)) %then %do;
			%let stepneeded=1;
			%if (&stepstarted eq 0) %then %do;
				proc sql;
				%let stepstarted=1;
			%end;
				drop view &name;
		%end;
		%let num=%eval(&num+1);
      	%let dsname=%qscan(&syspbuff,&num,',()');
	%end;
	%if &stepstarted %then %do;
		quit;
	%end;
%mend _eg_conditional_dropds;


/* save the current settings of XPIXELS and YPIXELS */
/* so that they can be restored later               */
%macro _sas_pushchartsize(new_xsize, new_ysize);
	%global _savedxpixels _savedypixels;
	options nonotes;
	proc sql noprint;
	select setting into :_savedxpixels
	from sashelp.vgopt
	where optname eq "XPIXELS";
	select setting into :_savedypixels
	from sashelp.vgopt
	where optname eq "YPIXELS";
	quit;
	options notes;
	GOPTIONS XPIXELS=&new_xsize YPIXELS=&new_ysize;
%mend _sas_pushchartsize;

/* restore the previous values for XPIXELS and YPIXELS */
%macro _sas_popchartsize;
	%if %symexist(_savedxpixels) %then %do;
		GOPTIONS XPIXELS=&_savedxpixels YPIXELS=&_savedypixels;
		%symdel _savedxpixels / nowarn;
		%symdel _savedypixels / nowarn;
	%end;
%mend _sas_popchartsize;


ODS PROCTITLE;
OPTIONS DEV=PNG;
GOPTIONS XPIXELS=0 YPIXELS=0;
FILENAME EGSRX TEMP;
ODS tagsets.sasreport13(ID=EGSRX) FILE=EGSRX
    STYLE=HtmlBlue
    STYLESHEET=(URL="file:///C:/Program%20Files%20(x86)/SASHome/x86/SASEnterpriseGuide/7.1/Styles/HtmlBlue.css")
    NOGTITLE
    NOGFOOTNOTE
    GPATH=&sasworklocation
    ENCODING=UTF8
    options(rolap="on")
;

/*   START OF NODE: Code For Linear Regression   */
%LET _CLIENTTASKLABEL='Code For Linear Regression';
%LET _CLIENTPROCESSFLOWNAME='Process Flow';
%LET _CLIENTPROJECTPATH='C:\Users\Gratiam Suam\Desktop\Project.egp';
%LET _CLIENTPROJECTPATHHOST='DESKTOP-79PUDA0';
%LET _CLIENTPROJECTNAME='Project.egp';
%LET _SASPROGRAMFILE='';
%LET _SASPROGRAMFILEHOST='';

GOPTIONS ACCESSIBLE;

/* -------------------------------------------------------------------
   Code generated by SAS Task

   Generated on: Friday, January 7, 2022 at 3:23:54 AM
   By task: Linear Regression

   Input Data: Local:WORK.DAYO_PODS_0002
   Server:  Local
   ------------------------------------------------------------------- */
ODS GRAPHICS ON;

%_eg_conditional_dropds(WORK.SORTTempTableSorted,
		WORK.TMP1TempTableForPlots);
/* -------------------------------------------------------------------
   Determine the data set's type attribute (if one is defined)
   and prepare it for addition to the data set/view which is
   generated in the following step.
   ------------------------------------------------------------------- */
DATA _NULL_;
	dsid = OPEN("WORK.DAYO_PODS_0002", "I");
	dstype = ATTRC(DSID, "TYPE");
	IF TRIM(dstype) = " " THEN
		DO;
		CALL SYMPUT("_EG_DSTYPE_", "");
		CALL SYMPUT("_DSTYPE_VARS_", "");
		END;
	ELSE
		DO;
		CALL SYMPUT("_EG_DSTYPE_", "(TYPE=""" || TRIM(dstype) || """)");
		IF VARNUM(dsid, "_NAME_") NE 0 AND VARNUM(dsid, "_TYPE_") NE 0 THEN
			CALL SYMPUT("_DSTYPE_VARS_", "_TYPE_ _NAME_");
		ELSE IF VARNUM(dsid, "_TYPE_") NE 0 THEN
			CALL SYMPUT("_DSTYPE_VARS_", "_TYPE_");
		ELSE IF VARNUM(dsid, "_NAME_") NE 0 THEN
			CALL SYMPUT("_DSTYPE_VARS_", "_NAME_");
		ELSE
			CALL SYMPUT("_DSTYPE_VARS_", "");
		END;
	rc = CLOSE(dsid);
	STOP;
RUN;

/* -------------------------------------------------------------------
   Sort data set WORK.DAYO_PODS_0002
   ------------------------------------------------------------------- */
PROC SORT
	DATA=WORK.DAYO_PODS_0002(KEEP="GDP growth (annual %)"n "Access to electricity (% of popu"n 
"Inflation, consumer prices (annu"n "Population growth (annual %)"n "Food exports (% of merchandise e"n
	  "Food imports (% of merchandise i"n "Population, total"n "Fuel imports (% of merchandise 
i"n "Fuel exports (% of merchandise e"n "Electric power consumption (kWh"n "Electricity production from oil,"n
	  "Electricity production from oil"n Continent &_DSTYPE_VARS_)
	OUT=WORK.SORTTempTableSorted &_EG_DSTYPE_
	;
	BY Continent;
RUN;
TITLE;
TITLE1 "Linear Regression Results";
FOOTNOTE;
FOOTNOTE1 "Generated by the SAS System (&_SASSERVERNAME, &SYSSCPL) 
on %TRIM(%QSYSFUNC(DATE(), NLDATE20.)) at %TRIM(%SYSFUNC(TIME(), TIMEAMPM12.))";
PROC REG DATA=WORK.SORTTempTableSorted
		PLOTS(ONLY)=ALL
	;
	BY Continent;
	Linear_Regression_Model: MODEL "GDP growth (annual %)"n = "Access to electricity 
(% of popu"n "Inflation, consumer prices (annu"n "Population growth (annual %)
"n "Food exports (% of merchandise e"n "Food imports (% of merchandise i"n "Population, 
total"n "Fuel imports (% of merchandise i"n "Fuel exports (% of merchandise e"n "
Electric power consumption (kWh"n "Electricity production from oil,"n "Electricity 
production from oil"n
		/		SELECTION=NONE
	;
RUN;
QUIT;

/* -------------------------------------------------------------------
   End of task code
   ------------------------------------------------------------------- */
RUN; QUIT;
%_eg_conditional_dropds(WORK.SORTTempTableSorted,
		WORK.TMP1TempTableForPlots);
TITLE; FOOTNOTE;
ODS GRAPHICS OFF;




GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;
%LET _SASPROGRAMFILEHOST=;

;*';*";*/;quit;run;
ODS _ALL_ CLOSE;
