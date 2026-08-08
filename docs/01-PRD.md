# ASCEND — Product Requirements Document

**Version:** 0.1 (Draft for review)
**Owner:** Product / Tech Lead
**Status:** Awaiting approval

---

## 1. Vision

**Tagline:** Your Life is the Game.

**Mission:** Help people become the best version of themselves by turning real life into an RPG.

Users should wake up excited to open Ascend because their real-life progress grows their in-game character. The product converts identity ("who do I want to become?") into daily behavior, and measures *outcomes* — not checkbox counting.

## 2. Positioning

| | Duolingo | Notion | Habitica | Finch | **Ascend** |
|---|---|---|---|---|---|
| Core loop | Language streaks | Docs/life OS | Checkbox RPG | Self-care pet | **Identity → Real outcomes → RPG growth** |
| Rewards | Streak/league | — | Fake coins | Pet vibes | **Stats, skills, bosses on real metrics** |
| AI | — | Q's AI | — | — | **Coach (plans, reflections, reviews)** |
| Outcome evidence | In-app answers | — | Honor system | — | **Proof-based missions + AI review** |
| Target | Learners | Pros/organized | Gamers | Gens Z | **Strivers 18–40** |

**Wedge:** Habit apps reward *doing*; Ascend rewards *becoming*. The badge on your chest is your progress as a human.

## 3. Product Principles → Concrete Design Rules

The core philosophy translates to enforceable rules:

1. **Real life first** — Missions always describe real-world actions. In-app-only "fake" tasks (clicking buttons) are banned.
2. **Reward outcomes, not productivity theatre** — Every "high-value" completion can be stamped with evidence (photo, link, number, screenshot). The AI Mentor performs a weekly integrity review. Missing evidence = XP at 50%.
3. **Growth over perfection** — No XP decay, no level-down. A broken streak is recoverable (grace + freeze items). Boss defeat is a re-plan, never a failure screen.
4. **AI is a mentor, not a chatbot** — Conversations exist only as *sessions* (daily check-in, weekly review, plan reshaping). No open-ended chat in v1.
5. **Every feature must increase motivation** — Every feature has an attached motivation metric (see §14). Features that fail 8-week metrics are cut.
6. **The user is the hero** — The hero exists in the narrative, but we never embarrass; the "invincible user" framing powers all copy.
7. **Simplicity** — The daily screen must be operable one-handed below a phone lock. Feature budget: every new system ships against one removed or merged.

## 4. Target Users & Segments

Age 18–40 primary; 18–28 core (habit-forming), 28–40 growth market (long-term life goals).

**Personas:**

- **Marco, 24 — Career Builder.** "I want to become a data scientist." Needs longitudinal structure, roadmap, portfolio proof.
- **Priya, 27 — Entrepreneur.** "I want to be financially free." Needs outcome metrics (savings, revenue), weekly momentum.
- **Dev, 22 — Creator.** wants YouTube channel; needs content pipeline, skill tree, publishing deadlines.
- **Sana, 30 — Fit & Mindful.** wants health/balance; needs gentle habit loops, Vitality stat, no-perfection rules.
- **Arjun, 19 — Student.** wants discipline + focus; needs streaks, focus missions, social challenge engine.

## 5. Core Experience & Core Loop (MVP)

### 5.1 The core loop (daily)
```
Wake up → open app → "Today's Quest" (5 missions, each 10–90 min real work)
→ progress your real life → check in (tap, add evidence) → XP + coins
→ character stats climb → streak day +1 → boss takes damage (weekly/monthly)
→ Sunday weekly reflection w/ AI → plan adaptive for following week
```

### 5.2 The unit beats (MVP scope)

**F-01 Character** — Canonical feature.
- XP: `xpFor(level) = 100 + (level-1)*25` cumulative curve (level 1→2: 100, 2→3: 125, …).
- Level cap: none in v1; legendary ranks label from level 50.
- **8 Stats** (renamed for safety — see §9 "Vitality"): Vitality, Knowledge, Discipline, Strength, Creativity, Finance, Relationships, and *Confidence* as a meta-stat (introduced at level 3 as a feedback indicator).
  - Stats 0–100; each mission lists 1–2 stat gains; Stats are the *visible outcome mirror* — the entire motivation layer.
