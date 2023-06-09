import pool from "../../../../util/pg-pool.js";
import HTTPStatus from "../../../../util/http-status.js";

export const post = (req, res) => {
    const params = [
        req.params.id,
        req.body.conflicts,
        req.body.label_ids,
        req.body.is_interesting,
        req.body.remarks
    ];
    pool.query("CALL conflict_resolution_review($1, $2, $3, $4, $5)", params)
        .then(() => res.status(HTTPStatus.CREATED).end());
};
