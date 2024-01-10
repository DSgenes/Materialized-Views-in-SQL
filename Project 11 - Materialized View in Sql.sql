/*

Materialized View - Materialized views are also database objects which are formed based on a SQL query
                    however unlike views, the contents or data of the materialized views are periodically 
					refreshed based on its configuration.                   
*/


create table random_tab (id int, val decimal);

--i want to insert millions of records into this table
insert into random_tab
select 1, random() from generate_series(1, 10000000);

insert into random_tab
select 2, random() from generate_series(1, 10000000);

--it took 3 seconds 218 milliseconds to process this query
select id, avg(val), count(*)
from random_tab

drop materialized view mv_random_tab;

--it's fetching two records and it just took 63 milliseconds
create materialized view mv_random_tab
as
select id, avg(val), count(*)
from random_tab
group by id;

--when i execute this query it just took 60 milliseconds
select * from mv_random_tab;

--Data will not get automatically updated
--if i change the data in this base table that is in my random tab table then materialize view 
--is not going to have that data updated automatically we've to manually do that by using a refresh

--let delete this 10 million records from base table
delete from random_tab where id = 1; 

--so if i run my base query then you can see its only fetching me one record
select id, avg(val), count(*)
from random_tab
group by id;

--but if i run my query from materialized view you can see it's still having the old data
--materialize view is not going to automatically update it

select * from mv_random_tab;

--internally sql went and executed the query and whatever the data was returned it got stored into the 
--materialize view so this is basically what a refresh can do
refresh materialized view mv_random_tab; 

--now if i go and execute materialize view it's going to get the latest data
select * from mv_random_tab;

-----------------------------------------------------------------------------------