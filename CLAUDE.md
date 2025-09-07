# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter Obsidian Clone - A note-taking application inspired by Obsidian, built with Flutter. The app features a multi-view interface with note editing, graph visualization, settings management, and export functionality.

## Commands

### Development
- `flutter run -d chrome --web-port=8080` - Run in Chrome browser
- `flutter run -d macos` - Run on macOS
- `flutter build web` - Build for web
- `flutter build macos` - Build for macOS

### Code Quality
- `flutter analyze` - Run static analysis
- `flutter test` - Run tests
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies

## Architecture

### State Management
Uses Provider pattern for state management:
- `AppState` (lib/models/app_state.dart) - Central state management with ChangeNotifier
- `AppSettings` (lib/models/app_settings.dart) - Settings model with JSON serialization
- Manages notes collection, selected note, current view, and note creation flow
- Three main views: editor, graphView, settings

### Core Models
- `Note` (lib/models/note.dart) - Note data model with JSON serialization
- `AppSettings` (lib/models/app_settings.dart) - Application settings model
- Contains id, title, content, createdAt, modifiedAt fields for notes

### UI Structure
Main layout follows a three-panel design:
- `TopNavigationBar` (lib/widgets/top_navigation_bar.dart) - App controls and view switching
- `Sidebar` (lib/widgets/sidebar.dart) - Notes list and navigation (280px fixed width)
- `ContentArea` (lib/widgets/content_area.dart) - Dynamic content based on current view
- Entry point: `MainScreen` (lib/screens/main_screen.dart)

### View System
Content area switches between:
- `EditorView` (lib/widgets/editor_view.dart) - Rich text note editing with Flutter Quill
- `GraphView` (lib/widgets/graph_view.dart) - Graph visualization of notes
- `SettingsView` (lib/widgets/settings_view.dart) - Application settings
- `WelcomeScreen` (lib/widgets/welcome_screen.dart) - Shown when no note is selected

### Services
- `NotesStorage` (lib/services/notes_storage.dart) - File-based note persistence using JSON
- `SettingsStorage` (lib/services/settings_storage.dart) - Settings persistence
- `ExportService` (lib/services/export_service.dart) - Abstract export interface
- `ExportServiceDesktop` (lib/services/export_service_desktop.dart) - Desktop export implementation
- `ExportServiceWeb` (lib/services/export_service_web.dart) - Web export implementation
- Uses `path_provider` to store notes in app documents directory
- Auto-saves notes with debounced timer to prevent excessive writes

### Dependencies
- `provider: ^6.1.1` - State management
- `path_provider: ^2.1.2` - File system path access
- `markdown_widget: ^2.3.2+6` - Markdown rendering
- `archive: ^3.4.10` - Archive creation for exports
- `file_picker: ^8.0.0+1` - File picking functionality
- `flutter_quill: ^11.4.2` - Rich text editor
- `flutter_quill_extensions: ^11.0.0` - Quill extensions
- `flutter_localizations` - Localization support
- `flutter_lints: ^5.0.0` - Linting rules

### Theming
Uses dark theme with red accent colors:
- Background: #1a1a1a
- Surface: #2a2a2a
- Dividers: #404040
- Primary: Red/RedAccent

### Export Functionality
Supports multiple export formats:
- Individual notes as Markdown, HTML, or PDF
- Bulk export as ZIP archives
- Platform-specific implementations for web and desktop