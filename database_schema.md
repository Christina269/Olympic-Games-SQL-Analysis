# Database fields used by the queries

This is a reference inferred from the submitted SQL, **not** a verified DDL or the original database schema.

| Table | Referenced fields |
|---|---|
| `countries` | `code`, `country` |
| `athletes` | `code`, `name`, `country_code`, `disciplines` |
| `teams` | `code`, `country_code`, `athletes_code` |
| `medals` | `winner_code`, `discipline` |
| `results` | `participant_code`, `participant_type`, `event_name`, `rank` |
| `tokyo_medals` | `country_code`, `gold_medal`, `silver_medal`, `bronze_medal` |
| `coaches` | `name`, `country_code`, `discipline` |

`medals.winner_code` is matched to athlete codes or team codes; team membership links to athlete codes. Country codes link records to `countries.code`. Individual results use `participant_type = 'Person'`. Coach associations use country and discipline, per the assignment. Actual key constraints and data types need verification with the original database.
