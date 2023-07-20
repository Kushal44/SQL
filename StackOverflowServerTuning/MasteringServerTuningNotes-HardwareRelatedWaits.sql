/*
1. WRITELOG - SQL server having hard time log entires to disk. Look at avg. ms wait for this wait statistics.
It tells how long transaction are being held up by storage. Use sp_BlitzFirst @SinceStartup = 1. 
If it's 100 ms or more then there is problem.
Microsoft reminds keep it less than 3 ms. Brent recommends less than 30 ms.
SOLUTION - 1. Don't store file, big blog in database. This keeps transaction log relatively small.
		 2. Delayed Durability - transaction committed before they hit the log. 
				This can cause loss of data.
		3. Use Solid State Drive.	
2. HADR_SYNC_COMMIT - HADR stands for Hight Availability Disaster Recovery
	Only seen on Always On Availability Groups in synchronous commit mode.
	Only affects data modifictions, not select.
	Check wait time for transaction.
SOLUTION -
	1. Switch to async
	2. Check waits on the sync secondaries.
	3. Check network latency bewteen replicas (use iSCSI wire)
3. ASYNC_NETWORK_IO - This is not network related wait stats which is weird.
It happens slow client machine consuming the data from SQL.
For every row received from SQL client is doing some operation.
It is not a database problem.

	SOLUTION:
	Run sp_WhoIsActive
	20
	Find the query showing ASYNC_NETWORK_IO. Check how client application is consuming that data from SQL server.

*/