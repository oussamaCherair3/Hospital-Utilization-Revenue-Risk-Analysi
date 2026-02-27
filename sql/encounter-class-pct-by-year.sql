SELECT
    en.encounterclass,
    COUNT(en.encounterclass) AS encounter_class_count,
    EXTRACT(YEAR FROM en.start::date) AS encounter_year,
    ROUND(
        COUNT(en.encounterclass) * 100.0
        / SUM(COUNT(en.encounterclass)) OVER (
            PARTITION BY EXTRACT(YEAR FROM en.start::date)
        ),
        2
    ) AS encounter_class_by_year
FROM encounters en
GROUP BY
    en.encounterclass,
    EXTRACT(YEAR FROM en.start::date)
ORDER BY
    encounter_year ASC,
    encounter_class_count DESC;