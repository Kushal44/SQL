set statistics io on
go

/*
https://data.stackexchange.com/lifehacks/query/6627/top-50-most-prolific-editors
*/

create or alter proc dbo.usp_6627 as
begin


	--No need of temp table when creating an indexed view having same information.
	create table #UserWithTotalEdits(Id int primary key clustered, TotalEdits int);
	insert into #UserWithTotalEdits(Id, TotalEdits)
	select top 50 LastEditorUserId as Id, SUM(TotalEdits) AS TotalEdits
	from dbo.vwPosts_Editors pTE
	group by LastEditorUserId
	order by SUM(TotalEdits) desc;


	SELECT 
		Id AS [User Link],
		(
			SELECT COUNT(*) FROM dbo.vwPosts_Editors as pQ WITH (NOEXPAND) -- plan is not considering view by just mentioning view, use WITH (NO EXPAND)
			WHERE
				PostTypeId = 1 AND
				LastEditorUserId = u.Id
		) AS QuestionEdits,
		(
			SELECT COUNT(*) FROM dbo.vwPosts_Editors as pA WITH (NOEXPAND) -- plan is not considering view by just mentioning view, use WITH (NOEXPAND)
			WHERE
				PostTypeId = 2 AND
				LastEditorUserId = u.Id 
		) as AnswersEdits,
		u.TotalEdits
	   from #UserWithTotalEdits u
	   --from dbo.vwPosts_Editors u
    
end

/*
Sequence of columns included in index matters
In above query OwnerUserId is searched with != operator.
It is last in index and giving much better performance in comparison to the order
(PostTypeId, OwnerUserId, LastEditorUserId)
Narrow down the search with equal operator first. 
REMEMBER BRENT OZAR HANDS MOVING CLOSER
*/

--drop index PostTypeId_Last on dbo.Posts;
create index PostTypeId_Last on dbo.Posts(PostTypeId, LastEditorUserId, OwnerUserId)
with (maxdop = 0, online = off);
go

--drop index PostTypeId_Last on dbo.Posts

/*Other way of doing that is Indexed Views. It will create a view of records inserted into 
	temp table #UsersWithTotalEdits
*/


--drop view dbo.vwPosts_Editors;
--go

create or alter view dbo.vwPosts_Editors WITH SCHEMABINDING AS
	select LastEditorUserId, PostTypeId, COUNT_BIG(*) as TotalEdits
	from dbo.Posts
	where LastEditorUserId <> OwnerUserId --this helps filter our records where Owner is not last editor of the posts, as need by temp table
	group by LastEditorUserId, PostTypeId;
GO

create unique clustered index CL_LastEditorUserId 
	ON dbo.vwPosts_Editors(LastEditorUserId, PostTypeId);

set statistics io, time on;
exec dbo.usp_6627

dbcc freeproccache