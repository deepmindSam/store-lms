import { requireAuth, signOut, goTo } from "../auth.js";
import { fetchCurriculum, fetchQuizQuestions, submitQuizAnswers } from "../progress.js";
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

const form = document.getElementById("quiz-form");
const resultEl = document.getElementById("result");

if (!mod) {
  document.getElementById("quiz-title").textContent = "Quiz not found";
} else {
  document.getElementById("quiz-title").textContent = `Quiz: ${mod.title}`;
  document.getElementById("quiz-meta").textContent = `Pass mark: ${mod.pass_mark_percent}%`;
  document.getElementById("back-link").href = `/module.html?m=${encodeURIComponent(slug)}`;

  const startedAt = Date.now();

  try {
    const questions = await fetchQuizQuestions(slug);
    if (questions.length === 0) throw new Error("no questions found");
    renderQuiz(questions, startedAt);
  } catch (err) {
    form.innerHTML = `<p class="error">Could not load quiz (${escapeHtml(String(err.message))}). ` +
      `Check that quiz_questions has rows for module_slug = '${escapeHtml(slug)}' (see supabase/seed_quiz_questions.sql).</p>`;
  }
}

function renderQuiz(questions, startedAt) {
  form.innerHTML =
    questions
      .map(
        (q, qi) => `
      <div class="card quiz-question">
        <h3>${qi + 1}. ${escapeHtml(q.question)}</h3>
        <div class="options">
          ${q.options
            .map(
              (opt, oi) => `
            <label>
              <input type="radio" name="q${qi}" value="${oi}" required />
              ${escapeHtml(opt)}
            </label>`
            )
            .join("")}
        </div>
      </div>`
      )
      .join("") + `<button class="btn" type="submit">Submit answers</button>`;

  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    const submitBtn = form.querySelector("button[type=submit]");
    submitBtn.disabled = true;

    const answers = questions.map((q, qi) => {
      const chosen = form.querySelector(`input[name="q${qi}"]:checked`);
      return chosen ? Number(chosen.value) : -1;
    });
    const timeTakenSeconds = (Date.now() - startedAt) / 1000;

    let result;
    try {
      result = await submitQuizAnswers(slug, answers, timeTakenSeconds);
    } catch (err) {
      submitBtn.disabled = false;
      resultEl.hidden = false;
      resultEl.innerHTML = `<p class="error">Could not submit quiz: ${escapeHtml(String(err.message))}</p>`;
      return;
    }

    const { score_percent: scorePercent, passed, correct_count: correct, total_count: total } = result;

    form.hidden = true;
    resultEl.hidden = false;
    resultEl.innerHTML = `
      <h2 class="${passed ? "result-pass" : "result-fail"}">
        ${passed ? "Passed! ✓" : "Not yet — you can try again"}
      </h2>
      <p>You scored <strong>${scorePercent}%</strong> (needed ${mod.pass_mark_percent}%). Correct: ${correct} / ${total}.</p>
      ${
        passed
          ? `<a class="btn" href="/dashboard.html">Back to dashboard</a>`
          : `<button class="btn" id="retry-btn">Try again</button>
             <a class="btn secondary" href="/module.html?m=${encodeURIComponent(slug)}">Review the lesson</a>`
      }
    `;

    if (!passed) {
      document.getElementById("retry-btn").addEventListener("click", () => window.location.reload());
    }
  });
}
