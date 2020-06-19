select '2012-08-31 01:00:00'::timestamp;

select '2012-08-31 01:00:00'::timestamp - '2012-07-30 01:00:00'::timestamp;

select * from generate_series('2012-10-01'::timestamp, '2012-10-31'::timestamp, '1 day');

select date_part('day', '2012-08-31'::timestamp);

select date_part('epoch', '2012-09-02 00:00:00'::timestamp - '2012-08-31 01:00:00'::timestamp);

select month, count(*) || ' days'
from (
    select date_part('month', generate_series('2012-01-01'::timestamp, '2012-12-31'::timestamp, '1 day')) as month
) m
group by month
order by month asc;

with given as (select '2012-02-11 01:00:00'::timestamp as d)
select date_trunc('month', d + '1 month'::interval) - date_trunc('days', d)
from given;

select starttime, (slots * '30 minutes'::interval) + starttime as endtime
from cd.bookings
order by endtime desc, starttime desc
limit 10;

select date_trunc('month', starttime) as month, count(*)
from cd.bookings
group by date_trunc('month', starttime)
order by month asc;

with slots_per_month as (
    select month, date_part('days', (month + '1 month'::interval) - month) * slots as month_slots
    from
    ( select distinct(date_trunc('month', starttime)) as month from cd.bookings) m, 
    ( select date_part('epoch', '20:30'::time - '08:00'::time) / 3600 * 2 as slots ) n
),
booked_slots_per_month as (
    select sum(slots) as sum, name, date_trunc('month', starttime) as month
    from cd.bookings b
    join cd.facilities using(facid)
    join slots_per_month s on s.month = date_trunc('month', b.starttime)
    group by name, date_trunc('month', starttime)
    order by name, month asc 
)
select name, month, round(cast(sum/month_slots * 100 as numeric), 1) as utilisation
from booked_slots_per_month
join slots_per_month using (month)
order by name asc, month asc;
