

/* DIRECTORIES */
libname interim	'F:/Users/0747394/phd-2-fluoroquinolones/2_interim_data/';
libname clean 	'F:/Users/0747394/phd-2-fluoroquinolones/3_clean_data/';


data rx_indexed;
	set interim.rx_indexed_pg30(keep = patid eventdate atc_code tx_episode rx_type);
	eventdate = intnx('month', eventdate, '0', 'b');
run;


data tx_indications;
	set interim.tx_indications;
run;


proc sql;
	create table ts_dx as
	select *
	from rx_indexed as a
	left join tx_indications as b
	on a.tx_episode = b.tx_episode;
quit;


data ts_dx;
	set ts_dx;
	if concept = "" then concept = "Unknown";
run;


proc sql;
	create table ts_dx1 as
	select eventdate, atc_code, rx_type, concept as dx_group, count(*) as n
	from ts_dx
	group by eventdate, atc_code, rx_type, concept;
quit;


data clean.ts_dx;
	set ts_dx1;
run;
