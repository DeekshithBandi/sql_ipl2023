
-- create the table in the database

SET XACT_ABORT ON

BEGIN TRANSACTION QUICKDBD

CREATE TABLE [ipl_matches] (
    [match_no] int  NOT NULL ,
    [city] varchar(50)  NOT NULL ,
    [date_of_match] date  NOT NULL ,
    [venue] varchar(100)  NOT NULL ,
    [Home_team] varchar(100)  NOT NULL ,
    [Awayteam] varchar(100)  NOT NULL ,
    [toss_winner] varchar(100)  NOT NULL ,
    [winner] varchar(100)  NOT NULL ,
    [man_of_the_match] varchar(100)  NOT NULL ,
    [result] varchar(20)  NOT NULL ,
    [result_margin] int  NOT NULL ,
    [eliminator] varchar(5)  NOT NULL ,
    [umpire1] varchar(50)  NOT NULL ,
    [umpire2] varchar(50)  NOT NULL ,
    CONSTRAINT [PK_ipl_matches] PRIMARY KEY CLUSTERED (
        [match_no] ASC
    )
)

CREATE TABLE [ipl_match_scorecard] (
    [match_no] int  NOT NULL ,
    [Home_team_run] int  NOT NULL ,
    [Home_team_wickets] int  NOT NULL ,
    [Home_team_over] decimal(3,1)  NOT NULL ,
    [Away_team_run] int  NOT NULL ,
    [Away_team_wickets] int  NOT NULL ,
    [Away_team_over] decimal(3,1)  NOT NULL ,
    CONSTRAINT [PK_ipl_match_scorecard] PRIMARY KEY CLUSTERED (
        [match_no] ASC
    )
)

CREATE TABLE [ipl2023_batsman] (
    [match_no] int  NOT NULL ,
    [Batsman] varchar(50)  NOT NULL ,
    [team] varchar(50)  NOT NULL ,
    [Run] int  NOT NULL ,
    [Ball] int  NOT NULL ,
    [4s] int  NOT NULL ,
    [6s] int  NOT NULL ,
    [out_by] varchar(50)  NOT NULL ,
    CONSTRAINT [PK_ipl2023_batsman] PRIMARY KEY CLUSTERED (
        [match_no] ASC
    )
)

CREATE TABLE [ipl2023_bowler] (
    [match_no] int  NOT NULL ,
    [Bowler] varchar(50)  NOT NULL ,
    [team] varchar(50)  NOT NULL ,
    [over] decimal(2,1)  NOT NULL ,
    [run] int  NOT NULL ,
    [wicket] int  NOT NULL ,
    [No_ball] int  NOT NULL ,
    [ECO] decimal(3,1)  NOT NULL ,
    CONSTRAINT [PK_ipl2023_bowler] PRIMARY KEY CLUSTERED (
        [match_no] ASC
    )
)

ALTER TABLE [ipl_match_scorecard] WITH CHECK ADD CONSTRAINT [FK_ipl_match_scorecard_match_no] FOREIGN KEY([match_no])
REFERENCES [ipl_matches] ([match_no])

ALTER TABLE [ipl_match_scorecard] CHECK CONSTRAINT [FK_ipl_match_scorecard_match_no]

ALTER TABLE [ipl2023_batsman] WITH CHECK ADD CONSTRAINT [FK_ipl2023_batsman_match_no] FOREIGN KEY([match_no])
REFERENCES [ipl_matches] ([match_no])

ALTER TABLE [ipl2023_batsman] CHECK CONSTRAINT [FK_ipl2023_batsman_match_no]

ALTER TABLE [ipl2023_bowler] WITH CHECK ADD CONSTRAINT [FK_ipl2023_bowler_match_no] FOREIGN KEY([match_no])
REFERENCES [ipl_matches] ([match_no])

ALTER TABLE [ipl2023_bowler] CHECK CONSTRAINT [FK_ipl2023_bowler_match_no]

COMMIT TRANSACTION QUICKDBD





--to drop primary key from the table if the data doesnt have unique value it may give you the error

SELECT 
    tc.CONSTRAINT_NAME, 
    tc.TABLE_NAME, 
    kcu.COLUMN_NAME
FROM 
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tc
JOIN 
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS kcu
ON 
    tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE 
    tc.TABLE_NAME = 'ipl2023_batsman'
    AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

ALTER TABLE ipl2023_batsman
DROP CONSTRAINT PK_ipl2023_batsman;

