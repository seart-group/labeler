import pool from "../../../util/pg-pool.js";
import HTTPStatus from "../../../util/http-status.js";

export const get = async (req, res) => {
    const params = [ req.params.id ];
    const { rows: [ instance ] } = await pool.query("SELECT * FROM instance WHERE id = $1", params);
    if (!instance) {
        res.status(HTTPStatus.NOT_FOUND)
            .render("error", {
                icon: "bi-none",
                title: "Instance does not exist!"
            });
    } else {
        res.render("instance", { instance });
    }
};
