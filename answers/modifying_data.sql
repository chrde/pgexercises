begin;
insert into cd.facilities(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
values (9,'Spa', 20, 30, 100000, 800);
rollback;

begin;
insert into cd.facilities(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
values
(9,'Spa', 20, 30, 100000, 800),
(10, 'Squash Court 2', 3.5, 17.5, 5000, 80);
rollback;

begin;
insert into cd.facilities(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
select max(facid) + 1,'Spa', 20, 30, 100000, 800 from cd.facilities
rollback;

begin;
update cd.facilities set initialoutlay = 10000 where facid = 1;
rollback;

begin;
update cd.facilities set membercost = 6, guestcost = 30 where facid in (0,1);
rollback;

begin;
update cd.facilities a
set membercost = b.membercost * 1.1, guestcost = b.guestcost * 1.1
from cd.facilities b
where b.facid = 0 and a.facid = 1;
rollback;

begin;
truncate table cd.bookings;
rollback;


begin;
delete from cd.members where memid = 37;
rollback;

begin;
delete from cd.members where memid not in
(select distinct memid from cd.bookings);
rollback;
