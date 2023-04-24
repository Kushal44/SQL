CREATE OR ALTER PROC usp_Q49864 @UserId INT = 26837 AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/49864/my-comments-ordered-by-score-pundit-badge-progress  */
SELECT 
    c.Score,
    c.Id as [Comment Link],
    PostId as [Post Link],
    CASE 
    WHEN Q.Id is not NULL 
		THEN CONCAT('<a href=\"http://stackoverflow.com/a/', Posts.Id, '\">', Q.Title, '</a>')
        ELSE CONCAT('<a href=\"http://stackoverflow.com/q/', Posts.Id, '\">', Posts.Title, '</a>') 
    END as QTitle,
    PostId,
    Posts.ParentId,
    c.CreationDate
FROM 
    Comments c join Posts on c.PostId = Posts.Id
        left join Posts as Q on Posts.ParentId = Q.Id
WHERE 
    UserId = @UserId and c.Score > 0
ORDER BY 
    c.Score DESC;
END
GO

exec usp_Q49864 @UserId = 22656

SET STATISTICS IO ON;

dropindexes


CREATE NONCLUSTERED INDEX UserId_Score
ON [dbo].[Comments] ([UserId],[Score])
INCLUDE ([CreationDate],[PostId])
with (maxdop = 0, online = off, drop_existing = on)

