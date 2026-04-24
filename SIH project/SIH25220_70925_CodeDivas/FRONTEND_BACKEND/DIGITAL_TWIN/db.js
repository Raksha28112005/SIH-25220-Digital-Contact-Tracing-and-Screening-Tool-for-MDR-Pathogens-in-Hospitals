// db.js
import pkg from "pg";
const { Pool } = pkg;

export const pool = new Pool({
  host: "mdr-cloud-db.cj6uoyqiqhi2.ap-south-1.rds.amazonaws.com",
  user: "mdr_admin",
  password: "NanduDevaraj", 
  database: "mdr_cloud_db",
  port: 5432,
  ssl: {
    rejectUnauthorized: false,
  },
});
