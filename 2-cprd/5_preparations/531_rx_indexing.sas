

/* DIRECTORIES */
libname interim 	'F:/Users/0747394/phd-2-fluoroquinolones/2_interim_data/';

/* PERMISSIBLE GAP = 30 (2)  */ 

%let permissible_gap = 30;

data rx_selected;
	set interim.rx_selected;
run;

proc sort data = rx_selected;
	by patid eventdate;
run;

data tx_ids;
	set rx_selected;
	if lag_rx > &permissible_gap or lag_rx = '.';
run; 

/* tx episode start days */
proc sort data = tx_ids;
	by patid eventdate;
run;
data tx_ids;
	set tx_ids;
	by patid;
	retain tx_id;
	if first.patid then tx_id = 1;
	else tx_id + (eventdate ne lag(eventdate));
	tx_episode = catx("-", patid, tx_id);
	start = eventdate;
	format start ddmmyy10.;
	keep patid start tx_episode;
run;

/* tx episode end days*/
proc sort data = tx_ids;
	by patid descending start;
run;
data tx_ids;
	set tx_ids;
	by patid;
	end = lag(start);
	format end ddmmyy10.;
	if first.patid then end = '01JAN2024'd;
run;

proc sort data = tx_ids;
	by patid start;
run;

/* indexing all prescriptions */
proc sql;
	create table rx_indexed as
	select *
	from rx_selected as a
	full join tx_ids as b
	on a.patid = b.patid
	where eventdate >= start and eventdate < end
	order by patid asc, tx_episode asc, eventdate asc, lag_rx desc;
quit;

data rx_indexed;
	set rx_indexed(keep = patid eventdate atc_code rx_end lag_rx lag_atc tx_episode);
run;


data rx_indexed;
	set rx_indexed;
	lag_date = lag(eventdate);
	format lag_date ddmmyy10.;
run;


data rx_indexed(drop = lag_date);
	set rx_indexed;
	by patid tx_episode;
	retain atc_order;
	if first.tx_episode then atc_order = 1;
	else if eventdate ne lag_date then atc_order + 1;
	else atc_order + 0;
run;

data rx_indexed;
	set rx_indexed;
	length rx_type $10;
	if atc_order = 1 then rx_type = 'incident';
	else if lag_atc > &permissible_gap or lag_atc = . then rx_type = 'add-on';
	else rx_type = 'continued';
run;

/* saving indexed data */
data interim.rx_indexed_pg30;
	set rx_indexed;
run;



/* PERMISSIBLE GAP = 14 (2)  */

%let permissible_gap = 14;

data tx_ids;
	set rx_selected;
	if lag_rx > &permissible_gap or lag_rx = '.';
run; 

/* tx episode start days */
proc sort data = tx_ids;
	by patid eventdate;
run;
data tx_ids;
	set tx_ids;
	by patid;
	retain tx_id;
	if first.patid then tx_id = 1;
	else tx_id + (eventdate ne lag(eventdate));
	tx_episode = catx("-", patid, tx_id);
	start = eventdate;
	format start ddmmyy10.;
	keep patid start tx_episode;
run;

/* tx episode end days*/
proc sort data = tx_ids;
	by patid descending start;
run;
data tx_ids;
	set tx_ids;
	by patid;
	end = lag(start);
	format end ddmmyy10.;
	if first.patid then end = '01JAN2024'd;
run;

proc sort data = tx_ids;
	by patid start;
run;

/* indexing all prescriptions */
proc sql;
	create table rx_indexed as
	select *
	from rx_selected as a
	full join tx_ids as b
	on a.patid = b.patid
	where eventdate >= start and eventdate < end
	order by patid asc, tx_episode asc, eventdate asc, lag_rx desc;
quit;

data rx_indexed;
	set rx_indexed(keep = patid eventdate atc_code rx_end lag_rx lag_atc tx_episode);
run;

data rx_indexed;
	set rx_indexed;
	lag_date = lag(eventdate);
	format lag_date ddmmyy10.;
run;

data rx_indexed(drop = lag_date);
	set rx_indexed;
	by patid tx_episode;
	retain atc_order;
	if first.tx_episode then atc_order = 1;
	else if eventdate ne lag_date then atc_order + 1;
	else atc_order + 0;
run;

data rx_indexed;
	set rx_indexed;
	length rx_type $10;
	if atc_order = 1 then rx_type = 'incident';
	else if lag_atc > &permissible_gap or lag_atc = . then rx_type = 'add-on';
	else rx_type = 'continued';
