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

TomatoBar is a Pomodoro timer living in the macOS menu bar (~700 lines of Swift).

### Directory Structure

```
TomatoBar/
├── App/                    # Application entry and menu bar
│   ├── App.swift           # SwiftUI @main entry point
│   └── StatusItem.swift    # Menu bar status item controller
├── Core/                   # Business logic
│   ├── State.swift         # State machine types (TimerState/TimerEvent)
│   ├── Timer.swift         # Timer orchestration, state transitions
│   └── Task.swift          # Task model and persistence manager
├── Views/                  # SwiftUI views
│   ├── PopoverView.swift   # Main popover UI container
│   ├── IntervalsView.swift # Work/rest interval settings
│   ├── SettingsView.swift  # General settings (shortcuts, etc.)
│   ├── SoundsView.swift    # Sound volume controls
│   └── TasksView.swift     # Task list UI
├── Services/               # System integrations
│   ├── Logger.swift        # JSON event logger
│   ├── Player.swift        # Audio playback (windup, ding, ticking)
│   └── Notifications.swift # macOS notification handling
├── Assets.xcassets/        # Images and audio assets
├── en.lproj/               # English localization
├── zh-Hans.lproj/          # Simplified Chinese localization
└── Info.plist
```

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

States defined in `Core/State.swift`, transitions handled in `Core/Timer.swift`.

### Key Components

| File | Purpose |
|------|---------|
| `App/App.swift` | SwiftUI entry point, initializes status bar |
| `App/StatusItem.swift` | NSApplicationDelegate for menu bar integration |
| `Core/Timer.swift` | State machine orchestration, DispatchSourceTimer, URL scheme |
| `Core/State.swift` | TimerState and TimerEvent type definitions |
| `Core/Task.swift` | Task model with UserDefaults persistence |
| `Views/PopoverView.swift` | Main UI with tab navigation |
| `Views/IntervalsView.swift` | Work/rest duration steppers |
| `Views/SettingsView.swift` | Shortcuts, launch at login settings |
| `Views/SoundsView.swift` | Volume sliders for each sound |
| `Views/TasksView.swift` | Task list with add/complete/delete |
| `Services/Player.swift` | AVAudioPlayer wrapper for sounds |
| `Services/Notifications.swift` | UNUserNotificationCenter with "Skip Break" action |
| `Services/Logger.swift` | JSON event logger to caches directory |

### Data Flow

1. UI binds to `TBTimer` (ObservableObject) via `@EnvironmentObject`
2. User preferences stored via `@AppStorage` (auto-synced to UserDefaults)
3. State transitions trigger handlers that update icon, play sounds, send notifications
4. Menu bar icon/title updated through `TBStatusItem.shared`
5. Tasks managed by `TBTaskManager` with JSON persistence to UserDefaults

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
