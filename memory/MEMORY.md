# IELTSpeak Project Memory

## Color Theme (Applied Feb 2026)
Central color definitions live in `IELTSpeak/Core/Theme/Color+Theme.swift`.

### Palette
| Token | Hex | Role |
|-------|-----|------|
| `Color.brandGreen` | #89E219 | Primary CTAs, active states, branding |
| `Color.primaryVariant` | #58CC02 | Gradients, button depth, shadows |
| `Color.textGray` | #4B4B4B 	| Body text, icons, borders |
| `Color.errorRed` | #FF4B4B | Errors, destructive actions |
| `Color.warningOrange` | #FF9600 | Warnings, streaks |
| `Color.rewardYellow` | #FFC800 | Rewards, gems, stars |
| `Color.lightBlue` | #1CB0F6 | Secondary buttons, tooltips |
| `Color.infoBlue` | #2B70C9 | Lesson icons, navigation, high-band scores |

### Key Rules
- All blue-purple gradients → `brandGreen + primaryVariant`
- Score colors: high (≥8) = brandGreen, mid-high (6.5-8) = infoBlue, mid (5-6.5) = warningOrange, low = errorRed
- Tab bar tint = `brandGreen`
- AccentColor.colorset updated to #89E219

## Architecture
- Entry: `IELTSpeakApp.swift` → `MainView.swift` → `ContentView.swift`
- Tab bar: Home, Lesson, Leaderboard, Settings
- Auth: Supabase magic link (email OTP)
- Test simulation: `TestSimulationManager.swift` (core engine)

## Custom Fonts
Fredoka family registered in UIAppFonts: Light, Regular, Medium, SemiBold, Bold.
Usage: `.font(.custom("Fredoka-Medium", size: 18))`

## Backend
- Supabase URL: roovqypkzhynhrzzafre.supabase.co
- Default template ID: 550e8400-e29b-41d4-a716-446655440000
