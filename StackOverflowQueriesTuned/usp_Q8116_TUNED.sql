/*
https://data.stackexchange.com/stackoverflow/query/8116/my-money-for-jam
*/

create or alter proc dbo.usp_Q8116_TUNED as
begin

declare @latestDate datetime
select @latestDate = max(CreationDate) from Posts
declare @ignoreDays numeric = 15
declare @minAgeDays numeric = @ignoreDays * 4
declare @UserId int = 22656;

/*
Replace table variable CTE - Common Table Expression.
In table variable insertion operation is single threaded.
Alos table variable estimation is incorrect, it estimate 
ONLY ONE row.
*/
-- temp table moded from http://odata.stackexchange.com/stackoverflow/s/87
--declare @VoteStats table (PostId int, up int, down int, CreationDate datetime)
--insert @VoteStats
WITH VoteStats
as (
	select
		p.Id as PostId,
		up = sum(case when VoteTypeId = 2 then
			case when p.ParentId is null then 5 else 10 end
			else 0 end),
		down = sum(case when VoteTypeId = 3 then 2 else 0 end),
		p.CreationDate
	from Votes v join posts p on v.postid = p.id
	where v.VoteTypeId in (2,3)
	and OwnerUserId = @UserId
	and p.CommunityOwnedDate is null
	and datediff(day, p.CreationDate, v.CreationDate) > @ignoreDays
	and datediff(day, p.CreationDate, @latestDate) > @minAgeDays
	group by p.Id, p.CreationDate, p.ParentId
)

select top 100 PostId as [Post Link],
  convert(decimal(10,2), up - down)/(datediff(day, vs.CreationDate, @latestDate) - @ignoreDays) as [Passive Rep Per Day],
  (up - down) as [Passive Rep],
  up as [Passive Up Reputation],
  down as [Passive Down Reputation],
  datediff(day, vs.CreationDate, @latestDate) - @ignoreDays as [Days Counted]
from VoteStats vs
order by [Passive Rep Per Day] desc

end


exec dbo.usp_Q8116_TUNED