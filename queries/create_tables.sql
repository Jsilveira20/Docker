-- Dimension Tables

CREATE TABLE pldata.dim_season AS
SELECT DISTINCT
  1 AS season_id,
  '2025-26' AS season_name
FROM pldata."premier.csv";

CREATE TABLE pldata.dim_perf_junk AS
SELECT DISTINCT
  ROW_NUMBER() OVER (ORDER BY redCards, yellowCards, ownGoals) AS perf_junk_id,
  redCards AS red_cards,
  yellowCards AS yellow_cards,
  ownGoals AS own_goals,
  errorLeadToGoal AS error_lead_to_goal,
  penaltyConceded AS penalty_conceded,
  penaltyWon AS penalty_won,
  cleanSheet AS clean_sheet,
  offsides
FROM pldata."premier.csv";

-- Fact Table

CREATE TABLE pldata.ft_player_season AS
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
FROM pldata."premier.csv" s
JOIN pldata.dim_player p ON s.player_name = p.player_name
JOIN pldata.dim_team t ON s.team_name = t.team_name
JOIN pldata.dim_position pos ON s."position" = pos.position_name
JOIN pldata.dim_perf_junk pj ON s.redCards = pj.red_cards
  AND s.yellowCards = pj.yellow_cards
  AND s.ownGoals = pj.own_goals;
