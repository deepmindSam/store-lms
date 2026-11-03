import { createClient } from "@supabase/supabase-js";

const url = import.meta.env.VITE_SUPABASE_URL;
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!url || !anonKey) {
  // Fails loudly at build/runtime rather than silently hitting a bad API.
  throw new Error(
    "Missing VITE_SUPABASE_URL / VITE_SUPABASE_ANON_KEY. Copy .env.example to .env (local dev) " +
      "or set the repo secrets used by .github/workflows/deploy.yml (production)."
  );
}

export const supabase = createClient(url, anonKey);
