

/* DIRECTORIES */
libname interim 	'F:/Users/0747394/phd-2-fluoroquinolones/2_interim_data/';

/* CONSTANTS */ 
%let permissible_gap = 30;
%let study_start = '01JAN2014'd;
%let study_end = '31DEC2023'd;
%let study_lookback = 365;


data tx_info(drop = patida);
	set interim.tx_info_pg30(keep = tx_episode start end);
	patida = scan(tx_episode, 1, '-');
	patid = input(patida, 12.);
	format patid 12.;
	informat patid 12.;
run;

data rf;
	set interim.rf_dates;
	format patid 12.;
	informat patid 12.;
run;

proc sql;
	create table step0 as
	select *
	from tx_info as a
	inner join rf as b
	on a.patid = b.patid;
quit;

proc sql;
	create table rf1 as
	select tx_episode, concept, rf_subgroup 
	from step0
	where eventdate <= start;
quit;

data rfc10;
	set interim.rf_c10;
	format patid 12.;
	informat patid 12.;
run;

proc sql;
	create table step1 as
	select *
	from tx_info as a
	inner join rfc10 as b
	on a.patid = b.patid;
quit;


proc sql;
	create table rf2 as
	select * 
	from step1
	where eventdate <= start;
quit;

data rf2;
	set rf2;
	concept = "prior lipid lowering medication use";
	rf_subgroup = "aortic";
run;


data rfh02;
	set interim.rf_h02;
	format patid 12.;
	informat patid 12.;
run;

proc sql;
	create table step2 as
	select *
	from tx_info as a
	inner join rfh02 as b
	on a.patid = b.patid;
quit;


proc sql;
	create table rf3 as
	select * 
	from step2
	where hstart <= start and hend >= start;
quit;

data rf3;
	set rf3;
	concept = "concomitant glucocorticoid use";
	rf_subgroup = "tendon";
run;


data rf_123(keep = tx_episode concept rf_subgroup);
	set rf1
		rf2
		rf3;
run;

proc sql;
	create table rf4 as
	select tx_episode
	from tx_info
	where tx_episode not in (select tx_episode from rf_123);
quit;

data rf4;
	set rf4;
	concept = "none";
	rf_subgroup = "none";
run;

data tx_risk_factors;
	set rf_123
		rf4;
run;

proc sort data = tx_risk_factors out = tx_risk_factors;
	by tx_episode concept rf_subgroup;
run;


/* rf at tx start */

data interim.tx_risk_factors;
	set tx_risk_factors;
run;
	



proc sql;
	select distinct concept, rf_subgroup
	from tx_risk_factors
	group by concept;
quit;

data rf_at_index;
	set tx_risk_factors;
	first  = scan(tx_episode, 2, "-");
	if first = "1";
run;

proc sql;
	select count(distinct tx_episode)
	from rf_at_index;
quit;


/* rf at index */

data interim.rf_at_index;
	set rf_at_index(drop = first);
	rename tx_episode = patid;
run;
