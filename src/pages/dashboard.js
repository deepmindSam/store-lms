import { requireAuth, signOut, pageUrl } from "../auth.js";
import { fetchCurriculum, fetchProgressMap, isUpskillingUnlocked, coreModules } from "../progress.js";
import { escapeHtml, formatDuration, statusLabel } from "../util.js";

const { session, profile } = await requireAuth();

document.getElementById("who").textContent = `${profile.full_name} (${profile.role})`;
if (profile.role === "admin") document.getElementById("admin-link").hidden = false;
document.getElementById("signout").addEventListener("click", (e) => {
  e.preventDefault();
  signOut();
});

const curriculum = await fetchCurriculum();
const progressMap = await fetchProgressMap(session.user.id);
const unlocked = isUpskillingUnlocked(curriculum, progressMap);

const required = coreModules(curriculum);
const completedCount = required.filter((m) => progressMap[m.slug]?.status === "completed").length;
document.getElementById("overall-summary").textContent =
  `Core training: ${completedCount} of ${required.length} modules completed.` +
  (unlocked && required.length > 0 ? " Upskilling modules are now unlocked." : "");

const container = document.getElementById("courses");
container.innerHTML = curriculum
  .map((course) => {
    const locked = course.tier === "upskilling" && !unlocked;
    const rows = course.modules
      .map((m) => {
        const row = progressMap[m.slug];
        const status = locked ? "locked" : row?.status || "not_started";
        const timeSpent = row ? formatDuration(row.time_spent_seconds) : "0s";
        const link = locked
          ? `<span class="muted small">Complete core training first</span>`
          : `<a href="${pageUrl(`module.html?m=${encodeURIComponent(m.slug)}`)}">${status === "completed" ? "Review" : "Start"} →</a>`;
        return `
          <div class="module-row">
            <div class="meta">
              <span class="badge ${status}">${statusLabel(status)}</span>
              <div>
                <div>${escapeHtml(m.title)}</div>
                <div class="muted small">Time spent: ${timeSpent} · Pass mark: ${m.pass_mark_percent}%</div>
              </div>
            </div>
            <div>${link}</div>
          </div>`;
      })
      .join("");

    return `
      <div class="card">
        <h2>${escapeHtml(course.title)} ${locked ? '<span class="badge locked">Locked</span>' : ""}</h2>
        <p class="muted">${escapeHtml(course.description)}</p>
        ${rows || '<p class="muted small">No modules yet.</p>'}
      </div>`;
  })
  .join("");
