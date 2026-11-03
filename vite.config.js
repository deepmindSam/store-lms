import { defineConfig } from "vite";
import { resolve } from "path";

export default defineConfig({
  base: "./",
  build: {
    target: "es2022",
    rollupOptions: {
      input: {
        main: resolve(import.meta.dirname, "index.html"),
        login: resolve(import.meta.dirname, "login.html"),
        dashboard: resolve(import.meta.dirname, "dashboard.html"),
        module: resolve(import.meta.dirname, "module.html"),
        quiz: resolve(import.meta.dirname, "quiz.html"),
        admin: resolve(import.meta.dirname, "admin.html")
      }
    }
  }
});
