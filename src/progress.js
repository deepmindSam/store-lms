import { supabase } from "./supabaseClient.js";

/** Courses with their modules, both ordered by sort_order. */
export async function fetchCurriculum() {
  const [{ data: courses, error: cErr }, { data: modules, error: mErr }] = await Promise.all([
    supabase.from("courses").select("*").order("sort_order"),
    supabase.from("modules").select("*").order("sort_order")
  ]);
  if (cErr) throw cErr;
  if (mErr) throw mErr;

  return courses.map((course) => ({
    ...course,
    modules: modules.filter((m) => m.course_slug === course.slug)
  }));
}

/** { [module_slug]: progressRow } for one learner. */
export async function fetchProgressMap(userId) {
  const { data, error } = await supabase.from("progress").select("*").eq("user_id", userId);
  if (error) throw error;
  const map = {};
  for (const row of data) map[row.module_slug] = row;
  return map;
}

export async function recordTimeSpent(moduleSlug, seconds) {
  if (seconds <= 0) return;
  const { error } = await supabase.rpc("track_module_time", {
    p_module_slug: moduleSlug,
    p_seconds: Math.round(seconds)
  });
  if (error) console.error("track_module_time failed", error);
}

/** Questions only — never includes correct answers (see quiz_questions_public in schema.sql). */
export async function fetchQuizQuestions(moduleSlug) {
  const { data, error } = await supabase
    .from("quiz_questions_public")
    .select("*")
    .eq("module_slug", moduleSlug)
    .order("sort_order");
  if (error) throw error;
  return data;
}

/**
 * Submits answers for server-side grading. The server (grade_quiz RPC) holds
 * the only copy of the correct answers and is the only thing that can write
 * a passing attempt or flip a module to 'completed' — see schema.sql.
 * `answers` is an array of chosen option indexes, in question order.
 */
export async function submitQuizAnswers(moduleSlug, answers, timeTakenSeconds) {
  const { data, error } = await supabase.rpc("grade_quiz", {
    p_module_slug: moduleSlug,
    p_answers: answers,
    p_time_taken_seconds: Math.round(timeTakenSeconds)
  });
  if (error) throw error;
  return data[0]; // { score_percent, passed, correct_count, total_count }
}

/** A module counts as "core" if its course's tier is 'core'. */
export function coreModules(curriculum) {
  return curriculum.filter((c) => c.tier === "core").flatMap((c) => c.modules);
}

export function isUpskillingUnlocked(curriculum, progressMap) {
  const required = coreModules(curriculum);
  if (required.length === 0) return true;
  return required.every((m) => progressMap[m.slug]?.status === "completed");
}

/**
 * Tracks wall-clock time spent on the current page while it is visible,
 * and flushes it to Supabase periodically + on page hide/unload.
 */
export class TimeTracker {
  constructor(moduleSlug, { flushEverySeconds = 20 } = {}) {
    this.moduleSlug = moduleSlug;
    this.flushEverySeconds = flushEverySeconds;
    this.accumulated = 0;
    this.lastTick = document.visibilityState === "visible" ? Date.now() : null;
    this._onVisibility = this._onVisibility.bind(this);
    this._onUnload = this._onUnload.bind(this);
    document.addEventListener("visibilitychange", this._onVisibility);
    window.addEventListener("pagehide", this._onUnload);
    this._interval = setInterval(() => this._tickAndMaybeFlush(), 5000);
  }

  _tick() {
    if (this.lastTick !== null) {
      const now = Date.now();
      this.accumulated += (now - this.lastTick) / 1000;
      this.lastTick = now;
    }
  }

  _tickAndMaybeFlush() {
    this._tick();
    if (this.accumulated >= this.flushEverySeconds) this.flush();
  }

  _onVisibility() {
    if (document.visibilityState === "visible") {
      this.lastTick = Date.now();
    } else {
      this._tick();
      this.lastTick = null;
      this.flush();
    }
  }

  _onUnload() {
    this._tick();
    this.flush();
  }

  flush() {
    const seconds = Math.floor(this.accumulated);
    if (seconds <= 0) return;
    this.accumulated -= seconds;
    recordTimeSpent(this.moduleSlug, seconds);
  }

  stop() {
    this._tick();
    this.flush();
    clearInterval(this._interval);
    document.removeEventListener("visibilitychange", this._onVisibility);
    window.removeEventListener("pagehide", this._onUnload);
  }
}
