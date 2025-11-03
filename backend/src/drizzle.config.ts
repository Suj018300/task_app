import {defineConfig} from "drizzle-kit"

export default defineConfig({
    dialect: "postgresql",
    schema: "./db/schema.ts",
    out: "./drizzle",
    dbCredentials: {
        host: "localhost",
        port: 5433,
        database: "taskapp",
        user: "postgres",
        password: "sujal",
        ssl: false
    }
})