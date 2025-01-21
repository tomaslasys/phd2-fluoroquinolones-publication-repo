
options nolabel;

/* DIRECTORIES */
libname interim	'F:/Users/0747394/phd-2-fluoroquinolones/2_interim_data/';

/* CONSTANTS */ 
%let permissible_gap = 30;
%let study_start = '01JAN2014'd;
%let study_end = '31DEC2023'd;
%let study_lookback = 365;


data rx;
	set interim.therapy(obs = 10000);
	if numdays ne . and atc_code ne '';
run;


proc sort data = rx;
	by patid eventdate;
run;

data rx;
	set rx;
	by patid;
	lag_rx = eventdate - lag(rx_end);
	if first.patid then lag_rx = 9999;
run;


proc sort data = rx;
	by patid atc_code eventdate;
run;

data rx;
	set rx;
	by patid atc_code;
	lag_atc = eventdate - lag(rx_end);
	if first.patid or first.atc_code then lag_atc = 9999;
	eventdate1 = eventdate;
	rx_end1 = rx_end;
	format eventdate1 rx_end1 ddmmyy10.;
run;


data check;
	set rx;
	if lag_atc = .;
run;


data rx1;
	set rx;
run;


proc sql;
	create table ids_with_overlaps as
	select distinct patid
	from rx1
	where lag_atc < 0;
run;


proc sql;
	create table rx_adjusted as
	select * 
	from rx1
	where patid not in (select patid from ids_with_overlaps);
run;

proc sql;
	create table rx1 as
	select * 
	from rx1
	where patid in (select patid from ids_with_overlaps);
run;


%macro adjust_dates;
    %let finished = 1;

    %do %while (&finished > 0);
        data rx1;
            set rx1;
            by patid atc_code;
            if lag_atc < 0 then eventdate1 = eventdate1 - lag_atc;
    		if lag_atc < 0 then rx_end1 = rx_end1 - lag_atc;
			lag_atc = eventdate1 - lag(rx_end1);
			if eventdate + 90 < eventdate1 then lag_atc = 0; 
			if first.patid or first.atc_code then lag_atc = 9999; 
        run;


		proc sql;
			create table ids_with_overlaps as
			select distinct patid
			from rx1
			where lag_atc < 0;
		run;

		proc sql;
			create table rx_adjusted1 as
			select * 
			from rx1
			where patid not in (select patid from ids_with_overlaps);
		run;

		data rx_adjusted;
			set rx_adjusted
				rx_adjusted1;
		run;

		proc sql;
			create table rx1 as
			select * 
			from rx1
			where patid in (select patid from ids_with_overlaps);
		run;

		proc sql noprint;
            select count(*)
            into :finished
            from ids_with_overlaps;
        quit;

    %end;
%mend adjust_dates;

%adjust_dates;


data check2;
	set rx_adjusted;
	if lag_atc = .;
run;


proc sort data = rx_adjusted;
	by patid eventdate;
run;

data rx2(drop = eventdate1 rx_end1);
	set rx_adjusted;
	by patid;
	lag_rx = eventdate - lag(rx_end);
	if first.patid then lag_rx = 9999;
	if lag_atc < lag_rx then lag_rx = lag_atc;
	rx_end = rx_end1;
run;


data interim.rx_adjusted;
	set rx2;
run;

