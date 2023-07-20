/*
RESOURCE_SEMAPHORE - Poison Wait - SQL server run out of memory.
It needs query workspace memory to run a query. One query can grab 25% of total memory. 
SQL server allocates granted memory at starts of memory.
*/
/*
How SQL server calculate desired memory - Estimated No. of rows * (Sum of size of each column)/2 
*/

select top 250 *
from dbo.users
order by reputation desc 

/*
Use sp_WhoIsActive to see which are the query runnning having RESOURCE_SEMAPHORE.
Also use sp_BlitzCache @SortOrder = 'memory grant'  if the plan is in the cache. 
Unfortunately if there is memory pressure, cache is constantly rotating. 
SOLUTION - 1. Create index for this query. 
2, Select less columns, avoid select *, especially nvarachar(max) columns
3. Select less row, SQL server uses a different memory grant alogrithm for 100 or less rows.
At 101 or above memory grant is always same. (Sad Trombone)
4. Add memory in server. Adding memory covers lot of sins.
5. Resource Governor - Classify queries into groups. Control memory allocation by group.
*/