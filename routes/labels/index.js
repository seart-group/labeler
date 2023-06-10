import pool from "../../util/pg-pool.js";
import HTTPStatus from "../../util/http-status.js";
import { PostgresError as PGError } from "pg-error-enum";

export const get = async (req, res) => {
    const current = req.query.page || 1;
    const limit = req.query.limit || 10;
    const name = req.query.name || 1;
    const order = (name > 0) ? "ASC" : "DESC";
    const query = `SELECT id, name FROM label ORDER BY name ${order} OFFSET $1 LIMIT $2`;
    const { rows: labels } = await pool.query(query, [ (current - 1) * limit, limit ]);
    const { rows: [ { count: items } ] } = await pool.query("SELECT COUNT(id) FROM label");
    const pages = Math.ceil(items / req.query.limit);
    res.render("labels", {
        labels,
        pagination: { items, pages, current, limit, name }
    });
};

export const post = (req, res) => {
    pool.query("INSERT INTO label(name) VALUES ($1) RETURNING *", [ req.body.name ])
        .then(({ rows }) => { res.status(HTTPStatus.CREATED).send(rows[0]); })
        .catch(({ code }) => {
            const status = code === PGError.UNIQUE_VIOLATION ? HTTPStatus.CONFLICT : HTTPStatus.INTERNAL_SERVER_ERROR;
            res.status(status).end();
        });
};
