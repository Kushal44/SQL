
select abc.Day, abc.DownVotes, abc.UpVotes, CAST(abc.UpVotes as float)/abc.DownVotes as UpVoteDownVoteRatio from
(
select Top 10
	DATENAME(WEEKDAY, p.CreationDate) AS Day,
    SUM(CASE WHEN VoteTypeId = 2 THEN 1 ELSE 0 END) AS UpVotes,
    SUM(CASE WHEN VoteTypeId = 3 THEN 1 ELSE 0 END) AS DownVotes
from Votes v inner join Posts p on v.PostId = p.Id
GROUP BY
    PostTypeId, DATEPART(WEEKDAY, p.CreationDate), DATENAME(WEEKDAY, p.CreationDate)
ORDER BY
    PostTypeId, DATEPART(WEEKDAY, p.CreationDate)
) abc


SELECT Top 10
    CASE WHEN PostTypeId = 1 THEN 'Question' ELSE 'Answer' END As [Post Type],
    DATENAME(WEEKDAY, p.CreationDate) AS Day,
    Count(*) AS Amount,
    SUM(CASE WHEN VoteTypeId = 2 THEN 1 ELSE 0 END) AS UpVotes,
    SUM(CASE WHEN VoteTypeId = 3 THEN 1 ELSE 0 END) AS DownVotes,
    CASE WHEN SUM(CASE WHEN VoteTypeId = 3 THEN 1 ELSE 0 END) = 0 THEN NULL
     ELSE (CAST(SUM(CASE WHEN VoteTypeId = 2 THEN 1 ELSE 0 END) AS float) / CAST(SUM(CASE WHEN VoteTypeId = 3 THEN 1 ELSE 0 END) AS float))
    END AS UpVoteDownVoteRatio
FROM
    Votes v JOIN Posts p ON v.PostId=p.Id
WHERE
    PostTypeId In (1,2)
 AND
    VoteTypeId In (2,3)
GROUP BY
    PostTypeId, DATEPART(WEEKDAY, p.CreationDate), DATENAME(WEEKDAY, p.CreationDate)
ORDER BY
    PostTypeId, DATEPART(WEEKDAY, p.CreationDate)

/*
SET STATISTICS IO ON
dropindexes
*/


create index PostTypeId_CreationDate
on dbo.Posts(PostTypeId, CreationDate)
with (maxdop=0, online = off);


create index VoteTypeId
on dbo.Votes(VoteTypeId)
include (PostId)
with (maxdop = 0, online = off, drop_existing = on);