SELECT name 
FROM sys.key_constraints 
WHERE type = 'PK' 
AND parent_object_id = OBJECT_ID('ipl2023_bowler');

SELECT 
    c.name AS constraint_name,
    t.name AS table_name,
    c.type_desc
FROM 
    sys.objects t
JOIN 
    sys.key_constraints c ON t.object_id = c.parent_object_id
WHERE 
    t.name = 'ipl2023_bowler';


ALTER TABLE ipl2023_bowler
DROP CONSTRAINT PK_ipl_2023_bowler;
SELECT 
    object_name(object_id) AS table_name,
    name AS constraint_name,
    type_desc
FROM 
    sys.objects
WHERE 
    type_desc LIKE '%CONSTRAINT%' 
    AND object_name(object_id) = 'ipl2023_bowler';
SELECT 
    i.name AS index_name,
    i.type_desc AS index_type
FROM 
    sys.indexes i
WHERE 
    i.object_id = OBJECT_ID('ipl2023_bowler');
ALTER TABLE ipl2023_bowler
DROP CONSTRAINT PK_ipl2023_bowler;

-- After importing data from the csv file check the data

SELECT * from ipl_matches;
SELECT * from ipl_match_scorecard;
SELECT * from ipl2023_batsman;
SELECT * from ipl2023_bowler;

--Which team won the most matches in IPL 2023?
SELECT winner, Count(*) as total_wins
from ipl_matches
group by winner
order by total_wins desc

-- What is the highest-scoring match of the season?
SELECT TOP 1
	match_no , Home_team_run+ Away_team_run as total_runs
from ipl_match_scorecard
Order by total_runs desc

--Which bowler took the most wickets in IPL 2023?
SELECT TOP 1 
       Bowler, 
       SUM(wicket) AS total_wickets
FROM ipl2023_bowler
GROUP BY Bowler
ORDER BY total_wickets DESC;

--Venue Analysis

--Which venue hosted the most matches?
SELECT TOP 1
	venue, count(*) as total_no_of_matches_hosted
FROM ipl_matches
group by venue
order by total_no_of_matches_hosted desc


--What is the average score of matches at each venue?
SELECT 
    m.venue, 
    AVG(s.Home_team_run + s.Away_team_run) AS avg_score
FROM ipl_matches m
INNER JOIN ipl_match_scorecard s
    ON m.match_no = s.match_no
GROUP BY m.venue
ORDER by avg_score desc

-- Batsman Performance
--Top Performers

--List the top 10 batsmen with the highest strike rates (minimum 100 runs).
SELECT TOP 10
       Batsman, 
       SUM(Run) AS total_runs,
       SUM(Ball) AS total_balls,
       CAST(SUM(Run) * 100.0 / SUM(Ball) AS DECIMAL(10, 2)) AS strike_rate
FROM ipl2023_batsman
GROUP BY Batsman
HAVING SUM(Run) >= 100
ORDER BY strike_rate DESC;



--Identify batsmen with the most 50+ scores in the season.
SELECT TOP 1
	Batsman,
	count(*) as MOST_FIFTIES
from ipl2023_batsman
where Run >= 50
group by Batsman
ORDER by MOST_FIFTIES DESC;

--Consistency

--Which batsman had the highest average runs per match?
SELECT Top 1
	Batsman,
	avg(Run) as average_runs
from ipl2023_batsman
group by Batsman
Order by average_runs DESC;

--Find the batsman who scored the most runs against a specific team (e.g., Mumbai Indians).
SELECT Batsman,
	SUM(Run) as total_runs
from ipl2023_batsman
inner join ipl_matches
	on ipl2023_batsman.match_no = ipl_matches.match_no
WHERE Home_team = 'Sunrisers Hyderabad' or Awayteam = 'Sunrisers Hyderabad' and team != 'Sunrisers Hyderabad'
Group by Batsman
Order by total_runs DESC;

-- Top Bowlers

--Which bowler had the best economy rate (minimum 10 overs bowled)?
SELECT 
	Bowler,
	Avg(ECO) as best_economy
FROM ipl2023_bowler
where [over] >= 1
group by Bowler
order by best_economy ;

-- Match-Winning Performances

--Which bowler had the best bowling figures in a single match?
SELECT TOP 1
       Bowler,
       run AS runs_conceded,
       wicket AS wickets_taken
FROM ipl2023_bowler
ORDER BY wicket DESC, run ASC;


--List bowlers with the most 4-wicket or 5-wicket hauls.
SELECT Bowler,
	count(*) as total_wicket_hauls
