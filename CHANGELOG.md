# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- Substitute status tracking in game stats
  — `PlayerStats.swift` (added isSubstitute field to track players starting on the bench)
  — `Game.swift` (passes isSubstitute flag from Player to PlayerStats during game initialization)
  — `GameTrackerView.swift` (substitutes display "SUB" badge, stat buttons disabled with visual feedback and explanatory message)
  — Substitutes cannot record stats (goals, assists, saves, shots, cards) during the game
  — Clear visual distinction between starting players and substitutes in player list

- Action logging system to track individual game events with timestamps
  — `GameAction.swift` (new data model with actionType enum, timestamp, gameHalf, elapsedSeconds, player details)
  — `Game.swift` (added actions array, logAction() and removeAction() methods, Codable support)
  — Tracks goals (team/unknown/opponent), assists, saves, shots, yellow cards, red cards
  — Actions grouped by half and sorted chronologically
- Actions view in live game tracker
  — `ActionsTabView.swift` (new view with ActionRow component showing action timeline)
  — Accessible via "Actions" button in GameTrackerView
  — Swipe-to-delete functionality that maintains stat consistency
  — Empty state for games without actions
- Action logging integrated throughout game flow
  — `GameTrackerView.swift` (action logging on all stat increments: goals, assists, saves, cards, shots, opponent goals)
  — `GoalAssignmentView` logs actions when goals confirmed with/without assists
  — `PlayerStatsDetailView` StatButtons log actions when stats incremented
  — Goal decrement finds and removes most recent action for player
- Action timeline in game summaries and history
  — `EndGameConfirmationView.swift` (share text includes action timeline grouped by half)
  — `GameSummaryView.swift` (action log section with ActionSummaryRow component)
  — Actions display elapsed game time, icon, description, and actual timestamp
  — Historical games show read-only action timeline
- Smart roster management with manual and auto-assignment and goalkeeper constraints
  — `Player.swift` (added isSubstitute Boolean flag to separate player role from position)
  — `RosterManager.swift` (addPlayer() accepts optional isSubstitute parameter for manual designation)
  — Users can manually choose to add players directly to substitutes in AddPlayerView
  — Players exceeding team format size (5v5/7v7/11v11) automatically assigned as substitutes
  — Substitutes retain their actual position (Goalkeeper, Defender, Midfielder, Forward) instead of losing it to "Substitute" designation
  — Display format: "Position • SUB" in substitutes section
- Goalkeeper validation and swap functionality
  — `RosterManager.swift` (enforces exactly 1 goalkeeper in starting lineup; can have GKs in substitutes)
  — `wouldRemoveOnlyGoalkeeper()` prevents deleting the only starting goalkeeper
  — `requiresGoalkeeperSwap()` detects when moving substitute GK to starters requires swap
  — `swapGoalkeepers()` automatically moves current starter GK to subs when bringing in replacement
  — PlayerEditView shows swap confirmation dialog before executing goalkeeper swap
- Roster editing lockdown during active games
  — `RosterView.swift` (GameManager integration disables add/edit/delete when game is active)
  — Visual feedback with reduced opacity (50%) on disabled elements
  — Tap-to-edit functionality for all players (when no game active)
  — Edit sheet with player details and role selection
- Player position management improvements
  — `Position.swift` (added displayPositions array excluding deprecated substitute case)
  — All position pickers now use displayPositions to prevent selecting "Substitute" as a position
  — Migration logic automatically converts legacy Position.substitute to isSubstitute flag
  — Backward compatible with existing roster data

### Changed

- Created semantic color system with WCAG AA accessibility compliance for light and dark modes
  — `/SoccerGameTracker/Theme/SemanticColors.swift` (adaptive colors with fallbacks)
- Implemented design tokens for consistent spacing, sizing, typography, and animations
  — `/SoccerGameTracker/Theme/DesignTokens.swift` (centralized design constants)
- Created reusable view modifiers following SwiftUI best practices
  — `/SoccerGameTracker/Theme/ViewModifiers.swift` (CardStyle, PrimaryButtonStyle, SecondaryButtonStyle, BadgeStyle, conditional modifiers)
