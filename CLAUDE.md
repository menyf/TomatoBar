# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

macOS SwiftUI app. Open in Xcode and build/run with Cmd+R:
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

TomatoBar is a Pomodoro timer for the macOS menu bar. Fork of [ivoronin/TomatoBar](https://github.com/ivoronin/TomatoBar) with task tracking and manual break start features.

### Structure

- `App/` - Entry point and menu bar integration
- `Core/` - State machine (SwiftState), timer logic, task model
- `Views/` - SwiftUI views (popover, settings tabs)
- `Services/` - Audio, notifications, JSON logger

### State Machine

```
idle <--startStop--> work --timerFired--> rest --timerFired--> idle/work
                       ^                   |
                       +---skipRest--------+
```

States: `idle`, `work`, `rest`. Defined in `Core/State.swift`, transitions in `Core/Timer.swift`.

When `autoStartBreak` is disabled, work ends in `idle` with `pendingBreak=true`, waiting for manual `startBreak` event.

### Data Flow

- UI binds to `TBTimer` (ObservableObject) via `@EnvironmentObject`
- Preferences via `@AppStorage` (UserDefaults)
- Menu bar icon/title via `TBStatusItem.shared`
- Tasks via `TBTaskManager` (JSON in UserDefaults)

### Dependencies (SPM)

- **SwiftState** - State machine
- **KeyboardShortcuts** - Global hotkey (Cmd+Shift+A)
- **LaunchAtLogin** - Login item

## Integration

- **URL Scheme**: `open tomatobar://startStop`
- **Event Log**: `~/Library/Containers/com.github.ivoronin.TomatoBar/Data/Library/Caches/TomatoBar.log`

## Localization

English (en), Simplified Chinese (zh-Hans). Strings in `*.lproj/Localizable.strings`.

## Constraints

- macOS 11.0+ (Big Sur)
- Fully sandboxed, no entitlements, no network access
