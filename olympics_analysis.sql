-- Country Medal Totals
SET search_path TO olympics;


WITH team_country AS (
SELECT DISTINCT
    code,
    country_code
FROM teams
),
medal_country AS (
SELECT
    COALESCE(a.country_code, tc.country_code) AS country_code
FROM medals m
LEFT JOIN athletes a ON m.winner_code = a.code
LEFT JOIN team_country tc ON m.winner_code = tc.code
)
SELECT
    c.code AS CountryCode,
    c.country AS CountryName,
    COUNT(*) AS TotalNumber
FROM medal_country mc
JOIN countries c ON c.code = mc.country_code
GROUP BY
    c.code,
    c.country
ORDER BY
    TotalNumber DESC,
    CountryName ASC;

-- Athletes Above Country Average
SET search_path TO olympics;

WITH athlete_results AS (
SELECT
    a.name AS athlete_name,
    a.country_code,
    r.event_name AS event,
    r.rank
FROM results r
JOIN athletes a ON r.participant_code = a.code
WHERE r.participant_type = 'Person'
AND r.rank IS NOT NULL
),
country_average AS (
SELECT
    country_code,
    AVG(rank) AS average_country_rank
FROM athlete_results
GROUP BY country_code
)
SELECT
    ar.athlete_name AS "Athlete Name",
    ar.country_code AS "Country Code",
    ar.event AS "Event",
    ar.rank AS "Rank",
    ROUND(ca.average_country_rank, 2) AS "Average Country Rank"
FROM athlete_results ar
JOIN country_average ca ON ar.country_code = ca.country_code
WHERE ar.rank < ca.average_country_rank
ORDER BY
    ar.country_code,
    ar.athlete_name,
    ar.event;

-- Single Discipline Medal Countries
SET search_path TO olympics;

WITH team_country AS (
SELECT DISTINCT
    code,
    country_code
FROM teams
),
medal_country AS (
SELECT
    COALESCE(a.country_code, tc.country_code) AS country_code,
    m.discipline
FROM medals m
LEFT JOIN athletes a ON m.winner_code = a.code
LEFT JOIN team_country tc ON m.winner_code = tc.code
),
country_discipline AS (
SELECT
    country_code,
    discipline,
    COUNT(*) AS number_of_medals
FROM medal_country
WHERE country_code IS NOT NULL
GROUP BY
    country_code,
    discipline
),
one_discipline_countries AS (
SELECT
    country_code
FROM country_discipline
GROUP BY country_code
HAVING COUNT(*) = 1
)
SELECT
    c.country AS "Country",
    cd.discipline AS "Discipline",
    cd.number_of_medals AS "Number of Medals"
FROM country_discipline cd
JOIN one_discipline_countries odc
    ON cd.country_code = odc.country_code
JOIN countries c
    ON c.code = cd.country_code
ORDER BY
    cd.number_of_medals DESC,
    c.country ASC;

-- Athlete Medal Counts
SET search_path TO olympics;

WITH team_members AS (
SELECT DISTINCT
    code,
    athletes_code
FROM teams
),
athlete_medals AS (
SELECT
    a.code AS athlete_code,
    a.name AS athlete_name
FROM medals m
JOIN athletes a ON m.winner_code = a.code

UNION ALL

SELECT
    a.code AS athlete_code,
    a.name AS athlete_name
FROM medals m
JOIN team_members tm ON m.winner_code = tm.code
JOIN athletes a ON tm.athletes_code = a.code
)
SELECT
    athlete_name AS "Athlete Name",
    COUNT(*) AS "Total Number of Medals"
FROM athlete_medals
GROUP BY
    athlete_code,
    athlete_name
ORDER BY
    "Total Number of Medals" DESC,
    "Athlete Name" ASC;

-- Judo Athlete Medal Counts
SET search_path TO olympics;

