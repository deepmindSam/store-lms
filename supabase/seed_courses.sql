-- Seeds the curriculum structure. Run after schema.sql.
-- Safe to re-run: upserts on primary key.
-- Edit/extend this file whenever you add or reorder courses & modules —
-- each module's slug must match a folder name under public/content/.

insert into stores (slug, name) values
  ('hq', 'Head Office')
on conflict (slug) do update set name = excluded.name;
-- Add one row per real store, e.g.: ('store-042', 'Store 042 - Main Street')

insert into courses (slug, title, description, tier, sort_order) values
  ('compliance-essentials', 'Compliance Essentials', 'The rules everyone must know and follow, no exceptions.', 'core', 1),
  ('store-operations', 'Store Operations', 'How we run a store day to day, and why the rules exist.', 'core', 2),
  ('customer-experience', 'Customer Experience & People', 'How we treat customers and each other.', 'core', 3),
  ('upskilling', 'Upskilling Track', 'Optional deeper-dive modules, unlocked once core training is complete.', 'upskilling', 4)
on conflict (slug) do update set
  title = excluded.title,
  description = excluded.description,
  tier = excluded.tier,
  sort_order = excluded.sort_order;

insert into modules (slug, course_slug, title, sort_order, pass_mark_percent) values
  ('data-privacy', 'compliance-essentials', 'Data Privacy', 1, 90),
  ('employee-code-of-conduct', 'compliance-essentials', 'Employee Code of Business Principles', 2, 90),
  ('anti-harassment-diversity', 'compliance-essentials', 'Anti-Harassment, Equity & Diversity', 3, 90),
  ('conflict-of-interest', 'compliance-essentials', 'Conflict of Interest & Anti-Bribery', 4, 90),
  ('it-security-passwords', 'compliance-essentials', 'IT Security & Password Hygiene', 5, 80),

  ('validation-rules-per-store', 'store-operations', 'Validation Rules Per Store', 1, 85),
  ('pos-cash-handling', 'store-operations', 'POS & Cash Handling Procedures', 2, 85),
  ('store-open-close', 'store-operations', 'Store Opening & Closing Checklist', 3, 80),
  ('health-safety', 'store-operations', 'Health, Safety & Emergency Procedures', 4, 85),

  ('customer-service-brand', 'customer-experience', 'Customer Service & Brand Standards', 1, 80),
  ('leave-attendance', 'customer-experience', 'Leave, Attendance & Scheduling Policy', 2, 80),

  ('advanced-customer-recovery', 'upskilling', 'Advanced: Service Recovery & De-escalation', 1, 80)
on conflict (slug) do update set
  course_slug = excluded.course_slug,
  title = excluded.title,
  sort_order = excluded.sort_order,
  pass_mark_percent = excluded.pass_mark_percent;
