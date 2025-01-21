

/* DIRECTORIES */
libname interim	'F:/Users/0747394/phd-2-fluoroquinolones/2_interim_data/';
libname clean 	'F:/Users/0747394/phd-2-fluoroquinolones/3_clean_data/';


data rx_indexed;
	set interim.rx_indexed_pg30(keep = patid eventdate atc_code tx_episode rx_type);
run;

proc sql;
	create table fq_episodes as
	select distinct tx_episode, atc_code
	from rx_indexed
	where atc_code like 'J01MA%';
run;


data clean.fq_episodes;
	set fq_episodes(drop = atc_code);
run;

data demographics;
	set interim.demographics(keep = patid gender yob);
run;

proc sql;
	create table rx_demographics as
	select *
	from rx_indexed as x
	left join demographics as y
	on x.patid = y.patid;
quit;

data rx_demographics1(drop = yob);
	set rx_demographics;
	age = year(eventdate) - yob;
	eventdate = intnx('month', eventdate, '0', 'b');
run;

proc sql;
	create table ts_sex as
	select eventdate, atc_code, rx_type, gender, count(*) as n
	from rx_demographics1
	group by eventdate, atc_code, rx_type, gender;
quit;

proc sql;
	create table ts_age as
	select eventdate, atc_code, rx_type, age, count(*) as n
	from rx_demographics1
	group by eventdate, atc_code, rx_type, age;
quit;

data clean.ts_age;
	set ts_age;
run;

data clean.ts_sex;
	set ts_sex;
run;



/* different pg */

data rx_indexed30;
	set interim.rx_indexed_pg30(keep = eventdate atc_code tx_episode rx_type);
	eventdate = intnx('month', eventdate, '0', 'b');
run;

proc sql;
	create table ts30 as
	select eventdate, atc_code, rx_type, count(*) as n
	from rx_indexed30
	group by eventdate, atc_code, rx_type;
quit;

data rx_indexed14;
	set interim.rx_indexed_pg14(keep =eventdate atc_code tx_episode rx_type);
	eventdate = intnx('month', eventdate, '0', 'b');
run;

proc sql;
	create table ts14 as
	select eventdate, atc_code, rx_type, count(*) as n
	from rx_indexed14
	group by eventdate, atc_code, rx_type;
quit;

data rx_indexed10;
	set interim.rx_indexed_pg10(keep =eventdate atc_code tx_episode rx_type);
	eventdate = intnx('month', eventdate, '0', 'b');
run;

proc sql;
	create table ts10 as
	select eventdate, atc_code, rx_type, count(*) as n
	from rx_indexed10
	group by eventdate, atc_code, rx_type;
quit;

data rx_indexed7;
	set interim.rx_indexed_pg7(keep =eventdate atc_code tx_episode rx_type);
	eventdate = intnx('month', eventdate, '0', 'b');
run;

proc sql;
	create table ts7 as
	select eventdate, atc_code, rx_type, count(*) as n
	from rx_indexed7
	group by eventdate, atc_code, rx_type;
quit;

data ts30;
	set ts30;
	permissible_gap = 30;
run;
data ts14;
	set ts14;
	permissible_gap = 14;
run;
data ts10;
	set ts10;
	permissible_gap = 10;
run;
data ts7;
	set ts7;
	permissible_gap = 7;
run;

data ts_main;
	set ts30
		ts14
		ts10
		ts7;
run;

proc sort data = ts_main;
	by eventdate atc_code rx_type permissible_gap;
run;


data clean.ts_main;
	set ts_main;
run;

