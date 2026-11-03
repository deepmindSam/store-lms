import { supabase } from "./supabaseClient.js";

export const pageUrl = (p) => new URL(p, document.baseURI).href;

export function goTo(page) {
  window.location.href = pageUrl(page);
}

/** Redirects to login.html if not signed in. Returns {session, profile}. */
export async function requireAuth() {
  const { data: sessionData } = await supabase.auth.getSession();
  const session = sessionData?.session;
  if (!session) {
    goTo("login.html");
    throw new Error("redirecting to login");
  }

  const { data: profile, error } = await supabase
    .from("profiles")
    .select("*")
    .eq("id", session.user.id)
    .single();

  if (error || !profile) {
    console.error("Could not load profile", error);
    goTo("login.html");
    throw new Error("no profile");
  }

  return { session, profile };
}

/** Like requireAuth, but also redirects non-admins back to the dashboard. */
export async function requireAdmin() {
  const { session, profile } = await requireAuth();
  if (profile.role !== "admin") {
    goTo("dashboard.html");
    throw new Error("not an admin");
  }
  return { session, profile };
}

export async function signOut() {
  await supabase.auth.signOut();
  goTo("login.html");
}
