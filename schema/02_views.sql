CREATE OR REPLACE VIEW "categories" AS
SELECT DISTINCT category FROM instance;

CREATE OR REPLACE VIEW "instance_review_candidate" AS
WITH instance_review_or_discard AS (
    SELECT instance_id AS id
    FROM instance_review
    UNION ALL
    SELECT instance_id AS id
    FROM instance_discard
)
SELECT instance.* FROM instance
LEFT JOIN instance_review_or_discard review_or_discard
    ON instance.id = review_or_discard.id
GROUP BY instance.id
HAVING COUNT(instance.id) < 2
ORDER BY COUNT(review_or_discard.id) DESC,
         RANDOM();

CREATE OR REPLACE VIEW "instance_review_finished" AS
SELECT
    instance.id AS id,
    instance.category AS category,
    instance.data AS data
FROM instance
INNER JOIN instance_review review
    ON instance.id = review.instance_id
GROUP BY instance.id
HAVING COUNT(review.id) >= 2;

CREATE OR REPLACE VIEW "instance_review_bucket" AS
SELECT
    finished.category AS category,
    COUNT(finished.id)::INTEGER AS count
FROM instance_review_finished finished
GROUP BY finished.category
ORDER BY finished.category;

CREATE OR REPLACE VIEW "instance_review_bucket_filled" AS
SELECT bucket.category
FROM instance_review_bucket bucket
WHERE bucket.count > 366;

CREATE OR REPLACE VIEW "reviewer_review_progress" AS
SELECT
    reviewer.id AS id,
    reviewer.name AS name,
    COUNT(review.reviewer_id)::INTEGER AS progress
FROM reviewer
LEFT OUTER JOIN instance_review review
    ON reviewer.id = review.reviewer_id
GROUP BY reviewer.id
ORDER BY reviewer.id;

CREATE OR REPLACE VIEW "reviewer_discard_progress" AS
SELECT
    reviewer.id AS id,
    reviewer.name AS name,
    COUNT(discard.reviewer_id)::INTEGER AS progress
FROM reviewer
LEFT OUTER JOIN instance_discard discard
    ON reviewer.id = discard.reviewer_id
GROUP BY reviewer.id
ORDER BY reviewer.id;

CREATE OR REPLACE VIEW "reviewer_progress" AS
SELECT
    reviewer.id AS id,
    reviewer.name AS name,
    review_progress.progress AS review_progress,
    discard_progress.progress AS discard_progress
FROM reviewer
INNER JOIN reviewer_review_progress review_progress
    ON reviewer.id = review_progress.id
INNER JOIN reviewer_discard_progress discard_progress
    ON reviewer.id = discard_progress.id;

CREATE OR REPLACE VIEW "instance_review_conflict_label" AS
SELECT DISTINCT ON (instance.id)
    instance.id,
    instance.category,
    instance.data
FROM instance
INNER JOIN instance_review_finished finished
    ON instance.id = finished.id
INNER JOIN instance_review review
    ON finished.id = review.instance_id
INNER JOIN instance_review_label review_label
    ON review.id = review_label.instance_review_id
INNER JOIN label
    ON label.id = review_label.label_id
GROUP BY instance.id, label.id
HAVING
    COUNT(label.id) < (
        SELECT COUNT(instance_review.id)
        FROM instance_review
        WHERE instance_review.instance_id = instance.id
    )
ORDER BY instance.id;

CREATE OR REPLACE VIEW "instance_review_conflict_outcome" AS
WITH instance_review_outcomes AS (
    SELECT
        instance_id AS id,
        'R' AS outcome
    FROM instance_review
    UNION ALL
    SELECT
        instance_id AS id,
        'D' AS outcome
    FROM instance_discard
), instance_review_and_discard AS (
    SELECT outcomes.*
    FROM instance_review_outcomes outcomes
    WHERE EXISTS(
        SELECT FROM instance_review_outcomes self
        WHERE
            self.id = outcomes.id
        AND
            self.outcome IS DISTINCT FROM outcomes.outcome
    )
)
SELECT instance.* FROM instance
INNER JOIN instance_review_and_discard review_and_discard
    ON instance.id = review_and_discard.id
GROUP BY instance.id
HAVING
    SUM(
        CASE WHEN review_and_discard.outcome = 'R'
            THEN 1
            ELSE 0
        END
    ) >=
    SUM(
        CASE WHEN review_and_discard.outcome = 'D'
            THEN 1
            ELSE 0
        END
    )
ORDER BY instance.id;

CREATE OR REPLACE VIEW "instance_review_conflict" AS
WITH conflict_union AS (
    SELECT
        conflict_label.*,
        '1'::CONFLICT AS conflict
    FROM instance_review_conflict_label conflict_label
    UNION ALL
    SELECT
        conflict_outcome.*,
        '2'::CONFLICT AS conflict
    FROM instance_review_conflict_outcome conflict_outcome
)
SELECT
    instance.id AS id,
    instance.category AS category,
    instance.data AS data,
    ARRAY_AGG(
        conflict_union.conflict
        ORDER BY conflict
    ) AS conflicts
FROM instance
INNER JOIN conflict_union ON instance.id = conflict_union.id
GROUP BY instance.id
ORDER BY instance.id;

CREATE OR REPLACE VIEW "instance_discard_export" AS
SELECT
    instance.*,
    STRING_AGG(
        DISTINCT discard.remarks,
        ',' ORDER BY discard.remarks
    ) AS remarks
FROM instance
INNER JOIN instance_discard discard ON instance.id = discard.instance_id
WHERE NOT EXISTS(
    SELECT FROM instance_review_conflict conflict
    WHERE conflict.id = instance.id
)
GROUP BY instance.id;

CREATE OR REPLACE VIEW "instance_review_finished_export" AS
SELECT
    instance.id AS id,
    instance.category AS category,
    instance.data AS data,
    STRING_AGG(
            DISTINCT label.name,
            ',' ORDER BY label.name
        ) AS labels,
    STRING_AGG(
            DISTINCT review.remarks,
            ',' ORDER BY review.remarks
        ) AS remarks,
    BOOL_OR(review.is_interesting) AS is_interesting
FROM instance
INNER JOIN instance_review_finished finished
    ON instance.id = finished.id
INNER JOIN instance_review review
    ON finished.id = review.instance_id
INNER JOIN instance_review_label review_label
    ON review.id = review_label.instance_review_id
INNER JOIN label
    ON label.id = review_label.label_id
WHERE NOT EXISTS(
    SELECT FROM instance_review_conflict conflict
    WHERE conflict.id = instance.id
)
GROUP BY instance.id;

CREATE OR REPLACE VIEW "instance_review_conflict_resolution_export" AS
SELECT
    resolution.instance_id AS instance_id,
    STRING_AGG(resolution.conflict::text, ',') AS conflicts
FROM instance_review_conflict_resolution resolution
GROUP BY resolution.instance_id;
