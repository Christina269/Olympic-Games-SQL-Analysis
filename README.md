# Olympic Games SQL Analysis

An undergraduate Database Management project analyzing Paris Olympic Games data and comparing medal totals with Tokyo using PostgreSQL.

## Queries
1. Country medal totals.
2. Athletes ranked better than their country's average rank (lower is better).
3. Countries with medals in only one discipline.
4. Athlete medal counts, including team medals.
5. All athletes listed in judo and their medals across disciplines, including zero-medal athletes.
6. Tokyo versus Paris medal totals, absolute differences and percentage changes.
7. Coach medal associations based on country and discipline, as explicitly defined by the assignment. This is not evidence of an actual coach–athlete relationship.

## SQL techniques
CTEs, joins, UNION ALL, grouping, aggregation, COALESCE and NULLIF.

## Files and execution
`queries/` contains the seven individual queries. `olympics_analysis.sql` combines them; run either the combined file or the individual queries, not both. `database_schema.md` documents the fields used in the analysis.
The original `paris_database.sql` was provided through the university course and is not included. 

## Academic context
Undergraduate coursework. Tokyo medal totals are grouped by country. The coach query groups by name under the assignment’s country-and-discipline association rule; the course data must be checked for homonymous coaches or repeated coach records. 

All seven queries passed a local SQLite smoke test using temporary in-memory test records and with the PostgreSQL search-path statement omitted. These test records are not included.
