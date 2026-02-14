# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a tvOS (Apple TV) quiz app built with SwiftUI that fetches weekly quiz data from an API and presents it in a TV-friendly interface. The app is designed for the 10-foot experience with remote control navigation.

## Building and Running

```bash
# Build the project
xcodebuild -project SaturdayQuiz.xcodeproj -scheme SaturdayQuiz -configuration Debug build

# Build for release
xcodebuild -project SaturdayQuiz.xcodeproj -scheme SaturdayQuiz -configuration Release build

# Clean build artifacts
xcodebuild -project SaturdayQuiz.xcodeproj -scheme SaturdayQuiz clean
```

**Note:** This is a tvOS app (TARGETED_DEVICE_FAMILY = 3). It must be run in the tvOS Simulator or on an Apple TV device via Xcode.

## Architecture

### Data Flow

1. **Quiz Data Source**: Fetches quiz JSON from `https://eaton-bitrot.koyeb.app/api/quiz` on app launch
2. **State Management**: Uses SwiftUI's `@StateObject` with `QuizPresenter` as the central state manager
3. **Scene Navigation**: Linear progression through predefined scenes controlled by `sceneIndex`
4. **Score Persistence**: Stores user scores in `UserDefaults` keyed by quiz date

### Key Components

**QuizPresenter** (QuizPresenter.swift)
- Central presenter managing quiz state and navigation
- Handles API fetching, scene building, and score persistence
- Implements scene-based navigation (loading → ready → questions → answers → results)
- Score storage uses date-based keys: `quiz_scores_YYYY-MM-DD`
- If scores exist for a quiz date, skips question scenes and jumps to answers

**QuizView** (QuizView.swift)
- Main view switching between scenes based on `presenter.currentScene`
- Implements remote control navigation: left/right arrows navigate, play/pause or tap cycles scores
- Exits app when backgrounded (tvOS behavior)
- Contains all UI components: LoadingView, ReadyView, QuestionView, AnswersTitleView, ResultsView, ScoreIndicatorView

**Models** (Models/)
- `Quiz`: Top-level quiz data (id, date, title, questions)
- `Question`: Individual question with number, text, answer, type, and whatLinks data
- `QuestionType`: Enum distinguishing `.normal` from `.whatLinks` questions
- `ScoreState`: Enum for scoring (.none = 0, .half = 0.5, .full = 1.0) with cycling logic

**View Extensions** (View.swift)
- Custom layout modifiers: `fillParentCentered()`, `fillParentTopLeft()`, `fillParentBottomLeft()`, `fillParentBottomRight()`

### UI Constants

All design constants are centralized at the top of QuizView.swift:
- **FontSizes**: title (120), body (70), whatLinks (35), subTitle (50)
- **FontWeights**: Uses "Open Sans" font loaded from assets
- **Colors**: text (#ddd), highlight (#fd0), midGray (#666), darkGray (#444)
- **Dimensions**: Layout spacing, score circle size, etc.

### Remote Control Interactions

- **Left/Right arrows**: Navigate between scenes
- **Play/Pause or Tap**: Cycle scores on answer screens (none → full → half → none)
- **Menu button**: Standard tvOS back behavior
- **Exiting**: App exits when reaching final scene or when backgrounded

### Scene Flow Logic

1. **New quiz** (no stored scores): loading → ready → [questions] → answersTitle → [question/answer pairs] → results
2. **Returning to quiz** (scores exist): loading → ready → [question/answer pairs] → results

The whatLinks question type displays a special "WHAT LINKS" indicator above the question text.

## Custom Fonts

The app uses "Open Sans" variable font from `assets/OpenSans-Variable.ttf`. Font must be registered in Info.plist and referenced as "Open Sans" in code.

## API Contract

Expected JSON structure from quiz API:
```json
{
  "id": "string",
  "date": "ISO8601 date string",
  "title": "string",
  "questions": [
    {
      "number": int,
      "question": "string",
      "answer": "string",
      "type": "NORMAL" | "WHAT_LINKS",
      "whatLinks": ["string"]
    }
  ]
}
```
