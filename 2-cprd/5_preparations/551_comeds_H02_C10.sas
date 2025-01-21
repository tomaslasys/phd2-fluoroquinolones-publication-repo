

/* DIRECTORIES */
libname raw 	'F:/Users/0747394/phd-2-fluoroquinolones/1_raw_data/mar2024';
libname interim	'F:/Users/0747394/phd-2-fluoroquinolones/2_interim_data/';

/* CONSTANTS */ 
%let permissible_gap = 30;
%let study_start = '01JAN2014'd;
%let study_end = '31DEC2023'd;
%let study_lookback = 365;


proc import
	out = work.codes
    datafile = "F:/Users/0747394/phd-2-fluoroquinolones/1_raw_data/Supplement_3_concomitant_use.xlsx"
	dbms = xlsx replace;
	sheet = "CPRD";
	getnames = YES;
run;

data ids;
	set interim.index_dates_pg7(keep = patid index_date);
run;


data comed11;
	set raw.tomas_comed_file1(keep = patid eventdate prodcode qty numdays)
		raw.tomas_comed_file2(keep = patid eventdate prodcode qty numdays)
		raw.tomas_comed_file3(keep = patid eventdate prodcode qty numdays)
		raw.tomas_comed_file4(keep = patid eventdate prodcode qty numdays);
	format patid best12.;
	informat patid best32.;
run;

data comed12;
	set raw.tomas_comed_file5(keep = patid eventdate prodcode qty numdays)
		raw.tomas_comed_file6(keep = patid eventdate prodcode qty numdays)
		raw.tomas_comed_file7(keep = patid eventdate prodcode qty numdays)
		raw.tomas_comed_file8(keep = patid eventdate prodcode qty numdays);
	format patid best12.;
	informat patid best32.;
run;

data comed13;
	set raw.tomas_comed_file9(keep = patid eventdate prodcode qty numdays)
		raw.tomas_comed_file10(keep = patid eventdate prodcode qty numdays)
		raw.tomas_comed_file11(keep = patid eventdate prodcode qty numdays)
		raw.tomas_comed_file12(keep = patid eventdate prodcode qty numdays);
	format patid best12.;
	informat patid best32.;
run;

data comed14;
	set raw.tomas_comed_file13(keep = patid eventdate prodcode qty numdays)
		raw.tomas_comed_file14(keep = patid eventdate prodcode qty numdays)
		raw.tomas_comed_file15(keep = patid eventdate prodcode qty numdays)
		raw.tomas_comed_file16(keep = patid eventdate prodcode qty numdays);
	format patid best12.;
	informat patid best32.;
run;

data comed15;
	set raw.tomas_comed_file17(keep = patid eventdate prodcode qty numdays)
		raw.tomas_comed_file18(keep = patid eventdate prodcode qty numdays)
		raw.tomas_comed_file19(keep = patid eventdate prodcode qty numdays)
		raw.tomas_comed_file20(keep = patid eventdate prodcode qty numdays);
	format patid best12.;
	informat patid best32.;
run;


proc sql;
	create table comed21 as
	select * 
	from comed11 
	where patid in (select patid from ids) and prodcode in (select prodcode from codes);
quit;

proc sql;
	create table comed22 as
	select * 
	from comed12 
	where patid in (select patid from ids) and prodcode in (select prodcode from codes);
quit;

proc sql;
	create table comed23 as
	select * 
	from comed13
	where patid in (select patid from ids) and prodcode in (select prodcode from codes);
quit;

proc sql;
	create table comed24 as
	select * 
	from comed14
	where patid in (select patid from ids) and prodcode in (select prodcode from codes);
quit;

proc sql;
	create table comed25 as
	select * 
	from comed15
	where patid in (select patid from ids) and prodcode in (select prodcode from codes);
quit;



data comed;
	set comed21
		comed22
		comed23
		comed24
		comed25;
run;


proc sort data = comed out = comed1 nodup;
	by patid prodcode eventdate;
run;


data atc_codes;
	set codes(keep= prodcode atc_code);
run;


proc sql;
	create table comed2 as
	select * 
	from comed1 as a
	left join atc_codes as b
	on a.prodcode = b.prodcode;
quit;


/* C10 */

data rx_c10(keep = patid eventdate atc_code);
	set comed2;
	if substr(atc_code, 1, 3) = 'C10';
run;

proc sql;
	create table c10 as
	select *
	from rx_c10 as a
	left join ids as b
	on a.patid = b.patid;
quit;


proc sql;
	create table c10_prior as
	select *, max(eventdate) as date
	from (select * from c10 where eventdate <= index_date)
	group by patid;
run;

proc sql;
	create table c10_post as
	select *, min(eventdate) as date
	from (select * from c10 where eventdate > index_date)
	where patid not in (select patid from c10_prior)
	group by patid;
run;

data rf_c10;
	set c10_prior
		c10_post;
	format date ddmmyy10.;
	if date = eventdate;
run;

proc sort data= rf_c10 out= rf_c10 nodup;
	by patid eventdate;
run;

data interim.rf_c10;
	set rf_c10(keep = patid eventdate);
run;

/* H02 */

data h02;
	set comed2;
	if substr(atc_code, 1, 3) = 'H02';
run;

data h02a;
	set h02;
	if numdays = 0 then numdays = qty;
	if numdays > 30 then numdays = 30;
	rx_end = eventdate + numdays;
	fromat rx_end ddmmyy10.;
run;


proc sql;
	create table h02b as
	select *
	from h02a as a
	left join ids as b
	on a.patid = b.patid
	where rx_end >= index_date;
quit;

data h02c;
	set h02b(keep=patid eventdate rx_end);
	rename eventdate = hstart rx_end = hend;
run;

data interim.rf_h02;
	set h02c;
run;