from ipl2023_bowler
where [wicket] >= 4
group by Bowler
order by total_wicket_hauls desc;
 
-- Consistency

--Identify bowlers with the highest average wickets per match.
SELECT TOP 1
	Bowler,
	AVG(wicket) as avg_wickets
FROM ipl2023_bowler
group by Bowler
order by avg_wickets desc;

--Which bowler conceded the least runs against a specific team (e.g., Chennai Super Kings)?
SELECT Top 1
	Bowler,
	sum(Run) as run_conceded
FROM ipl2023_bowler
INNER JOIN ipl_matches ON ipl_matches.match_no = ipl2023_bowler.match_no
WHERE (Home_team = 'Sunrisers Hyderabad' or Awayteam = 'Sunrisers Hyderabad' )
	and team != 'Sunrisers Hyderabad'
GROUP BY Bowler
ORDER BY run_conceded ASC;

--Match Highlights

--What is the largest margin of victory by runs in IPL 2023?
SELECT TOP 1
	match_no , result, result_margin
FROM ipl_matches
where result='Runs'
Order by result_margin desc;


--Which match had the closest margin of victory by wickets?
SELECT TOP 1
	match_no, result, result_margin
FROM ipl_matches
where result = 'Wickets'
ORDER BY result_margin;

--Team Performance

--Which team had the highest average score per match?
SELECT 
       team_name,
       AVG(total_runs) AS avg_runs
FROM (
         SELECT m.Home_team AS team_name, s.Home_team_run AS total_runs
         FROM ipl_match_scorecard s
         INNER JOIN ipl_matches m ON s.match_no = m.match_no
         UNION ALL
         SELECT m.Awayteam AS team_name, s.Away_team_run AS total_runs
         FROM ipl_match_scorecard s
         INNER JOIN ipl_matches m ON s.match_no = m.match_no
     ) AS combined_scores
GROUP BY team_name
ORDER BY avg_runs DESC;


--Find the team with the most wins while chasing.
SELECT winner, COUNT(*) as wins_chasing
From ipl_matches
where [result] = 'Wickets'
Group By winner
Order By wins_chasing desc

--Comparative Analysis

--Compare the performance of batsmen in home vs. away matches.
SELECT Batsman,
       SUM(CASE WHEN team = m.home_team THEN Run ELSE 0 END) AS home_runs,
       SUM(CASE WHEN team = m.Awayteam THEN Run ELSE 0 END) AS away_runs
FROM ipl2023_batsman b
INNER JOIN ipl_matches m ON b.match_no = m.match_no
GROUP BY Batsman
ORDER BY home_runs DESC, away_runs DESC;

--Find the top-performing bowlers in home vs. away matches.
SELECT Bowler,
	SUM(CASE WHEN team = m.home_team then wicket ELSE 0 END) as home_wickets,
	SUM(CASE WHEN team = m.Awayteam THEN wicket Else 0 END) as away_wickets
FROM ipl2023_bowler b
INNER JOIN ipl_matches m on m.match_no = b.match_no
GROUP BY Bowler
ORDER BY home_wickets DESC, away_wickets DESC;

--Player Impact

--Determine which players contributed the most to their team's wins (by runs/wickets).
-- Batsmen's Contribution to Wins
SELECT b.Batsman AS Player,
       SUM(b.Run) AS total_runs_in_wins
FROM ipl2023_batsman b
INNER JOIN ipl_matches m ON b.match_no = m.match_no
WHERE b.team = m.winner
GROUP BY b.Batsman
ORDER BY total_runs_in_wins DESC;

-- Bowlers' Contribution to Wins
SELECT bo.Bowler AS Player,
       SUM(bo.wicket) AS total_wickets_in_wins
FROM ipl2023_bowler bo
INNER JOIN ipl_matches m ON bo.match_no = m.match_no
WHERE bo.team = m.winner
GROUP BY bo.Bowler
ORDER BY total_wickets_in_wins DESC;


--Find players with the most "Player of the Match" awards.
SELECT Player, COUNT(*) AS no_of_MOM
FROM (
    SELECT b.Batsman AS Player
    FROM ipl2023_batsman b
    INNER JOIN ipl_matches m ON m.match_no = b.match_no
    WHERE b.Batsman = m.man_of_the_match

    UNION ALL

    SELECT c.Bowler AS Player
    FROM ipl2023_bowler c
    INNER JOIN ipl_matches m ON m.match_no = c.match_no
    WHERE c.Bowler = m.man_of_the_match
) AS combined
GROUP BY Player
ORDER BY no_of_MOM DESC;

