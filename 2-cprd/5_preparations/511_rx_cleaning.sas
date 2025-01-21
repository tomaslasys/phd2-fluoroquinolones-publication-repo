

/* DIRECTORIES */
libname raw		'F:/Users/0747394/phd-2-fluoroquinolones/1_raw_data/mar2024';
libname interim	'F:/Users/0747394/phd-2-fluoroquinolones/2_interim_data/';

/* CONSTANTS */ 
%let permissible_gap = 30;
%let study_start = '01JAN2014'd;
%let study_end = '31OCT2023'd;
%let study_lookback = 365;

data rx01;
	set raw.j01_file1
		raw.j01_file2
		raw.j01_file3
		raw.j01_file4
		raw.j01_file5
		raw.j01_file6
		raw.j01_file7
		raw.j01_file8
		raw.j01_file9
		raw.j01_file10
		raw.j01_file11
		raw.j01_file12
		raw.j01_file13
		raw.j01_file14
		raw.j01_file15
		raw.j01_file16
		raw.j01_file17
		raw.j01_file18
		raw.j01_file19
		raw.j01_file20*/;
	format patid best12.;
	informat patid best32.;
	where eventdate >= &study_start - 366 and eventdate <= &study_end;
run;


data rx01;
	set rx01(keep = patid eventdate prodcode qty numdays);
run;

proc sort data = rx01 out=rx01 nodupkey;
	by patid eventdate prodcode;
run;


proc import out = atc_key
	datafile= 'F:/Users/0747394/phd-2-fluoroquinolones/1_raw_data/codes/main_exposure.csv'
	dbms=csv
	replace;
	delimiter=";";
	guessingrows = 32767;
	getnames = YES;
run;


data atc_key;
	set atc_key (keep=prodcode atc_code);
run;


proc import out = prodcode_ddd
	datafile= 'F:/Users/0747394/phd-2-fluoroquinolones/0_lookup/prodcode_ddd.csv'
	dbms=csv
	replace;
	delimiter=";";
	guessingrows = 32767;
	getnames = YES;
run;


proc import out = atc_names
	datafile= 'F:/Users/0747394/phd-2-fluoroquinolones/1_raw_data/atc_index.csv'
	dbms=dlm
	replace;
	delimiter=' ';
	guessingrows = 32767;
	getnames = YES;
run;

proc sql;
	create table atc_full as
	select a.*, b.*
	from atc_key as a
	left join atc_names as b
	on a.atc_code = b.atc_code;
quit;


/* add atc_codes to rx file */
proc sql;
	create table rx02 as
	select a.*, b.*
	from rx01 as a
	left join atc_full as b
	on a.prodcode = b.prodcode;
quit;

proc sql;
	create table rx03 as
	select a.*, b.*
	from rx02 as a
	left join prodcode_ddd as b
	on a.prodcode = b.prodcode;
quit;

data rx04(keep = patid eventdate atc_code numdays rx_end);
	set rx03;
	if qty = 0 then qty = 1;
	if numdays = 0 then numdays= ceil(qty*ddd_per_dose);
	if numdays = 0 then numdays = 1;
	rx_end = eventdate + numdays;
	format rx_end ddmmyy10.;
run;

proc sort data = rx04 out=rx05 nodupkey;
	by patid eventdate atc_code;
run;


data interim.therapy;
	set rx05;
run;
