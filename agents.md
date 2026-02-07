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

## 4. Animation Mapping (Rive State Machine)
The Coding Agent should map health values to Rive State Machine inputs:

- **Input**: `healthValue` (Double): 0-100.
- **States**:
    - **100 - 80**: Trigger "Happy/Idle"
    - **79 - 40**: Trigger "Neutral/Bored"
    - **39 - 10**: Trigger "Sad/Tired"
    - **< 10**: Trigger "Fainting"

## 5. Implementation Rules for the AI Agent
- **Privacy First**: Never attempt to log specific app names; only use Apple's DeviceActivity categories to protect user privacy.
- **Battery Efficiency**: Limit Live Activity updates to once every minute or when a significant health change occurs.
- **State Persistence**: Always save the current health and lastUpdateTimestamp to UserDefaults or SwiftData to prevent data loss on app kill.
