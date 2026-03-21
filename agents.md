# Agents.md

## 1. System Overview
**ScreenPet** is a gamified digital wellbeing iOS app.

- **Core Loop**: The user starts with a "Healthy" pet at 100% health at 4:00 AM.
- **Decay**: As the user spends time on "Distracting" apps (Social Media, Games), the pet’s health decays.
- **Goal**: Maintain pet health by staying under screen time limits.
- **Primary UI**: The pet lives in the Dynamic Island and Live Activities for constant visibility.

## 2. Technical Stack
- **Language**: Swift 6 / SwiftUI
- **Frameworks**:
    - **FamilyControls & DeviceActivity**: For screen time monitoring.
    - **ActivityKit**: For Dynamic Island/Live Activity "Nudge."
    - **RiveRuntime**: For state-machine driven pet animations.
    - **SwiftData**: For persisting pet history and user settings.

## 3. Core Logic Agents

### A. Vitality Manager (State Logic)
- **State Property**: `health` (Double, 0.0 to 1.0).
- **Decay Formula**:
  $$ Health_{current} = Health_{initial} - (UsageMinutes \times DecayRate) $$
- **Decay Rates**:
    - **Distracting Apps**: -1% per minute.
    - **Educational/Work Apps**: 0% decay.
    - **Phone Locked (Bonus)**: +0.5% per 10 minutes (Recovery).
- **Daily Reset**: At 04:00, health resets to 1.0. If health was 0.0 at the end of the previous day, the pet is "Revived" with a "Scar" (Persistent tally).

### B. Device Activity Monitor (The Listener)
- Implement a `DeviceActivityMonitorExtension`.
- Monitor specific `ActivityCategory` (Social, Games, Entertainment).
- When a threshold is reached (e.g., every 5-minute increment), call the Vitality Manager to deduct health.

### C. Live Activity Agent (The Nudge)
- Initialize a `LiveActivity` session on app launch.
- **Dynamic Island (Compact)**: Shows the pet icon and a small health ring.
- **Dynamic Island (Expanded)**: Shows the animated pet and a "Time Remaining" countdown before the next health drop.
- **Constraints**: Must update via push notifications or background tasks to stay within the 12-hour Live Activity limit.

## 4. Pet States & Visuals

### A. States (Health Driven)
The pet's state is determined by the `health` value (0-100).

| State | Health Range | Description | Asset Name |
| :--- | :--- | :--- | :--- |
| **Happy** | 80% - 100% | Pet is energetic, happy, glowing. | `1_pet_happy` |
| **Neutral** | 40% - 79% | Pet is content but normal. | `2_pet_neutral` |
| **Sad** | 10% - 39% | Pet looks tired, droopy, maybe glitching. | `3_pet_sad` |
| **Critical** | < 10% | Pet looks very sick, fainting, close to death. | `4_pet_critical` |
| **Sleeping** | (Time-based)| Active during "Sleeping Hours" (e.g. 10 PM - 6 AM) or DND. | `0_pet_sleeping` |

### B. Asset Requirements (Phase 1: Static PNGs)
For the initial implementation, we will use static PNG images to establish the visual identity before moving to Rive animations.

- **File Format**: PNG
- **Background**: Transparent
- **Resolution**: ~500x500px (recommended for high DPI displays)
- **Location**: `Mimic/Assets.xcassets`
- **Action**: Create a **New Image Set** for each state with the exact names listed above. Note: User has provided assets: `0_pet_sleeping`, `1_pet_happy`, `2_pet_neutral`, `3_pet_sad`, `4_pet_critical`.

### C. Animation Mapping (Future: Rive State Machine)
Eventually, these states will map to Rive inputs:
- **Input**: `healthValue` (Double): 0-100.
- **Triggers**: "Happy/Idle", "Neutral/Bored", "Sad/Tired", "Fainting".

## 5. Implementation Rules for the AI Agent
- **Privacy First**: Never attempt to log specific app names; only use Apple's DeviceActivity categories to protect user privacy.
- **Battery Efficiency**: Limit Live Activity updates to once every minute or when a significant health change occurs.
- **State Persistence**: Always save the current health and lastUpdateTimestamp to UserDefaults or SwiftData to prevent data loss on app kill.
- **Keep `agents.md` Updated**: Whenever a new component, feature, folder, or external asset (website, tool, etc.) is added to this repository, this file must be updated accordingly to reflect the change. This applies to both the AI agent and the developer.

---

## 6. Pet Modes (Variants)

The app supports 3 emotional narrative modes. Users can switch via Settings. **Default: Guardian**.

| Mode | Enum Value | Pet Identity | Core Emotion |
|:---|:---|:---|:---|
| **The Reflection** | `.reflection` | Digital twin of user | Self-compassion |
| **The Guardian** | `.guardian` | Vulnerable creature to protect | Protective duty |
| **The Echo** | `.echo` | User's future self | Aspiration |

### Guardian Mode (Default) — Key Elements
- **Pet Name**: Lumi (fixed for MVP)
- **Narrative**: User is protector; phone is habitat
- **Sanctuary Stages**: 3 levels (Barren → Growing → Paradise)
- **Rescue Missions**: Simple "Put your phone down" prompt
- **Notifications**: At health thresholds (75%, 50%, 25%)

### Implementation
- `PetMode` enum in `PetMode.swift`
- Mode-specific narrative in `Narrative/<ModeName>Narrative.swift`
- Current mode stored in `UserDefaults` via `@AppStorage("petMode")`

---

## 7. Design System & UI/UX Development Rules

> [!IMPORTANT]
> All design-related documentation, including our design system tokens, colors, typography, and spacing rules, has been moved to `design.md`.
> Please refer to `design.md` for any UI/UX implementation details.

---

## 8. Repository Structure

This repository contains more than just the iOS app. Below is an overview of all major components:

| Folder / File | Description |
|:---|:---|
| `Mimic/` | Main iOS app source code (SwiftUI, Swift 6) |
| `PetWidgetExtension/` | Home screen & lock screen widget target |
| `DeviceActivityMonitorExtension/` | Screen time monitoring extension |
| `docs/` | **Landing page** hosted via GitHub Pages at `www.life-strategizer.com` |
| `Desktop Landing Page/` | Original source file for the landing page (for reference) |
| `design.md` | Design system tokens, colors, typography, spacing |
| `agents.md` | This file — system overview and AI agent rules |

### Landing Page (`docs/index.html`)
- A single-page HTML/CSS marketing site for the Mimic app
- Uses **Tailwind CSS** (CDN) and **Plus Jakarta Sans** (Google Fonts)
- Sections: Hero, Cycle of Care, Modes (Guardian / Reflection / Echo), Live Activities, CTA, Footer
- Hosted via **GitHub Pages** connected to the custom domain `www.life-strategizer.com` via Strato DNS

