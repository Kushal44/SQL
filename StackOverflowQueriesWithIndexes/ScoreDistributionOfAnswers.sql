
CREATE OR ALTER PROC dbo.usp_Q9900 @UserId INT = 26837 AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/9900/distribution-of-scores-on-my-answers */
-- Distribution of scores on my answers
-- Shows how often a user's answers get a specific score. Related to http://odata.stackexchange.com/stackoverflow/q/1930

DECLARE @totalAnswers DECIMAL;
SELECT @totalAnswers = COUNT(*) FROM Posts WHERE PostTypeId = 2 AND OwnerUserId = @UserId;

SELECT Score AS AnswerScore, Occurences,
  CASE WHEN Frequency < 1 THEN '<1%' 
	  ELSE Cast(Cast(ROUND(Frequency, 0) AS INT) AS VARCHAR) + '%' END AS Frequency
FROM (
  SELECT Score, COUNT(*) AS Occurences, (COUNT(*) / @totalAnswers) * 100 AS Frequency
  FROM Posts
  WHERE PostTypeId = 2                 -- answers
    AND OwnerUserId = @UserId       -- by you
  GROUP BY Score
) AS answers
ORDER BY answers.Frequency DESC, Score;
END
GO

exec dbo.usp_Q9900 22656

create index OwnerUserId_PostTypeId
on dbo.Posts(OwnerUserId, PostTypeId)
include (Score)
with (maxdop =0 , online = off, drop_existing = off)

select *
from dbo.Users 
where DisplayName = 'Jon Skeet'