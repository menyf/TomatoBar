<p align="center">
<img src="https://raw.githubusercontent.com/menyf/TomatoBar/main/TomatoBar/Assets.xcassets/AppIcon.appiconset/icon_128x128%402x.png" width="128" height="128"/>
<p>

<h1 align="center">TomatoBar</h1>
<p align="center">
<em>A fork of <a href="https://github.com/ivoronin/TomatoBar">ivoronin/TomatoBar</a> with additional features</em>
</p>

<img
  src="https://github.com/menyf/TomatoBar/raw/main/screenshot.gif?raw=true"
  alt="Screenshot"
  width="50%"
  align="right"
/>

## Overview
Have you ever heard of Pomodoro? It's a great technique to help you keep track of time and stay on task during your studies or work. Read more about it on <a href="https://en.wikipedia.org/wiki/Pomodoro_Technique">Wikipedia</a>.

TomatoBar is world's neatest Pomodoro timer for the macOS menu bar. All the essential features are here - configurable work and rest intervals, optional sounds, discreet actionable notifications, global hotkey.

TomatoBar is fully sandboxed with no entitlements.

## Features

This fork includes additional features:

- **Task Tracking** - Add and manage tasks during your pomodoro sessions
- **Manual Break Start** - Option to manually start breaks instead of auto-starting
- **Improved UI** - Refined button styles and dynamic content sizing

## Installation

Download the latest release <a href="https://github.com/menyf/TomatoBar/releases/latest/">here</a>.

Or build from source:
```bash
git clone https://github.com/menyf/TomatoBar.git
cd TomatoBar
open TomatoBar.xcodeproj
# Build and run with Cmd+R in Xcode
```

## Integration with other tools

### Event log
TomatoBar logs state transitions in JSON format to `~/Library/Containers/com.github.ivoronin.TomatoBar/Data/Library/Caches/TomatoBar.log`. Use this data to analyze your productivity and enrich other data sources.

### Starting and stopping the timer
TomatoBar can be controlled using `tomatobar://` URLs. To start or stop the timer from the command line, use `open tomatobar://startStop`.

## Credits

Originally created by [Ilya Voronin](https://github.com/ivoronin/TomatoBar).

## Licenses
- Timer sounds are licensed from buddhabeats
