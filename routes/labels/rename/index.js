import pool from "../../../util/pg-pool.js";
import HTTPStatus from "../../../util/http-status.js";
import { PostgresError as PGError } from "pg-error-enum";

export const post = (req, res) => {
    const payload = req.body;
    const parameters = [ payload.old_name, payload.new_name ];
    pool.query("CALL label_rename($1, $2)", parameters)
        .then(() => res.status(HTTPStatus.OK).end())
        .catch(({ code: PGCode }) => {
            let code;
            switch (PGCode) {
            case "L0001":
                code = HTTPStatus.BAD_REQUEST;
                break;
            case PGError.NO_DATA_FOUND:
                code = HTTPStatus.NOT_FOUND;
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
