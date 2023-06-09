import pool from "../../../../util/pg-pool.js";
import HTTPStatus from "../../../../util/http-status.js";

export const post = async (req, res) => {
    const parameters = [
        req.params.id,
        req.body.reviewer_id,
        req.body.is_interesting,
        req.body.remarks
    ];

    const { rows: [ { id: instance_review_id } ] } = await pool.query(
        `INSERT INTO instance_review(instance_id, reviewer_id, is_interesting, remarks) 
         VALUES ($1, $2, $3, $4) RETURNING id`,
        parameters
    );

    req.body.label_ids.forEach(label_id => {
        pool.query(
            "INSERT INTO instance_review_label(label_id, instance_review_id) VALUES ($1, $2)",
            [ label_id, instance_review_id ]
        );
    });

    res.status(HTTPStatus.OK).end();
};
