use StackOverflow2013
go

/*
https://data.stackexchange.com/stackoverflow/query/7521/how-unsung-am-i
*/

create or alter proc dbo_usp_Q@7521 @UserId int as
begin

-- How Unsung am I?
-- Zero and non-zero accepted count. Self-accepted answers do not count.

select
    count(a.Id) as [Accepted Answers],
    sum(case when a.Score = 0 then 0 else 1 end) as [Scored Answers],  
    sum(case when a.Score = 0 then 1 else 0 end) as [Unscored Answers],
    sum(CASE WHEN a.Score = 0 then 1 else 0 end)*1000 / count(a.Id) / 10.0 as [Percentage Unscored]
from
    Posts q
  inner join
    Posts a
  on a.Id = q.AcceptedAnswerId
where
      a.CommunityOwnedDate is null
  and a.OwnerUserId = @UserId
  and q.OwnerUserId != @UserId
  and a.postTypeId = 2

end

set statistics io, time on
exec dbo_usp_Q@7521 22656

create index OwnerUserId_PostTypeId_CommunityOwnedDate 
on dbo.Posts(OwnerUserId, PostTypeId, CommunityOwnedDate)
include (Score)
with (maxdop = 0, online = off);

drop index AcceptedAnswerId_OwnerUserId
on dbo.Posts;

create index AcceptedAnswerId_OwnerUserId
on dbo.Posts(OwnerUserId, AcceptedAnswerId)
with (maxdop = 0, online = off);

--drop index OwnerUserId_PostTypeId_CommunityOwnedDate 
--on dbo.Posts

dbcc freeproccache