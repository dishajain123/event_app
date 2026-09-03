# event_app — Phases 1–7 (Complete): All Planned Phases Delivered

## Before anything else — please read this

This code was written without access to a Flutter toolchain (the sandbox
this was built in blocks `pub.dev` and `dl.google.com`, so `flutter pub
get`/`analyze`/`test`/`build` could not be run even once). Everything here
was checked by hand — every relative import path was verified to resolve to
a real file, every model was checked field-by-field against the actual
backend schemas, class/provider names were checked for collisions — but
**none of it has actually compiled yet.** Please run the steps below and,
if anything fails, send me the exact error output — I'll fix it immediately
rather than guess.

## Setup

**Critical step, easy to miss:** this project has no native Android/iOS
scaffolding — `android/` and `ios/` exist as empty folders. Since this
sandbox has no Flutter CLI at all, `flutter create` was never run, so
there's no `AndroidManifest.xml`, no Gradle files, no `Info.plist`,
nothing native. `flutter pub get` and `flutter analyze` don't need this,
but **`flutter run` and `flutter build` will fail without it.** Generate
the missing platform folders first, non-destructively (this does not
touch `lib/`, `pubspec.yaml`, or anything else already here):

```bash
flutter --version   # this was written against the Flutter 3.22+ / Dart 3.4+ API surface
flutter create .     # fills in android/ and ios/ only — safe to run in an existing project
flutter pub get
```

