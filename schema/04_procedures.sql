CREATE OR REPLACE PROCEDURE
    "label_remove"(id INTEGER)
AS $$
    DECLARE
        _id INTEGER;
    BEGIN
        IF id IS NULL
        THEN RAISE EXCEPTION SQLSTATE 'L0001'
            USING MESSAGE = 'id parameter is required';
        END IF;
        _id := id;
        IF NOT EXISTS(SELECT FROM label WHERE label.id = _id)
        THEN RAISE no_data_found;
        END IF;
        DELETE FROM instance_review_label WHERE label_id = _id;
        DELETE FROM label WHERE label.id = _id;
    END;
$$ LANGUAGE PLpgSQL;

CREATE OR REPLACE PROCEDURE
    "label_rename"(
        old_name TEXT,
        new_name TEXT
    )
AS $$
    DECLARE
        _ TEXT;
    BEGIN
        IF old_name IS NULL
        OR new_name IS NULL
        THEN RAISE EXCEPTION SQLSTATE 'L0001'
            USING MESSAGE = 'both name parameters are required';
        END IF;
        SELECT name INTO STRICT _ FROM label WHERE name = old_name;
        UPDATE label SET name = new_name WHERE name = old_name;
    END;
$$ LANGUAGE PLpgSQL;

CREATE OR REPLACE PROCEDURE
    "label_merge"(
        source_name TEXT,
        target_name TEXT
    )
AS $$
    DECLARE
        _source_id INTEGER;
        _target_id INTEGER;
        _instance_review_id INTEGER;
        _instance_review_ids INTEGER[];
    BEGIN
        IF source_name IS NULL
        OR target_name IS NULL
        THEN RAISE EXCEPTION SQLSTATE 'L0001'
            USING MESSAGE = 'both name parameters are required';
        END IF;
        IF source_name = target_name
        THEN RETURN;
        END IF;
        SELECT id INTO STRICT _source_id FROM label WHERE name = source_name;
        SELECT id INTO STRICT _target_id FROM label WHERE name = target_name;
        SELECT DISTINCT COALESCE(ARRAY_AGG(instance_review_id), '{}')
        INTO _instance_review_ids
        FROM instance_review_label
        WHERE label_id IN (_source_id, _target_id);
        FOREACH _instance_review_id IN ARRAY _instance_review_ids
        LOOP
            BEGIN
                INSERT INTO instance_review_label(instance_review_id, label_id)
                VALUES (_instance_review_id, _target_id);
            EXCEPTION
                WHEN unique_violation THEN -- ignore
            END;
            DELETE FROM instance_review_label
            WHERE
                instance_review_id = _instance_review_id
            AND
                label_id = _source_id;
        END LOOP;
        DELETE FROM label WHERE id = _source_id;
    END;
$$ LANGUAGE PLpgSQL;

CREATE OR REPLACE PROCEDURE
    "conflict_resolution_discard"(
        instance_id INTEGER,
        conflicts CONFLICT[],
        remarks TEXT
    )
AS $$
    DECLARE
        _instance_id INTEGER;
        _conflict CONFLICT;
        _conflicts CONFLICT[];
        _remarks TEXT;
        _reviewer INTEGER;
        _reviewers INTEGER[];
    BEGIN
        -- Copy parameters to avoid ambiguity
        _instance_id := conflict_resolution_discard.instance_id;
        _conflicts := conflict_resolution_discard.conflicts;
        _remarks := conflict_resolution_discard.remarks;
        -- Record reviewers that have already reviewed the instance
        SELECT ARRAY_AGG(reviewer_id) INTO _reviewers
        FROM instance_review review
        WHERE review.instance_id = _instance_id;
        -- Clean labels and reviews related to the instance
        DELETE FROM instance_review_label WHERE instance_review_id IN (
            SELECT id
            FROM instance_review review
            WHERE review.instance_id = _instance_id
        );
        DELETE FROM instance_review review WHERE review.instance_id = _instance_id;
        -- Add a discard entry for each previous reviewer
        FOREACH _reviewer IN ARRAY _reviewers
        LOOP
            INSERT INTO instance_discard(instance_id, reviewer_id, remarks)
            VALUES (_instance_id, _reviewer, _remarks);
        END LOOP;
        -- Update existing instance discards with the provided remarks
        UPDATE instance_discard AS discard
        SET remarks = _remarks
        WHERE discard.instance_id = _instance_id;
        -- Record conflict resolution
        FOREACH _conflict IN ARRAY _conflicts
        LOOP
            INSERT INTO instance_review_conflict_resolution(instance_id, conflict)
            VALUES (_instance_id, _conflict);
        END LOOP;
    END;
$$ LANGUAGE PLpgSQL;

CREATE OR REPLACE PROCEDURE
    "conflict_resolution_review"(
        instance_id INTEGER,
        conflicts CONFLICT[],
        label_ids INTEGER[],
        is_interesting BOOLEAN,
        remarks TEXT
    )
AS $$
    DECLARE
        _instance_id INTEGER;
        _conflict CONFLICT;
        _conflicts CONFLICT[];
        _label_id INTEGER;
        _label_ids INTEGER[];
        _review_id INTEGER;
        _is_interesting BOOLEAN;
        _remarks TEXT;
        _person INTEGER;
        _reviewers INTEGER[];
        _discarders INTEGER[];
    BEGIN
        -- Copy parameters to avoid ambiguity
        _instance_id := conflict_resolution_review.instance_id;
        _conflicts := conflict_resolution_review.conflicts;
        _label_ids := conflict_resolution_review.label_ids;
        _is_interesting := conflict_resolution_review.is_interesting;
        _remarks := conflict_resolution_review.remarks;
        -- Record reviewers that have already reviewed the instance
        SELECT ARRAY_AGG(reviewer_id) INTO _reviewers
        FROM instance_review review
        WHERE review.instance_id = _instance_id;
        -- Record discarders that have already discarded the instance
        SELECT ARRAY_AGG(reviewer_id) INTO _discarders
        FROM instance_discard discard
        WHERE discard.instance_id = _instance_id;
        -- Clean discards, labels and reviews related to the instance
        DELETE FROM instance_discard discard WHERE discard.instance_id = _instance_id;
        DELETE FROM instance_review_label WHERE instance_review_id IN (
            SELECT id
            FROM instance_review review
            WHERE review.instance_id = _instance_id
        );
        DELETE FROM instance_review review WHERE review.instance_id = _instance_id;
        -- Add a review with provided labels for each reviewer and discarder
        FOREACH _person IN ARRAY ARRAY_CAT(_reviewers, _discarders)
        LOOP
            INSERT INTO instance_review(instance_id, reviewer_id, is_interesting, remarks)
            VALUES (_instance_id, _person, _is_interesting, _remarks)
            RETURNING id INTO _review_id;
            FOREACH _label_id IN ARRAY _label_ids
            LOOP
                INSERT INTO instance_review_label(instance_review_id, label_id)
                VALUES (_review_id, _label_id);
            END LOOP;
        END LOOP;
        -- Record conflict resolution
        FOREACH _conflict IN ARRAY _conflicts
        LOOP
            INSERT INTO instance_review_conflict_resolution(instance_id, conflict)
            VALUES (_instance_id, _conflict);
        END LOOP;
    END;
$$ LANGUAGE PLpgSQL;
