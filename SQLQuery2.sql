--List all matches with their venue, date, and participating teams.
SELECT match_no,
date_of_match, 
Home_team,Awayteam, venue
FROM ipl_matches

--Retrieve matches where the margin of victory was greater than 50 runs or 5 wickets.
SELECT match_no,result, result_margin
from ipl_matches
where (result ='Wickets' AND result_margin > 5) or (result = 'Runs' AND result_margin > 50)
Order by result_margin desc;

--Player Statistics:

--Find the top 5 batsmen with the most runs in a single match.

SELECT TOP 5
	match_no,
	Batsman,
	Run
From ipl2023_batsman
Order BY Run DESC;

--List all bowlers who have taken at least 3 wickets in a match.

SELECT match_no,
	Bowler,
	wicket
FROM ipl2023_bowler
WHERE wicket >= 3
Order by wicket desc;

--Team Performance:

--Find all matches won by a specific team (e.g., "Chennai Super Kings").

SELECT match_no,
	Home_team,
	Awayteam,
	winner
FROM ipl_matches
WHERE winner = 'Chennai Super Kings';

-- Display the win percentage of each team in the tournament
SELECT winner AS Team,
       COUNT(winner) AS Wins,
       (COUNT(winner) * 100.0) / 
       (
           SELECT COUNT(*) 
           FROM ipl_matches 
           WHERE Home_team = winner OR Awayteam = winner
       ) AS Win_Percentage
FROM ipl_matches
GROUP BY winner
ORDER BY Win_Percentage DESC;

--Aggregate Statistics:

-- Calculate the total runs scored by each team in the entire tournament
SELECT team,
       SUM(runs) AS total_runs
FROM (
    SELECT m.Home_team AS team, r.Home_team_run AS runs
    FROM ipl_matches m
    INNER JOIN ipl_match_scorecard r ON m.match_no = r.match_no
    UNION ALL
    SELECT m.Awayteam AS team, r.Away_team_run AS runs
    FROM ipl_matches m
    INNER JOIN ipl_match_scorecard r ON m.match_no = r.match_no
) AS combined_runs
GROUP BY team
ORDER BY total_runs DESC;


--Find the average economy rate of bowlers across all matches.
SELECT Bowler,
	AVG(ECO) as avg_economy
FROM ipl2023_bowler
where [over] > 2.0
GROUP BY Bowler
ORDER BY avg_economy ASC;

--Comparisons:

--Compare the performance of two teams (e.g., "Mumbai Indians" vs. "Delhi Capitals") based on runs scored, wickets taken, and matches won.
DECLARE @team1  VARCHAR(100) = 'Mumbai Indians'; -- Declaring the Variables
DECLARE @team2 VARCHAR(100) = 'Delhi Capitals';

WITH Team_Comparision AS( --Use a Common Table Expression (CTE) named Team_Comparison to prepare a temporary result set. 
	SELECT
		TEAM = CASE --A CASE statement determines whether the current match involves @team1 or @team2
			WHEN m.Home_team = @team1 OR m.Awayteam = @team1 THEN @team1
			WHEN m.Home_team = @team2 OR m.Awayteam = @team2 THEN @team2
			END,

		Runs = CASE --Calculate the runs scored by the team in each match.
			WHEN m.Home_team = @team1 THEN r.Home_team_run
			WHEN m.Awayteam = @team1 THEN r.Away_team_run
			WHEN m.Home_team = @team2 THEN r.Home_team_run
			WHEN m.Awayteam = @team2 THEN r.Away_team_run
			END,

		Wickets =CASE --Calculate the total wickets taken by the opposing team
			WHEN m.Home_team = @team1 THEN r.Home_team_wickets
			WHEN m.Awayteam = @team1 THEN r.Away_team_wickets
			WHEN m.Home_team = @team2 THEN r.Home_team_wickets
			WHEN m.Awayteam = @team2 THEN r.Away_team_wickets
			END,

		Wins = CASE --Determine whether the team won the match.
			WHEN m.winner = @team1 THEN 1
			WHEN m.winner = @team2 THEN 1
			ELSE 0
			END
	FROM ipl_matches m
	INNER JOIN ipl_match_scorecard r ON r.match_no = m.match_no
	WHERE m.Home_team IN (@team1, @team2) or m.Awayteam in (@team1,@team2)
)

SELECT TEAM,
	SUM(Runs) as Total_runs,
	SUM(Wickets) as Total_Wickets,
	SUM(Wins) as Total_Wins

FROM Team_Comparision
GROUP BY TEAM
ORDER BY TEAM;


--Find the highest individual batting score and the player who achieved it.
SELECT TOP 1
	match_no,
	Batsman,
	Run
From ipl2023_batsman
Order by Run DESC;


--Filters with Joins:

--List all players who scored more than 50 runs and took at least one wicket in the same match.
SELECT b.match_no,
	b.Batsman,
	b.Run,
	bo.wicket
FROM ipl2023_batsman b
INNER JOIN ipl2023_bowler bo on b.match_no = bo.match_no
WHERE b.batsman = bo.Bowler and b.Run > 50 and bo.wicket >=1
Order by run desc;

-- 
--Retrieve all eliminator matches, showing the venue, participating teams, and winner.
SELECT 
    match_no,
    venue,
    Home_team AS Participating_Team_1,
    Awayteam AS Participating_Team_2,
    winner
FROM ipl_matches
WHERE eliminator = 'Yes';

-- Dynamic Rankings:

--Rank teams based on their total points (2 points for a win) and net run rate.
WITH Team_Performance AS(
	SELECT Home_team AS Team,
		SUM(CASE WHEN m.Home_team = m.winner Then 2 ELSE 0 END) AS Points,
		SUM(r.Home_team_run- r.Away_team_run) * 1.5/ COUNT(*) AS NRR
	FROM ipl_matches m
	INNER JOIN ipl_match_scorecard r on r.match_no = m.match_no
	GROUP BY m.Home_team

	UNION ALL

	SELECT Awayteam AS Team,
		SUM(CASE WHEN m.Awayteam = m.Winner Then 2 ELSE 0 END) AS Points,
		SUM(r.Away_team_run- r.Home_team_run) * 1.5/ COUNT(*) AS NRR
	FROM ipl_matches m
	INNER JOIN ipl_match_scorecard r on r.match_no = m.match_no
	GROUP BY m.Awayteam
)

SELECT Team,
	SUM(Points) AS Total_Points,
	SUM(NRR) AS Total_NRR
FROM Team_Performance
GROUP BY Team
ORDER BY Total_Points DESC, Total_NRR DESC;
--Generate a ranking of batsmen by strike rate (runs per 100 balls) in the tournament.
SELECT Batsman,
	SUM(Ball) AS Total_Balls,
	Sum(Run) AS Total_Runs,
	CAST(SUM(Run) * 100/SUM(Ball) AS decimal(10,2)) AS Strike_Rate
FROM ipl2023_batsman
GROUP BY Batsman
HAVING SUM(Ball) > 100
ORDER BY Strike_Rate DESC;


--Performance Trends:

--Analyze a bowler�s performance (e.g., wickets and economy rate) across different matches.
SELECT 
    match_no,
    Bowler,
    SUM(wicket) AS Total_Wickets,
    SUM(run) AS Total_Runs_Conceded,
    SUM([over]) AS Total_Overs_Bowled,
    CAST(SUM(run) * 1.0 / SUM([over]) AS DECIMAL(10, 2)) AS Economy_Rate
FROM ipl2023_bowler
GROUP BY match_no, Bowler
ORDER BY Bowler, match_no;

--Man of the Match Analysis:

--Find the players who won the "Man of the Match" award multiple times.
SELECT 
    man_of_the_match AS Player,
    COUNT(man_of_the_match) AS No_of_MOM
FROM ipl_matches
GROUP BY man_of_the_match
HAVING COUNT(man_of_the_match) >= 2
ORDER BY No_of_MOM DESC;

--Determine the correlation between toss winners and match winners.
SELECT 
    COUNT(*) AS Total_Matches,
    SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) AS Matches_Won_By_Toss_Winner,
    CAST(SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5, 2)) AS Toss_Win_Correlation_Percentage
FROM ipl_matches;
--Win/Loss Analysis:

--What percentage of matches did the team batting first win compared to the team batting second?
SELECT COUNT(*) AS TOTAL_Matches,
	SUM(CASE WHEN result = 'Wickets' THEN 1 ELSE 0 END) AS Second_batting_team_Win,
	CAST( SUM(CASE WHEN result = 'Wickets' THEN 1 ELSE 0 END) *100.0 / COUNT(*) AS DECIMAL (5,2)) AS Second_batting_win_percent,
	SUM(CASE WHEN result = 'Runs' THEN 1 ELSE 0 END) AS First_Batting_team_Win,
	CAST(SUM(CASE WHEN result = 'Runs' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL (5,2)) AS First_batting_win_percent
FROM ipl_matches

--Venue Insights:

--Identify the venues with the highest average scores.
SELECT m.venue,
	sum(r.Home_team_run + r.Away_team_run) AS Total_runs,
	CAST(AVG((r.Home_team_run + r.Away_team_run)) AS decimal(5,2)) AS AVG_runs
FROM ipl_matches m
INNER JOIN ipl_match_scorecard r on r.match_no = m.match_no
GROUP BY venue
ORDER BY AVG_runs DESC;

--Find the venue where the most matches were won by the team batting first.
SELECT venue,
	SUM(CASE WHEN result = 'Runs' THEN 1 ELSE 0 END) AS first_batting_wins
FROM ipl_matches
GROUP BY venue
ORDER BY first_batting_wins DESC;

--Custom Scorecards:

--Generate a detailed match scorecard that includes:
--Batting stats for each player.
SELECT 
    b.Batsman,
    b.team AS Batting_Team,
    SUM(b.Run) AS Runs_Scored,
    SUM(b.Ball) AS Balls_Faced,
    SUM(b.[4s]) AS Fours_Hit,
    SUM(b.[6s]) AS Sixes_Hit
FROM 
    ipl2023_batsman b
WHERE 
    b.match_no = 1
GROUP BY 
    b.Batsman, b.team
ORDER BY 
    Runs_Scored DESC;

--Bowling stats for each player.
SELECT 
    bo.Bowler,
    bo.team AS Bowling_Team,
    SUM(bo.[over]) AS Overs_Bowled,
    SUM(bo.run) AS Runs_Conceded,
    SUM(bo.wicket) AS Wickets_Taken,
    ROUND(SUM(bo.run) * 1.0 / SUM(bo.[over]), 2) AS Economy
FROM 
    ipl2023_bowler bo
WHERE 
    bo.match_no = 1
GROUP BY 
    bo.Bowler, bo.team
ORDER BY 
    Wickets_Taken DESC, Economy ASC;

--Final match result.

SELECT 
    m.match_no,
    m.venue,
    m.date_of_match,
    m.winner,
    m.result,
    m.result_margin
FROM 
    ipl_matches m
WHERE 
    m.match_no = 1;



