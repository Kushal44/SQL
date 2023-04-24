/*
https://data.stackexchange.com/stackoverflow/query/7521/how-unsung-am-i
*/
USE StackOverflow2013
GO
SET STATISTICS IO ON;

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
  and a.OwnerUserId = 26837
  and q.OwnerUserId != 26837
  and a.postTypeId = 2

/* logical reads 73,834,564 with just CI */

create index OwnerUserId
on dbo.Posts(OwnerUserId)
with (online = off, maxdop =0);
/*logical reads 42,63,962 with OwnerUserId*/

create index AcceptedAnswerId
on dbo.Posts(AcceptedAnswerId)
with (online = off, maxdop =0);
/*logical reads 42,63,962 with OwnerUserId, AcceptedAnswerId*/

DROP INDEX AcceptedAnswerId
on dbo.Posts;