--Strike Rate Trends of Batsmen Across Matches
SELECT 
    b.Batsman,
    b.match_no,
    SUM(b.run) AS total_runs,
    COUNT(b.Ball) AS total_balls,
    CAST(SUM(b.run) * 1.0 / COUNT(b.Ball) AS DECIMAL(5, 2)) AS strike_rate
FROM ipl2023_batsman b
GROUP BY b.Batsman, b.match_no
ORDER BY b.Batsman, b.match_no;

--. Identify the Most Impactful All-Rounder (Runs Scored + Wickets Taken)
SELECT 
    player_stats.Player,
    player_stats.total_runs,
    player_stats.total_wickets,
    (player_stats.total_runs + (player_stats.total_wickets * 25)) AS impact_score
FROM (
    SELECT 
        b.Batsman AS Player,
        SUM(b.Run) AS total_runs,
        COALESCE(w.total_wickets, 0) AS total_wickets
    FROM ipl2023_batsman b
    LEFT JOIN (
        SELECT 
            Bowler AS Player,
            SUM(wicket) AS total_wickets
        FROM ipl2023_bowler
        GROUP BY Bowler
    ) w ON b.Batsman = w.Player
    GROUP BY b.Batsman, w.total_wickets
) player_stats
ORDER BY impact_score DESC;

--Find Teams That Consistently Performed Well in Low-Scoring Matches
SELECT 
    m.winner AS team,
    COUNT(*) AS low_scoring_wins
FROM ipl_matches m
INNER JOIN ipl_match_scorecard s ON m.match_no = s.match_no
WHERE (s.Home_team_run + s.Away_team_run) < 300
GROUP BY m.winner
ORDER BY low_scoring_wins DESC;
--Rank players based on their performance in a specific match.
SELECT 
    player_stats.Player,
    player_stats.match_no,
    player_stats.batting_score,
    player_stats.bowling_score,
    (player_stats.batting_score + player_stats.bowling_score) AS total_score
FROM (
    -- Batting Performance
    SELECT 
        b.Batsman AS Player,
        b.match_no,
        SUM(b.Run) AS total_runs,
        (CAST(SUM(b.Run) AS FLOAT) * 1.5) / NULLIF(SUM(b.Ball), 0) AS strike_rate,
        (SUM(b.Run) * 2 + SUM(b.[4s]) * 4 + SUM(b.[6s]) * 6) AS batting_score,
        0 AS bowling_score
    FROM ipl2023_batsman b
    GROUP BY b.Batsman, b.match_no

    UNION ALL

    -- Bowling Performance
    SELECT 
        bowler.Bowler AS Player,
        bowler.match_no,
        0 AS total_runs,
        0 AS strike_rate,
        0 AS batting_score,
        (SUM(bowler.wicket) * 25 - SUM(bowler.run)) / NULLIF(SUM(bowler.[over]), 0) AS bowling_score
    FROM ipl2023_bowler bowler
    GROUP BY bowler.Bowler, bowler.match_no
) player_stats
WHERE player_stats.match_no = 5 -- Replace 5 with the desired match number
ORDER BY total_score DESC;





--Generate a leaderboard combining batting and bowling performance (weighted score based on metrics like runs, wickets, strike rate, and economy).
SELECT 
    player_stats.Player,
    SUM(player_stats.batting_score) AS total_batting_score,
    SUM(player_stats.bowling_score) AS total_bowling_score,
    SUM(player_stats.batting_score + player_stats.bowling_score) AS total_score
FROM (
    -- Batting Performance Subquery
    SELECT 
        b.Batsman AS Player,
        (SUM(b.Run) * 1.5 + SUM(b.[4s]) * 4 + SUM(b.[6s]) * 6) AS batting_score,
        0 AS bowling_score
    FROM ipl2023_batsman b
    GROUP BY b.Batsman

    UNION ALL

    -- Bowling Performance Subquery
    SELECT 
        bowler.Bowler AS Player,
        0 AS batting_score,
        (SUM(bowler.wicket) * 25 - SUM(bowler.run)) / NULLIF(SUM(bowler.[over]), 0) AS bowling_score
    FROM ipl2023_bowler bowler
    GROUP BY bowler.Bowler
) player_stats
GROUP BY player_stats.Player
ORDER BY total_score DESC;


