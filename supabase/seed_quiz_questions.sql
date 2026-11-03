-- Quiz questions and answers. Run after seed_courses.sql.
-- IMPORTANT: this file contains correct answers. It is only ever run inside
-- the Supabase SQL editor against your own database — never deployed to
-- GitHub Pages or committed anywhere a learner could fetch it as a static
-- file. The app reads questions via the answer-free quiz_questions_public
-- view, and grades answers via the server-side grade_quiz() function; see
-- schema.sql for why that split exists.
--
-- To edit a quiz: delete that module's rows and re-insert, e.g.
--   delete from quiz_questions where module_slug = 'data-privacy';
-- then re-run the relevant block below.

delete from quiz_questions where module_slug in (
  'data-privacy', 'employee-code-of-conduct', 'anti-harassment-diversity',
  'conflict-of-interest', 'it-security-passwords', 'validation-rules-per-store',
  'pos-cash-handling', 'store-open-close', 'health-safety',
  'customer-service-brand', 'leave-attendance', 'advanced-customer-recovery'
);

insert into quiz_questions (module_slug, question, options, correct_index, sort_order) values
-- data-privacy
('data-privacy', 'A customer''s purchase history counts as personal data.',
  '["True", "False", "Only if they''re a loyalty member", "Only if it includes payment info"]', 0, 1),
('data-privacy', 'You can look up a friend''s purchase history for free, as long as you don''t tell anyone else what you saw.',
  '["True, as long as it stays private", "False — accessing data you don''t need for your job is a violation even if you never share it", "True, if the friend gives verbal permission", "False, but only if a manager is watching"]', 1, 2),
('data-privacy', 'You accidentally emailed a spreadsheet of customer phone numbers to the wrong address. What should you do?',
  '["Wait and see if anyone notices", "Delete the sent email and say nothing", "Tell your manager immediately", "Only report it if a customer complains"]', 2, 3),
('data-privacy', 'A customer asks what personal data you hold on them. What should you do?',
  '["Refuse — that information is private to the business", "Read out everything from the till screen on the spot", "Escalate the request to your manager/privacy contact so it''s handled correctly", "Tell them to find it themselves online"]', 2, 4),
('data-privacy', 'Which of these is safe to write down on a customer''s order slip?',
  '["Full card number", "CVV code", "PIN", "None of the above — never write down full card details, CVV, or PIN"]', 3, 5),

-- employee-code-of-conduct
('employee-code-of-conduct', 'A regular customer you like asks for a discount outside policy. What should you do?',
  '["Give it to them since they''re a loyal customer", "Explain you don''t have authority to do that and offer to check with a manager", "Give a smaller unofficial discount instead", "Tell them to come back when a different staff member is on shift"]', 1, 1),
('employee-code-of-conduct', 'Which of these is gross misconduct under the code of conduct?',
  '["Taking an unpaid break 5 minutes late", "Making an honest pricing mistake", "Falsifying a stock count to hide a shortage", "Asking a manager a clarifying question"]', 2, 2),
('employee-code-of-conduct', 'You see a colleague breaking an age-restricted sales rule under pressure from a customer. What should you do?',
  '["Ignore it — it''s not your sale", "Report what you saw so it can be addressed", "Only mention it if the customer complains later", "Handle it yourself by refusing to serve that customer in future"]', 1, 3),
('employee-code-of-conduct', 'Someone raises a genuine, good-faith concern about a rule being broken. What should never happen to them?',
  '["They should be thanked", "They should be retaliated against", "Their concern should be looked into", "They should be kept informed of the outcome where appropriate"]', 1, 4),
('employee-code-of-conduct', 'The code of conduct applies:',
  '["Only to new employees during probation", "Only to customer-facing roles", "Equally, regardless of role, seniority, or store", "Only when a manager is present"]', 2, 5),

-- anti-harassment-diversity
('anti-harassment-diversity', 'A colleague makes repeated comments about another colleague''s accent, even after being asked to stop. This is:',
  '["Just banter, not a real problem", "Harassment, even if ''meant as a joke''", "Only a problem if HR is told directly by the victim", "Acceptable if most of the team laughs along"]', 1, 1),
('anti-harassment-diversity', 'A customer makes an offensive comment about a staff member''s religion. What should happen?',
  '["The staff member should just let it go to keep the sale", "Nothing — customers can say what they like", "The staff member is entitled to support, and it should be reported to a manager", "Only report it if the customer becomes violent"]', 2, 2),
