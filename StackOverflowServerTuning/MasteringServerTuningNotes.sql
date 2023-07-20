use StackOverflow2013
go

--TODO: need to find the DMV for missing index recommendations
/*
1. PageIOLATCH - this means that SQL needs to read lot of 8K pages from disk to memory
Solution -  Look for high value missing indexes for that.

2. SOS_SCHEDULER_YIELD - this means query has to yield for other queries. 
SQL has 4 milliseconds limit on one query using a CPU. After 4 milliseconds,
that query needs to give up that CPU. After 4 milliseconds, it is going to YIELD
CPU to some other query. Task has to cooperate and release the CPU after 4 milli seconds.
If the task doesn't, it results in non-yielding error. SQL OS eventually kills that task.
If the avg wait time to get the CPU back after yielding is high, 
then this wait type is issue. This is because there is a long line for that thread to get CPU back.
Look for :
	2.1 sys.dm_os_scheduler
	2.3 sys.dm_os_workers

	2.4 Common Cause
	1. Other processes using CPU
	2. Query using lot of CPU - If server is bottleneck on CPU, logical reads are not most relevant.
	use sp_BlitzCache @SortOrder = 'cpu'
		Examples:
		1. string processing like UPPER, LTRIM, RTRIM. This makes WHERE clause non-sargable.
		This results in query reading lot of records and 8K pages.
		2. Row by row processing - This happens when Scalar or multi statement table value functions
		are used. Try inlining as shown in Mastering Query Tuning.
		3. GROUP BY or DISTINCT for a string based cloumn.
		4. ORDER BY -  If the query doesn't have TOP in it, do the ordering in application layer.
		5. Heaps - They are table without clustered indexes. Their Forward Fetching can cause SOS_SCHEDULER_YIELD.
		5. Implicit Conversion - Make sure all parameters have same data type as columns in table
	3. Upgrade to better CPU - http://ec2instances.info, http://azure-instances.info

NOTES: 
1. When you create index on the table, all missing index recommendation 
for that table disappear.
2. SQL has 4 milliseconds limit on one query using a CPU. After 4 milliseconds,
that query needs to give up that CPU. After 4 milliseconds, it is going to YIELD
CPU to some other query. Task has to cooperate and release the CPU after 4 milli seconds.
If the task doesn't, it results in non-yielding error. SQL OS eventually kills that task.





http://brenozar.com/go/progress
this shows the index creation progress
*/