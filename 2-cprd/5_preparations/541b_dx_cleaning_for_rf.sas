

/* DIRECTORIES */
libname raw		 'F:/Users/0747394/phd-2-fluoroquinolones/1_raw_data/mar2024';
libname interim 	'F:/Users/0747394/phd-2-fluoroquinolones/2_interim_data/';

/* CONSTANTS */ 
%let permissible_gap = 30;
%let study_start = '01JAN2014'd;
%let study_end = '31DEC2023'd;
%let study_lookback = 365;


data index_dates;
	set interim.cohort_info(keep = patid index_date);
run;

data comorbidities;
	set raw.dx_comorbiditiesevents1
		raw.dx_comorbiditiesevents2
		raw.dx_comorbiditiesevents3
		raw.dx_comorbiditiesevents4
		raw.dx_comorbiditiesevents5
		raw.dx_comorbiditiesevents6
		raw.dx_comorbiditiesevents7
		raw.dx_comorbiditiesevents8
		raw.dx_comorbiditiesevents9
		raw.dx_comorbiditiesevents10
		raw.dx_comorbiditiesevents11
		raw.dx_comorbiditiesevents12
		raw.dx_comorbiditiesevents13
		raw.dx_comorbiditiesevents14
		raw.dx_comorbiditiesevents15
		raw.dx_comorbiditiesevents16
		raw.dx_comorbiditiesevents17
		raw.dx_comorbiditiesevents18
		raw.dx_comorbiditiesevents19
		raw.dx_comorbiditiesevents20;
run;

proc sql;
	create table comorb1 as
	select * 
	from comorbidities
	where patid in (select patid from index_dates);
quit;

data outcomes;
	set raw.dx_outcomesevents1
		raw.dx_outcomesevents2
		raw.dx_outcomesevents3
		raw.dx_outcomesevents4
		raw.dx_outcomesevents5
		raw.dx_outcomesevents6
		raw.dx_outcomesevents7
		raw.dx_outcomesevents8
		raw.dx_outcomesevents9
		raw.dx_outcomesevents10
		raw.dx_outcomesevents11
		raw.dx_outcomesevents12
		raw.dx_outcomesevents13
		raw.dx_outcomesevents14
		raw.dx_outcomesevents15
		raw.dx_outcomesevents16
		raw.dx_outcomesevents17
		raw.dx_outcomesevents18
		raw.dx_outcomesevents19
		raw.dx_outcomesevents20;
run;

proc sql;
	create table comorb2 as
	select * 
	from outcomes
	where patid in (select patid from index_dates);
quit;


proc import out = concepts
	datafile = 'F:/Users/0747394/phd-2-fluoroquinolones/1_raw_data/dx codes/dx_concepts1.csv'
	dbms = csv
	replace;
	delimiter = ",";
	guessingrows = 32767;
	getnames = YES;
run;

data concepts;
	set concepts;
	medcode1 = input(medcode, 8.);
	rename medcode = old;
	rename medcode1 = medcode;
	rename readcode = read_term;
run;


proc sql;
	select distinct(concept)
	from concepts;
quit;


data rf;
	set comorb1 comorb2;
run;


proc sql;
	create table rf1 as
	select * 
	from rf
	where medcode in (select medcode from concepts);
quit;


proc sql;
	create table rf2 as 
	select * 
	from rf1 as a
	left join (select * from concepts) as dt
	on a.medcode = dt.medcode;
quit;


data rf3;
	set rf2(drop = read_term);
	where type ne "indication";
run;

data rf;
	set rf3;
	where concept ne 'to remove';
run;

data add_indications;
	set rf2(drop = read_term);
	where type = "indication";
run;


proc sql;
	select concept, count(*) as n
	from rf
	group by concept;
quit;


proc sort data=rf out=rf nodupkey;
	by patid concept eventdate;
run;


proc sql;
	create table rf as 
	select *
	from rf
	where patid in (select patid from index_dates);
quit;


proc sql;
	create table temp1 as
	select *
	from index_dates as a
	right join rf as b
	on a.patid = b.patid;
quit;


proc sql;
	create table rf_prior1 as
	select *, max(eventdate) as maxdate
	from (select * from temp1 where index_date >= eventdate)
	group by patid, concept;
quit;


data rf_prior2(drop=maxdate);
	set rf_prior1;
	format maxdate ddmmyy10.;
	if eventdate = maxdate;
run;


proc sql;
	create table rf_post as
	select *, min(eventdate) as mindate
	from (select * from temp1 where index_date < eventdate)
	group by patid, concept;
quit;


data rf_post(drop=mindate);
	set rf_post;
	format mindate ddmmyy10.;
	if eventdate = mindate;
run;


data rf_all;
	set rf_prior2 rf_post;
	by patid concept;
run;

proc sort data = rf_all;
	by patid concept eventdate;
run;

data rf_all2;
	set rf_all;
	by patid concept;
	if first.concept;
run;


data rf_all;
	set rf_all2;
	if concept in ('renal impairment',
					'solid organ transplant',
					'prior tobacco use', 
					'tendon rupture' ,
					'tendinitis') then rf_tendon = 1;
	if concept in ('cerebrovascular diseases',
					'hypertension',
					'prior tobacco use', 
					'ischemic heart disease' ,
					'aortic aneurysm',
					'aortic dissection',
					'other heart diseases',
					'aortic valve disorder',
					'dislipidemia') then rf_aortic = 1;
run; 

proc sql;
	select distinct concept, count(*) as n, rf_aortic, rf_tendon
	from rf_all
	group by concept;
quit;


data rf_dates;
	set rf_all(keep = patid eventdate concept rf_tendon rf_aortic);
run;

proc transpose data= rf_dates out = rf_dates1;
	by patid concept eventdate;
run;


data rf_dates2(keep = patid eventdate concept rf_subgroup);
	set rf_dates1;
	if _name_ = "rf_aortic" and col1 = 1 then rf_subgroup = "aortic";
	if _name_ = "rf_tendon" and col1 = 1 then rf_subgroup = "tendon";
	where col1 <> .;
run;

/* saving files */

data interim.rf_dates;
	set rf_dates2;
run;


/* updating indications */

data ind;
	set interim.dx_clean
		add_indications;
run;

data ind1;
	set ind
		add_indications;
run;

data ids;
	set interim.index_dates_pg7(keep = patid index_date);
run;

proc sql;
	create table dxs as 
	select patid, eventdate, concept
	from ind1
	where patid in (select patid from ids);
quit;

proc sort data=dxs nodupkey;
	by patid eventdate concept;
run;

/* saving updated indications */

data interim.dx_clean;
	set dxs(keep = patid eventdate concept);
run;
