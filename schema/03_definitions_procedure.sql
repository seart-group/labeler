-- noinspection SqlUnusedForFile

CREATE OR REPLACE PROCEDURE
    "label_remove"(id INTEGER)
AS $$
    BEGIN
    END;
$$ LANGUAGE PLpgSQL;

CREATE OR REPLACE PROCEDURE
    "label_rename"(
        old_name TEXT,
        new_name TEXT
    )
AS $$
    BEGIN
    END;
$$ LANGUAGE PLpgSQL;

CREATE OR REPLACE PROCEDURE
    "label_merge"(
        source_name TEXT,
        target_name TEXT
    )
AS $$
    BEGIN
    END;
$$ LANGUAGE PLpgSQL;

CREATE OR REPLACE PROCEDURE
    "conflict_resolution_discard"(
        instance_id INTEGER,
        conflicts CONFLICT[],
        remarks TEXT
    )
AS $$
    BEGIN
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
    BEGIN
    END;
$$ LANGUAGE PLpgSQL;
