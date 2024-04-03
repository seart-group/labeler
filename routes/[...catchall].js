import HTTPStatus from "../util/http-status.js";

export const get = (_, res) => {
    res.status(HTTPStatus.NOT_FOUND)
        .render("error", {
            icon: "bi-emoji-dizzy-fill",
            title: "Page Not Found!"
        });
};
