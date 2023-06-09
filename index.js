import ip from "ip";
import morgan from "morgan";
import * as path from "path";
import express from "express";
import paginate from "express-paginate";
import bodyParser from "body-parser";
import { config } from "dotenv";
import { router } from "express-file-routing";
import { fileURLToPath } from "url";
import { parse as parseUserAgent } from "useragent";
import { Server as IO } from "socket.io";

config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const nodeEnv = process.env.NODE_ENV || "development";
const port = process.env.PORT || 3000;

const app = express();

app.use(morgan( nodeEnv === "development" ? "dev" : "combined" ));

app.set("views", "./views");
app.set("view engine", "ejs");

app.use("/", express.static(path.join(__dirname, "public")));

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use(paginate.middleware(10, 50));
app.use((req, res, next) => {
    res.locals.path = req.baseUrl + req.path;
    const user_agent = req.headers["user-agent"];
    res.locals.os = parseUserAgent(user_agent).os.family;
    next();
});

app.use("/", await router());

const server = app.listen(port, () => {
    if (nodeEnv === "development") {
        console.debug(`
App listening on:
* http://localhost:${port}
* http://${ip.address()}:${port}
`);
    }
});

const io = new IO(server);

io.on("connection", (socket) => {
    socket.on("label_added", (label) => {
        socket.broadcast.emit("label_append", label);
    });
    socket.on("label_removed", (label) => {
        socket.broadcast.emit("label_detach", label);
    });
    socket.on("label_renamed", (data) => {
        socket.broadcast.emit("label_replace", data);
    });
});
