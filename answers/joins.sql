nnoremap <F6> vip:TREPLSendSelection<cr>
xmap <F6> :TREPLSendSelection<cr>

select 1;

select starttime from cd.bookings b
join cd.members m using(memid)
where firstname = 'David' and surname = 'Farrell';

select b.starttime, f.name
from cd.bookings b
join cd.facilities f using(facid)
where f.name like 'Tennis Court%'
and b.starttime >= '2012-09-21'
and b.starttime < '2012-09-22'
order by b.starttime asc;

select m.firstname, m.surname
from cd.members m
join cd.members m1 on m1.recommendedby = m.memid
group by m.firstname, m.surname
order by m.surname, m.firstname;

select m.firstname, m.surname, r.firstname, r.surname
from cd.members m
left join cd.members r on m.recommendedby = r.memid
order by m.surname, m.firstname;

select distinct m.firstname || ' ' || m.surname as member, f.name
from cd.members m
join cd.bookings b using(memid)
join cd.facilities f using(facid)
where f.name like 'Tennis Court%'
order by member;

select m.firstname || ' ' || m.surname as member, f.name, 
case
    when m.memid = 0 then b.slots * f.guestcost
    else b.slots * f.membercost
end as cost
from cd.bookings b
join cd.facilities f using(facid)
join cd.members m using(memid)
where b.starttime >= '2012-09-14'
and b.starttime < '2012-09-15'
and ((m.memid = 0 and b.slots * f.guestcost > 30)
    or
    (m.memid != 0 and b.slots * f.membercost > 30))
order by cost desc;

select distinct m.firstname || ' ' || m.surname as member,
(select r.firstname || ' ' || r.surname from cd.members r
where m.recommendedby = r.memid) as recommender
from cd.members m
order by member;

select b.firstname || ' ' || b.surname as member, b.name, b.cost
from (
    select m.firstname, m.surname, f.name as name,
    case
        when m.memid = 0 then b.slots * f.guestcost
        else b.slots * f.membercost
    end as cost
    from cd.bookings b
    join cd.facilities f using(facid)
    join cd.members m using(memid)
    where b.starttime >= '2012-09-14'
    and b.starttime < '2012-09-15') b
where b.cost > 30
order by cost desc;
