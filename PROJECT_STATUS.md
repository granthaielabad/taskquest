# TaskQuest Project Status & Roadmap

This file is the "source of truth" for the development team. Move tasks between sections to keep each other updated.

## ✅ DONE (Completed Features)
- [x] **Firebase Integration:** Core, Auth, and Firestore initialized.
- [x] **Authentication:** Email/Password and Google Sign-In fully functional.
- [x] **UI Redesign:** New "Quest-like" design system implemented (Syne + DM Mono).
- [x] **Theming:** Full Dark Mode support and System theme switching.
- [x] **Theme System:** Implemented a robust Light/Dark/System theme engine using dynamic `ColorScheme.fromSeed` for consistent accessibility.
- [x] **AI Scanning:** Gemini 2.5 Flash integration with Web-safe byte processing for auto-generating flashcards.
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
- [x] **Explore Redesign:** Modern discovery hub with "Daily Byte" history facts, interactive category filters (#AI, #Web), and sleek horizontal feeds.
- [x] **In-App Browsing:** Native article reader for Dev.to articles and a dedicated **Wikipedia History Viewer** for tech figures/history.
- [x] **Wikipedia Integration:** Refined Wikipedia search restricted to Technology/CS topics with in-app reading.
- [x] **Bookmarking System:** Ability to "Save" articles and pioneers to a personalized "Your Collection" section.
- [x] **Leaderboard Screen:** Global ranking system with podium UI and real Firestore data.
- [x] **Badge Unlocking Logic:** Backend tracking for Syntax Sage, Bug Hunter, and other milestones.
- [x] **Manual Entry Refinement:** Added "Clear All" and field-level error highlighting.
- [x] **Edit Profile Logic:** Functional UI to update name and real-time Firestore synchronization.
- [x] **Search Logic:** Upgraded search bar in Explore to query both local quests and the Dev.to API.
- [x] **Deck Categorization:** Ability to group flashcards by subject (Data Structures, OS, etc.).
- [x] **Haptic Feedback:** Tactile vibrations for buttons, correct/wrong answers, and level-ups.
- [x] **Sound Effects:** Auditory feedback for correct/wrong answers, level-ups, and clicks.
- [x] **Flutter Web Support:** Project fully configured for Chrome development/deployment with Firebase Web.
- [x] **Universal Game Timer:** Shared timer component with visual alerts and level-based difficulty scaling.
- [x] **Game Feedback System:** Integrated "Report Issue" functionality to flag inaccurate content.
- [x] **Games Redesign:** Full UI/UX overhaul for all 5 game modes (Code Blocks, Which Lang, SDLC, Solve Algorithm, Flashcards) with dedicated lobbies and interactive gameplay.
- [x] **Dynamic Home Screen:** Dynamic greeting, Notifications access, and Badges entry point integrated.
- [x] **Firestore Indexing:** Composite indexes created to support efficient "My Decks" sorting.
- [x] **Deck Deletion:** Fully functional UI and logic to remove old decks from Firestore.
- [x] **Profile Redesign:** Completely overhauled the Profile UI with a centered avatar, floating stats row, and semantic, theme-aware layout.
- [x] **Social Sharing:** Ability to share Level-Ups and unlocked Badges to social media.

---

## 🚧 IN PROGRESS (Current Focus)
- [ ] **Performance Optimization:** Profile image caching. (Assigned to: **Gemini**)
- [ ] **Accessibility:** Adding semantics labels for screen readers. (Assigned to: ______)

---

## ⏳ BACKLOG (To-Do List)

### Phase 3: Final Polish
- [ ] **Notifications:** Local reminders for daily quests.

---

## 🛠️ Development Rules
1. **Branching:** Create a new branch for every task (e.g., `feat/xp-rewards`).
2. **Status Update:** Before starting a task, add your name to the "IN PROGRESS" section and commit it.
3. **Conflicts:** If you change a `Model` class, notify the team immediately.