**Then add two permissions `flutter create` won't add for you**, since
this app uses the camera (Staff Mode's QR scanner, Phase 5):

- **Android** (`android/app/src/main/AndroidManifest.xml`): add
  `<uses-permission android:name="android.permission.CAMERA" />`
  alongside the `INTERNET` permission the template already includes.
- **iOS** (`ios/Runner/Info.plist`): add an `NSCameraUsageDescription`
  key with a short string explaining why (e.g. "Used to scan participant
  tickets at check-in.") — iOS refuses to even show the camera permission
  prompt without this.

## Running against your backend

The Android emulator reaches a backend running on your host machine at
`10.0.2.2`, not `localhost` — that's already the default in
`config/development.json`. If the backend isn't on port 8000 locally,
edit that file.

```bash
# Start your backend first (from the event-platform-backend repo):
#   uvicorn app.main:app --host 0.0.0.0 --port 8000

flutter run --target lib/main_development.dart \
  --dart-define-from-file=config/development.json
```

**Testing on a physical device instead of the emulator:** copy
`config/development.physical-device.example.json` to
`config/development.local.json`, replace the IP with your machine's actual
LAN address, and point `--dart-define-from-file` at that file instead. This
file is gitignored — never commit a personal IP.

## Acceptance checklist — Phase 1 (auth, navigation, mode switch)

1. **App launches to a splash screen**, briefly shows a loading spinner, then lands on the mobile-number entry screen (no stored session yet).
2. **Enter a real mobile number** your backend's OTP stub will accept → tap "Send code" → app navigates to the OTP screen.
3. **Check your backend's logs** for the stub-SMS line containing the OTP code (the backend logs it rather than sending a real SMS in development).
4. **Enter that code** → app should log in and land on the **Home tab** of the Public Mode bottom nav (Home / Registrations / Tickets / Profile).
5. **Force-close and reopen the app** → should skip straight past login and land back on Home (silent token refresh working).
6. **Open the Profile tab.**
   - If this account holds **no** staff role assignment on your backend: you should see Account/Log out options only — **no Staff Mode section at all.**
   - If this account **does** hold an `event_manager`/`event_coordinator`/`staff_lead`/`staff_member` assignment for at least one event on your backend: you should see a **"Switch to Staff Mode"** card. Tap it.
7. **After switching**, you should land on the Staff Mode bottom nav (Scan / Tasks / My Events / Staff), with a distinct amber/warm color scheme instead of the indigo one.
8. **Open the "Staff" tab** and tap **"Switch to Public Mode"** — you should return to the ordinary Home tab. This confirms the switch is not one-way.
9. **Force-close and reopen** while in whichever mode you last selected — it should reopen in that same mode (persisted).
10. **Log out** from either mode's profile screen (with the confirmation sheet appearing first) → should return to the mobile-number entry screen, and the mode selection should reset to Public for whoever logs in next on this device.

If step 6 shows the Staff Mode switch for an account that should NOT have
any staff role, or hides it for one that should, that's the single most
important thing to tell me — it means the role-assignments bootstrap or
the `SessionRoles` derivation has a bug.

## Acceptance checklist — Phase 2 (event discovery)

11. **Home tab** should now show real category chips (from `GET /event-categories/main` on your backend) and a real list of published events (from `GET /events`), each as a full-bleed cover-image card — not a placeholder message. If your backend has no published events yet, you should see "No events published yet" rather than a blank screen or an error.
12. **Tap an event card** → should open a real Event Detail screen: status badge, category, dates, description, and — if your backend has them for that event — Venue, Schedule, Sponsors, and Gallery sections. Sections with no data should simply not appear (no "Venue: none" placeholder clutter).
13. **On Event Detail**, an event whose status is `registration_open` should show an enabled **"Register"** button (tapping it shows a "Registration opens in Phase 3" message — expected, since Phase 3 hasn't landed yet). Any other status should show a message explaining why registration isn't available, never a broken or silently-disabled button.
14. **Tap the search icon** on Home, or tap a category chip → Search screen opens, optionally pre-filtered by that category (shown as a removable chip at the top). Typing in the search box should filter the already-loaded list by name instantly (no network call per keystroke — this is client-side filtering over a backend category-filtered list, since the backend has no free-text search endpoint).
15. **Pull-to-refresh** on Home should visibly reload both the event list and the category chips.

## Backend changes made — Phase 3

Two real fixes to `event-platform-backend`, both applied and verified live against a running instance before this ZIP was built:

1. **`app/modules/teams/router.py`** — added the missing `from app.modules.rbac.models import RoleName` import. This was a confirmed, currently-failing bug (a hard `NameError` on `GET /teams`), flagged as mandatory in the original planning document.
2. **`app/modules/teams/service.py` + `app/modules/teams/router.py`** — added `GET /teams/{team_id}` and `GET /teams/{team_id}/members`, both properly permission-checked (a team's captain, an accepted member, or a pending invitee can view it; anyone else gets a real 403). This closes a genuine gap found while building the Team Roster screen: previously, a team's own captain had **no way at all** to check their team's state after creation — `GET /teams` was Event-Manager/console-only, so the only glimpse of team state was the one-time create/submit response. A new regression test (`tests/modules/teams/test_teams.py`) covers this; the full backend suite (60/60) passes.

If you're running this against your own backend checkout, you'll need
these two changes for the Teams screens in this build to work — reach out
and I'll paste the exact diffs, or re-describe them here if you'd like
the full corrected files inline.

## Acceptance checklist — Phase 3 (registration engine)

16. **On an event with `registration_open` status**, tap "Register" on Event Detail → should show a Participation Type screen listing only the types your backend's `EventConfiguration.participation_types` actually enables for that event (not a hardcoded list). If the event has no configuration yet, you should see a clear "not configured for registration yet" message, not a crash or blank screen.
17. **Tap "Individual" (or any non-team type)** → should open a real registration form. If your backend's field schema for that participation type has fields defined, they should render as real inputs (text/number/select/date/boolean) — not raw JSON, not blank.
18. **Tap "Check eligibility"** before submitting → should show a green "you meet the requirements" banner or a red banner with the backend's actual rejection reason (e.g. an age-rule message), never a generic error. This is a real call to your backend's `/configuration/validate` endpoint — try an event with an age rule and a date of birth outside it to confirm the rejection message is real.
19. **Submit a registration** (confirmation sheet should appear first) → should navigate to My Registrations and show the new registration with its real status badge (e.g. "Confirmed" for a free, no-approval event — this exercises the free-event ticket-issuance fix from earlier in this project).
20. **Tap "Team" as the participation type** → should open Create Team → after creating, should land on a real Team Roster screen showing you as Captain.
21. **On the Team Roster screen, tap "Invite member"** and enter a mobile number → should send a real invitation. **Force-close and reopen the app, navigate back to that same team** (My Registrations won't show it until submitted — for this test, note the team ID from the URL/logs) → the roster should still show correctly. This is the specific gap the backend fix in this phase closes — previously this would have been impossible for anyone but an Event Manager.
22. **Tap "Submit team"** (with fewer members than the event's configured minimum team size) → should show the backend's real rejection message, not a generic failure.
23. **From Profile, tap "My Children"** → should show an empty state with an "Add child" action, or a real list if you've already added one. Adding a child should return you to the list with the new entry visible immediately.
24. **Register using a child's profile** (once wired from the type selector — currently reachable by registering with `child_id` set via the guardian flow) should use the same dynamic form renderer as individual registration.

## Acceptance checklist — Phase 4 (payments & tickets)

25. **Register for an event with a real fee configured** on your backend → after submitting, the app should navigate straight to a Payment screen showing the correct amount and currency (not a generic "registration submitted" message) — this only triggers when the created registration's status comes back as `pending_payment`.
26. **Tap "Pay now"** → Razorpay's checkout sheet should open with the correct amount pre-filled. **This is the one part of this phase I could not verify at all** — see the note below.
27. **Complete a test payment** (Razorpay test mode/test card) → on success, the app should navigate to My Tickets and show a confirmation snackbar. Behind the scenes this calls `POST /payments/webhook` directly with the values Razorpay's checkout returns, which is a real, deliberate part of this design (see the note in `payments/data/payments_api.dart`) — not a shortcut.
28. **Open My Tickets** → the newly-issued ticket should appear with a "Ready to scan" badge.
29. **Tap the ticket** → should show a real QR code rendered from the backend's actual `qr_payload`, plus the ticket code. **Turn off your device's network entirely and reopen this same ticket screen** — the QR should still render, since it was already fetched; this confirms the ticket screen has no unnecessary live dependency once loaded.
30. **Register for a free event** (Phase 3's flow) → confirm a ticket appears in My Tickets immediately, with no payment step at all — this exercises the free-event ticket-issuance fix from earlier in this project, now visible end-to-end from the mobile side for the first time.

### Two things I could not verify in this phase, specifically

Every backend-facing model and endpoint in this phase was checked line-by-line against your real schemas, exactly like every previous phase. But two files touch **third-party plugin APIs** (`razorpay_flutter`, `qr_flutter`) that this sandbox cannot download from `pub.dev` to actually read — meaning I wrote them from training knowledge of those packages' public APIs, not from the real installed source, which is a categorically different (weaker) kind of confidence than everything else in this app:

- **`payments/application/razorpay_checkout_service.dart`** — the `Razorpay` class, event constants, and response field names.
- **`tickets/presentation/screens/ticket_detail_screen.dart`** — `qr_flutter` v4.x's `QrImageView` widget (renamed from `QrImage` in v3.x).

Both files say so directly in their own doc comments, and both are deliberately isolated (all Razorpay usage in one file; the QR widget usage is a single, small block) specifically so that if `flutter pub get` succeeds but either fails to compile, the fix is small and contained rather than scattered. **Please run this phase and tell me exactly what error you get, if any** — this is the single most likely place for a real compile error in everything built so far.

## Backend changes made — Phase 5

Three real fixes, all applied and verified live, the last one found only by actually tracing through and testing the real check-in flow end to end:

1. **`app/modules/staff/repository.py` + `service.py` + `router.py`** — added `GET /staff/assignments/mine`. Same class of gap as Phase 3's team-visibility fix: an invited staff member had **no way whatsoever** to discover the invitation exists — `create_assignment` sends no notification, and every other listing endpoint is Event-Manager/console-gated.
2. **`scripts/seed_super_admin.py`** — a more foundational issue: the official, documented bootstrap script never seeded the three mobile-only Staff Mode roles (`event_coordinator`, `staff_lead`, `staff_member`) at all. On any fresh deployment following the script's own instructions, it was **structurally impossible** to ever create or accept a staff invitation using those roles. Fixed by deriving the seed list from the backend's own `GLOBAL_ROLES | SCOPED_ROLES` partition instead of a hand-maintained list that had silently drifted, so this can't recur the same way.
3. **`app/modules/tickets/service.py` + `router.py` + `schemas.py`** — added `GET /tickets/resolve` (verified, signature-checked lookup by scanned payload) and `GET /tickets/by-code/{ticket_code}` (the manual-entry fallback, narrower trust model — no signature required, since it's gated by the caller already being an authenticated, permission-checked Staff Mode account). Neither existed; `POST /{ticket_id}/check-in` requires a ticket UUID a QR scan never actually provides — the scanned payload only ever contains `ticket_code:registration_id:payment_id_or_free`.

New regression tests for all three; **63/63 backend tests passing.**

## Acceptance checklist — Phase 5 (staff mode: check-in)

31. **On an account with no staff role at all**, confirm the Profile tab still shows no Staff Mode switch (this hasn't changed, but worth re-confirming after this much new code).
32. **Have an Event Manager invite a different account as staff** (via your backend directly, or a future console) → **on that invited account**, open Profile → Switch to Staff Mode → "My Events" tab should show the invitation under "Pending invitations" — this is the fix from this phase; previously there was no way for this to ever appear.
33. **Tap "Accept"** (confirmation sheet should appear first) → the assignment should move to the "Active" section, and the app's cached permissions should update immediately (no restart needed) — confirms `refreshRoles()` is wired correctly after accepting.
34. **Open the Scan tab** → should request camera permission (confirming the AndroidManifest/Info.plist setup above worked), then show a live camera preview with a scan-target overlay.
35. **On a separate device/account, open a confirmed ticket's QR code** (Phase 4) and scan it with the Staff Mode device → should show a green "Checked in successfully" banner within a second or two.
36. **Scan the same ticket again** → should show a distinct amber "Already checked in" banner, never a generic error.
37. **Turn on Airplane Mode on the Staff Mode device, then scan a different valid ticket** → should show a blue "queued to sync later" banner, not an error, and the AppBar should now show a queued-count badge. **Turn Airplane Mode back off** → sync should trigger automatically within a moment (no manual action needed) and the badge should clear; you can also tap the badge to trigger sync immediately rather than waiting.
38. **Tap the keyboard icon to open manual entry**, type a ticket code exactly as shown on a ticket detail screen (Phase 4) → should check in the same way as a camera scan.

### The offline queue now has real UI, not just correct data handling

`QrScannerScreen` shows a badge with the queued count whenever it's above zero, tapping it triggers a manual sync, and a `connectivity_plus` listener triggers sync automatically the moment connectivity returns — so a volunteer never has to remember to do it themselves. `CheckInRepository.syncQueue()` (already correct — syncs one item at a time so a partial failure never loses track of what succeeded) is now actually wired to something visible.

## Backend changes made — Phase 6

Three real fixes, all applied and verified live — each one the same class of gap as earlier phases (a participant with no way to see their own data), found by actually tracing each feature's real permission model rather than assuming it matched the plan:

1. **`app/modules/assistance/repository.py` + `service.py` + `router.py`** — added `GET /assistance-requests/mine`. The only listing endpoint was Event-Manager-only, so a participant who'd actually submitted a fee-waiver request had no way to ever check its status.
2. **`app/modules/notifications/router.py`** — added `POST /notifications/{id}/read`. The service's `mark_read()` already existed, fully correct and permission-checked — it had simply never been wired to any router endpoint, so there was no way through the API to ever change a notification's read state at all.
3. **`app/modules/funnels/service.py` + `router.py`** — added `GET /entries/public`, deliberately narrower than the existing (Event-Manager-only) `GET /entries`: it only ever returns entries for a stage whose `stage_type` is `public_vote`, so a participant can discover what to vote for without ever being able to browse entries mid-judging for a jury/manual-review stage.

New regression tests for all three; **66/66 backend tests passing.**

One precision correction to the original plan, found while implementing: **registration review is Event-Manager-only**, not open to the broader Staff Mode roles as the plan's Section 8 loosely described — confirmed directly against `list_entries`'/`registrations`' real permission checks, and the mobile screen is scoped accordingly.

## Acceptance checklist — Phase 6 (growth, engagement & Event Manager tasks)

39. **Profile → Notifications** → should show a real inbox. Tap an unread item (indicated by a dot) → it should mark as read and the dot should disappear. Pull to refresh.
40. **Profile → Assistance Requests** → should show any fee-waiver requests you've submitted, with a real status badge. From a `pending_payment` registration's detail screen, tap "Request assistance with this fee" → submit → it should appear here.
41. **On an event's detail screen**, you should now see three quick-action tiles: Refer & Earn, Gallery, Competition.
42. **Tap "Refer & Earn"** → should show a real referral code (auto-created on first visit) and a "Copy code" button. Copying should show a confirmation snackbar.
43. **Tap "Gallery"** → should show a real grid of the event's published media (or an empty state if none exist yet) — distinct from the smaller inline gallery already on the event detail screen itself.
44. **Tap "Competition"** → if the event has stages configured, they should list in order; a stage of type "Public Vote" should show a green "Vote now" badge and be tappable. **Have a different account submit a fee-based registration to create an entry, then vote for it** → vote count should increase after confirming.
45. **On an account holding an active `event_manager` assignment, open Staff Mode → Tasks** → should show an event picker (if you manage more than one) and a real task queue of registrations awaiting a decision — not the old placeholder message.
46. **Tap "Approve"** on a task (confirmation sheet first) → it should disappear from the queue. **Tap "Reject"** on another → the sheet should now require a reason before the Reject button becomes tappable (this exercises the `ConfirmActionSheet` extension described below) — confirm the registration then shows as rejected with your reason visible to the registrant on their own Registration Detail screen.

## Backend changes made — Phase 7

Two more real fixes, the same "a user has data but no way to see or change it" shape as every earlier phase, both applied and verified live:

1. **`app/modules/identity/schemas.py` + `service.py` + `router.py`** — added `PATCH /users/me`. There was no way whatsoever to change your own name or email; `GET /users/me` was the only endpoint touching a user's own profile at all.
2. **`app/modules/identity/router.py`** — added `GET /users/me/identity-documents`. The exact same "service method exists, never wired to a route" pattern as Phase 6's notification `mark_read` fix: `list_identity_documents()` was already correctly implemented, but only the upload endpoint had a route, so a user who'd uploaded a document could never see it (or its verification status) again.

New regression tests for both; **68/68 backend tests passing.** This brings the total for the whole build to **10 real, verified backend gaps found and fixed** — every one surfaced by actually building the screen that needed the data, not by reading the code in isolation.

## Cross-cutting consistency pass (Section 3.7/3.10, Phase 7)

Ran two automated audits across every screen in the app, the same category of check that found real, silent bugs late in the web console project:

1. **Every `AsyncValue.when()` call has all three required branches** (loading/error/data) — checked programmatically across all 145 Dart files. Clean; no gaps found.
2. **Every consequential action (approve, reject, check-in, submit, vote, logout) is wrapped in `showConfirmActionSheet`** — checked programmatically. One flagged result turned out to be a false positive in my own check's lookback window, not a real gap (registration reject is correctly wrapped; verified by hand). No real gaps found.

Deliberately did **not** build a fake "Notification preferences" toggle — the backend has no such endpoint anywhere in the notifications module, and a setting that looks like it saves but silently does nothing would be a worse experience than not having the screen. Settings is honest app-info-only until a real preferences endpoint exists to build against.

## Acceptance checklist — Phase 7 (profile, settings & polish)

47. **On the Profile tab, tap your name/avatar at the top** → should open a real Edit Profile screen pre-filled with your current name/email. Change either, save → should return to Profile showing the updated values immediately (no manual refresh needed).
48. **Tap "Identity documents"** → should show an empty state with an "Add document" action, or a real list with verification-status badges if you've added one already. Add a document (type + number) → should appear in the list immediately with a "Pending review" badge.
49. **Tap "Settings"** → should show app version/environment info and an honest note about notification preferences not being available yet — not a toggle that looks functional but does nothing.
50. **Force-close and reopen the app after editing your profile** → the change should persist (confirms it's a real backend update, not just local state).

## What's real vs. placeholder now

**Real and functional (Phases 1–3):** OTP login, mode switch, event
discovery/detail/search, the full registration engine (dynamic forms,
eligibility dry-run, teams, guardians).

**Real and functional (Phase 4):** payment initiation, Razorpay checkout
(pending the verification caveat above), the direct-webhook-confirmation
flow, My Tickets, and QR ticket display that works fully offline once
loaded.

**Real and functional (Phase 5):** the mode switch's Staff Mode side —
My Events (pending invitations with accept, active assignments), the QR
scanner with online check-in, offline queueing with auto-sync-on-reconnect,
and manual entry for a damaged/unreadable code — each with distinct
success/duplicate/queued/error feedback.

**Real and functional (Phase 6):** notifications inbox with tap-to-read,
assistance request submission and status tracking, referral code
display/copy with reward tracking, a standalone media gallery, the Event
Manager's registration review task queue (approve/reject with required
reason), and public competition voting.

**Still placeholder:** none of the seven planned phases — all are now
delivered in some form. See "Deliberately not built" just below for the
two specific, narrower gaps still open within otherwise-complete phases.

**Real and functional (Phase 7):** profile editing (name/email, persisted
to the backend), identity document upload + status list, and an honest
settings screen.

**Deliberately not built, flagged clearly rather than hidden:** the team
invitation acceptance screen (Phase 3) and the Event Manager's
competition stage-decision screen (advancing an entry through jury/
manual-review stages, Phase 6) — both real, narrower gaps that were
lower priority than the growth/engagement and profile features this plan
otherwise covers. Notification preferences has no backend to build
against yet, so Settings stays honest app-info-only rather than faking a
toggle.

## Architecture notes — Phase 7 specifically

- The consistency-pass scripts described above are the same discipline
  used after every phase in this build, just pointed at the *whole* app
  at once rather than one phase's new files — Section 7's own plan for
  this phase said to do exactly this, and it's what actually caught the
  false-positive-vs-real-gap distinction worth recording: automated
  checks narrow down where to look by hand, they don't replace looking.
- `EditProfileScreen` updates the cached `AuthStateNotifier` user in
  place after a successful save (`AuthStateNotifier.updateProfile`)
  rather than a full re-fetch — the same "update local state to match
  what the backend just confirmed" pattern used for role-assignment
  refresh after accepting a staff invitation in Phase 5.
- Identity document numbers are never displayed back — confirmed
  directly against `IdentityDocumentOut`'s real schema, which only ever
  returns `document_type` and `verification_status`, never the number
  itself (it's encrypted at rest server-side). The mobile model reflects
  this exactly rather than assuming a field that was never actually
  going to be there.

## Architecture notes — Phase 6 specifically

- **A breaking change I introduced and then fully fixed, not just
  patched around:** rejecting a registration needed a required-reason
  field, matching the console's mature `ConfirmActionDialog` pattern —
  but extending the shared `ConfirmActionSheet`'s `onConfirm` callback to
  accept a `String? reason` argument meant every existing zero-argument
  call site across Phases 3–6 (7 of them, in teams, staff assignments,
  logout ×2, registration submission, and this phase's two new ones) no
  longer matched the new signature. Found and fixed all 7, rather than
  leaving a partial change — a lesson in checking the blast radius before
  changing a widely-shared component's public API, not just the one call
  site that motivated the change.
- **The recurring path-depth bug from earlier phases showed up again,
  twice in a row this phase**, in the two newly-nested
  `staff_mode/funnels/` screens and their model file — one `../` short of
  reaching `lib/`, landing at `lib/features/` instead. Same root cause as
  the sibling-directory import bug: a folder one level deeper than usual
  (`staff_mode/<subfeature>/presentation/screens/` is five levels from
  `lib/`, not four) is easy to miscount by hand. Caught both times by the
  same automated script, not by eye.
- `staff_mode/funnels/` houses `CompetitionStagesScreen` and
  `VotingScreen`, but both are genuinely public — reachable by any
  participant, not staff-only. Left under `staff_mode/` for now purely
  because that's where the folder was scaffolded before this became
  clear; a strictly accurate structure would put public voting under a
  standalone `funnels/` feature at the top level, parallel to
  `referrals/`/`assistance/`. Cosmetic, not functional — flagged for
  awareness rather than fixed under this phase's time budget.
- Referral sharing uses Flutter's built-in `Clipboard` rather than the
  `share_plus` package's native share sheet — a deliberate choice to
  avoid a fifth third-party API this sandbox can't verify against real
  installed source (alongside razorpay_flutter, qr_flutter,
  mobile_scanner, and connectivity_plus). Copy-to-clipboard is a
  complete, working way to share a code today; a native share sheet is a
  reasonable later polish item, not a functional gap.

## Architecture notes — Phase 5 specifically

- **The single most consequential thing found this phase:** the QR code
  displayed on `TicketDetailScreen` only ever encoded `ticket.qrPayload`
  — never `ticket.qrSignature`. Since `/tickets/resolve` requires both to
  verify and look up a ticket, a scan could never actually be resolved at
  all until this was caught and fixed (the QR now encodes
  `"$qrPayload|$qrSignature"`, split back apart by the scanner). This was
  a bug in code I wrote myself in Phase 4, only surfaced by actually
  designing the Phase 5 scanner against it — a good example of why
  building the next phase is itself a real test of the previous one.
- Three backend fixes this phase (see above), the middle one more
  foundational than most: the officially documented bootstrap script for
  a fresh deployment never seeded three of the platform's nine roles at
  all, making an entire category of account (every mobile-only Staff
  Mode role) impossible to ever create. Found only by actually trying to
  invite and accept a `staff_member` assignment end-to-end, not from
  reading the code.
- Manual ticket-code entry deliberately uses a *different*, narrower
  trust model than the camera scan path (no signature required) — a
  human can't type a cryptographic signature from memory, so this relies
  instead on the caller already being an authenticated, permission-checked
  Staff Mode account. Documented explicitly in both the backend service
  method and here, so it reads as a deliberate design decision, not an
  overlooked security gap.
- The offline sync deliberately sends one scan per request, never a
  batch, even though the backend's endpoint accepts one — traced through
  the real implementation and found that each item in a batch commits
  individually as it's processed, but a failure partway through returns
  one all-or-nothing error response with no way for the client to tell
  which earlier items actually succeeded. One request per item sidesteps
  this completely, at the cost of more requests for what's expected to
  be small queues between sync windows.
- Two more depth-related import bugs, a new variant of the recurring
  pattern: files under `staff_mode/<subfeature>/...` sit one directory
  level deeper than every other feature, and several relative imports
  were written assuming the shallower depth. Caught by the same
  automated script as every other phase.
- Deliberately did NOT add the `uuid` package for local (client-only,
  never sent as a real ID) queue-item identifiers — a timestamp plus an
  in-memory counter already solves that narrower problem, and every
  additional dependency is one more thing this sandbox can't verify
  against real installed source.

## Architecture notes — Phase 4 specifically

- **Confirmed directly against the live router, not assumed:** there is
  no `GET /payments/mine` or `GET /payments/{id}` endpoint — a
  participant can't poll a payment resource directly (`GET /payments` is
  Finance-role-only). The mobile app instead calls
  `POST /payments/webhook` itself with the exact values Razorpay's
  checkout SDK returns on success, which is the same shape the gateway's
  own server-to-server webhook uses and requires no auth (the signature
  is the real security boundary) — confirmed this is a legitimate,
  intended flow, not a workaround, by reading `handle_webhook`'s actual
  implementation: it's synchronous, so by the time that call returns, the
  registration is already `confirmed` and the ticket already exists — no
  polling loop was needed.
- `PaymentGatewayOrderOut.amount` is in whole rupees, not paise — checked
  directly against the router's response construction
  (`amount=payment.amount`, the stored Decimal). The paise conversion for
  Razorpay's checkout options happens exactly once, in
  `PaymentGatewayOrder.amountInPaise`, rather than being recomputed
  wherever it's needed.
- The route for a single ticket is `/ticket/:ticketId` (singular),
  deliberately not `/tickets/:ticketId` — the latter would collide with
  the already-registered literal `/tickets/mine` shell route under the
  same prefix. Caught during router wiring, before it became a runtime
  ambiguity.
- One more real bug from hand-review: the registration submit flow used
  `RegistrationStatus.pendingPayment` directly but never imported the enum
  — caught by the same discipline as every other phase, not by a
  compiler.

## Architecture notes — Phase 3 specifically
  three more times this phase** — every new `application/*_providers.dart`
  file (config_engine, registrations, guardians, teams) imported its
  sibling `data/` folder as if it were a child directory. All four were
  caught and fixed by the same automated import-resolution script, not by
  eye — worth knowing that this is apparently a mistake I make reliably
  when writing a provider file quickly, so it's specifically worth
  double-checking if you ever add a new feature module by hand.
- Two more real bugs caught by hand-review: `DropdownButtonFormField`'s
  `initialValue` and `Switch`'s `activeThumbColor` are both newer Flutter
  APIs that may not exist at the `3.22.0` floor this project targets —
  reverted to the long-stable `value`/`activeColor` equivalents. And a
  double-pop bug in the registration submit flow, where my own submit
  handler was popping the confirmation sheet a second time after the
  sheet had already popped itself on success.
- The dynamic field renderer (`registrations/presentation/widgets/
  dynamic_field_renderer.dart`) is deliberately controller-free and
  stateless, taking `answers` and `onFieldChanged` from its parent screen
  — this is what lets `RegistrationFormScreen` run a real eligibility
  check against the live answers at any point without the renderer
  needing to know anything about validation itself.

## Architecture notes — Phases 1–2
  as dynamic) : error` cast in the error-state branches, which would have
  crashed at runtime for any error that wasn't already an `AppException`
  — replaced with a proper `error is AppException ? error :
  UnknownException(error.toString())` conversion, used consistently in
  both Home and Search. Separately, three `*_providers.dart` files
  imported their sibling `data/` folder as if it were a child directory
  (`'data/foo.dart'` instead of `'../data/foo.dart'`) — caught by the
  same automated import-resolution check used throughout this project,
  not by eye.
- `EventCard` was initially placed under `shared/widgets/` and then
  deliberately moved into `features/events/presentation/widgets/` once I
  noticed it imported the `AppEvent` model — `shared/` is supposed to
  carry zero business/feature logic (Section 3.10), so a widget that
  understands what an "Event" is doesn't belong there. Worth knowing if
  you're wondering why it isn't where the original folder-structure plan
  might have implied.

- **No `freezed`/`json_serializable`/`riverpod_generator`.** These need
  `build_runner` codegen, and generated code I can't run is code I can't
  verify — so Phase 1 uses plain hand-written immutable model classes and
  plain Riverpod `Provider`/`StateNotifierProvider`/`AsyncNotifier`
  classes instead. This is a legitimate standing choice for a model set
  this size, not just a workaround — happy to revisit if you'd prefer
  codegen once real device/CI testing is in the loop.
- Every backend-facing model (`AppUser`, `RoleAssignment`, `RoleName`,
  `TokenPair`) was checked field-by-field against the actual Pydantic
  schemas in your backend repo, not written from memory.
- `core/utils/phone_formatter.dart` mirrors
  `app/modules/identity/phone.py`'s `normalize_mobile_number` exactly —
  same accepted formats, same rejected cases, same output.
