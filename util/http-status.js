import { constants } from "http2";

const HTTPStatus = Object.freeze(
    Object.fromEntries(
        Object.entries(constants)
            .filter(([key]) => key.startsWith("HTTP_STATUS_"))
            .map(([key, value]) => [key.replace("HTTP_STATUS_", ""), value])
    )
);

export default HTTPStatus;
