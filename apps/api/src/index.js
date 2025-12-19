import express from "express";

const app = express();
app.use(express.json());

app.get("/health", (req, res) => {
    res.json({ status: "ok", service: "speedy-api", ts: new Date().toISOString() });
});

const port = process.env.PORT || 5000;
app.listen(port, () => console.log(`API listening on ${port}`));
export default app;