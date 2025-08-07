# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

IELTSpeak is a SwiftUI-based iOS application for IELTS (International English Language Testing System) speaking test preparation. The app simulates the three-part IELTS speaking test format with real-time audio recording, speech recognition, and AI-powered scoring through backend integration.

## Architecture

### Core App Structure
- **Entry Point**: `IELTSpeakApp.swift` → `MainView.swift` → authentication-gated `ContentView.swift`
- **Navigation**: Tab-based interface with Home, Lessons, Leaderboard, and Settings
- **Authentication**: Supabase-based auth with automatic session management in `MainView.swift`
- **Theme System**: Dark/light mode support via `DLMode.swift` and `@AppStorage("userTheme")`

### Key Modules
- **Home (`Core/Home/`)**: Dashboard with test results, statistics, and band descriptors
- **Lessons (`Core/Lesson/`)**: Educational content with JSON-based data management
- **Exam Simulation (`Core/ExamSimulation/`)**: Core test simulation engine with audio processing
- **User Management (`Core/User/`)**: Authentication, profiles, and Supabase integration
- **Settings (`Core/Settings/`)**: App preferences, feedback, and legal content

### Data Architecture
- **Local Data**: Lesson content stored in `lesson_data.json` with `LessonDataManager` for state management
- **User Progress**: `UserDefaults`-based persistence with complex progress tracking models
- **Backend**: Supabase integration for test sessions, questions, audio uploads, and AI scoring
- **Audio Storage**: Temporary files for recordings, streamed audio for questions

## Development Commands

Since this is an Xcode project with Swift Package Manager dependencies:

```bash
# Build the project
xcodebuild -project IELTSpeak.xcodeproj -scheme IELTSpeak -destination 'platform=iOS Simulator,name=iPhone 15' build

# Clean build folder
xcodebuild clean -project IELTSpeak.xcodeproj -scheme IELTSpeak

# Run on simulator (use Xcode GUI preferred)
open IELTSpeak.xcodeproj
# Then Cmd+R to run

# Archive for release
xcodebuild -project IELTSpeak.xcodeproj -scheme IELTSpeak -archivePath ./build/IELTSpeak.xcarchive archive
```

**Note**: No automated testing framework is currently configured. Consider adding XCTest for unit tests and UI tests.

## Key Dependencies

All dependencies are managed via Swift Package Manager and resolved in `Package.resolved`:

- **Supabase Swift** (2.30.1): Backend services, authentication, database, storage
- **RevenueCat** (5.32.0): Subscription and payment management  
- **Speech Framework**: iOS speech recognition for test interactions
- **AVFoundation**: Audio recording, playback, and session management

## Complex Systems

### Test Simulation Engine (`TestSimulationManager.swift`)
The core of the app - handles IELTS speaking test flow:
- **Three-part test structure**: Part 1 (personal questions), Part 2 (cue card with 1-min prep + 2-min speaking), Part 3 (discussion)
- **Audio Pipeline**: `AudioPlayerManager` → user listens → `AudioRecorderManager` + `SpeechRecognizerManager` → backend upload
- **State Management**: Complex phase transitions (preparation → testing → processing → completed)
- **Backend Integration**: Session creation, question fetching, response uploading, AI processing

### Audio Management System
Three specialized managers working together:
- **AudioPlayerManager**: Plays examiner questions with completion callbacks
- **AudioRecorderManager**: Records user responses with optimized settings (16kHz, mono, 32kbps)
- **SpeechRecognizerManager**: Detects speech start/end with configurable silence detection

### Lesson Data System (`LessonDataManager.swift`)
- **JSON-based content**: Structured lesson data with categories, subcategories, vocabulary, idioms, phrasal verbs
- **Progress Tracking**: Complex user progress models with mastery levels, streaks, unlocking logic
- **Background Processing**: Async data loading with error handling and state management

## Important Configuration

### Info.plist Requirements
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone for recording your speaking test answers.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech recognition to detect when you finish speaking during the test.</string>
```

### Supabase Configuration
- **URL**: `https://roovqypkzhynhrzzafre.supabase.co` (configured in `Supabase.swift`)
- **Key**: Anon key included in code (ensure proper RLS policies on backend)
- **URL Schemes**: `io.supabase.user-management` for auth callbacks

### Custom Fonts
Fredoka font family (Light, Regular, Medium, SemiBold, Bold) registered in `UIAppFonts`

## Development Guidelines

### Audio Permissions
Always request both microphone and speech recognition permissions before starting test flow. The app will not function without these permissions.

### State Management
- Use `@Published` properties for UI-reactive state in ObservableObjects
- Complex async operations use `Task` with proper `@MainActor` updates
- Audio operations require careful session management to avoid conflicts

### Error Handling
- Audio errors are surfaced through `errorMessage` properties
- Backend failures have fallback to local-only results
- Speech recognition issues should gracefully degrade test experience

### Performance Considerations
- Audio files use optimized compression (16kHz, mono, 32kbps) for backend uploads
- Large lesson data is loaded asynchronously in background threads
- UI updates always performed on main actor to prevent crashes

## Common Development Tasks

### Adding New Test Questions
1. Update backend database with new questions and audio URLs
2. Questions are fetched dynamically via `TestService.fetchTestQuestions()`
3. Audio is downloaded and cached during test initialization

### Modifying Lesson Content
1. Edit `lesson_data.json` with new categories, subcategories, or items
2. Update corresponding data models in `LessonData.swift` if structure changes
3. Test data migration with `DataMigrationManager` for version changes

### Backend Integration
- All API calls go through `SupabaseService` 
- Test sessions create entries in `test_sessions` table
- Audio uploads to Supabase Storage with response metadata
- AI processing polls for results with exponential backoff