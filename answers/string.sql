select surname || ', ' || firstname from cd.members;

select * from cd.facilities where name like 'Tennis%';

select * from cd.facilities where name ilike 'tennis%';

select memid, telephone from cd.members where telephone like '%(%)%';

select lpad(zipcode::text, 5, '0') as zip from cd.members
order by zip;

select first, count(*) from (
select substr(surname, 1, 1) as first from cd.members
) initials
group by first
order by first;

select memid, translate(telephone, '-() ', '') from cd.members;
