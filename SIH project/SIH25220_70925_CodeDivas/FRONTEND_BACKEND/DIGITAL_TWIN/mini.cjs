// mini.cjs - tiny express server with no DB

const express = require("express");

const app = express();

app.get("/health", (req, res) => {
  res.send("mini-ok");
});

const PORT = 5001;
app.listen(PORT, () => {
  console.log(`Mini server running on http://localhost:${PORT}`);
});
