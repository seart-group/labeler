import pool from "../../../../util/pg-pool.js";
import HTTPStatus from "../../../../util/http-status.js";

export const post = (req, res) => {
    const parameters = [
        req.params.id,
        req.body.conflicts,
        req.body.remarks
    ];
    pool.query("CALL conflict_resolution_discard($1, $2, $3)", parameters)
        .then(() => res.status(HTTPStatus.CREATED).end());
};
