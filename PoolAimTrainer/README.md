# 🎱 Pool Aim Trainer (iOS)

A native iPhone **aiming-practice** app for 8-ball / pool players. It is a
**standalone trainer** — an in-app pool table with real physics that teaches you
the *ghost-ball* method, cut angles, and rail reflections so you improve in the
real game through practice.

> **Not a cheat / overlay.** This app does **not** read, overlay, or interact
> with *8 Ball Pool* or any other app. iOS sandboxing makes that impossible, and
> overlaying a live online match would violate the game's terms and get accounts
> banned. This is a legitimate skill trainer you play inside.

## What it does

- **Interactive table** (SwiftUI + SpriteKit) with real ball, cushion and pocket physics.
- **Ghost-ball guide** — drag to aim and see exactly where the cue ball must
  strike the object ball to send it toward the pocket.
- **Live cut-angle readout** so you learn how thin/thick a cut is.
- **Predicted object-ball path** drawn from the target ball.
- **Rail reflection preview** when you aim at a cushion.
- **Shoot** with adjustable power and watch the physics confirm the prediction.
- **Rack** (triangle) and **Scatter** layouts for varied practice.
- Toggle guides off to test yourself.

## How the aiming math works

`AimCalculator.swift` is pure geometry (no SpriteKit), so it's easy to reason
about and test:

1. Cast a ray from the cue-ball center along the aim direction.
2. Find the nearest contact — either an object ball (ray vs. a circle of radius
   `2R` around the target center) or a cushion (ray vs. the inset play rectangle).
3. For a ball hit, the contact point is the **ghost ball** center; the object
   ball then travels along `targetCenter − ghostCenter`. The angle between the
   cue path and that line is the **cut angle**.

The SpriteKit cushion edge loop is inset by one ball radius so that *centers*
bounce exactly where the math predicts — the guide and the simulation agree.

## Project layout

```
PoolAimTrainer/
├─ PoolAimTrainer.xcodeproj      # open this in Xcode
└─ PoolAimTrainer/
   ├─ PoolAimTrainerApp.swift    # @main entry
   ├─ ContentView.swift          # SwiftUI shell + control panel
   ├─ PoolTableScene.swift       # SpriteKit table, physics, guide drawing
   ├─ AimCalculator.swift        # pure-geometry ghost-ball / cut-angle solver
   └─ GameModel.swift            # shared state between UI and scene
```

## Build & run

- **Requirements:** Xcode 15+, iOS 16+.
- Open `PoolAimTrainer.xcodeproj`, pick an iPhone simulator, press **Run**.
- To run on a device, set your own signing team in
  *Target → Signing & Capabilities* (bundle id `com.pathly.PoolAimTrainer`).

### Command line

```bash
xcodebuild -project PoolAimTrainer.xcodeproj \
  -scheme PoolAimTrainer \
  -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## Roadmap ideas

- Save/replay shots and challenge scenarios.
- Spin (english) and throw modelling.
- Two-rail kick/bank solver.
- Practice drills with scoring.
