import pool from "../../util/pg-pool.js";
import HTTPStatus from "../../util/http-status.js";
import {PostgresError as PGError} from "pg-error-enum";

export const get = async (req, res) => {
    const current = req.query.page || 1;
    const limit = req.query.limit || 10;
    const name = req.query.name || 1;
    const [
        { rows: [ { count: items } ] },
        { rows: labels }
    ] = await Promise.all([
        pool.query("SELECT COUNT(id) FROM label"),
        pool.query(
            name > 0
                ? "SELECT id, name FROM label ORDER BY name OFFSET $1 LIMIT $2"
                : "SELECT id, name FROM label ORDER BY name DESC OFFSET $1 LIMIT $2",
            [ (current - 1) * limit, limit ]
        )
    ]);
    const pages = Math.ceil(items / limit);
    res.render("labels", {
        labels,
        pagination: { items, pages, current, limit, name }
    });
};

export const post = (req, res) => {
    pool.query("INSERT INTO label(name) VALUES ($1) RETURNING *", [ req.body.name ])
        .then(({ rows }) => { res.status(HTTPStatus.CREATED).send(rows[0]); })
        .catch(({ code: PGCode }) => {
            let code;
            switch (PGCode) {
            case PGError.NOT_NULL_VIOLATION:
                code = HTTPStatus.BAD_REQUEST;
                break;
            case PGError.UNIQUE_VIOLATION:
                code = HTTPStatus.CONFLICT;
                break;
            default:
                code = HTTPStatus.INTERNAL_SERVER_ERROR;
            }
            res.status(code).end();
        });
};
