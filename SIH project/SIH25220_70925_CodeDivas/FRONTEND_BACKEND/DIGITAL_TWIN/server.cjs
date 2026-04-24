// server.cjs

// Debug: log any uncaught errors
process.on("uncaughtException", (err) => {
  console.error("UNCAUGHT EXCEPTION:", err);
});

process.on("unhandledRejection", (err) => {
  console.error("UNHANDLED REJECTION:", err);
});

// Debug: mark startup progress
console.log("1) Starting server.cjs...");

const express = require("express");
const cors = require("cors");
const { Pool } = require("pg");

console.log("2) After requires");

// AWS RDS connection
const pool = new Pool({
  host: "mdr-cloud-db.cj6uoyqighi2.ap-south-1.rds.amazonaws.com",
  user: "mdr_admin",
  password: "NanduDevaraj",
  database: "mdr_cloud_db",
  port: 5432,
  ssl: {
    rejectUnauthorized: false,
  },
});

console.log("3) After creating pool");

const app = express();
app.use(cors());
app.use(express.json());

app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

app.get("/api/twin/patients", async (req, res) => {
  try {
    console.log("4) /api/twin/patients called");

    const { ward } = req.query;

    const params = [];
    const where = [];

    where.push("is_mdr_known = 1");

    if (ward) {
      params.push(ward);
      where.push(`ward = $${params.length}`);
    }

    const whereClause = where.length ? `WHERE ${where.join(" AND ")}` : "";

    const query = `
      SELECT id, name, age, ward, is_mdr_known
      FROM patients
      ${whereClause}
      ORDER BY id;
    `;

    console.log("5) Running query:", query, "with params:", params);

    const result = await pool.query(query, params);
    console.log("6) Fetched rows:", result.rows.length);

    res.json(result.rows);
  } catch (err) {
    console.error("DB ERROR in /api/twin/patients:", err);
    res.status(500).json({ error: "Failed to fetch patients" });
  }
});

const PORT = 4000;
app.listen(PORT, () => {
  console.log(`7) Backend running on http://localhost:${PORT}`);
});

// Debug: keep Node event loop alive even if nothing else
setInterval(() => {
  // console.log("tick"); // uncomment to verify it's alive
}, 10000);