- Avatar: 3D-style + customizable fittings via cosmetics (shop).
- Equipmentless. Cosmetics only (can't buy power — **no pay-to-win**).

**S Goals** — Goals
- Onboarding: user picks an **Archetype** (6–8 curated: Data Scientist, Financially Free, Athlete, Creator, Founder, Body/Mind, General Rise) → gives 1 Main Goal + 3 pillar goals (fitness/finance/skill/consistency).
- Each goal auto-splits into milestones (AI-augmented heuristics; depth = user-settable). Goal progress = two sources: **measured milestones** + **signal-of-real-effort** (completing missions tagged to it).
- Target dates estimated; user confirms at review.

**C. Daily Missions — the engine of retention:**
- **Generated:** rule engine produces 3–6 missions/day: focus/craft line, wellness line, skill line, relationship line, mindset line. Weekend generation adapts (recovery days).
- AI session acts as *shaper* (seasonality, streak-plan, phase alignment), not generator. Cost controls in §9 and roadmap.
- Mission Anatomy: `title, ask(int), category (focus/stats), duration, XP, coins, evidenceRequired.`
- **Bad-day handling:** if user marks a rough day, auto-regenerate into 2-minute micro-missions (keep the loop, protect the streak).
- Skip allowance: 1/day banked. Proof rule: duration ≥ 15 min + high-value → evidence required.

**D. Skill Trees:** 4-6 trees in v1 catalog (Fitness, Data/AI, Creation, Money, Confidence/Mind):
- Node = real skill + node intro + stat bonus + tool guide.
- Node unlock gating: tree points + category mission completions. Unlock = splash moment.
- Catalog lives in **Cloud Firestore (Content CMS)** — engineers ship the schema, non-engineers ship trees. **Never hardcoded in the app.**
- Per-user state: unlocked nodes, tree XP, spent points.

**E. Boss Battles (monthly) — the accountability stake:**
- A battle is bound to a **single measured outcome** (e.g., lose 4kg, ₹25K saved, 12 publishable videos, portfolio deployed). HP = OutcomeProgress.
- Damage events: mission completions (tagged), user's self-reported measurements/events (with evidence), weekly quest completion.
- Difficulty curve adapts per-user from historical completion rates (forgiving at first).
- **Defeat is a redesign, not a failure:** 30-day rematch plan, 20% of remaining HP carries over, mentor "adaptation lesson." Never lose a player to shame.
- Rewards: 2× coins, exclusive cosmetic, shareable victory card.

**F. Weekly Quests (weekly challenges):** 2–4 counter-missions based on last week's analysis (complete 5 missions, 2 workouts, 1 deep-focus day...). Rewards: bonus coins + XP + weekly chest (cosmetic-only).

**G. Achievements / Honors:** One unified pillar:
- One-time Achievements (first workout, first 1k XP, 365 streak → special frame),
- Mechanics tracked from day one but **reveal** as they trigger.
- Badges (combo achievements, e.g., "7× discipline week"), Titles (cosmetic vanity from Boss wins / streaks).

**H. Economy:**
- Earn: missions, quests, streak, milestone, boss wins.
- Spend: cosmetic shop (avatars, card themes, titles, emblems), streak freezes.
- **Never spend coins on XP/power**. (No pay-to-win — hard)
- Premium (further iteration, v1.0 post): AI mentor unlimited, advanced visualization, even more cosmetics + no-dollar monthly membership.

**I. AI Mentor (with hard guardrails):**
- "Sessions" only:
  1. **Onboarding planner** — turns archetype+goal into plan maps (1 session)
  2. **Daily break** — 5-line status/attaboy (budget)
  3. **Weekly review** — full bandwidth: chart vs plan, integrity check, next-week re-plan (highest value session)
  4. **Ask me anything about your plan** — 3 follow-ups/day max (v1.1)
- Output always JSON-structured; **no free-form token overage** client-side. 20/hour/100/mo server cap.
- Integrity check: cross-references mission-evidence rates, streak pattern, self-reported #. "If you can't log evidence for 3 streaks, the week gets a plan-adjust, not shame."

**J. Dashboard:** Home = character + streak + today's quests (big block) + a line for boss HP progress + next rank/achievement indicator. Tap-through to modules. **Empty state never blank: character visible + "Status?" prompt.**

**K. Notifications (retention cornerstone):**
- Morning quest (07:30 local), evening streak warning (design system) if no completion by 18:00, streak-save prompt, weekly review reminder Sat/Sun, quiet hours 22:00–07:00 default, per-channel opt-in, 4/day max, local scheduling where possible (FCM/analytics fallback).

**L. Social (v1 post-MVP, design now):**
- **Friend system**: view a friend's daily quest list; "send-a-boost" (1/day).
- **Leagues (weekly, opt-in, ~20 per group):** derived weekly XP leaderboard, soft rewards only. Post-MVP.
- **Share cards** from boss wins and level-ups (growth hook), shareable to Instagram/WhatsApp.

## 6. Scope matrix — MVP vs deferred

| Capability | MVP (v1.0) | v1.1 / Later |
|---|---|---|
| Character (levels, stats, XP) | ✅ | avatar evolution poses |
| Streak + freeze items | ✅ | streak freeze shop v2 |
| Daily quest engine | ✅ | wellness/context risk profiles |
| Goals + auto milestones | ✅ * | manual granularity |
| Skill trees (4 trees) | ✅ 4 | more + community trees |
| Boss battles | ✅ | Бoss leagues |
| Weekly quests | ✅ | — |
| Achievements/Badges/Titles | ✅ | honor titles engine |
| Economy + cosmetics shop | ✅ basic | seasonal inventory — |
| AI Mentor sessions | ✅ (3 types) | open Q&A — |
| Leagues | ❌ | ✅ v1.1 |
| Friends/boosts | ❌ (design lock) | ✅ |
| Wearables integration | ❌ | fitness sync roadmap |
| i18n | EN only | likely H1/DE/ES after |

## 7. Non-functional requirements

- **Performance:** cold start → first content ≤ 2.5 s on mid-range hardware; UI ≥ 60 fps; release APK ≤ 120–150 MB.
- **Offline:** mission fetch cached; mission-complete queued; sync reconciliation on resolve; evidence fields degrade to "offline" flag.
- **Timezone/DST:** all storage UTC; DayKey calibrated in the user's local tz; streak reset = user-local midnight; facility for 2nd tz travel notification.
- **Concurrency:** counters only via atomic increments (server); transactions only for XP + level changes.
- **Privacy & Compliancy:** minimal data collected; explicit opt-in for optional signals; per-user data export; permanent delete on request; **health-adjacent data opt-in only**; never sell or ad-target on self-reported values.
- **Crash free:** ≥ 99.5% of sessions.
- **Security:** Firestore security rules closed to personal docs; OpenAI key server-only (Cloud Functions); rate limiting on all functions; abuse monitoring.

## 8. Success metrics & KPIs

**North star:** **Weekly Active Quests** = users who complete ≥1 daily missions on ≥5 of 7 days of the rolling week.

Secondary:
- Activation: ≥ 1 mission completed within 24h; Day-2 re-engagement ≥ 70%
- Retention: D1 ≥ 60%, D7 ≥ 45%, D30 ≥ 30%
- Core-loop density: avg. completions / active day ≥ 3; ≥ 80% of active days keep the streak
- Integrity: ≥ 50% of claimed missions carry evidence at review time
- AI cost cap: < $0.02 / MAU / day at 10k DAU scale
- NPS ≥ 40 at 60 days of real users
- Crash-free ≥ 99.5%; top-issue crash rate < 0.5%

## 9. Risks & Mitigations (top)

| Risk | Severity | Mitigation |
|---|---|---|
| Dropoff at onboarding | High | Archetypes, 5-screen max, 1st win in 90s, saved → "resume" |
| "Game-y" because rewards are hollow | High | Evidence rule + AI weekly integrity review + no XP grind incentive |
| AI cost blow-up | High | deterministic engine first; OpenAI as shaper (~from §5C); cap calls/day per account role server side |
| Cheating / fabricating evidence | Med | AI integrity review; cosmetic-only economy; silent flag when evidence mismatch > 15% |
| Mobile app store rejection (health/weight) | Med | Vitality stat rename, content review, no health data collection |
| Motivation dead-ends | Med | Cresting: next goal always unlocks ≤ 5 days away; smart mission recycling |
| Streak destruction | Med | Forgiving freezes, "undo if claimed by midnight + grace", never-shaming |

## 10. MVP User Journey (text walkthrough)

1. **Onboarding (5 screens, ≤90 s, 0 registration friction until plan)**
   — "Who do you want to become?" → Archetype blind pick → confirm goal storyboard → scoped plan rendered + **first daily quest instantly available ("Your quest: 20 min walk")** → native toggle push permission; Google Sign-In/email + account.
2. **Day 1:** complete the first quest (return to app to check-in, +streak++)
3. **Day 2–13:** cohort flowing through daily loop; week 1 nightly AI-review trigger.
4. **Day 14:** weekly review produces updated "closest boss HP".
5. **Day 30:** boss resolved → Rewards → new boss begins → share card → League beta invite.
6. **+90d:** achievements + skills evolved; friendship layer if desired.

## 11. Open decisions (APPROVED 2026-08-08)

1. **MVP scope:** Lean core loop — XP/stats/streak/goals/missions/bosses in v1. Badges/titles ship as a lightweight cosmetic layer; skill trees as catalog-driven node unlocks. ✅
2. **Economy:** Coins are cosmetic-only from Day 1. No ads in v1. ✅
3. **Stat rename:** "Health" → "Vitality" (sleep/energy/hydration/mental). Actual weight targets only via explicit opt-in with content guardrails. ✅
4. **i18n:** English (primary) + Hindi (prepared from day 1); Indian-market-friendly defaults. ✅
5. **Monetization:** Free in v1; premium tier at v1.2 (unlimited AI questions, advanced reports). ✅

## 12. Non-goals for v1
- No real-money purchases affecting gameplay
- No open-ended freeform chat with the AI (sessions only)
- No wearable/HR integration
- No social media scraping
- No in-app video content
- No currency exchanges/auctions

*End of PRD.*