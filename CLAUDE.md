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

## Backend Architecture & Database Schema

### Supabase Database Schema

#### Core Tables

##### 1. `profiles` - User Management
- `id` (uuid, PK) - Links to auth.users.id
- `updated_at` (timestamptz)
- `username` (text)
- `full_name` (text)  
- `avatar_url` (text)

##### 2. `test_templates` - Test Configuration
- `id` (uuid, PK) - Test template identifier
- `title` (text) - Template name/title
- `description` (text) - Template description
- `difficulty_level` (text) - Easy/Medium/Hard difficulty
- `created_at` (timestamptz)
- `updated_at` (timestamptz)
- `is_active` (bool) - Template availability status

##### 3. `questions` - Test Questions Bank
- `id` (uuid, PK) - Question identifier
- `test_template_id` (uuid, FK) - Links to test_templates
- `part_number` (int4) - IELTS part (1, 2, or 3)
- `question_order` (int4) - Order within part
- `question_text` (text) - The actual question
- `audio_file_url` (text) - URL to examiner audio
- `transcript` (text) - Audio transcript
- `expected_duration` (int4) - Expected response time (seconds)
- `topic_keywords` (text) - Keywords for categorization
- `created_at` (timestamptz)

##### 4. `test_sessions` - Active Test Sessions
- `id` (uuid, PK) - Session identifier  
- `user_id` (uuid, FK) - Links to profiles
- `test_template_id` (uuid, FK) - Links to test_templates
- `status` (text) - in_progress/completed/processing/evaluated
- `started_at` (timestamptz) - Session start time
- `completed_at` (timestamptz) - Session completion time
- `completed_responses` (int4) - Number of responses submitted
- `all_responses_uploaded` (bool) - Upload completion status
- `overall_band_score` (numeric) - Final IELTS band score
- `fluency_score` (numeric) - Fluency component score
- `pronunciation_score` (numeric) - Pronunciation component score
- `grammar_score` (numeric) - Grammar component score  
- `vocabulary_score` (numeric) - Vocabulary component score
- `topic_relevance_score` (numeric) - Topic relevance score
- `expected_responses` (int4) - Total expected responses

##### 5. `responses` - Individual Question Responses
- `id` (uuid, PK) - Response identifier
- `test_session_id` (uuid, FK) - Links to test_sessions
- `question_id` (uuid, FK) - Links to questions
- `audio_file_path` (text) - Path in Supabase Storage
- `wav_file_path` (text) - Converted WAV file path
- `transcript` (text) - Speech-to-text transcript
- `duration_seconds` (int4) - Response duration
- `fluency_score` (numeric) - Individual fluency score
- `pronunciation_score` (numeric) - Individual pronunciation score
- `grammar_score` (numeric) - Individual grammar score
- `vocabulary_score` (numeric) - Individual vocabulary score
- `topic_relevance_score` (numeric) - Individual topic relevance
- `azure_response` (jsonb) - Full Azure API response
- `is_processed` (bool) - Processing completion status
- `processing_order` (int4) - Order for processing
- `error_message` (text) - Any processing errors
- `created_at` (timestamptz)
- `uploaded_at` (timestamptz)
- `evaluated_at` (timestamptz)
- `upload_status` (text) - Upload status tracking
- `processing_status` (text) - Processing status tracking

##### 6. `processing_queue` - AI Processing Queue
- `id` (uuid, PK) - Queue item identifier
- `session_id` (uuid, FK) - Links to test_sessions
- `test_session_id` (uuid, FK) - Alternative session link
- `status` (text) - pending/processing/completed/failed
- `priority` (int4) - Processing priority
- `queued_at` (timestamptz) - Queue entry time
- `started_processing_at` (timestamptz) - Processing start time
- `completed_at` (timestamptz) - Processing completion time
- `retry_count` (int4) - Number of retry attempts
- `error_message` (text) - Processing error details
- `processing_worker_id` (text) - Worker handling processing
- `max_retries` (int4) - Maximum retry attempts
- `last_error_at` (timestamptz) - Last error timestamp
- `processing_duration_seconds` (int4) - Total processing time

