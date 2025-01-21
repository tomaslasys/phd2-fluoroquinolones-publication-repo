
options nolabel;

/* DIRECTORIES */
libname interim 'F:/Users/0747394/phd-2-fluoroquinolones/2_interim_data/';

/* CONSTANTS */ 
%let study_start = '01JAN2014'd;
%let study_end = '31OCT2023'd;


/* FILE UPLOADS */

data denominator(keep= yob gender init exit);
	set 'F:/Users/0747394/phd-2-fluoroquinolones/1_raw_data/dec2023/denominator_gold_dec2023_full.sas7bdat';
	where init <= &study_end and exit >= &study_start and init < exit ;
run;


data pt_dates(keep=date1);
	do year = 2014 to 2023;
		do month = 1 to 12;
			date1 = intnx('month', mdy(month, 1, year), 0);
			output;
		end;
	end;
	format date1 ddmmyy10.;
run;


data denominator1;
	set denominator;
	if init < &study_start then init = &study_start - 1;
	init = intnx('month', init, 0, 'b');
	exit = intnx('month', exit - 1, 0, 'e');
run;

proc sql;
	create table denominator2 as
	select gender, yob, init, exit, count(*) as n
	from denominator1
	group by gender, yob, init, exit;
quit;


proc sql;
	create table pt as
	select * 
	from pt_dates, denominator2
	where init <= date1 and date1 < exit;
quit;


proc sql;
	create table pt_monthly as
	select date1, gender, yob, sum(n) as n
	from pt
	group by date1, gender, yob;
quit;


data pt_monthly;
	set pt_monthly;
	age = year(date1) - yob;
run;


data interim.pt_counts_monthly;
	set pt_monthly;
run;
