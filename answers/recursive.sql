with recursive r(id) as (
    select recommendedby from cd.members where memid = 12
    union all
    select m.recommendedby from cd.members m join r on m.memid = r.id
)
select memid, firstname, surname
from cd.members m
join r on m.memid = r.id;

with recursive r(memid) as (
    select memid from cd.members where recommendedby = 1
    union all
    select m.memid from cd.members m join r on m.recommendedby = r.memid
)
select m.recommendedby, m.memid, m.firstname, m.surname
from cd.members m
join r on m.memid = r.memid
order by m.memid asc;

with recursive r(memid, recommendedby) as (
    select memid, recommendedby from cd.members where memid in('12', '22')
    union all
    select r.memid, m.recommendedby from cd.members m
    join r on r.recommendedby = m.memid
)
select r.memid, r.recommendedby, m.firstname, m.surname
from r
join cd.members m on r.recommendedby = m.memid
order by memid asc;
