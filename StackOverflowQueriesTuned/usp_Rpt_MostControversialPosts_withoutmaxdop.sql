 
--set nocount on 

--declare @VoteStats table (PostId int, up int, down int) 

--insert @VoteStats
--select
--    PostId, 
--    up = sum(case when VoteTypeId = 2 then 1 else 0 end), 
--    down = sum(case when VoteTypeId = 3 then 1 else 0 end)
--from Votes
--where VoteTypeId in (2,3)
--group by PostId

--set nocount off
/*
https://data.stackexchange.com/cs/query/466/most-controversial-posts-on-the-site
*/

create or alter proc dbo.usp_Rpt_MostControversialPosts_withoutmaxdop as
begin
set nocount on;

WITH VoteStats AS(
	select
		PostId, 
		up = sum(case when VoteTypeId = 2 then 1 else 0 end), 
		down = sum(case when VoteTypeId = 3 then 1 else 0 end)
	from Votes
	where VoteTypeId in (2,3)
	group by PostId
)



select top 100 p.id as [Post Link] , up, down from VoteStats 
join Posts p --WITH(FORCESEEK) 
on PostId = p.Id
where down > (up * 0.5) and p.CommunityOwnedDate is null and p.ClosedDate is null
order by up desc 

--option(maxdop 1)

end

exec dbo.usp_Rpt_MostControversialPosts_withoutmaxdop

/*Nonclustered cloumnstore index*/
create nonclustered columnstore index VoteTypeId_PostId ON dbo.Votes(VoteTypeId, PostId)
with (online = off, maxdop = 0);
create nonclustered index PostId_VoteTypeId ON dbo.Votes(PostId, VoteTypeId)
with (online = off, maxdop = 0);

drop index PostId_VoteTypeId ON dbo.Votes;
dbcc freeproccache