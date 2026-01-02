# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- Created semantic color system with WCAG AA accessibility compliance for light and dark modes
  — `/SoccerGameTracker/Theme/SemanticColors.swift` (adaptive colors with fallbacks)
- Implemented design tokens for consistent spacing, sizing, typography, and animations
  — `/SoccerGameTracker/Theme/DesignTokens.swift` (centralized design constants)
- Created reusable view modifiers following SwiftUI best practices
  — `/SoccerGameTracker/Theme/ViewModifiers.swift` (CardStyle, PrimaryButtonStyle, SecondaryButtonStyle, BadgeStyle, conditional modifiers)
- Built reusable UI components for common patterns
  — `/SoccerGameTracker/Components/ReusableComponents.swift` (ScoreDisplay, GameStatusBadge, TimerDisplay, EmptyStateView, ActionButton, StatBadgeView, PlayerNumberBadge)

### Changed

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
