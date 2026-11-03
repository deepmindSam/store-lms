# Store Training LMS

A learning management system for store staff: lessons in Markdown, quizzes with a configurable pass mark, per-learner progress and time-on-task tracking, an upskilling tier that unlocks once core training is complete, and an admin dashboard showing everyone's progress across stores.

**Access boundary:** GitHub Pages and this public repository expose the app code to anyone with the URL. Approved lessons live in Supabase `lesson_content`, where Row Level Security permits signed-in learners to read published lessons. Supabase also protects learner records and quiz results. Never put confidential policies, personal data, or quiz answers in this repository or `public/`. Earlier generic lesson templates were committed to Git history and remain publicly accessible there; do not reuse them for confidential company policies.

**Stack:** static site (Vite, plain JS) deployed free via **GitHub Pages**, with **Supabase** (free tier) providing real per-user login and a Postgres database for progress/quiz data. There is no server to run or pay for.

## 1. Create your Supabase project (free tier)

1. Go to [supabase.com](https://supabase.com), create a free account and a new project. Pick any name/region; note the database password somewhere safe (you likely won't need it again).
2. Once the project is ready, go to **Project Settings → API**. Copy:
   - **Project URL** → this is `VITE_SUPABASE_URL`
   - **anon public** key → this is `VITE_SUPABASE_ANON_KEY`

   These are safe to expose in client-side code — they are *meant* to be public. Real access control comes from Row Level Security (RLS) in the database, which is already set up for you below (not from hiding this key).

3. Go to **SQL Editor → New query**, and run these files from this repo **in order**, pasting each one's contents and clicking Run:
   1. `supabase/schema.sql` — tables, security rules, and the server-side grading function
   2. `supabase/private_lessons.sql` — private lesson storage and access rules
   3. A reviewed curriculum seed for your actual business. `supabase/seed_courses.sql` is a retail draft; do not run it for Agile Minds without replacing the unrelated modules and approving the pass marks.

4. Create a **new, private** quiz question bank and enter it through the Supabase SQL editor. The original quiz seed file was mistakenly committed to this public repository and its answers remain visible in Git history. Do not use those questions as an assessment. Keep the replacement SQL outside this repository and review it against your actual policies. Each row needs `module_slug`, `question`, `options` (JSON array), `correct_index` (zero-based), and `sort_order`. Every module needs at least one question before learners can complete it.

5. Go to **Authentication → Sign In / Providers** and make sure **Email** is enabled. Turn **off** "Allow new users to sign up" — this app has no public sign-up page; you create learner accounts yourself (see step 3 below). GitHub Pages app files remain public.

When creating the project, keep **Enable Data API** on, turn **Automatically expose new tables** off, and turn **Enable automatic RLS** on. `schema.sql` explicitly grants the app its required reads and enables RLS on its tables.

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
- **Modules** are individual lessons, each with a private `lesson_content` row and a pass mark.
- **Upskilling courses are locked** on the dashboard until every `core` module is marked `completed` for that learner.
- The retail draft curriculum in `supabase/seed_courses.sql` (review and replace before use for Agile Minds):
  - **Compliance Essentials:** Data Privacy, Employee Code of Business Principles, Anti-Harassment/Equity/Diversity, Conflict of Interest & Anti-Bribery, IT Security & Passwords
  - **Store Operations:** Validation Rules Per Store, POS & Cash Handling, Store Opening & Closing, Health & Safety
  - **Customer Experience & People:** Customer Service & Brand Standards, Leave/Attendance/Scheduling
  - **Upskilling (locked until the above is done):** Advanced Service Recovery & De-escalation

Use approved company policies for the Employee Code of Business Principles, Validation Rules Per Store, leave, and customer service modules. Store each approved lesson in Supabase, never in the public repository.

### Adding or editing a lesson

1. Add the course and module row in Supabase if needed. The module slug must match `lesson_content.module_slug`.
2. In Supabase Table Editor, add or edit the `lesson_content` row. Paste the approved Markdown and leave `is_published` false while reviewing. Set it to true only when approved; signed-in learners can then read it. Keep policy text out of Git, GitHub Issues, and public pull requests.

### Adding or editing a quiz

Quiz questions and answers belong in a **private** SQL file outside this public repository. Run it in the Supabase SQL editor. When replacing a module's quiz, delete that module's old `quiz_questions` rows first, then insert the revised rows. Review any completed attempts after a substantial policy change and decide whether learners need reassessment.

## Why quizzes are graded on the server, not in the browser

An earlier, simpler design shipped quiz answers as a static JSON file alongside the lesson, graded in the browser. That's the obvious approach for a static site — and it's broken for a compliance tool: anyone can open their browser's network tab (or just fetch the file directly) and read the correct answers before answering, and nothing stops them from writing a fake "passed" record straight to the database via the browser console, since GitHub Pages has no server to stop them.

The schema closes those direct database holes **once you use a fresh, private question bank**:
- Quiz **questions** (without answers) are fetched from a database view (`quiz_questions_public`) that simply doesn't contain the `correct_index` column.
- **Grading** happens inside a Postgres function (`grade_quiz`, see `supabase/schema.sql`) that runs with elevated privileges, compares answers against the real `quiz_questions` table (which the browser can never read directly), and is the only client-callable path that writes a quiz attempt or marks a module `completed`.
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
