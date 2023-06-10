import pool from "../../../util/pg-pool.js";
import { parse as parsePGArray } from "postgres-array";

export const get = async (req, res) => {
    const params = [ req.params.id ];
    const { rows: [ instance ] } = await pool.query("SELECT * FROM instance_review_conflict WHERE id = $1", params);
    if (!instance) {
        res.render("error", {
            icon: "bi-none",
            title: "Conflict not found or already resolved!"
        });
    } else {
        instance.conflicts = parsePGArray(instance.conflicts);
        const { rows: reviews } = await pool.query("SELECT * FROM instance_review_details($1)", params);
        const { rows: discards } = await pool.query("SELECT * FROM instance_discard_details($1)", params);
        const { rows: labels } = await pool.query("SELECT * FROM label ORDER BY name");
        res.render("conflict", { instance, reviews, discards, labels });
    }
};
