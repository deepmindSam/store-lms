import { marked } from "marked";
import DOMPurify from "dompurify";
import { requireAuth, signOut, goTo, pageUrl } from "../auth.js";
import { fetchCurriculum, TimeTracker } from "../progress.js";
import { supabase } from "../supabaseClient.js";
import { escapeHtml } from "../util.js";

const { session } = await requireAuth();

document.getElementById("signout").addEventListener("click", (e) => {
  e.preventDefault();
  signOut();
});

const params = new URLSearchParams(window.location.search);
const slug = params.get("m");
if (!slug) goTo("dashboard.html");

const curriculum = await fetchCurriculum();
const course = curriculum.find((c) => c.modules.some((m) => m.slug === slug));
const mod = course?.modules.find((m) => m.slug === slug);

if (!mod) {
  document.getElementById("module-title").textContent = "Module not found";
  document.getElementById("lesson-body").textContent =
    "This module doesn't exist (or isn't in the curriculum yet).";
} else {
  document.getElementById("module-title").textContent = mod.title;
  document.getElementById("module-meta").textContent =
    `${course.title} · Pass mark: ${mod.pass_mark_percent}%`;
  document.getElementById("quiz-link").href = pageUrl(`quiz.html?m=${encodeURIComponent(slug)}`);

  try {
    const { data, error } = await supabase
      .from("lesson_content")
      .select("markdown")
      .eq("module_slug", slug)
      .single();
    if (error) throw error;
    document.getElementById("lesson-body").innerHTML = DOMPurify.sanitize(
      marked.parse(data.markdown),
      { USE_PROFILES: { html: true } }
    );
  } catch (err) {
    document.getElementById("lesson-body").innerHTML =
      `<p class="error">Could not load lesson content (${escapeHtml(String(err.message))}). ` +
      `Ask your training admin to publish this lesson.</p>`;
  }

  // Tracks time-on-page and flushes it to Supabase; stopped when leaving the page.
  const tracker = new TimeTracker(slug);
  window.addEventListener("beforeunload", () => tracker.stop());
}
