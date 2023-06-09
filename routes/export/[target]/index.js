import QueryStream from "pg-query-stream";
import pool from "../../../util/pg-pool.js";
import HTTPStatus from "../../../util/http-status.js";
import { stringify as stringifyJSONStream } from "JSONStream";

export const get = (req, res) => {
    const target = req.params.target;
    const targets = {
        review: "instance_review_finished_export",
        discard: "instance_discard_export",
        conflict: "instance_review_conflict_resolution_export",
    };

    if (!Object.keys(targets).includes(target)) {
        res.status(HTTPStatus.BAD_REQUEST).end();
    } else {
        pool.connect((err, client, done) => {
            const stream = client.query(new QueryStream(`SELECT * FROM ${targets[target]}`));
            const date = new Date().toISOString()
                .replace(/T.*/, "")
                .split("-")
                .reverse()
                .join("-");
            const filename = `${target}-${date}.jsonl`;
            stream.on("end", done);
            stream.on("error", () => res.status(HTTPStatus.INTERNAL_SERVER_ERROR).end());
            res.writeHead(HTTPStatus.OK, {
                "Transfer-Encoding": "chunked",
                "Content-Type": "application/jsonl",
                "Content-Disposition": `attachment; filename="${filename}"`
            });
            stream.pipe(stringifyJSONStream("", "\n", "\n")).pipe(res);
        });
    }
};
