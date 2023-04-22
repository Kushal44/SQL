/*
Find the accepted answer percentage 
https://data.stackexchange.com/stackoverflow/query/949/what-is-my-accepted-answer-percentage-rate
*/

/*
Using the index on OwnerUserId and Accepted Answer Id
logical reads 1809
*/

SET STATISTICS IO ON

SELECT 
    (CAST(Count(a.Id) AS float) / 
	(SELECT Count(*) FROM Posts WHERE OwnerUserId = 26837 AND PostTypeId = 2) * 100) AS AcceptedPercentage
FROM
    Posts q
  INNER JOIN
    Posts a ON q.AcceptedAnswerId = a.Id
WHERE
    a.OwnerUserId = 26837
  AND
    a.PostTypeId = 2

