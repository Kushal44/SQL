CREATE OR ALTER PROC dbo.usp_Q40304 AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/40304/colorado-c-people */
select *
from Users
where --1=1
  --AND displayName like 'L%'
  --Location = 'BOULDER, CO'
  UPPER(Location) LIKE 'BOULDER, CO'
  AND AboutMe LIKE '%C#%'
ORDER BY Reputation DESC;
END
GO

/*Even with this index UPPER(Location) is non-sargable */
Create index Location on dbo.Users(Location)

DBCC SHOW_STATISTICS('dbo.Users', 'Location');