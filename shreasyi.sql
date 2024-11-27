create table matches ( 
id int,
country_id int, 
league_id int, 
season varchar(45), 
stage int, 
date varchar(45), 
match_api_id int, 
home_team_api_id int, 
away_team_api_id int, 
home_team_goal int, 
away_team_goal int 
); 


create table team ( 
id int, 
team_api_id int, 
team_fifa_api_id int, 
team_long_name varchar(200), 
team_short_name varchar(5) 
); 

create table country ( 
id int, 
name varchar(50) 
); 


create table league ( 
id int, 
country_id int, 
name varchar(200) 
); 



--- Primary keys 
alter table country add primary key(id); 
alter table league add primary key(id); 
alter table matches add primary key(match_api_id); 
alter table team add primary key(team_api_id); --- Foreign keys 
alter table league add foreign key(country_id) references country(id); 
alter table matches add foreign key(country_id) references 
country(id); 
alter table matches add foreign key(league_id) references league(id); 
alter table matches add foreign key(home_team_api_id) references 
team(team_api_id); 
alter table matches add foreign key(away_team_api_id) references 
team(team_api_id); 



---We created a smaller dataset using the following queries: 
create view country_limit as 
select * from country limit 5; 
create view league_limit as 
select * from league limit 5; 
create view matches_limit as 
select * from matches limit 5; 
create view team_limit as 
select * from team limit 5;

---check the tables 
select * from country 
limit 5;

select * from league 
limit 5;

select * from matches 
limit 5;

select * from team 
limit 5;


---List leagues and their associated country. 
select country.name as country_name, 
league.name as league_name from country  
join league on country.id=league.country_id;


---Extract country, league_name, season, stage, date, home_team,  away_team,goals, and team 
--names: 
select country.name as country_name,league.id as league_id, 
matches.season as season,matches.stage as stage,matches.date, 
HT.team_long_name as home_team_long_name, 
AT.team_long_name as away_team_long_name from country 
join league on country.id=league.country_id  
join matches on country.id=matches.country_id 
and league.id=matches.league_id 
left join team as HT 
on HT.team_api_id=matches.home_team_api_id 
left join team as AT 
on AT.team_api_id=matches.away_team_api_id; 



 ---Find the number of teams, average home team goals, average away team goals, 
---average goal difference, average total number of goals 
--- sum of the goals made by both the home and away team. 
--- w.r.t country and the league 
select country.name as country_name, 
league.name as league_name, 
count(HT.team_api_id) as no_of_teams, 
avg(matches.home_team_goal) as avg_home_team_goals, 
avg(matches.away_team_goal) as avg_away_team_goals, 
avg(matches.home_team_goal-matches.away_team_goal) as avg_goal_diff, 
avg(matches.home_team_goal+matches.away_team_goal) as avg_tot_goals, 
sum(matches.home_team_goal+matches.away_team_goal) as sum_of_goals 
from country 
join league on country.id=league.country_id 
join matches on matches.country_id=country.id 
and matches.league_id=league.id
left join team HT on HT.team_api_id=matches.home_team_api_id 
left join team AT on AT.team_api_id=matches.away_team_api_id 
group by country.name, league.name;


---Display the average number of goals the home team scored in all matches: 
select home_team_api_id, avg(home_team_goal) as avg_goal from matches 
group by home_team_api_id having avg(home_team_goal)>1;

---Compute the number of home goals a team has scored: 
create view home_team_goal_count as 
select matches.home_team_api_id,  team.team_long_name, 
sum(matches.home_team_goal) as goal_count 
from matches 
join team on 
matches.home_team_api_id=team.team_api_id 
group by matches.home_team_api_id, team.team_long_name 
having sum(matches.home_team_goal)>=2; 
select * from home_team_goal_count; 


---Compute the number of away goals a team has scored: 
create view away_team_goal_count as 
select matches.away_team_api_id,  team.team_long_name, 
sum(matches.away_team_goal) as goal_count 
from matches 
join team on matches.away_team_api_id=team.team_api_id 
group by matches.away_team_api_id, team.team_long_name 
having sum(matches.away_team_goal)>=2; 
select * from away_team_goal_count;


---q9 test your database ...
---1 insert a new league 
INSERT INTO league (id, country_id, name)
VALUES (101, 1, 'Premier League');
---2 insert a new match 
INSERT INTO matches (id, match_api_id, country_id, league_id, season, stage, date, home_team_api_id, away_team_api_id, home_team_goal, away_team_goal)
VALUES (5001, 600001, 1, 101, '2024/2025', 1, '2024-01-01', 9987, 9993, 3, 2);
---3 delete a league --- creating an error 
DELETE FROM league
WHERE id = 101;
---4  delete matches for a specific reason 
DELETE FROM matches
WHERE season = '2024/2025';
---4 update team name 
UPDATE team
SET team_long_name = 'New Genk FC'
WHERE team_api_id = 9987;
---4  update match goals 
UPDATE matches
SET home_team_goal = 5, away_team_goal = 4
WHERE match_api_id = 600001;

----select queris 
---join query -list league and associated countries
SELECT country.name AS country_name, league.name AS league_name
FROM country
JOIN league ON country.id = league.country_id;
---groupby query -avg goals per league 
SELECT league.name AS league_name, AVG(matches.home_team_goal + matches.away_team_goal) AS avg_goals
FROM league
JOIN matches ON league.id = matches.league_id
GROUP BY league.name
ORDER BY avg_goals DESC;

---subquery -teams with high goal difference 
SELECT team_long_name, team_api_id
FROM team
WHERE team_api_id IN (
    SELECT home_team_api_id
    FROM matches
    WHERE home_team_goal - away_team_goal > 3
);


----q10 u can use your own complex queries   take a complex query example lot of subqueries  , joins etc  so what will u do to epxlain t
---- after u go the query , you ogt this diagram , amalyse it and then stick the screeenshot 
--- d
---- take some complex queries . lots of joins put ne , they have to be new ones  
---- find what u  can  do to  reduce the  time to reduce the time of the querry 
---  look for ways to imprve it 
---as  well as the new improved query 
--- how much time that index is taking , 
SELECT league.name AS league_name, AVG(matches.home_team_goal + matches.away_team_goal) AS avg_goals
FROM league
JOIN matches ON league.id = matches.league_id
GROUP BY league.name;


---solution 
--add an index 
CREATE INDEX idx_matches_league_id ON matches(league_id);


----query 2 - teams with high goal difference 
SELECT team_long_name, team_api_id
FROM team
WHERE team_api_id IN (
    SELECT home_team_api_id
    FROM matches
    WHERE home_team_goal - away_team_goal > 3
);
--solution - optimization  -error
CREATE INDEX idx_matches_goals_diff ON matches(home_team_goal, away_team_goal);


---sorting without index 
SELECT match_api_id, home_team_goal, away_team_goal, (home_team_goal + away_team_goal) AS total_goals
FROM matches
ORDER BY total_goals DESC
LIMIT 5;

---soln  -error 
CREATE INDEX idx_matches_total_goals ON matches((home_team_goal + away_team_goal));



---order by query  - top 5 matches by goals scored 
SELECT match_api_id, home_team_goal, away_team_goal, (home_team_goal + away_team_goal) AS total_goals
FROM matches
ORDER BY total_goals DESC
LIMIT 5;


---- sql dump   .datasets  - ---zip folder   