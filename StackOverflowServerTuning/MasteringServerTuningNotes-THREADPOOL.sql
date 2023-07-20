/*
THREADPOOL - This is a poision wait, which can kill the SQL server.
This happens when SQL runs out of worker threads to assign to a query.
Scenario: Let's say we have lots of queries running in parallel for 
select count(*) from dbo.users.
Meanwhile another query runs to update one dbo.users with BEGIN TRAN
it never calls COMMIT OR ROLLBACK.
So count(*) queries will keep waiting to transaction to finish, stay are waiting in worker queue (Right side queue in Brent Vidoes)
Eventually there will be a large number of worker threads waiting for transaction to finish that SQL runs
out of workder thread. This results in THREADPOOL waits.
NOTE: SSMS to other monitoring tools may not be able to connect to SQL server at that time.

SOLUTION: 
Use Dedicated Admin Connection. 
http://brentozar.com/go/dac
It is once CPU, with one worker thread to run one query at time.
*/


sp_configure 'remote admin connections', 1;

RECONFIGURE 

SELECT *
FROM sys.configurations
WHERE value <> value_in_use;
--RECONFIGURE

/*
KILL the query which has transaction open. Use sp_whoIsActive.

*/

KILL 61

/*
Once that blocker is killed do following:
1. Change the query to commit the transaction to avoid blocking.
2. Increase the value for Cost Threshold for Parallellism so that the select count(*) 
doesn't go parallel.
3. MAXDOP 1 kinda fix it because less worker threads are created. 
It is only short term emergency fix. Queries will run slower but will run.
4. Add an index for count(*) query so that it runs fast. 
It will read from the copy created by not clustered index instead of scanning clustered index.
5. CREATE NONCLUSTERED COLUMNSTORE INDEX - This is faster for count(*) queries.
*/

