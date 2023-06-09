export const get = (_, res) => {
    res.render("error", {
        icon: "bi-emoji-dizzy-fill",
        title: "Page Not Found!"
    });
};
