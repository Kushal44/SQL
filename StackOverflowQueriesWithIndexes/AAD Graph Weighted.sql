CREATE OR ALTER PROC dbo.usp_Q283566 @Keyword NVARCHAR(30) = '%graph%' AS
BEGIN
-- leading/trailing space helps match stackoverflow.com search behavior

-- Build the filter result set; contains key and unanswered 'skew' value
CREATE TABLE #unanswered (Id int primary key, Age int, UnansweredSkew int)
INSERT #unanswered
SELECT q.Id as Id, 
CAST((GETDATE() - q.CreationDate) AS INT) as Age,
CASE WHEN q.AcceptedAnswerId is null THEN -10 
     WHEN q.AcceptedAnswerId is not null THEN 0 END AS [Total]
FROM Posts q
WHERE ((q.Tags LIKE '%adal%')
    OR (q.Tags LIKE '%office365%')
    OR (q.Tags LIKE '%azure-active-directory%'))
AND ((LOWER(q.Body) LIKE @Keyword)
   OR(LOWER(q.Title) LIKE @Keyword))

    
-- Build the weighting result set, using the one above as driver
SELECT p.Id AS [Post Link], 
p.ViewCount, 
p.AnswerCount, 
CONVERT(VARCHAR(10), p.CreationDate, 1) as Created,
u.Age,
CASE WHEN p.AcceptedAnswerId is null THEN 'false' ELSE 'true' END AS Answered,
((p.ViewCount * .05) + (u.Age * .1) + p.AnswerCount + u.UnansweredSkew) AS Weight
FROM Posts p
JOIN #unanswered u ON u.Id = p.Id
ORDER BY Answered ASC, Weight DESC;
END
GO

exec dbo.usp_Q283566
go
/*
SET STATISTICS IO ON
DropIndexes
create index Tags on dbo.Posts(Tags)
drop index Tags on dbo.Posts
DBCC FREEPROCCACHE
*/

/* Creating a View and indexed view. 
  This is useful to parse very small dataset especially when WHERE 
  condition is having non-sargable parameters
  NOTE - SQL decides not to use this view for query above. It continues to 
  use Index scan, not sure why
*/
create or alter view dbo.usp_Q283566_tags with schemabinding as
select Id, AcceptedAnswerId, CreationDate
from dbo.Posts
WHERE ((Tags LIKE '%adal%')
    OR (Tags LIKE '%office365%')
    OR (Tags LIKE '%azure-active-directory%'))

create unique clustered index Id 
on dbo.usp_Q283566_tags(Id)
with (drop_existing = off, maxdop = 0, online = off);

/* This query uses the clustered index created on Indexed View */
select count(*)
from Posts
WHERE ((Tags LIKE '%adal%')
    OR (Tags LIKE '%office365%')
    OR (Tags LIKE '%azure-active-directory%'))
