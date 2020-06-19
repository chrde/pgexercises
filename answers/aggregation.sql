select count(*) from cd.facilities;

select count(*) from cd.facilities
where guestcost >= 10;

select recommendedby, count(*) from cd.members
where recommendedby is not null
group by recommendedby
order by recommendedby;

select facid, sum(slots)
from cd.bookings
group by facid
order by facid;

select facid, sum(slots) total
from cd.bookings
where starttime >= '2012-09-01' and starttime < '2012-10-01'
group by facid
order by total;

select facid, date_part('month', starttime) as month, sum(slots)
from cd.bookings
where starttime >= '2012-01-01' and starttime < '2013-01-01'
group by month, facid
order by facid asc, month asc;

select count(distinct memid)
from cd.members
join cd.bookings using(memid);

select facid, sum(slots) as slots
from cd.bookings
join cd.facilities using(facid)
group by facid
having sum(slots) > 1000
order by facid;

select name, sum(cost)
from (
    select f.name,
    slots * case
        when b.memid = 0 then f.guestcost
        else f.membercost
    end as cost
    from cd.bookings b
    join cd.facilities f using(facid)
) b
group by name
order by sum(cost) asc;

select name, sum(cost)
from (
    select f.name,
    slots * case
        when b.memid = 0 then f.guestcost
        else f.membercost
    end as cost
    from cd.bookings b
    join cd.facilities f using(facid)
) b
group by name
having sum(cost) < 1000
order by sum(cost) asc;

with groups as (
    select facid, sum(slots) as slots
    from cd.bookings
    group by facid
)
select facid, slots
from groups
where slots = (select max(slots) from groups);

select facid, date_part('month', starttime) as month, sum(slots)
from cd.bookings
where starttime >= '2012-01-01' and starttime < '2013-01-01'
group by rollup (facid, month)
order by facid asc, month asc;

select f.facid, f.name, to_char(float8 (sum(b.slots) / 2.0), 'FM9999.00')
from cd.bookings b
join cd.facilities f using(facid)
group by f.facid, f.name
order by f.facid;

explain select m.surname, m.firstname, f.memid, f.starttime
from cd.members m
join (
    select distinct on (memid)
    memid, starttime
    from cd.bookings
    where starttime >= '2012-09-01'
    order by memid, starttime asc
) f using(memid);

select count(*) over (), firstname, surname
from cd.members;

select row_number() over (order by joindate), firstname, surname
from cd.members;

select facid, total from (
    select facid, sum(slots) total, rank() over (order by sum(slots) desc)
    from cd.bookings
    group by facid
) f
where rank = 1;

select firstname, surname, ((sum(slots) + 10) / 2)/10 * 10 as hours,
rank() over (order by((sum(slots) + 10) / 2)/10 * 10 desc)
from cd.members
join cd.bookings using(memid)
group by memid
order by rank, surname, firstname;

with revenue(name, cost) as
(
    select f.name,
    sum(slots * case
        when b.memid = 0 then f.guestcost
        else f.membercost
    end) as cost
    from cd.bookings b
    join cd.facilities f using(facid)
    group by f.name
)
select name, rank() over(order by cost desc)
from revenue
limit 3;

with revenue(name, cost) as (
    select f.name,
    sum(slots * case
        when b.memid = 0 then f.guestcost
        else f.membercost
    end) as cost
    from cd.bookings b
    join cd.facilities f using(facid)
    group by f.name
),
tiles(name, class) as (
    select name, ntile(3) over(order by cost desc)
    from revenue
)
select name, case
when class = 1 then 'high'
when class = 2 then 'average'
else 'low' end revenue
from tiles
order by class, name;

select name, initialoutlay / (benefits - monthlymaintenance) as months
from (
    select f.name, f.initialoutlay, f.monthlymaintenance, sum(slots * case
        when b.memid = 0 then f.guestcost
        else f.membercost
        end)/3 as benefits
    from cd.bookings b
    join cd.facilities f using(facid)
    group by f.facid
) m
order by name;

with
revenue_per_day as (
    select starttime::date as day,
    sum(slots * case
        when b.memid = 0 then f.guestcost
        else f.membercost
    end) as cost
    from cd.bookings b
    join cd.facilities f using(facid)
    where starttime >= '2012-08-01'::date - '15 days'::interval
    and starttime < '2012-09-01'::date
    group by starttime::date
    order by day
),
avg_revenue as (
    select day, avg(cost) over (order by day asc rows between 14 preceding and current row)
    from revenue_per_day
)
select * from avg_revenue 
where day >= '2012-08-01'::date;