run;

/* saving indexed data */
data interim.rx_indexed_pg14;
	set rx_indexed;
run;



/* PERMISSIBLE GAP = 10 (3)   */

%let permissible_gap = 10;

data tx_ids;
	set rx_selected;
	if lag_rx > &permissible_gap or lag_rx = '.';
run; 

/* tx episode start days */
proc sort data = tx_ids;
	by patid eventdate;
run;
data tx_ids;
	set tx_ids;
	by patid;
	retain tx_id;
	if first.patid then tx_id = 1;
	else tx_id + (eventdate ne lag(eventdate));
	tx_episode = catx("-", patid, tx_id);
	start = eventdate;
	format start ddmmyy10.;
	keep patid start tx_episode;
run;

/* tx episode end days*/
proc sort data = tx_ids;
	by patid descending start;
run;
data tx_ids;
	set tx_ids;
	by patid;
	end = lag(start);
	format end ddmmyy10.;
	if first.patid then end = '01JAN2024'd;
run;

proc sort data = tx_ids;
	by patid start;
run;

/* indexing all prescriptions */
proc sql;
	create table rx_indexed as
	select *
	from rx_selected as a
	full join tx_ids as b
	on a.patid = b.patid
	where eventdate >= start and eventdate < end
	order by patid asc, tx_episode asc, eventdate asc, lag_rx desc;
quit;

data rx_indexed;
	set rx_indexed(keep = patid eventdate atc_code rx_end lag_rx lag_atc tx_episode);
run;


data rx_indexed;
	set rx_indexed;
	lag_date = lag(eventdate);
	format lag_date ddmmyy10.;
run;

data rx_indexed(drop = lag_date);
	set rx_indexed;
	by patid tx_episode;
	retain atc_order;
	if first.tx_episode then atc_order = 1;
	else if eventdate ne lag_date then atc_order + 1;
	else atc_order + 0;
run;

data rx_indexed;
	set rx_indexed;
	length rx_type $10;
	if atc_order = 1 then rx_type = 'incident';
	else if lag_atc > &permissible_gap or lag_atc = . then rx_type = 'add-on';
	else rx_type = 'continued';
run;

/* saving indexed data */
data interim.rx_indexed_pg10;
	set rx_indexed;
run;


/* PERMISSIBLE GAP = 7 (4)   */

%let permissible_gap = 7;

data tx_ids;
	set rx_selected;
	if lag_rx > &permissible_gap or lag_rx = '.';
run; 

/* tx episode start days */
proc sort data = tx_ids;
	by patid eventdate;
run;
data tx_ids;
	set tx_ids;
	by patid;
	retain tx_id;
	if first.patid then tx_id = 1;
	else tx_id + (eventdate ne lag(eventdate));
	tx_episode = catx("-", patid, tx_id);
	start = eventdate;
	format start ddmmyy10.;
	keep patid start tx_episode;
run;

/* tx episode end days*/
proc sort data = tx_ids;
	by patid descending start;
run;
data tx_ids;
	set tx_ids;
	by patid;
	end = lag(start);
	format end ddmmyy10.;
	if first.patid then end = '01JAN2024'd;
run;

proc sort data = tx_ids;
	by patid start;
run;

/* indexing all prescriptions */
proc sql;
	create table rx_indexed as
	select *
	from rx_selected as a
	full join tx_ids as b
	on a.patid = b.patid
	where eventdate >= start and eventdate < end
	order by patid asc, tx_episode asc, eventdate asc, lag_rx desc;
quit;

data rx_indexed;
	set rx_indexed(keep = patid eventdate atc_code rx_end lag_rx lag_atc tx_episode);
run;

data rx_indexed;
	set rx_indexed;
	lag_date = lag(eventdate);
	format lag_date ddmmyy10.;
run;

data rx_indexed(drop = lag_date);
	set rx_indexed;
	by patid tx_episode;
	retain atc_order;
	if first.tx_episode then atc_order = 1;
	else if eventdate ne lag_date then atc_order + 1;
	else atc_order + 0;
run;

data rx_indexed;
	set rx_indexed;
	length rx_type $10;
	if atc_order = 1 then rx_type = 'incident';
	else if lag_atc > &permissible_gap or lag_atc = . then rx_type = 'add-on';
	else rx_type = 'continued';
run;

/* saving indexed data */
data interim.rx_indexed_pg7;
	set rx_indexed;
run;
