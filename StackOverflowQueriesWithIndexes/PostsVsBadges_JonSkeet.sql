SET STATISTICS IO ON;

select *
from Badges
where UserId = 22656 and CAST(Date as Date) = '2008-12-01'

select *
from Posts
where OwnerUserId = 22656 and CAST(CreationDate as Date) = '2008-12-01'
GO

CREATE OR ALTER PROC dbo.usp_Q66093 @UserId INT = 22656 AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/66093/posts-by-jon-skeet-per-day-versus-total-badges-hes-earnt */

select CAST(p.CreationDate as Date) as PostDate, count(p.Id) as Posts,
(
select count(b.Id) / 100
  from Badges b
  where b.UserId = u.Id
  and b.Date <= CAST(p.CreationDate as Date)
  ) as BadgesEarned
from Posts p, Users u
  where u.Id = @UserId
  and p.OwnerUserId = u.Id
  group by CAST(p.CreationDate as Date), u.Id
order by CAST(p.CreationDate as Date);
END
GO

exec dbo.usp_Q66093

create index OwnerUserId_CreationDate
on dbo.Posts(OwnerUserId, CreationDate)
with (maxdop = 0, online = off, drop_existing = off);

create index UserId_Date
on dbo.Badges(UserId, Date)
with (maxdop = 0, online = off, drop_existing = off);

/*This is the query Kushal created to find number of Posts created and number of Badges created everyday*/

select CAST(p.CreationDate as DATE) as PostDate, Count(p.Id) PostsCreated,
(
	select count(b.Id)
	from Badges b
	where b.UserId = u.Id
	and CAST(b.Date as Date) = CAST(p.CreationDate as date)
) as BadgesEarned
from Posts p inner join Users u 
on 
p.OwnerUserId = u.Id
and u.Id =  22656
group by CAST(p.CreationDate as DATE), u.Id
order by CAST(p.CreationDate as Date);