('anti-harassment-diversity', 'You witness a colleague being excluded from conversations because of their background, but it''s not happening to you. What should you do?',
  '["Nothing, since it''s not your issue", "Report what you saw and check in on the colleague", "Wait for them to complain first", "Mention it only if asked directly"]', 1, 3),
('anti-harassment-diversity', '"I was only joking" is a valid defense for comments that someone found offensive, as long as most people would find it funny.',
  '["True", "False — impact matters more than intent", "True, if said quietly", "True, only for first-time offenses"]', 1, 4),
('anti-harassment-diversity', 'What happens to someone who reports harassment in good faith?',
  '["They may face retaliation if the claim isn''t proven", "Their report is investigated fairly and they are protected from retaliation", "Nothing — reports are only logged, not investigated", "They must prove it beyond doubt before anything happens"]', 1, 5),

-- conflict-of-interest
('conflict-of-interest', 'A supplier offers you a personal cash gift to keep ordering from them even though a competitor has better prices. You should:',
  '["Accept it quietly, it''s a personal gift not a business one", "Decline and report the offer to your manager", "Accept, but only order a little extra from them", "Accept if the gift is small enough"]', 1, 1),
('conflict-of-interest', 'Can you approve a refund or discount for your own purchase?',
  '["Yes, if the amount is small", "Yes, as long as you log it correctly", "No — someone else should always approve transactions involving you", "Yes, if you''re a manager"]', 2, 2),
('conflict-of-interest', 'Your cousin applies for a job at your store. What should you do?',
  '["Say nothing, it''s not relevant", "Disclose the relationship to your manager so it can be managed openly", "Make sure you''re not involved in interviewing them, without telling anyone why", "Ask your cousin to use a different last name on the application"]', 1, 3),
('conflict-of-interest', 'A conflict of interest only matters if you actually act dishonestly because of it.',
  '["True", "False — even the appearance of a conflict can damage trust", "True, unless money is involved", "False, but only for managers"]', 1, 4),
('conflict-of-interest', 'A good test before accepting a favor from a supplier is:',
  '["Would I be comfortable if my manager saw exactly what I''m about to do?", "Did anyone else see it happen?", "Is the value under a certain amount?", "Would the supplier be upset if I said no?"]', 0, 5),

-- it-security-passwords
('it-security-passwords', 'A colleague forgot their login and asks to use yours just for today. You should:',
  '["Share it, it''s just for one day", "Refuse — logins should never be shared", "Share it but change the password after", "Share it only if a manager asks"]', 1, 1),
('it-security-passwords', 'Which password is strongest?',
  '["P@ssw0rd1", "your store name + 123", "three random unrelated words plus a number", "your birthday"]', 2, 2),
('it-security-passwords', 'You get an urgent email asking you to click a link and enter your password to avoid your account being locked. You should:',
  '["Click immediately to avoid losing access", "Reply with your password to be safe", "Not click, and report it instead", "Forward it to a colleague to check first"]', 2, 3),
('it-security-passwords', 'You step away from the till for a minute to help a customer in the aisle. What should you do first?',
  '["Nothing, it''s only a minute", "Lock the screen", "Leave it open but turn the monitor off", "Ask the next customer to watch it"]', 1, 4),
('it-security-passwords', 'You think your account may have been compromised. What''s the right move?',
  '["Wait to see if anything bad actually happens", "Tell your manager or IT contact immediately", "Quietly change your password and say nothing", "Only report it if money goes missing"]', 1, 5),

-- validation-rules-per-store
('validation-rules-per-store', 'A delivery arrives and the quantity doesn''t match the purchase order. What should you do?',
  '["Accept it anyway to save time", "Log the discrepancy and follow the store''s escalation process", "Quietly adjust the system count to match", "Ignore it if it''s a small difference"]', 1, 1),
('validation-rules-per-store', 'A validation step feels like unnecessary paperwork. What''s the right approach?',
  '["Skip it if no one is watching", "Understand what it protects against, and raise it with your manager if it genuinely seems unnecessary", "Skip it only during busy periods", "Do it only for high-value transactions"]', 1, 2),
('validation-rules-per-store', 'Who can override a scanned price that doesn''t match the shelf price?',
  '["Any staff member, at their own discretion", "Only whoever is specified by store policy, following the approval process", "The customer, if they insist", "No one — the till is always right"]', 1, 3),
