use StackOverflow2013
go

set statistics io, time on;
go



create or alter proc dbo.usp_FindRelatedPosts @PostId int as
begin
	select *, 
		CommentCount = (select count(*) from dbo.Comments where PostId = pwr.Id)
	from dbo.PostsWithRelatives pwr
	where pwr.OriginalPostId = @PostId
	order by pwr.LastActivityDate desc
end
go

create or alter view dbo.PostsWithRelatives as
	select p.Id as OriginalPostId, pRelatives.*
	from
	dbo.Posts p
	cross apply dbo.RelatedPosts_ITVF(p.Id) rp
	inner join dbo.Posts pRelatives on rp.PostId = pRelatives.Id
GO

/*
this is multi statement table value function. This is causing the plan to got Single threaded.
And estimations are also wrong.
So to fix this, we need to convert it into Inline table value function
*/
create or alter function dbo.RelatedPosts(@PostId int)
Returns @Out Table (PostId BIGINT)
AS
BEGIN
	insert into @Out(PostId)
		select top 10 pRelative.Id
		from dbo.PostLinks pl
		inner join dbo.Posts pRelative on pl.RelatedPostId = pRelative.Id
		where pl.LinkTypeId = 1 and pRelative.PostTypeId = 1
		order by pl.CreationDate DESC
	return;
END

/*
Here is the Inline Table Value Function
*/
create or alter function dbo.RelatedPosts_ITVF(@PostId int)
Returns Table
AS
RETURN
		select top 10 pRelative.Id as PostId
		from dbo.PostLinks pl
		inner join dbo.Posts pRelative on pl.RelatedPostId = pRelative.Id
		where pl.LinkTypeId = 1 and pRelative.PostTypeId = 1
		and pl.PostId = @PostId
		order by pl.CreationDate DESC

create index PostId_LinkTypeId_CreationDate_Includes 
on dbo.PostLinks(PostId, LinkTypeId, CreationDate) include (RelatedPostId)

create index PostId on dbo.Comments(PostId)
with (maxdop = 0, online = off); 

exec dbo.usp_FindRelatedPosts 3737139 WITH RECOMPILE
go

/**/
select Top 100 PostId, Count(*)
from dbo.PostLinks
where LinkTypeId = 1
group by PostId
order by Count(*) desc;

