

/* DIRECTORIES */
libname raw 	"F:/Users/0747394/phd-2-fluoroquinolones/1_raw_data/dec2023/";
/*libname raw1 	"F:/Users/0747394/phd-2-fluoroquinolones/1_raw_data/Raw/Define_txt/";
libname updated "F:/Users/0747394/phd-2-fluoroquinolones/Updated extraction";
libname codes 	"F:/Users/0747394/phd-2-fluoroquinolones/1_raw_data/codes/";*/
libname interim 	"F:/Users/0747394/phd-2-fluoroquinolones/2_interim_data/";

/* CONSTANTS */ 
%let permissible_gap = 30;
%let study_start = "01JAN2014"d;
%let study_end = "31OCT2023"d;
%let study_lookback = 365;


data denominator;
	set raw.denominator_gold_dec2023_full;
	where exit >= &study_start and init < &study_end and init < exit;
run;

data rx;
	set interim.rx_adjusted;
run;



proc sql;
	create table demographics as
	select patid, gender, yob, init, exit
	from denominator
	where patid in (select patid from rx);
quit;

data demographics;
	set demographics;
	where gender <> 3 and yob > 1900;
run;



proc sql;
	create table flowchart1 as
	select 	count(*) as n_rx,
			count(distinct patid) as n_patid
	from rx;
quit;
data flowchart1;
	set flowchart1;
	stage = "all";
	no = 1;
run;


proc sort data = rx;
	by patid eventdate;
run;

data rx_selected1;
	set rx;
	where eventdate >= &study_start and eventdate <= &study_end;
run;


proc sql;
	create table flowchart2 as
	select 	count(*) as n_rx,
			count(distinct patid) as n_patid
	from rx_selected1;
quit;

data flowchart2;
	set flowchart2;
	stage = "in study period";
	no = 2;
run;

proc sql;
	create table flowchart as
	select * from flowchart1
	outer union corresponding
	select *
	from flowchart2;
quit;



proc sql;
	create table rx_selected2 as
	select *
	from rx_selected1
	where patid in (select patid from demographics);
quit;

proc sql;
	create table flowchart3 as
	select 	count(*) as n_rx,
			count(distinct patid) as n_patid
	from rx_selected2;
quit;
data flowchart3;
	set flowchart3;
	stage = "with demographics";
	no = 3;
run;

proc sql;
	create table flowchart as
	select * from flowchart
	outer union corresponding
	select *
	from flowchart3;
quit;


proc sql;
	create table rx_selected3 as
	select *
	from rx_selected2 as a
	left join (select patid, init, exit from demographics) as b
	on a.patid = b.patid;
quit;

data rx_selected3(drop = init exit);
	set rx_selected3;
	lookback = eventdate - init;
	where eventdate - init > &study_lookback & eventdate <= exit; 
run;

proc sql;
	create table flowchart4 as
	select 	count(*) as n_rx,
			count(distinct patid) as n_patid
	from rx_selected3;
quit;
data flowchart4;
	set flowchart4;
	stage = "with lookback";
	no = 4;
run;

proc sql;
	create table flowchart as
	select * from flowchart
	outer union corresponding
	select *
	from flowchart4;
quit;


proc sql;
	create table index_dates as 
	select patid, min(eventdate) as index_date format ddmmyy10.
	from (select * from rx_selected3 where lag_rx > 30 or lag_rx = .)
	group by patid;
quit;

proc sql;
	create table index_dates_pg7 as 
	select patid, min(eventdate) as index_date format ddmmyy10.
	from (select * from rx_selected3 where lag_rx > 7 or lag_rx = .)
	group by patid;
quit;



proc sql;
	create table rx_selected4 as
	select *
	from rx_selected3 as a
	left join index_dates as b
	on a.patid = b.patid
	where eventdate >= index_date and index_date <> .;
quit;

proc sql;
	create table flowchart5 as
	select 	count(*) as n_rx,
			count(distinct patid) as n_patid
	from rx_selected4;
quit;
data flowchart5;
	set flowchart5;
	stage = "with drug-free lookback";
	no = 5;
run;

proc sql;
	create table flowchart as
	select * from flowchart
	outer union corresponding
	select *
	from flowchart5;
quit;



proc sql;
	create table rx_selected5 as
	select *
	from rx_selected3 as a
	left join index_dates_pg7 as b
	on a.patid = b.patid
	where eventdate >= index_date and index_date <> .;
quit;


proc sql;
	create table demographics1 as
	select *
	from index_dates_pg7 as a
	left join demographics as b
	on a.patid = b.patid;
quit;

/* SAVING FILES */

data interim.flowchart;
	set flowchart;
run;

data interim.rx_selected;
	set rx_selected5;
run;

data interim.index_dates_pg7;
	set index_dates_pg7;
run;

data interim.index_dates_pg30;
	set index_dates;
run;

data interim.demographics;
	set demographics1;
run;
