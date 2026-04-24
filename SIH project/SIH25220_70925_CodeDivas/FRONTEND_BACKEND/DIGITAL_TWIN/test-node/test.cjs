const http = require("http");

http
  .createServer((req, res) => {
    res.end("Server is alive");
  })
  .listen(5000, () => {
    console.log("Test server running on port 5000");
  });
