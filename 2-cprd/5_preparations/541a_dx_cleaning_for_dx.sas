

/* DIRECTORIES */
libname raw		 'F:/Users/0747394/phd-2-fluoroquinolones/1_raw_data/mar2024';
libname interim 	'F:/Users/0747394/phd-2-fluoroquinolones/2_interim_data/';

/* CONSTANTS */ 
%let permissible_gap = 30;
%let study_start = '01JAN2014'd;
%let study_end = '31DEC2023'd;
%let study_lookback = 365;

data ids;
	set interim.index_dates_pg7(keep = patid index_date);
run;


data dx;
	set raw.dx_main_indicationsevents1
		raw.dx_main_indicationsevents2
		raw.dx_main_indicationsevents3
		raw.dx_main_indicationsevents4
		raw.dx_main_indicationsevents5
		raw.dx_main_indicationsevents6
		raw.dx_main_indicationsevents7
		raw.dx_main_indicationsevents8
		raw.dx_main_indicationsevents9
		raw.dx_main_indicationsevents10
		raw.dx_main_indicationsevents11
		raw.dx_main_indicationsevents12
		raw.dx_main_indicationsevents13
		raw.dx_main_indicationsevents14
		raw.dx_main_indicationsevents15
		raw.dx_main_indicationsevents16
		raw.dx_main_indicationsevents17
		raw.dx_main_indicationsevents18
		raw.dx_main_indicationsevents19
		raw.dx_main_indicationsevents20;
	format patid best12.;
	informat patid best32.;
run;

proc contents data=ids;
proc contents data=dx;
run;


data dx;
	set dx;
	where eventdate >= &study_start - 30;
run;

proc import out = concepts
	datafile = 'F:/Users/0747394/phd-2-fluoroquinolones/1_raw_data/dx codes/dx_concepts1.csv'
	dbms = csv
	replace;
	delimiter = ",";
	guessingrows = 32767;
	getnames = YES;
run;

data concepts;
	set concepts;
	medcode1 = input(medcode, 8.);
	rename medcode = old;
	rename medcode1 = medcode;
	rename readcode = read_term;
run;

proc sql;
	create table dxs as
	select * 
	from dx
	left join concepts
	on dx.medcode = concepts.medcode;
quit;

data dxs1;
	set dxs;
	if concept ne "";
run;

proc sql;
	create table temp1 as
	select distinct(concept)
	from dxs1
	group by concept;
run;

proc sql;
	create table dxs as 
	select *
	from dxs1
	where patid in (select patid from ids);
quit;


/* saving files */

data interim.dx_clean;
	set dxs(keep = patid eventdate concept);
run;
