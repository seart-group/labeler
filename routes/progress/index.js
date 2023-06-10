import pool from "../../util/pg-pool.js";

export const get = async (_, res) => {
    const { rows: reviewers } = await pool.query("SELECT * FROM instance_review_progress");
    const { rows: buckets } = await pool.query("SELECT * FROM instance_review_bucket");
    res.render("progress", { reviewers, buckets });
};
