# Event App

Flutter mobile application for participants and event staff. It connects to `event-platform-backend` for all events, categories, schedules, registrations, payments, tickets, check-ins, feedback, sponsorship inquiries, volunteer applications, notifications, teams, guardians, and profile data.

## Prerequisites

- Flutter 3.22 or newer
- Dart 3.4 or newer
- Android Studio and an Android emulator/device, or Xcode and an iOS simulator/device
- A running Event Platform Backend

Install dependencies:

```bash
cd /Users/dishajain/Desktop/event_app
flutter pub get
```

If this checkout does not contain generated native platform files, create them once without replacing the Dart source:

```bash
flutter create .
flutter pub get
```

## Backend URL Configuration

The app reads compile-time values from `--dart-define-from-file`. Existing configurations are:

- `config/development.json`: Android emulator, backend on host port 8001 (`10.0.2.2`)
- `config/staging.json`: staging API placeholder
- `config/production.json`: production API placeholder
- `config/development.physical-device.example.json`: template for a physical device

Start the backend on port 8001 for the default development file:

```bash
flutter run \
  --target lib/main_development.dart \
  --dart-define-from-file=config/development.json
```

If the backend uses a different Docker or host port, copy the development config to a gitignored local file and change the URL accordingly:

```bash
cp config/development.json config/development.local.json
```

For a physical device, replace `10.0.2.2` with the host computer's LAN IP and ensure the device and backend are on the same network. Never commit a personal LAN IP or production secret.

## Guest-First Behavior

Fresh app launches do not require login. Guests can browse public events, event details, categories, venues, schedules, sponsors, public competition content, and published media.

Authentication is requested when a user performs an identity-dependent action, including event registration, child/other-participant/team actions, feedback submission, payments, viewing personal registrations or tickets, profile actions, and staff actions.

The original route/action is preserved through mobile-number OTP authentication. After successful verification, the app returns to the protected action instead of forcing the user to restart. Logout returns the app to guest browsing. The backend independently rejects unauthenticated protected API calls.

## Device Permissions

### Android

Add this permission to `android/app/src/main/AndroidManifest.xml` if it is not already present:

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS

Add `NSCameraUsageDescription` to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Used to scan participant tickets at event check-in.</string>
```

The camera is used by Staff Mode for Code 128 ticket scanning. Razorpay and barcode plugins should be tested on a real device before release.

## Main User Flows

### Participant

1. Open the app as Guest.
2. Browse or search published events and categories.
3. Open event details and choose Register.
4. Complete mobile OTP authentication if required.
5. Select Viewer/Participant or another configured participation type.
6. Register for self, child, other participant, or team when permitted.
7. Complete Razorpay payment for paid events.
8. View the confirmed registration and signed Code 128 barcode ticket.

### Staff

1. Authenticate with an account assigned to an event-scoped staff role.
2. Switch from Public Mode to Staff Mode.
3. Use My Events and assigned event tasks.
4. Scan a ticket QR code or use manual ticket-code entry.
5. The backend validates the QR signature, event scope, payment/registration state, ticket status, and duplicate check-in state.
6. Offline scans are queued locally and synchronized when connectivity returns; the backend remains authoritative.

## Run and Build Commands

Development:

```bash
flutter run --target lib/main_development.dart --dart-define-from-file=config/development.json
```

Staging:

```bash
flutter run --target lib/main_staging.dart --dart-define-from-file=config/staging.json
```

Production Android build:

```bash
flutter build apk \
  --target lib/main_production.dart \
  --dart-define-from-file=config/production.json
```

Use the appropriate signing configuration and production API URL before distributing an artifact.

## Validation

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```

Also test on a real device for OTP delivery, Razorpay checkout, camera scanning, offline check-in synchronization, permissions, and deep-link/action-resume behavior.

## Architecture

```text
lib/app/                    App bootstrap and navigation
lib/core/                   API client, auth, config, errors, storage
lib/features/events/        Public event discovery and details
lib/features/registrations/ Registration and participant flows
lib/features/payments/      Razorpay order and verification flow
lib/features/tickets/       Ticket display and QR data
lib/features/staff_mode/    Staff assignments, scanning, review, check-in
lib/features/feedback/      Authenticated feedback
lib/features/sponsorships/  Public opportunities and authenticated inquiries
lib/features/volunteers/    Volunteer/Event Manager applications
```

All API calls use the shared Dio client and backend response models. Do not hardcode event IDs, categories, capacities, statuses, ticket data, or user-specific data in screens. Backend authorization and state are authoritative; the mobile UI presents the current response and handles loading, empty, error, guest, and authenticated states.

## Troubleshooting

### The app cannot reach the API

Check the selected config file. Android emulators use `10.0.2.2` for the host machine, while physical devices use the host LAN IP. Confirm the backend port, firewall, and that the API prefix ends in `/api/v1`.

### OTP does not arrive

In development, inspect backend logs for the configured stub behavior. In staging/production, configure the SMS provider and verify credentials and sender settings.

### Registration or ticket actions return 401/403

This is expected for guests or users without the required event/staff assignment. Complete OTP authentication and confirm the account owns the registration/ticket or has an active role for the event.

### QR scanning fails

Confirm camera permissions, that the ticket is paid/confirmed or valid for a free event, and that the code has not already been checked in or cancelled. The backend rejects altered QR payloads.
