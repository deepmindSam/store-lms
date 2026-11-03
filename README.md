# Store Training LMS

A free, password-protected learning management system for store staff: lessons in Markdown, quizzes with a configurable pass mark, per-learner progress and time-on-task tracking, an upskilling tier that unlocks once core training is complete, and an admin dashboard showing everyone's progress across stores.

**Stack:** static site (Vite, plain JS) deployed free via **GitHub Pages**, with **Supabase** (free tier) providing real per-user login and a Postgres database for progress/quiz data. There is no server to run or pay for.

## 1. Create your Supabase project (free tier)

1. Go to [supabase.com](https://supabase.com), create a free account and a new project. Pick any name/region; note the database password somewhere safe (you likely won't need it again).
2. Once the project is ready, go to **Project Settings → API**. Copy:
   - **Project URL** → this is `VITE_SUPABASE_URL`
   - **anon public** key → this is `VITE_SUPABASE_ANON_KEY`

   These are safe to expose in client-side code — they are *meant* to be public. Real access control comes from Row Level Security (RLS) in the database, which is already set up for you below (not from hiding this key).

3. Go to **SQL Editor → New query**, and run these three files from this repo **in order**, pasting each one's contents and clicking Run:
   1. `supabase/schema.sql` — tables, security rules, and the server-side grading function
   2. `supabase/seed_courses.sql` — the curriculum structure (courses + modules)
   3. `supabase/seed_quiz_questions.sql` — quiz questions **and answers** (this file never leaves your Supabase project — see "Why quizzes are graded server-side" below)

4. Go to **Authentication → Providers** and make sure **Email** is enabled. Go to **Authentication → Settings** and turn **off** "Allow new users to sign up" (or similar wording in your Supabase version) — this app has no public sign-up page; you create learner accounts yourself (see step 3 below), which is what makes it "password protected" rather than open to anyone who finds the URL.

## 2. Create your own admin account

1. In Supabase, go to **Authentication → Users → Add user**, and create a user with your own email and a password. (Or "send invite" if you've configured email sending — the free default email service is rate-limited but fine for a handful of invites.)
2. Go to **SQL Editor** and run, replacing the UUID with your new user's ID (shown in the Users list):
   ```sql
   update profiles set role = 'admin', full_name = 'Your Name' where id = 'paste-your-user-uuid-here';
   ```
3. That account can now sign in and see **Admin dashboard** on the top bar.

## 3. Create learner accounts

There's no public sign-up — you (or a manager) create each account, same as giving someone a work email.

- **One at a time:** Supabase dashboard → Authentication → Users → Add user.
- **In bulk:** use the Supabase dashboard's bulk invite, or script it with the [Supabase Admin API](https://supabase.com/docs/reference/javascript/admin-api) using your **service_role** key (never put that key in this repo or in client code — only use it from your own machine/script, never commit it).

After creating a user, set their name and store in the `profiles` table (a row is created automatically on signup):
```sql
update profiles set full_name = 'Jane Doe', store_slug = 'hq' where id = 'their-user-uuid';
```
Add real stores first (edit `supabase/seed_courses.sql`'s `insert into stores` block, or insert directly):
```sql
insert into stores (slug, name) values ('store-042', 'Store 042 - Main Street');
```

## 4. Deploy to GitHub Pages

1. Push this repo to GitHub (if you haven't already).
2. In your GitHub repo: **Settings → Pages → Build and deployment → Source: GitHub Actions**.
3. In your GitHub repo: **Settings → Secrets and variables → Actions → New repository secret**, add:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`

   (using the values from step 1 above)
4. Push to `main` (or run the "Deploy to GitHub Pages" workflow manually from the Actions tab). The site will build and deploy automatically — the Actions tab shows progress, and the Pages settings page shows the live URL once done.

Every future push to `main` redeploys automatically, for free.

## 5. Local development

```bash
npm install
cp .env.example .env   # fill in your Supabase URL + anon key
npm run dev
```

## How the curriculum is organized

- **Courses** group related modules (e.g. "Compliance Essentials"). A course has a `tier`: `core` or `upskilling`.
- **Modules** are individual lessons, each with a Markdown file at `public/content/<module-slug>/lesson.md` and a pass mark.
- **Upskilling courses are locked** on the dashboard until every `core` module is marked `completed` for that learner.
- The starting curriculum (edit freely in `supabase/seed_courses.sql` and the matching `public/content/<slug>/` folders):
  - **Compliance Essentials:** Data Privacy, Employee Code of Business Principles, Anti-Harassment/Equity/Diversity, Conflict of Interest & Anti-Bribery, IT Security & Passwords
  - **Store Operations:** Validation Rules Per Store, POS & Cash Handling, Store Opening & Closing, Health & Safety
  - **Customer Experience & People:** Customer Service & Brand Standards, Leave/Attendance/Scheduling
  - **Upskilling (locked until the above is done):** Advanced Service Recovery & De-escalation

Two modules are intentionally written as **templates for you to customize** rather than generic best-practice content, since they depend on specifics only you know: **Employee Code of Business Principles** and **Validation Rules Per Store**. Open their `lesson.md` files and fill in your actual rules/policies before relying on them — the surrounding structure (why the rule exists, how to raise exceptions) is ready to go.

### Adding or editing a lesson

1. Add/edit the Markdown file at `public/content/<module-slug>/lesson.md`.
2. If it's a new module, add a row for it in `supabase/seed_courses.sql` and re-run just that file in the SQL editor (it's safe to re-run — it upserts).

### Adding or editing a quiz

Quiz questions (and answers) live only in the database, not in a file this app serves publicly — see the security note below. To add/change a quiz, edit `supabase/seed_quiz_questions.sql` and re-run it in the SQL editor (it deletes and re-inserts the modules you list at the top of the file, so it's safe to re-run after edits).

## Why quizzes are graded on the server, not in the browser

An earlier, simpler design shipped quiz answers as a static JSON file alongside the lesson, graded in the browser. That's the obvious approach for a static site — and it's broken for a compliance tool: anyone can open their browser's network tab (or just fetch the file directly) and read the correct answers before answering, and nothing stops them from writing a fake "passed" record straight to the database via the browser console, since GitHub Pages has no server to stop them.

This app closes both holes:
- Quiz **questions** (without answers) are fetched from a database view (`quiz_questions_public`) that simply doesn't contain the `correct_index` column.
- **Grading** happens inside a Postgres function (`grade_quiz`, see `supabase/schema.sql`) that runs with elevated privileges, compares answers against the real `quiz_questions` table (which the browser can never read directly), and is the *only* thing allowed to write a quiz attempt or mark a module `completed`.
- There is no database policy allowing a learner's browser to insert into `progress` or `quiz_attempts` directly — every write goes through `grade_quiz()` or `track_module_time()`.

**Time spent, however, is a soft metric, not a hard gate.** It's self-reported by the browser (time the lesson page was visibly open) and could be inflated by someone leaving a tab open — there's no way to fully verify "active attention" from a static site without invasive tracking, which wasn't the goal here. Treat time-on-task as a useful signal for coaching conversations, not as proof of comprehension — that's what the pass mark is for.

## Admin dashboard

Signed-in admins see a table of every learner × module: status, time spent, quiz attempts, best score, and completion date — filterable by store, course, and status. This is where you check who still needs to complete what.

## Extending this further

Ideas worth considering as this grows:
- **Certificates:** generate a PDF/record on module or course completion.
- **Due dates / reminders:** a `due_at` column on a learner's assignment, surfaced on the dashboard, with a scheduled email reminder.
- **Manager view:** restrict the admin dashboard to "my store only" for store managers, versus "all stores" for head-office admins (straightforward RLS addition, keyed off a new `role: 'manager'`).
- **Richer lessons:** images/video embeds work fine in the Markdown already; for interactive content, consider embedding external tools.
