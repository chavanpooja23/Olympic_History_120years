select * from athletes;
select * from athlete_events;

--=============================================================================================

--1. which team has won the maximum gold medals over the years.

--=============================================================================================

select top 1 a.team as max_medal_team, count(distinct event) as gold_medal
from athletes a
inner join athlete_events ae on a.id = ae.athlete_id
where ae.medal = 'Gold'
group by a.team
order by gold_medal desc

--=============================================================================================

--2. for each team print total silver medals and year in which they won maximum silver medal.
--print 3 columns team,total_silver_medals, year_of_max_silver.

--=============================================================================================

with cte as
(
	select a.team as all_teams, ae.year as yr, count(distinct event) as silver_medal,
	rank() over(partition by team order by count(distinct event) desc) as rnk
	from athletes a
	inner join athlete_events ae on a.id = ae.athlete_id
	where ae.medal = 'Silver'
	group by a.team , ae.year
)

select all_teams, 
max(case when rnk = 1 then yr end), 
sum(silver_medal) as total_silver_medal 
from cte
group by all_teams

--=============================================================================================

--3. which player has won maximum gold medals amongst the players 
--which have won only gold medal (never won silver or bronze) over the years

--=============================================================================================

select top 1 a.name, count(*) as gold_medal
from athletes a
inner join athlete_events ae on a.id = ae.athlete_id
	and a.id not in 
	(
		select distinct ae.athlete_id 
		from athlete_events ae 
		where ae.medal <> 'Gold'
	)
group by a.name
order by count(*) desc

--=============================================================================================

--4. in each year which player has won maximum gold medal. 
--print year,player name and no of golds won in that year. 
--In case of a tie print comma separated player names.

--=============================================================================================

with cte as
(
	select a.name as athlete_name, ae.year as yr, count(*) as gold_medal,
		dense_rank() over(partition by  ae.year order by count(*)desc) as rnk
	from athletes a
	inner join athlete_events ae on a.id = ae.athlete_id
	where ae.medal = 'Gold'
	group by a.name, ae.year
)

select yr, gold_medal, STRING_AGG(athlete_name, ', ') as athlete_name 
from cte 
where rnk = 1
group by yr, gold_medal
 
--=============================================================================================

--5. in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

with cte as
(
	select distinct ae.event as olympic_event, ae.year, ae.medal,
		rank() over(partition by medal order by ae.year) as rnk
	from athletes a
	inner join athlete_events ae on a.id = ae.athlete_id
	where ae.medal <> 'NA'
		and a.team = 'India'
)

select olympic_event, year, medal 
from cte 
where rnk = 1

--=============================================================================================

--6. find players who won gold medal in summer and winter olympics both.

--=============================================================================================

select a.name 
from athletes a
inner join athlete_events ae on a.id = ae.athlete_id
where ae.medal = 'Gold'
group by a.name 
having count(distinct season) = 2

--=============================================================================================

--7. find players who won gold, silver and bronze medal in a single olympics. 
--print player name along with year.

--=============================================================================================

select distinct a.name, ae.year 
from athletes a
inner join athlete_events ae on a.id = ae.athlete_id
where ae.medal <> 'NA'
group by a.name, ae.year
having count(distinct medal) = 3

--=============================================================================================

--8. find players who have won gold medals in consecutive 3 summer olympics in the same event . 
--Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.

--=============================================================================================

with cte as 
(
	select a.name as player_name, ae.year as yr, ae.event as olympic_event,
		lag(ae.year, 1) over(partition by a.name, ae.event order by ae.year ) as prev_year,
		lead(ae.year, 1) over(partition by a.name, ae.event order by ae.year ) as next_year
	from athletes a
	inner join athlete_events ae on a.id = ae.athlete_id
	where ae.medal = 'Gold' 
		and ae.year >= 2000 
		and ae.season = 'Summer'
	group by a.name, ae.year, ae.event 
)

select player_name, olympic_event 
from cte
where yr=prev_year+4 
	and yr=next_year-4

--=============================================================================================
