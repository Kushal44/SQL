CREATE OR ALTER PROC dbo.usp_Q43336 AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/43336/who-brings-in-the-crowds */

-- Who Brings in the Crowds?
-- Users sorted by total number of views of their questions per day (softened by 30 days to keep new hot posts from skewing the results)

-- I tried removing the softener, but the results are really more useful with it
-- updated to use last database access (by a logged in user -- best we've got) instead of current_timestamp

SELECT TOP 50
  q.OwnerUserId as [User Link],
  count(q.Id) as Questions,
  sum(q.ViewCount/(30+datediff(day, q.CreationDate, datadumptime ))) AS [Question Views per Day]
FROM Posts AS q, (select max(LastAccessDate) as datadumptime from Users) tmp
WHERE  
  q.CommunityOwnedDate is null AND
  q.OwnerUserId is NOT null AND
  q.PostTypeId=1
GROUP BY q.OwnerUserId
ORDER BY [Question Views per Day] DESC;
END
GO


DBCC FREEPROCCACHE

--drop index
--PostTypeId_CommunityOwnedDate
--on dbo.Posts

CREATE NONCLUSTERED INDEX Clippy_Suggestion
ON [dbo].[Posts] ([CommunityOwnedDate],[PostTypeId],[OwnerUserId])
INCLUDE ([CreationDate],[ViewCount])
with (online = off, maxdop = 0);


create index LastAccessDate on dbo.Users(LastAccessDate)
with (online = off, maxdop = 0, drop_existing = off);

SET STATISTICS IO ON