WITH judo_athletes AS (
SELECT
    code,
    name
FROM athletes
WHERE disciplines LIKE '%Judo%'
),
team_members AS (
SELECT DISTINCT
    code,
    athletes_code
FROM teams
),
athlete_medals AS (
SELECT
    a.code AS athlete_code,
    a.name AS athlete_name
FROM medals m
JOIN athletes a ON m.winner_code = a.code

UNION ALL

SELECT
    a.code AS athlete_code,
    a.name AS athlete_name
FROM medals m
JOIN team_members tm ON m.winner_code = tm.code
JOIN athletes a ON tm.athletes_code = a.code
)
SELECT
    ja.name AS "AthleteName",
    COUNT(am.athlete_code) AS "NumberOfMedals"
FROM judo_athletes ja
LEFT JOIN athlete_medals am ON ja.code = am.athlete_code
GROUP BY
    ja.code,
    ja.name
ORDER BY
    "NumberOfMedals" DESC,
    "AthleteName" ASC;

-- Tokyo Paris Comparison
SET search_path TO olympics;

WITH tokyo_country_medals AS (
SELECT
    country_code,
    SUM(COALESCE(gold_medal, 0) +
    COALESCE(silver_medal, 0) +
    COALESCE(bronze_medal, 0)) AS tokyo_medals
FROM tokyo_medals
GROUP BY country_code
),
team_country AS (
SELECT DISTINCT
    code,
    country_code
FROM teams
),
paris_medal_country AS (
SELECT
    COALESCE(a.country_code, tc.country_code) AS country_code
FROM medals m
LEFT JOIN athletes a ON m.winner_code = a.code
LEFT JOIN team_country tc ON m.winner_code = tc.code
),
paris_country_medals AS (
SELECT
    country_code,
    COUNT(*) AS paris_medals
FROM paris_medal_country
WHERE country_code IS NOT NULL
GROUP BY country_code
)
SELECT
    c.country AS "Country",
    c.code AS "Country Code",
    COALESCE(tcm.tokyo_medals, 0) AS "Tokyo Medals",
    COALESCE(pcm.paris_medals, 0) AS "Paris Medals",
    COALESCE(pcm.paris_medals, 0) - COALESCE(tcm.tokyo_medals, 0) AS "Delta",
    ROUND(
        (
            COALESCE(pcm.paris_medals, 0) - COALESCE(tcm.tokyo_medals, 0)
        ) * 100.0 / NULLIF(COALESCE(tcm.tokyo_medals, 0), 0),
        2
    ) AS "Percentage Improvement"
FROM countries c
LEFT JOIN tokyo_country_medals tcm ON tcm.country_code = c.code
LEFT JOIN paris_country_medals pcm ON pcm.country_code = c.code
WHERE
    COALESCE(tcm.tokyo_medals, 0) > 0
    OR COALESCE(pcm.paris_medals, 0) > 0
ORDER BY
    "Delta" DESC,
    "Country" ASC;

-- Coach Medal Association
SET search_path TO olympics;

WITH team_country AS (
SELECT DISTINCT
    code,
    country_code
FROM teams
),
medal_country AS (
SELECT
    m.discipline,
    COALESCE(a.country_code, tc.country_code) AS country_code
FROM medals m
LEFT JOIN athletes a ON m.winner_code = a.code
LEFT JOIN team_country tc ON m.winner_code = tc.code
),
coach_medals AS (
SELECT
    c.name AS coach_name,
    COUNT(*) AS total_medals
FROM coaches c
JOIN medal_country mc
    ON c.country_code = mc.country_code
    AND c.discipline = mc.discipline
WHERE mc.country_code IS NOT NULL
GROUP BY c.name
)
SELECT
    coach_name AS "Coach",
    total_medals AS "TotalNumberOfMedals"
FROM coach_medals
WHERE total_medals >= 1
ORDER BY
    "TotalNumberOfMedals" DESC,
    "Coach" ASC;
