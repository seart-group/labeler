import pool from "../../../util/pg-pool.js";

export const get = async (req, res) => {
    const { rows: labels } = await pool.query("SELECT * FROM label ORDER BY name");
    const { rows: [ reviewer ] } = await pool.query(
        "SELECT * FROM instance_review_progress WHERE name = $1 LIMIT 1",
        [ req.params.name ]
    );
    const { rows: [ instance ] } = await pool.query(
        "SELECT * FROM next_instance($1)",
        [ reviewer?.id || null ]
    );
    res.render("review", { reviewer, instance, labels });
};
