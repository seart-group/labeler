import pool from "../../util/pg-pool.js";

export const get = async (_, res) => {
    const [
        { rows: reviewers },
        { rows: buckets }
    ] = await Promise.all([
        pool.query("SELECT * FROM reviewer_progress"),
        pool.query("SELECT * FROM instance_review_bucket")
    ]);
    res.render("progress", { reviewers, buckets });
};
