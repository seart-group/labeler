import pool from "../../util/pg-pool.js";

export const get = async (req, res) => {
    const current = req.query.page || 1;
    const limit = req.query.limit || 10;
    const id = req.query.id || 1;
    const [
        { rows: [ { count: items } ] },
        { rows: conflicts }
    ] = await Promise.all([
        pool.query("SELECT COUNT(id) FROM instance_review_conflict"),
        pool.query(
            `SELECT id, category FROM instance_review_conflict
             ORDER BY CASE
             WHEN $1 > 0 THEN id
             WHEN $1 < 0 THEN -id END
             OFFSET $2 LIMIT $3`,
            [ id, (current - 1) * limit, limit ]
        )
    ]);
    const pages = Math.ceil(items / limit);
    res.render("conflicts", {
        conflicts,
        pagination: { items, pages, current, limit, id }
    });
};
