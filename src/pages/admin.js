import { requireAdmin, signOut } from "../auth.js";
import { supabase } from "../supabaseClient.js";
import { fetchCurriculum } from "../progress.js";
import { escapeHtml, formatDuration, statusLabel } from "../util.js";

await requireAdmin();

document.getElementById("signout").addEventListener("click", (e) => {
  e.preventDefault();
  signOut();
});

const [curriculum, { data: profiles }, { data: stores }, { data: progressRows }, { data: attempts }] =
  await Promise.all([
    fetchCurriculum(),
    supabase.from("profiles").select("*").order("full_name"),
    supabase.from("stores").select("*"),
    supabase.from("progress").select("*"),
    supabase.from("quiz_attempts").select("*")
  ]);

const storeBySlug = Object.fromEntries((stores || []).map((s) => [s.slug, s.name]));
const moduleToCourse = {};
curriculum.forEach((c) => c.modules.forEach((m) => (moduleToCourse[m.slug] = c)));

// progress[userId][moduleSlug] = row
const progressByUser = {};
(progressRows || []).forEach((r) => {
  (progressByUser[r.user_id] ??= {})[r.module_slug] = r;
});

// bestAttempt[userId][moduleSlug] = {count, best}
const attemptsByUser = {};
(attempts || []).forEach((a) => {
  const slot = (attemptsByUser[a.user_id] ??= {});
  const bucket = (slot[a.module_slug] ??= { count: 0, best: 0 });
  bucket.count += 1;
  bucket.best = Math.max(bucket.best, Number(a.score_percent));
});

// Build the flat (learner x module) row set.
const allRows = [];
(profiles || [])
  .filter((p) => p.role === "learner")
  .forEach((profile) => {
    curriculum.forEach((course) => {
      course.modules.forEach((mod) => {
        const progress = progressByUser[profile.id]?.[mod.slug];
        const attemptInfo = attemptsByUser[profile.id]?.[mod.slug];
        allRows.push({
          learner: profile.full_name,
          store: storeBySlug[profile.store_slug] || "(unassigned)",
          storeSlug: profile.store_slug || "",
          course: course.title,
          courseSlug: course.slug,
          module: mod.title,
          status: progress?.status || "not_started",
          timeSpentSeconds: progress?.time_spent_seconds || 0,
          attempts: attemptInfo?.count || 0,
          bestScore: attemptInfo ? `${attemptInfo.best}%` : "—",
          completedAt: progress?.completed_at ? new Date(progress.completed_at).toLocaleDateString() : "—"
        });
      });
    });
  });

// Filters
const storeSelect = document.getElementById("filter-store");
[...new Set(allRows.map((r) => r.storeSlug).filter(Boolean))].forEach((slug) => {
  const opt = document.createElement("option");
  opt.value = slug;
  opt.textContent = storeBySlug[slug] || slug;
  storeSelect.appendChild(opt);
});

const courseSelect = document.getElementById("filter-course");
curriculum.forEach((c) => {
  const opt = document.createElement("option");
  opt.value = c.slug;
  opt.textContent = c.title;
  courseSelect.appendChild(opt);
});

const statusSelect = document.getElementById("filter-status");
[storeSelect, courseSelect, statusSelect].forEach((el) => el.addEventListener("change", render));

function render() {
  const storeFilter = storeSelect.value;
  const courseFilter = courseSelect.value;
  const statusFilter = statusSelect.value;

  const rows = allRows.filter(
    (r) =>
      (!storeFilter || r.storeSlug === storeFilter) &&
      (!courseFilter || r.courseSlug === courseFilter) &&
      (!statusFilter || r.status === statusFilter)
  );

  const totalLearners = new Set(
    (profiles || []).filter((p) => p.role === "learner").map((p) => p.id)
  ).size;
  const completedCount = rows.filter((r) => r.status === "completed").length;
  document.getElementById("summary").textContent =
    `${totalLearners} learner(s) · showing ${rows.length} module record(s), ${completedCount} completed.`;

  document.getElementById("progress-rows").innerHTML = rows
    .map(
      (r) => `
      <tr>
        <td>${escapeHtml(r.learner)}</td>
        <td>${escapeHtml(r.store)}</td>
        <td>${escapeHtml(r.course)}</td>
        <td>${escapeHtml(r.module)}</td>
        <td><span class="badge ${r.status}">${statusLabel(r.status)}</span></td>
        <td>${formatDuration(r.timeSpentSeconds)}</td>
        <td>${r.attempts}</td>
        <td>${r.bestScore}</td>
        <td>${r.completedAt}</td>
      </tr>`
    )
    .join("");
}

render();
