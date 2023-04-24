CREATE OR ALTER PROC usp_Q69607 @UserId INT AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/69607/what-is-my-archaeologist-badge-progress */
SELECT COUNT(*) FROM Posts p
INNER JOIN Posts a on a.ParentId = p.Id
WHERE p.LastEditDate < DATEADD(month, -6, p.LastActivityDate)
AND( p.OwnerUserId = @UserId OR  a.OwnerUserId = @UserId);
END
GO

exec usp_Q69607 @UserId = 22656

CREATE NONCLUSTERED INDEX OwnerUserId
ON [dbo].[Posts] (OwnerUserId)
include (LastEditDate, LastActivityDate, ParentId)
with (maxdop = 0, online = off, drop_existing = on)

/*
CREATE NONCLUSTERED INDEX LastEditDate_LastActivityDate_OwnerUserId
ON [dbo].[Posts] (LastEditDate, LastActivityDate, OwnerUserId)
INCLUDE (ParentId)
with (maxdop = 0, online = off, drop_existing = off)

drop index LastEditDate_LastActivityDate_OwnerUserId
ON [dbo].[Posts]

DBCC FREEPROCCACHE
SET STATISTICS IO ON
*/