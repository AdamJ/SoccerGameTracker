# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

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

### Fixed

- Fixed blank player stats sheet in GameTrackerView
  — `GameTrackerView.swift:392-461` (updated PlayerStatsDetailView to use NavigationStack, ScrollView, semantic colors, and presentation drag indicator for proper iOS swipe-to-dismiss behavior)
- Improved player stats grid layout to always show all fields (even with 0 values)
  — `GameTrackerView.swift:419-452` (restructured stats grid with consistent HStack rows; Saves stat displays for goalkeepers only)
- Verified iOS 26 compatibility with successful build on iPhone 17 Pro simulator
- Resolved all compiler warnings and errors
