import pool from "../../../util/pg-pool.js";

export const get = async (req, res) => {
    const current = req.query.page || 1;
    const limit = req.query.limit || 10;
    const name = req.query.name ?? "";
    pool.query(
        `WITH instance_discard_remarks AS (
             SELECT DISTINCT remarks
             FROM instance_discard
             WHERE remarks ILIKE $1
         )
         SELECT remarks
         FROM instance_discard_remarks
         ORDER BY
             POSITION($2 IN remarks),
             remarks
         OFFSET $3 LIMIT $4`,
        [ `%${name}%`, name, (current - 1) * limit, limit ]
    ).then(({ rows }) => {
        const remarks = rows.map(({ remarks }) => remarks);
        res.json(remarks);
    });
};
