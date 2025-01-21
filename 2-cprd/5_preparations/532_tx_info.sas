

/* DIRECTORIES */
libname interim 	'F:/Users/0747394/phd-2-fluoroquinolones/2_interim_data/';

/* CONSTANTS */ 
%let permissible_gap = 30;
%let study_start = '01JAN2014'd;
%let study_end = '31DEC2023'd;
%let study_lookback = 365;


data rx30;
	set interim.rx_indexed_pg30;
run;

/* TX INFO tables */

proc sql;
	create table tx_info as
	select 	patid, 
			tx_episode,
			min(eventdate) as start,
			max(rx_end) as end,
			count(*) as n_rx, 
			count(distinct(atc_code)) as n_atc 	
	from rx30
	group by tx_episode;
quit;

proc sort data = tx_info nodupkey out= tx_info1;
	by tx_episode;
run;

data rx_incident;
	set rx30;
	if rx_type = "incident";
run;

/* saving files */

data interim.tx_info_pg30;
	set tx_info1;
run;

data interim.tx_incident_pg30;
	set rx_incident(keep = tx_episode atc_code);
run;
