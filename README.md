# Chicken Recipes Hot 🍗🔥

A comprehensive chicken recipe mobile application built with Flutter, featuring 50+ delicious recipes from around the world.

## Features

- **50+ Recipes** - Soups, Main Dishes, Snacks, and Spicy recipes
- **Search & Filter** - Find recipes by name or category
- **Favorites** - Save your favorite recipes
- **Servings Calculator** - Adjust ingredients for any serving size
- **Cooking Timer** - Built-in timer with sound notifications
- **Cook Mode** - Step-by-step cooking with keep-awake screen
- **Shopping List** - Add ingredients from any recipe
- **Recipe Notes** - Add personal notes to recipes
- **Rating System** - Rate recipes you've tried
- **Cooking History** - Track which recipes you've made
- **Share Recipes** - Share with friends and family
- **Nutritional Info** - Calories, protein, carbs, fat per serving
- **Onboarding** - Introduction for new users

## Architecture

Clean Architecture with:
- **Domain Layer** - Entities, Repository interfaces, Use cases
- **Data Layer** - Models, Data sources, Repository implementations
- **Presentation Layer** - Screens, Widgets, Providers (State Management)

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- FVM (Flutter Version Management) - recommended

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd checken_road
```

2. Copy IDE settings (optional):
```bash
cp -r .vscode.example .vscode
```

3. Install Flutter version with FVM:
```bash
fvm install
fvm use
```

4. Install dependencies:
```bash
fvm flutter pub get
```

5. Run the app:
```bash
fvm flutter run
```

### Install Git Hooks (Recommended)

```bash
# macOS/Linux
./scripts/install-hooks.sh

# Windows - run manually before commits
powershell -ExecutionPolicy Bypass -File scripts\check-secrets.ps1
```

## Project Structure

```
lib/
├── domain/
│   ├── entities/          # Business entities
│   ├── repositories/      # Repository interfaces
│   └── usecases/          # Business logic
├── data/
│   ├── datasources/       # Data sources (local, remote)
│   ├── models/            # Data models
│   └── repositories/      # Repository implementations
├── presentation/
│   ├── providers/         # State management
│   ├── screens/           # App screens
│   └── widgets/           # Reusable widgets
└── main.dart              # App entry point
```

## Security

This project follows a **Zero-Trace Policy**. See [SECURITY.md](SECURITY.md) for details.

**Never commit:**
- Environment files (`.env`)
- API keys or secrets
- Local configuration (`local.properties`)
- IDE user settings
- Build artifacts

## Building for Production

**Important:** Release builds should only be done in CI/CD pipeline.

For development builds:
```bash
fvm flutter build apk --debug
fvm flutter build ios --debug --no-codesign
```

## License

This project is private. All rights reserved.
