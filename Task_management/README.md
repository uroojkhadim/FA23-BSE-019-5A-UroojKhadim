# Task Management App

A Flutter-based task management application with offline capabilities, local notifications, task repetition, export functionality, and Google Drive backup/sync.

## Features

- ✅ Offline functionality using SQLite local database
- 🔔 Local notifications for task reminders
- 🔄 Task repetition (daily, weekly, monthly, yearly)
- 📤 Export tasks to CSV files
- ☁️ Google Drive backup and sync
- 📱 Cross-platform support (Android, iOS, Web, Desktop)

## Prerequisites

- Flutter SDK (3.9.2 or higher)
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

## Getting Started

1. Clone or download this repository
2. Run `flutter pub get` to install dependencies
3. Connect a mobile device or start an emulator/simulator
4. Run `flutter run` to build and deploy the app

## Running on Mobile

### Android

1. Connect an Android device via USB with debugging enabled, or
2. Start an Android Emulator from Android Studio
3. Run `flutter run` in the project directory

### iOS (macOS only)

1. Connect an iOS device via USB, or
2. Start an iOS Simulator from Xcode
3. Run `flutter run` in the project directory

## Features Overview

### Task Management
- Create, read, update, and delete tasks
- Set due dates with calendar picker
- Assign priority levels (low, medium, high)
- Mark tasks as complete/incomplete
- Add detailed descriptions to tasks

### Task Repetition
- Set tasks to repeat daily, weekly, monthly, or yearly
- Recurring tasks automatically generate new instances

### Notifications
- Local notifications for task due dates
- Automatic notification scheduling when tasks are created/updated
- Notification cancellation when tasks are completed or deleted

### Export & Backup
- Export all tasks to CSV format
- Backup tasks to Google Drive
- Restore tasks from Google Drive backups

### Settings
- Toggle between showing/hiding completed tasks
- Export tasks to local storage
- Google Drive integration for backup and sync

## Dependencies

- `sqflite`: Local database for offline storage
- `flutter_local_notifications`: Local notifications
- `path_provider`: File system access
- `csv`: CSV file generation
- `googleapis`: Google Drive integration
- `google_sign_in`: Google authentication
- `jiffy`: Date/time utilities

## Folder Structure

```
lib/
├── main.dart              # Entry point
├── models/                # Data models
│   └── task.dart          # Task model with enums
├── services/              # Business logic
│   ├── database_service.dart      # SQLite database operations
│   ├── notification_service.dart  # Local notification management
│   ├── export_service.dart        # CSV export functionality
│   └── google_drive_service.dart  # Google Drive integration
├── screens/               # UI screens
│   ├── main_screen.dart           # Main screen with tabs
│   ├── task_list_screen.dart      # Task list view
│   └── task_form_screen.dart      # Task creation/editing form
```

## Mobile-Specific Configurations

### Android
- Permissions for notifications and boot completion
- Notification receivers for handling scheduled notifications
- Proper manifest configuration for all required permissions

### iOS
- Notification permissions in Info.plist
- AppDelegate configuration for notification handling
- Proper permission descriptions for App Store compliance

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a pull request

## License

This project is licensed under the MIT License.