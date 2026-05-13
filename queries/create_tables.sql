-- Dimension Tables

-- Season
CREATE TABLE pldata."tables"."dim_season" AS
SELECT DISTINCT
    1 AS season_id,
    '2025-26' AS season_name
FROM pldata.premierleague."dataset_limpio.csv";


-- Player
CREATE TABLE pldata."tables"."dim_player" AS
SELECT DISTINCT
    ROW_NUMBER() OVER (ORDER BY player_name) AS player_id,
    player_name
FROM pldata.premierleague."dataset_limpio.csv";

-- Team
CREATE TABLE pldata."tables"."dim_team" AS
SELECT DISTINCT
    ROW_NUMBER() OVER (ORDER BY team_name) AS team_id,
    team_name
FROM pldata.premierleague."dataset_limpio.csv";


-- Position
CREATE TABLE pldata."tables"."dim_position" AS
SELECT DISTINCT
    ROW_NUMBER() OVER (ORDER BY "position") AS position_id,
    "position" AS position_name
FROM pldata.premierleague."dataset_limpio.csv";


-- Perf_Junk
CREATE TABLE pldata."tables"."dim_perf_junk" AS
SELECT DISTINCT
    ROW_NUMBER() OVER (
        ORDER BY redCards, yellowCards, ownGoals
    ) AS perf_junk_id,
    redCards AS red_cards,
    yellowCards AS yellow_cards,
    ownGoals AS own_goals,
    errorLeadToGoal AS error_lead_to_goal,
    penaltyConceded AS penalty_conceded,
    penaltyWon AS penalty_won,
    cleanSheet AS clean_sheet,
    offsides
FROM pldata.premierleague."dataset_limpio.csv";


--CREATE TABLE pldata."tables"."ft_player_season" AS
SELECT
    p.player_id,
    t.team_id,
    pos.position_id,
    1 AS season_id,
    pj.perf_junk_id,
    s.appearances,
    s.matchesStarted,
    s.minutesPlayed,
    s.goals,
    s.assists,
    s.expectedGoals,
    s.expectedAssists,
    s.shotsOnTarget,
    s.penaltyGoals,
    s.bigChancesCreated,
    s.accuratePassesPercentage,
    s.keyPasses,
    s.tackles,
    s.interceptions,
    s.fouls,
    s.offsides
FROM pldata.premierleague."dataset_limpio.csv" s
JOIN pldata."tables"."dim_player" p
    ON s.player_name = p.player_name
JOIN pldata."tables"."dim_team" t
    ON s.team_name = t.team_name
JOIN pldata."tables"."dim_position" pos
    ON s."position" = pos.position_name
JOIN pldata."tables"."dim_perf_junk" pj
    ON s.redCards = pj.red_cards
   AND s.yellowCards = pj.yellow_cards
   AND s.ownGoals = pj.own_goals;