('validation-rules-per-store', 'Cash/till reconciliation at the end of a shift exists mainly to:',
  '["Make closing take longer", "Catch and resolve discrepancies early, before they compound", "Give managers something to check", "Satisfy head office paperwork requirements only"]', 1, 4),
('validation-rules-per-store', 'If you think a validation rule no longer makes sense for how the store actually operates, you should:',
  '["Just stop following it", "Follow it until told otherwise, but also raise it with your manager so it can be reviewed", "Only follow it when convenient", "Ask a colleague instead of a manager"]', 1, 5),

-- pos-cash-handling
('pos-cash-handling', 'You make a scanning error and overcharge a customer by one item. What''s the correct fix?',
  '["Give the customer cash back from your pocket", "Void the line properly through the system", "Adjust the till count at the end of shift to compensate", "Tell the customer to come back later for a refund"]', 1, 1),
('pos-cash-handling', 'When counting down your till at the end of a shift, you should:',
  '["Enter the expected amount, then adjust the physical cash to match", "Count the physical cash first, then enter what you actually counted", "Skip counting if the shift was quiet", "Only count if asked by a manager"]', 1, 2),
('pos-cash-handling', 'A customer tendering a large note should be checked for authenticity:',
  '["Only if it looks suspicious", "Every time, following store procedure", "Only during night shifts", "Only for notes above a certain value set by the customer"]', 1, 3),
('pos-cash-handling', 'A colleague asks to use your till login because theirs isn''t working. You should:',
  '["Let them, it''s faster", "Refuse, and suggest they get their login fixed or ask a manager", "Let them but watch everything they do", "Let them only for a quick sale"]', 1, 4),
('pos-cash-handling', 'Small cash variances on your till happen occasionally every shift. What should you do?',
  '["Ignore it, small amounts don''t matter", "Report it honestly — a repeated pattern is worth investigating", "Stop counting the till as precisely to save time", "Only report it if it''s a large one-off amount"]', 1, 5),

-- store-open-close
('store-open-close', 'Why follow an opening/closing checklist every time, instead of relying on memory?',
  '["It''s required paperwork with no real purpose", "Memory fails under time pressure — the checklist catches what a rushed mind misses", "Only new staff need to use it", "It''s only useful during busy seasons"]', 1, 1),
('store-open-close', 'You arrive to open and notice something looks disturbed from overnight. What should you do?',
  '["Continue the checklist and mention it later", "Stop and report it to a manager before proceeding", "Only worry about it if something is obviously missing", "Reset everything yourself to be safe"]', 1, 2),
('store-open-close', 'At closing, a till won''t balance. What''s the right move?',
  '["Force the numbers to match so you can go home", "Stop and get help rather than leaving it unresolved", "Leave a note for the morning shift", "Adjust tomorrow''s float to even it out"]', 1, 3),
('store-open-close', 'Before locking up at close, you should check:',
  '["Only the main entrance", "Fitting rooms, restrooms, and back areas are fully clear of customers", "Only if it''s been a busy day", "Nothing extra — the alarm will catch anyone left behind"]', 1, 4),
('store-open-close', 'If a door won''t lock properly at close, you should:',
  '["Leave anyway, it''s probably fine", "Call for help (manager/locksmith/support line) rather than leaving the store in an uncertain state", "Prop something against it", "Only report it the next morning"]', 1, 5),

-- health-safety
('health-safety', 'You notice a spill on the floor but you''re in the middle of serving a customer. What should you do?',
  '["Finish the sale, deal with it after", "Get it cleaned up or cordoned off right away, or get someone else to", "Ignore it — customers should watch where they walk", "Only act if someone has already slipped"]', 1, 1),
('health-safety', 'You need to reach something on a high shelf and there''s no ladder nearby. What should you do?',
  '["Stand on a nearby chair or box", "Find the proper equipment or ask for help, even if it takes longer", "Reach as far as you can on tiptoe", "Ask a customer to grab it for you"]', 1, 2),
('health-safety', 'A near-miss (something that almost caused an injury but didn''t) happened. Should you report it?',
  '["No, since nobody was actually hurt", "Yes — near-misses reveal hazards before they cause real harm", "Only if a manager happened to see it", "Only if it happens more than once"]', 1, 3),
('health-safety', 'During a fire evacuation, you should:',
  '["Use the elevator to move faster", "Go back for your bag if it''s quick", "Use the nearest clear exit and go straight to the assembly point", "Wait to see if the alarm is a false one first"]', 2, 4),
