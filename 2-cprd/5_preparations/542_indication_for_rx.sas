

/* DIRECTORIES */
libname interim 	'F:/Users/0747394/phd-2-fluoroquinolones/2_interim_data/';

/* CONSTANTS */ 
%let permissible_gap = 30;
%let study_start = '01JAN2014'd;
%let study_end = '31DEC2023'd;
%let study_lookback = 365;


data tx_info(drop = patida);
	set interim.tx_info_pg30(keep = tx_episode start);
	patida = scan(tx_episode, 1, '-');
	patid = input(patida, 12.);
	format patid 12.;
	informat patid 12.;
run;

data dx;
	set interim.dx_clean;
	format patid;
	informat patid ;
run;

proc sql;
	create table step0 as
	select *
	from tx_info as a
	inner join dx as b
	on a.patid = b.patid;
quit;

proc sql;
	create table step1 as
	select * 
	from step0
	where start = eventdate;
quit;

proc sql;
	create table step2 as
	select *, max(eventdate) as max
	from (select * from step0 where tx_episode not in (select tx_episode from step1))
	where 	eventdate < start and 
			eventdate > start - 8
	group by tx_episode;
quit;

data step2a;
	set step2;
	format max ddmmyy10.;
	if eventdate = max;
run;

proc sql;
	create table step3 as
	select *, min(eventdate) as min
	from (select * from step0 where tx_episode not in (select tx_episode from step1) and tx_episode not in (select tx_episode from step2a))
	where 	eventdate > start and eventdate < start + 8
	group by tx_episode;
quit;

data step3a;
	set step3;
	format min ddmmyy10.;
	if eventdate = min;
run;

data tx_indications (keep = tx_episode concept);
	set step1
		step2a
		step3a;
run;

proc sql;
	select distinct concept, count(*)
	from tx_indications
	group by concept;
quit;


/* saving files */

data interim.tx_indications;
	set tx_indications;
run;
