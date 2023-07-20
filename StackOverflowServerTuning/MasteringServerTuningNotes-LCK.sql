/*
LCK% wait stats indicate that the thread is waiting to acquire a lock on shared resource.
Solutions are:
1. Have enough indexes to make your queries fast, but not so many that they slow down DUIs,
making them hold more locks for longer times.
2. Tune your transaction code. Working through the tables in same order everytime. 
Like parent and then child.
3. Look for long running queries with low CPU

4. Use the right isolation level for app's need. 
	1. RCSI - Read committed SnapShot Isolation - This is set at database level to have readable replicas at tempdb level.
	2. SI - Sanpshot Isolation - Setting this requries enabling readable replics in temp db for each query.

NOTE: When LCK% waits are addressed, more queries start running in parallel. 
This results in more usage of CPU and memory. 
This results in increase in PAGE_IO_LATCH and SOS_SCHEDULER_YIELD waits but LCK% waits go down.
Also Batch req per seconds should increase. You can monitor that using PerfMon.
*/
use StackOverflow2013
go

create or alter proc dbo.cpu_intensive
@tags nvarchar(50) = N'%<mysql>%'
as
begin

select * from
dbo.Posts
where Tags like @tags

end

exec dbo.cpu_intensive
go 5

