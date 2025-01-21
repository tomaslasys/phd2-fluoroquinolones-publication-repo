

/* DIRECTORIES */
libname interim	'F:/Users/0747394/phd-2-fluoroquinolones/2_interim_data/';
libname clean 	'F:/Users/0747394/phd-2-fluoroquinolones/3_clean_data/';


data rx_indexed;
	set interim.rx_indexed_pg30(keep = patid eventdate atc_code tx_episode rx_type);
	eventdate = intnx('month', eventdate, '0', 'b');
run;


data tx_risk_factors;
	set interim.tx_risk_factors;
run;


proc sql;
	create table ts_rf as
	select *
	from rx_indexed as a
	left join tx_risk_factors as b
	on a.tx_episode = b.tx_episode;
quit;


data ts_rf;
	set ts_rf;
run;


proc sql;
	create table ts_rf1 as
	select eventdate, atc_code, rx_type, rf_subgroup, count(*) as n
	from ts_rf
	group by eventdate, atc_code, rx_type, rf_subgroup;
quit;



data clean.ts_rf;
	set ts_rf1;
run;
