-- PART I: SCHOOL ANALYSIS
-- 1. View the schools and school details tables
select * from schools;
select * from school_details;

-- 2. In each decade, how many schools were there that produced players?
select round(s.yearID, -1) AS decade, count(distinct s.schoolID) as num_school
from schools s left join school_details sd on s.schoolID = sd.schoolID
group by decade;

-- 3. What are the names of the top 5 schools that produced the most players?
select sd.name_full, count(distinct playerID) as player_count
from schools s left join school_details sd on s.schoolID = sd.schoolID
group by s.schoolID
order by player_count desc
limit 5;

-- 4. For each decade, what were the names of the top 3 schools that produced the most players?
with t as 	(select round(s.yearID, -1) AS decade, sd.name_full, count(distinct s.playerID) as player_count
        			from schools s left join school_details sd on s.schoolID = sd.schoolID
        			group by decade, s.schoolID),

	    t2 as	(select decade, name_full, player_count,
					row_number() over(partition by decade order by player_count desc) as row_num
			from t)
select decade, name_full, player_count
from t2
where row_num <= 3
order by decade desc, row_num;


-- PART II: SALARY ANALYSIS
-- 1. View the salaries table

select *
from salaries;

-- 2. Return the top 20% of teams in terms of average annual spending
with t as	(select teamID, yearID, sum(salary) as total_spend	
			 from salaries
			 group by teamID,yearID),
                
	t2	as(select teamID, avg(total_spend) as avg_spent,
				ntile(5) over(order by avg(total_spend) desc) as spent_pct
				from t
				group by teamID)

select teamID, round(avg_spent/1000000, 1) avg_spent_million
from t2
where spent_pct = 1;

-- 3. For each team, show the cumulative sum of spending over the years
with t as (	select teamID, yearID, sum(salary) as total_spent
      			from salaries
      			group by teamID, yearID)
            
select teamID, yearID,
	round(sum(total_spent) over (partition by teamID order by yearID)/1000000, 1) AS cumulative_sum_millions
from t
order by teamID, yearID;

-- 4. Return the first year that each team's cumulative spending surpassed 1 billion
with t as (	select teamID, yearID, sum(salary) as total_spent
      			from salaries
      			group by teamID, yearID),
            
	t2 as (	select teamID, yearID,
				sum(total_spent) over (partition by teamID order by yearID) AS cumulative_sum
			  from t),

	t3 as	(select teamID, yearID, cumulative_sum,
					row_number() OVER(partition by teamID ORDER BY yearID) AS RN
    			from t2
    			where cumulative_sum >= 1000000000)

select teamID, yearID, ROUND(cumulative_sum /1000000000, 2) as cumulative_sum_millions
from t3
where RN = 1;

-- PART III: PLAYER CAREER ANALYSIS
-- 1. View the players table and find the number of players in the table
select count(*) as count_players from players;

select birthYear, nameGIVEN, debut, finalGame
from players;

select *
from players
;

-- 2. For each player, calculate their age at their first game, their last game, 
--    and their career length (all in years). Sort from longest career to shortest career.
select nameGIVEN,
		timestampdiff(year, cast(concat( birthYear,"-", birthMonth, "-" ,birthDay ) as date), debut) as starting_age,
        timestampdiff(year, cast(concat( birthYear,"-", birthMonth, "-" ,birthDay ) as date), finalGame) as end_age,
        timestampdiff(year, debut, finalGame) as carrer_length
from players
order by carrer_length desc;

-- 3. What team did each player play on for their starting and ending years?
select  p.nameGiven,
					s.yearID as starting_year, s.teamID as starting_team, 
          s2.yearID as ending_year, s2.teamID as ending_team
from players p
					inner join salaries s
					on p.playerID = s.playerID
					and year(p.debut) = s.yearID
                    	inner join salaries s2
					on p.playerID = s2.playerID
					and year(p.finalGame) = s2.yearID
where s.teamID = s2.teamID
		and s2.yearID - s.yearID > 10;


-- 4. How many players started and ended on the same team and also played for over a decade?
select *
from players;

select *
from salaries;

select  p.nameGiven,
					s.yearID as starting_year, s.teamID as starting_team, 
                    s2.yearID as ending_year, s2.teamID as ending_team
from players p
					inner join salaries s
					on p.playerID = s.playerID
					and year(p.debut) = s.yearID
                    	inner join salaries s2
					on p.playerID = s2.playerID
					and year(p.finalGame) = s2.yearID;
-- PART IV: PLAYER COMPARISON ANALYSIS
-- 1. View the players table
select *
from players;

-- 2. Which players have the same birthday?
with t as (	select p1.nameGIVEN,
					cast(concat( p1.birthYear,"-", p1.birthMonth, "-" ,p1.birthDay) as date) as birthday
			from players p1 inner join players p2
							on p1.playerID = p2.playerID)
select birthday, group_concat(nameGiven separator ", ") as players
from t
where year(birthday) between 1980 and 1990
group by birthday
order by birthday;

-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both
select s.teamID,
		round(sum(case when p.bats ="R" THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 1) as right_hand,
        round(sum(case when p.bats ="L" THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 1) as left_hand,
        round(sum(case when p.bats ="B" THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 1) as both_hands
from salaries s left join players p on p.playerID = s.playerID
group by s.teamID;
