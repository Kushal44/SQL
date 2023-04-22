/*
Users created after me and having Reputation more than me
*/

create or alter proc dbo.MoreReputation @UserId int as
BEGIN 
select u.Reputation, u.Reputation - me.Reputation as Difference
from
dbo.Users me
inner join 
dbo.Users u on u.CreationDate > me.CreationDate
			and u.Reputation > me.Reputation
where me.Id = @UserId
order by u.Reputation desc
END
GO

select count(*) from 
dbo.Users where Reputation > 
(select Reputation
from dbo.Users
where Id = 26837)

select count(*) from 
dbo.Users where CreationDate > 
(select CreationDate
from dbo.Users
where Id = 26837)


select count(*) from
dbo.Users
GO



DropIndexes

exec dbo.MoreReputation @UserId = 26837
/*logical reads 44564*/
SET STATISTICS IO ON;

create INDEX CreationDate_Reputation on dbo.users(CreationDate, Reputation)
/*logical reads 33393*/

create INDEX Reputation_CreationDate on dbo.users(Reputation, CreationDate)
/*logical reads 26730*/

create unique clustered index Id on dbo.users(id)

DBCC FREEPROCCACHE