- Built reusable UI components for common patterns
  — `/SoccerGameTracker/Components/ReusableComponents.swift` (ScoreDisplay, GameStatusBadge, TimerDisplay, EmptyStateView, ActionButton, StatBadgeView, PlayerNumberBadge)
- Added team format selection (5v5, 7v7, 11v11)
  — `TeamFormat.swift` (team format enum with player counts and descriptions)
  — `RosterManager.swift` (team format and home/away status storage with persistence)
- Enhanced roster view with team configuration and position grouping
  — `RosterView.swift` (team name input, format picker, home/away toggle, players grouped by position with substitutes separate, empty state, player count badges)
- Integrated team name and home/away status throughout game flow
  — `Game.swift` (added ourTeamName and isHomeTeam properties with Codable support)
  — `GameManager.swift` (updated startGame to accept team name and home/away status)
  — `GameSetupView.swift` (passes team configuration from RosterManager to new games)
  — `Components/ReusableComponents.swift` (ScoreDisplay updated to show correct team names based on home/away status)

### Changed

- Player stats sheet presentation now uses `.sheet(item:)` for reliable display
  — `GameTrackerView.swift` (fixed blank sheet issue on first tap by using item-based sheet presentation instead of boolean-based)
- Refactored AppColors to bridge legacy colors to new semantic color system
  — `/SoccerGameTracker/AppColors.swift` (maintains backward compatibility)
- Enhanced StatButton with improved accessibility support
  — `/SoccerGameTracker/StatButton.swift` (added VoiceOver support, accessibility adjustable actions, better semantic structure)
- Updated End Game workflow with optional share sheet
  — `EndGameConfirmationView.swift` ("Share & End Game" shows share sheet with formatted summary; "End Game" completes without sharing)
  — `GameTrackerView.swift` (added GameManager environment object for proper game ending)
  — `GameSetupView.swift` (automatic dismissal of game tracker when game ends, returns to New Game screen)
- Enhanced RosterView with edit functionality and game-active awareness
  — Grouping logic now filters out substitutes from position sections (groupedPlayers uses !isSubstitute)
  — Substitutes section displays players with showSubstituteLabel parameter showing "Position • SUB"
  — PlayerRowView supports optional showSubstituteLabel parameter for substitute designation
  — Delete validation prevents removing the only starting goalkeeper
  — All roster operations disabled when game is active (visual feedback with opacity)
- Updated AddPlayerView with manual role selection and smart auto-assignment
  — Added "Role" section with Starting Lineup/Substitute segmented picker
  — Users can directly choose to add players as substitutes
  — Smart warning shows when starting lineup is full
  — Confirmation alert offers to add as substitute if lineup is full
  — Goalkeeper validation only applies to starting lineup additions
  — Alert message clarifies GK limit is for starting lineup only
- Enhanced PlayerEditView with comprehensive role and goalkeeper management
  — Added "Role" section with Starting Lineup/Substitute segmented picker
  — Prevents moving only starting GK to substitutes (blocks with alert)
  — Prevents changing only starting GK to different position (blocks with alert)
  — Detects when substitute GK move to starters requires swap (shows confirmation dialog)
  — Goalkeeper swap dialog explains automatic swap behavior before executing
  — performGoalkeeperSwap() method handles automatic GK role transfer

### Fixed

- Fixed RosterView missing GameManager environment object
  — `ContentView.swift` (added .environmentObject(gameManager) to RosterView to support game-active lockdown)
- Fixed blank player stats sheet in GameTrackerView on first tap
  — `GameTrackerView.swift:28-30` (changed to `.sheet(item:)` for reliable sheet presentation)
  — `GameTrackerView.swift:392-461` (updated PlayerStatsDetailView to use NavigationStack, ScrollView, semantic colors, and presentation drag indicator for proper iOS swipe-to-dismiss behavior)
- Fixed GameTrackerView preview code to use correct initializers
  — `GameTrackerView.swift:913-951` (updated sample data to match Game and Player initializers)
- Improved player stats grid layout to always show all fields (even with 0 values)
  — `GameTrackerView.swift:419-452` (restructured stats grid with consistent HStack rows; Saves stat displays for goalkeepers only)
- Verified iOS 26 compatibility with successful build on iPhone 17 Pro simulator
- Resolved all compiler warnings and errors
