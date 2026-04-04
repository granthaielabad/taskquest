# TaskQuest Project Status & Roadmap

## ✅ DONE (Completed Features)
- [x] **Firebase Integration:** Core, Auth, and Firestore initialized.
- [x] **Authentication:** Email/Password and Google Sign-In fully functional.
- [x] **UI Redesign:** New "Quest-like" design system implemented (Syne + DM Mono).
- [x] **Theming:** Full Dark Mode support and System theme switching.
- [x] **AI Scanning:** Gemini 1.5 Flash integration for auto-generating flashcards from PDFs/Images.
- [x] **Flashcard Persistence:** Models and Services created to save decks to Firestore.
- [x] **Study Loop:** Interactive flashcard flipping with mastery tracking UI.
- [x] **Manual Entry:** UI and Logic for creating custom decks manually.
- [x] **Database Seeding:** Script and UI button to fill Firestore with Quests/Badges.
- [x] **XP Reward Bridge:** Finished study sessions now award real XP in Firestore.
- [x] **Auth State Persistence:** Splash screen correctly skips onboarding for logged-in users.
- [x] **User Profile Creation:** Firestore documents created automatically on first-time login/signup.
- [x] **Manual Entry Validation:** Prevent saving empty cards/decks + Discard confirmation dialog.
- [x] **Quest Completion Logic:** Home screen quests now award real XP and unlock the "First Flight" badge.
- [x] **Level-Up UI:** celebration dialog triggers automatically upon reaching a new level.
- [x] **Daily Streak Backend:** Automated logic to track and update consecutive login days.
- [x] **Level-Up Animation:** Confetti burst effect added to the level up celebration.
- [x] **"Code Blocks" Game:** Functional drag-and-drop syntax reordering challenge.
- [x] **"Which Lang?" Quiz:** Time-pressure multiple-choice language identification game.
- [x] **Explore Feed:** Redesigned discovery screen with featured articles and community challenges.
- [x] **Leaderboard Screen:** Global ranking system with podium UI and real Firestore data.
- [x] **Badge Unlocking Logic:** Backend tracking for Syntax Sage, Bug Hunter, and other milestones.
- [x] **Manual Entry Refinement:** Added "Clear All" and field-level error highlighting.
- [x] **Edit Profile Logic:** Functional UI to update name and real-time Firestore synchronization.

---

## 🚧 IN PROGRESS (Current Focus)
- [ ] **Search Logic:** Functional search bar in Explore and Decks. (Assigned to: **Gemini**)
- [ ] **Sound Effects:** Add subtle "ding" and "whoosh" sounds for gameplay. (Assigned to: ______)

---

## ⏳ BACKLOG (To-Do List)

### Phase 3: Final Polish
- [ ] **Deck Categorization:** Group flashcards by subject (e.g., OS, Networking).
- [ ] **Social Sharing:** Share your badges/rank to social media.
- [ ] **Haptic Feedback:** Vibrations for correct/wrong answers.

---

## 🛠️ Development Rules
1. **Branching:** Create a new branch for every task (e.g., `feat/xp-rewards`).
2. **Status Update:** Before starting a task, add your name to the "IN PROGRESS" section and commit it.
3. **Conflicts:** If you change a `Model` class, notify the team immediately.
