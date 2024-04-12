CREATE OR REPLACE FUNCTION
    "next_instance"(reviewer_id INTEGER)
    RETURNS SETOF instance
AS $$
    WITH reviewed AS (
        SELECT review.instance_id AS instance_id
        FROM instance_review AS review
        WHERE review.reviewer_id = next_instance.reviewer_id
    ), discarded AS (
        SELECT discard.instance_id AS instance_id
        FROM instance_discard AS discard
        WHERE discard.reviewer_id = next_instance.reviewer_id
    )
    SELECT candidate.*
    FROM instance_review_candidate candidate
    WHERE
        NOT EXISTS(
            SELECT FROM reviewed
            WHERE instance_id = candidate.id
        )
        AND NOT EXISTS(
            SELECT FROM discarded
            WHERE instance_id = candidate.id
        )
        AND NOT EXISTS(
            SELECT FROM instance_review_bucket_filled AS filled
            WHERE filled.category = candidate.category
        )
    LIMIT 1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION
    "instance_review_details"(instance_id INTEGER)
    RETURNS TABLE (
        reviewer_id INTEGER,
        reviewer_name TEXT,
        is_interesting boolean,
        reviewed_at TIMESTAMP,
        remarks TEXT,
        labels TEXT[]
    )
AS $$
    #variable_conflict use_variable
    BEGIN
        RETURN QUERY
        SELECT
            reviewer.id AS reviewer_id,
            reviewer.name AS reviewer_name,
            review.is_interesting AS is_interesting,
            review.reviewed_at AS reviewed_at,
            review.remarks AS remarks,
            ARRAY_AGG(label.name ORDER BY label.name) AS labels
        FROM instance_review review
        INNER JOIN reviewer
            ON review.reviewer_id = reviewer.id
        INNER JOIN instance_review_label review_label
            ON review.id = review_label.instance_review_id
        INNER JOIN label
            ON label.id = review_label.label_id
        WHERE review.instance_id = instance_id
        GROUP BY
            reviewer.id,
            reviewer.name,
            review.is_interesting,
            review.reviewed_at,
            review.remarks;
    END;
$$ LANGUAGE PLpgSQL;

CREATE OR REPLACE FUNCTION
    "instance_discard_details"(instance_id INTEGER)
    RETURNS TABLE(
        reviewer_id INTEGER,
        reviewer_name TEXT,
        discarded_at TIMESTAMP,
        remarks TEXT
    )
AS $$
    #variable_conflict use_variable
    BEGIN
        RETURN QUERY
        SELECT
            reviewer.id AS reviewer_id,
            reviewer.name AS reviewer_name,
            discard.discarded_at AS discarded_at,
            discard.remarks AS remarks
        FROM instance_discard discard
        INNER JOIN reviewer ON discard.reviewer_id = reviewer.id
        WHERE discard.instance_id = instance_id;
    END;
$$ LANGUAGE PLpgSQL;

CREATE OR REPLACE FUNCTION
    "label_distribution_category"(label_id INTEGER)
    RETURNS TABLE(
        category TEXT,
        count INTEGER
    )
AS $$
    #variable_conflict use_variable
    BEGIN
        RETURN QUERY
        WITH subquery AS (
            SELECT
                label.id AS id,
                label.name AS name,
                instance.category AS category,
                COUNT(DISTINCT instance.id)::INTEGER AS count
            FROM label
            INNER JOIN instance_review_label review_label
                ON label.id = review_label.label_id
            INNER JOIN instance_review review
                ON review.id = review_label.instance_review_id
            INNER JOIN instance
                ON review.instance_id = instance.id
            WHERE label.id = label_id
            GROUP BY label.id, instance.category
        )
        SELECT
            categories.category AS category,
            COALESCE(subquery.count, 0) AS count
        FROM categories
        LEFT JOIN subquery ON categories.category = subquery.category;
    END;
$$ LANGUAGE PLpgSQL;

CREATE OR REPLACE FUNCTION
    "label_distribution_reviewer"(label_id INTEGER)
    RETURNS TABLE(
        id INTEGER,
        name TEXT,
        count INTEGER
    )
AS $$
    #variable_conflict use_variable
    BEGIN
        RETURN QUERY
        WITH subquery AS (
            SELECT
                reviewer.id AS reviewer_id,
                reviewer.name AS reviewer_name,
                COUNT(*)::INTEGER AS count
            FROM label
            INNER JOIN instance_review_label review_label ON label.id = review_label.label_id
            INNER JOIN instance_review review ON review.id = review_label.instance_review_id
            INNER JOIN reviewer ON review.reviewer_id = reviewer.id
            WHERE label.id = label_id
            GROUP BY reviewer.id
        )
        SELECT
            reviewer.id AS id,
            reviewer.name AS name,
            COALESCE(subquery.count, 0) AS count
        FROM reviewer
        LEFT JOIN subquery ON reviewer.id = subquery.reviewer_id;
    END;
$$ LANGUAGE PLpgSQL;
