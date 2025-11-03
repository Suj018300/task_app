import { drizzle } from "drizzle-orm/node-postgres";
import { Pool } from "pg";

const pool = new Pool({
    connectionString: "postgresql://postgres:sujal@db:5432/taskapp"
});

export const db = drizzle(pool);