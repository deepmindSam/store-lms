import { supabase } from "../supabaseClient.js";
import { goTo } from "../auth.js";

const form = document.getElementById("login-form");
const errorEl = document.getElementById("error");
const submitBtn = document.getElementById("submit-btn");

// If already signed in, skip straight to the dashboard.
supabase.auth.getSession().then(({ data }) => {
  if (data?.session) goTo("dashboard.html");
});

form.addEventListener("submit", async (e) => {
  e.preventDefault();
  errorEl.hidden = true;
  submitBtn.disabled = true;
  submitBtn.textContent = "Signing in...";

  const email = document.getElementById("email").value.trim();
  const password = document.getElementById("password").value;

  const { error } = await supabase.auth.signInWithPassword({ email, password });

  if (error) {
    errorEl.textContent = "Could not sign in: " + error.message;
    errorEl.hidden = false;
    submitBtn.disabled = false;
    submitBtn.textContent = "Sign in";
    return;
  }

  goTo("dashboard.html");
});
