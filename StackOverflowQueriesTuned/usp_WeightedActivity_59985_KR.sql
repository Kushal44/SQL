create or alter proc dbo.usp_Weighted_Activity_59985_KR

@DisplayName NVARCHAR(40),
@StartDate NVARCHAR(40),
@EndDate NVARCHAR(40)

as
begin

declare @UserId int;

SELECT TOP 1 @UserId = Id 
	FROM Users 
	WHERE DisplayName = @DisplayName
	order by Id;

create table #MatchingPosts (Id int, PostTypeId int, Tags nvarchar(150),
							CreationDate DateTime, Score int, ViewCount int, ParentId int);

insert into #MatchingPosts(Id, PostTypeId, Tags, CreationDate, Score, ViewCount, ParentId)
select Id, PostTypeId, Tags, CreationDate, Score, ViewCount, ParentId
from Posts p
where p.OwnerUserId = @UserId AND
	  p.CreationDate BETWEEN convert(Date, @StartDate) and convert(Date, @EndDate)

SELECT DISTINCT
  p.Id as [Post Link],
  p.CreationDate,
  p.Score,
  isnull(p.ViewCount, p2.ViewCount) as [View Count],
  3 - p.PostTypeId as Weight
FROM #MatchingPosts p
LEFT JOIN PostTypes pt
ON p.PostTypeId = pt.Id
LEFT JOIN Posts p2
ON p.ParentId = p2.Id
WHERE (p.Tags in ('<sql-server>', '<oracle>', '<mysql>')
	or p2.Tags in ('<sql-server>', '<oracle>', '<mysql>')) 

end

--Execution of above mentioned SP

set statistics io on

exec usp_Weighted_Activity_59985_KR @DisplayName = N'Jon Skeet',
@StartDate =  N'2010-01-01',
@EndDate = N'2020-01-01'

/*
Find the user having most questions tagged with the tags in where 
select OwnerUserId, Count(Id) as recs
from Posts p
where p.Tags in ('<sql-server>', '<oracle>', '<mysql>')
group by OwnerUserId
order by Count(Id) desc
*/

/*
create or alter proc dbo.usp_Weighted_Activity_59985

@DisplayName NVARCHAR(40),
@StartDate NVARCHAR(40),
@EndDate NVARCHAR(40)

as
begin

SELECT DISTINCT
  p.Id as [Post Link],
  p.CreationDate,
  p.Score,
  isnull(p.ViewCount, p2.ViewCount) as [View Count],
  3 - p.PostTypeId as Weight --+ 
  -- Comment out the case if answers should have weight 1, 
  -- regardless of if they are the accepted answer.
  --  CASE
  --    WHEN p2.AcceptedAnswerId = p.Id 
  --    THEN 2
  --    ELSE 0
  --  END AS Weight
FROM Posts p
LEFT JOIN PostTypes pt
ON p.PostTypeId = pt.Id
LEFT JOIN Posts p2
ON p.ParentId = p2.Id
WHERE (p.Tags in ('<sql-server>', '<oracle>', '<mysql>')


	or p2.Tags in ('<sql-server>', '<oracle>', '<mysql>')) AND
  p.OwnerUserId = (SELECT TOP 1 Id FROM Users WHERE DisplayName = @DisplayName) AND
  p.CreationDate BETWEEN convert(Date, @StartDate) and convert(Date, @EndDate)

end
*/