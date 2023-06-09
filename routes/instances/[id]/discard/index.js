import pool from "../../../../util/pg-pool.js";
import HTTPStatus from "../../../../util/http-status.js";

export const post = (req, res) => {
    const parameters = [
        req.params.id,
        req.body.reviewer_id,
        req.body.remarks
    ];
    pool.query(
        `INSERT INTO instance_discard(instance_id, reviewer_id, remarks)
         VALUES ($1, $2, $3)`,
        parameters
    ).then(() => res.status(HTTPStatus.OK).end());
};
