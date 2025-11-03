import express from "express";
import authRouter from "./routes/auth.js";
import taskRouter from "./routes/task.js";

const app = express();

app.use(express.json());
app.use('/auth', authRouter);
app.use('/tasks', taskRouter);

app.get('/', (req, res) => {
    res.send("Welcome to my task app!!!!!");
});

app.listen(8000, () => {
    console.log("Server started on port 8000");
});