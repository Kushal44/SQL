/*
https://data.stackexchange.com/cs/query/8116/my-money-for-jam
*/

-- My Money for Jam
-- My Non Community Wiki Posts that earn the most Passive Reputation.
-- Reputation gained in the first 15 days of post is ignored,
-- all reputation after that is considered passive reputation.
-- Post must be at least 60 Days old.

/*
Just to get the User Id of famous Jon Skeet
*/
select * 
from dbo.Users
where DisplayName = 'Jon Skeet'

SET STATISTICS IO ON


set nocount on

declare @latestDate datetime
select @latestDate = max(CreationDate) from Posts
declare @ignoreDays numeric = 15
declare @minAgeDays numeric = @ignoreDays * 4
declare @UserId int = 22656 --Jon Skeet

-- temp table moded from http://odata.stackexchange.com/stackoverflow/s/87
declare @VoteStats table (PostId int, up int, down int, CreationDate datetime)
insert @VoteStats
select
    p.Id,
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

set nocount off

select top 100 PostId as [Post Link],
  convert(decimal(10,2), up - down)/(datediff(day, vs.CreationDate, @latestDate) - @ignoreDays) as [Passive Rep Per Day],
  (up - down) as [Passive Rep],
  up as [Passive Up Reputation],
  down as [Passive Down Reputation],
  datediff(day, vs.CreationDate, @latestDate) - @ignoreDays as [Days Counted]
from @VoteStats vs
order by [Passive Rep Per Day] desc

/*
With CI Only Posts Reads - 8,447,871
With CI Only Votes Reads - 243,698
*/

create index OwnerUserId_CommunityOwnedDate
on dbo.Posts(OwnerUserId, CommunityOwnedDate)
include (CreationDate, ParentId)
with (maxdop = 0, online = off, drop_existing = off) 

/*
With OwnerUserId_CommunityOwnedDate_CreationDate Posts Reads - 74,106
With OwnerUserId_CommunityOwnedDate_CreationDate Votes Reads - 243,698
*/

create index PostId_VoteTypeId
on dbo.Votes(PostId, VoteTypeId)
include (CreationDate)
with (maxdop = 0, online = off, drop_existing = on) 

--drop index PostId_VoteTypeId
--on dbo.Votes
/*
With OwnerUserId_CommunityOwnedDate_CreationDate, PostId_VoteTypeId Posts Reads - 74,106
With OwnerUserId_CommunityOwnedDate_CreationDate, PostId_VoteTypeId Votes Reads - 219,177
*/

/*
there is no major difference in page IO when using index PostId_VoteTypeId vs VoteTypeId_PostId
*/
create index VoteTypeId_PostId
on dbo.Votes(VoteTypeId, PostId)
include (CreationDate)
with (maxdop = 0, online = off, drop_existing = off)