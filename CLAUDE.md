# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is a macOS SwiftUI app. Open in Xcode and build/run with Cmd+R:
```bash
open TomatoBar.xcodeproj
```

Command-line build:
```bash
xcodebuild build -project TomatoBar.xcodeproj -scheme TomatoBar -configuration Debug
```

Release archive:
```bash
xcodebuild archive -project TomatoBar.xcodeproj -scheme TomatoBar -configuration Release -archivePath TomatoBar.xcarchive
```

## Architecture

TomatoBar is a Pomodoro timer living in the macOS menu bar (~450 lines of Swift).

### State Machine (Core Pattern)

The app uses SwiftState for a finite state machine with three states:

```
idle <--startStop--> work --timerFired--> rest --timerFired--> idle/work
                       ^                   |
                       +---skipRest--------+
```

- **idle**: Timer stopped
- **work**: Active work session (default 25 min)
- **rest**: Break period (short: 5 min, long: 15 min after 4 work intervals)

States defined in `State.swift`, transitions handled in `Timer.swift`.

### Key Components

| File | Purpose |
|------|---------|
| `App.swift` | SwiftUI entry point + NSApplicationDelegate for menu bar integration (TBStatusItem) |
| `Timer.swift` | Core logic - state machine orchestration, DispatchSourceTimer, URL scheme handling |
| `View.swift` | SwiftUI views - TBPopoverView (main UI), IntervalsView, SettingsView, SoundsView |
| `Player.swift` | Audio playback (windup, ding, ticking sounds) with per-sound volume control |
| `Notifications.swift` | UNUserNotificationCenter wrapper with "Skip Break" action support |
| `Log.swift` | JSON event logger to `~/Library/Caches/TomatoBar.log` |
| `State.swift` | State machine type definitions |

### Data Flow

1. UI binds to `TBTimer` (ObservableObject) via `@EnvironmentObject`
2. User preferences stored via `@AppStorage` (auto-synced to UserDefaults)
3. State transitions trigger handlers that update icon, play sounds, send notifications
4. Menu bar icon/title updated through `TBStatusItem.shared`

### External Dependencies (SPM)

- **SwiftState** - State machine
- **KeyboardShortcuts** - Global hotkey (default: Cmd+Shift+A)
- **LaunchAtLogin** - Login item support

## Integration Points

- **URL Scheme**: `open tomatobar://startStop` toggles timer externally
- **Event Log**: JSON at `~/Library/Containers/com.github.ivoronin.TomatoBar/Data/Library/Caches/TomatoBar.log`

## Localization

Supported: English (en), Simplified Chinese (zh-Hans). Strings in `Localizable.strings`.

## Constraints

- Deployment target: macOS 11.0 (Big Sur)+
- Fully sandboxed with no entitlements
- No network access
