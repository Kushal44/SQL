SET STATISTICS IO, TIME ON;

exec dbo.usp_TopQuestionersByTag_Difficult_Pagination
@StartDate = '2010-01-10',
@EndDate = '2019-12-31',
@Tag = N'<javascript>'


/*Query modified with Pagination support
NOTE: Please note pagination didn'thelp fixing the difference between 
estimated number of rows vs actual
*/
create or alter proc dbo.usp_TopQuestionersByTag_Difficult_Pagination
	@Tag NVARCHAR(150),
	@StartDate Date,
	@EndDate Date,
	@PageNumber int = 1,
	@PageSize int = 100 as
begin

With RowsIWant as (

select year(q.CreationDate) as CreationYear,
	month(q.CreationDate) as CreationMonth,
	count(distinct q.id) as questions,
	count(distinct a.id) as answers,
	q.OwnerUserId,
	avg(q.Score) as QuestionAvgScore,
	avg(a.Score) as AnswerAvgScore

from dbo.Posts q
left outer join dbo.Posts a on q.Id = a.ParentId
where q.PostTypeId = 1
and q.Tags = @Tag
and q.CreationDate between @StartDate and @EndDate
group by year(q.CreationDate), month(q.CreationDate), q.OwnerUserId
order by year(q.CreationDate), month(q.CreationDate), count(distinct q.id) DESC
offset ((@PageNumber -1) * @PageSize) row
fetch next @PageSize rows only
)

select r.CreationYear,
	r.CreationMonth,
	uq.DisplayName as QuentionerDisplayName,
	uq.Id as QuestionerUserId,
	r.questions,
	r.answers,
	r.QuestionAvgScore,
	r.AnswerAvgScore

from RowsIWant r
inner join dbo.Users uQ on r.OwnerUserId = uQ.Id
order by r.CreationYear, r.CreationMonth, r.questions DESC

end

/* Index created for fixing the query */
create index PostTypeId_Tags_CreationDate_Filtered
	on dbo.Posts(Tags, CreationDate)
	include (OwnerUserId, Score, Id, PostTypeId)
	where PostTypeId = 1
	with (online = off, maxdop = 0);
GO

/*Original query without above index*/
create or alter proc dbo.usp_TopQuestionersByTag_Difficult
	@Tag NVARCHAR(150),
	@StartDate Date,
	@EndDate Date AS
begin
select year(q.CreationDate) as CreationYear,
	month(q.CreationDate) as CreationMonth,
	uq.DisplayName as QuentionerDisplayName,
	uq.Id as QuestionerUserId,
	count(distinct q.id) as questions,
	count(distinct q.id) as answers,
	avg(q.Score) as QuestionAvgScore,
	avg(a.Score) as AnswerAvgScore

from dbo.Posts q
inner join dbo.Users uQ on q.OwnerUserId = uQ.Id
left outer join dbo.Posts a on q.Id = a.ParentId
where q.PostTypeId = 1
and q.Tags = @Tag
and q.CreationDate between @StartDate and @EndDate
group by year(q.CreationDate), month(q.CreationDate), uq.DisplayName, uq.Id
order by year(q.CreationDate), month(q.CreationDate), count(distinct q.id) DESC

end