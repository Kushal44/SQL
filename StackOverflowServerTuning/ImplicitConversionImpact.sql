use StackOverflow2013
go


create or alter proc dbo.usp_GetUsersByLocation
	@Location VARCHAR(100) = '%Iceland%' as
begin
	select * from dbo.Users
	where Location like @Location
	order by DisplayName;
end

/*
SP has to do implicit conversion 
because parameter is varchar but the table column is NVARCHAR
NOTE: Sometimes SQL server doesn't show the flag despute implicit conversion
*/

exec dbo.usp_GetUsersByLocation
go