##### 7. `session_processing_queue` - Session-level Processing
- `id` (uuid, PK) - Queue identifier
- `test_session_id` (uuid, FK) - Links to test_sessions  
- `status` (text) - Processing status
- `created_at` (timestamptz)
- `updated_at` (timestamptz)
- `error_message` (text) - Error details

### Supabase Storage Buckets

#### 1. `avatars` - User Profile Images
- User profile pictures and avatars
- Public access for display

#### 2. `audio-question-set` - Question Audio Files  
- Pre-recorded examiner questions
- Organized by test templates and parts
- Public access for playback during tests

#### 3. `audio-responses` - User Response Recordings
- User's recorded answers to test questions  
- Private access with RLS policies
- Organized by session and question: `responses/{sessionId}_part{part}_q{order}.m4a`

### Backend Integration Workflow

#### 1. Test Initialization
1. App downloads questions from `questions` table filtered by `test_template_id`
2. Creates new `test_sessions` entry with "in_progress" status
3. Downloads examiner audio from `audio-question-set` bucket

#### 2. Response Collection
1. User responds to questions with audio recording
2. App uploads audio to `audio-responses` bucket  
3. Creates `responses` entry linking session, question, and audio file
4. Updates `test_sessions.completed_responses` counter

#### 3. AI Processing Pipeline
1. Session marked as "processing" when all responses uploaded
2. Entry added to `processing_queue` for backend worker
3. Azure Speech Assessment API processes each response
4. Individual scores stored in `responses` table
5. Overall session scores calculated and stored in `test_sessions`
6. Session status updated to "evaluated"

#### 4. Result Retrieval
1. App polls `test_sessions` table for status changes
2. When "evaluated", fetches overall scores and individual response details
3. Results displayed in app with comprehensive feedback

### Azure Speech Assessment Integration

#### Evaluation Criteria
The Azure API provides comprehensive scoring across four key areas:
- **Pronunciation Scores**: Accuracy of sound production and accent
- **Fluency Scores**: Speaking rhythm, pace, and natural flow
- **Vocabulary Scores**: Lexical variety and appropriateness  
- **Grammar Scores**: Grammatical accuracy and complexity
- **Topic Relevance**: How well response addresses the question

#### Processing Methodology
- **Individual Response Analysis**: Each audio response evaluated separately
- **Multi-dimensional Scoring**: Each criterion evaluated independently
- **IELTS-aligned Scoring**: Scores calibrated to IELTS Speaking band descriptors
- **Session Aggregation**: Individual scores combined for overall band score

### Implementation Notes

#### Data Models Alignment
Current `SupabaseService.swift` includes these key data structures that align with the database schema:
- `CreateSessionRequest` - Maps to `test_sessions` table
- `CreateResponseRequest` - Maps to `responses` table
- `TestResultsResponse` - Retrieves evaluated session results
- `ResponseScoreResult` - Individual response scoring data

#### Key Implementation Details
- **Question ID Mapping**: Complex mapping system handles frontend question indexing vs. backend question UUIDs
- **Audio Format**: Responses uploaded as `.m4a` files, backend converts to `.wav` for Azure processing
- **Status Polling**: App polls session status every 10 seconds during processing with timeout handling
- **Error Recovery**: Failed uploads trigger storage cleanup and retry logic
- **Concurrent Processing**: Multiple responses can be processed simultaneously via the queue system

#### Backend Processing Flow
1. **Upload Phase**: Audio files uploaded to `audio-responses` bucket with metadata
2. **Queue Phase**: Session added to `processing_queue` for backend worker
3. **Evaluation Phase**: Azure Speech Assessment processes each response
4. **Aggregation Phase**: Individual scores combined into session-level results
5. **Completion Phase**: Session status updated to "evaluated" with final scores

#### Critical Dependencies
- **Default Template ID**: Hardcoded to `550e8400-e29b-41d4-a716-446655440000` in current implementation
- **Storage Paths**: Audio files use format `responses/{sessionId}_part{part}_q{order}.m4a`
- **Authentication**: All operations require valid Supabase auth session
- **RLS Policies**: Row Level Security enforces user-specific data access