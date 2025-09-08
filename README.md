# Flutter Obsidian Clone

A powerful note-taking application inspired by Obsidian, built with Flutter. Features a clean, modern interface with rich text editing, graph visualization, and comprehensive export capabilities.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## Features

- **Rich Text Editing**: Powered by Flutter Quill for advanced text formatting
- **Multi-View Interface**: Switch between Editor, Graph, and Settings views
- **Graph Visualization**: Visual representation of note connections
- **Export Functionality**: Export notes as Markdown, HTML, or PDF
- **Bulk Export**: Create ZIP archives of multiple notes
- **Dark/Light Theme**: Customizable theming with red accent color
- **Auto-Save**: Automatic note saving with debounced writes
- **Cross-Platform**: Runs on Web, macOS, Windows, and Linux

## Screenshots

*Coming soon...*

## Getting Started

### Prerequisites

- Flutter SDK: `^3.8.1` or higher is recommended.
- Dart SDK: `^3.8.1` or higher is recommended.

### Installation

1. Clone the repository:
```bash
git clone https://github.com/acass/obsidiclone.git
cd obsidiclone
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
# For web development
flutter run -d chrome --web-port=8080

# For macOS
flutter run -d macos
```

## Development Commands

### Running the App
```bash
flutter run -d chrome --web-port=8080  # Web browser
flutter run -d macos                   # macOS desktop
```

### Building
```bash
flutter build web    # Build for web
flutter build macos  # Build for macOS
```

### Code Quality
```bash
flutter analyze      # Static analysis
flutter test         # Run tests
flutter test --coverage # Run tests with coverage
flutter pub get      # Install dependencies
flutter pub upgrade  # Upgrade dependencies
```

## Project Structure

The project is organized into the following main directories:

- `lib/`: Contains the main source code of the application.
  - `main.dart`: The entry point of the application.
  - `models/`: Contains the data models for the app, like `Note`, `AppSettings`, and `AppState`.
  - `services/`: Contains services for things like storage (`notes_storage.dart`, `settings_storage.dart`) and exporting (`export_service.dart`).
  - `screens/`: Contains the main screens of the application.
  - `widgets/`: Contains the reusable UI widgets.
- `test/`: Contains all the tests for the application.
- `web/`: Contains the web-specific files.
- `macos/`: Contains the macOS-specific files.

## Architecture

### State Management
- **Provider Pattern**: Centralized state management with `ChangeNotifier`.
- **AppState**: Main application state managing notes, views, and navigation.
- **AppSettings**: Persistent settings with JSON serialization.
- **Dependency Injection**: The `AppState` class is designed to allow for dependency injection of storage services, which makes it easier to test.

### Core Components

#### Models
- `Note`: Note data model with metadata (ID, title, content, timestamps).
- `AppSettings`: Application configuration and preferences.

#### Services
- `NotesStorage`: File-based note persistence using JSON.
- `SettingsStorage`: Settings persistence.
- `ExportService`: Abstract export interface with platform-specific implementations.

#### UI Structure
- `MainScreen`: Primary application layout.
- `TopNavigationBar`: App controls and view switching.
- `Sidebar`: Notes list and navigation (280px fixed).
- `ContentArea`: Dynamic content based on current view.
- `EditorView`: Rich text editing with Flutter Quill.
- `GraphView`: Interactive graph visualization.
- `SettingsView`: Application preferences.
- `WelcomeScreen`: Empty state when no note is selected.

### Theming

**Dark Theme**
- Background: `#1a1a1a`
- Surface: `#2a2a2a`
- Primary: `#ff3b30` (Red)

**Light Theme**
- Background: `#ffffff`
- Surface: `#f5f5f5`
- Primary: `#d32f2f` (Red)

## Dependencies

- `provider: ^6.1.1` - State management
- `flutter_quill: ^11.4.2` - Rich text editor
- `path_provider: ^2.1.2` - File system access
- `markdown_widget: ^2.3.2+6` - Markdown rendering
- `archive: ^3.4.10` - ZIP file creation
- `file_picker: ^8.0.0+1` - File selection

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by [Obsidian](https://obsidian.md/)
- Built with [Flutter](https://flutter.dev/)
- Rich text editing powered by [Flutter Quill](https://pub.dev/packages/flutter_quill)
