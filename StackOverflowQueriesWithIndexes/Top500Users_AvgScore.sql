/*
https://data.stackexchange.com/stackoverflow/query/952/top-500-answerers-on-the-site
*/

SET STATISTICS IO ON 

SELECT 
    TOP 500
    Users.Id as [User Link],
    Count(p.Id) AS Answers,
    CAST(AVG(CAST(Score AS float)) as numeric(6,2)) AS [Average Answer Score]
FROM
    Posts p
  INNER JOIN
    Users ON Users.Id = p.OwnerUserId
WHERE 
    p.PostTypeId = 2 and p.CommunityOwnedDate is null and p.ClosedDate is null
GROUP BY
    Users.Id, DisplayName
HAVING
    Count(p.Id) > 10
ORDER BY
    [Average Answer Score] DESC

/* Posts logical reads 42,52,981*/
/* Users logical reads 44,867 */

create index PostTypeId_CommunityOwnedDate_ClosedDate
on dbo.Posts(PostTypeId, CommunityOwnedDate, ClosedDate)
include(OwnerUserId, Score)
with (maxdop = 0, online = off)

/* Posts logical reads 53,096*/
/* Users logical reads 44,867 */

/* Find the selectivity of Posts vs Users.  */

select count(*) 
from dbo.Posts p
where p.PostTypeId = 2 and p.CommunityOwnedDate is null and p.ClosedDate is null

select count(*)
from dbo.Users
