import pool from "../../../util/pg-pool.js";
import HTTPStatus from "../../../util/http-status.js";
import {PostgresError as PGError} from "pg-error-enum";

export const get = async (req, res) => {
    const parameters = [ req.params.id ];
    const { rows: [ label ] } = await pool.query("SELECT * FROM label WHERE id = $1", parameters);
    if (!label) {
        res.status(HTTPStatus.NOT_FOUND)
            .render("error", {
                icon: "bi-none",
                title: "Label does not exist!"
            });
    } else {
        const [
            { rows: labels },
            { rows: categories },
            { rows: reviewers }
        ] = await Promise.all([
            pool.query("SELECT id, name FROM label WHERE id != $1 ORDER BY name", parameters),
            pool.query("SELECT * FROM label_distribution_category($1)", parameters ),
            pool.query("SELECT * FROM label_distribution_reviewer($1)", parameters )
        ]);
        res.render("label", { label, labels, categories, reviewers });
    }
};

export const del = (req, res) => {
    const parameters = [ req.params.id ];
    pool.query("CALL label_remove($1)", parameters)
        .then(() => res.status(HTTPStatus.NO_CONTENT).end())
        .catch(({ code: PGCode }) => {
            let code;
            switch (PGCode) {
            case "L0001":
                code = HTTPStatus.BAD_REQUEST;
                break;
            case PGError.NO_DATA_FOUND:
                code = HTTPStatus.NOT_FOUND;
                break;
            default:
                code = HTTPStatus.INTERNAL_SERVER_ERROR;
            }
            res.status(code).end();
        });
};
