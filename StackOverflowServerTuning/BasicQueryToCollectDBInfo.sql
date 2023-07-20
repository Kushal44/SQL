
select * from msdb.dbo.backupfile

select sum(size)
from sys.database_files
where type = 0;

DBCC CHECKDB

/*
this one clears the cache having 8K pages of a table. 
It helps to test the performance of a query after tuning as 
a new starting point so that cache has no pages related 
to that table.
*/
DBCC DROPCLEANBUFFERS 