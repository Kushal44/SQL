create or alter proc dbo.usp_ActivityByLocation_KR
	@LocationList NVARCHAR(MAX),
	@PageNumber INT = 1, @PageSize INT = 100 AS
BEGIN
/*Create a temp table to get locations from a string instead of parsing as a sub query*/
create table #Locations(Location NVARCHAR(200) PRIMARY KEY CLUSTERED)
insert into #Locations
	select TRIM(value) from STRING_SPLIT(@LocationList, '|');

/*Create temp table for Users. This help to improve the estimation of 
execution plan because now number of users are know to "RowsIWant" query.
Also NOTE: Because temp table is filled with lots of users when 
executing the stored procedure for 'India' location in comparison to
'Antartica' location, so the statistics are updated for temp table. 
This avoid statistics reuse because more than (20% + 500) rows are added or deleted
*/

create table #Users (UserId INT PRIMARY KEY CLUSTERED)
INSERT INTO #Users (UserId)
	select Id
	from #Locations ll
	inner join dbo.Users u on ll.Location = u.Location;


WITH RowsIWant AS (
select u.UserId UserId, p.Id AS PostId, p.PostTypeId
	from  
	#Users u 
	inner join dbo.Posts p on u.UserId = p.OwnerUserId
	order by p.CreationDate
	OFFSET ((@PageNumber - 1) * @PageSize) ROW
				FETCH NEXT(@PageSize) ROWS ONLY
)


select u.DisplayName, u.Id as UserId, pt.Type as PostYpe, p.Id as PostId,
		p.Title, p.Tags, p.Score, p.CreationDate, p.Body
	from RowsIWant r
	inner join dbo.Users u on r.UserId = u.Id
	inner join dbo.Posts p on r.PostId = p.Id
	inner join dbo.PostTypes pt on p.PostTypeId = pt.Id
	order by p.CreationDate
	
END
GO
DROP index OwnerUserId on dbo.Posts
CREATE index OwnerUserId on dbo.Posts(OwnerUserId, CreationDate)
	with (online = off, maxdop =0);
create index Location_DisplayName on dbo.Users(Location, DisplayName)
	with (online = off, maxdop =0);



/*Executing with two different types of parameters, 
Antartica has very few users, India has lots.  */
SET STATISTICS IO ON
EXEC dbo.usp_ActivityByLocation_KR N'Antartica'
EXEC dbo.usp_ActivityByLocation_KR N'India'