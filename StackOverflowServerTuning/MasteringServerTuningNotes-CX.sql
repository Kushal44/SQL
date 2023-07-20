/*
CXCONSUMER and CXPACKET - This is an indication that queries are running parallel and paralleslism is unbalanced. 
It can be a good thing or bad thing.
CXCONSUMER - This tells about the waits of Thread 0, which is coordinating thread. 
Supposed to ignore CXCONSUMER but as per Brent experience this is not harmless. 
It is a bug by Microsoft.
CXPACKET -  This tells about the waits of Thread 1  ot n, i.e. child threads waiting
on each othere to finish.
Parallelism - There are two parameters - 
	1. Cost Threshold For Parallelism - If Serial plan cost is higher than CTFP, plan goes parallel.
	2. Max Degree Of Parallelism - Whatever MAXDOP is, that how parallel query can go. 
	It only controls how many cores a query uses. It doesn't control how many threads query can run.

Good defaults for these parameters:
CTFP -  30-100 - Settings to higher value cause a query doing lots to work to go single threaded 
MAXDOP - Read https://support.microsoft.com/kb/2806535
It should be high enough to get work done but not dominate the server.

There are following blockers for parallelism
http://brentozar.com/go/serialudf
1. Scalar Function
2. Table variables
3. TOP
4. Sequence Operators
5. Backwards Scan
*/

---------------------------------------------------------------------------------

/*

Another reason for high CPU usage showing CXCONSUMER, CXPACKET & SOS_SCHEDULER_YIELD is 
having multiple plans for same query. This happens because of
1. Hardcoded string in the query
2. Dynamic SQL not having parameters but string contactination
This results in creating new plan for every new parameter passed and SQL has to create and compile the
execution plan everytime.
*/