('health-safety', 'During a robbery, your first priority is:',
  '["Protecting the cash in the till", "Your safety and the safety of colleagues/customers — comply, don''t resist", "Chasing the person to get a description", "Triggering every alarm possible"]', 1, 5),

-- customer-service-brand
('customer-service-brand', 'A customer''s complaint isn''t something you can personally resolve. What''s the right response?',
  '["Tell them it''s not your department and move on", "Find who can help and hand it off properly, or follow up yourself", "Apologize and offer nothing further", "Ask them to come back when a manager is in"]', 1, 1),
('customer-service-brand', 'An upset customer is explaining a problem. What should you do first?',
  '["Immediately explain the policy that applies", "Let them finish and acknowledge how they feel before addressing policy", "Interrupt to correct any inaccurate details", "Offer a refund right away to end the conversation"]', 1, 2),
('customer-service-brand', 'When we get something wrong, the best response is to:',
  '["Explain in detail why it happened before fixing it", "Own the mistake and fix it, offering explanation only if they want it", "Avoid mentioning it was our fault", "Blame the specific process or system that failed"]', 1, 3),
('customer-service-brand', 'Giving a customer an off-policy exception just to end an uncomfortable conversation is:',
  '["Good service, since the customer leaves happy", "A problem — it can spiral into unfairness for other customers and isn''t real service", "Fine occasionally", "Only a problem if a manager finds out"]', 1, 4),
('customer-service-brand', 'The real measure of a good customer interaction is:',
  '["Whether the transaction was fast", "Whether the customer left trusting the brand more or less than before", "Whether the customer said thank you", "Whether a sale was made"]', 1, 5),

-- leave-attendance
('leave-attendance', 'Why does leave usually require advance notice?',
  '["To discourage people from taking time off", "So shifts can be covered properly", "Because managers enjoy saying no", "It''s just a formality with no real purpose"]', 1, 1),
('leave-attendance', 'You''re going to be late for your shift. What should you do?',
  '["Explain when you arrive", "Let your manager know as soon as you realize you''ll be late", "Only mention it if asked", "Text a colleague instead of your manager"]', 1, 2),
('leave-attendance', 'Two colleagues want the same holiday dates. Decisions should be based on:',
  '["Whoever is more senior", "Whoever the manager personally prefers", "The store''s stated rule, applied consistently (e.g. request order or rotation)", "Whoever asks most persistently"]', 2, 3),
('leave-attendance', 'You and a colleague agree between yourselves to swap shifts. What''s still required?',
  '["Nothing, it''s your own time", "Manager approval, so the business knows who''s responsible for the shift", "Just telling a coworker in case someone asks", "Nothing, as long as both shifts get covered"]', 1, 4),
('leave-attendance', 'Submitting a leave request means:',
  '["It''s automatically approved unless told otherwise", "You can make firm plans immediately", "It''s pending until you receive approval", "It only needs manager sign-off for long absences"]', 2, 5),

-- advanced-customer-recovery (upskilling)
('advanced-customer-recovery', 'In the LAST framework, what does the "T" stand for and why does it matter?',
  '["Transfer — pass the customer to someone else quickly", "Thank — because most unhappy customers don''t complain, they just leave", "Terminate — end the conversation politely", "Track — log the complaint in the system"]', 1, 1),
('advanced-customer-recovery', 'A customer raises their voice at you. The best response is to:',
  '["Match their energy so they know you''re taking it seriously", "Lower your voice and slow your pace", "Immediately call a manager without trying to help first", "Point out they''re being unreasonable"]', 1, 2),
('advanced-customer-recovery', 'Bringing in a manager during a difficult situation should be seen as:',
  '["A personal failure", "A legitimate skill — recognizing when more authority is needed, early", "Something to avoid at all costs", "Only appropriate if the customer demands it"]', 1, 3),
('advanced-customer-recovery', 'A customer becomes abusive during a complaint. What''s appropriate?',
  '["Accept it to keep them as a customer", "Calmly set a boundary and involve a manager or end the interaction if it continues", "Match their tone to show you won''t be pushed around", "Hang up/walk away immediately with no explanation"]', 1, 4),
('advanced-customer-recovery', 'A great service recovery can leave a customer:',
  '["Permanently distrustful of the brand", "Trusting the brand more than if nothing had gone wrong", "Indifferent, since the damage is already done", "Only satisfied if given a free item"]', 1, 5);
