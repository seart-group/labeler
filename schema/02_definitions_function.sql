-- noinspection SqlUnusedForFile

CREATE OR REPLACE FUNCTION
    "instance_review_bucket_threshold"()
    RETURNS INTEGER
    IMMUTABLE
    LANGUAGE SQL
    RETURN 2147483647;

CREATE OR REPLACE FUNCTION
    "next_instance"(reviewer_id INTEGER)
    RETURNS SETOF instance
AS $$
SELECT * FROM instance WHERE FALSE;
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
    BEGIN
        RETURN;
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
    BEGIN
        RETURN;
    END;
$$ LANGUAGE PLpgSQL;

CREATE OR REPLACE FUNCTION
    "label_distribution_category"(label_id INTEGER)
    RETURNS TABLE(
        category TEXT,
        count INTEGER
    )
AS $$
    BEGIN
        RETURN;
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
    BEGIN
        RETURN;
    END;
$$ LANGUAGE PLpgSQL;