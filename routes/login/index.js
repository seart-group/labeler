import pool from "../../util/pg-pool.js";

export const get = async (_, res) => {
    const { rows: reviewers } = await pool.query("SELECT * FROM reviewer");
    res.render("login", { reviewers: reviewers });
};

export const post = async (req, res) => {
    const { rows: [ reviewer ] } = await pool.query(
        "SELECT * FROM reviewer WHERE id = $1 LIMIT 1",
        [ req.body.id ]
    );
    const target = reviewer
        ? `${req.baseUrl}/${reviewer.name}/queue`
        : `${req.baseUrl}/login`;
    res.redirect(target);
};
