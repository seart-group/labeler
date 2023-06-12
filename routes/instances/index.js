import pool from "../../util/pg-pool.js";

export const get = async (req, res) => {
    const current = req.query.page || 1;
    const limit = req.query.limit || 10;
    const id = req.query.id || 1;
    const order = (id > 0) ? "ASC" : "DESC";
    const query = `SELECT * FROM instance ORDER BY id ${order} OFFSET $1 LIMIT $2`;
    const { rows: instances } = await pool.query(query, [ (current - 1) * limit, limit ]);
    const { rows: [ { count: items } ] } = await pool.query("SELECT COUNT(id) FROM instance");
    const pages = Math.ceil(items / req.query.limit);
    res.render("instances", {
        instances,
        pagination: { items, pages, current, limit, id }
    });
};
