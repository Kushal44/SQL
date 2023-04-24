-- Users by Popular Question ratio
-- (only users with at least 10 Popular Questions)

select top 20
  Users.Id as [User Link],
  BadgeCount as [Popular Questions],
  QuestionCount as [Total Questions],
  CONVERT(float, BadgeCount)/QuestionCount as [Ratio]
from Users
inner join (
  -- Popular Question badges for each user
  select
    UserId,
    count(Id) as BadgeCount
  from Badges
  where Name = 'Popular Question'
  group by UserId
) as Pop on Users.Id = Pop.UserId
inner join (
  -- Questions by each user
  select
    OwnerUserId,
    count(Id) as QuestionCount
  from posts
  where PostTypeId = 1
  group by OwnerUserId
) as Q on Users.Id = Q.OwnerUserId
where BadgeCount >= 10
order by [Ratio] desc;

select top 20 r.UserId, 
	 r.[Popular Question Count], 
	 r.[Total Questions],
	 CONVERT(float, r.[Popular Question Count])/r.[Total Questions] as [Ratio]
from 
Users
inner join
(
select u.id as UserId, count(b.Id) as [Popular Question Count],
(
	select count(p.Id) as [Total Questions]
	from Posts p 
	where PostTypeId = 1 and OwnerUserId = u.Id
	group by OwnerUserId
) as [Total Questions]
from dbo.Users u inner join dbo.Badges b
on u.Id = b.UserId
where b.Name = 'Popular Question' --and --u.Id = 329637
group by u.Id
) as r on Users.Id = r.UserId
where r.[Popular Question Count] >= 10
order by [Ratio] desc


