import { defineConfig } from "vite";
import { resolve } from "path";

export default defineConfig({
  base: "./",
  build: {
    target: "es2022",
    rollupOptions: {
      input: {
        main: resolve(__dirname, "index.html"),
        login: resolve(__dirname, "login.html"),
        dashboard: resolve(__dirname, "dashboard.html"),
        module: resolve(__dirname, "module.html"),
        quiz: resolve(__dirname, "quiz.html"),
        admin: resolve(__dirname, "admin.html")
      }
    }
  }
});
