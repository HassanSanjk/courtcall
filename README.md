# CourtCall

A mobile app for coordinating informal sports sessions in Malaysia. Built with Flutter and Firebase.

## About

CourtCall connects **organizers**, **players**, and **venue owners** in a single platform - no more scattered WhatsApp chats for RSVPs, payments, and court bookings. Create a session, invite your group, collect fees via DuitNow QR, and manage everything from one dashboard.

## Tech Stack

- **Framework:** Flutter (Dart)
- **Architecture:** MVVM with Provider
- **Backend:** Firebase (Firestore, Auth, Cloud Messaging)
- **Maps:** Google Maps Flutter
- **Navigation:** GoRouter

## Features

### Session Organizer
- Create & schedule sessions in under 30 seconds
- Live RSVP tracking with reminders
- Payment ledger with DuitNow QR / FPX
- Cancellation broadcast & waitlist auto-promotion

### Regular Player
- One-tap RSVP via push or WhatsApp link
- See who else is attending before committing
- Pay session fees in-app
- Join waitlists with auto-promotion

### Venue Owner
- Publish live court availability
- Manage bookings & deposits
- Broadcast freed slots for instant resale
- View occupancy & revenue analytics

## Getting Started

```bash
flutter pub get
flutter run
```

Make sure you have a Firebase project set up and the `google-services.json` / `GoogleService-Info.plist` placed in the respective platform folders.

## Project Structure

```
lib/
├── core/           # Theme, widgets, router
├── features/       # Screens & ViewModels by role
│   ├── organizer/
│   ├── venue/
│   └── maps/
└── repositories/   # Data layer (Firestore + mocks)
```

## Team

Group 5 - MAE Project, 2026
