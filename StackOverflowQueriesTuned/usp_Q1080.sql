use StackOverflow2013	
go

SET STATISTICS IO ON;
go

/*
https://data.stackexchange.com/cs/query/1080/top-users-by-number-of-bounties-won
*/

create or alter proc dbo_usp_10080_Tuned @StartYear int, @EndYear int as
begin

DECLARE @StartDate DATE = DATEFROMPARTS(@StartYear, 1, 1),
	@EndDate DATE = DATEFROMPARTS(@EndYear, 1, 1)

--CREATE TABLE #Votes(PostId int primary key, BountiesWon int, BountyReputation int)
--insert into #Votes(PostId, BountiesWon, BountyReputation)
--	select PostId, Count(*) as BountyWon,
--		Sum(Votes.BountyAmount) as BountyReputation
--	from dbo.Votes
--	where 
--	VoteTypeId=9
--	and Votes.CreationDate >= @StartDate
--	and Votes.CreationDate < @EndDate
--	group by postid
	
SELECT Users.DisplayName, Users.Reputation, Posts.OwnerUserId,
	SUM(v.BountiesWon) as BountiesWon,
	SUM(v.BountyReputation) as BountyReputation
FROM Votes v
  INNER JOIN Posts ON v.PostId = Posts.Id
  inner join Users on Posts.OwnerUserId = Users.Id
WHERE
  VoteTypeId=9
  --and YEAR(Votes.CreationDate) BETWEEN @StartYear and @EndYear
  and v.CreationDate >= @StartDate
  and v.CreationDate < @EndDate
GROUP BY
  Posts.OwnerUserId, Users.DisplayName, Users.Location, Users.Reputation
ORDER BY
  SUM(v.BountiesWon) DESC

end
go

DBCC FREEPROCCACHE
exec dbo_usp_10080_Tuned @StartYear = 2010, @EndYear = 2023
GO
/*
Original Query
*/

create or alter proc dbo_usp_10080 @StartYear int, @EndYear int as
begin

SELECT Users.DisplayName, Users.Reputation, Posts.OwnerUserId,
	COUNT(*) As BountiesWon
FROM Votes
  INNER JOIN Posts ON Votes.PostId = Posts.Id
  inner join Users on Posts.OwnerUserId = Users.Id
WHERE
  VoteTypeId=9
  and YEAR(Votes.CreationDate) BETWEEN @StartYear and @EndYear
GROUP BY
  Posts.OwnerUserId, Users.DisplayName, Users.Location, Users.Reputation
ORDER BY
  BountiesWon DESC

end



create index VoteTypeId_CreationDate
on dbo.Votes (VoteTypeId, CreationDate) 
with (maxdop =0, online = off)


--drop index VoteTypeId_PostId on dbo.Votes;